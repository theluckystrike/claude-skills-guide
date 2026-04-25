---

layout: default
title: "Amazon Price Tracker Chrome Extension"
description: "Build or use a price tracker Chrome extension for Amazon. Web scraping, price monitoring, and alert system implementation explained. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /price-tracker-chrome-extension-amazon/
categories: [guides]
tags: [chrome-extension, amazon, price-tracking, web-scraping]
reviewed: true
score: 8
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---


Building a price tracker Chrome extension for Amazon gives you complete control over price monitoring. Rather than relying on third-party services, you can create a custom solution tailored to your shopping needs. This guide walks through the technical implementation for developers and power users.

## Understanding Amazon's Page Structure

Amazon product pages present unique challenges for price extraction. The price appears in multiple locations depending on the product type, and the page uses dynamic JavaScript rendering. Your extension needs to handle several price elements:

- The main price (`.a-price-whole`)
- Strike-through prices for discounted items (`.a-text-price .a-offscreen`)
- Subscribe & Save pricing
- Lightning deal countdown timers
- Warehouse pricing variants

Here is a content script that extracts price data from Amazon product pages:

```javascript
// content.js - Amazon price extraction
function extractAmazonPrice() {
 const result = {
 currentPrice: null,
 originalPrice: null,
 discount: null,
 currency: 'USD',
 asin: null,
 productTitle: null,
 timestamp: new Date().toISOString()
 };

 // Extract ASIN from URL or page
 const urlMatch = window.location.pathname.match(/\/dp\/([A-Z0-9]{10})/);
 const asinMatch = document.querySelector('[data-asin]');
 result.asin = urlMatch ? urlMatch[1] : asinMatch?.getAttribute('data-asin');

 // Extract product title
 const titleElement = document.getElementById('productTitle');
 result.productTitle = titleElement ? titleElement.textContent.trim() : '';

 // Extract current price - multiple strategies
 const priceWhole = document.querySelector('.a-price-whole');
 const priceFraction = document.querySelector('.a-price-fraction');
 
 if (priceWhole) {
 const whole = priceWhole.textContent.replace(/[^0-9]/g, '');
 const fraction = priceFraction ? priceFraction.textContent : '00';
 result.currentPrice = parseFloat(`${whole}.${fraction}`);
 }

 // Extract original price (if discounted)
 const originalPriceElement = document.querySelector('.a-text-price .a-offscreen');
 if (originalPriceElement) {
 const originalText = originalPriceElement.textContent;
 const originalMatch = originalText.match(/[\d,]+\.?\d*/);
 if (originalMatch) {
 result.originalPrice = parseFloat(originalMatch[0].replace(/,/g, ''));
 }
 }

 // Calculate discount percentage
 if (result.currentPrice && result.originalPrice && result.originalPrice > 0) {
 result.discount = Math.round(((result.originalPrice - result.currentPrice) / result.originalPrice) * 100);
 }

 return result;
}

// Listen for messages from popup or background
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'getPriceData') {
 const priceData = extractAmazonPrice();
 sendResponse(priceData);
 }
 return true;
});
```

This extraction logic handles the most common Amazon price formats. The ASIN extraction enables tracking specific products across Amazon's global marketplaces.

## Storing Price History

Chrome's storage API provides persistent local storage for price history. For a production extension, consider using IndexedDB for larger datasets, but chrome.storage works well for personal use:

```javascript
// background.js - Price storage and tracking
const PRICE_STORAGE_KEY = 'amazon_price_history';

async function savePriceData(asin, priceData) {
 const storage = await chrome.storage.local.get(PRICE_STORAGE_KEY);
 const history = storage[PRICE_STORAGE_KEY] || {};
 
 if (!history[asin]) {
 history[asin] = {
 productTitle: priceData.productTitle,
 prices: [],
 lowestPrice: priceData.currentPrice,
 highestPrice: priceData.currentPrice,
 lastChecked: priceData.timestamp
 };
 }
 
 const productHistory = history[asin];
 
 // Add new price entry
 productHistory.prices.push({
 price: priceData.currentPrice,
 timestamp: priceData.timestamp
 });
 
 // Update price bounds
 productHistory.lowestPrice = Math.min(productHistory.lowestPrice, priceData.currentPrice);
 productHistory.highestPrice = Math.max(productHistory.highestPrice, priceData.currentPrice);
 productHistory.lastChecked = priceData.timestamp;
 
 // Keep only last 90 days of data
 const cutoffDate = new Date();
 cutoffDate.setDate(cutoffDate.getDate() - 90);
 productHistory.prices = productHistory.prices.filter(
 entry => new Date(entry.timestamp) > cutoffDate
 );
 
 await chrome.storage.local.set({ [PRICE_STORAGE_KEY]: history });
 return productHistory;
}

async function getPriceHistory(asin) {
 const storage = await chrome.storage.local.get(PRICE_STORAGE_KEY);
 return storage[PRICE_STORAGE_KEY]?.[asin] || null;
}
```

This storage approach maintains a rolling 90-day price history for each tracked product. You can query this data to display price trends in your popup interface.

## Implementing Price Alerts

Price alerts require comparing current prices against user-defined thresholds. This implementation supports both absolute price targets and percentage drops:

```javascript
// background.js - Price alert system
async function checkPriceAlerts(asin, currentPrice) {
 const storage = await chrome.storage.local.get('priceAlerts');
 const alerts = storage.priceAlerts || [];
 const matchingAlerts = alerts.filter(alert => 
 alert.asin === asin && 
 currentPrice <= alert.targetPrice
 );
 
 for (const alert of matchingAlerts) {
 await sendPriceNotification(alert, currentPrice);
 
 // Remove triggered one-time alerts
 if (!alert.recurring) {
 const updatedAlerts = alerts.filter(a => a.id !== alert.id);
 await chrome.storage.local.set({ priceAlerts: updatedAlerts });
 }
 }
}

async function sendPriceNotification(alert, currentPrice) {
 const notification = await chrome.notifications.create({
 type: 'basic',
 iconUrl: 'icon.png',
 title: 'Amazon Price Drop Alert!',
 message: `${alert.productName} is now $${currentPrice} (target: $${alert.targetPrice})`,
 priority: 2
 });
 
 // Optionally open the product page on click
 chrome.notifications.onClicked.addListener((notificationId) => {
 if (notificationId === notification) {
 chrome.tabs.create({ url: `https://www.amazon.com/dp/${alert.asin}` });
 }
 });
}
```

The notification system requires the `notifications` permission in your manifest. For Chrome Web Store distribution, note that aggressive notification usage may trigger review concerns.

## Building the Popup Interface

The popup provides the primary user interface for viewing tracked products and setting alerts:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 360px; font-family: system-ui, -apple-system, sans-serif; }
 .container { padding: 16px; }
 .header { font-size: 18px; font-weight: 600; margin-bottom: 16px; }
 .product-card { 
 background: #f8f9fa; border-radius: 8px; padding: 12px; margin-bottom: 12px;
 }
 .product-title { font-size: 14px; font-weight: 500; margin-bottom: 8px; }
 .price-row { display: flex; justify-content: space-between; align-items: center; }
 .current-price { font-size: 20px; font-weight: 700; color: #B12704; }
 .price-range { font-size: 12px; color: #565959; }
 .alert-btn { 
 background: #007185; color: white; border: none; padding: 8px 12px;
 border-radius: 4px; cursor: pointer; font-size: 12px; margin-top: 8px;
 }
 .add-product { 
 width: 100%; background: #ffd814; border: none; padding: 12px;
 border-radius: 20px; cursor: pointer; font-weight: 600;
 }
 </style>
</head>
<body>
 <div class="container">
 <div class="header">Amazon Price Tracker</div>
 <div id="trackedProducts"></div>
 <button id="trackCurrentBtn" class="add-product">Track This Product</button>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

The popup script handles user interactions and displays price data:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 // Check if on Amazon product page
 if (tab.url?.includes('amazon.com/dp/')) {
 document.getElementById('trackCurrentBtn').style.display = 'block';
 document.getElementById('trackCurrentBtn').addEventListener('click', async () => {
 const response = await chrome.tabs.sendMessage(tab.id, { action: 'getPriceData' });
 if (response?.asin) {
 await savePriceData(response.asin, response);
 loadTrackedProducts();
 }
 });
 }
 
 loadTrackedProducts();
});

async function loadTrackedProducts() {
 const storage = await chrome.storage.local.get('amazon_price_history');
 const history = storage.amazon_price_history || {};
 const container = document.getElementById('trackedProducts');
 
 container.innerHTML = '';
 
 for (const [asin, data] of Object.entries(history)) {
 const latestPrice = data.prices[data.prices.length - 1]?.price;
 const card = document.createElement('div');
 card.className = 'product-card';
 card.innerHTML = `
 <div class="product-title">${data.productTitle?.substring(0, 50)}...</div>
 <div class="price-row">
 <span class="current-price">$${latestPrice}</span>
 <span class="price-range">Low: $${data.lowestPrice} | High: $${data.highestPrice}</span>
 </div>
 <button class="alert-btn" data-asin="${asin}" data-price="${latestPrice}">
 Set Alert
 </button>
 `;
 container.appendChild(card);
 }
}
```

## Extension Manifest Configuration

Here is the complete Manifest V3 configuration:

```json
{
 "manifest_version": 3,
 "name": "Amazon Price Tracker",
 "version": "1.0",
 "description": "Track Amazon product prices and get notified of drops",
 "permissions": [
 "activeTab",
 "storage",
 "notifications"
 ],
 "host_permissions": [
 "https://*.amazon.com/*"
 ],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 },
 "content_scripts": [{
 "matches": ["https://*.amazon.com/dp/*"],
 "js": ["content.js"]
 }],
 "background": {
 "service_worker": "background.js"
 }
}
```

## Production Considerations

When extending this implementation, consider several enhancements. First, implement periodic background checks using the Alarm API to update prices even when the browser is running. Second, add support for multiple Amazon marketplaces (UK, DE, JP, etc.) by extending the host permissions and implementing marketplace-specific selectors.

Third, consider rate limiting to avoid triggering Amazon's anti-bot measures. Adding random delays between requests and limiting check frequency protects your IP from being blocked.

Fourth, for data persistence beyond a single browser, implement optional cloud sync using Firebase or a simple backend API. This enables cross-device price tracking.

Finally, test extensively across different Amazon page layouts. Amazon frequently changes their DOM structure, so building resilient selectors with multiple fallbacks prevents the extension from breaking during Amazon's UI updates.

A custom Amazon price tracker Chrome extension puts you in control of your shopping data. By implementing the core components outlined here, you can build a tool that precisely matches your price monitoring needs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=price-tracker-chrome-extension-amazon)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Price History Chrome Extension: Technical Implementation.](/price-history-chrome-extension/)
- [Chrome Extension Black Friday Deal Tracker: A.](/chrome-extension-black-friday-deal-tracker/)
- [Chrome Extension Linear Issue Tracker: A Developer's Guide](/chrome-extension-linear-issue-tracker/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Step-by-Step: Building the Amazon Price Tracker

1. Detect Amazon product pages: check `window.location.hostname` for `amazon.com` (or regional variants) and the URL path for `/dp/` which identifies product detail pages.
2. Extract ASIN and current price: the ASIN is in the URL path segment after `/dp/`. The price is in `#priceblock_ourprice`, `#priceblock_dealprice`, or `.a-price-whole` depending on the product type and whether a deal is active.
3. Store a price history record: on each visit, append `{ asin, price, currency, timestamp }` to the product's history array in `chrome.storage.local`.
4. Draw a sparkline chart: in the popup, render a small SVG line chart of the price history using only vanilla JS. no library needed for a simple sparkline.
5. Set a target price alert: add an input field where the user types their maximum acceptable price. Store it alongside the history. Check on every price read whether the current price has dropped to or below the target.
6. Trigger a browser notification: when the price drops below the target, call `chrome.notifications.create()` with the product name, current price, and a direct link to the product page.

## Reading Amazon Prices Reliably

Amazon's product page DOM is complex and changes frequently. Use a waterfall of selectors with a final regex fallback:

```javascript
function extractPrice() {
 const selectors = [
 '#priceblock_ourprice',
 '#priceblock_dealprice',
 '#priceblock_saleprice',
 '.a-price[data-a-size="xl"] .a-offscreen',
 '.a-price .a-offscreen',
 ];
 for (const sel of selectors) {
 const el = document.querySelector(sel);
 if (el) {
 const match = el.textContent.match(/[\d,]+\.?\d*/);
 if (match) return parseFloat(match[0].replace(/,/g, ''));
 }
 }
 // Regex fallback on page text
 const match = document.body.innerText.match(/\$\s*([\d,]+\.\d{2})/);
 return match ? parseFloat(match[1].replace(/,/g, '')) : null;
}
```

## Comparison with Dedicated Price Trackers

| Tool | Amazon support | Price history | Alerts | Privacy | Cost |
|---|---|---|---|---|---|
| This extension | Yes | Local storage | Browser notification | Local only | Free (build it) |
| CamelCamelCamel | Yes | Years of history | Email | Server-side | Free |
| Keepa | Yes | Years of history | Email/app | Server-side | Free/Premium |
| Honey | Yes | 30-day chart | No alerts | PayPal data | Free |
| PriceSpy | Limited | 3 months | Email | Server-side | Free |

Building your own tracker means price history is private and never sent to a third party. The trade-off is that you only track products you have personally visited. there is no pre-populated database of historical prices.

## Advanced: Multi-Region Price Comparison

The same product is often cheaper on Amazon.co.uk or Amazon.de than on Amazon.com after currency conversion. Add a background fetch that checks the current price on 3-4 regional Amazon domains for the same ASIN:

```javascript
async function checkRegionalPrices(asin) {
 const regions = [
 { domain: 'amazon.com', currency: 'USD' },
 { domain: 'amazon.co.uk', currency: 'GBP' },
 { domain: 'amazon.de', currency: 'EUR' },
 { domain: 'amazon.ca', currency: 'CAD' },
 ];
 // Note: requires CORS proxy since Amazon sets same-site cookies
 // Use a lightweight server-side fetch function or background offscreen document
 const results = await Promise.allSettled(
 regions.map(r => fetchPriceFromRegion(asin, r.domain, r.currency))
 );
 return results.filter(r => r.status === 'fulfilled').map(r => r.value);
}
```

## Troubleshooting

Price reading as null on some products: Amazon uses different page layouts for third-party sellers, warehouse deals, and subscribe-and-save items. Check that your selector list includes `.a-price[data-a-size="b"]` for Subscribe & Save prices and `#usedBuySection .a-color-price` for used listings.

Storage filling up for heavily tracked products: Limit price history to the last 365 entries per ASIN. On each write, check the history array length and slice off the oldest entries if it exceeds the limit.

Notification not firing even when price drops: `chrome.notifications` requires the `notifications` permission in the manifest. Also verify that the user has allowed notifications from Chrome in the OS notification settings. extensions respect the system-level permission.





---

## Frequently Asked Questions

### What is Understanding Amazon's Page Structure?

Amazon product pages display prices in multiple DOM locations using selectors like `.a-price-whole`, `.a-text-price .a-offscreen`, and Subscribe & Save elements. The page uses dynamic JavaScript rendering, so a price tracker extension needs a waterfall of CSS selectors with fallback strategies. The ASIN identifier is extracted from the URL path after `/dp/` and uniquely identifies each product across Amazon's global marketplaces.

### What is Storing Price History?

Storing price history uses Chrome's `chrome.storage.local` API to persist per-product price records keyed by ASIN. Each record contains the product title, a timestamped prices array, and lowest/highest price bounds. The implementation maintains a rolling 90-day history by filtering entries older than the cutoff date on each write. For larger datasets, IndexedDB provides better performance than chrome.storage.

### What is Implementing Price Alerts?

Price alerts compare the current scraped price against user-defined target thresholds stored in `chrome.storage.local`. When the current price drops to or below the target, the extension fires a browser notification using `chrome.notifications.create()` with the product name, current price, and a direct Amazon link. Alerts can be configured as one-time (auto-removed after triggering) or recurring for ongoing monitoring.

### What is Building the Popup Interface?

The popup interface is an HTML page defined in `popup.html` that displays tracked products with their current prices, historical low/high ranges, and alert buttons. It uses `chrome.tabs.query` to detect whether the user is on an Amazon product page, enabling a "Track This Product" button. The popup script communicates with the content script via `chrome.tabs.sendMessage` to extract live price data from the active tab.

### What is Extension Manifest Configuration?

The extension uses Manifest V3 with permissions for `activeTab`, `storage`, and `notifications`. Host permissions are set to `https://*.amazon.com/*` to restrict content script injection to Amazon domains. The content script matches the URL pattern `https://*.amazon.com/dp/*` to run only on product detail pages. A background service worker in `background.js` handles price storage, alert checking, and notification delivery.
