---

layout: default
title: "How to Use Brownie Python Workflow"
description: "A comprehensive guide to integrating Claude Code CLI with Brownie for efficient smart contract development, testing, and deployment workflows."
date: 2026-04-19
last_modified_at: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-code-for-brownie-python-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

This is a focused treatment of brownie python with Claude Code. It covers setup, common patterns, and troubleshooting specific to brownie python. For broader context, [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/) is a good companion read.

Brownie is a Python-based framework for developing, testing, and deploying smart contracts on Ethereum and other EVM-compatible networks. When combined with Claude Code, you get an intelligent pair programming assistant that can accelerate your entire development workflow, from initial contract design to final deployment. This guide shows you how to integrate Claude Code smoothly with your Brownie projects.

## Setting Up Claude Code with Brownie

Before integrating Claude Code with Brownie, ensure both tools are properly installed. Brownie requires Python 3.8+ and ganache-cli for local development:

```bash
pip install eth-brownie
brownie --version
```

You will also need Node.js installed for ganache-cli, which Brownie uses as a local EVM environment:

```bash
npm install -g ganache-cli
Verify installation
ganache-cli --version
```

Initialize Claude Code and configure it to recognize your Brownie project:

```bash
Start Claude Code in your Brownie project directory
claude
Claude Code will automatically detect your Python/Brownie project
```

Claude Code will automatically detect Python projects and configure appropriate tools. For Brownie projects, you'll want to ensure the following tools are available: read_file, write_file, edit_file, bash, and glob. These enable Claude to interact with your contract files, run Brownie commands, and navigate your project structure.

A good practice is to create a `CLAUDE.md` file at your project root to give Claude Code context about your Brownie setup:

```markdown
Project: MyToken DeFi Protocol

Stack
- Brownie 1.19+
- Solidity 0.8.x
- Python 3.10

Key Commands
- `brownie compile`. compile all contracts
- `brownie test`. run full test suite with coverage
- `brownie run scripts/deploy.py --network mainnet-fork`. test deploy on fork
- `brownie console`. interactive REPL with deployed contracts

Networks
- development: local ganache
- mainnet-fork: `http://localhost:8545` forked via Alchemy
- goerli: Goerli testnet (requires PRIVATE_KEY env var)

Contract Architecture
- Token.sol. ERC-20 base with burnable + pausable
- Vault.sol. Yield vault, depends on Token
- Governance.sol. DAO voting contract
```

This file ensures Claude Code understands your project conventions from the first prompt, avoiding generic suggestions that don't fit your setup.

## Project Structure Navigation

Brownie projects follow a specific directory structure that Claude Code can help you navigate and maintain:

```
my-project/
 contracts/
 Token.sol
 Vault.sol
 interfaces/
 IToken.sol
 scripts/
 deploy.py
 deploy_vault.py
 utils/
 helpers.py
 tests/
 conftest.py
 test_token.py
 test_vault.py
 build/
 contracts/
 Token.json (ABI + bytecode after compile)
 brownie-config.yaml
 .brownie/
```

Understanding this structure is critical because Brownie auto-discovers contracts in `contracts/`, auto-discovers tests in `tests/`, and writes deployment records to `.brownie/`. Claude Code navigates this without any extra configuration.

When working with Claude Code, you can ask it to explore your project structure, locate specific contracts, or identify test files related to a particular contract. For example:

> "Find all test files that test the Token contract and show me their coverage"

Claude Code will analyze your project and return relevant file paths along with coverage information from Brownie's test output.

## Useful Navigation Prompts

Some prompts that work particularly well for Brownie project navigation:

- "List all contracts that inherit from OpenZeppelin's Ownable"
- "Which scripts deploy to mainnet vs testnet?"
- "Show me every place the `Transfer` event is emitted across all contracts"
- "Find test fixtures defined in conftest.py and explain what each one sets up"

Claude Code reads multiple files in parallel and synthesizes the answer, something that would take several minutes of manual grepping.

## Smart Contract Development Workflow

Claude Code excels at assisting with contract development. Here's how to use it effectively:

## Writing New Contracts

When you need to create a new smart contract, describe your requirements to Claude Code:

> "Create an ERC-20 token contract with burnable functionality and pausable control"

Claude Code will generate the Solidity code, place it in your contracts directory, and ensure it follows best practices. You can then review and modify as needed.

Here is an example of the kind of contract Claude Code will produce when given that prompt:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title MyToken
/// @notice ERC-20 token with burn and pause functionality
contract MyToken is ERC20, ERC20Burnable, Pausable, Ownable {
 constructor(
 string memory name,
 string memory symbol,
 uint256 initialSupply
 ) ERC20(name, symbol) {
 _mint(msg.sender, initialSupply * 10 decimals());
 }

 /// @notice Pause all token transfers. Only callable by owner.
 function pause() external onlyOwner {
 _pause();
 }

 /// @notice Unpause token transfers. Only callable by owner.
 function unpause() external onlyOwner {
 _unpause();
 }

 /// @dev Override required by Solidity for multiple inheritance.
 function _beforeTokenTransfer(
 address from,
 address to,
 uint256 amount
 ) internal override whenNotPaused {
 super._beforeTokenTransfer(from, to, amount);
 }
}
```

Notice that Claude Code automatically imports OpenZeppelin contracts, adds NatSpec documentation, and resolves the multiple-inheritance `_beforeTokenTransfer` override, details that are easy to miss when writing from scratch.

## Iterative Development

For existing contracts, use Claude Code to analyze and suggest improvements:

```bash
claude "Review my Token.sol contract for security vulnerabilities"
```

Claude Code will read the contract, identify potential issues (like reentrancy risks, integer overflow possibilities, or access control gaps), and propose concrete fixes.

A typical audit response from Claude Code might look like this:

```
Issues found in Token.sol:

HIGH: withdrawFees() sends ETH before updating internal balance.
This is a classic reentrancy pattern. Fix: update state first.

MEDIUM: mintBatch() has no upper bound on array length.
An attacker can cause an out-of-gas DoS. Add: require(recipients.length <= 200).

LOW: Missing event emission in setFeeRecipient().
Off-chain tooling and explorers won't detect this state change.

INFO: Consider replacing ownerOnly modifier with AccessControl
for more granular permission management.
```

Use these findings as a starting point for your own review, Claude Code's analysis is a first pass, not a substitute for a formal audit.

## Running Tests

Brownie's testing framework integrates smoothly with Claude Code. Run tests through the CLI:

```bash
brownie test
```

Or ask Claude Code to run specific tests:

> "Run only the transfer-related tests in test_token.py"

Claude Code will execute the tests and interpret the results, highlighting any failures and suggesting fixes.

You can also ask Claude Code to run tests with specific flags that Brownie supports:

```bash
Run with coverage report
brownie test --coverage

Run a specific test function
brownie test tests/test_token.py::test_transfer_reverts_on_zero_amount -v

Run with gas profiling
brownie test --gas
```

Claude Code can parse the gas profiling output and tell you which functions are the most expensive, helping you prioritize optimization work.

## Deployment Automation

Deploying smart contracts requires careful orchestration. Claude Code can help you create and manage deployment scripts:

## Creating Deployment Scripts

Ask Claude Code to generate deployment scripts:

> "Create a deployment script for the Token contract that supports mainnet and testnet deployments"

Claude Code will create a scripts/deploy.py file with proper network handling, using Brownie's network management features:

```python
from brownie import Token, accounts, network, config
from scripts.utils.helpers import get_account, verify_on_etherscan

INITIAL_SUPPLY = 1_000_000 # 1 million tokens

def deploy_token(account=None):
 """
 Deploy the Token contract.

 Args:
 account: Brownie account to use. Defaults to accounts[0] on local,
 or loaded from config on live networks.
 Returns:
 Deployed Token contract instance.
 """
 if account is None:
 account = get_account()

 publish = config["networks"][network.show_active()].get("verify", False)

 token = Token.deploy(
 "MyToken",
 "MTK",
 18,
 INITIAL_SUPPLY,
 {"from": account},
 publish_source=publish,
 )

 print(f"Token deployed at {token.address} on {network.show_active()}")
 return token

def main():
 deploy_token()
```

The `get_account()` helper in `scripts/utils/helpers.py` handles the environment-specific account loading:

```python
from brownie import accounts, config, network

def get_account(index=None, id=None):
 """
 Resolve the account to use for deployment.

 - On local/forked networks: use accounts[0] (ganache pre-funded)
 - On live networks: load from encrypted keystore or env var
 """
 LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "mainnet-fork"]

 if index is not None:
 return accounts[index]

 if id is not None:
 return accounts.load(id)

 if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
 return accounts[0]

 # Live network: load from brownie-config.yaml wallets section
 return accounts.add(config["wallets"]["from_key"])

def verify_on_etherscan(contract):
 """Submit contract source to Etherscan for verification."""
 if config["networks"][network.show_active()].get("verify"):
 contract.contract.publish_source(contract)
```

The corresponding `brownie-config.yaml` section for secrets:

```yaml
networks:
 default: development
 mainnet-fork:
 cmd_settings:
 fork: ${ALCHEMY_MAINNET_URL}
 goerli:
 verify: true
wallets:
 from_key: ${PRIVATE_KEY}
dotenv: .env
```

This pattern ensures private keys never appear in source code, they come from environment variables resolved at runtime.

## Managing Deployments Across Networks

Brownie supports multiple networks through its configuration. Claude Code can help you manage deployments:

> "Show me the current deployment addresses on goerli testnet"

Claude Code reads your deployment records and displays the relevant addresses. For mainnet deployments, ensure you use secure key management, never hardcode private keys.

Brownie saves deployment addresses in `.brownie/accounts/` and exposes them through the contract interface. Claude Code can query these directly:

```python
Claude Code can run this interactively in brownie console
from brownie import Token, network
network.connect("goerli")
print(Token[-1].address) # Most recently deployed instance
```

## Testing Strategies with Claude Code

Comprehensive testing is crucial for smart contract development. Claude Code can enhance your testing workflow significantly.

## Writing Test Cases

Generate test cases by describing your requirements:

> "Write pytest tests for the Token contract covering: transfer, transferFrom, allowance, mint, and burn functions"

Claude Code creates comprehensive tests in your tests/ directory, covering happy paths and edge cases. Here is a representative example of the output:

```python
import pytest
from brownie import Token, accounts, reverts

@pytest.fixture(scope="module")
def token(Token, accounts):
 """Deploy a fresh Token for the test module."""
 return Token.deploy("MyToken", "MTK", 18, 1_000_000, {"from": accounts[0]})

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
 """Snapshot and revert the EVM state around each test."""
 pass

class TestTransfer:
 def test_transfer_updates_balances(self, token, accounts):
 sender = accounts[0]
 receiver = accounts[1]
 amount = 100 * 10 18

 initial_sender = token.balanceOf(sender)
 initial_receiver = token.balanceOf(receiver)

 token.transfer(receiver, amount, {"from": sender})

 assert token.balanceOf(sender) == initial_sender - amount
 assert token.balanceOf(receiver) == initial_receiver + amount

 def test_transfer_emits_event(self, token, accounts):
 tx = token.transfer(accounts[1], 50 * 10 18, {"from": accounts[0]})
 assert "Transfer" in tx.events
 assert tx.events["Transfer"]["value"] == 50 * 10 18

 def test_transfer_reverts_on_insufficient_balance(self, token, accounts):
 poor_account = accounts[5]
 with reverts("ERC20: transfer amount exceeds balance"):
 token.transfer(accounts[1], 1, {"from": poor_account})

 def test_transfer_reverts_to_zero_address(self, token, accounts):
 with reverts("ERC20: transfer to the zero address"):
 token.transfer("0x" + "0" * 40, 1, {"from": accounts[0]})

class TestBurn:
 def test_burn_reduces_total_supply(self, token, accounts):
 supply_before = token.totalSupply()
 burn_amount = 500 * 10 18

 token.burn(burn_amount, {"from": accounts[0]})

 assert token.totalSupply() == supply_before - burn_amount

 def test_burn_reverts_on_insufficient_balance(self, token, accounts):
 with reverts("ERC20: burn amount exceeds balance"):
 token.burn(10 30, {"from": accounts[9]})

class TestPause:
 def test_non_owner_cannot_pause(self, token, accounts):
 with reverts("Ownable: caller is not the owner"):
 token.pause({"from": accounts[1]})

 def test_transfer_reverts_when_paused(self, token, accounts):
 token.pause({"from": accounts[0]})
 with reverts("Pausable: paused"):
 token.transfer(accounts[1], 1, {"from": accounts[0]})
 token.unpause({"from": accounts[0]})
```

The `fn_isolation` fixture is critical, it snapshots the EVM state before each test and reverts after, ensuring tests don't bleed state into each other. Claude Code adds this automatically when generating Brownie tests.

## Test-Driven Development

Use Claude Code for TDD workflows:

1. Describe the expected behavior
2. Claude Code writes failing tests
3. Implement the contract
4. Run tests to verify

This iterative approach ensures your contracts meet specifications from the start.

A practical TDD session might look like:

```
You: "Write a failing test for a vesting contract that releases tokens linearly over 1 year with a 3-month cliff"

Claude Code: [writes test_vesting.py with 8 test cases, all expected to fail]

You: "Now implement VestingSchedule.sol to make these tests pass"

Claude Code: [writes VestingSchedule.sol]

You: brownie test tests/test_vesting.py

Claude Code: "6 pass, 2 fail. the cliff boundary condition test is off by one block. Here is the fix..."
```

## Coverage Analysis

After running tests, ask Claude Code to analyze coverage:

> "What's the line coverage for my Token contract? Which functions lack tests?"

Claude Code parses Brownie's coverage output and identifies untested code paths.

Brownie generates coverage data automatically when you pass the `--coverage` flag:

```bash
brownie test --coverage
Coverage report written to reports/coverage.json
```

Claude Code can read `reports/coverage.json` and produce a human-readable summary:

```
Token.sol coverage summary:
 Functions: 11/12 (91.7%)
 Statements: 47/52 (90.4%)
 Branches: 18/24 (75.0%)

Untested paths:
 - Line 87: emergencyWithdraw(). never called in tests
 - Lines 102-105: receive() fallback. no ETH transfer tests
 - Branch on line 63: permit() EIP-2612 deadline expiry branch
```

This level of specificity lets you focus your test-writing effort precisely where it is needed.

## Debugging and Error Resolution

When tests fail or deployments error, Claude Code helps diagnose issues:

> "Debug why the transfer test is failing with 'Insufficient balance'"

Claude Code examines the failing test, reads the contract implementation, and identifies the root cause, often spotting issues like incorrect balance checks or missing state updates.

## Reading Revert Reasons

Brownie captures revert reasons from the EVM. Claude Code can decode these and explain what went wrong:

```
VirtualMachineError: revert
 Traceback from Solidity:
 File "contracts/Vault.sol", line 142, in deposit:
 require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
```

If you paste this error into Claude Code and ask "why is this happening in my deposit test?", Claude Code will:

1. Read `tests/test_vault.py` and find the deposit test
2. Check whether `token.approve()` is called before `vault.deposit()`
3. Check the approval amount vs deposit amount
4. Explain the fix

## Common Brownie Error Patterns

| Error | Likely Cause | Claude Code Fix Strategy |
|---|---|---|
| `VirtualMachineError: revert` | Require/revert in contract | Claude reads contract logic and test setup to find mismatch |
| `AttributeError: 'NoneType' object has no attribute 'address'` | Contract not deployed | Claude checks deploy fixture in conftest.py |
| `ValueError: insufficient funds for gas` | Account has 0 ETH on testnet | Claude suggests using `accounts[0]` or funding from faucet |
| `CompilerError: Source not found` | Missing import or wrong path | Claude scans contracts/ for the missing file |
| `brownie.exceptions.ContractNotFound` | Accessing stale deployment | Claude suggests re-deploying or using contract[-1] |
| `Web3.exceptions.TimeExhausted` | Transaction not mined in time | Claude checks network config and gas price settings |

## Transaction Debugging with Brownie Console

For complex failures, Claude Code can walk you through interactive debugging in the Brownie console:

```python
In brownie console (brownie console --network mainnet-fork)
Claude Code can guide you through this sequence:

from brownie import Token, Vault, accounts

Reproduce the failing state
token = Token[-1]
vault = Vault[-1]
user = accounts[2]

Inspect state before the failing transaction
print("User balance:", token.balanceOf(user) / 1e18)
print("Vault allowance:", token.allowance(user, vault.address) / 1e18)

Attempt transaction and capture the tx object (not receipt)
tx = vault.deposit(100e18, {"from": user})
tx.call_trace() # Shows the full call tree with revert location
```

Claude Code interprets the call trace output and pinpoints exactly which internal call reverted and why.

## Comparison: Claude Code vs. Manual Brownie Workflow

| Task | Manual Workflow | With Claude Code |
|---|---|---|
| Write ERC-20 from scratch | 30-60 min including OZ import research | 2-5 min, correct imports auto-selected |
| Write test suite for 10 functions | 2-4 hours | 15-20 min review time |
| Identify missing test coverage | Read coverage JSON manually | One prompt, immediate summary |
| Debug revert error | Cross-reference contract, test, and stack trace | One prompt, root cause + fix |
| Generate deploy script with network handling | 30-60 min researching Brownie config | 5-10 min |
| Security review of one contract | 1-2 hours manual checklist | 5 min first pass, then manual detailed look |

These numbers reflect workflows where Claude Code handles the mechanical work, you still own the architectural decisions and final review.

## Best Practices for Claude Code with Brownie

1. Be Specific: Provide concrete details about your contracts, including interfaces and expected behaviors
2. Review Generated Code: Always review code before committing, Claude Code assists but doesn't replace developer judgment
3. Use Type Hints: Brownie supports type hints; Claude Code generates better code with them
4. Maintain Test Coverage: Ask Claude Code regularly about coverage gaps
5. Version Control: Commit changes incrementally so you can track Claude Code's modifications
6. Use fn_isolation in Every Test: Always include the `fn_isolation` autouse fixture to prevent state leakage between tests, Claude Code includes this by default but verify it is present
7. Keep CLAUDE.md Updated: As your project evolves, update the CLAUDE.md context file so Claude Code's suggestions stay relevant to your current architecture
8. Prompt for Edge Cases Explicitly: Claude Code generates happy-path tests by default; explicitly ask for "all revert conditions" and "boundary value tests" to get comprehensive coverage
9. Separate Concerns in Scripts: Ask Claude Code to put shared utilities in `scripts/utils/` so deployment scripts stay clean and reusable
10. Audit OpenZeppelin Versions: Claude Code will use the latest stable OZ version by default; confirm this matches what is in your `brownie-config.yaml` dependencies

## Conclusion

Integrating Claude Code with Brownie transforms your smart contract development workflow. From initial contract design through testing and deployment, Claude Code acts as an intelligent partner, generating code, running tests, debugging issues, and suggesting improvements. The key is providing clear, specific prompts and reviewing all generated code before deployment.

Start with small tasks, gradually incorporating more complex workflows as you become comfortable with the collaboration pattern. Your Brownie projects will benefit from faster development cycles, improved code quality, and more comprehensive testing, all while maintaining the security vigilance essential for smart contract development.

---

---



---

*Last verified: April 2026. If this approach no longer works, check [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/) for updated steps.*

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-brownie-python-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Plotly Dash Python Workflow](/claude-code-for-plotly-dash-python-workflow/)
- [Claude Code for Python Dataclass Advanced Workflow](/claude-code-for-python-dataclass-advanced-workflow/)
- [Claude Code for Rye Python Project Workflow Guide](/claude-code-for-rye-python-project-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Python Virtualenv Not Activated Fix](/claude-code-python-virtualenv-not-activated-fix-2026/)
