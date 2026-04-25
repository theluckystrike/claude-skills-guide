---
layout: default
title: "Building a Chrome Extension for Prime"
description: "Claude Code extension tip: learn how to build a Chrome extension that helps developers and power users find the best Prime Day deals across Amazon."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-prime-day-deal-finder/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---


Amazon Prime Day creates massive demand, and finding genuine deals among the noise takes effort. A well-built Chrome extension can automate deal discovery, filter by categories, and alert you to price drops. This guide walks through building a functional Prime Day deal finder extension from scratch.

## Understanding the Architecture

A deal finder extension relies on three core components:

1. Content scripts that scrape deal pages
2. Background scripts for API communication and storage
3. Popup UI for displaying results to users

The extension intercepts deal data from Amazon pages, stores it locally, and provides filtering capabilities that Amazon's native search doesn't offer.

## Setting Up the Project Structure

Create a new directory with this structure:

```
prime-day-deal-finder/
 manifest.json
 popup/
 popup.html
 popup.css
 popup.js
 content/
 content.js
 background/
 background.js
 icons/
 icon16.png
 icon48.png
 icon128.png
```

## Writing the Manifest

The manifest defines permissions and declares your extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Prime Day Deal Finder",
 "version": "1.0",
 "description": "Find the best Prime Day deals with advanced filtering",
 "permissions": [
 "storage",
 "activeTab",
 "scripting"
 ],
 "host_permissions": [
 "https://*.amazon.com/*"
 ],
 "action": {
 "default_popup": "popup/popup.html",
 "default_icon": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
 },
 "content_scripts": [{
 "matches": ["https://*.amazon.com/*"],
 "js": ["content/content.js"]
 }],
 "background": {
 "service_worker": "background/background.js"
 }
}
```

## Building the Content Script

The content script extracts deal information from Amazon product pages. This runs on Amazon URLs and pulls relevant data:

```javascript
// content/content.js

function extractDealData() {
 const product = {
 asin: window.location.pathname.match(/\/dp\/([A-Z0-9]+)/)?.[1],
 title: document.querySelector('#productTitle')?.textContent?.trim(),
 price: document.querySelector('.a-price .a-offscreen')?.textContent,
 originalPrice: document.querySelector('.a-text-price .a-offscreen')?.textContent,
 rating: document.querySelector('.a-icon-alt')?.textContent?.split(' ')[0],
 discount: calculateDiscount(),
 isPrime: !!document.querySelector('.a-badge-prime'),
 url: window.location.href
 };

 return product;
}

function calculateDiscount() {
 const current = document.querySelector('.a-price .a-offscreen')?.textContent;
 const original = document.querySelector('.a-text-price .a-offscreen')?.textContent;
 
 if (current && original) {
 const currentNum = parseFloat(current.replace(/[^0-9.]/g, ''));
 const originalNum = parseFloat(original.replace(/[^0-9.]/g, ''));
 return Math.round(((originalNum - currentNum) / originalNum) * 100);
 }
 return 0;
}

// Listen for messages from popup or background
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'getDealData') {
 sendResponse(extractDealData());
 }
});
```

## Creating the Popup Interface

The popup provides a quick-view interface for saved deals:

```html
<!-- popup/popup.html -->
<!DOCTYPE html>
<html>
<head>
 <link rel="stylesheet" href="popup.css">
</head>
<body>
 <div class="container">
 <header>
 <h1>Prime Day Deals</h1>
 <button id="scanPage" class="btn-primary">Scan Current Page</button>
 </header>
 
 <div class="filters">
 <label>
 Min Discount %
 <input type="number" id="minDiscount" value="20" min="0" max="100">
 </label>
 <label>
 Min Rating
 <input type="number" id="minRating" value="3.5" min="0" max="5" step="0.1">
 </label>
 </div>
 
 <div id="dealsList" class="deals-list"></div>
 
 <footer>
 <button id="clearDeals" class="btn-secondary">Clear All</button>
 <span id="dealCount">0 deals saved</span>
 </footer>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

## Implementing Popup Logic

The popup script handles user interactions and displays stored deals:

```javascript
// popup/popup.js

document.addEventListener('DOMContentLoaded', () => {
 loadSavedDeals();
 setupEventListeners();
});

function setupEventListeners() {
 document.getElementById('scanPage').addEventListener('click', scanCurrentPage);
 document.getElementById('clearDeals').addEventListener('click', clearAllDeals);
 
 document.getElementById('minDiscount').addEventListener('input', filterDeals);
 document.getElementById('minRating').addEventListener('input', filterDeals);
}

async function scanCurrentPage() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 chrome.tabs.sendMessage(tab.id, { action: 'getDealData' }, (product) => {
 if (product && product.asin) {
 saveDeal(product);
 loadSavedDeals();
 }
 });
}

function saveDeal(product) {
 chrome.storage.local.get(['deals'], (result) => {
 const deals = result.deals || [];
 const exists = deals.find(d => d.asin === product.asin);
 
 if (!exists) {
 deals.push(product);
 chrome.storage.local.set({ deals });
 }
 });
}

function loadSavedDeals() {
 chrome.storage.local.get(['deals'], (result) => {
 const deals = result.deals || [];
 displayDeals(deals);
 });
}

function displayDeals(deals) {
 const minDiscount = parseInt(document.getElementById('minDiscount').value);
 const minRating = parseFloat(document.getElementById('minRating').value);
 
 const filtered = deals.filter(d => 
 d.discount >= minDiscount && 
 (d.rating || 0) >= minRating
 );
 
 const container = document.getElementById('dealsList');
 container.innerHTML = filtered.map(deal => `
 <div class="deal-card">
 <h3>${deal.title?.substring(0, 50)}...</h3>
 <div class="deal-price">
 <span class="current">${deal.price}</span>
 <span class="original">${deal.originalPrice}</span>
 <span class="discount">-${deal.discount}%</span>
 </div>
 <div class="deal-rating"> ${deal.rating || 'N/A'}</div>
 <a href="${deal.url}" target="_blank" class="btn-view">View Deal</a>
 </div>
 `).join('');
 
 document.getElementById('dealCount').textContent = `${filtered.length} deals found`;
}

function clearAllDeals() {
 chrome.storage.local.set({ deals: [] });
 loadSavedDeals();
}

function filterDeals() {
 loadSavedDeals();
}
```

## Adding Background Processing

For more advanced features like price tracking over time, use the background script:

```javascript
// background/background.js

chrome.alarms.create('priceCheck', { periodInMinutes: 30 });

chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === 'priceCheck') {
 checkStoredDeals();
 }
});

async function checkStoredDeals() {
 const { deals } = await chrome.storage.local.get('deals');
 
 if (!deals) return;
 
 for (const deal of deals) {
 try {
 const response = await fetch(deal.url);
 const text = await response.text();
 // Parse new price and compare
 // Send notification if price dropped
 } catch (error) {
 console.error('Price check failed:', error);
 }
 }
}
```

## Testing Your Extension

Load your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select your extension directory

Test on Amazon product pages and Prime Day deal pages. The extension should capture product data when you click the scan button.

## Key Considerations for Production

When scaling beyond a personal tool, consider these factors:

- Amazon's structure changes frequently, build in solid selectors
- Rate limiting prevents detection but adds delay
- Storage limits mean large deal collections need IndexedDB
- Cross-origin requests require careful permission handling

## Conclusion

A custom Chrome extension gives you control over deal discovery that generic shopping tools cannot match. By understanding content scripts, popup interfaces, and storage APIs, developers can build sophisticated filtering and alerting systems. The foundation above provides a starting point, extend it with price history tracking, deal sharing, or category-based alerts based on your specific needs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-prime-day-deal-finder)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Building a Chrome Extension for Gaming Deal Finding](/chrome-extension-gaming-deal-finder-chrome/)
- [Deal Finder Chrome Extension: A Developer's Guide to Building Price Tracking Tools](/deal-finder-chrome-extension/)
- [Building a CLI DevTool with Claude Code: A Practical.](/building-a-cli-devtool-with-claude-code-walkthrough/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Advanced: Category-Aware Scanning

Prime Day surfaces deals across dozens of categories simultaneously. Prioritize categories with a config-driven scanner:

```javascript
const PRIORITY_CATEGORIES = ['electronics', 'gaming', 'home-kitchen'];

async function scanCategoryDeals(category) {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const results = await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: (sel) => Array.from(document.querySelectorAll(sel)).map(el => ({
 asin: el.dataset.asin,
 title: el.querySelector('h2 a span')?.textContent?.trim(),
 price: el.querySelector('.a-price .a-offscreen')?.textContent
 })),
 args: ['[data-component-type="s-search-result"]']
 });
 return results[0]?.result || [];
}
```

Combine scans using `Promise.all` to check multiple departments simultaneously during the Prime Day window.

## Best Practices for Prime Day Usage

Build in courteous rate limiting to avoid hammering Amazon's infrastructure:

- Space out page requests by at least 2-3 seconds
- Use the `alarms` API with a minimum `periodInMinutes: 5` for background checks
- Cache results in `chrome.storage.local` to avoid redundant fetches
- Disable or reduce check frequency outside Prime Day windows

## Comparison with Amazon's Built-In Tools

| Feature | This Extension | Amazon Wish List | Amazon Deal Notifications |
|---|---|---|---|
| Custom filters | Full control | Basic | Category only |
| Cross-category view | Yes | No | No |
| Price history | You build it | No | No |
| Export data | Yes | No | No |
| Works outside Prime Day | Yes | Yes | No |

The extension is most valuable during Prime Day because you can combine multiple filters simultaneously. minimum discount percentage, minimum rating, specific category. that Amazon's native interface does not support together.

## Troubleshooting Common Issues

Deal data missing after page load: Amazon renders deal data asynchronously. Wait for the DOM to stabilize using a `MutationObserver`:

```javascript
function waitForDeals(selector, timeout = 5000) {
 return new Promise((resolve, reject) => {
 const observer = new MutationObserver(() => {
 const el = document.querySelector(selector);
 if (el) { observer.disconnect(); resolve(el); }
 });
 observer.observe(document.body, { childList: true, subtree: true });
 setTimeout(() => { observer.disconnect(); reject(new Error('Timeout')); }, timeout);
 });
}
```

Extension popup closes when opening a deal: Open links with `chrome.tabs.create` instead of anchor tags so the popup stays open:

```javascript
document.getElementById('viewDeal').addEventListener('click', () => {
 chrome.tabs.create({ url: deal.url });
});
```

Storage filling up during Prime Day: Keep only the top 50 deals ranked by discount:

```javascript
async function trimDeals() {
 const { deals = [] } = await chrome.storage.local.get('deals');
 const trimmed = deals.sort((a, b) => b.discount - a.discount).slice(0, 50);
 await chrome.storage.local.set({ deals: trimmed });
}
```

A custom Chrome extension gives you control over deal discovery during Prime Day that generic shopping tools cannot match. Start with the foundation above and extend it with price history tracking or category-based alerts based on your needs.




