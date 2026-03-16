---
layout: default
title: "Chrome Extension Coding Practice Problems"
description: "Master Chrome extension development with hands-on practice problems. Build real extensions, debug common issues, and learn Manifest V3 patterns."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-coding-practice-problems/
---

# Chrome Extension Coding Practice Problems

Building Chrome extensions requires understanding browser-specific APIs, the extension lifecycle, and the nuances of Chrome's permission system. This guide provides practical coding problems that simulate real-world extension development scenarios, helping developers build production-ready extensions.

## Setting Up Your Development Environment

Before diving into practice problems, ensure your environment is properly configured. You'll need Chrome or Chromium-based browsers for testing, a code editor, and the Chrome Developer Tools.

Create a basic extension structure with these essential files:

```
my-extension/
├── manifest.json
├── popup.html
├── popup.js
├── background.js
└── content.js
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

## Practice Problem 1: Message Passing Between Contexts

Chrome extensions operate across multiple execution contexts—background scripts, content scripts, and popup pages. Communicating between these contexts is a fundamental skill.

**Problem**: Build an extension where clicking the popup button sends a message to the content script, which then modifies the current page's DOM.

**Solution**:

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

Note the `return true` in the message listener—this allows asynchronous sendResponse calls.

## Practice Problem 2: Handling Asynchronous Operations

Modern Chrome extensions frequently interact with storage, tabs, and network requests. Mastering async patterns is essential.

**Problem**: Create an extension that saves user preferences to chrome.storage and retrieves them when the popup opens.

**Solution**:

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

## Practice Problem 3: Working with Declarative Net Requests

Manifest V3 replaced webRequest with declarativeNetRequest for network filtering. This is a common friction point for developers.

**Problem**: Block specific domains using declarativeNetRequest rules.

**Solution**:

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

## Practice Problem 4: Service Worker Lifecycle Management

Background scripts in Manifest V3 are service workers, which introduces lifecycle considerations. They can be terminated after inactivity.

**Problem**: Implement a pattern that handles service worker restarts gracefully while maintaining state.

**Solution**:

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

## Practice Problem 5: Content Script Injection Patterns

Injecting scripts and styles into pages requires understanding the differences between static and programmatic injection.

**Problem**: Inject a content script only when a specific condition is met, such as when the user interacts with the page.

**Solution**:

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

## Debugging Tips

When developing Chrome extensions, these debugging patterns save significant time:

1. **Background Script Logs**: Access through chrome://extensions, enable "Allow background scripts" and view console output.

2. **Content Script Inspection**: Open DevTools for the page, then select the extension context from the dropdown.

3. **Storage Inspection**: Use chrome.storage.local.get(null) in the console to view all stored data.

4. **Network Debugging**: DeclarativeNetRequest rules appear in the Network tab as "blocked" or "redirected" entries.

## Moving Forward

These practice problems cover the core patterns you'll encounter building Chrome extensions. Focus on understanding message passing architecture, async handling with chrome.storage, and the service worker lifecycle. Once comfortable with these patterns, explore more advanced topics like native messaging, identity API integration, and debugging memory issues in long-running extensions.

Building real extensions—even simple ones—provides the best learning experience. Start with a problem you want to solve, then work through the implementation details using these patterns as reference.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
