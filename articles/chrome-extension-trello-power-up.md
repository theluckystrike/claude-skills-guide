---
layout: default
title: "Trello Power-Up manifest.json (2026)"
description: "Set up manifest.json for your Trello Power-Up Chrome extension. Code examples, API integration, and architecture patterns. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-trello-power-up/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

## Building a Chrome Extension Trello Power-Up

Trello Power-Ups extend Trello's functionality, allowing developers to add custom features to boards, cards, and lists. When combined with Chrome extensions, you create powerful browser-based tools that interact directly with Trello's API and UI. This guide walks through building a Chrome extension that functions as a Trello Power-Up, with practical code examples for developers and power users.

## Understanding the Architecture

A Trello Power-Up is essentially a JavaScript application that runs within Trello's iframe environment. It communicates with Trello through their Power-Up SDK, which provides methods for reading card data, updating UI, and storing persistence data. A Chrome extension, meanwhile, runs in the browser context and can access Chrome APIs, local storage, and the broader web.

The key distinction: Trello Power-Ups only run inside Trello. Chrome extensions run in the browser but can inject content scripts into Trello pages. The most solid approach combines both, a Chrome extension that provides the "Power-Up" capabilities while using Trello's client-side API.

## Setting Up Your Project

Create a new directory for your project and set up the basic Chrome extension structure:

```bash
mkdir trello-power-up-extension
cd trello-power-up-extension
mkdir -p icons src/background src/content src/power-up
```

Your manifest.json defines the extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Trello Custom Power-Up",
 "version": "1.0.0",
 "description": "Custom Power-Up functionality for Trello",
 "permissions": ["storage", "activeTab", "scripting"],
 "host_permissions": ["https://trello.com/*"],
 "background": {
 "service_worker": "src/background/background.js"
 },
 "content_scripts": [{
 "matches": ["https://trello.com/b/*"],
 "js": ["src/content/content.js"]
 }],
 "icons": {
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
}
```

## Integrating with Trello's Power-Up SDK

Trello provides a JavaScript SDK that your extension can load. The SDK exposes `TrelloPowerUp` globally, which you initialize with your Power-Up's capabilities.

Create the Power-Up initialization script:

```javascript
// src/power-up/trello-integration.js

const POWER_UP_KEY = 'your-trello-api-key';
const APP_NAME = 'My Custom Power-Up';

window.TrelloPowerUp.initialize({
 // Capability: Add a button to card back
 'card-badges': function(t, options) {
 return t.get('card', 'shared')
 .then(cardData => {
 return [{
 // Dynamic badge based on card data
 text: cardData.customField || 'No data',
 color: cardData.customField ? 'green' : 'gray',
 refresh: 10 // Refresh every 10 seconds
 }];
 });
 },
 
 // Capability: Add button to card back section
 'card-buttons': function(t, options) {
 return [{
 icon: './icons/icon48.png',
 text: 'Process Card',
 callback: function(t) {
 return t.modal({
 url: './modal.html',
 title: 'Process Card',
 height: 400
 });
 }
 }];
 },
 
 // Capability: Add section to card back
 'card-back-section': function(t, options) {
 return {
 title: 'Custom Processing',
 content: t.renderHtml('<div id="custom-section">Loading...</div>')
 };
 },
 
 // Capability: Save data persistence
 'card-from-url': function(t, options) {
 return {
 found: function(t, options) {
 // Called when URL is detected on card
 console.log('URL found on card:', options.url);
 }
 };
 }
}, {
 appKey: POWER_UP_KEY,
 appName: APP_NAME
});
```

## Communicating Between Chrome Extension and Trello

The content script bridges your Chrome extension with Trello's iframe. This script injects the Power-Up SDK and handles messaging:

```javascript
// src/content/content.js

// Listen for messages from background script
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'GET_TRELLO_CONTEXT') {
 // Extract Trello board and card context from page
 const context = extractTrelloContext();
 sendResponse(context);
 }
 
 if (message.type === 'UPDATE_CARD') {
 updateCardData(message.data)
 .then(result => sendResponse(result))
 .catch(error => sendResponse({ error: error.message }));
 return true; // Keep message channel open for async response
 }
});

function extractTrelloContext() {
 // Trello stores board/card IDs in the DOM
 const boardElement = document.querySelector('[data-board-id]');
 const cardElement = document.querySelector('[data-card-id]');
 
 return {
 boardId: boardElement?.dataset.boardId,
 cardId: cardElement?.dataset.cardId,
 boardUrl: window.location.pathname
 };
}

async function updateCardData(data) {
 // Use Trello's REST API via fetch
 const token = await getTrelloToken();
 const response = await fetch(`https://api.trello.com/1/cards/${data.cardId}`, {
 method: 'PUT',
 headers: {
 'Content-Type': 'application/json',
 'Authorization': `OAuth token=${token}`
 },
 body: JSON.stringify({
 desc: data.description,
 idLabels: data.labels
 })
 });
 
 return response.json();
}

async function getTrelloToken() {
 // Retrieve token from chrome storage
 return new Promise((resolve) => {
 chrome.storage.local.get(['trello_token'], (result) => {
 resolve(result.trello_token);
 });
 });
}
```

## Building a Practical Example: Card Priority Highlighter

Here's a complete example of a Chrome extension Power-Up that highlights cards based on priority keywords:

```javascript
// src/power-up/priority-highlighter.js

function highlightPriorityCards(t) {
 return t.cards('all')
 .then(cards => {
 const priorityKeywords = {
 'urgent': '#ff6b6b',
 'high': '#ffa502',
 'normal': '#7bed9f',
 'low': '#a4b0be'
 };
 
 cards.forEach(card => {
 const lowerName = card.name.toLowerCase();
 let priorityColor = null;
 
 Object.keys(priorityKeywords).forEach(keyword => {
 if (lowerName.includes(keyword)) {
 priorityColor = priorityKeywords[keyword];
 }
 });
 
 if (priorityColor) {
 // Apply visual indicator
 t.alert({
 message: `Priority detected: ${card.name}`,
 duration: 5,
 display: 'card'
 });
 }
 });
 });
}

// Register with Trello Power-Up
window.TrelloPowerUp.initialize({
 'board-buttons': function(t, options) {
 return [{
 icon: './icons/priority.png',
 text: 'Analyze Priorities',
 callback: t => highlightPriorityCards(t)
 }];
 }
});
```

## Best Practices for Production

Store your API credentials securely using Chrome's identity API rather than hardcoding tokens:

```javascript
// src/background/auth.js

chrome.identity.getAuthToken({ interactive: false }, (token) => {
 if (chrome.runtime.lastError) {
 console.error('Auth error:', chrome.runtime.lastError);
 return;
 }
 
 // Store token securely
 chrome.storage.local.set({ trello_token: token });
 
 // Use token for API calls
 fetch('https://api.trello.com/1/members/me', {
 headers: { 'Authorization': `Bearer ${token}` }
 });
});
```

Always handle the case where users haven't authorized Trello. Provide clear UI prompts and fallback behavior. Test your extension across different Trello plans, some Power-Up capabilities require Trello Gold or Enterprise.

## Wrapping Up

Building a Chrome extension that functions as a Trello Power-Up combines the best of both worlds: browser extension capabilities with Trello's embedded Power-Up SDK. The architecture described here gives you the foundation to create sophisticated integrations that can read, modify, and enhance Trello cards directly from the browser.

Start with the basic structure, add Trello SDK initialization, then layer on your specific functionality. The Trello developer documentation provides additional capability references, and their Power-Up framework handles the complexity of iframe communication and authentication.

## Advanced: Card Automation Triggers

React to card events automatically. When a card moves to "Done", trigger a deployment webhook:

```javascript
const t = TrelloPowerUp.iframe();

t.board('all').then(board => {
 const card = board.lists.flatMap(l => l.cards).find(c => c.id === cardId);
 if (card?.list?.name === 'Done') {
 triggerDeploymentWebhook(card);
 }
});
```

## Step-by-Step: Adding the Extension to Trello

1. Load the extension via `chrome://extensions` > "Load unpacked"
2. Navigate to your Trello board
3. Click "Power-Ups" in the board menu
4. Select "Custom Power-Up" and enter your extension's capability URL
5. The Power-Up iframe initializes and renders custom buttons on each card
6. Click a card. your extension's custom section appears below the card description

## Comparison with Native Trello Integrations

| Feature | Chrome Extension + Power-Up | Trello Butler | Zapier |
|---|---|---|---|
| Setup complexity | Medium (build it) | Low (no-code) | Low (visual builder) |
| Custom logic | Full JavaScript | Rule-based | Moderate |
| Runs when browser is closed | No | Yes | Yes |
| Cost | Free | Free/Gold plan | Subscription |

## Troubleshooting Common Issues

Power-Up iframe not loading: Trello requires Power-Up pages served over HTTPS. Use `ngrok` during development to expose your local server with a public HTTPS URL.

Trello API rate limits: Batch multiple card requests using the `/batch` endpoint:

```javascript
async function getBatchCardData(cardIds) {
 const params = cardIds.map(id => `/cards/${id}`).join(',');
 const res = await fetch(`https://api.trello.com/1/batch?urls=${encodeURIComponent(params)}&key=${KEY}&token=${TOKEN}`);
 return res.json();
}
```

Custom button not appearing: Ensure your capability registration includes `card-buttons`:

```javascript
TrelloPowerUp.initialize({ 'card-buttons': (t) => [{ text: 'My Action', callback: myAction }] });
```

The combination of Chrome extension capabilities with Trello's Power-Up framework gives you a powerful integration layer for custom project management automation.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-trello-power-up)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Form Filler Chrome Extension: A Developer and Power.](/ai-form-filler-chrome-extension/)
- [Best Privacy Browser 2026 Ranked: A Developer and Power User Guide](/best-privacy-browser-2026-ranked/)
- [Browser Memory Comparison 2026: A Developer and Power User Guide](/browser-memory-comparison-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

