---
layout: default
title: "Invoice Generator Freelance Chrome (2026)"
description: "Learn how to create a Chrome extension that generates invoices directly from your browser. A practical guide for developers and freelancers."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-invoice-generator-freelance/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---
Building a Chrome Extension Invoice Generator for Freelance Work

Freelancers often juggle multiple tools to manage their business. Between project management, communication, and billing, the administrative overhead can quickly eat into productive hours. A custom Chrome extension that generates invoices directly from your browser can streamline this workflow significantly.

This guide walks you through building a Chrome extension tailored for freelance invoicing. You'll learn the architecture, implementation details, and how to customize it for your specific needs. By the end, you'll have a working extension that stores client data locally, supports multiple line items, calculates tax, and outputs print-ready PDF invoices.

Why Build a Custom Invoice Generator?

Browser-based invoice tools exist, but they often come with subscription fees or require you to export data to their platform. A custom Chrome extension gives you complete control over your data and workflow. Here's what makes this approach valuable:

- Zero recurring costs. Your extension runs locally in Chrome
- Full data ownership. Invoices generate and store on your machine
- Custom templates. Design invoices that match your brand
- Quick access. Launch directly from your browser toolbar
- No account required. No login, no email confirmation, no SaaS dependency

The alternative is paying $15–$40/month for tools like FreshBooks or QuickBooks just to send occasional invoices. For solo freelancers with a handful of recurring clients, that cost rarely makes sense.

| Tool | Monthly Cost | Data Ownership | Customization |
|---|---|---|---|
| FreshBooks | $19+ | Vendor-hosted | Limited templates |
| Wave | Free (ads) | Vendor-hosted | Limited |
| Custom Extension | $0 | Local machine | Full control |
| Google Docs template | $0 | Google Drive | Manual process |

A custom extension sits in a unique position: free, local, and fast, with the automation of a paid tool.

## Extension Architecture

A Chrome extension for invoice generation consists of three core components:

1. Manifest file. Defines permissions and extension behavior
2. Popup HTML/JS. The user interface for entering invoice data
3. Background script. Handles data processing and storage

The extension uses Chrome's `storage` API to persist client information and invoice history locally. When you're ready to generate an invoice, the extension compiles the data into a clean HTML template that you can print to PDF.

Here's how the data flows:

```
User fills popup form
 ↓
popup.js validates and assembles invoiceData object
 ↓
chrome.storage.local saves invoice to history
 ↓
createInvoiceHTML() generates full HTML string
 ↓
Blob URL opens in a new tab
 ↓
window.print() triggers browser print dialog
 ↓
User saves as PDF
```

Understanding this flow helps when you need to debug or add features later. Each step is independent and testable.

## Implementation Guide

## Step 1: Create the Manifest

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

This manifest declares the permissions needed to store client data and interact with the active browser tab. The `storage` permission is required for persisting invoice history and the sequential invoice counter. Without it, every extension session starts fresh.

For a production extension, you'd also add `"icons"` with multiple sizes (16, 48, 128px) to ensure the toolbar icon looks sharp at every display density.

## Step 2: Build the Popup Interface

The popup serves as your invoice form. Create `popup.html` with fields for client details, line items, and tax calculations:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 400px; font-family: system-ui, sans-serif; padding: 16px; }
 .form-group { margin-bottom: 12px; }
 label { display: block; font-weight: 600; margin-bottom: 4px; }
 input, textarea, select { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #d1d5db; border-radius: 4px; }
 button { background: #2563eb; color: white; border: none; padding: 10px 16px; cursor: pointer; width: 100%; border-radius: 4px; margin-top: 8px; }
 button:hover { background: #1d4ed8; }
 .line-items { border: 1px solid #e5e7eb; border-radius: 6px; padding: 12px; margin-bottom: 12px; }
 .line-item { display: grid; grid-template-columns: 1fr 80px 80px 24px; gap: 6px; margin-bottom: 6px; align-items: center; }
 .remove-btn { background: #ef4444; width: 24px; height: 24px; border: none; border-radius: 4px; cursor: pointer; color: white; font-size: 14px; padding: 0; }
 .subtotal { text-align: right; font-weight: 600; margin-top: 8px; font-size: 14px; color: #374151; }
 </style>
</head>
<body>
 <h2 style="margin-top:0">New Invoice</h2>
 <div class="form-group">
 <label>Client Name</label>
 <input type="text" id="clientName" placeholder="Acme Corp" list="savedClients">
 <datalist id="savedClients"></datalist>
 </div>
 <div class="form-group">
 <label>Client Email</label>
 <input type="email" id="clientEmail" placeholder="billing@acmecorp.com">
 </div>
 <div class="form-group">
 <label>Due Date</label>
 <input type="date" id="dueDate">
 </div>
 <div class="form-group">
 <label>Line Items</label>
 <div class="line-items" id="lineItems">
 <div style="display:grid;grid-template-columns:1fr 80px 80px 24px;gap:6px;margin-bottom:4px;font-size:12px;color:#6b7280">
 <span>Description</span><span>Qty</span><span>Rate</span><span></span>
 </div>
 </div>
 <button id="addItemBtn" type="button" style="background:#10b981;margin-top:0">+ Add Line Item</button>
 </div>
 <div class="form-group">
 <label>Tax Rate (%)</label>
 <input type="number" id="taxRate" placeholder="0" value="0" min="0" max="100" step="0.1">
 </div>
 <div id="totalSummary" style="text-align:right;margin-bottom:12px;font-size:14px;color:#374151"></div>
 <button id="generateBtn">Generate Invoice</button>
 <button id="historyBtn" style="background:#6b7280;margin-top:6px">View Invoice History</button>
 <script src="popup.js"></script>
</body>
</html>
```

The `datalist` element on the client name field will be populated from saved clients, giving you autocomplete as you type. The line items section uses CSS grid for a compact, readable layout.

## Step 3: Handle Invoice Generation

The popup JavaScript processes form data, manages line items, and generates the invoice. Create `popup.js`:

```javascript
let lineItems = [];

// Populate saved clients in datalist
async function loadSavedClients() {
 const result = await chrome.storage.local.get('clients');
 const clients = result.clients || [];
 const datalist = document.getElementById('savedClients');
 clients.forEach(name => {
 const option = document.createElement('option');
 option.value = name;
 datalist.appendChild(option);
 });
}

// Set default due date to 30 days from today
document.getElementById('dueDate').valueAsDate = new Date(
 Date.now() + 30 * 24 * 60 * 60 * 1000
);

function renderLineItems() {
 const container = document.getElementById('lineItems');
 // Clear existing rows (keep header)
 while (container.children.length > 1) {
 container.removeChild(container.lastChild);
 }

 lineItems.forEach((item, index) => {
 const row = document.createElement('div');
 row.className = 'line-item';
 row.innerHTML = `
 <input type="text" placeholder="Description" value="${item.desc}"
 oninput="lineItems[${index}].desc = this.value; updateTotal()">
 <input type="number" placeholder="1" value="${item.qty}" min="0" step="0.5"
 oninput="lineItems[${index}].qty = parseFloat(this.value)||0; updateTotal()">
 <input type="number" placeholder="0.00" value="${item.rate}" min="0" step="0.01"
 oninput="lineItems[${index}].rate = parseFloat(this.value)||0; updateTotal()">
 <button class="remove-btn" onclick="removeItem(${index})">×</button>
 `;
 container.appendChild(row);
 });
 updateTotal();
}

function removeItem(index) {
 lineItems.splice(index, 1);
 renderLineItems();
}

window.removeItem = removeItem;

function updateTotal() {
 const subtotal = lineItems.reduce((sum, item) => sum + (item.qty * item.rate), 0);
 const taxRate = parseFloat(document.getElementById('taxRate').value) || 0;
 const tax = subtotal * (taxRate / 100);
 const total = subtotal + tax;

 const summary = document.getElementById('totalSummary');
 summary.innerHTML = `
 Subtotal: $${subtotal.toFixed(2)}<br>
 Tax (${taxRate}%): $${tax.toFixed(2)}<br>
 <strong>Total: $${total.toFixed(2)}</strong>
 `;
}

document.getElementById('addItemBtn').addEventListener('click', () => {
 lineItems.push({ desc: '', qty: 1, rate: 0 });
 renderLineItems();
});

document.getElementById('taxRate').addEventListener('input', updateTotal);

document.getElementById('generateBtn').addEventListener('click', async () => {
 const clientName = document.getElementById('clientName').value.trim();
 const clientEmail = document.getElementById('clientEmail').value.trim();
 const dueDate = document.getElementById('dueDate').value;
 const taxRate = parseFloat(document.getElementById('taxRate').value) || 0;

 if (!clientName) {
 alert('Client name is required');
 return;
 }
 if (lineItems.length === 0 || lineItems.every(i => !i.desc)) {
 alert('Add at least one line item');
 return;
 }

 const invoiceNumber = await generateInvoiceNumber();
 const subtotal = lineItems.reduce((sum, item) => sum + (item.qty * item.rate), 0);
 const tax = subtotal * (taxRate / 100);

 const invoiceData = {
 client: clientName,
 email: clientEmail,
 lineItems: [...lineItems],
 subtotal,
 tax,
 total: subtotal + tax,
 taxRate,
 dueDate,
 date: new Date().toLocaleDateString(),
 invoiceNumber,
 createdAt: Date.now()
 };

 await saveInvoice(invoiceData);
 await saveClient(clientName);
 createInvoiceHTML(invoiceData);
});

async function generateInvoiceNumber() {
 const result = await chrome.storage.local.get('invoiceCount');
 const count = (result.invoiceCount || 0) + 1;
 await chrome.storage.local.set({ invoiceCount: count });
 return `INV-${String(count).padStart(4, '0')}`;
}

async function saveInvoice(data) {
 const result = await chrome.storage.local.get('invoices');
 const invoices = result.invoices || [];
 invoices.push(data);
 // Keep last 200 invoices to avoid unbounded storage growth
 if (invoices.length > 200) invoices.shift();
 await chrome.storage.local.set({ invoices });
}

async function saveClient(name) {
 const result = await chrome.storage.local.get('clients');
 const clients = result.clients || [];
 if (!clients.includes(name)) {
 clients.push(name);
 await chrome.storage.local.set({ clients });
 }
}

function createInvoiceHTML(data) {
 const itemRows = data.lineItems
 .filter(item => item.desc)
 .map(item => `
 <tr>
 <td>${item.desc}</td>
 <td style="text-align:center">${item.qty}</td>
 <td style="text-align:right">$${item.rate.toFixed(2)}</td>
 <td style="text-align:right">$${(item.qty * item.rate).toFixed(2)}</td>
 </tr>
 `).join('');

 const invoiceHTML = `
 <!DOCTYPE html>
 <html>
 <head>
 <title>Invoice ${data.invoiceNumber}</title>
 <style>
 body { font-family: system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; color: #1e293b; }
 h1 { color: #1e293b; letter-spacing: 2px; margin: 0; }
 .invoice-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 40px; padding-bottom: 20px; border-bottom: 2px solid #e5e7eb; }
 .meta { font-size: 14px; color: #6b7280; line-height: 1.8; }
 .bill-to { background: #f8fafc; padding: 16px 20px; border-radius: 8px; }
 table { width: 100%; border-collapse: collapse; margin: 24px 0; }
 th { background: #f1f5f9; text-align: left; padding: 10px 12px; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; }
 td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; }
 .totals { margin-left: auto; width: 280px; }
 .totals td { border: none; padding: 6px 12px; }
 .totals .total-row td { font-size: 18px; font-weight: bold; color: #2563eb; border-top: 2px solid #e5e7eb; padding-top: 10px; }
 .footer { margin-top: 60px; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #9ca3af; }
 @media print { button { display: none; } }
 </style>
 </head>
 <body>
 <div class="invoice-header">
 <div>
 <h1>INVOICE</h1>
 <div class="meta">
 <div><strong>Invoice #:</strong> ${data.invoiceNumber}</div>
 <div><strong>Issue Date:</strong> ${data.date}</div>
 <div><strong>Due Date:</strong> ${data.dueDate || 'Upon receipt'}</div>
 </div>
 </div>
 <div class="bill-to">
 <div style="font-size:12px;text-transform:uppercase;letter-spacing:1px;color:#9ca3af;margin-bottom:6px">Bill To</div>
 <strong>${data.client}</strong>
 ${data.email ? `<div style="font-size:14px;color:#6b7280">${data.email}</div>` : ''}
 </div>
 </div>

 <table>
 <thead>
 <tr>
 <th>Description</th>
 <th style="text-align:center">Qty</th>
 <th style="text-align:right">Rate</th>
 <th style="text-align:right">Amount</th>
 </tr>
 </thead>
 <tbody>${itemRows}</tbody>
 </table>

 <table class="totals">
 <tr><td>Subtotal</td><td style="text-align:right">$${data.subtotal.toFixed(2)}</td></tr>
 <tr><td>Tax (${data.taxRate}%)</td><td style="text-align:right">$${data.tax.toFixed(2)}</td></tr>
 <tr class="total-row"><td>Total</td><td style="text-align:right">$${data.total.toFixed(2)}</td></tr>
 </table>

 <div class="footer">Thank you for your business.</div>
 <script>window.print()</script>
 </body>
 </html>
 `;

 const blob = new Blob([invoiceHTML], { type: 'text/html' });
 const url = URL.createObjectURL(blob);
 chrome.tabs.create({ url });
}

// Initialize
loadSavedClients();
// Add one empty line item to start
lineItems.push({ desc: '', qty: 1, rate: 0 });
renderLineItems();
```

This implementation handles the full lifecycle: client autocomplete from history, dynamic line item management, live tax calculation, and a professional invoice layout that prints cleanly.

## Step 4: Invoice History View

Add a simple history view so you can retrieve past invoice numbers or check what you've sent. Create `history.html`:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { font-family: system-ui, sans-serif; padding: 20px; min-width: 600px; }
 table { width: 100%; border-collapse: collapse; }
 th { background: #f1f5f9; padding: 10px; text-align: left; font-size: 13px; }
 td { padding: 10px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
 tr:hover td { background: #f8fafc; }
 </style>
</head>
<body>
 <h2>Invoice History</h2>
 <table id="historyTable">
 <thead>
 <tr><th>#</th><th>Client</th><th>Date</th><th>Total</th></tr>
 </thead>
 <tbody id="historyBody"></tbody>
 </table>
 <script>
 chrome.storage.local.get('invoices', ({ invoices = [] }) => {
 const tbody = document.getElementById('historyBody');
 [...invoices].reverse().forEach(inv => {
 const tr = document.createElement('tr');
 tr.innerHTML = `
 <td>${inv.invoiceNumber}</td>
 <td>${inv.client}</td>
 <td>${inv.date}</td>
 <td>$${inv.total.toFixed(2)}</td>
 `;
 tbody.appendChild(tr);
 });
 });
 </script>
</body>
</html>
```

Wire the history button in `popup.js` to open this page:

```javascript
document.getElementById('historyBtn').addEventListener('click', () => {
 chrome.tabs.create({ url: chrome.runtime.getURL('history.html') });
});
```

Add `history.html` to the manifest's `web_accessible_resources`:

```json
"web_accessible_resources": [{
 "resources": ["history.html"],
 "matches": ["<all_urls>"]
}]
```

## Storage Design Considerations

Chrome's `storage.local` can hold up to 10MB by default. Each invoice object is typically 500–2KB depending on how many line items you include. At that rate, you can store thousands of invoices before approaching the limit.

If you need more headroom, call `chrome.storage.local.getBytesInUse()` to monitor usage and prune older records automatically. The `saveInvoice` function in the example above already caps history at 200 entries as a safety measure.

For sensitive billing data, consider encrypting client names and amounts with the Web Crypto API before writing to storage. This isn't strictly necessary for a local-only tool, but it's worth adding if you share the machine.

## Loading Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension folder
4. Pin the extension to your toolbar for quick access

After making code changes during development, click the refresh icon on the extension card at `chrome://extensions/` and close/reopen the popup. Chrome caches popup HTML aggressively, so a simple page reload won't pick up changes.

## Advanced Features to Consider

Once you have the basics working, consider adding these enhancements:

- Recurring invoice templates. Save common project types with pre-filled line items and rates, then clone them for new invoices
- Export to CSV/JSON. Pull your full invoice history into a format your accountant's spreadsheet can read
- Currency selector. Add a dropdown for USD, EUR, GBP, etc., and format amounts accordingly
- Your business details. Add a settings page where you enter your name, address, and bank details once, then have them appear on every invoice automatically
- Payment status. Tag invoices as paid/unpaid and filter history by status
- Due date reminders. Use Chrome's notifications API to alert you when an invoice passes its due date

## Conclusion

A custom Chrome extension invoice generator gives freelancers full control over their billing workflow without recurring software costs. The implementation above provides a production-ready foundation with multi-line items, tax support, client autocomplete, and invoice history, all stored locally on your machine.

The print-to-PDF approach produces professional-looking invoices with zero dependencies. No third-party server sees your client names or billing amounts. No subscription expires. The extension stays in your browser toolbar, ready to invoice in under a minute whenever a project wraps up.

From here, the natural next step is adding your own business details to the invoice template and tweaking the CSS to match your brand colors. The HTML template is entirely self-contained, making visual customization straightforward.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-invoice-generator-freelance)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Blog Post Generator for Chrome: A Developer's Guide](/ai-blog-post-generator-chrome/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Lead Generator Chrome Extension: A Developer Guide](/ai-lead-generator-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



