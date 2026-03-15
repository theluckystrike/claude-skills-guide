---
layout: default
title: "Building a Chrome Extension for Prime Day Deal Finding"
description: "Learn how to build a Chrome extension that helps developers and power users find the best Prime Day deals across Amazon."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-prime-day-deal-finder/
---

{% raw %}
Amazon Prime Day creates massive demand, and finding genuine deals among the noise takes effort. A well-built Chrome extension can automate deal discovery, filter by categories, and alert you to price drops. This guide walks through building a functional Prime Day deal finder extension from scratch.

## Understanding the Architecture

A deal finder extension relies on three core components:

1. **Content scripts** that scrape deal pages
2. **Background scripts** for API communication and storage
3. **Popup UI** for displaying results to users

The extension intercepts deal data from Amazon pages, stores it locally, and provides filtering capabilities that Amazon's native search doesn't offer.

## Setting Up the Project Structure

Create a new directory with this structure:

```
prime-day-deal-finder/
├── manifest.json
├── popup/
│   ├── popup.html
│   ├── popup.css
│   └── popup.js
├── content/
│   └── content.js
├── background/
│   └── background.js
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
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
      <div class="deal-rating">★ ${deal.rating || 'N/A'}</div>
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

- Amazon's structure changes frequently—build in robust selectors
- Rate limiting prevents detection but adds delay
- Storage limits mean large deal collections need IndexedDB
- Cross-origin requests require careful permission handling

## Conclusion

A custom Chrome extension gives you control over deal discovery that generic shopping tools cannot match. By understanding content scripts, popup interfaces, and storage APIs, developers can build sophisticated filtering and alerting systems. The foundation above provides a starting point—extend it with price history tracking, deal sharing, or category-based alerts based on your specific needs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
