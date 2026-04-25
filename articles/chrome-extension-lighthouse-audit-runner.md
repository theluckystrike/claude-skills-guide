---
layout: default
title: "Lighthouse Audit Runner Chrome (2026)"
description: "Claude Code extension tip: learn how to build a Chrome extension that runs Lighthouse audits programmatically. Practical code examples, automation..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-lighthouse-audit-runner/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, lighthouse, performance, auditing, devtools]
geo_optimized: true
---
Chrome Extension Lighthouse Audit Runner: A Developer Guide

Running Lighthouse audits directly from your Chrome extension unlocks powerful possibilities for automated performance monitoring, continuous quality checks, and real-time developer feedback. This guide shows you how to build an extension that executes Lighthouse audits programmatically and integrates the results into your development workflow.

## Why Build a Lighthouse Audit Runner Extension

Google Lighthouse provides comprehensive audits for performance, accessibility, progressive web app compliance, SEO, and best practices. While you can run Lighthouse from Chrome DevTools or the command line, embedding audit capabilities directly into a Chrome extension offers several advantages:

- On-demand auditing from any page without switching contexts
- Automated workflows that trigger audits based on user actions or page events
- Custom reporting that formats results for your specific needs
- Integration with other extension features like bookmark management or project dashboards

For teams building web applications, a custom Lighthouse runner extension becomes a practical tool for catching performance regressions before they reach production.

## Core Architecture

A Lighthouse audit runner extension operates through three main components:

1. Popup interface for triggering audits and viewing quick results
2. Background service worker for managing audit state and long-running tasks
3. Content script integration for injecting audit configuration into pages

The extension communicates with Lighthouse through Chrome's `chrome.debugger` API or by injecting the Lighthouse library directly into page context. The former provides more accurate results by using Chrome's debugging protocol, while the latter offers simpler implementation but may have slight measurement differences.

## Setting Up the Manifest

Every Chrome extension starts with the manifest file. For a Lighthouse audit runner, you need manifest version 3 with specific permissions:

```json
{
 "manifest_version": 3,
 "name": "Lighthouse Audit Runner",
 "version": "1.0.0",
 "description": "Run Lighthouse audits from any page",
 "permissions": [
 "activeTab",
 "scripting",
 "storage",
 "debugger"
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

The `debugger` permission is essential for accurate Lighthouse measurements. Note that when using the debugger API, Chrome displays a banner indicating that a debugger is attached, this is expected behavior.

## Implementing the Background Service Worker

The background service worker orchestrates the audit process. It receives messages from the popup, launches the audit, and returns results:

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'runAudit') {
 runLighthouseAudit(message.url, message.categories)
 .then(results => sendResponse({ success: true, results }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 return true; // Keep message channel open for async response
 }
});

async function runLighthouseAudit(url, categories) {
 const targetTab = await findOrCreateAuditTab(url);
 
 return new Promise((resolve, reject) => {
 chrome.debugger.attach({ tabId: targetTab.id }, '1.0', async () => {
 if (chrome.runtime.lastError) {
 reject(new Error(chrome.runtime.lastError.message));
 return;
 }
 
 // Configure and run Lighthouse via debugger protocol
 const config = {
 categories: categories || ['performance', 'accessibility', 'best-practices', 'seo'],
 throttling: { cpuSlowdownMultiplier: 4, rttMs: 40, throughputKbps: 1024 }
 };
 
 // Send Lighthouse command through debugger
 chrome.debugger.sendCommand(
 { tabId: targetTab.id },
 'Lighthouse.start',
 config,
 (result) => {
 if (chrome.runtime.lastError) {
 reject(new Error(chrome.runtime.lastError.message));
 chrome.debugger.detach({ tabId: targetTab.id });
 return;
 }
 
 // Poll for completion
 pollForResults(targetTab.id, resolve, reject);
 }
 );
 });
 });
}

async function pollForResults(tabId, resolve, reject) {
 const maxAttempts = 120;
 let attempts = 0;
 
 const poll = async () => {
 attempts++;
 
 try {
 const response = await new Promise((resolve, reject) => {
 chrome.debugger.sendCommand(
 { tabId },
 'Lighthouse.getVersion',
 {},
 (result) => {
 if (chrome.runtime.lastError) {
 reject(chrome.runtime.lastError);
 return;
 }
 // Lighthouse running - check for completion
 chrome.debugger.sendCommand(
 { tabId },
 'Lighthouse.end',
 {},
 (endResult) => {
 if (!chrome.runtime.lastError && endResult.lhr) {
 resolve(endResult.lhr);
 } else {
 resolve(null);
 }
 }
 );
 }
 );
 });
 
 if (response) {
 chrome.debugger.detach({ tabId });
 resolve(response);
 } else if (attempts < maxAttempts) {
 setTimeout(poll, 1000);
 } else {
 chrome.debugger.detach({ tabId });
 reject(new Error('Audit timeout'));
 }
 } catch (error) {
 setTimeout(poll, 1000);
 }
 };
 
 poll();
}
```

This implementation uses the Chrome Debugger API to interface directly with Lighthouse. The polling mechanism waits for the audit to complete, with a timeout safeguard.

## Building the Popup Interface

The popup provides the user interface for triggering audits and viewing results:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 400px; padding: 16px; font-family: system-ui, sans-serif; }
 .url-input { width: 100%; padding: 8px; margin-bottom: 12px; box-sizing: border-box; }
 .category-checkboxes { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px; }
 .category-label { display: flex; align-items: center; gap: 4px; font-size: 13px; }
 .run-button { width: 100%; padding: 10px; background: #4285f4; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: 500; }
 .run-button:disabled { background: #ccc; cursor: not-allowed; }
 .results { margin-top: 16px; }
 .score { display: inline-block; padding: 4px 8px; border-radius: 4px; font-weight: bold; }
 .score.good { background: #e6f4ea; color: #137333; }
 .score.needs-improvement { background: #fef7e0; color: #b06000; }
 .score.poor { background: #fce8e6; color: #c5221f; }
 </style>
</head>
<body>
 <input type="text" id="url" class="url-input" placeholder="Enter URL to audit" />
 
 <div class="category-checkboxes">
 <label class="category-label"><input type="checkbox" value="performance" checked> Performance</label>
 <label class="category-label"><input type="checkbox" value="accessibility" checked> Accessibility</label>
 <label class="category-label"><input type="checkbox" value="best-practices" checked> Best Practices</label>
 <label class="category-label"><input type="checkbox" value="seo" checked> SEO</label>
 </div>
 
 <button id="runAudit" class="run-button">Run Audit</button>
 <div id="results" class="results"></div>
 
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.getElementById('runAudit').addEventListener('click', async () => {
 const url = document.getElementById('url').value;
 const checkboxes = document.querySelectorAll('.category-checkboxes input:checked');
 const categories = Array.from(checkboxes).map(cb => cb.value);
 
 const button = document.getElementById('runAudit');
 const resultsDiv = document.getElementById('results');
 
 button.disabled = true;
 button.textContent = 'Running audit...';
 resultsDiv.innerHTML = '';
 
 try {
 const response = await chrome.runtime.sendMessage({
 action: 'runAudit',
 url: url,
 categories: categories
 });
 
 if (response.success) {
 displayResults(response.results);
 } else {
 resultsDiv.innerHTML = `<p style="color: red;">Error: ${response.error}</p>`;
 }
 } catch (error) {
 resultsDiv.innerHTML = `<p style="color: red;">Error: ${error.message}</p>`;
 } finally {
 button.disabled = false;
 button.textContent = 'Run Audit';
 }
});

function displayResults(lhr) {
 const categories = lhr.categories;
 let html = '<h3>Audit Results</h3>';
 
 for (const [name, data] of Object.entries(categories)) {
 const score = Math.round(data.score * 100);
 const scoreClass = score >= 90 ? 'good' : score >= 50 ? 'needs-improvement' : 'poor';
 const displayName = name.charAt(0).toUpperCase() + name.slice(1).replace('-', ' ');
 
 html += `<p>
 <strong>${displayName}:</strong>
 <span class="score ${scoreClass}">${score}</span>
 </p>`;
 }
 
 document.getElementById('results').innerHTML = html;
}
```

## Practical Extensions and Enhancements

Once you have the basic audit runner working, consider these enhancements:

Automated Regression Detection: Store audit results in Chrome storage or a remote database. Compare new scores against baselines to detect performance regressions automatically.

Scheduled Audits: Use the Alarms API to run audits on specific pages at regular intervals, building a performance timeline over time.

Custom Throttling Profiles: Add UI controls for different network conditions (fast 3G, slow 3G, offline) to test under various conditions.

Export Functionality: Export results as JSON, CSV, or generate shareable HTML reports for team communication.

## Troubleshooting Common Issues

Several issues commonly arise when building Lighthouse extensions:

The debugger fails to attach if another extension is already using it. Check for conflicts and ensure only one extension uses the debugger at a time.

Some pages block audit scripts through Content Security Policy. You may need to inject Lighthouse differently for these sites or exclude them from auditing.

Memory limits in background service workers can cause timeouts on complex pages. Consider breaking audits into smaller chunks or using dedicated audit workers.

## Conclusion

Building a Chrome extension for running Lighthouse audits transforms your browser into a powerful performance testing tool. The architecture shown here, using the debugger API for accurate measurements, a service worker for orchestration, and a popup for user interaction, provides a solid foundation for custom audit workflows. Extend this base with automation, reporting, and integration features that match your specific development needs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-lighthouse-audit-runner)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Page Speed Insights: A Developer Guide](/chrome-extension-page-speed-insights/)
- [Claude Code Lighthouse Score Improvement Automation Guide](/claude-code-lighthouse-score-improvement-automation-guide/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



