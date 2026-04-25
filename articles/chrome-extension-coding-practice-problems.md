---
layout: default
title: "Chrome Extension Coding Practice (2026)"
description: "Claude Code extension tip: master Chrome extension development with hands-on practice problems. Build real extensions, debug common issues, and learn..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-coding-practice-problems/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
---

# Chrome Extension Coding Practice Problems

Building Chrome extensions requires understanding browser-specific APIs, the extension lifecycle, and the nuances of Chrome's permission system. This guide provides practical coding problems that simulate real-world extension development scenarios, helping developers build production-ready extensions. Whether you are moving from Manifest V2 to V3, learning service worker constraints for the first time, or struggling with cross-context communication, the problems below offer focused, runnable examples you can adapt immediately.

## Setting Up Your Development Environment

Before diving into practice problems, ensure your environment is properly configured. You'll need Chrome or Chromium-based browsers for testing, a code editor, and the Chrome Developer Tools.

Create a basic extension structure with these essential files:

```
my-extension/
 manifest.json
 popup.html
 popup.js
 background.js
 content.js
```

Your manifest.json defines the extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Practice Extension",
 "version": "1.0",
 "permissions": ["storage", "activeTab"],
 "action": {
 "default_popup": "popup.html"
 }
}
```

To load the extension during development, navigate to `chrome://extensions`, enable Developer Mode in the upper-right corner, then click "Load unpacked" and select your project folder. Chrome will display any manifest errors immediately. Keep this tab open as you work, each time you make changes to the background script or manifest, click the refresh icon on your extension card to reload it.

## Manifest V2 vs. Manifest V3: What Changed

Developers migrating from V2 face several breaking changes. Understanding the differences up front prevents wasted debugging time.

| Feature | Manifest V2 | Manifest V3 |
|---|---|---|
| Background context | Persistent background page | Service worker (ephemeral) |
| Network interception | `webRequest` (blocking) | `declarativeNetRequest` (rule-based) |
| Script injection | `chrome.tabs.executeScript` | `chrome.scripting.executeScript` |
| Remote code | Allowed via CSP | Blocked entirely |
| Persistent storage in BG | In-memory variables persist | Variables lost when SW terminates |

The most impactful change is the shift to service workers. Code that relied on a persistent background page keeping variables alive will silently fail in V3 because the service worker terminates after roughly 30 seconds of inactivity.

## Practice Problem 1: Message Passing Between Contexts

Chrome extensions operate across multiple execution contexts, background scripts, content scripts, and popup pages. Communicating between these contexts is a fundamental skill.

Problem: Build an extension where clicking the popup button sends a message to the content script, which then modifies the current page's DOM.

Solution:

```javascript
// popup.js
document.getElementById('highlightBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 chrome.tabs.sendMessage(tab.id, { action: 'highlight' }, (response) => {
 console.log('Response:', response);
 });
});

// content.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'highlight') {
 document.body.style.backgroundColor = '#fff9c4';
 sendResponse({ success: true, elements: document.querySelectorAll('p').length });
 }
 return true;
});
```

Note the `return true` in the message listener, this allows asynchronous sendResponse calls. Without it, the message channel closes before your async work completes and the response is never delivered.

Common pitfall: If the content script has not yet been injected into the tab, `chrome.tabs.sendMessage` will throw a "Could not establish connection" error. Guard against this by wrapping the send in a try/catch and injecting the content script programmatically when needed:

```javascript
// popup.js. defensive message sending
async function sendMessageToTab(tabId, message) {
 try {
 return await chrome.tabs.sendMessage(tabId, message);
 } catch (err) {
 // Content script not injected yet. inject it first
 await chrome.scripting.executeScript({
 target: { tabId },
 files: ['content.js']
 });
 return chrome.tabs.sendMessage(tabId, message);
 }
}
```

## One-time vs. long-lived connections

For simple request/response pairs, `chrome.tabs.sendMessage` is sufficient. For streaming data or ongoing communication (such as a sidebar panel that needs live updates), use `chrome.runtime.connect` to establish a long-lived port:

```javascript
// content.js. long-lived port
const port = chrome.runtime.connect({ name: 'sidebar' });

port.onMessage.addListener((message) => {
 if (message.type === 'UPDATE') {
 renderUpdate(message.data);
 }
});

port.onDisconnect.addListener(() => {
 console.log('Port disconnected. service worker may have restarted');
});

// background.js. accepting connections
chrome.runtime.onConnect.addListener((port) => {
 if (port.name === 'sidebar') {
 port.onMessage.addListener((msg) => {
 port.postMessage({ type: 'ACK', received: msg });
 });
 }
});
```

Long-lived ports also keep the service worker alive for the duration of the connection, which is useful when you need the background script to remain active during multi-step operations.

## Practice Problem 2: Handling Asynchronous Operations

Modern Chrome extensions frequently interact with storage, tabs, and network requests. Mastering async patterns is essential.

Problem: Create an extension that saves user preferences to chrome.storage and retrieves them when the popup opens.

Solution:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
 // Load saved preferences
 const result = await chrome.storage.local.get(['theme', 'fontSize', 'enabled']);

 document.getElementById('theme').value = result.theme || 'light';
 document.getElementById('fontSize').value = result.fontSize || '16';
 document.getElementById('toggle').checked = result.enabled ?? true;

 // Save on change
 document.getElementById('saveBtn').addEventListener('click', async () => {
 const preferences = {
 theme: document.getElementById('theme').value,
 fontSize: document.getElementById('fontSize').value,
 enabled: document.getElementById('toggle').checked
 };

 await chrome.storage.local.set(preferences);
 document.getElementById('status').textContent = 'Saved!';
 });
});
```

The chrome.storage API automatically serializes objects, making it ideal for storing complex configuration data.

chrome.storage.local vs. chrome.storage.sync

Choosing the right storage area matters for user experience:

| Property | `storage.local` | `storage.sync` |
|---|---|---|
| Quota | ~10 MB | ~100 KB total, 8 KB per item |
| Synced across devices | No | Yes (requires signed-in Chrome) |
| Read speed | Fast (local disk) | Fast (cached locally) |
| Best for | Large data, sensitive data | Small user preferences |

For preferences like theme or font size, `storage.sync` lets the user carry their settings across machines automatically. For anything larger, cached API responses, downloaded assets, use `storage.local`.

Listening for storage changes across contexts is equally important. A content script can react in real time when the user changes a setting in the popup:

```javascript
// content.js. react to preference changes
chrome.storage.onChanged.addListener((changes, area) => {
 if (area !== 'local') return;

 if (changes.theme) {
 applyTheme(changes.theme.newValue);
 }

 if (changes.fontSize) {
 document.body.style.fontSize = changes.fontSize.newValue + 'px';
 }
});
```

This pattern eliminates the need to send explicit messages for preference updates, the storage change event propagates automatically to all extension contexts.

## Practice Problem 3: Working with Declarative Net Requests

Manifest V3 replaced webRequest with declarativeNetRequest for network filtering. This is a common friction point for developers.

Problem: Block specific domains using declarativeNetRequest rules.

Solution:

```json
// manifest.json
{
 "permissions": ["declarativeNetRequest"],
 "host_permissions": ["<all_urls>"]
}
```

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 const rules = [
 {
 id: 1,
 priority: 1,
 action: { type: 'block' },
 condition: {
 urlFilter: '||example-ad-domain.com',
 resourceTypes: ['script', 'image']
 }
 },
 {
 id: 2,
 priority: 1,
 action: { type: 'redirect', redirect: { url: 'https://example.com/placeholder.png' } },
 condition: {
 urlFilter: '||tracker-analytics.com',
 resourceTypes: ['image']
 }
 }
 ];

 chrome.declarativeNetRequest.updateDynamicRules({
 addRules: rules
 });
});
```

Remember that declarativeNetRequest requires the "declarativeNetRequest" permission and appropriate host permissions.

## Dynamic rules vs. static rules

The API supports two rule sets:

- Static rules are declared in a JSON file referenced in the manifest. They are compiled at install time and cannot be changed at runtime. Use these for rules that never change.
- Dynamic rules are added and removed at runtime via `updateDynamicRules`. Use these for user-configurable blocklists.

```javascript
// background.js. toggling a dynamic rule based on user preference
async function setBlockingEnabled(enabled) {
 const existing = await chrome.declarativeNetRequest.getDynamicRules();
 const existingIds = existing.map(r => r.id);

 if (enabled) {
 await chrome.declarativeNetRequest.updateDynamicRules({
 removeRuleIds: existingIds,
 addRules: buildBlockingRules()
 });
 } else {
 await chrome.declarativeNetRequest.updateDynamicRules({
 removeRuleIds: existingIds
 });
 }
}
```

Dynamic rules have a limit of 5,000 per extension. If you need a larger list, consider static rules (up to 30,000) or apply server-side URL categorization to keep the active set small.

## Practice Problem 4: Service Worker Lifecycle Management

Background scripts in Manifest V3 are service workers, which introduces lifecycle considerations. They can be terminated after inactivity.

Problem: Implement a pattern that handles service worker restarts gracefully while maintaining state.

Solution:

```javascript
// background.js
let cachedData = null;

// Initialize from storage on startup
chrome.runtime.onInstalled.addListener(async () => {
 const { appState } = await chrome.storage.local.get('appState');
 cachedData = appState || { counters: {}, lastUpdate: Date.now() };
});

// Handle service worker wake-up
chrome.runtime.onStartup.addListener(() => {
 chrome.storage.local.get('appState').then(result => {
 cachedData = result.appState || { counters: {}, lastUpdate: Date.now() };
 });
});

// Persist state periodically
setInterval(() => {
 if (cachedData) {
 chrome.storage.local.set({ appState: cachedData });
 }
}, 30000);

// Handle messages from other contexts
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'GET_STATE') {
 sendResponse(cachedData);
 return true;
 }

 if (message.type === 'UPDATE_COUNTER') {
 cachedData.counters[message.key] = (cachedData.counters[message.key] || 0) + 1;
 sendResponse({ success: true, count: cachedData.counters[message.key] });
 return true;
 }
});
```

## The "service worker terminated" trap

The `setInterval` call above has a subtle flaw: Chrome may terminate the service worker before the interval fires, and intervals do not persist across restarts. A more reliable pattern is to persist state immediately after every mutation rather than on a timer:

```javascript
// background.js. persist-on-write pattern
async function updateCounter(key) {
 const { appState } = await chrome.storage.local.get('appState');
 const state = appState || { counters: {} };
 state.counters[key] = (state.counters[key] || 0) + 1;
 await chrome.storage.local.set({ appState: state });
 return state.counters[key];
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'UPDATE_COUNTER') {
 updateCounter(message.key).then(count => {
 sendResponse({ success: true, count });
 });
 return true;
 }
});
```

This eliminates the race condition entirely: every write is immediately durable regardless of when the service worker terminates.

## Keeping the service worker alive for long tasks

For operations that must complete without interruption, such as uploading a file or running a multi-step background job, use the chrome.alarms API to schedule periodic wakeups:

```javascript
// background.js. alarm-based keepalive during a long job
chrome.alarms.create('keepalive', { periodInMinutes: 0.4 });

chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === 'keepalive') {
 // Reading storage is enough to reset the idle timer
 chrome.storage.local.get('jobStatus');
 }
});
```

Delete the alarm once the long-running task completes to avoid unnecessary wakeups.

## Practice Problem 5: Content Script Injection Patterns

Injecting scripts and styles into pages requires understanding the differences between static and programmatic injection.

Problem: Inject a content script only when a specific condition is met, such as when the user interacts with the page.

Solution:

```javascript
// background.js - Programmatic injection on user action
chrome.action.onClicked.addListener(async (tab) => {
 // First inject the content script
 await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 files: ['content.js']
 });

 // Then send a message to initialize
 chrome.tabs.sendMessage(tab.id, { action: 'initialize' });
});

// content.js - Conditional logic execution
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'initialize') {
 // Only activate on specific pages
 if (window.location.hostname.endsWith('.example.com')) {
 initExtension();
 }
 }
});

function initExtension() {
 // Your extension logic here
 console.log('Extension initialized on:', window.location.href);
}
```

## Avoiding double-injection

`chrome.scripting.executeScript` re-injects the script every time it is called. If the user clicks the action button twice, your content script runs twice, creating duplicate event listeners or DOM elements. Guard against this with an injection guard variable:

```javascript
// content.js. idempotent injection guard
if (window.__myExtensionLoaded) {
 // Already injected. just re-initialize if needed
 chrome.runtime.sendMessage({ type: 'READY' });
} else {
 window.__myExtensionLoaded = true;
 initExtension();
}
```

## Injecting CSS alongside scripts

Visual modifications often require both a script and a stylesheet. Inject them together to avoid a flash of unstyled content:

```javascript
// background.js. inject script and CSS atomically
await Promise.all([
 chrome.scripting.executeScript({
 target: { tabId: tab.id },
 files: ['content.js']
 }),
 chrome.scripting.insertCSS({
 target: { tabId: tab.id },
 files: ['content.css']
 })
]);
```

Running both in parallel via `Promise.all` is faster than awaiting each sequentially and minimizes the window during which the script runs without its associated styles.

## Practice Problem 6: Cross-Origin Fetch from the Background Script

Content scripts share the page's origin and are subject to its CORS policy. Background service workers operate under the extension's origin and can make cross-origin requests to any host listed in `host_permissions`.

Problem: Fetch data from an external API and pass it to the content script without CORS errors.

Solution:

```javascript
// manifest.json. add host permission
{
 "host_permissions": ["https://api.example.com/*"]
}

// background.js. proxy the fetch
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'FETCH_DATA') {
 fetch(`https://api.example.com/data?q=${encodeURIComponent(message.query)}`)
 .then(res => res.json())
 .then(data => sendResponse({ success: true, data }))
 .catch(err => sendResponse({ success: false, error: err.message }));
 return true; // keep channel open for async response
 }
});

// content.js. request data through the background proxy
async function fetchData(query) {
 const response = await chrome.runtime.sendMessage({
 type: 'FETCH_DATA',
 query
 });
 if (!response.success) throw new Error(response.error);
 return response.data;
}
```

This proxy pattern keeps sensitive API keys out of content scripts (which are visible to the page) and centralizes network logic in the background script where it can be rate-limited or cached.

## Debugging Tips

When developing Chrome extensions, these debugging patterns save significant time:

1. Background Script Logs: Access through `chrome://extensions`, click the "Service Worker" link next to your extension to open a dedicated DevTools panel for the background script.

2. Content Script Inspection: Open DevTools for the page, then select the extension context from the JavaScript context dropdown in the Console panel. Logs from your content script appear here, separated from page-level logs.

3. Storage Inspection: Run `chrome.storage.local.get(null, console.log)` in the background service worker console to dump the entire storage namespace.

4. Network Debugging: DeclarativeNetRequest rules appear in the Network tab as "blocked" or "redirected" entries. Enable the "Has blocked response cookies" filter to spot rules firing unexpectedly.

5. Reloading without reinstalling: After changing the manifest or background script, click the refresh icon in `chrome://extensions`. Changes to popup or content scripts take effect immediately on the next invocation without a full reload.

6. Simulating service worker termination: In the service worker DevTools panel, click "Stop" to manually terminate the worker, then trigger an action that should wake it up. This quickly surfaces bugs caused by assuming in-memory state persists.

## Common error messages and their causes

| Error message | Likely cause |
|---|---|
| "Could not establish connection. Receiving end does not exist." | Content script not yet injected, or the target tab was closed |
| "Extension context invalidated" | The extension was reloaded while a content script was still running |
| "Cannot access a chrome:// URL" | Your extension tried to inject into a privileged browser page |
| "Maximum dynamic rules exceeded" | You hit the 5,000 dynamic rule limit in declarativeNetRequest |
| "Service worker registration failed" | Syntax error in background.js, or the file path in the manifest is wrong |

## Moving Forward

These practice problems cover the core patterns you'll encounter building Chrome extensions. Focus on understanding message passing architecture, async handling with chrome.storage, and the service worker lifecycle. Once comfortable with these patterns, explore more advanced topics like native messaging, identity API integration, and debugging memory issues in long-running extensions.

The extension APIs most worth studying after this foundation are `chrome.alarms` for scheduled background tasks, `chrome.identity` for OAuth flows, `chrome.notifications` for system-level alerts, and `chrome.offscreen` for running DOM-dependent code outside a visible tab.

Building real extensions, even simple ones, provides the best learning experience. Start with a problem you want to solve, then work through the implementation details using these patterns as reference. Publish to the Chrome Web Store early, even as an unlisted extension: the review process and the store's detailed crash reporting surface issues that are impossible to reproduce locally.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-coding-practice-problems)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension LeetCode Helper: Boost Your Coding.](/chrome-extension-leetcode-helper/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Color Picker Chrome Extension: A Developer's Guide](/ai-color-picker-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


