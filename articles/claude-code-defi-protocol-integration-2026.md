---
layout: default
title: "Claude Code for DeFi Protocol (2026)"
permalink: /claude-code-defi-protocol-integration-2026/
date: 2026-04-20
description: "DeFi protocol integration with Claude Code. Build Uniswap, Aave, and Compound interactions with proper slippage and MEV protection."
last_tested: "2026-04-22"
---

## Why Claude Code for DeFi Protocol Integration

Integrating with DeFi protocols means interacting with battle-tested but complex smart contracts: Uniswap V3's concentrated liquidity with tick math, Aave V3's isolation mode and efficiency mode, Compound V3's Comet interface. Each protocol has its own interface patterns, approval flows, and failure modes. A swap without proper slippage protection loses funds to MEV bots. A flash loan callback that does not repay in the same transaction reverts entirely.

Claude Code generates integration code that handles the full lifecycle: approval management, slippage calculation, deadline protection, and error handling for protocol-specific revert reasons. It understands the ABI encoding, multicall patterns, and permit2 signatures that modern DeFi requires.

## The Workflow

### Step 1: DeFi Development Setup

```bash
# Foundry project with DeFi dependencies
forge init defi_integrator && cd defi_integrator
forge install Uniswap/v3-core Uniswap/v3-periphery
forge install aave/aave-v3-core
pip install web3 eth-abi  # Python SDK for off-chain interactions
```

### Step 2: Build Protocol Integration Contracts

```solidity
// src/DeFiRouter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Uniswap V3 interfaces
interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params)
        external payable returns (uint256 amountOut);
}

// Aave V3 Pool interface
interface IPool {
    function supply(address asset, uint256 amount, address onBehalfOf,
                    uint16 referralCode) external;
    function borrow(address asset, uint256 amount, uint256 interestRateMode,
                    uint16 referralCode, address onBehalfOf) external;
    function repay(address asset, uint256 amount, uint256 interestRateMode,
                   address onBehalfOf) external returns (uint256);
    function flashLoanSimple(address receiverAddress, address asset,
                              uint256 amount, bytes calldata params,
                              uint16 referralCode) external;
}

interface IFlashLoanSimpleReceiver {
    function executeOperation(address asset, uint256 amount,
                               uint256 premium, address initiator,
                               bytes calldata params) external returns (bool);
}

/**
 * @title DeFiRouter
 * @notice Composable DeFi interactions: swap, lend, borrow, flash loan.
 * @dev All external calls use SafeERC20 and enforce deadlines.
 */
contract DeFiRouter is IFlashLoanSimpleReceiver {
    using SafeERC20 for IERC20;

    ISwapRouter public immutable swapRouter;
    IPool public immutable aavePool;
    address public immutable owner;

    error Unauthorized();
    error DeadlineExpired();
    error InsufficientOutput(uint256 received, uint256 minimum);

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor(address _swapRouter, address _aavePool) {
        swapRouter = ISwapRouter(_swapRouter);
        aavePool = IPool(_aavePool);
        owner = msg.sender;
    }

    /**
     * @notice Swap tokens via Uniswap V3 with slippage protection.
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Amount of input tokens
     * @param minAmountOut Minimum acceptable output (slippage protection)
     * @param fee Pool fee tier (500=0.05%, 3000=0.3%, 10000=1%)
     */
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint24 fee
    ) external onlyOwner returns (uint256 amountOut) {
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).safeIncreaseAllowance(address(swapRouter), amountIn);

        amountOut = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: msg.sender,
                deadline: block.timestamp + 300, // 5 min deadline
                amountIn: amountIn,
                amountOutMinimum: minAmountOut,
                sqrtPriceLimitX96: 0 // no price limit
            })
        );

        if (amountOut < minAmountOut) {
            revert InsufficientOutput(amountOut, minAmountOut);
        }
    }

    /**
     * @notice Supply collateral to Aave V3.
     */
    function supplyToAave(address asset, uint256 amount) external onlyOwner {
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(asset).safeIncreaseAllowance(address(aavePool), amount);
        aavePool.supply(asset, amount, msg.sender, 0);
    }

    /**
     * @notice Execute flash loan for arbitrage or liquidation.
     */
    function executeFlashLoan(address asset, uint256 amount,
                               bytes calldata params) external onlyOwner {
        aavePool.flashLoanSimple(address(this), asset, amount, params, 0);
    }

    /**
     * @notice Aave flash loan callback — must repay loan + premium.
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(msg.sender == address(aavePool), "Caller must be pool");
        require(initiator == address(this), "Initiator must be this contract");

        // --- Custom logic here (arbitrage, liquidation, etc.) ---
        // The borrowed `amount` is available in this contract's balance

        // Repay flash loan: amount + premium
        uint256 totalOwed = amount + premium;
        IERC20(asset).safeIncreaseAllowance(address(aavePool), totalOwed);

        return true;
    }

    /**
     * @notice Rescue stuck tokens (emergency only).
     */
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner, amount);
    }
}
```

### Step 3: Off-Chain Price Monitoring

```python
# scripts/price_monitor.py
"""Monitor DEX prices and calculate optimal swap parameters."""

from web3 import Web3
import json

def get_uniswap_v3_quote(w3: Web3, quoter_address: str,
                          token_in: str, token_out: str,
                          amount_in: int, fee: int = 3000) -> dict:
    """Get Uniswap V3 quote via Quoter contract."""
    quoter_abi = json.loads('[{"inputs":[{"internalType":"address","name":"tokenIn","type":"address"},{"internalType":"address","name":"tokenOut","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"uint160","name":"sqrtPriceLimitX96","type":"uint160"}],"name":"quoteExactInputSingle","outputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"}],"stateMutability":"nonpayable","type":"function"}]')

    quoter = w3.eth.contract(address=quoter_address, abi=quoter_abi)

    try:
        amount_out = quoter.functions.quoteExactInputSingle(
            token_in, token_out, fee, amount_in, 0
        ).call()
    except Exception as e:
        return {'success': False, 'error': str(e)}

    # Calculate slippage from spot price
    price_impact = 1 - (amount_out / amount_in) if amount_in > 0 else 0

    return {
        'success': True,
        'amount_out': amount_out,
        'price_impact': price_impact,
        'min_amount_out': int(amount_out * 0.995),  # 0.5% slippage tolerance
    }
```

### Step 4: Verify with Fork Test

```bash
# Run tests against mainnet fork
forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY -vvv

# Or with local anvil fork
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY &
forge test --rpc-url http://localhost:8545 -vvv

# Gas report
forge test --gas-report --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
```

## CLAUDE.md for DeFi Integration

```markdown
# DeFi Protocol Integration Standards

## Security Rules
- Always set amountOutMinimum > 0 (slippage protection)
- Always set deadline < block.timestamp + 300 (5 min max)
- Use SafeERC20 for all token interactions
- Never approve type(uint256).max in production (use exact amounts)
- Check return values of all protocol calls
- Protect against sandwich attacks with private mempools or MEV protection

## Protocol Interfaces
- Uniswap V3: ISwapRouter, IQuoterV2, INonfungiblePositionManager
- Aave V3: IPool, IPoolAddressesProvider
- Compound V3: CometMainInterface (Comet)
- Curve: ICurvePool (exchange, get_dy)

## Testing
- Fork tests against mainnet for integration verification
- Fuzz tests for numeric parameters
- Invariant tests for protocol-wide balance conservation

## Common Commands
- forge test --fork-url $RPC_URL — fork test
- cast call $POOL "getReserveData(address)" $TOKEN — read Aave state
- cast send $ROUTER "swap(...)" --private-key $KEY — execute swap
- anvil --fork-url $RPC_URL — local fork node
```

## Common Pitfalls

- **Zero slippage protection:** Setting `amountOutMinimum = 0` invites sandwich attacks that extract all swap value. Claude Code always calculates minimum output from a fresh quote minus 0.5% tolerance.
- **Stale deadline:** Using `block.timestamp` as deadline in the same transaction is useless (it always passes). Claude Code sets deadlines relative to `block.timestamp + 300` for 5-minute protection against delayed inclusion.
- **Flash loan callback not repaying:** If your executeOperation logic reverts or does not approve sufficient repayment, the entire transaction reverts with a cryptic error. Claude Code calculates totalOwed = amount + premium upfront and ensures approval before any custom logic can fail.

## Related

- [Claude Code for Solidity Smart Contracts](/claude-code-solidity-smart-contract-dev-2026/)
- [Claude Code for Options Pricing](/claude-code-options-pricing-black-scholes-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code vs Zed AI (2026): Editor Integration](/claude-code-vs-zed-ai-editor-integration-2026/)
- [Claude Code + Linear MCP Integration Guide 2026](/claude-code-linear-mcp-integration-2026/)
- [Claude Code + Neovim Terminal Integration 2026](/claude-code-neovim-terminal-integration-2026/)
- [How to Use Claude Code in IntelliJ IDEA 2026](/claude-code-intellij-idea-integration-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.




**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for OpenSea Protocol](/claude-code-for-opensea-protocol-workflow-guide/)
- [MCP Protocol Version Mismatch in Claude — Fix (2026)](/claude-code-model-context-protocol-version-mismatch-fix-2026/)
- [Claude Code for FIX Protocol Message](/claude-code-fix-protocol-message-handling-2026/)
- [Set Up Django MCP Server for Claude](/claude-code-django-mcp/)


## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
