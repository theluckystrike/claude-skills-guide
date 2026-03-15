---

layout: default
title: "Chrome Extension Import Duty Calculator: A Developer Guide"
description: "Learn how to build a Chrome extension that calculates import duties and tariffs. Practical code examples, APIs, and implementation patterns for developers."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-import-duty-calculator/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, import-duty, calculator]
---

{% raw %}
# Chrome Extension Import Duty Calculator: A Developer Guide

Building a Chrome extension that calculates import duties and tariffs opens up practical utility for e-commerce sellers, international shoppers, and logistics professionals. This guide walks you through creating a fully functional import duty calculator extension from scratch.

## Understanding Import Duty Calculations

Import duties depend on several key factors: the goods' HS (Harmonized System) code, the declared value, the country of origin, and the destination country's tariff schedule. A well-designed calculator must account for these variables while providing accurate estimates.

The fundamental formula for calculating import duties is:

```
Duty = (Declared Value + Shipping Cost + Insurance) × Duty Rate
```

However, different countries apply various additional fees: processing fees, VAT/GST, anti-dumping duties, and luxury taxes. Your extension needs to handle these complexities gracefully.

## Setting Up Your Extension Project

Every Chrome extension begins with a manifest file. For a duty calculator, you'll need Manifest V3 with specific permissions:

```json
{
  "manifest_version": 3,
  "name": "Import Duty Calculator",
  "version": "1.0.0",
  "description": "Calculate import duties and tariffs for international shipments",
  "permissions": [
    "activeTab",
    "storage"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  }
}
```

Create a project structure like this:

```
import-duty-calculator/
├── manifest.json
├── popup.html
├── popup.js
├── background.js
├── content.js
├── styles.css
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```

## Building the Popup Interface

The popup serves as your primary user interface. Keep it clean and focused on the essential inputs:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Import Duty Calculator</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="calculator">
    <h2>Import Duty Calculator</h2>
    
    <div class="form-group">
      <label for="country">Destination Country</label>
      <select id="country" required>
        <option value="">Select country...</option>
        <option value="US">United States</option>
        <option value="EU">European Union</option>
        <option value="UK">United Kingdom</option>
        <option value="CA">Canada</option>
        <option value="AU">Australia</option>
      </select>
    </div>
    
    <div class="form-group">
      <label for="value">Item Value (USD)</label>
      <input type="number" id="value" min="0" step="0.01" required>
    </div>
    
    <div class="form-group">
      <label for="shipping">Shipping Cost (USD)</label>
      <input type="number" id="shipping" min="0" step="0.01" value="0">
    </div>
    
    <div class="form-group">
      <label for="category">Product Category</label>
      <select id="category">
        <option value="general">General Merchandise</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing & Apparel</option>
        <option value="beauty">Beauty & Cosmetics</option>
        <option value="food">Food & Beverages</option>
      </select>
    </div>
    
    <button id="calculate">Calculate Duty</button>
    
    <div id="results" class="results hidden">
      <h3>Estimated Costs</h3>
      <div class="result-row">
        <span>Duty:</span>
        <span id="duty-amount">$0.00</span>
      </div>
      <div class="result-row">
        <span>VAT/GST:</span>
        <span id="vat-amount">$0.00</span>
      </div>
      <div class="result-row">
        <span>Processing Fee:</span>
        <span id="processing-fee">$0.00</span>
      </div>
      <div class="result-row total">
        <span>Total Additional Costs:</span>
        <span id="total-cost">$0.00</span>
      </div>
    </div>
  </div>
  
  <script src="popup.js"></script>
</body>
</html>
```

## Implementing the Calculation Logic

The core calculation happens in your popup script. Here's how to implement duty rates for different scenarios:

```javascript
// popup.js
class DutyCalculator {
  constructor() {
    this.rates = {
      US: {
        deMinimis: 800,
        dutyRates: {
          general: 0.046,
          electronics: 0.025,
          clothing: 0.125,
          beauty: 0.065,
          food: 0.042
        },
        processingFee: 0,
        vat: 0
      },
      EU: {
        deMinimis: 150,
        dutyRates: {
          general: 0.027,
          electronics: 0.014,
          clothing: 0.12,
          beauty: 0.067,
          food: 0.089
        },
        processingFee: 0,
        vat: 0.21 // Average EU VAT
      },
      UK: {
        deMinimis: 135,
        dutyRates: {
          general: 0.028,
          electronics: 0.014,
          clothing: 0.11,
          beauty: 0.065,
          food: 0.076
        },
        processingFee: 0,
        vat: 0.20
      },
      CA: {
        deMinimis: 40,
        dutyRates: {
          general: 0.045,
          electronics: 0.035,
          clothing: 0.18,
          beauty: 0.085,
          food: 0.065
        },
        processingFee: 9.95,
        vat: 0.05 // GST
      },
      AU: {
        deMinimis: 1000,
        dutyRates: {
          general: 0.025,
          electronics: 0.01,
          clothing: 0.10,
          beauty: 0.05,
          food: 0.015
        },
        processingFee: 0,
        vat: 0.10 // GST
      }
    };
  }

  calculate(country, itemValue, shippingCost, category) {
    const config = this.rates[country];
    if (!config) {
      throw new Error('Unsupported country');
    }

    const totalValue = itemValue + shippingCost;
    
    // Check if below de minimis threshold
    if (totalValue <= config.deMinimis) {
      return {
        duty: 0,
        vat: 0,
        processingFee: 0,
        total: 0,
        belowDeMinimis: true,
        deMinimisThreshold: config.deMinimis
      };
    }

    // Calculate duty based on category
    const dutyRate = config.dutyRates[category] || config.dutyRates.general;
    const duty = totalValue * dutyRate;

    // Calculate VAT/GST on (value + duty)
    const vatBase = totalValue + duty;
    const vat = vatBase * config.vat;

    // Processing fees (mainly for Canada)
    const processingFee = config.processingFee;

    return {
      duty: Math.round(duty * 100) / 100,
      vat: Math.round(vat * 100) / 100,
      processingFee,
      total: Math.round((duty + vat + processingFee) * 100) / 100,
      belowDeMinimis: false,
      deMinimisThreshold: config.deMinimis
    };
  }
}

// Initialize and bind events
document.addEventListener('DOMContentLoaded', () => {
  const calculator = new DutyCalculator();
  const calculateBtn = document.getElementById('calculate');
  const resultsDiv = document.getElementById('results');

  calculateBtn.addEventListener('click', () => {
    const country = document.getElementById('country').value;
    const value = parseFloat(document.getElementById('value').value) || 0;
    const shipping = parseFloat(document.getElementById('shipping').value) || 0;
    const category = document.getElementById('category').value;

    if (!country || value <= 0) {
      alert('Please fill in all required fields');
      return;
    }

    try {
      const result = calculator.calculate(country, value, shipping, category);
      
      document.getElementById('duty-amount').textContent = `$${result.duty.toFixed(2)}`;
      document.getElementById('vat-amount').textContent = `$${result.vat.toFixed(2)}`;
      document.getElementById('processing-fee').textContent = `$${result.processingFee.toFixed(2)}`;
      document.getElementById('total-cost').textContent = `$${result.total.toFixed(2)}`;
      
      resultsDiv.classList.remove('hidden');
      
      // Save to history
      this.saveCalculation({ country, value, shipping, category, result });
    } catch (error) {
      alert(error.message);
    }
  });
});
```

## Adding Content Script Capabilities

For advanced functionality, you might want to extract product information directly from e-commerce pages:

```javascript
// content.js - Extract product info from supported sites
const selectors = {
  amazon: {
    price: '#priceblock_ourprice, #priceblock_dealprice',
    title: '#productTitle',
    category: '#wayfinding-breadcrumbs_container'
  },
  ebay: {
    price: '.x-price-primary span',
    title: '.x-item-title__mainTitle',
    category: '.x-breadcrumbs'
  },
  generic: {
    price: '[data-price], .price, .product-price',
    title: 'h1, [itemprop="name"]',
    category: '.breadcrumb, .category'
  }
};

function extractProductInfo() {
  const url = window.location.hostname;
  let selectorSet = selectors.generic;
  
  if (url.includes('amazon')) selectorSet = selectors.amazon;
  else if (url.includes('ebay')) selectorSet = selectors.ebay;
  
  const getText = (sel) => {
    const el = document.querySelector(sel);
    return el ? el.textContent.trim() : null;
  };
  
  const getPrice = (sel) => {
    const el = document.querySelector(sel);
    if (!el) return null;
    const text = el.textContent.replace(/[^0-9.]/g, '');
    return parseFloat(text) || null;
  };
  
  return {
    title: getText(selectorSet.title),
    price: getPrice(selectorSet.price),
    category: getText(selectorSet.category),
    url: window.location.href
  };
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getProductInfo') {
    const info = extractProductInfo();
    sendResponse(info);
  }
});
```

## Styling Your Extension

Make your popup visually appealing with clean CSS:

```css
/* styles.css */
body {
  width: 320px;
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #f8f9fa;
  margin: 0;
}

.calculator {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

h2 {
  margin: 0 0 20px;
  font-size: 18px;
  color: #1a1a1a;
}

.form-group {
  margin-bottom: 16px;
}

label {
  display: block;
  margin-bottom: 6px;
  font-size: 13px;
  font-weight: 500;
  color: #4a4a4a;
}

input, select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  box-sizing: border-box;
  transition: border-color 0.2s;
}

input:focus, select:focus {
  outline: none;
  border-color: #0066cc;
}

button {
  width: 100%;
  padding: 12px;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

button:hover {
  background: #0052a3;
}

.results {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.results.hidden {
  display: none;
}

.result-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
}

.result-row.total {
  font-weight: 600;
  border-top: 1px solid #eee;
  margin-top: 8px;
  padding-top: 12px;
}
```

## Testing Your Extension

Load your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select your extension's project folder

Test with various scenarios:
- Values below and above de minimis thresholds
- Different product categories
- All supported destination countries
- Invalid inputs and error handling

## Enhancing with Real Tariff Data

For production use, integrate with actual tariff APIs:

```javascript
// Fetch real-time rates from a tariff API
async function fetchTariffRates(country, hsCode) {
  try {
    const response = await fetch(`https://api.example.com/tariffs`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_API_KEY'
      },
      body: JSON.stringify({
        country,
        hsCode,
        year: new Date().getFullYear()
      })
    });
    
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch tariff rates:', error);
    return null;
  }
}
```

Popular tariff data sources include:
- World Bank's WITS (World Integrated Trade Solution)
- Trade Tariff API (UK)
- HTS API (US International Trade Commission)

## Conclusion

Building an import duty calculator Chrome extension requires understanding both the technical implementation and the regulatory complexity of international trade. Start with the basic calculation framework, then progressively add features like HS code lookup, real-time API integration, and e-commerce site extraction.

Focus on accuracy and transparency—clearly display what fees are included, note that estimates are approximations, and always direct users to consult official sources for definitive duty information. Your extension becomes a valuable tool when it helps users make informed decisions about international purchases.

---


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
