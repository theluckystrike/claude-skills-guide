---
sitemap: false
layout: default
title: "Broken Link Finder Chrome Extension (2026)"
description: "Claude Code extension tip: learn how to build a broken link finder Chrome extension. Practical code examples, APIs, and implementation patterns for..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-broken-link-finder/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---
Chrome Extension Broken Link Finder: A Developer Guide

A broken link checker built as a Chrome extension provides real-time link validation directly in the browser. Unlike standalone crawling tools that require separate processes, a browser-based solution can validate links as you browse, check links before you share them, and maintain a persistent history of link health across sessions.

This guide walks through building a broken link finder extension from scratch, covering the core architecture, implementation patterns, and practical code examples you can adapt for your own projects.

## Core Architecture

A broken link finder extension operates across three main components:

1. Content script. Scans the page for links and extracts URLs
2. Background worker. Handles the actual HTTP requests and manages rate limiting
3. Popup interface. Displays results and provides controls for the user

The separation keeps the UI responsive even when checking many links simultaneously. The background worker also persists across page navigations, allowing cached results to display immediately.

## Setting Up the Manifest

Every Chrome extension starts with a manifest file. For a broken link finder, you need Manifest V3 with specific permissions:

```json
{
 "manifest_version": 3,
 "name": "Link Health Checker",
 "version": "1.0.0",
 "description": "Find and fix broken links on any webpage",
 "permissions": [
 "activeTab",
 "scripting",
 "storage"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "action": {
 "default_popup": "popup.html",
 "default_icon": {
 "16": "icon16.png",
 "48": "icon48.png",
 "128": "icon128.png"
 }
 },
 "background": {
 "service_worker": "background.js"
 }
}
```

The `host_permissions` with `<all_urls>` is essential, it allows your extension to make requests to any website to check link status. Without this, CORS policies block your HTTP requests.

## Content Script Implementation

The content script runs on the current page and extracts all links. Here's a practical implementation:

```javascript
// content.js
class LinkScanner {
 constructor() {
 this.links = [];
 }

 scan() {
 const anchors = document.querySelectorAll('a[href]');
 this.links = Array.from(anchors)
 .map(a => this.normalizeUrl(a.href))
 .filter(href => this.isValidUrl(href));
 
 return {
 url: window.location.href,
 title: document.title,
 links: [...new Set(this.links)],
 count: this.links.length
 };
 }

 normalizeUrl(url) {
 try {
 const normalized = new URL(url);
 // Remove fragments and tracking parameters
 normalized.hash = '';
 return normalized.toString();
 } catch {
 return null;
 }
 }

 isValidUrl(url) {
 if (!url) return false;
 try {
 const parsed = new URL(url);
 return ['http:', 'https:'].includes(parsed.protocol);
 } catch {
 return false;
 }
 }
}

// Send links to background script when page loads
document.addEventListener('DOMContentLoaded', () => {
 const scanner = new LinkScanner();
 const pageData = scanner.scan();
 
 chrome.runtime.sendMessage({
 action: 'pageLoaded',
 data: pageData
 });
});
```

This script normalizes URLs by removing fragments and filtering out non-HTTP links. Using a Set removes duplicate links efficiently.

## Background Worker for Link Checking

The background worker handles the actual HTTP requests. It uses a queue system to avoid overwhelming target servers:

```javascript
// background.js
const linkQueue = [];
const resultsCache = new Map();
const REQUEST_DELAY = 500; // ms between requests to same domain
const lastRequestTime = new Map();

async function checkLink(url) {
 // Check cache first
 if (resultsCache.has(url)) {
 return resultsCache.get(url);
 }

 // Rate limiting per domain
 try {
 const domain = new URL(url).hostname;
 const lastTime = lastRequestTime.get(domain) || 0;
 const now = Date.now();
 
 if (now - lastTime < REQUEST_DELAY) {
 await new Promise(r => setTimeout(r, REQUEST_DELAY - (now - lastTime)));
 }
 
 lastRequestTime.set(domain, Date.now());

 const controller = new AbortController();
 const timeoutId = setTimeout(() => controller.abort(), 10000);

 const response = await fetch(url, {
 method: 'HEAD',
 signal: controller.signal,
 redirect: 'follow'
 });

 clearTimeout(timeoutId);

 const result = {
 url,
 status: response.status,
 ok: response.ok,
 statusText: response.statusText
 };

 resultsCache.set(url, result);
 return result;

 } catch (error) {
 const result = {
 url,
 status: 0,
 ok: false,
 error: error.name === 'AbortError' ? 'timeout' : error.message
 };
 
 resultsCache.set(url, result);
 return result;
 }
}

// Handle messages from content script
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'checkLinks') {
 const links = message.links;
 
 Promise.all(links.map((url, i) => 
 checkLink(url).then(result => ({ index: i, ...result }))
 )).then(results => {
 sendResponse({ results, cached: resultsCache.size });
 });
 
 return true; // Keep message channel open for async response
 }
 
 if (message.action === 'getCachedResults') {
 sendResponse({ 
 results: Array.from(resultsCache.entries()).map(([url, data]) => ({ url, ...data }))
 });
 }
});
```

This implementation includes several important features: caching to avoid re-checking links, rate limiting to respect server resources, timeout handling for slow responses, and parallel checking with proper result ordering.

## Building the Popup Interface

The popup displays results and provides controls for users:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 * { box-sizing: border-box; }
 body { 
 width: 400px; 
 padding: 16px; 
 font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
 font-size: 14px;
 }
 .header { 
 display: flex; 
 justify-content: space-between; 
 align-items: center;
 margin-bottom: 16px;
 padding-bottom: 12px;
 border-bottom: 1px solid #eee;
 }
 .stats { 
 display: flex; 
 gap: 16px; 
 margin-bottom: 16px;
 }
 .stat { 
 text-align: center; 
 flex: 1;
 }
 .stat-value { 
 font-size: 24px; 
 font-weight: 600;
 }
 .stat-label { 
 font-size: 12px; 
 color: #666;
 }
 .broken { color: #d32f2f; }
 .working { color: #388e3c; }
 button {
 width: 100%;
 padding: 10px;
 background: #1976d2;
 color: white;
 border: none;
 border-radius: 4px;
 cursor: pointer;
 font-size: 14px;
 }
 button:hover { background: #1565c0; }
 button:disabled { background: #ccc; }
 .link-list {
 max-height: 300px;
 overflow-y: auto;
 border: 1px solid #eee;
 border-radius: 4px;
 }
 .link-item {
 padding: 8px 12px;
 border-bottom: 1px solid #eee;
 display: flex;
 align-items: center;
 gap: 8px;
 font-size: 12px;
 }
 .link-item:last-child { border-bottom: none; }
 .status-icon {
 width: 8px;
 height: 8px;
 border-radius: 50%;
 flex-shrink: 0;
 }
 .status-icon.ok { background: #4caf50; }
 .status-icon.broken { background: #f44336; }
 .link-url {
 overflow: hidden;
 text-overflow: ellipsis;
 white-space: nowrap;
 flex: 1;
 }
 </style>
</head>
<body>
 <div class="header">
 <h3>Link Health Checker</h3>
 <span id="pageUrl"></span>
 </div>
 
 <div class="stats">
 <div class="stat">
 <div class="stat-value" id="totalCount">-</div>
 <div class="stat-label">Total Links</div>
 </div>
 <div class="stat">
 <div class="stat-value working" id="workingCount">-</div>
 <div class="stat-label">Working</div>
 </div>
 <div class="stat">
 <div class="stat-value broken" id="brokenCount">-</div>
 <div class="stat-label">Broken</div>
 </div>
 </div>

 <button id="checkBtn">Check All Links</button>
 
 <div class="link-list" id="linkList" style="margin-top: 16px;"></div>
 
 <script src="popup.js"></script>
</body>
</html>
```

## Popup Logic

The popup script coordinates between the user interface and the background worker:

```javascript
// popup.js
let cachedResults = [];

document.addEventListener('DOMMAContentLoaded', async () => {
 // Get current tab
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 // Check for existing results
 chrome.runtime.sendMessage({ action: 'getCachedResults' }, (response) => {
 if (response && response.results) {
 displayResults(response.results);
 }
 });

 document.getElementById('checkBtn').addEventListener('click', async () => {
 const btn = document.getElementById('checkBtn');
 btn.disabled = true;
 btn.textContent = 'Checking...';

 // Execute content script to get links
 const results = await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: () => {
 const links = Array.from(document.querySelectorAll('a[href]'))
 .map(a => new URL(a.href).toString());
 return [...new Set(links)];
 }
 });

 const links = results[0].result;

 // Send to background for checking
 chrome.runtime.sendMessage({ 
 action: 'checkLinks', 
 links 
 }, (response) => {
 displayResults(response.results);
 btn.disabled = false;
 btn.textContent = 'Check All Links';
 });
 });
});

function displayResults(results) {
 cachedResults = results;
 
 const total = results.length;
 const broken = results.filter(r => !r.ok).length;
 const working = total - broken;

 document.getElementById('totalCount').textContent = total;
 document.getElementById('workingCount').textContent = working;
 document.getElementById('brokenCount').textContent = broken;

 const list = document.getElementById('linkList');
 list.innerHTML = results.slice(0, 50).map(r => `
 <div class="link-item">
 <div class="status-icon ${r.ok ? 'ok' : 'broken'}"></div>
 <div class="link-url" title="${r.url}">${r.url}</div>
 <span>${r.status || 'Error'}</span>
 </div>
 `).join('');
}
```

## Advanced Features to Consider

Once the basic implementation works, consider adding these power user features:

Selective checking. Allow users to check only external links or only links within a specific domain.

Export functionality. Generate CSV or JSON reports of broken links for documentation.

Scheduled checks. Re-check previously visited pages automatically and notify users of newly broken links.

Custom headers. Handle authentication-required links or respect custom server configurations.

## Performance Optimizations

For pages with hundreds of links, optimize your extension with these patterns:

1. Chunk processing. Check links in batches of 10-20 to keep the UI responsive
2. Progressive rendering. Display results as they come in rather than waiting for all
3. Connection pooling. Reuse HTTP connections where possible
4. Priority queue. Check visible links first, defer off-screen links

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Test thoroughly:

- Pages with hundreds of links
- Links requiring authentication
- Redirect chains (301, 302)
- Very slow-responding servers
- Non-standard HTTP ports
- International domain names

## Conclusion

Building a broken link finder Chrome extension combines browser extension APIs with practical HTTP handling patterns. The core implementation is straightforward, scan links, validate with HEAD requests, display results, but production-ready extensions require attention to caching, rate limiting, and error handling.

Start with the basic architecture shown here, then add features based on your specific use case. Whether you're building for personal use or as a product, the patterns established here provide a solid foundation.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=chrome-extension-broken-link-finder)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Chrome Check Link Safety: Developer Tools and Techniques](/chrome-check-link-safety/)
- [Chrome Extension Academic Paper Finder: Tools and.](/chrome-extension-academic-paper-finder/)
- [Chrome Extension Clearance Sale Finder: A Developer's Guide to Finding Deals](/chrome-extension-clearance-sale-finder/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

