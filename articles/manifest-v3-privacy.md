---
layout: default
title: "Manifest V3 Privacy — Developer Guide (2026)"
description: "Claude Code guide: a practical guide to Chrome extension privacy in Manifest V3. Learn about permission changes, host permissions, declarative Net..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /manifest-v3-privacy/
categories: [guides]
tags: [chrome-extension, manifest-v3, privacy, browser-security]
reviewed: true
score: 7
geo_optimized: true
---
Manifest V3 Privacy: What Developers and Power Users Need to Know

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

The key distinction is that `host_permissions` in V3 controls which sites an extension can access, while `permissions` now focuses on API capabilities. This separation makes it clearer what data an extension can access.

## Manifest V2 vs. V3: Side-by-Side Comparison

The scope of the changes goes well beyond permissions. Here is a full comparison across the axes that matter most for privacy and security:

| Feature | Manifest V2 | Manifest V3 | Privacy impact |
|---|---|---|---|
| Background pages | Persistent background pages | Service workers (ephemeral) | V3 reduces always-on data collection surface |
| Network interception | `webRequest` API (blocking mode) | `declarativeNetRequest` (static rules) | V3 prevents real-time inspection of request contents |
| Host permissions | Mixed into `permissions` array | Separate `host_permissions` key | V3 makes broad site access more visible to users |
| Remote code execution | Allowed via `eval()` and remote scripts | Prohibited | V3 eliminates a major malware vector |
| Content Security Policy | Loosely enforced | Strict enforcement | V3 limits XSS risk from injected scripts |
| Optional permissions | Supported | Supported with runtime API | V3 adds `withFilters` for finer control |
| Cross-origin fetch | Permitted from background | Limited, requires host permissions | V3 restricts silent data exfiltration |
| Storage | `chrome.storage` + cookies | `chrome.storage` (cookies restricted) | V3 reduces passive data harvesting |

The pattern is consistent: V3 trades developer flexibility for user privacy and security. Extension authors lose some power; users gain more meaningful control.

## Background Pages vs. Service Workers

One of the less-discussed privacy improvements in V3 is the shift from persistent background pages to service workers. In V2, a background page ran continuously as long as the browser was open. This gave extensions a permanent context to monitor events, accumulate data, and make network requests at any time. without any user action triggering the behavior.

Manifest V3 service workers are event-driven and ephemeral. They start when needed and terminate when idle. This means an extension cannot maintain a persistent in-memory session to accumulate data across your entire browsing history without explicit event triggers.

The V2 background page pattern looked like this:

```json
// manifest.json (V2)
{
 "background": {
 "scripts": ["background.js"],
 "persistent": true
 }
}
```

The V3 equivalent:

```json
// manifest.json (V3)
{
 "background": {
 "service_worker": "background.js",
 "type": "module"
 }
}
```

The difference in practice: V3 background code must use event listeners rather than long-running loops. A script that previously accumulated data in memory now has to write to `chrome.storage` immediately upon receiving an event, because the service worker is terminated before the next event fires. This is not a perfect privacy guarantee. a malicious extension can still store data aggressively. but it raises the effort required and makes behavior more auditable.

```javascript
// V3 service worker. correct pattern
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
 if (changeInfo.status === 'complete' && tab.url) {
 // Must persist immediately; cannot rely on in-memory state
 chrome.storage.local.set({ lastVisited: tab.url });
 }
});
```

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

## Dynamic Rules: When Static is Not Enough

For use cases that require runtime-determined blocking (user-defined blocklists, for example), V3 provides `chrome.declarativeNetRequest.updateDynamicRules()`. Dynamic rules are still declarative in structure. they cannot inspect request bodies. but they can be added or removed at runtime:

```javascript
// Add a user-specified domain to the blocklist at runtime
async function blockDomain(domain) {
 const ruleId = Date.now(); // Use a stable ID in production
 await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [{
 id: ruleId,
 priority: 2,
 action: { type: "block" },
 condition: {
 urlFilter: `*://${domain}/*`,
 resourceTypes: ["main_frame", "sub_frame", "script", "image", "xmlhttprequest"]
 }
 }],
 removeRuleIds: []
 });
}
```

The key constraint: even dynamic rules cannot read request or response bodies. The extension declares what to block; the browser engine executes the block without passing the content through extension JavaScript. This is the privacy boundary that V3 enforces.

webRequest vs. declarativeNetRequest: Practical Tradeoffs

| Capability | webRequest (V2) | declarativeNetRequest (V3) |
|---|---|---|
| Read request headers | Yes | No |
| Read response bodies | Yes | No |
| Modify requests in-flight | Yes | Redirect only |
| Block based on content | Yes | URL pattern only |
| Privacy risk (malicious use) | High | Low |
| Legitimate ad blocking | Fully supported | Mostly supported (rule limits apply) |
| Custom per-request logic | Arbitrary JS | Not possible |
| Performance overhead | Extension JS runs per request | Native browser engine, near-zero overhead |

The performance improvement is a genuine benefit. `webRequest` forced every matching request through extension JavaScript, creating measurable latency. `declarativeNetRequest` runs in the browser's network stack with no JavaScript overhead.

## Optional Permissions: Privacy Through Just-In-Time Access

Manifest V3 encourages. and in some cases requires. the use of optional permissions. Instead of declaring all permissions at install time, extensions can request additional access only when the user performs an action that requires it.

```javascript
// Request an optional permission only when the user needs the feature
document.getElementById('export-btn').addEventListener('click', async () => {
 const granted = await chrome.permissions.request({
 permissions: ['downloads'],
 origins: ['https://api.example.com/*']
 });

 if (granted) {
 exportData();
 } else {
 showPermissionDeniedMessage();
 }
});
```

Declare optional permissions in the manifest without granting them at install:

```json
{
 "manifest_version": 3,
 "name": "Data Exporter",
 "permissions": ["storage"],
 "optional_permissions": ["downloads"],
 "optional_host_permissions": ["https://api.example.com/*"]
}
```

From a privacy standpoint, this is meaningful. An extension with optional permissions only accesses protected APIs when the user explicitly triggers the relevant action. Chrome displays a prompt confirming the request, keeping the user informed in real time rather than asking for blanket trust at install.

## User Privacy Controls in V3

Manifest V3 provides users with more visibility and control over extension permissions. When installing an extension from the Chrome Web Store, users now see clearly labeled permission requests separated into categories: "Data access on all websites," "Data access on specific sites," and "Site access."

Chrome also implements automatic permission revocation for extensions that haven't been used in an extended period. Extensions lose access to host permissions they haven't actively used, requiring users to re-grant access when needed.

For developers, this means designing extensions with minimal permissions from the start. Using `activeTab` instead of broad host access not only improves privacy but also increases user trust and installation rates.

## Privacy Best Practices for Extension Developers

Building privacy-conscious extensions involves more than just complying with Manifest V3 requirements. Consider these practices:

Request only necessary permissions. If your extension only needs to read data from the current page, request `activeTab` rather than broad host access. The user must explicitly invoke your extension, providing clear intent.

Use declarative APIs when possible. The `declarativeNetRequest` and `declarativeContent` APIs handle common use cases without requiring background script access to page data.

Store data minimally. If you need to persist user preferences, use `chrome.storage.local` instead of storing data in cookies or external databases. Be transparent about what data you store and for how long.

Implement proper content script isolation. Use separate JavaScript files for content scripts and avoid injecting code directly into page contexts when possible.

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

Avoid `executeScript` with remote content. Remote code execution is prohibited in V3. All JavaScript must be bundled with the extension. If your extension previously loaded scripts from a CDN, you must bundle those libraries locally. This closes a significant supply-chain attack vector.

Audit your `host_permissions` scope. Ask whether your extension actually needs access to every URL pattern you declared. An extension that only interacts with a single service should list only that service's domain, not `<all_urls>`. Reviewers and users both notice overly broad permissions.

Use content script `world` isolation. V3 lets you specify whether a content script runs in the `ISOLATED` world (default, cannot access page's JavaScript globals) or the `MAIN` world (has access to page globals, higher risk). Default to `ISOLATED` unless you have a specific reason to access page-level JavaScript:

```json
{
 "content_scripts": [{
 "matches": ["https://example.com/*"],
 "js": ["content.js"],
 "world": "ISOLATED"
 }]
}
```

## What Power Users Should Know

For users concerned about extension privacy, Manifest V3 provides better tools for managing browser extensions:

1. Review permissions before installing. Chrome displays permission categories clearly during installation. Pay particular attention to any extension requesting access to "all websites" or specific sensitive sites like your bank or email provider.
2. Use the Extensions Manager. Access `chrome://extensions` to see which sites each extension can access. Click "Details" on any extension to see its full permission list and the specific host patterns it can access.
3. Audit installed extensions regularly. Remove extensions you no longer use to reduce your attack surface. An extension you installed three years ago for a one-time task may still have broad host permissions active.
4. Check for excessive permissions. An extension that needs access to all websites for a simple feature is overreaching. A color picker does not need `<all_urls>` host permissions. A grammar checker might legitimately need to read text from any page. but also might not.
5. Watch for automatic revocation. Chrome will notify you when an extension loses access due to inactivity. Treat this as an opportunity to decide whether you actually still use the extension.
6. Inspect network activity. For extensions you want to scrutinize closely, use Chrome DevTools (F12 → Network) with the extension active. If a simple utility extension is making unexpected outbound requests to third-party domains, that warrants investigation.
7. Check the Chrome Web Store listing date and update history. Extensions that were last updated years ago predate V3 requirements and may still be running with V2 permission models. Extensions that suddenly gained a large number of new permissions in a recent update warrant scrutiny.

## Red Flags in Extension Permission Requests

Some permission combinations are inherently higher risk than others:

| Permission combination | Why it is risky |
|---|---|
| `<all_urls>` + `storage` | Can read data from any site and persist it |
| `<all_urls>` + `webRequest` (V2 legacy) | Can intercept all network traffic including credentials |
| `tabs` + broad host permissions | Can read URL history and page content silently |
| `cookies` + `<all_urls>` | Can read session cookies for any domain |
| `identity` | Can access your Google account information |
| `nativeMessaging` | Can communicate with native apps on your computer |

None of these permission combinations are automatically malicious. a legitimate password manager, for example, genuinely needs cookie access and broad host permissions. The question is whether the extension's stated purpose justifies the level of access it requests.

## Limitations and Ongoing Debates

Manifest V3 is not without its critics. Several privacy and security concerns remain unresolved or are actively debated in the extension developer community:

Rule limits constrain sophisticated ad blockers. The `declarativeNetRequest` API caps the number of dynamic rules an extension can maintain. Large filter lists used by tools like uBlock Origin exceed these limits, forcing maintainers to choose which rules to prioritize. Google has increased these limits in response to feedback, but the debate continues.

The `webRequest` read-only mode. V3 allows extensions to observe (but not modify) network requests using the `webRequest` API in read-only mode. This is a compromise that preserves some monitoring capability while removing the ability to intercept and modify traffic. Some developers argue this still exposes too much; others argue it does not expose enough for legitimate security tooling.

Enterprise extensions. Organizations deploying internally-developed extensions via enterprise policy can bypass some V3 restrictions. This is intentional. enterprise IT needs flexibility. but it means V3's privacy model does not apply uniformly across all Chrome deployments.

Side-loaded extensions. Extensions installed outside the Chrome Web Store (via developer mode or enterprise policy) are not subject to Web Store review, which is the primary gate that enforces V3 compliance. A malicious actor who can convince a user to enable developer mode and install a `.crx` file bypasses all V3 privacy protections entirely.

Understanding these limitations does not negate V3's improvements. it helps set realistic expectations. V3 raises the bar significantly for extensions distributed through the Chrome Web Store, which covers the vast majority of users.

## The Future of Extension Privacy

Manifest V3 represents a shift toward more controlled extension behavior, but privacy remains a shared responsibility between developers and users. Google continues to refine the platform, with potential future changes focusing on tighter restrictions on extension capabilities and more granular user controls.

For developers, building privacy-respecting extensions isn't just about compliance. it's about user trust. Extensions that demonstrate responsible data handling earn positive reviews and sustained user bases. For power users, understanding these changes helps make better decisions about which extensions to trust with their browsing data.

The Manifest V3 privacy model isn't perfect, but it represents meaningful progress toward a browser extension ecosystem where user privacy is the default rather than the exception.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=manifest-v3-privacy)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Block Phishing Extension: A Developer Guide to.](/chrome-block-phishing-extension/)
- [Chrome Extension Auto Meeting Summary: A Developer Guide](/chrome-extension-auto-meeting-summary/)
- [Chrome Extension Screen Recorder for Meetings: A.](/chrome-extension-screen-recorder-meetings/)
- [How to Use Web App Manifest Configuration (2026)](/claude-code-for-web-app-manifest-configuration-guide/)
- [Claude Code Kafka Consumer Producer Tutorial Guide](/claude-code-kafka-consumer-producer-tutorial-guide/)
- [Claude Code for Continuing Education as a Developer](/claude-code-for-continuing-education-as-a-developer/)
- [Claude Code Weights and Biases Experiment Tracking](/claude-code-weights-and-biases-experiment-tracking/)
- [Claude Code for Writing Research Methodology Sections](/claude-code-for-writing-research-methodology-sections/)
- [Claude Code Pulumi Python Infrastructure Guide](/claude-code-pulumi-python-infrastructure-guide/)
- [Claude Code Unleash Feature — Complete Developer Guide](/claude-code-unleash-feature-toggle-nodejs-integration-guide/)
- [Claude Code NestJS Guards Interceptors Pipes Deep Dive](/claude-code-nestjs-guards-interceptors-pipes-deep-dive/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

