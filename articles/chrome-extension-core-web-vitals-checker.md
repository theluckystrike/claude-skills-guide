---
layout: default
title: "Chrome Extension Core Web Vitals (2026)"
description: "Claude Code extension tip: build a Chrome extension to measure Core Web Vitals directly in your browser. Practical code examples, APIs, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-core-web-vitals-checker/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---


Chrome Extension Core Web Vitals Checker: Developer Guide

Core Web Vitals have become the standard for measuring web performance and user experience. Building a Chrome extension that checks these metrics gives you real-time insights without leaving your browser. This guide walks you through creating a functional Core Web Vitals checker extension from scratch.

## What Are Core Web Vitals

Core Web Vitals consist of three metrics that Google uses to evaluate page experience:

- Largest Contentful Paint (LCP) measures loading performance. A good LCP is under 2.5 seconds.
- First Input Delay (FID) measures interactivity. A good FID is under 100 milliseconds.
- Cumulative Layout Shift (CLS) measures visual stability. A good CLS is under 0.1.

Building an extension to track these metrics requires understanding the Chrome APIs available for performance measurement and how to extract meaningful data from them.

## Extension Architecture

Your Core Web Vitals checker will need three main components:

1. Content script - Injected into pages to collect performance data
2. Background worker - Handles message passing and data aggregation
3. Popup UI - Displays metrics to users in a clean interface

The content script uses the Performance API to gather metrics, then communicates with the popup through Chrome's message passing system.

## Setting Up the Manifest

Every Chrome extension starts with the manifest file. For a Core Web Vitals checker, you need Manifest V3 with specific permissions:

```json
{
 "manifest_version": 3,
 "name": "Core Web Vitals Checker",
 "version": "1.0.0",
 "description": "Measure Core Web Vitals on any page",
 "permissions": [
 "activeTab",
 "scripting"
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
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content.js"],
 "run_at": "document_idle"
 }]
}
```

The `activeTab` permission lets your extension interact with the currently active tab, while `scripting` allows you to execute content scripts. The host permissions `<all_urls>` grants access to measure performance on any website.

## Collecting Performance Metrics

The content script is where the actual measurement happens. You'll use the Performance API to extract Core Web Vitals data:

```javascript
// content.js
function getCoreWebVitals() {
 return new Promise((resolve) => {
 if (!window.PerformanceObserver) {
 resolve(null);
 return;
 }

 const metrics = {};
 let observer;

 // Measure LCP
 try {
 observer = new PerformanceObserver((list) => {
 const entries = list.getEntries();
 const lastEntry = entries[entries.length - 1];
 metrics.lcp = Math.round(lastEntry.renderTime || lastEntry.loadTime);
 });
 observer.observe({ type: 'largest-contentful-paint', buffered: true });
 } catch (e) {
 console.log('LCP not supported');
 }

 // Measure CLS
 try {
 const clsObserver = new PerformanceObserver((list) => {
 for (const entry of list.getEntries()) {
 if (!(entry as any).hadRecentInput) {
 metrics.cls = (metrics.cls || 0) + (entry as any).value;
 }
 }
 });
 clsObserver.observe({ type: 'layout-shift', buffered: true });
 } catch (e) {
 console.log('CLS not supported');
 }

 // Get FID from event timing
 const paintEntries = performance.getEntriesByType('paint');
 const fcpEntry = paintEntries.find(e => e.name === 'first-contentful-paint');
 if (fcpEntry) {
 metrics.fcp = Math.round(fcpEntry.startTime);
 }

 // Return metrics after a delay to ensure collection
 setTimeout(() => {
 resolve(metrics);
 }, 2000);
 });
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'getMetrics') {
 getCoreWebVitals().then(sendResponse);
 return true;
 }
});
```

This script uses PerformanceObserver to watch for Largest Contentful Paint and layout shift events. The CLS calculation filters out entries with recent user input, as those shouldn't count toward cumulative shift. The script returns metrics after a 2-second delay to ensure enough time for all paint events to fire.

## Building the Popup Interface

The popup provides the user-facing interface. It requests metrics from the content script and displays them with visual indicators:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 300px; padding: 16px; font-family: system-ui, sans-serif; }
 .metric { margin-bottom: 12px; padding: 12px; border-radius: 8px; background: #f5f5f5; }
 .metric.good { border-left: 4px solid #34d399; }
 .metric.needs-improvement { border-left: 4px solid #fbbf24; }
 .metric.poor { border-left: 4px solid #f87171; }
 .metric-label { font-size: 12px; color: #666; }
 .metric-value { font-size: 24px; font-weight: bold; margin-top: 4px; }
 h2 { margin: 0 0 16px 0; font-size: 18px; }
 .refresh { width: 100%; padding: 8px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer; }
 .refresh:hover { background: #2563eb; }
 </style>
</head>
<body>
 <h2>Core Web Vitals</h2>
 <div id="metrics"></div>
 <button class="refresh" id="refreshBtn">Refresh Metrics</button>
 <script src="popup.js"></script>
</body>
</html>
```

## Handling Metric Display Logic

The popup JavaScript bridges the gap between the content script and the UI:

```javascript
// popup.js
function getRating(value, type) {
 if (type === 'lcp') {
 return value < 2500 ? 'good' : value < 4000 ? 'needs-improvement' : 'poor';
 } else if (type === 'fid') {
 return value < 100 ? 'good' : value < 300 ? 'needs-improvement' : 'poor';
 } else if (type === 'cls') {
 return value < 0.1 ? 'good' : value < 0.25 ? 'needs-improvement' : 'poor';
 }
 return 'needs-improvement';
}

function displayMetrics(metrics) {
 const container = document.getElementById('metrics');
 container.innerHTML = '';

 const metricDefinitions = [
 { key: 'lcp', label: 'Largest Contentful Paint', unit: 'ms' },
 { key: 'cls', label: 'Cumulative Layout Shift', unit: '' },
 { key: 'fcp', label: 'First Contentful Paint', unit: 'ms' }
 ];

 metricDefinitions.forEach(def => {
 const value = metrics[def.key];
 if (value === undefined) return;

 const rating = getRating(value, def.key);
 const displayValue = def.unit ? `${value}${def.unit}` : value.toFixed(3);

 const div = document.createElement('div');
 div.className = `metric ${rating}`;
 div.innerHTML = `
 <div class="metric-label">${def.label}</div>
 <div class="metric-value">${displayValue}</div>
 `;
 container.appendChild(div);
 });
}

async function fetchMetrics() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 if (!tab || !tab.id) return;

 try {
 const response = await chrome.tabs.sendMessage(tab.id, { action: 'getMetrics' });
 if (response) {
 displayMetrics(response);
 }
 } catch (error) {
 document.getElementById('metrics').innerHTML = 
 '<p>Unable to fetch metrics. Try refreshing the page.</p>';
 }
}

document.getElementById('refreshBtn').addEventListener('click', fetchMetrics);
fetchMetrics();
```

The rating function applies Google's official thresholds for each metric, coloring the results green for good, yellow for needs improvement, and red for poor performance. The fetchMetrics function queries the active tab and requests performance data from the content script.

## Testing Your Extension

To test the extension locally:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" and select your extension folder
4. Visit any website and click the extension icon to see metrics

For debugging, check the popup console and the background service worker console in the extensions page. PerformanceObserver can be finicky, so test across multiple sites to ensure reliable data collection.

## Limitations and Considerations

Limitations and Considerations captures metrics at the time of measurement, which differs from field data that Chrome's CrUX reports. Your extension provides lab data, a snapshot of performance under specific conditions. For comprehensive analysis, combine your extension with PageSpeed Insights or Chrome DevTools.

Some Single Page Applications may not trigger fresh LCP events on navigation, requiring users to manually refresh after content changes. The extension works best on traditional multi-page sites where full page loads occur.

Building this extension gives you a practical tool for quick performance audits while learning the Chrome extension APIs and Performance API in depth.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-core-web-vitals-checker)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Web Vitals Optimization: A Practical Guide for.](/chrome-web-vitals-optimization/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)
- [AI Grammar Checker Chrome Extension: A Developer's Guide](/ai-grammar-checker-chrome-extension/)
- [SEO Checker Chrome Extension Guide (2026)](/chrome-extension-seo-checker/)
- [Diff Checker Chrome Extension Guide (2026)](/chrome-extension-diff-checker/)
- [Plagiarism Checker Free Chrome Extension Guide (2026)](/chrome-extension-plagiarism-checker-free/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



