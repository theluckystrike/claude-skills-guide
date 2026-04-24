---
layout: default
title: "Claude Code For Chainlink Vrf (2026)"
description: "Learn how to use Claude Code to implement Chainlink VRF workflows in your smart contracts. This guide covers practical examples, code snippets, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-chainlink-vrf-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---
Chainlink VRF (Verifiable Random Function) is a powerful tool for generating provably fair random numbers in smart contracts. When combined with Claude Code, you can streamline the entire development workflow, from contract creation to testing and deployment. This guide walks you through practical strategies for implementing Chainlink VRF using Claude Code, with actionable advice and code examples you can apply immediately.

What is Chainlink VRF?

Chainlink VRF provides cryptographically secure randomness for blockchain applications. Unlike pseudo-random number generators, VRF produces verifiable proofs that anyone can verify the randomness was generated fairly. This makes it ideal for NFT minting, gaming applications, lottery systems, and any use case where fairness matters.

The workflow typically involves:
1. Requesting randomness from a VRF coordinator
2. Receiving the random number with its proof
3. Verifying the proof on-chain
4. Using the verified random value

Understanding this cycle is essential before implementing your contracts.

VRF v1 vs VRF v2: Which Should You Use?

Chainlink has two versions of VRF in production. The table below summarizes the key differences so you can make the right choice before writing a single line of code:

| Feature | VRF v1 | VRF v2 |
|-----------------------|-------------------------------|-------------------------------------|
| Funding model | Per-request LINK payment | Subscription-based prepayment |
| Multi-word support | One word per request | Up to 500 words per request |
| Gas overhead | Higher per request | Lower via subscription amortization |
| Request confirmation | Fixed | Configurable |
| Recommended for | Legacy contracts only | All new development |

VRF v2 is the standard for all new development. Claude Code defaults to generating v2 contracts and will flag v1 patterns in code you paste for review. If you inherit a v1 contract, ask Claude Code to walk you through the migration path, it can produce a diff-style comparison of the two contract structures.

## Setting Up Your Development Environment

Before diving into VRF implementation, ensure your environment is ready. Claude Code can help you set up the necessary tooling.

First, create a new project structure:

```bash
mkdir my-vrf-project && cd my-vrf-project
npm init -y
npm install @chainlink/contracts hardhat
```

After installation, initialize Hardhat and create a basic project layout:

```bash
npx hardhat init
Choose "Create a JavaScript project" when prompted
```

Your directory structure should look like this before writing any contracts:

```
my-vrf-project/
 contracts/
 scripts/
 deploy.js
 test/
 hardhat.config.js
 package.json
```

A useful Claude Code prompt at this stage: "Generate a hardhat.config.js for Sepolia testnet with etherscan verification and a dotenv setup for my private key and RPC URL." Claude Code will produce the complete config and flag the environment variables you need to populate, which prevents accidental key exposure.

## Implementing the VRF Consumer Contract

The core of VRF integration is the consumer contract that requests and receives random values. Here's a practical implementation pattern:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomWinner is VRFConsumerBaseV2 {
 VRFCoordinatorV2Interface coordinator;
 uint64 subscriptionId;
 bytes32 keyHash;
 uint32 callbackGasLimit = 100000;
 uint16 requestConfirmations = 3;
 uint256[] public randomWords;
 uint256 public requestId;

 constructor(
 address _vrfCoordinator,
 uint64 _subscriptionId,
 bytes32 _keyHash
 ) VRFConsumerBaseV2(_vrfCoordinator) {
 coordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
 subscriptionId = _subscriptionId;
 keyHash = _keyHash;
 }

 function requestRandomWords() external returns (uint256) {
 requestId = coordinator.requestRandomWords(
 keyHash,
 subscriptionId,
 requestConfirmations,
 callbackGasLimit,
 1 // number of random words
 );
 return requestId;
 }

 function fulfillRandomWords(
 uint256 _requestId,
 uint256[] memory _randomWords
 ) internal override {
 randomWords = _randomWords;
 }
}
```

This contract demonstrates the essential pattern: requesting randomness and handling the fulfillment callback. Claude Code can help you customize this for specific use cases like weighted selections or multiple random values.

## Extending the Contract for Real Use Cases

A bare-bones VRF consumer is rarely enough. Here is an extended example that implements a lottery drawing with access control, request tracking, and a winner storage pattern:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBaseV2, Ownable {
 VRFCoordinatorV2Interface private coordinator;
 uint64 private subscriptionId;
 bytes32 private keyHash;
 uint32 private callbackGasLimit = 200000;
 uint16 private requestConfirmations = 3;

 address[] public players;
 address public lastWinner;
 mapping(uint256 => bool) public pendingRequests;

 event WinnerRequested(uint256 indexed requestId, uint256 playerCount);
 event WinnerSelected(uint256 indexed requestId, address winner);

 constructor(
 address _vrfCoordinator,
 uint64 _subscriptionId,
 bytes32 _keyHash
 ) VRFConsumerBaseV2(_vrfCoordinator) Ownable(msg.sender) {
 coordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
 subscriptionId = _subscriptionId;
 keyHash = _keyHash;
 }

 function enter() external payable {
 require(msg.value >= 0.01 ether, "Minimum entry is 0.01 ETH");
 players.push(msg.sender);
 }

 function pickWinner() external onlyOwner {
 require(players.length > 0, "No players entered");
 uint256 reqId = coordinator.requestRandomWords(
 keyHash,
 subscriptionId,
 requestConfirmations,
 callbackGasLimit,
 1
 );
 pendingRequests[reqId] = true;
 emit WinnerRequested(reqId, players.length);
 }

 function fulfillRandomWords(
 uint256 _requestId,
 uint256[] memory _randomWords
 ) internal override {
 require(pendingRequests[_requestId], "Unknown request");
 delete pendingRequests[_requestId];

 uint256 winnerIndex = _randomWords[0] % players.length;
 lastWinner = players[winnerIndex];

 // Transfer prize
 (bool success, ) = lastWinner.call{value: address(this).balance}("");
 require(success, "Transfer failed");

 emit WinnerSelected(_requestId, lastWinner);
 delete players;
 }
}
```

Claude Code can generate this kind of extension when you describe the business logic in plain English. A prompt like "Add a lottery drawing that picks a winner from an array of player addresses and pays out the contract balance" produces a working starting point you can review and refine.

## Optimizing VRF Requests with Claude Code

When working with VRF in production, several optimizations improve efficiency and reduce costs.

## Batching Multiple Requests

If your application needs multiple random values, batch them into a single request:

```solidity
function requestMultipleWinners(uint256 _count) external {
 coordinator.requestRandomWords(
 keyHash,
 subscriptionId,
 requestConfirmations,
 callbackGasLimit,
 _count
 );
}
```

Batching is one of the most impactful optimizations in VRF v2. Each request incurs a fixed coordination overhead regardless of how many words you request, so requesting 10 words costs far less than making 10 separate single-word requests. Claude Code will suggest this pattern when it sees multiple sequential `requestRandomWords` calls in your contract.

## Calibrating callbackGasLimit

The `callbackGasLimit` must cover all the logic inside `fulfillRandomWords`. Underestimating causes the fulfillment transaction to revert, leaving your contract stuck. A safe approach is to measure gas usage in tests:

```javascript
// In your Hardhat test
const tx = await vrfCoordinator.fulfillRandomWords(requestId, contract.address);
const receipt = await tx.wait();
console.log("Fulfillment gas used:", receipt.gasUsed.toString());
```

Add a 20% buffer to the measured value and use that as your `callbackGasLimit`. Claude Code can calculate this buffer for you when you paste in the gas figure.

## Using Subscription Management

Create a dedicated subscription for your VRF usage to track costs and manage funding. You can do this programmatically in your deployment script:

```javascript
// scripts/setup-subscription.js
const { ethers } = require("hardhat");

async function main() {
 const vrfCoordinatorAddress = "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625"; // Sepolia
 const vrfCoordinator = await ethers.getContractAt(
 "VRFCoordinatorV2Interface",
 vrfCoordinatorAddress
 );

 // Create subscription
 const tx = await vrfCoordinator.createSubscription();
 const receipt = await tx.wait();
 const subscriptionId = receipt.events[0].args.subId;
 console.log("Subscription ID:", subscriptionId.toString());
}

main().catch(console.error);
```

Claude Code can explain the subscription model and help you set up proper billing tracking. Maintaining a separate subscription per environment (development, staging, production) gives you clean cost attribution and prevents a runaway script from draining production LINK.

## Testing VRF Contracts Locally

Testing VRF functionality presents unique challenges since mainnet VRF isn't available in local development. Use mock contracts for testing:

```solidity
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

// In your test setup
VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(100000, 100000);
uint64 subscriptionId = vrfCoordinator.createSubscription();
vrfCoordinator.fundSubscription(subscriptionId, 1000000000000000000);
```

A complete Hardhat test that exercises the full request/fulfillment cycle looks like this:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RandomWinner", function () {
 let vrfCoordinator, randomWinner, subscriptionId;

 const BASE_FEE = ethers.utils.parseEther("0.1");
 const GAS_PRICE_LINK = 1e9;
 const KEY_HASH = "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc";

 beforeEach(async function () {
 const VRFCoordinatorV2Mock = await ethers.getContractFactory("VRFCoordinatorV2Mock");
 vrfCoordinator = await VRFCoordinatorV2Mock.deploy(BASE_FEE, GAS_PRICE_LINK);

 const tx = await vrfCoordinator.createSubscription();
 const receipt = await tx.wait();
 subscriptionId = receipt.events[0].args.subId;

 await vrfCoordinator.fundSubscription(
 subscriptionId,
 ethers.utils.parseEther("10")
 );

 const RandomWinner = await ethers.getContractFactory("RandomWinner");
 randomWinner = await RandomWinner.deploy(
 vrfCoordinator.address,
 subscriptionId,
 KEY_HASH
 );

 await vrfCoordinator.addConsumer(subscriptionId, randomWinner.address);
 });

 it("requests and receives randomness", async function () {
 const requestTx = await randomWinner.requestRandomWords();
 const requestReceipt = await requestTx.wait();
 const requestId = requestReceipt.events[0].args.requestId;

 // Simulate the VRF coordinator fulfilling the request
 await vrfCoordinator.fulfillRandomWords(requestId, randomWinner.address);

 const randomWord = await randomWinner.randomWords(0);
 expect(randomWord).to.not.equal(0);
 });
});
```

Claude Code can generate comprehensive test suites that cover various scenarios including successful requests, failure conditions, and edge cases such as attempting to call `fulfillRandomWords` from an unauthorized address.

## Deployment Best Practices

When deploying to testnet or mainnet, follow these recommendations:

1. Verify subscription funding: Ensure your subscription has sufficient LINK tokens before deploying consumer contracts
2. Set appropriate gas limits: Balance between reliability and cost; use measured values from tests rather than guessing
3. Use key hash appropriately: Select the right key hash for your network and the gas lane speed you need
4. Implement request tracking: Track request IDs for debugging and to prevent replay issues

```bash
Example deployment command
npx hardhat run scripts/deploy.js --network sepolia
```

After deployment, always run the Hardhat verify task to publish your source code on Etherscan:

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS "COORDINATOR_ADDRESS" "SUBSCRIPTION_ID" "KEY_HASH"
```

Claude Code can generate the exact verify command with the correct constructor arguments based on your deploy script, which is easy to get wrong manually.

## Common Pitfalls and How to Avoid Them

Several mistakes trip up developers new to Chainlink VRF:

- Insufficient gas in callback: Always set `callbackGasLimit` high enough for your fulfillment logic. Measure it in tests and add a buffer.
- Forgetting request confirmations: Higher confirmations increase security against block reorganizations but add latency. Three confirmations is a sensible default.
- Not handling fulfillRandomWords reentrancy: If your fulfillment function calls external contracts or sends ETH, apply the checks-effects-interactions pattern to prevent reentrancy.
- Ignoring subscription balance: Monitor and fund subscriptions regularly. A depleted subscription causes all VRF requests to fail silently from the user's perspective.
- Using `block.timestamp` or `blockhash` as randomness: These are manipulable by validators. VRF exists specifically to replace these patterns, if you find yourself using them alongside VRF, something has gone wrong.

Claude Code can review your implementation and identify potential issues before deployment. Paste your entire contract and ask specifically: "Are there any security concerns with how I am using the VRF callback?" This targeted question tends to surface reentrancy and access control issues that a general review might miss.

## Integrating with Frontend Applications

Your smart contract is only part of the equation. Building a complete UX requires frontend integration:

```javascript
// Example: Requesting random words from frontend
const requestRandomWords = async (contract) => {
 const tx = await contract.requestRandomWords();
 const receipt = await tx.wait();
 // Extract requestId from events
 const requestId = receipt.events[0].args.requestId;
 return requestId;
};
```

Monitor the `RandomWordsRequested` and `RandomWordsFulfilled` events to provide user feedback during the VRF process. Because VRF fulfillment is asynchronous, typically taking a few blocks, you need to poll or subscribe to events to know when the random value is available:

```javascript
// Listen for fulfillment
const listenForFulfillment = (contract, requestId, callback) => {
 const filter = contract.filters.RandomWordsFulfilled(requestId);
 contract.once(filter, (reqId, randomWords) => {
 callback(randomWords);
 });
};
```

Claude Code can generate a complete React hook that wraps this pattern, including loading state management and error handling for the case where the subscription runs out of LINK mid-request.

## Conclusion

Chainlink VRF enables trustless randomness for blockchain applications, and Claude Code makes implementing it significantly easier. By following the patterns in this guide, proper contract architecture, thorough testing, and careful deployment, you can build reliable VRF-powered applications efficiently.

Remember to start with testnet deployment, validate your implementation thoroughly, and monitor subscription balances in production. With these practices in place, you will be well-equipped to use Chainlink VRF in any project requiring provably fair randomness.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-chainlink-vrf-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


