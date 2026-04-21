---

layout: default
title: "Chrome Extension Development for Claude Code Plugins (2026)"
description: "Build Chrome extensions that work in incognito mode using Claude Code. Configuration, API patterns, and testing strategies for Claude Code-generated..."
date: 2026-03-15
last_modified_at: 2026-04-21
last_tested: "2026-04-22"
author: "Claude Skills Guide"
permalink: /chrome-incognito-extensions/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

Chrome's incognito mode provides a privacy-focused browsing session that does not save history, cookies, or site data. However, many users expect their extensions to work smoothly in this mode, and developers need to understand how to handle incognito-specific behavior properly.

This guide covers the technical details of Chrome incognito extensions, including configuration options, API limitations, implementation patterns, and actionable advice for developers and power users alike.

## Building Chrome Extensions with Claude Code

Claude Code excels at generating Chrome extension boilerplate, implementing Manifest V3 service workers, and handling the nuanced incognito mode configurations that trip up many developers. When you ask Claude Code to build a Chrome extension, understanding incognito behavior ensures your generated code works correctly across all browsing modes.

Key advantages of using Claude Code for Chrome extension development:
- Claude Code generates correct `manifest.json` with proper `incognito` field configuration
- It handles the split vs spanning mode decision based on your extension's requirements
- Claude Code writes service worker event handlers that correctly isolate incognito storage
- It generates test scripts that validate extension behavior in both normal and incognito contexts

When prompting Claude Code to build extensions that support incognito mode, include the incognito requirements in your initial prompt to avoid refactoring later.

**Related Claude Code guides:**
- [Claude Code Chrome Extension Manifest V3 Guide](/chrome-extension-development-2026/)
- [Claude Code Testing Automation](/claude-code-shift-left-testing-strategy-guide/)
- Claude Code JavaScript Best Practices

## How Incognito Mode Affects Extensions

When a user opens an incognito window, Chrome applies specific rules to extensions by default:

1. Extensions are disabled unless explicitly allowed by the user
2. Separate storage is used for extension data in incognito contexts
3. Background pages may behave differently depending on manifest version and `incognito` mode setting
4. Some APIs have reduced functionality or require special handling

The default behavior blocks extensions from reading or modifying incognito sessions entirely. Users must manually grant permission for each extension they want active in incognito mode, either during installation or through `chrome://extensions` afterward.

This is intentional from Chrome's perspective. Incognito is meant to be a clean-slate session. Extensions that silently run in incognito and persist data would undermine that expectation. Respecting this design, and being transparent about your extension's incognito behavior, builds user trust.

## The Three Incognito Modes Compared

The `incognito` field in your manifest controls how Chrome handles your extension in private sessions. Understanding the differences is critical before writing any code.

| Mode | Background Context | Storage | When to Use |
|------|--------------------|---------|-------------|
| `spanning` (default) | Single shared service worker for both regular and incognito | Separate storage per context | Most extensions |
| `split` | Separate background context for incognito | Fully isolated | Extensions needing distinct incognito behavior |
| (omitted) | Extension does not run in incognito | N/A | Extensions that must not run in private mode |

The `split` mode was more common in Manifest V2 with persistent background pages. In Manifest V3 with service workers, `split` creates a separate service worker instance for incognito sessions. This is resource-intensive and only worth using when your incognito functionality is fundamentally different from regular mode.

## Configuring Extension Manifest

To support incognito mode, declare the `incognito` field in your manifest. Here is an example for Manifest V3:

```json
{
 "manifest_version": 3,
 "name": "My Privacy Extension",
 "version": "1.0",
 "permissions": [
 "storage",
 "activeTab",
 "scripting"
 ],
 "incognito": "spanning"
}
```

Note that declaring `"incognito": "spanning"` does not automatically enable your extension in incognito, users still must allow it. The manifest field controls what happens once the user has granted access.

If you omit the `incognito` field entirely, Chrome treats it as `spanning` by default in most cases, but it is better to be explicit. Some extension review processes and documentation tools expect to see it declared.

## Enabling Incognito Access. The User Side

From a user's perspective, enabling an extension in incognito mode takes a few steps:

1. Navigate to `chrome://extensions`
2. Find the extension and click "Details"
3. Toggle "Allow in Incognito" to on

Users can also right-click the extension icon in the toolbar and choose "Manage Extension" to reach the same settings. Power users who rely on extensions like ad blockers, password managers, or developer tools in incognito sessions need to do this manually for each extension.

As a developer, you can prompt users with instructions when your popup detects it is not allowed in incognito. You cannot programmatically enable incognito access, that would defeat the privacy model.

## Detecting Incognito Mode in Your Extension

Your extension code can detect whether it is running in an incognito window by checking the tab's `incognito` property:

```javascript
chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
 if (chrome.runtime.lastError) {
 console.error(chrome.runtime.lastError);
 return;
 }

 const currentTab = tabs[0];
 if (currentTab.incognito) {
 console.log("Running in incognito mode");
 // Adjust behavior accordingly
 }
});
```

Use the async/await version for cleaner code in Manifest V3:

```javascript
async function isIncognito() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 return tab?.incognito ?? false;
}
```

Alternatively, check whether the user has granted incognito permission to your extension at all:

```javascript
chrome.extension.isAllowedIncognitoAccess((isAllowed) => {
 if (isAllowed) {
 console.log("Incognito access is enabled");
 } else {
 console.log("Incognito access is disabled - prompt user to enable");
 }
});
```

This second check is useful in your popup to show a helpful message when the user opens your popup in incognito but has not granted access, instead of showing a broken UI, you can show clear instructions to enable it.

## Storage Behavior in Incognito Mode

Storage is one of the most important, and most misunderstood, aspects of incognito extensions. Here is how each storage type behaves:

| Storage API | Incognito Behavior | Notes |
|-------------|-------------------|-------|
| `chrome.storage.local` | Separate storage for incognito context | Data written in incognito is not visible in regular mode and vice versa |
| `chrome.storage.sync` | Data does not sync between regular and incognito | Changes in incognito stay local to that context |
| `chrome.storage.session` | Cleared when the last incognito window closes | Ideal for per-session state that must not persist |
| `localStorage` (web page) | Cleared when incognito session ends | Not accessible from extension background |
| IndexedDB (page context) | Cleared when incognito session ends | Same as localStorage |

The separation of `chrome.storage.local` between regular and incognito contexts catches many developers off guard. A user's saved preferences, authentication tokens, or extension settings in regular mode are not visible when that same extension runs in incognito. You need to decide whether to show default/empty state in incognito, or to read regular-mode settings as a fallback.

Here is a utility function that reads settings with a fallback approach:

```javascript
async function getSettings() {
 // Try incognito-context storage first
 const incognitoSettings = await chrome.storage.local.get('settings');

 if (Object.keys(incognitoSettings).length > 0) {
 return incognitoSettings.settings;
 }

 // Fall back to default settings if nothing is stored for this context
 return {
 theme: 'system',
 notifications: false,
 analyticsEnabled: false,
 };
}
```

## Background Service Workers and Incognito

Manifest V3 uses service workers as background scripts. In incognito mode with `spanning` behavior, the same service worker handles both regular and incognito tabs. You need to check the context when handling events to route logic appropriately:

```javascript
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (sender.tab && sender.tab.incognito) {
 // Handle incognito-specific logic
 handleIncognitoMessage(message, sender, sendResponse);
 } else {
 // Handle regular browsing logic
 handleRegularMessage(message, sender, sendResponse);
 }
 return true; // Keep message channel open for async response
});
```

With `split` behavior, Chrome creates a separate background context for incognito mode, which runs its own instance of your background script. The two instances cannot share in-memory state, communication between them requires using the messaging API or shared storage (which itself is subject to the storage isolation rules described above).

A practical implication of `spanning` mode: if your service worker caches API responses in memory, those cached values are shared across regular and incognito contexts. This is acceptable for non-sensitive data (e.g., a cached list of countries), but unacceptable for user-specific data (e.g., a cached authentication token). Design your in-memory state with this sharing in mind.

## Practical Implementation Patterns

## Pattern 1: Prompt Users to Enable Incognito Access

Rather than showing a broken popup when your extension is not allowed in incognito, detect the situation and guide the user:

```javascript
async function checkIncognitoAccess() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 if (!tab?.incognito) return; // Not in incognito, nothing to check

 chrome.extension.isAllowedIncognitoAccess((isAllowed) => {
 if (!isAllowed) {
 document.getElementById('main-content').style.display = 'none';
 document.getElementById('incognito-prompt').style.display = 'block';
 // Show instructions: go to chrome://extensions > Details > Allow in Incognito
 }
 });
}

document.addEventListener('DOMContentLoaded', checkIncognitoAccess);
```

## Pattern 2: Disable Specific Features in Incognito

Not all features make sense in a privacy context. Analytics, sync, and persistent storage should typically be disabled:

```javascript
function getFeatureFlags(incognito) {
 return {
 analytics: !incognito, // Disable analytics in incognito
 syncData: !incognito, // Disable sync in incognito
 persistentStorage: !incognito, // Use session storage only
 backgroundFetch: !incognito, // Disable background operations
 autoSave: !incognito, // Do not auto-save user data
 };
}

async function initializeExtension() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const flags = getFeatureFlags(tab?.incognito ?? false);

 if (!flags.analytics) {
 disableAnalytics();
 }
 if (!flags.syncData) {
 disableSync();
 }
}
```

This approach makes it easy to audit which features are privacy-sensitive. The feature flags object documents the incognito behavior explicitly, which is useful for code reviews and security audits.

## Pattern 3: Clear Sensitive Data on Incognito Exit

When the last incognito window closes, your extension should clean up any data it wrote during that session:

```javascript
chrome.windows.onRemoved.addListener(async (windowId) => {
 // Check if there are any remaining incognito windows
 const incognitoWindows = await chrome.windows.getAll({ windowTypes: ['normal'] });
 const hasIncognito = incognitoWindows.some(w => w.incognito);

 if (!hasIncognito) {
 // All incognito windows closed. clean up
 await chrome.storage.session.clear();
 console.log('Incognito session data cleared');
 }
});
```

Using `chrome.storage.session` for incognito-specific transient data (rather than `chrome.storage.local`) is even better, since session storage is automatically cleared by Chrome when the incognito session ends, no manual cleanup needed.

## Pattern 4: Visual Indicator for Incognito Mode

Show users clearly when your extension is running in an incognito context, especially when behavior differs:

```javascript
async function updatePopupForContext() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 if (tab?.incognito) {
 document.body.classList.add('incognito-mode');
 document.getElementById('mode-badge').textContent = 'Private Mode';
 document.getElementById('mode-badge').style.display = 'inline';

 // Hide features not available in incognito
 document.querySelectorAll('[data-requires="regular-mode"]').forEach(el => {
 el.style.display = 'none';
 });
 }
}
```

In your CSS, the `.incognito-mode` class can apply a subtle visual treatment (a dark banner, a lock icon, a muted color scheme) that mirrors Chrome's own incognito visual language, making the UI feel coherent with the browser experience.

## Content Scripts in Incognito Mode

Content scripts run on web pages and are subject to the same incognito access restrictions as the rest of your extension. If your extension is allowed in incognito mode, content scripts will execute on incognito tabs as well.

One important consideration: content scripts have access to the DOM and can read page content, including URLs and page text. In incognito mode, users have a heightened expectation that their browsing is private. Content scripts that log page URLs, capture form content, or track user interaction should either be disabled in incognito or ensure that collected data is never persisted.

Here is a content script that checks its own context before doing anything sensitive:

```javascript
// content-script.js
(function() {
 // chrome.tabs is not available in content scripts. use the document URL instead
 // For incognito checks, rely on the background service worker having sent context
 chrome.runtime.sendMessage({ type: 'GET_CONTEXT' }, (response) => {
 if (response?.incognito) {
 // Restrict to read-only, non-logging behavior
 initReadOnly();
 } else {
 initFull();
 }
 });
})();
```

## Manifest V2 vs V3: What Changed for Incognito

Many articles about Chrome incognito extensions reference Manifest V2 patterns. Here is a summary of what changed:

| Feature | Manifest V2 | Manifest V3 |
|---------|-------------|-------------|
| Background context | Persistent background page | Service worker (ephemeral) |
| `split` mode | Two persistent background pages | Two separate service worker instances |
| In-memory state | Persists for the session | is cleared when service worker goes idle |
| `chrome.extension.getBackgroundPage()` | Works for `spanning` to get shared context | Removed; use `chrome.runtime.getBackgroundPage()` as Promise |

The shift to ephemeral service workers in Manifest V3 makes in-memory state sharing between regular and incognito contexts less reliable. Any state that needs to be shared across contexts must use `chrome.storage` rather than module-level variables.

## User Experience Considerations

When designing extensions that work with incognito mode, consider these user experience factors:

Permission Requests: Users see a specific prompt when they first install an extension that supports incognito. Make sure your extension's purpose is clear so users feel comfortable granting access. A password manager asking for incognito access makes intuitive sense; a coupon finder might raise more questions.

Visual Indicators: Add a clear visual indicator in your extension popup when running in incognito mode. Users should immediately understand why certain features are unavailable, rather than assuming the extension is broken.

Onboarding for Incognito: If your extension provides meaningful value in incognito (an ad blocker, for example), proactively suggest that the user enable incognito access during onboarding, but explain why, and let them decline without penalty.

Documentation: Clearly document which features work in incognito mode and which do not. Users deserve transparency about privacy-related behavior. A simple table in your extension's README or Chrome Web Store description goes a long way.

## Common Pitfalls to Avoid

1. Assuming persistent storage: Data in `chrome.storage.session` is cleared when incognito windows close. Data in `chrome.storage.local` is isolated per context. Do not assume a value written in regular mode will be readable in incognito.
2. Ignoring split mode complexity: If using `split` behavior, remember you have two separate extension contexts that cannot share in-memory state. Debug each context independently using separate DevTools instances.
3. Missing error handling: Always check `chrome.runtime.lastError` in callback-based APIs, or handle Promise rejections in async code. Incognito contexts can trigger edge cases that do not appear in regular mode.
4. Blocking incognito entirely without reason: Unless there is a valid security or compliance reason, blocking incognito access creates a poor user experience and may result in negative reviews. Handle incognito gracefully with reduced functionality rather than a hard block.
5. Logging incognito URLs: Never log or transmit URLs, page titles, or user actions from incognito tabs to an external server. This violates user trust and may violate Chrome Web Store policies.
6. Forgetting that `chrome.storage.local` is context-isolated: This is the most common source of "my extension forgot my settings in incognito" bug reports. Default settings should be applied when storage reads return empty results in incognito.

## Testing Incognito Behavior During Development

Testing incognito behavior requires a few specific steps that differ from regular extension development:

1. Load your unpacked extension via `chrome://extensions` with Developer mode enabled
2. Click "Details" on your extension and enable "Allow in Incognito"
3. Open an incognito window with `Ctrl+Shift+N` (or `Cmd+Shift+N` on macOS)
4. Open DevTools for the extension's service worker via `chrome://serviceworker-internals`
5. Use the "Inspect" link next to your extension's service worker to open a DevTools panel

Note that in `spanning` mode, the service worker DevTools panel covers both regular and incognito contexts. You can filter log messages by checking `tab.incognito` in your logging code.

For `split` mode, Chrome creates a second service worker entry in `chrome://serviceworker-internals` with "(incognito)" in the name. Inspect each separately.

## Conclusion

Chrome incognito extensions require thoughtful implementation to provide good user experience while respecting privacy expectations. By properly configuring your manifest, handling storage appropriately, detecting incognito context in your code, and giving users clear feedback about what works in private mode, you can build extensions that work smoothly in both regular and private browsing sessions.

The most important principle is transparency: users who choose incognito mode are making an active choice about their privacy. Your extension should honor that choice by minimizing data collection, clearly communicating limitations, and cleaning up after itself when the private session ends. Extensions that treat incognito as a first-class context, rather than an afterthought, build significantly more user trust and avoid the negative reviews that come from surprising privacy-related behavior.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-incognito-extensions)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best AI Chrome Extensions 2026: A Practical Guide for Developers](/best-ai-chrome-extensions-2026/)
- [Best Cookie Manager Chrome Extensions for Developers in 2026](/best-cookie-manager-chrome/)
- [Best Developer Chrome Extensions 2026](/best-developer-chrome-extensions-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


