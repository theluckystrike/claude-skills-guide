---
layout: default
title: "Manifest V3 Privacy: What Developers and Power Users."
description: "A practical guide to Chrome extension privacy in Manifest V3. Learn about permission changes, host permissions, declarative Net Request, and how to."
date: 2026-03-15
author: theluckystrike
permalink: /manifest-v3-privacy/
categories: [guides]
tags: [chrome-extension, manifest-v3, privacy, browser-security]
reviewed: true
score: 7
---

{% raw %}
# Manifest V3 Privacy: What Developers and Power Users Need to Know

Chrome extensions have long been a powerful way to customize browser behavior, but they also present significant privacy concerns. With the transition from Manifest V2 to Manifest V3, Google introduced substantial changes to how extensions handle permissions, network requests, and user data. Understanding these changes helps developers build privacy-respecting extensions and empowers power users to make informed decisions about the extensions they install.

## The Permission Model Changes

Manifest V3 fundamentally reimagines how extensions request and use permissions. The most significant change involves how extensions access data on websites they interact with.

In Manifest V2, extensions could request broad host permissions that granted access to read and modify content on any webpage. This meant a single extension could theoretically read your emails, capture passwords, or exfiltrate sensitive data. Manifest V3 introduces a more restrictive model where host permissions must be explicitly declared, and the new "active tab" permission allows extensions to access the current tab only when the user explicitly invokes them.

Here's how the permission structure differs:

```json
// Manifest V2 (V2 style - no longer accepted for new extensions)
{
  "permissions": ["tabs", "storage", "http://*/*", "https://*/*"],
  "host_permissions": []
}

// Manifest V3 - Separated permissions and host_permissions
{
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["http://example.com/*", "https://example.com/*"]
}
```

The key distinction is that `host_permissions` in V3 controls which sites an extension can access, while `permissions` now focuses on API capabilities. This separation makes it clearer what data an extension can potentially access.

## The Declarative Net Request API

One of the most impactful privacy-related changes in Manifest V3 is the replacement of the `webRequest` API with the `declarativeNetRequest` API for blocking network requests.

Previously, extensions could intercept, modify, or block any network request in real-time. This powerful capability enabled ad blockers and privacy tools but also created potential for malicious extensions to intercept sensitive data like authentication tokens or credit card numbers.

With `declarativeNetRequest`, you define rules statically in a JSON file:

```json
// rules.json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "block"
    },
    "condition": {
      "urlFilter": "https://tracker.example.com/",
      "resourceTypes": ["script", "image"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": {
      "type": "redirect",
      "redirect": {
        "url": "https://your-extension.local/blocked.html"
      }
    },
    "condition": {
      "urlFilter": ".*\\.doubleclick\\.net",
      "resourceTypes": ["script"]
    }
  }
]
```

The extension registers these rules in its manifest:

```json
{
  "name": "Privacy Shield",
  "version": "1.0",
  "manifest_version": 3,
  "permissions": ["declarativeNetRequest"],
  "host_permissions": ["<all_urls>"],
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "rules.json"
    }]
  }
}
```

This approach shifts the blocking logic from runtime execution to static rules, reducing the extension's ability to make dynamic decisions about network traffic.

## User Privacy Controls in V3

Manifest V3 provides users with more visibility and control over extension permissions. When installing an extension from the Chrome Web Store, users now see clearly labeled permission requests separated into categories: "Data access on all websites," "Data access on specific sites," and "Site access."

Chrome also implements automatic permission revocation for extensions that haven't been used in an extended period. Extensions lose access to host permissions they haven't actively used, requiring users to re-grant access when needed.

For developers, this means designing extensions with minimal permissions from the start. Using `activeTab` instead of broad host access not only improves privacy but also increases user trust and installation rates.

## Privacy Best Practices for Extension Developers

Building privacy-conscious extensions involves more than just complying with Manifest V3 requirements. Consider these practices:

**Request only necessary permissions.** If your extension only needs to read data from the current page, request `activeTab` rather than broad host access. The user must explicitly invoke your extension, providing clear intent.

**Use declarative APIs when possible.** The `declarativeNetRequest` and `declarativeContent` APIs handle common use cases without requiring background script access to page data.

**Store data minimally.** If you need to persist user preferences, use `chrome.storage.local` instead of storing data in cookies or external databases. Be transparent about what data you store and for how long.

**Implement proper content script isolation.** Use separate JavaScript files for content scripts and avoid injecting code directly into page contexts when possible.

```javascript
// Good: Explicit content script injection
{
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content-script.js"],
    "run_at": "document_idle"
  }]
}
```

## What Power Users Should Know

For users concerned about extension privacy, Manifest V3 provides better tools for managing browser extensions:

1. **Review permissions before installing** — Chrome displays permission categories clearly during installation
2. **Use the Extensions Manager** — Access chrome://extensions to see which sites each extension can access
3. **Audit installed extensions regularly** — Remove extensions you no longer use to reduce your attack surface
4. **Check for excessive permissions** — An extension that needs access to all websites for a simple feature may be overreaching
5. **Watch for automatic revocation** — Chrome will notify you when an extension loses access due to inactivity

## The Future of Extension Privacy

Manifest V3 represents a shift toward more controlled extension behavior, but privacy remains a shared responsibility between developers and users. Google continues to refine the platform, with potential future changes focusing on tighter restrictions on extension capabilities and more granular user controls.

For developers, building privacy-respecting extensions isn't just about compliance—it's about user trust. Extensions that demonstrate responsible data handling earn positive reviews and sustained user bases. For power users, understanding these changes helps make better decisions about which extensions to trust with their browsing data.

The Manifest V3 privacy model isn't perfect, but it represents meaningful progress toward a browser extension ecosystem where user privacy is the default rather than the exception.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
