---
layout: default
title: "Chrome Referrer Blocking Extension: A Developer's Guide"
description: "Learn how to control and block the HTTP Referrer header in Chrome using extensions. Practical implementation guide for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-referrer-blocking-extension/
---

{% raw %}
# Chrome Referrer Blocking Extension: A Developer's Guide

The HTTP Referrer header has been a staple of web analytics since the early days of the internet. However, it also poses significant privacy concerns and can leak sensitive URL information across domains. For developers and power users, understanding how to control or block the Referrer header in Chrome becomes essential for building privacy-respecting applications and protecting user data.

This guide covers the technical implementation of referrer blocking in Chrome extensions, providing practical code examples and real-world use cases.

## Understanding the Referrer Header

When you click a link on website A that takes you to website B, the browser sends a Referrer header indicating where the user came from. This header can contain:

- Full URLs including query parameters
- Path information that may reveal user-specific data
- Fragment identifiers with sensitive identifiers

```http
GET /landing-page HTTP/1.1
Host: example.com
Referrer: https://previous-site.com/user/profile?id=12345&token=abc
```

Chrome extensions can intercept and modify this behavior using the `declarativeNetRequest` API, which provides a performant way to modify network requests without requiring broad host permissions.

## Setting Up Your Extension

Create a new Chrome extension project with the following structure:

```
referrer-blocker/
├── manifest.json
├── rules.json
└── background.js
```

### Manifest Configuration

Your manifest must declare the `declarativeNetRequest` permission:

```json
{
  "manifest_version": 3,
  "name": "Referrer Blocker",
  "version": "1.0",
  "permissions": [
    "declarativeNetRequest"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "background": {
    "service_worker": "background.js"
  }
}
```

## Implementing Referrer Blocking Rules

The declarative Net Request API uses JSON rules to define how headers should be modified. Here's a practical implementation:

### Basic Referrer Removal

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  const rules = [
    {
      id: 1,
      priority: 1,
      action: {
        type: "modifyHeaders",
        requestHeaders: [
          { header: "Referer", operation: "set", value: "" }
        ]
      },
      condition: {
        urlFilter: "*://*/*",
        resourceTypes: ["main_frame", "sub_frame"]
      }
    }
  ];

  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: rules
  });
});
```

This rule removes the Referrer header entirely for all main frame and iframe navigations.

### Selective Referrer Blocking

You may want to block referrers only for specific domains or allow them for trusted sites:

```javascript
// background.js
const rules = [
  // Block referrer when leaving your domain
  {
    id: 1,
    priority: 1,
    action: {
      type: "modifyHeaders",
      requestHeaders: [
        { header: "Referer", operation: "set", value: "" }
      ]
    },
    condition: {
      urlFilter: "*://*/*",
      resourceTypes: ["main_frame"],
      initiatorDomains: ["yourdomain.com"]
    }
  },
  // Allow referrer to specific analytics domains
  {
    id: 2,
    priority: 2,
    action: {
      type: "allow"
    },
    condition: {
      urlFilter: "*://analytics.example.com/*",
      resourceTypes: ["image", "script"]
    }
  }
];

chrome.declarativeNetRequest.updateDynamicRules({
  addRules: rules,
  removeRuleIds: []
});
```

### Using referrerPolicy

Modern browsers support the `referrerPolicy` attribute, which provides more granular control. You can set this at the page level:

```html
<!-- Block referrer entirely -->
<a href="https://example.com" referrerpolicy="no-referrer">Link</a>

<!-- Send only origin, not full URL -->
<a href="https://example.com/page?id=123" referrerpolicy="origin">Link</a>

<!-- Same-origin only -->
<a href="/internal-page" referrerpolicy="same-origin">Link</a>
```

For a Chrome extension, you can inject this attribute into all links:

```javascript
// content script: inject-referrer-policy.js
document.addEventListener('DOMContentLoaded', () => {
  const links = document.querySelectorAll('a');
  links.forEach(link => {
    if (!link.hasAttribute('referrerpolicy')) {
      link.setAttribute('referrerpolicy', 'no-referrer');
    }
  });
});
```

## Building a Complete Extension

Here's a more complete implementation that includes a popup UI for toggling blocking:

```javascript
// popup.js
document.getElementById('toggle').addEventListener('click', async () => {
  const enabled = await chrome.storage.local.get('enabled');
  const newState = !enabled.enabled;
  
  await chrome.storage.local.set({ enabled: newState });
  
  if (newState) {
    enableBlocking();
  } else {
    disableBlocking();
  }
});

function enableBlocking() {
  const rules = [{
    id: 1,
    priority: 1,
    action: {
      type: "modifyHeaders",
      requestHeaders: [
        { header: "Referer", operation: "set", value: "" }
      ]
    },
    condition: {
      urlFilter: "*://*/*",
      resourceTypes: ["main_frame"]
    }
  }];
  
  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: rules
  });
}

function disableBlocking() {
  chrome.declarativeNetRequest.updateDynamicRules({
    removeRuleIds: [1]
  });
}
```

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Test the following scenarios:

1. Click links on various websites and verify no referrer is sent
2. Check network requests in DevTools to confirm headers
3. Test with different resource types (images, scripts, XHR)
4. Verify that allowed domains still receive referrers

## Performance Considerations

The declarative Net Request API runs efficiently because:

- Rules are evaluated in the browser's network stack, not JavaScript
- No content scripts are required for basic header modification
- Rules can be updated dynamically without reloading the extension

For extensions with complex rule sets, consider using rule sets stored in `rules.json` and loaded at runtime.

## Common Pitfalls

Host permissions matter significantly. Without proper `host_permissions` in your manifest, rules may not apply to all URLs. Also note that some strict browser security policies may override referrer settings for sensitive origins like `chrome://` URLs.

The Referrer-Policy HTTP header set by servers takes precedence over meta tags, so you may need to work with server-side configuration for complete control.

## Conclusion

Building a Chrome referrer blocking extension requires understanding the declarative Net Request API, proper manifest configuration, and thoughtful rule design. The examples provided here give you a foundation for creating privacy-respecting extensions that protect user data without breaking legitimate use cases.

For production deployments, consider adding user controls for different blocking modes, logging for debugging, and compatibility testing across different Chrome versions.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
