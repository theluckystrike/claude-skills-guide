---

layout: default
title: "Claude Code for Compound Governance"
description: "Learn how to build automated governance workflows for Compound-like DeFi protocols using Claude Code. Includes practical examples for proposal."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-compound-governance-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---


Claude Code for Compound Governance Workflow

Automating decentralized governance is one of the most powerful use cases for Claude Code in the Web3 space. Compound's governance model, which relies on proposers, delegates, and executors, lends itself perfectly to Claude-assisted automation. This guide walks you through building a complete governance workflow using Claude Code, from drafting proposals to executing passed measures.

## Understanding Compound Governance Architecture

Compound's governance operates on a three-phase model: proposal submission, voting period, and execution. The protocol uses COMP tokens as voting power, with delegates able to cast votes on behalf of token holders. Before automating, you need to understand how these components interact:

- Proposal Contract: The on-chain entity that holds the executable code
- Governor Bravo: The governance contract that manages voting thresholds and timing
- Timelock Controller: The contract that enforces a delay between proposal passage and execution

Claude Code can interact with all three through a combination of RPC calls and local file operations for proposal drafting.

## Setting Up Your Governance Skill

Create a specialized skill for governance operations. This skill should handle both the off-chain drafting and on-chain interaction aspects:

```yaml
---
name: compound-governance
description: Manage Compound governance proposals and voting
---
```

This skill declaration restricts tool access to file operations and bash, enough to draft proposals locally while keeping governance calls isolated in executable scripts.

## Proposal Drafting Workflow

The first governance task Claude Code excels at is proposal drafting. Rather than manually writing Solidity and configuration files, you can automate the entire drafting process:

## Step 1: Define Proposal Parameters

Create a configuration-driven approach where proposal details live in structured files:

```json
{
 "proposal": {
 "title": "Increase USDC Collateral Factor",
 "description": "Increase the collateral factor for USDC from 75% to 80% to improve capital efficiency.",
 "targets": ["0x39AA39c419df9D5B5A9D46f1bA1dD4e2bF3d8E1c"],
 "values": ["0"],
 "signatures": ["_setCollateralFactor(address,uint256)"],
 "calldatas": ["0x000000000000000000000000A0b86991c6218b36c1d19D4a2e9Eb0cE3606eB480000000000000000000000000000000000000000000000000000000000000050"],
 "voteStart": 1682000000,
 "voteDuration": 199080
 }
}
```

## Step 2: Generate Proposal Script

Use Claude Code to generate the executable JavaScript that submits your proposal:

```javascript
const { ethers } = require('ethers');
const fs = require('fs');

async function propose(config) {
 const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
 const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
 
 const governor = new ethers.Contract(
 config.governanceAddress,
 ['function propose(address[],uint256[],string[],bytes[],string) returns (uint256)'],
 wallet
 );
 
 const tx = await governor.propose(
 config.proposal.targets,
 config.proposal.values,
 config.proposal.signatures,
 config.proposal.calldatas,
 config.proposal.description
 );
 
 const receipt = await tx.wait();
 console.log(`Proposal created: ${receipt.hash}`);
 return receipt;
}

module.exports = { propose };
```

## Step 3: Automate Execution

Combine everything into a bash script that Claude Code can execute:

```bash
#!/bin/bash
Governance proposal submission script

CONFIG_FILE=$1
PROPOSAL_ID=$(node submit-proposal.js "$CONFIG_FILE")
echo "Proposal ID: $PROPOSAL_ID"
```

## Voting Automation with Delegates

Once proposals exist, Claude Code can help manage voting through delegate accounts. This is particularly useful for protocols where you hold voting power across multiple wallets.

## Delegate Voting Pattern

```javascript
class GovernanceVoter {
 constructor(delegates, governorAddress) {
 this.delegates = delegates;
 this.governor = new ethers.Contract(governorAddress,GovernorABI,provider);
 }
 
 async castVote(proposalId, voteType) {
 // voteType: 0=Against, 1=For, 2=Abstain
 const results = await Promise.all(
 this.delegates.map(async (delegate) => {
 const wallet = new ethers.Wallet(delegate.privateKey, provider);
 const contract = this.governor.connect(wallet);
 const tx = await contract.castVote(proposalId, voteType);
 return tx.hash;
 })
 );
 return results;
 }
}
```

The key insight here is that Claude Code can maintain a secure configuration of delegate keys (never committing them to version control) and execute voting across all accounts with a single command.

## Monitoring and Execution

The final piece of the governance workflow is monitoring proposal status and executing passed measures. Claude Code can continuously monitor chain state:

```javascript
async function checkProposalState(proposalId) {
 const state = await governor.state(proposalId);
 const states = ['Pending', 'Active', 'Canceled', 'Defeated', 'Succeeded', 'Queued', 'Expired', 'Executed'];
 console.log(`Proposal ${proposalId}: ${states[state]}`);
 
 if (state === 4) { // Succeeded
 await queueForTimelock(proposalId);
 }
}
```

For continuous monitoring, set up a simple cron job that Claude Code can manage:

```bash
Run every 5 minutes to check active proposals
*/5 * * * * cd /path/to/governance && node monitor-proposals.js >> /var/log/governance.log
```

## Queuing and Executing Passed Proposals

When a proposal reaches the Succeeded state, it needs to be queued in the Timelock before it can be executed. This is a separate on-chain transaction that starts the mandatory delay clock. Claude Code can automate both steps as part of a continuous monitoring loop:

```javascript
async function queueForTimelock(proposalId) {
 const tx = await governor.queue(proposalId);
 const receipt = await tx.wait();
 console.log(`Proposal ${proposalId} queued: ${receipt.hash}`);

 // Calculate when execution becomes available
 const delay = await timelock.delay();
 const executableAt = Date.now() + (Number(delay) * 1000);
 console.log(`Executable at: ${new Date(executableAt).toISOString()}`);

 // Store state for later execution
 const state = {
 proposalId,
 executableAt,
 status: 'queued'
 };
 require('fs').writeFileSync(`./state/proposal-${proposalId}.json`, JSON.stringify(state, null, 2));
}

async function executeWhenReady(proposalId) {
 const statePath = `./state/proposal-${proposalId}.json`;
 const state = JSON.parse(require('fs').readFileSync(statePath, 'utf8'));

 if (Date.now() < state.executableAt) {
 const remaining = Math.ceil((state.executableAt - Date.now()) / 1000 / 60);
 console.log(`Not yet executable. ${remaining} minutes remaining`);
 return;
 }

 const tx = await governor.execute(proposalId);
 const receipt = await tx.wait();
 console.log(`Proposal ${proposalId} executed: ${receipt.hash}`);
 state.status = 'executed';
 require('fs').writeFileSync(statePath, JSON.stringify(state, null, 2));
}
```

Writing state to disk between runs means your monitoring loop survives restarts without losing track of where proposals stand in the lifecycle.

## Calldata Encoding and Validation

One of the most error-prone parts of governance is encoding calldata correctly. A single byte offset wrong means your proposal passes and then silently does nothing, or worse, executes against the wrong parameters. Claude Code can generate and verify calldata before submission:

```javascript
const { ethers } = require('ethers');

function encodeCollateralFactor(tokenAddress, factorBips) {
 // Governor Bravo expects ABI-encoded calldata without the function selector
 // because the selector is passed separately in the signatures array
 const abiCoder = ethers.AbiCoder.defaultAbiCoder();
 const encoded = abiCoder.encode(
 ['address', 'uint256'],
 [tokenAddress, factorBips]
 );
 return encoded;
}

async function validateCalldata(targetAddress, signature, calldata) {
 // Simulate the call locally before submitting the proposal
 const iface = new ethers.Interface([`function ${signature}`]);
 const fullCalldata = iface.encodeFunctionData(
 signature.split('(')[0],
 iface.decodeFunctionData(signature.split('(')[0], '0x' + calldata.slice(2))
 );

 try {
 await provider.call({
 to: targetAddress,
 data: fullCalldata
 });
 console.log('Calldata validation: PASSED');
 return true;
 } catch (err) {
 console.error('Calldata validation FAILED:', err.reason || err.message);
 return false;
 }
}

// Example: validate before proposing
const calldata = encodeCollateralFactor(
 '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
 800 // 80% expressed as basis points out of 1000
);

const isValid = await validateCalldata(
 '0x39AA39c419df9D5B5A9D46f1bA1dD4e2bF3d8E1c',
 '_setCollateralFactor(address,uint256)',
 calldata
);

if (!isValid) {
 process.exit(1); // Never submit proposals with invalid calldata
}
```

Run this validation as part of your CI pipeline so bad calldata never reaches the chain.

## Building a Governance Audit Trail

Governance decisions are permanent and public. Keeping a local audit trail that correlates on-chain events with the off-chain intent behind them is invaluable for post-mortems and protocol transparency reports.

Add a logging layer to every governance operation:

```javascript
const fs = require('fs');
const path = require('path');

const AUDIT_LOG = path.resolve('./audit/governance-log.jsonl');

function auditLog(event) {
 const entry = {
 timestamp: new Date().toISOString(),
 blockNumber: event.blockNumber || null,
 txHash: event.txHash || null,
 type: event.type,
 proposalId: event.proposalId,
 actor: event.actor,
 details: event.details
 };
 fs.appendFileSync(AUDIT_LOG, JSON.stringify(entry) + '\n');
}

// Usage after each operation
auditLog({
 type: 'PROPOSAL_SUBMITTED',
 proposalId: '42',
 actor: wallet.address,
 txHash: receipt.hash,
 blockNumber: receipt.blockNumber,
 details: { title: 'Increase USDC Collateral Factor', calldataHash: ethers.keccak256(calldata) }
});
```

The JSONL format (one JSON object per line) makes it easy to grep specific proposal IDs or event types without loading the entire log into memory.

## Multi-Protocol Governance with Shared Skill Infrastructure

Once you have a working governance skill for Compound, the same architecture extends to any Governor Bravo-compatible protocol: Uniswap, Aave (with minor adapter changes), and Compound forks. The key is parameterizing the contract addresses and ABIs rather than hardcoding them:

```javascript
// governance-config.js. supports multiple protocols
const PROTOCOLS = {
 compound: {
 governor: '0xc0Da02939E1441F497fd74F78cE7Decb17B66529',
 timelock: '0x6d903f6003cca6255D85CcA4D3B5E5146dC33925',
 token: '0xc00e94Cb662C3520282E6f5717214004A7f26888',
 votingDelay: 13140, // blocks
 votingPeriod: 19710, // blocks
 proposalThreshold: '100000000000000000000000' // 100,000 COMP
 },
 uniswap: {
 governor: '0x408ED6354d4973f66138C91495F2f2FCbd8724C3',
 timelock: '0x1a9C8182C09F50C8318d769245beA52c32BE35BC',
 token: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
 votingDelay: 1,
 votingPeriod: 40320,
 proposalThreshold: '2500000000000000000000000' // 2.5M UNI
 }
};

module.exports = { PROTOCOLS };
```

Your Claude Code skill can accept a `--protocol` flag and load the appropriate configuration, making the same skill reusable across your entire governance portfolio.

## Security Considerations

When automating governance with Claude Code, follow these security practices:

1. Never commit private keys: Use environment variables or a secrets manager like AWS Secrets Manager or HashiCorp Vault
2. Multi-sig for execution: Configure your timelock to require multiple signatures using a Gnosis Safe as the executor
3. Timelock verification: Always verify the timelock delay before execution, protocol upgrades can change it
4. Proposal simulation: Test calldata with `eth_call` before submitting, as shown in the validation section above
5. Dry-run mode: Add a `DRY_RUN=true` environment variable that logs what would happen without sending transactions
6. Rotate keys regularly: Delegate-voting keys should be rotated on a schedule; automate key rotation with your secrets manager

A practical dry-run implementation keeps the same code path but skips the actual `tx.wait()`:

```javascript
async function submitProposal(config) {
 if (process.env.DRY_RUN === 'true') {
 console.log('[DRY RUN] Would submit proposal:', JSON.stringify(config, null, 2));
 return { hash: '0x-dry-run', blockNumber: null };
 }
 const tx = await governor.propose(/* ... */);
 return tx.wait();
}
```

## Actionable Summary

To implement a complete Compound governance workflow with Claude Code:

1. Create a governance skill with file and bash tool access
2. Define proposals in structured JSON configuration files
3. Build submission scripts that interact with Governor contracts
4. Validate calldata with `eth_call` simulations before submitting
5. Implement delegate voting automation for multi-wallet governance
6. Set up monitoring for proposal state transitions, queue, and execution
7. Write every operation to a JSONL audit log for transparency
8. Parameterize protocol configs to reuse the same skill across Governor Bravo forks
9. Always follow security best practices for key management and use dry-run mode during development

Claude Code transforms governance from a manual, error-prone process into a reliable, auditable workflow. By treating governance operations as code-configured actions, you gain repeatability and safety in protocol management.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-compound-governance-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for OSS Governance Workflow Tutorial Guide](/claude-code-for-oss-governance-workflow-tutorial-guide/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


