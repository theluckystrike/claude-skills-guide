---
sitemap: false

layout: default
title: "Chrome Extension Periodic Table (2026)"
description: "Claude Code extension tip: a comprehensive reference guide to Chrome extension APIs and components. Practical patterns, code examples, and best..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-periodic-table-reference/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---


Chrome Extension Periodic Table Reference: Developer Guide

Chrome extensions transform the browsing experience by adding functionality directly into the browser. Understanding the relationships between extension components, APIs, and manifest configurations is essential for building solid extensions. This guide provides a systematic reference for developers working with Chrome extension architecture.

## Core Extension Components

A Chrome extension consists of several interconnected components that work together. The manifest file serves as the configuration center, defining permissions, content scripts, background workers, and popup interfaces.

## Manifest Configuration

The manifest.json file is the entry point for every extension:

```json
{
 "manifest_version": 3,
 "name": "My Extension",
 "version": "1.0",
 "permissions": ["storage", "activeTab", "scripting"],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 },
 "background": {
 "service_worker": "background.js"
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content.js"]
 }]
}
```

Manifest V3 introduced significant changes from V2, particularly the replacement of background pages with service workers and modifications to declarative net request rules.

## API Categories and Permissions

Chrome provides extensive APIs organized by functionality. Each category requires specific permissions in the manifest.

## Storage APIs

The storage API persists data across sessions:

```javascript
// Saving data
chrome.storage.local.set({ key: "user preferences" }).then(() => {
 console.log("Data saved successfully");
});

// Retrieving data
chrome.storage.local.get(["key"]).then((result) => {
 console.log("Retrieved:", result.key);
});
```

Storage options include local (persistent), sync (cloud-synced), and managed (admin-controlled) storage.

## Messaging APIs

Communication between extension components uses message passing:

```javascript
// From content script to background
chrome.runtime.sendMessage({
 action: "fetchData",
 url: "https://api.example.com/data"
}).then((response) => {
 console.log("Response:", response);
});

// In background service worker
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === "fetchData") {
 fetch(message.url)
 .then(res => res.json())
 .then(data => sendResponse(data));
 return true; // Keep message channel open for async response
 }
});
```

## Content Script Patterns

Content scripts run in the context of web pages, enabling direct DOM manipulation. They operate in an isolated world, meaning they cannot access page JavaScript variables but can modify the DOM.

## DOM Manipulation

```javascript
// Creating and injecting elements
const container = document.createElement("div");
container.id = "my-extension-root";
container.style.cssText = "position: fixed; top: 10px; right: 10px; z-index: 999999;";

const button = document.createElement("button");
button.textContent = "Click Me";
button.addEventListener("click", () => {
 chrome.runtime.sendMessage({ action: "buttonClicked" });
});

container.appendChild(button);
document.body.appendChild(container);
```

## Communicating with Page Scripts

To share data between content scripts and page JavaScript, use custom events:

```javascript
// Content script dispatching to page
const event = new CustomEvent("myExtensionEvent", {
 detail: { data: "important information" }
});
document.dispatchEvent(event);

// Page script listening
document.addEventListener("myExtensionEvent", (e) => {
 console.log("Received:", e.detail.data);
});
```

## Service Worker Best Practices

Background service workers handle events when no extension UI is visible. They must be efficient and handle the asynchronous nature of Chrome APIs.

## Event Handling

```javascript
// Browser action click handler
chrome.action.onClicked.addListener((tab) => {
 chrome.tabs.sendMessage(tab.id, { action: "toggleFeature" });
});

// Install/update handlers
chrome.runtime.onInstalled.addListener((details) => {
 if (details.reason === "install") {
 // First-time setup
 chrome.storage.local.set({ firstRun: true });
 } else if (details.reason === "update") {
 // Migration logic for updates
 console.log("Extension updated from version:", details.previousVersion);
 }
});
```

## Extension Contexts Reference

Understanding where your code executes is critical for debugging and architecture:

| Context | Access | Limitations |
|---------|--------|-------------|
| Popup | Chrome APIs | Closes on blur |
| Content Script | Page DOM | Isolated world |
| Background | All Chrome APIs | No DOM access |
| Options Page | Chrome APIs | User-initiated |

## Common Patterns for Power Users

## Keyboard Shortcuts

Define commands in manifest:

```json
"commands": {
 "toggle-feature": {
 "suggested_key": "Ctrl+Shift+F",
 "description": "Toggle the main feature"
 }
}
```

Handle in background:

```javascript
chrome.commands.onCommand.addListener((command) => {
 if (command === "toggle-feature") {
 chrome.tabs.query({ active: true, currentWindow: true })
 .then(([tab]) => {
 chrome.tabs.sendMessage(tab.id, { action: "toggle" });
 });
 }
});
```

## Declarative Content Matching

Control when content scripts load:

```json
"content_scripts": [{
 "matches": ["https://*.example.com/*"],
 "exclude_matches": ["*://*/admin/*"],
 "js": ["content.js"],
 "run_at": "document_idle"
}]
```

## Debugging Tips

Effective debugging requires understanding Chrome's extension architecture:

1. Service Worker Logs: Use chrome://extensions and click "Service Worker" to access console output
2. Content Script Debugging: Right-click page → Inspect → Content scripts tab
3. Network Inspection: Popup and background scripts appear in Network tab with "Extension" filter

## Security Considerations

Always follow security best practices:

- Request minimum necessary permissions
- Use `host_permissions` sparingly
- Validate all data from external sources
- Avoid `eval()` and inline scripts where possible
- Implement Content Security Policy in manifest

## Tabs and Windows API: Practical Patterns

The tabs and windows APIs are among the most commonly used in real-world extensions. They let you query, create, update, and close tabs programmatically, enabling everything from simple tab counters to full-featured workflow managers.

## Querying and Updating Active Tabs

A common pattern is grabbing the current active tab and modifying its URL or injecting a script:

```javascript
// Get the active tab and inject a script dynamically
chrome.tabs.query({ active: true, currentWindow: true }).then(([tab]) => {
 chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: () => {
 document.body.style.backgroundColor = "lightyellow";
 }
 });
});
```

This approach is useful for one-off injections triggered by a popup button click, without needing a persistent content script running on every page. The `scripting` permission must be declared in the manifest.

## Creating and Grouping Tabs

Chrome 89+ introduced tab groups, which let extensions organize tabs programmatically:

```javascript
// Open multiple related tabs and group them
async function openDocumentationSet(urls) {
 const tabIds = [];
 for (const url of urls) {
 const tab = await chrome.tabs.create({ url, active: false });
 tabIds.push(tab.id);
 }
 const groupId = await chrome.tabs.group({ tabIds });
 await chrome.tabGroups.update(groupId, {
 title: "Reference Docs",
 color: "blue",
 collapsed: false
 });
}

openDocumentationSet([
 "https://developer.chrome.com/docs/extensions/",
 "https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions"
]);
```

This requires the `tabGroups` permission. Tab groups persist across sessions when Chrome's tab restore feature is active, making them practical for saving research workflows.

## Options Page Patterns

An options page lets users configure extension behavior without cluttering the popup. It's a full HTML page with access to all Chrome APIs.

## Connecting Options Page to Storage

```javascript
// options.js. save user preferences
document.getElementById("saveBtn").addEventListener("click", () => {
 const theme = document.getElementById("themeSelect").value;
 const autoRun = document.getElementById("autoRunCheckbox").checked;

 chrome.storage.sync.set({ theme, autoRun }).then(() => {
 const status = document.getElementById("status");
 status.textContent = "Settings saved.";
 setTimeout(() => { status.textContent = ""; }, 2000);
 });
});

// Load existing values on page open
chrome.storage.sync.get(["theme", "autoRun"]).then((prefs) => {
 if (prefs.theme) document.getElementById("themeSelect").value = prefs.theme;
 if (prefs.autoRun !== undefined) {
 document.getElementById("autoRunCheckbox").checked = prefs.autoRun;
 }
});
```

Using `storage.sync` here ensures that settings follow the user across devices where they are signed into Chrome. Keep sync storage payloads small. Chrome limits sync storage to 100KB total with individual keys capped at 8KB.

## Alarms API for Scheduled Tasks

Service workers can be terminated by Chrome after a period of inactivity. The alarms API provides a reliable mechanism for scheduling recurring tasks that survive service worker restarts.

```javascript
// background.js. schedule a recurring check every 30 minutes
chrome.runtime.onInstalled.addListener(() => {
 chrome.alarms.create("dataRefresh", { periodInMinutes: 30 });
});

chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === "dataRefresh") {
 fetch("https://api.example.com/status")
 .then(res => res.json())
 .then(data => {
 chrome.storage.local.set({ lastStatus: data, lastChecked: Date.now() });
 });
 }
});
```

The alarms API requires the `"alarms"` permission. Unlike `setTimeout`, alarms fire even after the service worker has been idle and restarted, making them essential for any extension that needs reliable background polling.

## Notifications API

Extensions can surface native OS notifications without requiring the user to have the extension popup open:

```javascript
// Show a notification with an action button
chrome.notifications.create("alert-001", {
 type: "basic",
 iconUrl: "icon128.png",
 title: "Task Complete",
 message: "Your data export is ready to download.",
 buttons: [{ title: "Open File" }],
 priority: 2
});

chrome.notifications.onButtonClicked.addListener((notificationId, buttonIndex) => {
 if (notificationId === "alert-001" && buttonIndex === 0) {
 chrome.tabs.create({ url: "https://example.com/download" });
 }
});
```

Notifications require the `"notifications"` permission. On macOS, users must grant notification permissions to Chrome at the OS level for these to appear. Always clear notifications once they are no longer relevant using `chrome.notifications.clear()` to avoid notification buildup.

## Building for Production

Before publishing to Chrome Web Store:

1. Test across multiple Chrome versions
2. Verify permissions are minimal and justified
3. Compress images and assets
4. Include clear privacy policy if accessing user data
5. Test with Chrome's Lighthouse audit for extensions

The Chrome extension ecosystem offers tremendous flexibility for enhancing browser functionality. By understanding these core patterns and APIs, developers can build extensions that are performant, secure, and provide genuine value to users.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-periodic-table-reference)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Agent Handoff Strategies for Long Running Tasks Guide](/agent-handoff-strategies-for-long-running-tasks-guide/)
- [Agentic AI Coding Tools Comparison 2026: A Practical.](/agentic-ai-coding-tools-comparison-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

