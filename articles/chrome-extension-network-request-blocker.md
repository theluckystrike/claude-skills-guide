---

layout: default
title: "Chrome Network Request Blocker"
description: "Build a Chrome network request blocker extension using declarativeNetRequest API. Practical code examples for developers and power users. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-network-request-blocker/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

# Chrome Extension Network Request Blocker: A Developer's Guide

Chrome extensions have powerful capabilities when it comes to modifying network behavior. Whether you're building a privacy-focused extension, debugging API calls, or creating developer tools, understanding how to block network requests at the extension level is essential knowledge.

This guide covers the modern approach to blocking network requests in Chrome extensions using the `declarativeNetRequest` API, with practical examples developers can implement immediately. including dynamic user-configurable rules, header modification, and testing strategies.

## Understanding the declarativeNetRequest API

The `declarativeNetRequest` API is Chrome's recommended way to block or modify network requests. Unlike the older `webRequest` API, `declarativeNetRequest` operates declaratively, which means you define rules upfront rather than intercepting each request in real-time. This approach offers better performance and privacy since extension code doesn't need to analyze every single network request.

Here is how the two APIs compare:

| Feature | webRequest (MV2) | declarativeNetRequest (MV3) |
|---------|------------------|-----------------------------|
| Request interception | Real-time in JS | Rule-based, no JS needed |
| Performance | Slower (JS overhead) | Faster (native matching) |
| Privacy | Extension sees all URLs | No URL exposure to JS |
| Dynamic rules | Full JS flexibility | updateDynamicRules API |
| Manifest version | MV2 (deprecated) | MV3 (current standard) |
| Chrome Web Store | Being phased out | Required for new submissions |

Because Chrome is actively phasing out MV2 extensions, any new extension you build for production should target `declarativeNetRequest`. If you are maintaining an older MV2 extension, migration is now a practical requirement rather than a future consideration.

To use this API, your extension needs the appropriate permissions in the manifest:

```json
{
 "manifest_version": 3,
 "name": "Network Request Blocker",
 "version": "1.0",
 "permissions": [
 "declarativeNetRequest",
 "declarativeNetRequestFeedback"
 ],
 "host_permissions": [
 "<all_urls>"
 ]
}
```

The `host_permissions` field specifies which URLs your rules can match. Using `<all_urls>` gives your extension global reach, but you can restrict it to specific domains for more targeted blocking. The `declarativeNetRequestFeedback` permission is optional but required if you want to use `testMatchOutcome` or retrieve matched rule details during debugging.

## Creating Blocking Rules

Rules are defined in a JSON file within your extension's root directory. Here's a basic example that blocks requests to a specific domain:

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

This rule blocks scripts and images from `example-ad-server.com`. The `urlFilter` field supports both plain string matching and regular expressions. To use a regex pattern, set `isUrlFilterCaseSensitive: false` and prefix your pattern with a `/` character, or use the `regexFilter` field directly:

```json
{
 "id": 2,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "regexFilter": ".*\\.ads\\.example\\.com/.*",
 "resourceTypes": ["script", "xmlhttprequest"]
 }
}
```

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

You can define multiple rulesets and enable or disable them at runtime using `chrome.declarativeNetRequest.updateEnabledRulesets()`. This is useful for building extensions with toggleable feature modules. for example, enabling an "aggressive tracking protection" ruleset only when the user opts in.

## Practical Implementation Example

Here is a complete rules file targeting common tracking and ad domains. This is the kind of file you would ship with a privacy-focused extension:

```json
[
 {
 "id": 1,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "googlesyndication.com",
 "resourceTypes": ["script", "sub_frame", "xmlhttprequest"]
 }
 },
 {
 "id": 2,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "google-analytics.com",
 "resourceTypes": ["script", "ping", "xmlhttprequest"]
 }
 },
 {
 "id": 3,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "facebook.com/tr/",
 "resourceTypes": ["image", "script", "ping"]
 }
 },
 {
 "id": 4,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "doubleclick.net",
 "resourceTypes": ["script", "image", "sub_frame"]
 }
 },
 {
 "id": 5,
 "priority": 2,
 "action": { "type": "allow" },
 "condition": {
 "urlFilter": "analytics.yourowndomain.com",
 "resourceTypes": ["script", "xmlhttprequest"]
 }
 }
]
```

Rule 5 shows an important pattern: using an `allow` rule with higher priority to whitelist your own analytics while blocking third-party equivalents. Priority values are integers where higher numbers win. When multiple rules match a request, Chrome applies the one with the highest priority. If priorities are equal, `allow` beats `block`.

## Advanced: Modifying Requests Instead of Blocking

Sometimes you want to modify requests rather than block them entirely. The `declarativeNetRequest` API supports several action types:

- `block`: Prevents the request entirely
- `allow`: Whitelists matching requests, overriding lower-priority block rules
- `redirect`: Sends requests to a different URL
- `removeHeaders`: Strips specific headers from requests or responses
- `modifyHeaders`: Adds, sets, or removes request/response headers
- `allowAllRequests`: Allows all sub-requests for a document, bypassing other rules

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
 "urlFilter": "tracking-pixel.com",
 "resourceTypes": ["image"]
 }
 }
]
```

This approach keeps pages functioning while eliminating privacy-invasive tracking. The referenced file (`/images/pixel-placeholder.png`) must exist in your extension package.

Header modification is equally powerful. Here is a rule that strips the `Referer` header from cross-origin requests, reducing the fingerprinting surface:

```json
[
 {
 "id": 10,
 "priority": 1,
 "action": {
 "type": "modifyHeaders",
 "requestHeaders": [
 {
 "header": "Referer",
 "operation": "remove"
 }
 ]
 },
 "condition": {
 "urlFilter": "*",
 "resourceTypes": ["xmlhttprequest", "script"]
 }
 }
]
```

You can also add headers. useful for developer tools that need to inject an API key or debug flag into every request to a specific domain without modifying page code.

## Dynamic Rules for User Configuration

For extensions that allow users to manage their own blocklist, you need dynamic rules. Unlike static rules defined in the manifest, dynamic rules can be added or removed at runtime:

```javascript
// background.js. add a rule based on user input
async function addBlockRule(domain) {
 const existingRules = await chrome.declarativeNetRequest.getDynamicRules();
 const nextId = existingRules.length
 ? Math.max(...existingRules.map(r => r.id)) + 1
 : 1;

 const rule = {
 id: nextId,
 priority: 1,
 action: { type: 'block' },
 condition: {
 urlFilter: domain,
 resourceTypes: ['script', 'image', 'xmlhttprequest', 'sub_frame']
 }
 };

 await chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [rule]
 });

 return nextId;
}

// Remove a rule by ID
async function removeBlockRule(ruleId) {
 await chrome.declarativeNetRequest.updateDynamicRules({
 removeRuleIds: [ruleId]
 });
}
```

Pair this with Chrome's storage API to persist the user's blocklist across sessions:

```javascript
// Save rule mapping to storage so IDs survive extension restarts
async function saveRuleMapping(domain, ruleId) {
 const { ruleMap = {} } = await chrome.storage.local.get('ruleMap');
 ruleMap[domain] = ruleId;
 await chrome.storage.local.set({ ruleMap });
}

// On extension install or update, restore saved rules
chrome.runtime.onInstalled.addListener(async () => {
 const { ruleMap = {} } = await chrome.storage.local.get('ruleMap');
 const rules = Object.entries(ruleMap).map(([domain, id]) => ({
 id,
 priority: 1,
 action: { type: 'block' },
 condition: { urlFilter: domain, resourceTypes: ['script', 'xmlhttprequest'] }
 }));

 if (rules.length) {
 await chrome.declarativeNetRequest.updateDynamicRules({ addRules: rules });
 }
});
```

Chrome limits dynamic rules to 5,000 per extension. Check your current allocation with `chrome.declarativeNetRequest.getAvailableStaticRuleCount()` and keep track of IDs to avoid collisions.

## Testing Your Extension

When developing network blocking extensions, testing requires attention to detail. Use Chrome's extension management page to reload your extension after each change. For debugging, the `chrome.declarativeNetRequest` API provides helpful methods:

```javascript
// List all currently active dynamic rules
chrome.declarativeNetRequest.getDynamicRules()
 .then(rules => console.log('Active dynamic rules:', rules));

// Test whether a specific URL would be matched
chrome.declarativeNetRequest.testMatchOutcome(
 {
 url: 'https://googlesyndication.com/pagead/js/adsbygoogle.js',
 type: 'script',
 tabId: chrome.tabs.TAB_ID_NONE,
 frameId: 0
 },
 result => {
 if (result.matchedRules.length) {
 console.log('Would be blocked by rule:', result.matchedRules[0].ruleId);
 } else {
 console.log('Request would pass through');
 }
 }
);
```

The `testMatchOutcome` method is particularly useful for verifying your rules match the intended URLs before deploying. It is also helpful for regression testing: write a small test script that calls `testMatchOutcome` for a list of known-bad URLs and asserts they are all matched, running it after any rules change.

For integration testing, load your extension in a Chrome instance with `--load-extension=./path/to/extension`, navigate to a page with known third-party requests, and verify in the Network tab that the expected requests show as blocked (they appear with a red circle icon and status "blocked:extension").

## Performance Considerations

The `declarativeNetRequest` API is optimized for performance, but following best practices ensures your extension remains efficient:

- Prefer static rules: Define rules in your manifest when possible. Static rules are loaded once at startup and matched natively without JavaScript execution.
- Limit dynamic rules: Chrome imposes a quota of 5,000 dynamic rules. Use `chrome.declarativeNetRequest.MAX_NUMBER_OF_DYNAMIC_AND_SESSION_RULES` to check the limit programmatically.
- Use resourceType filters: Only target the request types you need. Blocking all resource types for a domain adds unnecessary overhead. If you only care about stopping tracking pixels, target `image` and `ping` rather than all types.
- Avoid overly broad regex: A pattern like `.*` matching every URL runs against every request in the browser. Narrow your `urlFilter` as much as possible to reduce the matching surface.
- Batch rule updates: When adding or removing multiple dynamic rules, pass all changes in a single `updateDynamicRules` call rather than looping with individual calls. Chrome processes the batch atomically and more efficiently.

## Common Pitfalls to Avoid

Many developers encounter issues when first implementing network blocking. The most frequent problems include:

- Missing host_permissions: Without proper host permissions, rules won't apply to HTTPS sites. If your rules seem to have no effect, check that `<all_urls>` or your target domain pattern is in `host_permissions`.
- Regex complexity: Overly complex regex patterns slow down matching. Chrome enforces a complexity limit on `regexFilter` values and will reject rules that exceed it. Prefer `urlFilter` with plain string patterns where possible.
- Rule priority conflicts: When multiple rules match the same request, the highest priority wins. If an `allow` rule is unexpectedly letting something through, check whether a lower-priority `block` rule exists that it is overriding.
- ID collisions in dynamic rules: Dynamic rule IDs must be unique integers. If you call `updateDynamicRules` with an ID that already exists, the call will fail. Always query existing rules first to determine the next available ID.
- Forgetting to re-enable rulesets after update: If you use `updateEnabledRulesets` and the extension is updated via the Chrome Web Store, verify that your desired rulesets are re-enabled in the `onInstalled` handler with the `"update"` reason check.

Always test thoroughly across different websites since network request patterns vary significantly. A rule targeting `analytics.js` by filename may inadvertently block a legitimate resource on a site that happens to name its own script the same way.

## Building a Complete Extension

Putting it all together, a production-quality network request blocker extension has this structure:

```
my-blocker/
 manifest.json # permissions, ruleset declarations
 background.js # dynamic rule management, storage sync
 popup.html # user interface
 popup.js # add/remove domain UI logic
 rules/
 base-rules.json # static rules shipped with extension
 images/
 pixel-placeholder.png
```

The popup lets users type a domain and click "Block" or "Unblock". The background script handles `chrome.declarativeNetRequest.updateDynamicRules` and persists the list to `chrome.storage.local`. The static `rules.json` covers well-known tracking domains that apply for all users without any configuration.

Building a network request blocker is a straightforward process once you understand the `declarativeNetRequest` API. Whether you're creating a privacy tool, debugging API calls, or developing developer utilities, the declarative approach provides the performance and flexibility needed for production-quality extensions that pass Chrome Web Store review.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-network-request-blocker)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Color Picker Chrome Extension: A Developer's Guide](/ai-color-picker-chrome-extension/)
- [AI Competitive Analysis Chrome Extension: A Developer's Guide](/ai-competitive-analysis-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Understanding the declarativeNetRequest API?

The `declarativeNetRequest` API is Chrome's Manifest V3 replacement for the deprecated `webRequest` API. It operates declaratively through predefined JSON rules rather than real-time JavaScript interception, delivering faster native matching and better privacy since extension code never sees individual URLs. It requires `declarativeNetRequest` and `host_permissions` in the manifest. Chrome is phasing out MV2 extensions, making declarativeNetRequest the required approach for new Chrome Web Store submissions.

### What is Creating Blocking Rules?

Blocking rules are JSON objects defined in a rules file with fields for `id`, `priority`, `action` (block, allow, redirect, modifyHeaders), and `condition` (urlFilter or regexFilter plus resourceTypes). The `urlFilter` field supports plain string matching, while `regexFilter` handles regular expressions. Rules are loaded via the `declarative_net_request.rule_resources` manifest entry. Multiple rulesets can be enabled or disabled at runtime using `chrome.declarativeNetRequest.updateEnabledRulesets()`.

### What are the practical implementation example?

A practical implementation ships a `rules.json` file targeting common tracking domains like `googlesyndication.com`, `google-analytics.com`, `facebook.com/tr/`, and `doubleclick.net`, blocking resource types including `script`, `image`, `sub_frame`, `ping`, and `xmlhttprequest`. An `allow` rule with higher priority whitelists your own analytics domain. Priority is an integer where higher values win; when priorities are equal, `allow` beats `block`. This pattern protects user privacy while preserving first-party analytics.

### What is Advanced: Modifying Requests Instead of Blocking?

Beyond blocking, the declarativeNetRequest API supports `redirect` (sends requests to a different URL or local extension file), `removeHeaders` (strips specific headers), and `modifyHeaders` (adds, sets, or removes request/response headers). Redirecting tracking pixels to a local placeholder image keeps pages functioning while eliminating tracking. Removing the `Referer` header from cross-origin requests reduces fingerprinting. Header addition enables injecting API keys or debug flags into requests to specific domains.

### What is Dynamic Rules for User Configuration?

Dynamic rules allow users to manage their own blocklist at runtime using `chrome.declarativeNetRequest.updateDynamicRules()`. The background script generates unique rule IDs by querying existing rules with `getDynamicRules()`, creates new block rules from user-supplied domains, and persists the domain-to-ID mapping in `chrome.storage.local`. Rules are restored on extension install or update via the `onInstalled` listener. Chrome limits dynamic rules to 5,000 per extension.
