---


layout: default
title: "Chrome Extension Network Request Blocker: A Developer Guide"
description: "Learn how to build and implement network request blocking in Chrome extensions using Manifest V3. Practical examples for developers and power users."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-network-request-blocker/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
---


{% raw %}
Network request blocking is one of the most powerful capabilities available to Chrome extension developers. Whether you need to block ads, tracker's analytics scripts, or debug API calls during development, understanding how to intercept and block network requests from a Chrome extension opens up a wide range of possibilities.

## Understanding the Blocking APIs

Chrome provides two primary APIs for network request manipulation: `chrome.webRequest` and `chrome.declarativeNetRequest`. The choice between them depends on your use case and Chrome'sManifest V3 requirements.

The `chrome.webRequest` API has been available for years and provides fine-grained control over network requests. However, in Manifest V3, you can no longer use the `blocking` option in most contexts. Instead, you must use `chrome.declarativeNetRequest` for declarative blocking.

The `chrome.declarativeNetRequest` API is the modern approach for Manifest V3 extensions. It allows you to define rules that specify which requests to block or modify, and Chrome handles the blocking efficiently without needing a persistent background script.

## Setting Up Your Manifest

First, you need to declare the appropriate permissions in your `manifest.json`:

```json
{
  "manifest_version": 3,
  "name": "Network Request Blocker",
  "version": "1.0",
  "permissions": [
    "declarativeNetRequest",
    "declarativeNetRequestWithHostAccess"
  ],
  "host_permissions": [
    "<all_urls>"
  ]
}
```

The `declarativeNetRequestWithHostAccess` permission allows your extension to block requests while still accessing request details. For more restricted access, you can use specific host patterns.

## Creating Blocking Rules

Rules are defined in a JSON file that describes which network requests to block. Here's a practical example that blocks common tracking domains:

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "block"
    },
    "condition": {
      "urlFilter": "google-analytics.com",
      "resourceTypes": ["script", "image", "xhr"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": {
      "type": "block"
    },
    "condition": {
      "urlFilter": "facebook.net",
      "resourceTypes": ["script"]
    }
  }
]
```

Each rule consists of an ID, priority (higher priority rules are evaluated first), an action type, and conditions that match specific URL patterns.

## Loading Rules in Your Extension

In your background service worker, you load the rules when the extension installs or updates:

```javascript
// background.js
const RULES_FILE = 'rules.json';

chrome.runtime.onInstalled.addListener(() => {
  fetch(chrome.runtime.getURL(RULES_FILE))
    .then(response => response.json())
    .then(rules => {
      chrome.declarativeNetRequest.updateDynamicRules({
        addRules: rules,
        removeRuleIds: rules.map(rule => rule.id)
      });
    })
    .catch(console.error);
});
```

This approach loads rules dynamically, allowing users to customize blocking behavior without repackaging the extension.

## Implementing User-Controlled Blocking

For a practical extension, you want users to be able to toggle blocking for different categories. Here's a pattern for managing rule sets:

```javascript
// Rule categories
const ruleCategories = {
  trackers: { id: 1, name: "Trackers", enabled: true },
  ads: { id: 2, name: "Advertisements", enabled: true },
  analytics: { id: 3, name: "Analytics", enabled: false }
};

async function updateBlocking(category, enabled) {
  const rules = await loadCategoryRules(category);
  
  if (enabled) {
    await chrome.declarativeNetRequest.updateDynamicRules({
      addRules: rules
    });
  } else {
    await chrome.declarativeNetRequest.updateDynamicRules({
      removeRuleIds: rules.map(r => r.id)
    });
  }
  
  ruleCategories[category].enabled = enabled;
}
```

This allows users to enable or disable specific blocking categories without affecting others.

## Blocking Based on Response Content

Sometimes you need to block requests based on the response content rather than just the URL. While `declarativeNetRequest` doesn't support content-based blocking directly, you can combine it with `webRequest` for more complex scenarios:

```javascript
// In background.js with webRequest
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    // Check if this matches our content-based criteria
    if (shouldBlockBasedOnContent(details)) {
      return { cancel: true };
    }
  },
  {
    urls: ["<all_urls>"],
    types: ["xmlhttprequest", "script"]
  },
  ["blocking"]
);
```

However, note that this pattern requires the `webRequestBlocking` permission and will only work in unpacked extensions or extensions approved for this capability.

## Practical Use Cases

Network request blocking serves many practical purposes beyond ad blocking:

**Development Debugging**: Block specific API endpoints to test error handling or simulate failed requests without modifying your backend.

**Privacy Enhancement**: Block known tracking domains to prevent data collection while browsing.

**Performance Optimization**: Block resource-heavy elements like embedded videos or social media widgets that slow down page loads.

**Testing**: Simulate network conditions by blocking certain request types to test your application's resilience.

## Performance Considerations

When implementing network blocking, keep these performance tips in mind:

1. Use `declarativeNetRequest` instead of `webRequest` whenever possible—it's more efficient because Chrome handles the blocking natively.

2. Keep your rule sets small and specific. Thousands of rules can impact startup time.

3. Use URL patterns efficiently. Simple domain matching is faster than complex regex patterns.

4. Group related rules with the same priority to minimize rule evaluation overhead.

## Wrapping Up

Network request blocking in Chrome extensions has evolved significantly with Manifest V3. The `declarativeNetRequest` API provides a performant, modern approach to intercepting and blocking network calls. For developers and power users, this capability enables everything from building privacy-focused extensions to creating powerful development tools.

Start with simple URL-based blocking rules, then expand to more complex scenarios as needed. The Chrome extension documentation provides comprehensive details on advanced features like redirect actions, request modification, and rule priority handling.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
