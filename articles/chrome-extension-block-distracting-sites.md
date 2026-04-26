---
layout: default
title: "Block Distracting Sites Chrome (2026)"
description: "Learn how to build a chrome extension to block distracting sites using Manifest V3, custom blocklists, and programmatic controls."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-block-distracting-sites/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
Building a chrome extension to block distracting sites gives you granular control over your browsing environment. Unlike generic blockers, a custom solution lets you define exact blocking rules, integrate with your workflow, and extend functionality as needs change. This guide walks through the implementation using Chrome's declarative NetRequest API for Manifest V3 compliance.

## Understanding the Blocking Mechanism

Chrome extensions can block network requests through the `declarativeNetRequest` API, which replaces the older `webRequest` blocking in Manifest V2. This approach is more performant and privacy-conscious since the blocking logic runs in Chrome's network layer rather than in your extension's background script.

The core concept involves defining rules in a JSON file that specify which requests to block, modify, or redirect. Each rule contains conditions (matching patterns) and actions (what to do when matched).

## Project Structure

A minimal chrome extension for blocking distracting sites requires four files:

```
block-distracting-sites/
 manifest.json
 rules.json
 background.js
 popup.html
```

manifest.json Configuration

The manifest declares the necessary permissions and declares the rules file:

```json
{
 "manifest_version": 3,
 "name": "Focus Blocker",
 "version": "1.0",
 "description": "Block distracting sites to improve productivity",
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
 "default_popup": "popup.html"
 }
}
```

The `declarativeNetRequest` permission enables the blocking capability, while `storage` allows saving user preferences. The `host_permissions` with `<all_urls>` lets the extension evaluate requests across all domains.

## Defining Blocking Rules

The rules.json file contains the actual blocking logic. Each rule needs a unique ID and specifies conditions and actions:

```json
{
 "rules": [
 {
 "id": 1,
 "priority": 1,
 "action": {
 "type": "block"
 },
 "condition": {
 "urlFilter": "twitter\\.com",
 "resourceTypes": ["main_frame"]
 }
 },
 {
 "id": 2,
 "priority": 1,
 "action": {
 "type": "block"
 },
 "condition": {
 "urlFilter": "reddit\\.com",
 "resourceTypes": ["main_frame"]
 }
 },
 {
 "id": 3,
 "priority": 1,
 "action": {
 "type": "redirect",
 "redirect": {
 "url": "https://github.com"
 }
 },
 "condition": {
 "urlFilter": "youtube\\.com",
 "resourceTypes": ["main_frame"]
 }
 }
 ]
}
```

This configuration blocks Twitter and Reddit entirely while redirecting YouTube to GitHub. The `urlFilter` uses regex patterns, giving you flexibility in matching domains and paths. The `resourceTypes` array specifies which request types to evaluate, `main_frame` targets top-level page loads.

## Dynamic Rule Management

Static rules work for fixed blocklists, but a truly useful extension needs dynamic management. The background script handles updating rules based on user input:

```javascript
// background.js
const RULE_ID_START = 1000;

// Load saved rules from storage on startup
chrome.storage.local.get(['blocklist', 'enabled'], (result) => {
 if (result.enabled && result.blocklist) {
 updateBlockingRules(result.blocklist);
 }
});

// Function to update blocking rules dynamically
function updateBlockingRules(sites) {
 const rules = sites.map((site, index) => ({
 id: RULE_ID_START + index,
 priority: 1,
 action: { type: 'block' },
 condition: {
 urlFilter: site.replace(/\./g, '\\.'),
 resourceTypes: ['main_frame']
 }
 }));

 chrome.declarativeNetRequest.updateDynamicRules({
 addRules: rules,
 removeRuleIds: rules.map(r => r.id)
 });
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'updateRules') {
 updateBlockingRules(message.sites);
 sendResponse({ success: true });
 }
 return true;
});
```

This script initializes blocking rules from stored preferences and listens for messages to update rules in real-time. The rule IDs start at 1000 to avoid conflicts with any static rules defined in rules.json.

## User Interface with Popup

The popup provides controls for managing the blocklist:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 300px; padding: 16px; font-family: system-ui; }
 textarea { width: 100%; height: 150px; margin-bottom: 12px; }
 button { background: #0066cc; color: white; border: none; padding: 8px 16px; cursor: pointer; }
 .status { margin-top: 12px; color: green; }
 </style>
</head>
<body>
 <h3>Focus Blocker</h3>
 <textarea id="blocklist" placeholder="Enter domains to block (one per line)"></textarea>
 <button id="save">Save Blocklist</button>
 <div id="status" class="status"></div>
 <script src="popup.js"></script>
</body>
</html>
```

The corresponding popup.js handles user interactions:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
 // Load existing blocklist
 chrome.storage.local.get(['blocklist'], (result) => {
 if (result.blocklist) {
 document.getElementById('blocklist').value = result.blocklist.join('\n');
 }
 });

 document.getElementById('save').addEventListener('click', () => {
 const blocklist = document.getElementById('blocklist')
 .value.split('\n')
 .map(s => s.trim())
 .filter(s => s.length > 0);

 chrome.storage.local.set({ blocklist, enabled: true }, () => {
 // Notify background script to update rules
 chrome.runtime.sendMessage({
 action: 'updateRules',
 sites: blocklist
 });

 document.getElementById('status').textContent = 'Saved!';
 setTimeout(() => {
 document.getElementById('status').textContent = '';
 }, 2000);
 });
 });
});
```

## Advanced Features

## Time-Based Blocking

You can extend functionality to block sites only during certain hours:

```javascript
// Schedule blocking during work hours
function checkSchedule() {
 const now = new Date();
 const hour = now.getHours();
 const isWorkHour = hour >= 9 && hour < 17;

 chrome.storage.local.get(['workBlocklist'], (result) => {
 if (isWorkHour && result.workBlocklist) {
 updateBlockingRules(result.workBlocklist);
 } else {
 // Clear rules during non-work hours
 chrome.declarativeNetRequest.updateDynamicRules({
 removeRuleIds: result.workBlocklist.map((_, i) => 1000 + i)
 });
 }
 });
}

// Check every minute
setInterval(checkSchedule, 60000);
```

## Whitelist Mode

Instead of blocking specific sites, implement an allowlist that only permits certain domains:

```javascript
const allowlistRules = sites.map((site, index) => ({
 id: 2000 + index,
 priority: 100,
 action: { type: 'allow' },
 condition: {
 urlFilter: site.replace(/\./g, '\\.'),
 resourceTypes: ['main_frame']
 }
}));

// Block everything else with a lower priority rule
allowlistRules.push({
 id: 2999,
 priority: 1,
 action: { type: 'block' },
 condition: {
 urlFilter: '.*',
 resourceTypes: ['main_frame']
 }
});
```

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Select your extension directory.

Test the blocking by attempting to visit sites in your blocklist. The page should fail to load for blocked domains. Check the extension's service worker logs in the DevTools console for debugging information.

## Limitations and Considerations

The declarativeNetRequest API has constraints to be aware of. You can define up to 50,000 dynamic rules, but Chrome evaluates them in priority order. Regex patterns should be specific to avoid performance impacts. Also note that the API doesn't support blocking WebSocket connections or chrome:// URLs.

For users who need more advanced features like password-protected blocking or detailed analytics, consider integrating a backend service or combining with other APIs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-block-distracting-sites)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [How to Block Chrome from Sending Data to Google](/block-chrome-sending-data-google/)
- [Block WebRTC Leak in Chrome: A Developer's Guide](/block-webrtc-leak-chrome/)
- [How to Block Cryptomining in Chrome: A Developer's Guide](/chrome-block-cryptomining/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Step-by-Step: Building the Distraction Blocker

1. Set up Manifest V3 with `declarativeNetRequest`, `storage`, and `alarms` permissions.
2. Build the blocklist UI: create a popup with an input field to add domains. Store the list in `chrome.storage.local` as `{ blocklist: ["reddit.com", "twitter.com", ...] }`.
3. Generate declarativeNetRequest rules: convert the blocklist to DNR rules that redirect blocked domains to an extension-hosted focus page. Update the ruleset dynamically using `chrome.declarativeNetRequest.updateDynamicRules`.
4. Add focus session scheduling: let users set a focus session duration (25-90 minutes). Start a `chrome.alarms` timer. While the alarm is active, enforce the blocklist; when it fires, temporarily allow access.
5. Track productivity stats: record daily block counts per domain in `chrome.storage.local`. Display a weekly chart in the popup showing which sites consumed the most attempted visit attempts.
6. Add allowlist for exceptions: let users mark specific subpages as allowed even if the root domain is blocked (e.g., block reddit.com but allow reddit.com/r/learnprogramming).

## Dynamic Rule Management

```javascript
// Convert blocklist array to declarativeNetRequest rules
function buildBlockRules(domains) {
 return domains.map((domain, index) => ({
 id: index + 1,
 priority: 1,
 action: {
 type: 'redirect',
 redirect: { extensionPath: '/focus.html' }
 },
 condition: {
 urlFilter: '||' + domain + '^',
 resourceTypes: ['main_frame']
 }
 }));
}

async function updateBlockRules(domains) {
 const existing = await chrome.declarativeNetRequest.getDynamicRules();
 const removeIds = existing.map(r => r.id);
 await chrome.declarativeNetRequest.updateDynamicRules({
 removeRuleIds: removeIds,
 addRules: buildBlockRules(domains)
 });
}
```

## Comparison with Distraction Blockers

| Tool | Scheduling | Stats | Sync | Bypass protection | Cost |
|---|---|---|---|---|---|
| This extension | Yes | Yes | chrome.storage.sync | Build it | Free |
| Freedom | Yes | Yes | Cloud | Strong (kernel-level) | $7.99/mo |
| Cold Turkey | Yes | Limited | No | Very strong | $39 one-time |
| StayFocusd | Basic | No | No | Weak | Free |
| BlockSite | Yes | Basic | Account | Medium | Free/Pro |

The custom extension is most appropriate for developers who want full control over the blocking logic and no subscription fees. Freedom and Cold Turkey are better for users who need strong bypass protection against their own impulses.

## Advanced: Intelligent Block Suggestions

After a week of usage, analyze the domains in the browser history with high visit counts and suggest adding them to the blocklist:

```javascript
async function suggestBlockCandidates() {
 const oneWeekAgo = Date.now() - 7 * 86400000;
 const history = await chrome.history.search({
 text: '', startTime: oneWeekAgo, maxResults: 500
 });

 const domainCounts = {};
 history.forEach(item => {
 const domain = new URL(item.url).hostname;
 domainCounts[domain] = (domainCounts[domain] || 0) + item.visitCount;
 });

 return Object.entries(domainCounts)
 .sort(([, a], [, b]) => b - a)
 .slice(0, 10)
 .map(([domain, count]) => ({ domain, count }));
}
```

## Troubleshooting

declarativeNetRequest rules not blocking all requests: DNR rules match the `main_frame` resource type for full-page navigations. If the blocked site is loaded in an iframe, add `sub_frame` to the `resourceTypes` array as well.

Focus session timer not surviving browser restart: `chrome.alarms` persist across browser restarts. However, `chrome.storage.session` (which you might use to store session state) is cleared on restart. Store the session start time and duration in `chrome.storage.local` instead so the timer can be reconstructed after a restart.

Users bypassing the blocker by using incognito: The extension only runs in incognito if the user has explicitly allowed it in the extensions settings. For self-blocking use cases, consider adding a note in the focus page that the block does not apply in incognito mode.


**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

