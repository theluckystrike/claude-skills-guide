---
render_with_liquid: false
layout: default
title: "Building a Chrome Extension for Senior"
description: "Learn how to build a Chrome extension that helps users discover and apply senior discounts. Includes code examples, API integration patterns, and best."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-senior-discount-chrome/
reviewed: true
score: 8
categories: [guides]
geo_optimized: true
---

Building a Chrome extension for senior discounts presents an interesting technical challenge. You need to aggregate discount information from multiple sources, detect when users are on retail sites, and present relevant savings opportunities without slowing down the browsing experience. This guide walks through the architectural decisions and implementation details you'll need to create a production-ready discount discovery extension.

## Understanding the Core Requirements

A senior discount Chrome extension must solve several interconnected problems. First, you need a reliable data source for discount information, retailers often publish senior discount policies but don't always make them easy to find programmatically. Second, you need content scripts that can detect when users land on pages where discounts apply. Finally, you need a clean user interface that presents savings without being intrusive.

The average senior discount ranges from 5% to 15% and typically requires verification through membership cards, AARP membership, or state-issued ID. Your extension needs to communicate these requirements clearly while maintaining a frictionless experience.

## Project Structure and Manifest Configuration

Starting with Manifest V3, your extension will use a specific directory structure. Here's a minimal setup:

```
senior-discount-finder/
 manifest.json
 background.js
 content.js
 popup/
 popup.html
 popup.js
 utils/
 discount-detector.js
 data/
 retailers.json
```

Your manifest.json defines the extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Senior Discount Finder",
 "version": "1.0.0",
 "description": "Automatically finds senior discounts on shopping sites",
 "permissions": ["activeTab", "storage"],
 "host_permissions": ["*://*.com/*"],
 "action": {
 "default_popup": "popup/popup.html",
 "default_icon": "icons/icon48.png"
 },
 "content_scripts": [{
 "matches": ["*://*/*"],
 "js": ["content.js"],
 "run_at": "document_idle"
 }]
}
```

The host permissions should be scoped appropriately for production. Using `*://*.com/*` works during development but you should restrict this to known retail domains before publishing.

## Building the Discount Detection System

The core logic lives in your content script. This script analyzes page content to determine if the current site offers senior discounts:

```javascript
// content.js - Main content script
const RETAILER_DATA = {
 'amazon.com': { discount: null, notes: 'Check for Amazon Prime Senior membership' },
 'walmart.com': { discount: '10%', verification: 'Valid ID at checkout' },
 'target.com': { discount: '10%', verification: 'Valid ID at checkout' },
 'kroger.com': { discount: '5%', verification: 'Senior day or valid ID' },
 'cvs.com': { discount: '10%', verification: 'Valid ID every Tuesday' },
 'walgreens.com': { discount: '10%', verification: 'Valid ID every first Tuesday' },
 ' Michaels': { discount: '10%', verification: 'Valid ID' }
};

function detectRetailer(hostname, pageText) {
 const hostnameLower = hostname.toLowerCase();
 
 for (const [domain, data] of Object.entries(RETAILER_DATA)) {
 if (hostnameLower.includes(domain.toLowerCase())) {
 return { domain, ...data };
 }
 }
 
 return null;
}

function showDiscountBadge(retailerInfo) {
 const existingBadge = document.getElementById('senior-discount-badge');
 if (existingBadge) return;
 
 const badge = document.createElement('div');
 badge.id = 'senior-discount-badge';
 badge.innerHTML = `
 <div class="discount-badge">
 <span class="icon"></span>
 <span class="text">Senior Discount: ${retailerInfo.discount || 'Available'}</span>
 <span class="verify">${retailerInfo.verification || ''}</span>
 </div>
 `;
 
 badge.style.cssText = `
 position: fixed;
 bottom: 20px;
 right: 20px;
 background: #2563eb;
 color: white;
 padding: 12px 20px;
 border-radius: 8px;
 font-family: system-ui, sans-serif;
 font-size: 14px;
 z-index: 999999;
 box-shadow: 0 4px 12px rgba(0,0,0,0.15);
 cursor: pointer;
 `;
 
 document.body.appendChild(badge);
}

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'checkDiscount') {
 const retailer = detectRetailer(window.location.hostname, document.body.innerText);
 sendResponse({ retailer });
 }
});
```

This approach uses pattern matching against the hostname and scans for keywords. For more solid detection, consider using the Page Visibility API to trigger checks only when users focus on relevant tabs.

## Implementing the Popup Interface

The popup provides users with quick access to settings and saved discounts:

```html
<!-- popup/popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; font-family: system-ui, sans-serif; }
 .header { padding: 16px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; }
 .header h2 { margin: 0; font-size: 16px; color: #1e293b; }
 .content { padding: 16px; }
 .site-list { list-style: none; padding: 0; margin: 0; }
 .site-item { 
 padding: 12px 0; 
 border-bottom: 1px solid #f1f5f9;
 display: flex;
 justify-content: space-between;
 align-items: center;
 }
 .discount-tag {
 background: #dcfce7;
 color: #166534;
 padding: 4px 8px;
 border-radius: 4px;
 font-size: 12px;
 font-weight: 600;
 }
 .empty-state {
 text-align: center;
 color: #64748b;
 padding: 24px;
 }
 </style>
</head>
<body>
 <div class="header">
 <h2>Senior Discount Finder</h2>
 </div>
 <div class="content">
 <div id="current-site"></div>
 <div id="saved-sites"></div>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup/popup.js
document.addEventListener('DOMContentLoaded', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const hostname = new URL(tab.url).hostname;
 
 const response = await chrome.tabs.sendMessage(tab.id, { action: 'checkDiscount' });
 
 const currentSiteDiv = document.getElementById('current-site');
 
 if (response?.retailer) {
 const { discount, verification } = response.retailer;
 currentSiteDiv.innerHTML = `
 <div class="site-item">
 <div>
 <strong>${hostname}</strong><br>
 <small>${verification || 'Check for discount eligibility'}</small>
 </div>
 <span class="discount-tag">${discount || 'Check'}</span>
 </div>
 `;
 } else {
 currentSiteDiv.innerHTML = `
 <div class="empty-state">
 <p>No senior discount information available for this site.</p>
 </div>
 `;
 }
});
```

## Data Management and Updates

Managing retailer data requires a strategy for updates. You have several options:

Static JSON approach: Include retailer data in your extension and push updates through the Chrome Web Store. This works well for a curated list but requires review cycles for changes.

Remote fetch approach: Load discount data from your own server:

```javascript
// background.js - Fetch discount data periodically
async function updateDiscountData() {
 try {
 const response = await fetch('https://your-api.com/discounts');
 const data = await response.json();
 
 await chrome.storage.local.set({
 discountData: data,
 lastUpdated: Date.now()
 });
 } catch (error) {
 console.error('Failed to update discount data:', error);
 }
}

// Check for updates every 24 hours
chrome.alarms.create('updateDiscounts', { periodInMinutes: 1440 });
chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === 'updateDiscounts') {
 updateDiscountData();
 }
});
```

Extension Store approach: Use the chrome.storage.sync API to let users contribute and share discount discoveries:

```javascript
async function contributeDiscount(domain, discount, verification) {
 const contributions = await chrome.storage.sync.get('contributions') || {};
 contributions[domain] = { discount, verification, timestamp: Date.now() };
 await chrome.storage.sync.set({ contributions });
}
```

## Performance Considerations

Content scripts run on every page, so optimization matters. Use the `run_at` property in your manifest to control execution timing. The `document_idle` value loads your script after the DOM is ready but before some images, this balances responsiveness with page load performance.

For expensive operations like DOM scanning, use requestIdleCallback:

```javascript
function scanPageForDiscounts() {
 return new Promise((resolve) => {
 function doWork(deadline) {
 while (deadline.timeRemaining() > 0 && workQueue.length > 0) {
 processWorkItem(workQueue.shift());
 }
 
 if (workQueue.length > 0) {
 requestIdleCallback(doWork);
 } else {
 resolve(results);
 }
 }
 requestIdleCallback(doWork);
 });
}
```

## Testing and Deployment

Before publishing to the Chrome Web Store, test your extension thoroughly:

1. Install locally through `chrome://extensions/`, enable Developer mode, and use "Load unpacked"
2. Test on multiple retail sites to verify detection accuracy
3. Check the popup behavior on sites with and without discounts
4. Verify the extension doesn't break page functionality on sites with aggressive CSP

For enterprise deployment, Chrome supports administrative installation through Group Policy. You can also distribute through the Web Store with visibility set to "Unlisted" for private organization use.

## Summary

Building a senior discount Chrome extension combines web scraping, browser extension APIs, and user interface design. The key architectural decisions involve how you source and update discount data, how efficiently your content scripts detect relevant pages, and how you present savings information without disrupting the user experience.

Start with a curated list of major retailers, then expand through community contributions and automated discovery. The extension can evolve from a simple notification system to a comprehensive savings tool that tracks price histories and notifies users of discount eligibility.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-senior-discount-chrome)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Building a CLI DevTool with Claude Code: A Practical.](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Building AI Coding Culture in Engineering Teams](/building-ai-coding-culture-in-engineering-teams/)
- [Building Apps with Claude API: Anthropic SDK Python Guide](/building-apps-with-claude-api-anthropic-sdk-python-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


