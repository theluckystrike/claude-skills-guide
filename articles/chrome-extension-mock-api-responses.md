---

layout: default
title: "How to Mock API Responses in Chrome (2026)"
description: "Claude Code guide: how to Mock API Responses in Chrome — practical setup steps, configuration examples, and working code you can use in your projects..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-mock-api-responses/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---



When building Chrome extensions that interact with external APIs, you often need to mock responses during development or testing. Rather than relying on actual API calls or setting up a complex backend, you can intercept network requests directly within your extension. This guide shows you how to mock API responses in Chrome extensions using the declarative NetRequest API and background service workers.

## Why Mock API Responses in Extensions

Mocking API responses offers several advantages. You can test your extension without hitting rate limits or incurring API costs. You can simulate edge cases and error responses that are difficult to reproduce with real APIs. Development becomes faster when you do not depend on external services being available. Additionally, you can create reproducible test scenarios for debugging.

## Using the Declarative NetRequest API

Chrome provides the `declarativeNetRequest` API, which allows you to modify network requests without needing permission to read page content. This API is powerful and works in the background, making it ideal for mocking API responses.

## Step 1: Declare Permissions

First, add the required permissions to your `manifest.json` file:

```json
{
 "name": "API Mocker Extension",
 "version": "1.0",
 "manifest_version": 3,
 "permissions": [
 "declarativeNetRequest"
 ],
 "host_permissions": [
 "*://api.example.com/*"
 ]
}
```

You also need to create a ruleset file that defines your mock responses.

## Step 2: Define Mock Rules

Create a file named `rules.json` in your extension's directory:

```json
{
 "rules": [
 {
 "id": 1,
 "priority": 1,
 "action": {
 "type": "redirect",
 "redirect": {
 "extensionPath": "/mock-data/users.json"
 }
 },
 "condition": {
 "urlFilter": "https://api.example.com/users",
 "resourceTypes": ["xmlhttprequest", "fetch"]
 }
 }
 ]
}
```

This rule intercepts requests to `api.example.com/users` and redirects them to a local JSON file.

## Step 3: Register the Ruleset

In your background service worker, register the ruleset when the extension loads:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 chrome.declarativeNetRequest.updateDynamicRules({
 addRules: [
 {
 id: 1,
 priority: 1,
 action: {
 type: "redirect",
 redirect: { extensionPath: "/mock-data/users.json" }
 },
 condition: {
 urlFilter: "https://api.example.com/users",
 resourceTypes: ["xmlhttprequest", "fetch"]
 }
 }
 ]
 });
});
```

## Creating Mock Response Data

Create a directory named `mock-data` in your extension and add JSON files that mimic the real API responses:

```json
// mock-data/users.json
{
 "users": [
 { "id": 1, "name": "John Doe", "email": "john@example.com" },
 { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
 ],
 "total": 2
}
```

For more complex scenarios, you can serve different responses based on request parameters using multiple rules with different priorities.

## Mocking Different Response Types

## Mocking Error Responses

You can simulate error conditions by using the `block` action or serving custom error pages:

```javascript
{
 "rules": [
 {
 "id": 2,
 "priority": 1,
 "action": {
 "type": "redirect",
 "redirect": {
 "extensionPath": "/mock-data/error-500.json"
 }
 },
 "condition": {
 "urlFilter": "https://api.example.com/error-test",
 "resourceTypes": ["xmlhttprequest"]
 }
 }
 ]
}
```

## Mocking Dynamic Responses

For responses that need to vary based on request context, consider combining the NetRequest API with a custom response handler. You can use a redirect to your own extension page that then serves dynamic content:

```javascript
// In your background script
{
 "action": {
 "type": "redirect",
 "redirect": {
 "url": "chrome-extension://" + chrome.runtime.id + "/mock-handler.html?original=" + encodeURIComponent(request.url)
 }
 }
}
```

## Managing Rules Efficiently

As your extension grows, you may need multiple mock rules. Store them in a structured way:

```
/extension
 /mock-rules
 users.json
 products.json
 auth.json
 rules.json
 background.js
```

You can update rules programmatically to switch between mock and live APIs:

```javascript
function enableMocks() {
 chrome.declarativeNetRequest.updateDynamicRules({
 addRules: mockRules,
 removeRuleIds: liveRules.map(r => r.id)
 });
}

function disableMocks() {
 chrome.declarativeNetRequest.updateDynamicRules({
 addRules: liveRules,
 removeRuleIds: mockRules.map(r => r.id)
 });
}
```

## Testing Your Mocks

Use Chrome's developer tools to verify your mocks are working. Open the Network tab in your extension's background service worker context and make API calls. You should see the requests being intercepted and redirected to your mock files.

You can also add logging to verify rules are applied:

```javascript
chrome.declarativeNetRequest.onRuleMatchedDebug.addListener((info) => {
 console.log("Rule matched:", info.rule.ruleId, info.request.url);
});
```

## Toggling Mocks with a Popup UI

For day-to-day development, you want to switch mocks on and off without touching code. Add a simple popup that reads and updates a flag in `chrome.storage.local`:

```javascript
// popup.js
async function loadState() {
 const { mocksEnabled } = await chrome.storage.local.get('mocksEnabled');
 document.getElementById('toggle').checked = !!mocksEnabled;
}

document.getElementById('toggle').addEventListener('change', async (e) => {
 const enabled = e.target.checked;
 await chrome.storage.local.set({ mocksEnabled: enabled });
 // Notify background to swap rule sets
 chrome.runtime.sendMessage({ action: 'setMocks', enabled });
});

loadState();
```

In your background script, listen for that message and call `enableMocks()` or `disableMocks()` as defined earlier. This gives every team member a one-click toggle without requiring a reload or a code change.

## Simulating Network Latency

Real APIs are not instant. If you test exclusively against local JSON files, you may miss bugs that only appear under latency. race conditions, spinner states that never clear, or UI that assumes synchronous behavior. Add artificial delay by routing through a small service worker response handler:

```javascript
// background.js. fetch event approach for extension pages
self.addEventListener('fetch', (event) => {
 if (event.request.url.includes('/mock-data/')) {
 event.respondWith(
 new Promise((resolve) => {
 setTimeout(async () => {
 const response = await fetch(event.request);
 resolve(response);
 }, 800); // simulate 800 ms latency
 })
 );
 }
});
```

You can randomize the delay to simulate unstable connections:

```javascript
const delay = 200 + Math.random() * 1200; // 200–1400 ms
```

This forces your UI to handle slow responses correctly before you ever ship.

## Mocking Authentication Flows

Authentication is one of the trickiest areas to mock. Tokens expire, refresh flows involve multiple sequential requests, and 401 responses must trigger re-auth logic. Set up dedicated mock rule IDs for auth endpoints:

```json
[
 {
 "id": 10,
 "priority": 2,
 "action": {
 "type": "redirect",
 "redirect": { "extensionPath": "/mock-data/auth-success.json" }
 },
 "condition": {
 "urlFilter": "https://api.example.com/auth/token",
 "resourceTypes": ["xmlhttprequest", "fetch"]
 }
 },
 {
 "id": 11,
 "priority": 2,
 "action": {
 "type": "redirect",
 "redirect": { "extensionPath": "/mock-data/auth-expired.json" }
 },
 "condition": {
 "urlFilter": "https://api.example.com/auth/refresh",
 "resourceTypes": ["xmlhttprequest", "fetch"]
 }
 }
]
```

Your `auth-expired.json` returns a 401-equivalent payload so your extension's token refresh logic runs against a realistic scenario. Pair this with the toggle mechanism above to flip between success and failure states without editing files.

## Keeping Mock Data in Sync with Real APIs

The most common failure mode with mocking is drift. the real API changes its response shape and your mocks silently fall behind. Two practices prevent this:

Schema snapshots. Periodically run your extension against the live API, log the responses, and save them as your mock files. A simple Node script run in CI can do this:

```javascript
// scripts/refresh-mocks.js
const endpoints = [
 { path: '/users', file: 'mock-data/users.json' },
 { path: '/products', file: 'mock-data/products.json' }
];

for (const ep of endpoints) {
 const res = await fetch(`https://api.example.com${ep.path}`, { headers: authHeaders });
 const data = await res.json();
 fs.writeFileSync(ep.file, JSON.stringify(data, null, 2));
}
```

Contract tests. After generating content, a real API call should produce a response whose keys are a superset of what your mock provides. Any key your extension reads but your mock does not include is a bug waiting to surface in production.

## Performance Considerations

The declarative NetRequest API processes rules efficiently, but keep these tips in mind. Limit the number of rules to avoid memory overhead. Use specific URL filters rather than broad patterns. Remove unused rules when they are no longer needed.

Rule IDs must be unique integers. Using a numbering convention. 1xx for user endpoints, 2xx for auth, 3xx for error scenarios. makes large rule sets easier to manage and debug without collisions.

## Conclusion

Mocking API responses in Chrome extensions is straightforward with the declarative NetRequest API. By defining rules in your manifest and background scripts, you can intercept network requests and serve custom responses without complex backend setup. This approach accelerates development, improves testing, and gives you full control over your extension's API interactions.

Start with simple redirects to local JSON files, then layer in latency simulation, toggle UI, and auth-flow mocks as your extension grows in complexity. The investment pays off the first time you catch a race condition in local testing that would have been a production bug.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-mock-api-responses)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [How to Make Claude Code Generate Consistent API Responses](/how-to-make-claude-code-generate-consistent-api-responses/)
- [Best AI Chrome Extensions 2026: A Practical Guide for Developers](/best-ai-chrome-extensions-2026/)
- [Best AI Tools for API Development in 2026: A Practical Guide](/best-ai-tools-for-api-development-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



