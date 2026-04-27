---
sitemap: false
layout: default
title: "Development Chrome Extension Guide (2026)"
description: "Claude Code guide: build Chrome extensions in 2026 with Manifest V3, service workers, content scripts, and popup UI. Includes a minimal working example..."
date: 2026-03-20
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [chrome-extension, manifest-v3, javascript, browser-extension, web-development]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /chrome-extension-development-2026/
geo_optimized: true
---
# Chrome Extension Development in 2026: A Practical Manifest V3 Guide

Manifest V2 is gone. Chrome enforced the deadline, and every extension published to the Chrome Web Store now runs under Manifest V3 (MV3). If you built extensions under MV2 or you are starting fresh, this guide gives you a working foundation: architecture, code, and a path to publishing.

## What Changed with Manifest V3

The biggest shift in MV3 is the replacement of persistent background pages with service workers. Under MV2, your background script ran continuously and held state in memory. Under MV3, the service worker starts on demand, handles an event, and terminates. You cannot rely on in-memory globals surviving between events.

Other notable changes:

- `webRequestBlocking` is gone for most extensions (only enterprise policies retain it)
- `declarativeNetRequest` replaces programmatic request blocking
- Remote code execution (`eval`, remote scripts in extension context) is banned
- Content Security Policy is stricter by default

The mental model shift: your background logic is now event-driven and stateless between activations. Use `chrome.storage` for anything that needs to persist.

## The Minimal Working Extension

Here is the smallest useful extension: it reads the current tab's URL and copies it to the clipboard when you click the toolbar icon.

## Directory structure

```
my-extension/
 manifest.json
 background.js
 popup.html
 popup.js
 icons/
 icon16.png
 icon48.png
 icon128.png
```

manifest.json

```json
{
 "manifest_version": 3,
 "name": "Copy Tab URL",
 "version": "1.0.0",
 "description": "Copy the current tab URL to your clipboard",
 "permissions": ["activeTab", "scripting", "clipboardWrite"],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html",
 "default_icon": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
 }
}
```

background.js

```js
// Service workers in MV3 are event-driven.
// This listener fires when the extension is first installed or updated.
chrome.runtime.onInstalled.addListener(() => {
 console.log("Copy Tab URL extension installed.");
});
```

popup.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1.0" />
 <title>Copy URL</title>
 <style>
 body { font-family: sans-serif; padding: 12px; min-width: 200px; }
 button { padding: 8px 16px; cursor: pointer; width: 100%; }
 #status { margin-top: 8px; font-size: 12px; color: green; }
 </style>
</head>
<body>
 <button id="copyBtn">Copy Current URL</button>
 <div id="status"></div>
 <script src="popup.js"></script>
</body>
</html>
```

popup.js

```js
document.getElementById("copyBtn").addEventListener("click", async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 if (!tab?.url) return;

 await navigator.clipboard.writeText(tab.url);

 const status = document.getElementById("status");
 status.textContent = "Copied!";
 setTimeout(() => { status.textContent = ""; }, 1500);
});
```

Load this in Chrome by going to `chrome://extensions`, enabling Developer mode, and clicking Load unpacked. Point it at your `my-extension/` directory.

## Service Workers: What You Need to Know

Since the service worker can be terminated at any time, any state you set on a plain variable is gone on the next activation. The fix is `chrome.storage.local` or `chrome.storage.session`.

```js
// Writing state
await chrome.storage.local.set({ lastCopied: tab.url });

// Reading state
const data = await chrome.storage.local.get("lastCopied");
console.log(data.lastCopied);
```

`chrome.storage.session` (available since Chrome 102) holds data for the lifetime of the browser session and is faster than `local`, but it does not persist across browser restarts. Use it for ephemeral state like rate-limit counters.

## Keeping the service worker alive for long tasks

If you have a long-running task (polling, a chain of async operations), use `chrome.alarms` instead of `setInterval`. Alarms fire the service worker reliably:

```js
// Set up a repeating alarm (fires every 5 minutes)
chrome.alarms.create("pollData", { periodInMinutes: 5 });

chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === "pollData") {
 fetchAndStoreData();
 }
});
```

## Content Scripts

Content scripts run in the context of a web page. They can read and modify the DOM, but they run in an isolated world. they share the DOM but not the JavaScript scope with the page.

```js
// content.js. injected into matching pages
const banner = document.createElement("div");
banner.textContent = "Extension active on this page.";
banner.style.cssText = "position:fixed;top:0;left:0;background:#0070f3;color:#fff;padding:8px;z-index:99999;";
document.body.prepend(banner);
```

Declare content scripts in `manifest.json`:

```json
"content_scripts": [
 {
 "matches": ["https://example.com/*"],
 "js": ["content.js"],
 "run_at": "document_end"
 }
]
```

For dynamic injection (injecting based on user action rather than page match), use `chrome.scripting.executeScript`:

```js
chrome.action.onClicked.addListener(async (tab) => {
 await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 files: ["content.js"]
 });
});
```

## Messaging Between Contexts

Popup, background, and content scripts are separate contexts. Use `chrome.runtime.sendMessage` and `chrome.runtime.onMessage` to pass data between them.

```js
// popup.js. send a message to the background service worker
const response = await chrome.runtime.sendMessage({ type: "GET_DATA" });
console.log(response.data);

// background.js. receive it
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === "GET_DATA") {
 sendResponse({ data: "some result" });
 }
 return true; // required to keep the channel open for async sendResponse
});
```

For content scripts to communicate with the background, the same API works. the `sender` object will include `sender.tab` so you know which tab it came from.

## Publishing to the Chrome Web Store

Once your extension works locally:

1. Zip the extension directory (not the parent folder, the contents): `zip -r my-extension.zip my-extension/`
2. Go to the [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
3. Pay the one-time $5 developer registration fee if you have not already
4. Click New Item, upload the zip
5. Fill in the store listing: description, screenshots (1280x800 or 640x400), at least one icon at 128x128
6. Select a category and set visibility (Public, Unlisted, or Private)
7. Submit for review

Review typically takes 1-3 business days for new items. Updates to existing extensions with small diffs often go through in hours.

## What trips up reviews

- Requesting permissions you do not actually use (reviewers check)
- Missing privacy policy if your extension handles any user data
- Remote code loading (banned under MV3)
- Misleading descriptions or screenshots

## Using Claude Code During Development

Claude Code is genuinely useful for Chrome extension work because the surface area of the Chrome APIs is large and the documentation is scattered. A few patterns that work well:

Generating permission lists. Describe what your extension needs to do and ask Claude which permissions are required. This prevents you from requesting broad permissions that trigger Chrome Web Store review flags or user suspicion.

> My extension needs to: (1) read cookies for the current domain, (2) inject a script into the active tab on button click, and (3) store user preferences locally. What is the minimum set of MV3 permissions I need?

Migrating MV2 code. If you have an older extension with a background page, ask Claude to convert it:

> Here is my background.js from a Manifest V2 extension. Convert it to an MV3 service worker. Flag any places where I relied on persistent state that will break under MV3's event-driven model.

Debugging undefined behavior. The Chrome extension APIs fail silently in many cases. Paste your code and ask: "This `chrome.storage.local.get` call is returning undefined even though I set the key. What are the possible reasons?"

## Common Pitfalls

Service worker scope: Files referenced by the service worker must be at the extension root or a subdirectory you control. You cannot load scripts from external URLs.

CSP violations: Inline event handlers (`onclick="..."`) are blocked. Move all event listeners to JS files.

Storage quotas: `chrome.storage.local` gives you 10 MB by default. For larger needs, request the `unlimitedStorage` permission, but justify it in your store listing.

Popup lifecycle: The popup DOM is destroyed when the popup closes. Do not store important state in popup variables. Persist to `chrome.storage`.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-development-2026)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for gRPC API Development](/claude-code-grpc-api-development-guide/)
- [Open Source Contribution Workflow with Claude Code](/claude-code-open-source-contribution-workflow-guide-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

