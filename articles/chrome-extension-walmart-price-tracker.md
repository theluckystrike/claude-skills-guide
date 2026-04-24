---
render_with_liquid: false

layout: default
title: "How to Build a Walmart Price Tracker Chrome Extension"
description: "Learn to build a Chrome extension that tracks Walmart product prices. Technical guide for developers covering API integration, content scripts, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-walmart-price-tracker/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---

Building a Chrome extension for tracking Walmart prices requires understanding web scraping boundaries, Chrome extension architecture, and real-time notification systems. This guide walks through creating a functional price tracker from scratch.

## Understanding the Architecture

A Walmart price tracker extension consists of three primary components:

1. Background Service Worker - Handles periodic price checks and notifications
2. Content Script - Injects into Walmart product pages to extract pricing data
3. Popup Interface - Displays tracked items and current prices to users

Before building, recognize that Walmart's Terms of Service restrict automated data collection. Use this knowledge responsibly, build for personal use or with explicit API partnerships.

## Setting Up the Extension Structure

Create your extension directory with the following structure:

```text
walmart-price-tracker/
 manifest.json
 background.js
 content.js
 popup.html
 popup.js
 popup.css
 icons/
 icon16.png
 icon48.png
 icon128.png
```

The manifest.json defines permissions and entry points:

```json
{
 "manifest_version": 3,
 "name": "Walmart Price Tracker",
 "version": "1.0.0",
 "description": "Track Walmart product prices and get notified of changes",
 "permissions": [
 "storage",
 "notifications",
 "activeTab"
 ],
 "host_permissions": [
 "https://www.walmart.com/*"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html",
 "default_icon": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
 },
 "content_scripts": [{
 "matches": ["https://www.walmart.com/ip/*"],
 "js": ["content.js"]
 }]
}
```

## Extracting Price Data with Content Scripts

The content script runs on Walmart product pages and extracts relevant pricing information. Walmart frequently changes their DOM structure, so build resilient selectors:

```javascript
// content.js
(function() {
 'use strict';

 function extractProductData() {
 const data = {
 productId: null,
 title: '',
 currentPrice: null,
 originalPrice: null,
 url: window.location.href,
 timestamp: new Date().toISOString()
 };

 // Extract product ID from URL or page
 const urlMatch = window.location.href.match(/\/ip\/[^\/]+\/(\d+)/);
 if (urlMatch) {
 data.productId = urlMatch[1];
 }

 // Extract title - Walmart uses multiple selectors
 const titleSelectors = [
 '[data-testid="product-title"]',
 'h1[itemprop="name"]',
 '.prod-ProductTitle'
 ];
 for (const selector of titleSelectors) {
 const titleEl = document.querySelector(selector);
 if (titleEl) {
 data.title = titleEl.textContent.trim();
 break;
 }
 }

 // Extract current price
 const priceSelectors = [
 '[data-testid="price-wrap"] .price-characteristic',
 '[itemprop="price"]',
 '.price-characteristic'
 ];
 for (const selector of priceSelectors) {
 const priceEl = document.querySelector(selector);
 if (priceEl) {
 data.currentPrice = parseFloat(priceEl.getAttribute('content') || priceEl.textContent);
 break;
 }
 }

 // Extract original price (if on sale)
 const originalSelectors = [
 '[data-testid="was-price"] .price-characteristic',
 '.strike-through'
 ];
 for (const selector of originalSelectors) {
 const origEl = document.querySelector(selector);
 if (origEl) {
 data.originalPrice = parseFloat(origEl.getAttribute('content') || origEl.textContent);
 break;
 }
 }

 return data;
 }

 // Listen for messages from popup or background
 chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'getProductData') {
 const data = extractProductData();
 sendResponse(data);
 }
 return true;
 });
})();
```

## Managing Data Storage

Use Chrome's storage API to persist tracked products:

```javascript
// background.js
'use strict';

const STORAGE_KEY = 'tracked_products';

async function getTrackedProducts() {
 const result = await chrome.storage.local.get(STORAGE_KEY);
 return result[STORAGE_KEY] || [];
}

async function saveTrackedProduct(product) {
 const products = await getTrackedProducts();
 const existingIndex = products.findIndex(p => p.productId === product.productId);
 
 if (existingIndex >= 0) {
 products[existingIndex] = { ...products[existingIndex], ...product, lastUpdated: new Date().toISOString() };
 } else {
 products.push({
 ...product,
 addedAt: new Date().toISOString(),
 lastUpdated: new Date().toISOString(),
 priceHistory: [{ price: product.currentPrice, date: new Date().toISOString() }]
 });
 }
 
 await chrome.storage.local.set({ [STORAGE_KEY]: products });
 return products;
}

async function removeTrackedProduct(productId) {
 const products = await getTrackedProducts();
 const filtered = products.filter(p => p.productId !== productId);
 await chrome.storage.local.set({ [STORAGE_KEY]: filtered });
 return filtered;
}

// Price check logic - fetches product pages and extracts current prices
async function checkPrices() {
 const products = await getTrackedProducts();
 const updatedProducts = [];
 
 for (const product of products) {
 try {
 const response = await fetch(product.url);
 const html = await response.text();
 
 // Extract price from HTML (simplified - real implementation needs proper parsing)
 const priceMatch = html.match(/"price":"?(\d+\.?\d*)"?/);
 const newPrice = priceMatch ? parseFloat(priceMatch[1]) : null;
 
 if (newPrice && newPrice !== product.currentPrice) {
 const priceChange = {
 price: newPrice,
 date: new Date().toISOString()
 };
 
 updatedProducts.push({
 ...product,
 currentPrice: newPrice,
 priceHistory: [...product.priceHistory, priceChange],
 lastUpdated: new Date().toISOString()
 });
 
 // Send notification for price changes
 await sendPriceNotification(product.title, product.currentPrice, newPrice);
 } else {
 updatedProducts.push(product);
 }
 } catch (error) {
 console.error(`Error checking price for ${product.productId}:`, error);
 updatedProducts.push(product);
 }
 }
 
 await chrome.storage.local.set({ [STORAGE_KEY]: updatedProducts });
}

async function sendPriceNotification(title, oldPrice, newPrice) {
 const direction = newPrice < oldPrice ? 'dropped' : 'increased';
 const change = Math.abs(oldPrice - newPrice).toFixed(2);
 
 await chrome.notifications.create({
 type: 'basic',
 iconUrl: 'icons/icon128.png',
 title: 'Walmart Price Alert',
 message: `${title} price has ${direction} by $${change}`
 });
}

// Check prices every 6 hours
setInterval(checkPrices, 6 * 60 * 60 * 1000);
```

## Building the Popup Interface

The popup provides users with a dashboard to manage tracked products:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <link rel="stylesheet" href="popup.css">
</head>
<body>
 <div class="container">
 <header>
 <h1>Walmart Price Tracker</h1>
 <button id="currentPageBtn">Track This Product</button>
 </header>
 
 <div id="trackedProducts">
 <h2>Tracked Products</h2>
 <ul id="productList"></ul>
 </div>
 
 <footer>
 <button id="checkNowBtn">Check Prices Now</button>
 <span id="lastCheck"></span>
 </footer>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
 const productList = document.getElementById('productList');
 const currentPageBtn = document.getElementById('currentPageBtn');
 const checkNowBtn = document.getElementById('checkNowBtn');
 
 // Load and display tracked products
 async function loadProducts() {
 const result = await chrome.storage.local.get('tracked_products');
 const products = result.tracked_products || [];
 
 productList.innerHTML = '';
 
 if (products.length === 0) {
 productList.innerHTML = '<li class="empty">No products tracked yet</li>';
 return;
 }
 
 for (const product of products) {
 const li = document.createElement('li');
 li.className = 'product-item';
 li.innerHTML = `
 <div class="product-info">
 <a href="${product.url}" target="_blank">${product.title}</a>
 <span class="price">$${product.currentPrice.toFixed(2)}</span>
 </div>
 <button class="remove-btn" data-id="${product.productId}">×</button>
 `;
 productList.appendChild(li);
 }
 }
 
 // Track current Walmart product
 currentPageBtn.addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 if (!tab.url.includes('walmart.com/ip/')) {
 alert('Navigate to a Walmart product page first');
 return;
 }
 
 chrome.tabs.sendMessage(tab.id, { action: 'getProductData' }, async (productData) => {
 if (productData && productData.productId) {
 await saveTrackedProduct(productData);
 loadProducts();
 currentPageBtn.textContent = 'Product Tracked!';
 setTimeout(() => currentPageBtn.textContent = 'Track This Product', 2000);
 }
 });
 });
 
 // Remove product from tracking
 productList.addEventListener('click', async (e) => {
 if (e.target.classList.contains('remove-btn')) {
 const productId = e.target.dataset.id;
 await removeTrackedProduct(productId);
 loadProducts();
 }
 });
 
 // Manual price check
 checkNowBtn.addEventListener('click', async () => {
 checkNowBtn.textContent = 'Checking...';
 await checkPrices();
 checkNowBtn.textContent = 'Check Prices Now';
 loadProducts();
 });
 
 loadProducts();
});
```

## Loading and Testing Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" (top right toggle)
3. Click "Load unpacked"
4. Select your extension directory

When visiting any Walmart product page, click the extension icon to add it to your tracking list. The background service will check prices every 6 hours and notify you of changes.

## Production Considerations

For a production extension, consider these enhancements:

- Implement proper error handling for network failures
- Add data encryption for stored prices
- Create a settings page for customization
- Implement rate limiting to avoid detection
- Add support for multiple retailers beyond Walmart
- Consider implementing the official Walmart API if available for your use case

Building a price tracker teaches valuable skills in Chrome extension development, web scraping ethics, and real-time notification systems. Use these principles to create useful tools while respecting platform terms of service.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-walmart-price-tracker)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Deal Finder Chrome Extension: A Developer's Guide to Building Price Tracking Tools](/deal-finder-chrome-extension/)
- [AI Flashcard Maker Chrome Extension: Build Your Own Learning Tool](/ai-flashcard-maker-chrome-extension/)
- [AI Quiz Generator Chrome Extension: Build Your Own Quiz Tool](/ai-quiz-generator-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Advanced: Price History Chart

Track prices over time and render a mini price history chart in the popup:

```javascript
function renderPriceHistory(canvas, product) {
 const ctx = canvas.getContext('2d');
 const history = product.priceHistory || [];
 if (history.length < 2) return;

 const prices = history.map(h => h.price);
 const min = Math.min(...prices) * 0.95;
 const max = Math.max(...prices) * 1.05;
 const range = max - min;

 ctx.clearRect(0, 0, canvas.width, canvas.height);
 ctx.strokeStyle = '#0071ce';
 ctx.lineWidth = 2;
 ctx.beginPath();

 prices.forEach((price, i) => {
 const x = (i / (prices.length - 1)) * canvas.width;
 const y = canvas.height - ((price - min) / range) * canvas.height;
 i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
 });
 ctx.stroke();
}
```

## Comparison with Existing Tools

| Tool | Setup | Real-time alerts | Price history | Cost |
|---|---|---|---|---|
| This extension | Build yourself | Yes | Yes (local) | Free |
| Honey | Install from store | Sale events only | Limited | Free |
| CamelCamelCamel | Website only | Email alerts | Excellent (Amazon only) | Free |
| Keepa | Install from store | Yes | Excellent | Free/Premium |

Building your own gives full control over data and notification triggers. The trade-off is maintenance when Walmart updates their page structure.

## Step-by-Step: Tracking Your First Product

1. Navigate to a Walmart product page (`walmart.com/ip/...`)
2. Click the extension icon in the toolbar
3. The popup detects the product page and enables "Track This Product"
4. Click the button. the content script extracts the product ID, title, and price
5. The background script stores the product and schedules 6-hour checks
6. Revisit the popup to see current price and history chart
7. Chrome sends a notification when the background alarm detects a price change

## Troubleshooting Common Issues

Selector no longer matching prices: Use `[itemprop="price"]` or look for JSON-LD structured data as a more resilient fallback:

```javascript
function extractPriceFromStructuredData() {
 const scripts = document.querySelectorAll('script[type="application/ld+json"]');
 for (const script of scripts) {
 try {
 const data = JSON.parse(script.textContent);
 if (data.offers?.price) return parseFloat(data.offers.price);
 } catch {}
 }
 return null;
}
```

`setInterval` not persisting in service worker: Replace `setInterval(checkPrices, ...)` with the `alarms` API:

```javascript
chrome.alarms.create('walmartPriceCheck', { periodInMinutes: 360 });
chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === 'walmartPriceCheck') checkPrices();
});
```

Notifications not appearing: Add `"notifications"` to the `permissions` array in the manifest and reload the extension.

Content script not running: Verify the `content_scripts.matches` pattern is `"https://www.walmart.com/ip/*"`. A missing wildcard silently prevents injection.

Building a price tracker teaches valuable skills in Chrome extension development, web scraping ethics, and real-time notification systems. Use these principles responsibly. build for personal use and respect platform terms of service.



