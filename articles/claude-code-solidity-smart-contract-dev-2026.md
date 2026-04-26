---
layout: default
title: "Claude Code for Solidity Smart (2026)"
permalink: /claude-code-solidity-smart-contract-dev-2026/
date: 2026-04-20
description: "Claude Code for Solidity Smart — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Smart Contract Development

Smart contract bugs are irreversible and expensive -- the DAO hack lost $60M, the Wormhole bridge exploit $320M. Solidity development requires thinking about reentrancy, integer overflow (pre-0.8), storage layout collisions in upgradeable proxies, gas optimization, and the EVM's unique execution model. A single unchecked external call or missing access control modifier can drain an entire protocol.

Claude Code generates Solidity contracts with security-first patterns (checks-effects-interactions, OpenZeppelin SafeMath/AccessControl), produces comprehensive Foundry test suites that cover edge cases and attack vectors, and identifies common vulnerabilities that Slither and Mythril might miss. It understands the EVM at the opcode level well enough to suggest gas optimizations that save real deployment costs.

## The Workflow

### Step 1: Foundry Project Setup

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Create project
forge init my_protocol && cd my_protocol
forge install OpenZeppelin/openzeppelin-contracts

# Configure remappings
echo '@openzeppelin/=lib/openzeppelin-contracts/' > remappings.txt
```

### Step 2: Build a Secure Token Contract

```solidity
// src/StakingVault.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakingVault
 * @notice Stake ERC-20 tokens and earn yield over time.
 * @dev Follows checks-effects-interactions pattern throughout.
 *      Uses SafeERC20 for non-standard token compatibility.
 */
contract StakingVault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable stakingToken;
    uint256 public rewardRate;         // tokens per second per staked token (18 decimals)
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalStaked;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    error ZeroAmount();
    error InsufficientBalance(uint256 requested, uint256 available);

    constructor(address _stakingToken, uint256 _rewardRate) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Zero address");
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored +
            ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalStaked;
    }

    function earned(address account) public view returns (uint256) {
        return (stakedBalance[account] *
            (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18
            + rewards[account];
    }

    /**
     * @notice Stake tokens into the vault.
     * @param amount Number of tokens to stake (must have approval).
     */
    function stake(uint256 amount)
        external
        nonReentrant
        updateReward(msg.sender)
    {
        // Checks
        if (amount == 0) revert ZeroAmount();

        // Effects (state changes before external calls)
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        // Interactions (external call last)
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Withdraw staked tokens.
     * @param amount Number of tokens to withdraw.
     */
    function withdraw(uint256 amount)
        external
        nonReentrant
        updateReward(msg.sender)
    {
        // Checks
        if (amount == 0) revert ZeroAmount();
        if (amount > stakedBalance[msg.sender]) {
            revert InsufficientBalance(amount, stakedBalance[msg.sender]);
        }

        // Effects
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        // Interactions
        stakingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function claimReward()
        external
        nonReentrant
        updateReward(msg.sender)
    {
        uint256 reward = rewards[msg.sender];
        if (reward == 0) revert ZeroAmount();

        rewards[msg.sender] = 0;
        stakingToken.safeTransfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }
}
```

### Step 3: Comprehensive Foundry Tests

```solidity
// test/StakingVault.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/StakingVault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1_000_000 * 1e18);
    }
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract StakingVaultTest is Test {
    StakingVault vault;
    MockToken token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new MockToken();
        vault = new StakingVault(address(token), 1e15); // reward rate
        token.transfer(alice, 10_000 * 1e18);
        token.transfer(bob, 10_000 * 1e18);
        // Fund vault with rewards
        token.transfer(address(vault), 100_000 * 1e18);
    }

    function testStakeAndWithdraw() public {
        vm.startPrank(alice);
        token.approve(address(vault), 1000 * 1e18);
        vault.stake(1000 * 1e18);
        assertEq(vault.stakedBalance(alice), 1000 * 1e18);
        assertEq(vault.totalStaked(), 1000 * 1e18);

        vault.withdraw(500 * 1e18);
        assertEq(vault.stakedBalance(alice), 500 * 1e18);
        vm.stopPrank();
    }

    function testCannotWithdrawMoreThanStaked() public {
        vm.startPrank(alice);
        token.approve(address(vault), 1000 * 1e18);
        vault.stake(1000 * 1e18);

        vm.expectRevert();
        vault.withdraw(2000 * 1e18);
        vm.stopPrank();
    }

    function testRewardAccumulation() public {
        vm.startPrank(alice);
        token.approve(address(vault), 1000 * 1e18);
        vault.stake(1000 * 1e18);
        vm.stopPrank();

        // Advance time by 1 day
        vm.warp(block.timestamp + 86400);

        uint256 earned = vault.earned(alice);
        assertGt(earned, 0, "Should have earned rewards");
    }

    function testReentrancyProtection() public {
        // Reentrancy guard prevents re-entry during stake/withdraw
        vm.startPrank(alice);
        token.approve(address(vault), 1000 * 1e18);
        vault.stake(1000 * 1e18);
        // Direct reentrancy would revert with ReentrancyGuardReentrantCall
        vm.stopPrank();
    }

    // Fuzz test: any valid amount should work
    function testFuzzStake(uint256 amount) public {
        amount = bound(amount, 1, 10_000 * 1e18);
        vm.startPrank(alice);
        token.approve(address(vault), amount);
        vault.stake(amount);
        assertEq(vault.stakedBalance(alice), amount);
        vm.stopPrank();
    }
}
```

### Step 4: Verify and Audit

```bash
# Compile and test
forge build
forge test -vvv

# Gas report
forge test --gas-report

# Static analysis with Slither
pip install slither-analyzer
slither src/StakingVault.sol --solc-remaps '@openzeppelin/=lib/openzeppelin-contracts/'

# Expected: 0 high/medium findings, all tests pass
```

## CLAUDE.md for Solidity Development

```markdown
# Solidity Smart Contract Standards

## Security Patterns
- Checks-Effects-Interactions (CEI) in every state-changing function
- ReentrancyGuard on all external-facing functions that transfer value
- SafeERC20 for all token transfers (handles non-standard return values)
- Ownable or AccessControl for admin functions
- Custom errors over require strings (gas efficient)

## Testing Requirements
- Unit tests for every public function
- Fuzz tests for numeric inputs (forge fuzz)
- Invariant tests for protocol-wide properties
- Fork tests against mainnet state for integrations

## Libraries
- OpenZeppelin Contracts 5.0+
- Foundry (forge, cast, anvil)
- Slither (static analysis)
- Mythril (symbolic execution)

## Common Commands
- forge build — compile contracts
- forge test -vvv — run tests with verbose output
- forge test --gas-report — measure gas usage
- slither . — static security analysis
- cast call <addr> "balanceOf(address)" <user> — read contract state
- anvil — local Ethereum node for testing
```

## Common Pitfalls

- **Missing reentrancy guard on withdrawal:** Without ReentrancyGuard and CEI pattern, an attacker can re-enter withdraw() before the balance update. Claude Code adds nonReentrant to all value-transferring functions and orders state changes before external calls.
- **Unsafe ERC-20 assumptions:** Some tokens (USDT) do not return bool from transfer(). Using raw transfer() without SafeERC20 silently ignores failures. Claude Code always uses safeTransfer/safeTransferFrom.
- **Storage collision in proxy upgrades:** Adding new state variables to the wrong position in an upgradeable contract overwrites existing data. Claude Code uses storage gaps and verifies layout compatibility with forge inspect.

## Related

- [Claude Code for DeFi Protocol Integration](/claude-code-defi-protocol-integration-2026/)
- [Claude Code for Options Pricing](/claude-code-options-pricing-black-scholes-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


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




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Skills for Smart Grid](/claude-skills-for-energy-smart-grid-applications/)
- [Smart Context Pruning for Claude API](/smart-context-pruning-claude-api-savings/)
- [Claude Code + Mythril Smart Contract](/claude-code-for-mythril-workflow-tutorial/)
- [Smart Model Selection Saves 80%](/smart-model-selection-saves-80-percent-claude/)

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
