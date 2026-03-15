---
layout: default
title: "Building a Chrome Extension Invoice Generator for Freelance Work"
description: "Learn how to create a Chrome extension that generates invoices directly from your browser. A practical guide for developers and freelancers."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-invoice-generator-freelance/
---

{% raw %}
# Building a Chrome Extension Invoice Generator for Freelance Work

Freelancers often juggle multiple tools to manage their business. Between project management, communication, and billing, the administrative overhead can quickly eat into productive hours. A custom Chrome extension that generates invoices directly from your browser can streamline this workflow significantly.

This guide walks you through building a Chrome extension tailored for freelance invoicing. You'll learn the architecture, implementation details, and how to customize it for your specific needs.

## Why Build a Custom Invoice Generator?

Browser-based invoice tools exist, but they often come with subscription fees or require you to export data to their platform. A custom Chrome extension gives you complete control over your data and workflow. Here's what makes this approach valuable:

- **Zero recurring costs** — Your extension runs locally in Chrome
- **Full data ownership** — Invoices generate and store on your machine
- **Custom templates** — Design invoices that match your brand
- **Quick access** — Launch directly from your browser toolbar

## Extension Architecture

A Chrome extension for invoice generation consists of three core components:

1. **Manifest file** — Defines permissions and extension behavior
2. **Popup HTML/JS** — The user interface for entering invoice data
3. **Background script** — Handles data processing and storage

The extension uses Chrome's `storage` API to persist client information and invoice history locally. When you're ready to generate an invoice, the extension compiles the data into a clean HTML template that you can print to PDF.

## Implementation Guide

### Step 1: Create the Manifest

Every Chrome extension requires a `manifest.json` file. Here's a minimal configuration for an invoice generator:

```json
{
  "manifest_version": 3,
  "name": "Freelance Invoice Generator",
  "version": "1.0",
  "description": "Generate professional invoices directly in your browser",
  "permissions": ["storage", "activeTab", "scripting"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  }
}
```

This manifest declares the permissions needed to store client data and interact with the active browser tab.

### Step 2: Build the Popup Interface

The popup serves as your invoice form. Create `popup.html` with fields for client details, line items, and tax calculations:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 400px; font-family: system-ui, sans-serif; padding: 16px; }
    .form-group { margin-bottom: 12px; }
    label { display: block; font-weight: 600; margin-bottom: 4px; }
    input, textarea { width: 100%; padding: 8px; box-sizing: border-box; }
    button { background: #2563eb; color: white; border: none; padding: 10px 16px; cursor: pointer; width: 100%; }
    button:hover { background: #1d4ed8; }
  </style>
</head>
<body>
  <h2>New Invoice</h2>
  <div class="form-group">
    <label>Client Name</label>
    <input type="text" id="clientName" placeholder="Acme Corp">
  </div>
  <div class="form-group">
    <label>Description</label>
    <textarea id="description" rows="3" placeholder="Project work completed"></textarea>
  </div>
  <div class="form-group">
    <label>Amount ($)</label>
    <input type="number" id="amount" placeholder="500.00">
  </div>
  <button id="generateBtn">Generate Invoice</button>
  <script src="popup.js"></script>
</body>
</html>
```

### Step 3: Handle Invoice Generation

The popup JavaScript processes form data and generates the invoice. Add `popup.js`:

```javascript
document.getElementById('generateBtn').addEventListener('click', async () => {
  const clientName = document.getElementById('clientName').value;
  const description = document.getElementById('description').value;
  const amount = parseFloat(document.getElementById('amount').value);
  
  if (!clientName || !amount) {
    alert('Please fill in required fields');
    return;
  }

  const invoiceData = {
    client: clientName,
    description,
    amount,
    date: new Date().toLocaleDateString(),
    invoiceNumber: await generateInvoiceNumber()
  };

  // Save to storage for history
  await saveInvoice(invoiceData);
  
  // Generate and display invoice
  createInvoiceHTML(invoiceData);
});

async function generateInvoiceNumber() {
  const result = await chrome.storage.local.get('invoiceCount');
  const count = (result.invoiceCount || 0) + 1;
  await chrome.storage.local.set({ invoiceCount: count });
  return `INV-${String(count).padStart(4, '0')}`;
}

function createInvoiceHTML(data) {
  const invoiceHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Invoice ${data.invoiceNumber}</title>
      <style>
        body { font-family: system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
        h1 { color: #1e293b; }
        .invoice-header { display: flex; justify-content: space-between; margin-bottom: 40px; }
        .invoice-details { background: #f8fafc; padding: 20px; border-radius: 8px; }
        .amount { font-size: 24px; font-weight: bold; color: #2563eb; }
      </style>
    </head>
    <body>
      <div class="invoice-header">
        <div>
          <h1>INVOICE</h1>
          <p>Invoice #: ${data.invoiceNumber}</p>
          <p>Date: ${data.date}</p>
        </div>
        <div class="invoice-details">
          <strong>Bill To:</strong><br>
          ${data.client}
        </div>
      </div>
      <p><strong>Description:</strong> ${data.description}</p>
      <p class="amount">Total: $${data.amount.toFixed(2)}</p>
      <script>window.print()</script>
    </body>
    </html>
  `;

  const blob = new Blob([invoiceHTML], { type: 'text/html' });
  const url = URL.createObjectURL(blob);
  chrome.tabs.create({ url });
});
```

This script generates a clean invoice page and automatically triggers the print dialog, allowing you to save as PDF.

## Advanced Features to Consider

Once you have the basics working, consider adding these enhancements:

- **Client database** — Store frequently used clients for quick autocomplete
- **Line items** — Support multiple items per invoice with individual pricing
- **Tax calculation** — Add configurable tax rates
- **Export formats** — Generate CSV or JSON exports for accounting software
- **Template customization** — Allow users to define custom CSS templates

## Loading Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension folder
4. Pin the extension to your toolbar for quick access

## Conclusion

A custom Chrome extension invoice generator gives freelancers full control over their billing workflow without recurring software costs. The implementation above provides a foundation you can expand based on your specific requirements.

The extension stores all data locally using Chrome's storage API, ensuring your client information never leaves your machine. Print-to-PDF functionality provides professional-looking invoices that you can send directly to clients.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
