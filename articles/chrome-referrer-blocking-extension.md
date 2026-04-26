---
layout: default
title: "Referrer Blocking Chrome Extension (2026)"
description: "Claude Code extension tip: learn how to control and block the HTTP Referrer header in Chrome using extensions. Practical implementation guide for..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-referrer-blocking-extension/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
geo_optimized: true
---
Chrome Referrer Blocking Extension: A Developer's Guide

The HTTP Referrer header has been a staple of web analytics since the early days of the internet. However, it also poses significant privacy concerns and can leak sensitive URL information across domains. For developers and power users, understanding how to control or block the Referrer header in Chrome becomes essential for building privacy-respecting applications and protecting user data.

This guide covers the technical implementation of referrer blocking in Chrome extensions, providing practical code examples and real-world use cases. By the end, you will have a complete, deployable extension and a solid understanding of when and why to apply different referrer policies.

## Understanding the Referrer Header

When you click a link on website A that takes you to website B, the browser automatically sends a `Referer` header (note the historical misspelling) indicating where the user came from. This header can contain:

- Full URLs including query parameters
- Path information that may reveal user-specific data
- Fragment identifiers with sensitive identifiers
- Session tokens embedded in URLs by legacy systems

```http
GET /landing-page HTTP/1.1
Host: example.com
Referer: https://previous-site.com/user/profile?id=12345&token=abc
```

That request exposes the user's ID and a token to the destination server. The destination server logs this, third-party analytics scripts on that page log it, and if the page is served over HTTP, every network hop between the client and server sees it.

## Real-World Leakage Scenarios

Consider these practical situations where referrer leakage causes real problems:

Healthcare dashboards. A hospital patient portal includes the patient's record ID in its URL. When a patient clicks an external link on that page (say, a link to a drug information website), the drug site now knows that record ID came from the hospital's domain.

Internal tooling. A developer working inside a corporate intranet clicks a StackOverflow link from an internal ticket tracker. The full internal URL. including ticket numbers, project names, and any embedded tokens. goes to StackOverflow.

E-commerce checkout flows. A checkout page URL often contains cart identifiers or promo codes. Clicking any outbound link from that page leaks those details to the destination.

SaaS admin panels. Admin pages typically include resource identifiers in the URL. Clicking documentation links from an admin page can reveal your infrastructure topology to the docs provider.

Chrome extensions can intercept and modify this behavior using the `declarativeNetRequest` API, which provides a performant way to modify network requests without requiring broad host permissions or heavyweight content scripts.

## Referrer Policy Values: What Your Options Are

Before building an extension, understand the full spectrum of `Referrer-Policy` values available. This table summarizes each value and when to use it:

| Policy | What gets sent | Best for |
|---|---|---|
| `no-referrer` | Nothing | Maximum privacy, no analytics needed |
| `no-referrer-when-downgrade` | Full URL on HTTPS→HTTPS, nothing on HTTPS→HTTP | Default browser behavior |
| `origin` | Scheme + host only (`https://mysite.com`) | Useful for analytics without path exposure |
| `origin-when-cross-origin` | Full URL same-origin, origin only cross-origin | Balanced: internal detail kept internal |
| `same-origin` | Full URL same-origin, nothing cross-origin | Good default for sensitive apps |
| `strict-origin` | Origin on HTTPS→HTTPS, nothing on HTTPS→HTTP | Like `origin` but blocks HTTP downgrade |
| `strict-origin-when-cross-origin` | Full URL same-origin, strict-origin cross-origin | Chrome's current default since 2021 |
| `unsafe-url` | Full URL always | Debugging only, never in production |

For most privacy-focused extensions, `no-referrer` or `same-origin` are the right choices.

## Setting Up Your Extension

Create a new Chrome extension project with the following structure:

```
referrer-blocker/
 manifest.json
 rules.json
 background.js
 content-script.js
 popup.html
 popup.js
```

## Manifest Configuration

Your manifest must declare the `declarativeNetRequest` permission:

```json
{
 "manifest_version": 3,
 "name": "Referrer Blocker",
 "version": "1.0",
 "description": "Block or control the HTTP Referrer header for all requests",
 "permissions": [
 "declarativeNetRequest",
 "storage"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html",
 "default_title": "Referrer Blocker"
 },
 "content_scripts": [
 {
 "matches": ["<all_urls>"],
 "js": ["content-script.js"],
 "run_at": "document_end"
 }
 ]
}
```

The `storage` permission lets you persist the user's enabled/disabled state across browser sessions.

## Implementing Referrer Blocking Rules

The declarativeNetRequest API uses JSON rules to define how headers should be modified. Rules are evaluated in the browser's network stack. not in JavaScript. which makes them fast and reliable.

## Basic Referrer Removal

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
 addRules: rules,
 removeRuleIds: []
 });
});
```

This rule removes the Referrer header entirely for all main frame and iframe navigations. The `set` operation with an empty string value causes the header to be sent with no content. Some servers treat an empty string differently from an absent header. if you want the header completely absent, check whether the Chrome version you are targeting supports the `remove` operation instead.

## Selective Referrer Blocking

You should block referrers only for specific domains or allow them for trusted sites:

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

Rule priority matters here. A higher priority number wins when two rules match the same request. In the example above, any request to `analytics.example.com` is allowed (priority 2 beats priority 1) while everything else from your domain gets stripped.

## Domain Allowlist Pattern

For enterprise deployments where you need to whitelist a set of trusted domains, structure your rules as an array and register them together:

```javascript
// background.js
const TRUSTED_DOMAINS = [
 "internalanalytics.corp.com",
 "staging.myapp.com",
 "docs.myapp.com"
];

function buildAllowRules(domains) {
 return domains.map((domain, index) => ({
 id: 100 + index,
 priority: 3, // Higher than blocking rule
 action: { type: "allow" },
 condition: {
 urlFilter: `*://${domain}/*`,
 resourceTypes: ["main_frame", "sub_frame", "xmlhttprequest"]
 }
 }));
}

function buildBlockRule() {
 return {
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
 resourceTypes: ["main_frame", "sub_frame", "xmlhttprequest"]
 }
 };
}

chrome.runtime.onInstalled.addListener(async () => {
 const allRules = [buildBlockRule(), ...buildAllowRules(TRUSTED_DOMAINS)];
 await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: allRules,
 removeRuleIds: []
 });
 console.log(`Loaded ${allRules.length} referrer rules`);
});
```

## Using referrerPolicy on Links

Modern browsers support the `referrerPolicy` attribute directly on anchor elements. You can inject this attribute into all links via a content script, providing a second layer of protection that works even when header-level rules are not active:

```html
<!-- Block referrer entirely -->
<a href="https://example.com" referrerpolicy="no-referrer">Link</a>

<!-- Send only origin, not full URL -->
<a href="https://example.com/page?id=123" referrerpolicy="origin">Link</a>

<!-- Same-origin only -->
<a href="/internal-page" referrerpolicy="same-origin">Link</a>
```

For a Chrome extension, inject this attribute into all links automatically:

```javascript
// content-script.js
function applyReferrerPolicy(policy = 'no-referrer') {
 const links = document.querySelectorAll('a[href]');
 let patched = 0;
 links.forEach(link => {
 if (!link.hasAttribute('referrerpolicy')) {
 link.setAttribute('referrerpolicy', policy);
 patched++;
 }
 });
 return patched;
}

// Apply on initial load
document.addEventListener('DOMContentLoaded', () => {
 const count = applyReferrerPolicy();
 console.log(`[ReferrerBlocker] Patched ${count} links`);
});

// Watch for dynamically added links (SPAs)
const observer = new MutationObserver((mutations) => {
 mutations.forEach(mutation => {
 mutation.addedNodes.forEach(node => {
 if (node.nodeType === Node.ELEMENT_NODE) {
 const links = node.querySelectorAll
 ? node.querySelectorAll('a[href]')
 : [];
 links.forEach(link => {
 if (!link.hasAttribute('referrerpolicy')) {
 link.setAttribute('referrerpolicy', 'no-referrer');
 }
 });
 // Handle the node itself if it's a link
 if (node.tagName === 'A' && !node.hasAttribute('referrerpolicy')) {
 node.setAttribute('referrerpolicy', 'no-referrer');
 }
 }
 });
 });
});

observer.observe(document.body, {
 childList: true,
 subtree: true
});
```

The MutationObserver is critical for single-page applications (React, Vue, Angular) where links are injected after the initial DOM load.

## Building a Complete Extension with Toggle UI

Here's a complete implementation that includes a popup UI for toggling blocking on and off, with state persisted to storage:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <meta charset="UTF-8">
 <style>
 body { width: 240px; padding: 16px; font-family: system-ui, sans-serif; }
 h2 { margin: 0 0 12px; font-size: 14px; }
 .status { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
 .indicator { width: 10px; height: 10px; border-radius: 50%; }
 .indicator.on { background: #22c55e; }
 .indicator.off { background: #ef4444; }
 button { width: 100%; padding: 8px; cursor: pointer; border-radius: 4px; border: 1px solid #ccc; }
 </style>
</head>
<body>
 <h2>Referrer Blocker</h2>
 <div class="status">
 <div id="indicator" class="indicator off"></div>
 <span id="status-text">Loading...</span>
 </div>
 <button id="toggle">Toggle</button>
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
async function getState() {
 const result = await chrome.storage.local.get({ enabled: true });
 return result.enabled;
}

async function setState(enabled) {
 await chrome.storage.local.set({ enabled });
}

async function updateUI(enabled) {
 const indicator = document.getElementById('indicator');
 const statusText = document.getElementById('status-text');
 indicator.className = `indicator ${enabled ? 'on' : 'off'}`;
 statusText.textContent = enabled ? 'Blocking active' : 'Blocking disabled';
}

document.addEventListener('DOMContentLoaded', async () => {
 const enabled = await getState();
 await updateUI(enabled);

 document.getElementById('toggle').addEventListener('click', async () => {
 const current = await getState();
 const next = !current;
 await setState(next);
 await updateUI(next);

 // Notify background to update rules
 chrome.runtime.sendMessage({ type: 'SET_BLOCKING', enabled: next });
 });
});
```

```javascript
// background.js (complete version)
const BLOCK_RULE_ID = 1;

function buildBlockRule() {
 return {
 id: BLOCK_RULE_ID,
 priority: 1,
 action: {
 type: "modifyHeaders",
 requestHeaders: [
 { header: "Referer", operation: "set", value: "" }
 ]
 },
 condition: {
 urlFilter: "*://*/*",
 resourceTypes: ["main_frame", "sub_frame", "xmlhttprequest", "script", "image"]
 }
 };
}

async function enableBlocking() {
 await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [buildBlockRule()],
 removeRuleIds: [BLOCK_RULE_ID]
 });
}

async function disableBlocking() {
 await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [],
 removeRuleIds: [BLOCK_RULE_ID]
 });
}

chrome.runtime.onInstalled.addListener(async () => {
 const result = await chrome.storage.local.get({ enabled: true });
 if (result.enabled) {
 await enableBlocking();
 }
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'SET_BLOCKING') {
 const action = message.enabled ? enableBlocking() : disableBlocking();
 action.then(() => sendResponse({ ok: true }));
 return true;
 }
});
```

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Test the following scenarios:

1. Click links on various websites and verify no referrer is sent. check the Network tab in DevTools and inspect request headers
2. Confirm that the `Referer` header is absent or empty in outbound requests
3. Test with different resource types: images, scripts, XHR calls, and fetch requests
4. Navigate from a URL with query parameters to an external site and confirm those parameters do not appear in the destination's logs
5. Toggle the extension off and verify referrers resume being sent
6. Test SPA navigation on React/Vue apps to confirm the MutationObserver picks up dynamically added links

Use `chrome://net-internals/#events` for lower-level request inspection when DevTools does not show the headers you expect.

## Debugging Common Issues

Rules not applying. Double-check your `host_permissions` in the manifest. Without `<all_urls>` or the specific domain you are targeting, rules will silently fail to match.

Server-set Referrer-Policy overrides your extension. When a server sends a `Referrer-Policy` response header with a restrictive value, that takes precedence over what the browser would otherwise send. but your extension's header modification happens before the browser processes response headers, so your rule still wins for outbound requests. The response header governs what subsequent navigations from that page send.

Empty string vs. absent header. Some web applications behave differently when `Referer: ` (empty) is present versus when it is absent entirely. If you see unexpected behavior, try using `operation: "remove"` (available in Chrome 102+) instead of `set` with an empty value.

Iframe content. Sub-frame navigations require explicit inclusion in your rule's `resourceTypes` array. The `sub_frame` type covers iframes; omitting it means nested frames still leak referrers.

## Performance Considerations

The declarativeNetRequest API runs efficiently because:

- Rules are evaluated in the browser's network stack, not JavaScript
- No content scripts are required for basic header modification
- Rules can be updated dynamically without reloading the extension
- The rule evaluation is O(1) per request. it does not scale with the number of rules the way older approaches did

For extensions with complex rule sets, consider using static rule sets stored in `rules.json` declared in the manifest. Static rules are compiled at install time and are marginally faster than dynamic rules, but dynamic rules are flexible enough for most use cases.

## Comparison: Extension Approaches

| Approach | Performance | Flexibility | Privacy |
|---|---|---|---|
| `declarativeNetRequest` header rule | Excellent | Medium | Excellent |
| Content script link patching | Good | High | Good (misses non-link requests) |
| `Referrer-Policy` meta tag injection | Fast | Low | Partial (no control over existing tags) |
| `webRequest` API (MV2 only) | Slower | Very high | Excellent |

For Manifest V3, the `declarativeNetRequest` approach combined with content script link patching gives you the best coverage.

## Conclusion

Building a Chrome referrer blocking extension requires understanding the declarativeNetRequest API, proper manifest configuration, and thoughtful rule design. The examples provided here give you a foundation for creating privacy-respecting extensions that protect user data without breaking legitimate use cases.

For production deployments, consider adding user controls for different blocking modes (no-referrer vs. origin vs. same-origin), a logging panel for debugging, and compatibility testing across different Chrome versions. The combination of header-level rules and content script link patching provides defense in depth that handles both standard navigation and dynamically generated content in modern SPAs.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-referrer-blocking-extension)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Calendar Assistant Chrome Extension: A Developer's Guide](/ai-calendar-assistant-chrome-extension/)
- [AI Form Filler Chrome Extension: A Developer and Power.](/ai-form-filler-chrome-extension/)
- [AI Podcast Summary Chrome Extension: A Developer's Guide.](/ai-podcast-summary-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



