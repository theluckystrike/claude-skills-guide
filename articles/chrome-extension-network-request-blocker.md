---

layout: default
title: "Chrome Extension Network Request Blocker: A Developer's Guide"
description: "Learn how to block network requests in Chrome extensions using the declarativeNetRequest API. Practical examples for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-network-request-blocker/
---

# Chrome Extension Network Request Blocker: A Developer's Guide

Chrome extensions have powerful capabilities when it comes to modifying network behavior. Whether you're building a privacy-focused extension, debugging API calls, or creating developer tools, understanding how to block network requests at the extension level is essential knowledge.

This guide covers the modern approach to blocking network requests in Chrome extensions using the `declarativeNetRequest` API, with practical examples developers can implement immediately.

## Understanding the declarativeNetRequest API

The `declarativeNetRequest` API is Chrome's recommended way to block or modify network requests. Unlike the older `webRequest` API, `declarativeNetRequest` operates declaratively, which means you define rules upfront rather than intercepting each request in real-time. This approach offers better performance and privacy since extension code doesn't need to analyze every single network request.

To use this API, your extension needs the appropriate permissions in the manifest:

```json
{
  "manifest_version": 3,
  "name": "Network Request Blocker",
  "version": "1.0",
  "permissions": [
    "declarativeNetRequest"
  ],
  "host_permissions": [
    "<all_urls>"
  ]
}
```

The `host_permissions` field specifies which URLs your rules can match. Using `<all_urls>` gives your extension global reach, but you can restrict it to specific domains for more targeted blocking.

## Creating Blocking Rules

Rules are defined in a JSON file within your extension's `_locales` or root directory. Here's a basic example that blocks requests to a specific domain:

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "block"
    },
    "condition": {
      "urlFilter": "example-ad-server.com",
      "resourceTypes": ["script", "image"]
    }
  }
]
```

This rule blocks scripts and images from `example-ad-server.com`. The `urlFilter` field supports regular expressions, giving you fine-grained control over which URLs match.

To load these rules, update your manifest:

```json
{
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "rules.json"
    }]
  }
}
```

## Practical Implementation Example

Let me walk through building a practical network blocker that targets common tracking domains. First, create your rules file:

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": ".*\\.googlesyndication\\.com",
      "resourceTypes": ["script", "sub_frame"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": ".*\\.google-analytics\\.com",
      "resourceTypes": ["script", "ping"]
    }
  },
  {
    "id": 3,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": ".*\\.facebook\\.com/tr/",
      "resourceTypes": ["image", "script"]
    }
  }
]
```

This configuration blocks common tracking scripts from Google, Facebook, and ad networks. The regex patterns match subdomains automatically thanks to the `.*` prefix.

## Advanced: Modifying Requests Instead of Blocking

Sometimes you want to modify requests rather than block them entirely. The `declarativeNetRequest` API supports several action types:

- `block`: Prevents the request entirely
- `allow`: Whitelists matching requests
- `redirect`: Sends requests to a different URL
- `removeHeaders`: Strips specific headers from requests
- `modifyHeaders`: Adds or modifies request/response headers

Here's how to redirect tracking pixels to a local placeholder:

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "redirect",
      "redirect": {
        "extensionPath": "/images/pixel-placeholder.png"
      }
    },
    "condition": {
      "urlFilter": ".*\\.tracking-pixel\\.com/.*",
      "resourceTypes": ["image"]
    }
  }
]
```

This approach keeps pages functioning while eliminating privacy-invasive tracking.

## Dynamic Rules for User Configuration

For extensions that allow users to manage their own blocklist, you need dynamic rules. Unlike static rules defined in the manifest, dynamic rules can be added or removed at runtime:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  const rule = {
    id: 1,
    priority: 1,
    action: { type: 'block' },
    condition: {
      urlFilter: 'user-configured-domain.com',
      resourceTypes: ['script']
    }
  };

  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: [rule]
  });
});
```

You can build a popup interface where users add domains to block, then persist those choices using Chrome's storage API. When users update their blocklist, you call `updateDynamicRules` to apply changes immediately.

## Testing Your Extension

When developing network blocking extensions, testing requires attention to detail. Use Chrome's extension management page to reload your extension after each change. For debugging, the `chrome.declarativeNetRequest` API provides helpful methods:

```javascript
// Check current rules
chrome.declarativeNetRequest.getDynamicRules()
  .then(rules => console.log('Active rules:', rules));

// Test matching without blocking
chrome.declarativeNetRequest.testMatchOutcome(
  { url: 'https://example.com/script.js' },
  result => console.log('Would match:', result.matchedRules)
);
```

The `testMatchOutcome` method is particularly useful for verifying your rules match the intended URLs before deploying.

## Performance Considerations

The `declarativeNetRequest` API is optimized for performance, but following best practices ensures your extension remains efficient:

- **Prefer static rules**: Define rules in your manifest when possible. Static rules are loaded once at startup.
- **Limit dynamic rules**: Chrome imposes quotas on dynamic rules. Check `chrome.declarativeNetRequest.getAvailableStaticRuleCount()` to see your allocation.
- **Use resourceType filters**: Only target the request types you need. Blocking all requests to a domain is wasteful if you only care about scripts.

## Common Pitfalls to Avoid

Many developers encounter issues when first implementing network blocking. The most frequent problems include:

- **Missing host_permissions**: Without proper host permissions, rules won't apply to HTTPS sites
- **Regex complexity**: Overly complex regex patterns can slow down matching
- **Rule priority conflicts**: When multiple rules match, the highest priority wins

Always test thoroughly across different websites since network request patterns vary significantly.

Building a network request blocker is a straightforward process once you understand the `declarativeNetRequest` API. Whether you're creating a privacy tool, debugging API calls, or developing developer utilities, the declarative approach provides the performance and flexibility needed for production-quality extensions.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
