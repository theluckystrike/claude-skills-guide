---

layout: default
title: "Chrome Extension User Agent Switcher: A Developer's Guide"
description: "Learn how to build a Chrome extension that switches user agents programmatically. Practical code examples and implementation patterns for developers."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-user-agent-switcher-developer/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


{% raw %}
Building a Chrome extension to switch user agents is a practical project that demonstrates how to interact with browser network requests and modify extension behavior dynamically. This guide walks you through the implementation, from manifest configuration to runtime message handling.

## Understanding the User Agent Challenge

The User-Agent header identifies your browser to web servers. Developers often need to switch this header for testing responsive designs, debugging server-side rendering issues, or accessing region-locked content. Chrome extensions provide several approaches to modify the User-Agent, each with different trade-offs.

## Method 1: Declarative Net Request (Manifest V3)

The modern approach uses the Declarative Net Request API, which replaces the deprecated webRequest blocking API in Manifest V3.

### manifest.json Configuration

```json
{
  "manifest_version": 3,
  "name": "User Agent Switcher",
  "version": "1.0",
  "permissions": [
    "declarativeNetRequest"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "action": {
    "default_popup": "popup.html"
  },
  "declarative_net_request": {
    "rule_resources": [{
      "id": "user_agent_rules",
      "enabled": true,
      "path": "rules.json"
    }]
  }
}
```

### rules.json Definition

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "requestHeaders": [
        { "header": "User-Agent", "operation": "set", "value": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1" }
      ]
    },
    "condition": {
      "urlFilter": "*",
      "resourceTypes": ["main_frame"]
    }
  }
]
```

This configuration applies the iPhone User-Agent to all main frame requests. The extension intercepts network requests before they reach the server.

## Method 2: Programmatic User Agent Switching

For dynamic switching based on user preferences, use runtime messaging with the declarativeNetRequest API.

### background.js Implementation

```javascript
// background.js - Handle messages from popup or content scripts
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'setUserAgent') {
    updateUserAgent(message.userAgent);
  }
});

function updateUserAgent(userAgent) {
  const rules = [{
    id: 1,
    priority: 1,
    action: {
      type: "modifyHeaders",
      requestHeaders: [
        { header: "User-Agent", operation: "set", value: userAgent }
      ]
    },
    condition: {
      urlFilter: "*",
      resourceTypes: ["main_frame"]
    }
  }];

  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: rules,
    removeRuleIds: [1]
  });
}
```

### popup.html Interface

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 250px; padding: 15px; font-family: system-ui; }
    select { width: 100%; padding: 8px; margin-bottom: 10px; }
    button { width: 100%; padding: 8px; background: #4285f4; color: white; border: none; cursor: pointer; }
  </style>
</head>
<body>
  <h3>User Agent Switcher</h3>
  <select id="userAgentSelect">
    <option value="default">Default Chrome</option>
    <option value="firefox">Firefox</option>
    <option value="safari">Safari iPhone</option>
    <option value="custom">Custom</option>
  </select>
  <input type="text" id="customUA" placeholder="Custom UA string" style="width: 100%; display: none;">
  <button id="applyBtn">Apply</button>
  <script src="popup.js"></script>
</body>
</html>
```

### popup.js Logic

```javascript
const userAgents = {
  default: navigator.userAgent,
  firefox: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
  safari: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
};

document.getElementById('userAgentSelect').addEventListener('change', (e) => {
  const customInput = document.getElementById('customUA');
  customInput.style.display = e.target.value === 'custom' ? 'block' : 'none';
});

document.getElementById('applyBtn').addEventListener('click', () => {
  const select = document.getElementById('userAgentSelect');
  let ua = select.value === 'custom' 
    ? document.getElementById('customUA').value 
    : userAgents[select.value];
  
  chrome.runtime.sendMessage({ action: 'setUserAgent', userAgent: ua });
  window.close();
});
```

## Method 3: Content Script Injection

For per-tab switching without affecting the entire browser, inject a content script that overrides navigator.userAgent.

### manifest.json (Content Script)

```json
{
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"],
    "run_at": "document_start"
  }]
}
```

### content.js

```javascript
// Override navigator.userAgent property
Object.defineProperty(navigator, 'userAgent', {
  get: function() {
    return localStorage.getItem('customUserAgent') || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  },
  configurable: false
});
```

This method works for JavaScript-accessible user agent values but does not change the actual HTTP header sent with requests.

## Handling Edge Cases

Several scenarios require additional consideration when building user agent switchers.

### Extension Update Conflicts

When updating rules dynamically, ensure previous rules are properly removed to prevent conflicts:

```javascript
async function setUserAgent(ua) {
  // Clear existing rules first
  await chrome.declarativeNetRequest.updateDynamicRules({
    removeRuleIds: [1, 2, 3, 4, 5]
  });
  
  // Add new rule
  await chrome.declarativeNetRequest.updateDynamicRules({
    addRules: [{
      id: 1,
      priority: 1,
      action: {
        type: "modifyHeaders",
        requestHeaders: [{ header: "User-Agent", operation: "set", value: ua }]
      },
      condition: { urlFilter: "*", resourceTypes: ["main_frame"] }
    }]
  });
}
```

### Manifest V2 Legacy Support

If supporting older extensions, use the webRequest API:

```javascript
chrome.webRequest.onBeforeSendHeaders.addListener(
  function(details) {
    for (var i = 0; i < details.requestHeaders.length; ++i) {
      if (details.requestHeaders[i].name === 'User-Agent') {
        details.requestHeaders[i].value = 'Custom UA String';
        break;
      }
    }
    return { requestHeaders: details.requestHeaders };
  },
  { urls: ["<all_urls>"] },
  ["blocking", "requestHeaders"]
);
```

Note that Manifest V2 requires the "webRequest" and "webRequestBlocking" permissions.

## Best Practices

Store user preferences using chrome.storage.sync for persistence across devices:

```javascript
// Save preference
chrome.storage.sync.set({ userAgent: selectedUA }, () => {
  console.log('User agent saved:', selectedUA);
});

// Load on startup
chrome.storage.sync.get(['userAgent'], (result) => {
  if (result.userAgent) {
    updateUserAgent(result.userAgent);
  }
});
```

Test your extension against multiple websites to verify compatibility. Some sites use additional headers or JavaScript checks beyond the User-Agent string.

## Conclusion

Building a user agent switcher in Chrome extensions requires understanding the Declarative Net Request API and its limitations. Choose the method that matches your use case: declarative rules for simple global switching, runtime messaging for dynamic control, or content script injection for per-tab customization. The Manifest V3 approach provides the most reliable results for HTTP header modification.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
