---
layout: default
title: "Manifest V3 vs V2 Security Comparison"
description: "Claude Code comparison: manifest V3 tightens Chrome extension security with declarativeNetRequest, service workers, and reduced permissions. See what..."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /manifest-v3-vs-v2-security/
reviewed: true
score: 8
categories: [comparisons]
tags: [chrome-extension, claude-skills]
geo_optimized: true
---
Google's transition from Manifest V2 to Manifest V3 represents the most significant security overhaul in Chrome extension history. If you maintain browser extensions, understanding these security differences is essential for protecting your users and ensuring compliance with Chrome Web Store policies. The timeline is no longer theoretical: new Manifest V2 extensions stopped being accepted in 2022, and existing V2 extensions have been gradually losing Chrome Web Store visibility since 2024. If you are still running V2, migration is now urgent, not optional.

## Background: Why the Security Overhaul

Manifest V2 served as the standard for Chrome extensions for over a decade. However, security researchers discovered significant vulnerabilities that demanded structural changes. The core problem was architectural: V2 treated extensions as highly trusted code with extensive runtime capabilities, which created a large attack surface.

Several high-profile incidents drove the urgency. Compromised CDN servers delivered malicious code updates to legitimate extensions. Extensions with broad `<all_urls>` permissions were found harvesting form data from banking sites. Persistent background pages enabled extensions to act as persistent spyware once installed. The transition to Manifest V3 wasn't merely cosmetic, it addressed fundamental architectural weaknesses in how extensions could access and manipulate user data.

Google's stated goals for MV3 were: improving user privacy, improving security, and improving performance. Not all developers agreed the tradeoffs were worth it (especially for ad-blockers), but from a pure security standpoint the changes are substantial.

## Key Security Differences at a Glance

| Security Area | Manifest V2 | Manifest V3 |
|---|---|---|
| Remote code execution | Allowed via external URLs | Banned. all code must be bundled |
| Background scripts | Persistent pages (always running) | Service workers (event-driven, idle-terminated) |
| Network interception | `webRequest` with full request body access | `declarativeNetRequest`. rule-based, no body access |
| Host permissions | Mixed with API permissions | Separate `host_permissions` field, optional grants |
| Dynamic code eval | `eval()` allowed in background | `eval()` restricted in service workers |
| Cross-origin fetch from content scripts | Broadly allowed | Blocked by default |
| Cookie scope | Broad domain access possible | Restricted to declared `host_permissions` |

## Key Security Differences

1. Remote Code Execution

Manifest V2 allowed extensions to execute remote code by loading and running scripts from external URLs:

```json
{
 "manifest_version": 2,
 "name": "Insecure Extension",
 "version": "1.0",
 "permissions": ["<all_urls>"],
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["https://malicious-server.com/script.js"]
 }]
}
```

This pattern was widely abused. An extension could appear benign at review time and then pull in malicious code after installation. CDN supply chain attacks allowed legitimate-looking extensions to deliver malware to millions of users.

Manifest V3 eliminates this attack vector by requiring all code to be bundled within the extension package:

```json
{
 "manifest_version": 3,
 "name": "Secure Extension",
 "version": "1.0",
 "permissions": ["activeTab"],
 "host_permissions": ["https://example.com/*"],
 "content_scripts": [{
 "matches": ["https://example.com/*"],
 "js": ["content-script.js"]
 }]
}
```

This change prevents malicious actors from injecting code through compromised CDN domains or man-in-the-middle attacks. The Chrome Web Store review team can now fully evaluate the extension's behavior at submission time because no external code can be loaded at runtime.

One practical impact: if you previously fetched configuration from a remote endpoint and then `eval()`'d it, you will need to redesign your approach. The typical replacement is a structured JSON configuration endpoint that your extension fetches and interprets through normal conditional logic. no dynamic code execution required.

2. Host Permission Granularity

In Manifest V2, requesting broad host permissions like `<all_urls>` or `*://*/*` gave extensions unrestricted access to every website a user visited:

```javascript
// Manifest V2 - Broad access, no user visibility
chrome.webRequest.onBeforeRequest.addListener(
 callback,
 { urls: ["<all_urls>"] }
);
```

Users had no way to understand the scope of this access during installation. The permission dialog showed a generic warning, but many users clicked through without understanding the implications.

Manifest V3 introduces the `host_permissions` field and requires explicit, limited access:

```json
{
 "manifest_version": 3,
 "permissions": ["activeTab", "scripting"],
 "host_permissions": [
 "https://specific-site.com/*",
 "https://another-app.com/*"
 ]
}
```

Users now see permission requests split from installation. Chrome can prompt users to grant host permissions site-by-site after installation, making it clearer what data an extension can access. The `activeTab` permission is a narrower alternative. it grants access only to the currently active tab for the duration of a user gesture, rather than background access to all tabs matching a pattern.

When migrating, audit your actual permission usage. Many V2 extensions requested `<all_urls>` as a convenience even when they only needed access to one or two domains. V3 forces you to be specific, which is both more secure and clearer to users.

3. Background Script Restrictions

Manifest V2 allowed persistent background pages that ran continuously for the entire browser session:

```javascript
// Manifest V2 background.js - Always running, holds state indefinitely
let sessionCache = {};

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 // This code runs even when the user isn't actively using the extension
 sessionCache[sender.tab.id] = request.data;
});

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
 // Monitor every page load on every tab
 if (changeInfo.status === 'complete') {
 analyzePageContent(tab.url);
 }
});
```

A compromised or malicious persistent background page could silently monitor all user activity for the entire browser session, accumulate data, and exfiltrate it without any user-visible action.

Manifest V3 replaces these with service workers that activate only when needed:

```javascript
// Manifest V3 background.js (service_worker) - Event-driven, terminates when idle
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === "processData") {
 // Handle the specific action, then service worker may terminate
 processAndRespond(message.payload).then(result => {
 sendResponse({ success: true, data: result });
 });
 return true; // Keep the message channel open for async response
 }
});

// State that needs to survive service worker termination must use chrome.storage
async function persistState(key, value) {
 await chrome.storage.session.setItem(key, value);
}
```

Service workers terminate when idle (typically after about 30 seconds of inactivity), reducing the attack surface and memory footprint. A key implication for developers: you cannot store state in module-level variables and expect it to persist. All state that needs to survive service worker restarts must go into `chrome.storage.session` or `chrome.storage.local`.

This also means careful management of async operations. The `sendResponse` callback becomes invalid once the service worker terminates, so long-running async operations require either `return true` in the message listener (to keep the channel open) or a different communication pattern using `chrome.runtime.connect` for persistent ports.

4. Declarative Net Request Replaces Web Request

Manifest V2 used the `webRequest` API for network filtering, which allowed extensions to intercept and modify HTTP requests in real-time. This gave extensions full access to request headers, body content, and response data:

```javascript
// Manifest V2 - Can read and modify request bodies
chrome.webRequest.onBeforeRequest.addListener(
 (details) => {
 // Could inspect POST body, read auth headers, modify any request
 if (details.url.includes("track")) {
 return { cancel: true };
 }
 // Could also redirect, modify headers, or read all request data
 },
 { urls: ["<all_urls>"] },
 ["blocking", "requestBody"] // requestBody gives access to POST data
);
```

The `requestBody` flag was particularly dangerous. it gave extensions access to form submissions including passwords, credit card numbers, and any other POST data. A malicious extension could silently harvest credentials from any site.

Manifest V3 requires declarative rulesets, where you specify rules in JSON and the browser engine applies them. the extension never sees the actual request data:

```json
{
 "manifest_version": 3,
 "permissions": ["declarativeNetRequest"],
 "host_permissions": ["<all_urls>"],
 "declarative_net_request": {
 "rule_resources": [{
 "id": "block_trackers",
 "enabled": true,
 "path": "rules.json"
 }]
 }
}
```

```json
[
 {
 "id": 1,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "||doubleclick.net^",
 "resourceTypes": ["script", "image", "xmlhttprequest"]
 }
 },
 {
 "id": 2,
 "priority": 2,
 "action": {
 "type": "modifyHeaders",
 "requestHeaders": [
 { "header": "Referer", "operation": "remove" }
 ]
 },
 "condition": {
 "urlFilter": "||analytics.example.com^",
 "resourceTypes": ["xmlhttprequest"]
 }
 }
]
```

This approach prevents extensions from reading actual request contents, limiting data exposure. The tradeoff is reduced flexibility: you cannot implement rules that depend on the actual content of a request body, only on URL patterns, resource types, and headers.

For extensions with dynamic rule needs (like ad-blockers that update filter lists), use the `updateDynamicRules` API:

```javascript
// Add dynamic rules at runtime (up to 5000 dynamic rules)
await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [{
 id: 100,
 priority: 1,
 action: { type: "block" },
 condition: {
 urlFilter: "||newtracker.example.com^",
 resourceTypes: ["script"]
 }
 }],
 removeRuleIds: [oldRuleId]
});
```

5. Cookie Access Control

Manifest V3 restricts cookie access to specific domains:

```javascript
// Manifest V3 - Cookie access limited to declared host_permissions only
chrome.cookies.get({
 url: "https://specific-domain.com",
 name: "session_token"
}, (cookie) => {
 // Can only access cookies for explicitly declared host_permissions
 // Attempting to access cookies for undeclared domains returns null
 console.log(cookie); // null if domain not in host_permissions
});

// Getting all cookies still requires the "cookies" permission AND host access
chrome.cookies.getAll({
 domain: "specific-domain.com"
}, (cookies) => {
 // Only returns cookies for domains covered by host_permissions
});
```

This prevents extensions from accessing authentication tokens or session data on unrelated domains. A password manager extension that needs cookie access to `yourbank.com` must explicitly declare that domain in `host_permissions`. It cannot silently read cookies from sites the user never intended to grant access to.

6. Content Security Policy Changes

Manifest V3 enforces a stricter default Content Security Policy for extension pages (popup, options, etc.):

```json
// Manifest V3 - Cannot relax script-src to allow unsafe-inline or unsafe-eval
// This is the effective default and cannot be weakened:
// "script-src 'self'; object-src 'self'"

// You CAN add hash-based or nonce-based allowances for specific inline scripts
{
 "content_security_policy": {
 "extension_pages": "script-src 'self' 'sha256-abc123...'; object-src 'self'"
 }
}
```

{% raw %}
Inline JavaScript in extension HTML pages (`onclick="..."`, `<script>` tags without hashes) is blocked by default. All event handlers must be attached programmatically from external `.js` files. This is a common migration problem for older extensions that used inline handlers extensively.

## Migration Strategies

When moving from V2 to V3, a systematic approach prevents regressions:

1. Audit all external script sources. Use `grep -r "http" manifest.json content_scripts/` to find remote script references. Bundle remote scripts or redesign the feature to avoid dynamic code loading.

2. Inventory permissions. List every permission in your V2 manifest and map each one to the feature that requires it. Eliminate any permission not actively used, then separate host-based permissions into the new `host_permissions` field.

3. Convert background page to service worker. Rename `background.html` or `background.js` and update `manifest.json` to use `"service_worker": "background.js"`. Identify all module-level state variables and move them to `chrome.storage.session` for short-lived state or `chrome.storage.local` for persistent state.

4. Rewrite network filters. Map each `webRequest` listener to equivalent declarative rules. For rules that genuinely cannot be expressed declaratively, consider whether the feature is worth maintaining or if an alternative design is possible.

5. Fix inline event handlers. Search all extension HTML files for `onclick`, `onsubmit`, and other inline handlers. Move them to external JS files and attach via `addEventListener`.

6. Test service worker lifecycle. Use Chrome DevTools Service Workers panel to force-terminate your service worker, then verify the extension still works correctly after restart. This catches state management bugs before your users do.

7. Update content script injection. If using `tabs.executeScript`, migrate to `chrome.scripting.executeScript` which has a different API signature and requires the `scripting` permission.

## Performance and Security Trade-offs

The Manifest V3 security model introduces real challenges that developers should plan for. Service workers may have cold start delays of 50-300ms when invoked after being idle. For extensions where latency is critical (like a popup that queries a service on open), this delay is noticeable. The workaround is to keep the service worker alive with a keepalive ping from the popup, though this partially undermines the intended idle-termination behavior.

The declarative net request API is less flexible than the old `webRequest` API for complex filtering rules. Sophisticated ad-blockers and privacy tools that relied on procedural filter matching (checking request content, not just URLs) needed significant redesigns. The maximum rule count (30,000 static + 5,000 dynamic) is sufficient for most use cases but constrains extremely large filter lists.

However, these trade-offs significantly improve user security. The service worker lifecycle ensures background code cannot run indefinitely. The declarative approach means extensions cannot exfiltrate user data through intercepted network requests. For the vast majority of extensions. productivity tools, developer utilities, reading helpers. the V3 constraints are easy to work within and the security benefits are real.

## Additional Security Improvements

Beyond the major changes, Manifest V3 includes several smaller security enhancements worth noting:

Cross-origin fetch restrictions: Content scripts can no longer make cross-origin requests to arbitrary domains. Any external API calls must either go through a background service worker (which has its own host permissions) or be proxied through the page's own fetch capabilities.

eval() restrictions: The `eval()` function, `new Function()`, and `setTimeout` with string arguments are restricted in service workers. Code that previously used these patterns for dynamic dispatch must be refactored to use normal conditional logic or switch statements.

WASM restrictions: WebAssembly execution in extension contexts follows stricter rules, requiring explicitly allowing it in the CSP if needed.

Storage isolation: Extension storage is isolated per extension and cannot be accessed cross-origin. Combined with the explicit permission model, this limits the blast radius of a compromised extension.

These cumulative changes create a defense-in-depth strategy that protects users even when individual extension permissions are granted. No single bypass enables an attacker to do everything a V2 extension could do.

## Real-World Migration Example: A Tab Manager Extension

To illustrate a complete migration, consider a tab manager extension that groups tabs by domain:

```javascript
// V2 approach: persistent background page with module-level state
let tabGroups = {}; // Lives forever

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
 if (changeInfo.status === 'complete') {
 const domain = new URL(tab.url).hostname;
 if (!tabGroups[domain]) tabGroups[domain] = [];
 tabGroups[domain].push(tabId);
 }
});
```

```javascript
// V3 approach: service worker with persistent storage
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
 if (changeInfo.status === 'complete' && tab.url) {
 try {
 const domain = new URL(tab.url).hostname;
 // Load current state from storage (service worker may have been restarted)
 const result = await chrome.storage.session.get('tabGroups');
 const tabGroups = result.tabGroups || {};
 if (!tabGroups[domain]) tabGroups[domain] = [];
 if (!tabGroups[domain].includes(tabId)) {
 tabGroups[domain].push(tabId);
 }
 // Persist back to storage
 await chrome.storage.session.set({ tabGroups });
 } catch (e) {
 // Handle chrome:// and other non-parseable URLs gracefully
 }
 }
});
```

The V3 version is slightly more verbose, but it works correctly across service worker restarts and is more resilient to edge cases.

## Conclusion

Manifest V3's security model shifts the burden from runtime trust to build-time verification. By requiring bundled code, explicit permissions, and event-driven architecture, Google created a more defensive extension platform. Users benefit from reduced attack surface, while developers gain a clearer permission model and improved extension performance.

For developers, the migration requires upfront investment but delivers lasting security improvements. The Chrome Web Store no longer accepts new Manifest V2 extensions, and V2 extensions are losing visibility in the store. The transition is mandatory for any active extension project. the question is no longer whether to migrate, but how quickly you can do it without breaking existing users.

---

---

<div class="mastery-cta">

I've tried them all. Claude Code wins — but only if you set it up right.

The gap isn't the tool. It's the CLAUDE.md, the prompts, the workflow. I run 5 Claude Max subscriptions in parallel with autonomous agent fleets. These are my actual configs — the ones that let a solo dev outproduce a small team.

**[See the full setup →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-compare&utm_campaign=manifest-v3-vs-v2-security)**

$99. Once. Everything I use to ship.

</div>

Related Reading

- [Chrome Extension Canva Alternative: Build Your Own.](/chrome-extension-canva-alternative/)
- [Evernote Web Clipper Alternative for Chrome in 2026: A.](/evernote-web-clipper-alternative-chrome-extension-2026/)
- [MozBar Alternative Chrome Extension 2026: Developer SEO Tools](/mozbar-alternative-chrome-extension-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



{% endraw %}