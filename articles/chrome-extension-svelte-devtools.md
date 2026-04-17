---
layout: default
title: "Svelte Devtools Chrome Extension Guide (2026)"
description: "Learn how to build Chrome extensions with Svelte and use devtools for debugging. Practical examples and code snippets for developers."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-svelte-devtools/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---
Building Chrome extensions with Svelte gives you a powerful combination: Svelte's reactive framework for creating responsive UI, and Chrome's extension APIs for browser functionality. This guide walks you through setting up a Chrome extension with Svelte and using devtools effectively during development.

You'll cover project scaffolding, Manifest V3 configuration, bridging Chrome's async APIs with Svelte stores, and a systematic debugging approach for every extension context, popup, service worker, and content script.

Why Svelte for Chrome Extensions?

Svelte compiles your components to vanilla JavaScript, which means smaller bundle sizes and faster execution, critical when Chrome enforces strict limits on extension package sizes. Unlike React or Vue, Svelte doesn't require a runtime, reducing memory overhead in the browser context.

The reactive nature of Svelte works naturally with Chrome's event-driven API model. When you listen to browser events like `chrome.tabs.onUpdated` or `chrome.runtime.onMessage`, Svelte stores can immediately reflect those changes in your popup or options page UI.

Here's how Svelte compares to other popular frameworks for extension development:

| Framework | Bundle size (min+gz) | Runtime required | Reactive stores | MV3 compatible |
|---|---|---|---|---|
| Svelte | ~5–15KB | No | Yes (built-in) | Yes |
| React + hooks | ~45KB+ | Yes | Via useState/useReducer | Yes |
| Vue 3 | ~33KB+ | Yes | Via ref/reactive | Yes |
| Vanilla JS | ~0KB | No | Manual | Yes |

Svelte's compiled output is closest to vanilla JS in size, which matters when Chrome's extension review process scrutinizes large bundles and when users expect popup UIs to open instantly.

## Project Structure

Before writing code, understand the file layout you're targeting:

```
my-extension/
 public/
 manifest.json
 src/
 popup/
 Popup.svelte
 main.js
 background/
 service-worker.js
 content/
 content.js
 stores/
 tabs.js
 vite.config.js
 package.json
```

This separation keeps each extension context in its own directory. Chrome's Manifest V3 treats each context as an isolated JavaScript environment, the popup, service worker, and content scripts cannot share module state at runtime. Your Svelte stores live in the popup context only; background and content scripts use message passing to communicate with them.

## Setting Up Your Project

Create a new Svelte project using Vite, then configure it for Chrome extension development:

```bash
npm create vite@latest my-extension -- --template svelte
cd my-extension
npm install
```

Install any additional dependencies you'll need for Chrome type definitions:

```bash
npm install --save-dev @types/chrome
```

Modify your `vite.config.js` to output to a Chrome-compatible format:

```javascript
import { defineConfig } from 'vite';
import svelte from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
 plugins: [svelte()],
 build: {
 outDir: 'dist',
 rollupOptions: {
 input: {
 popup: 'index.html',
 },
 output: {
 entryFileNames: 'src/[name].js',
 chunkFileNames: 'src/[name].js',
 assetFileNames: 'src/[name].[ext]'
 }
 }
 },
 base: '.'
});
```

The `base: '.'` setting is critical. Without it, Vite generates absolute asset paths like `/assets/index.js` that Chrome's extension context can't resolve. Relative paths ensure your bundled files load correctly from the extension's own origin.

Create your `manifest.json` in the `public` folder:

```json
{
 "manifest_version": 3,
 "name": "My Svelte Extension",
 "version": "1.0.0",
 "description": "A Chrome extension built with Svelte",
 "action": {
 "default_popup": "index.html",
 "default_title": "Open Extension"
 },
 "background": {
 "service_worker": "src/background/service-worker.js",
 "type": "module"
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["src/content/content.js"]
 }],
 "permissions": ["tabs", "storage"],
 "host_permissions": ["<all_urls>"]
}
```

Build your project with `npm run build`, then load the `dist` folder as an unpacked extension in Chrome's `chrome://extensions` page.

## Connecting DevTools to Your Extension

Chrome provides several devtools pages for debugging extensions. Each context has its own DevTools instance, understanding which one to open is the first skill you need.

## Popup DevTools

When your popup is open, right-click and select Inspect to open DevTools specifically for the popup context. This is where you'll debug your Svelte components, inspect reactive state, and trace event handlers.

A key limitation: the popup DevTools session ends when the popup closes. If you need to keep DevTools open while the popup is visible, pin the popup using the dock-to-left DevTools layout, this prevents the popup from closing when you click away.

Useful popup debugging patterns:

```javascript
// In Popup.svelte - expose store state for DevTools inspection
import { currentTab } from '../stores/tabs.js';

// Make store readable from console: window.__store = currentTab
if (import.meta.env.DEV) {
 window.__store = currentTab;
}
```

With this, you can run `$.__store` in the DevTools console to read current store state without adding permanent logging.

## Background Script Debugging

Navigate to `chrome://extensions` and click the "service worker" link under your extension. This opens DevTools for the background context where `chrome.runtime` listeners operate. Your Svelte app's initialization logic runs here if you're building a full-page extension.

Note that Manifest V3 service workers are ephemeral, Chrome unloads them after 30 seconds of inactivity. This means you cannot rely on in-memory state in the service worker surviving between events. Always persist state you need across events to `chrome.storage.session` or `chrome.storage.local`:

```javascript
// service-worker.js
// BAD: this state is lost when the service worker sleeps
let cachedData = {};

// GOOD: persist to storage instead
async function getCachedData(key) {
 const result = await chrome.storage.session.get(key);
 return result[key] ?? null;
}
```

## Content Script Debugging

Content scripts run in the context of web pages. Set breakpoints in DevTools by navigating to the Sources panel and expanding the "Content Scripts" section. You'll see your bundled content script there alongside the page's own scripts.

Content scripts have a restricted view of the page, they run in an isolated world with access to the DOM but not the page's JavaScript globals. If you're trying to read a variable set by the page, use `chrome.scripting.executeScript` from the popup instead.

## Using Svelte Stores with Chrome APIs

Svelte stores provide an elegant way to bridge Chrome's asynchronous APIs with reactive UI. Here's a pattern for managing tab state:

```javascript
// stores/tabs.js
import { writable } from 'svelte/store';

export const currentTab = writable(null);
export const tabHistory = writable([]);

export function initTabListener() {
 chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
 if (changeInfo.status === 'complete' && tab.active) {
 currentTab.set(tab);
 tabHistory.update(history => [...history.slice(-9), tab]);
 }
 });
}
```

In your Svelte component, use the store to automatically reflect Chrome state:

```svelte
<script>
 import { currentTab, tabHistory, initTabListener } from '../stores/tabs.js';
 import { onMount } from 'svelte';

 onMount(() => {
 initTabListener();
 chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
 currentTab.set(tabs[0]);
 });
 });
</script>

<div class="tab-info">
 <h3>Current Tab</h3>
 <p>{$currentTab?.title || 'No active tab'}</p>
 <p class="url">{$currentTab?.url || ''}</p>
</div>

{#if $tabHistory.length > 1}
 <h4>Recent Tabs</h4>
 <ul>
 {#each $tabHistory.slice(0, -1).reverse() as tab}
 <li>{tab.title}</li>
 {/each}
 </ul>
{/if}

<style>
 .url {
 font-size: 0.8em;
 color: #666;
 word-break: break-all;
 }
</style>
```

## Persisting Store State Across Sessions

A Svelte writable store resets to its initial value every time the popup reopens. For data you want to survive popup close-and-open cycles, write a custom store that syncs with `chrome.storage.local`:

```javascript
// stores/persistent.js
import { writable } from 'svelte/store';

export function persistentWritable(key, initialValue) {
 const store = writable(initialValue);

 // Load from storage on creation
 chrome.storage.local.get(key, (result) => {
 if (result[key] !== undefined) {
 store.set(result[key]);
 }
 });

 // Write to storage on every update
 store.subscribe((value) => {
 chrome.storage.local.set({ [key]: value });
 });

 return store;
}
```

Usage:

```javascript
import { persistentWritable } from '../stores/persistent.js';

// This value survives popup close/reopen
export const userPreferences = persistentWritable('prefs', {
 theme: 'light',
 showHistory: true
});
```

## Debugging Common Issues

## Hot Reload Problems

During development, Chrome caches your extension files. After making changes:

1. Click the reload icon in `chrome://extensions`
2. Close and reopen your popup
3. Check "Allow in incognito" if testing there

For faster iteration, consider using [crxjs/vite-plugin](https://crxjs.dev) which adds hot module replacement support specifically for Chrome extensions, popup and content script changes reload automatically without touching `chrome://extensions`.

## Message Passing Failures

When communication between content scripts and background scripts fails, verify your message structure:

```javascript
// Content script sends message
chrome.runtime.sendMessage({
 type: 'FETCH_DATA',
 payload: { url: window.location.href }
});

// Background script receives
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'FETCH_DATA') {
 // Handle the message
 fetchData(message.payload.url).then(sendResponse);
 return true; // Keep message channel open for async response
 }
});
```

The `return true` is critical for asynchronous responses. Without it, Chrome closes the channel before your async operation completes. This is one of the most common sources of silent failures in extension message passing, the `sendResponse` callback executes successfully, but no one is listening on the other end.

To debug message passing, add logging in both the sender and receiver:

```javascript
// Wrap sendMessage with logging during development
function debugSendMessage(message) {
 console.log('[Extension] Sending:', message);
 return new Promise((resolve) => {
 chrome.runtime.sendMessage(message, (response) => {
 console.log('[Extension] Response:', response);
 resolve(response);
 });
 });
}
```

## State Not Updating

If your Svelte store updates but the UI doesn't reflect changes, verify you're accessing the store with the `$` prefix in your template. This triggers Svelte's subscription mechanism.

```svelte
<!-- WRONG: reads the store object, not its value -->
<p>{currentTab.title}</p>

<!-- CORRECT: subscribes to the store and reads its current value -->
<p>{$currentTab?.title}</p>
```

The distinction matters: `currentTab` is a store object with `subscribe`, `set`, and `update` methods. `$currentTab` is the unwrapped value Svelte automatically subscribes to and unsubscribes from when the component unmounts.

## Content Security Policy Errors

Manifest V3 enforces a strict Content Security Policy that blocks inline scripts and `eval`. If you see CSP errors in the console, check that your Vite build isn't generating inline scripts. Configure Rollup to externalize them:

```javascript
// vite.config.js addition
build: {
 rollupOptions: {
 output: {
 // Prevents inline script injection that violates CSP
 inlineDynamicImports: false
 }
 }
}
```

## Performance Optimization

Chrome extensions have resource limits. Svelte helps by producing minimal JavaScript, but follow these practices:

- Lazy-load non-critical components using Svelte's dynamic imports, if your popup has a settings panel that rarely opens, don't bundle it in the main chunk
- Use `chrome.storage.session` for ephemeral data instead of in-memory variables that get cleared when the service worker sleeps
- Avoid polling. use event listeners instead of `setInterval` for checking state; Chrome will throttle or kill intervals in inactive extension contexts
- Debounce storage writes. if a store updates frequently (e.g., on every keystroke), batch writes to avoid excessive storage API calls:

```javascript
import { debounce } from 'lodash-es';

const debouncedSave = debounce((value) => {
 chrome.storage.local.set({ myKey: value });
}, 500);

myStore.subscribe(debouncedSave);
```

## Building for Production

When ready to publish, create a production build that minimizes bundle size:

```bash
npm run build
```

Vite minifies by default in production mode. Inspect your `dist` folder before submitting, Chrome Web Store reviewers look at your extension's source, and a clean, readable build (even minified) avoids delays.

Checklist before publishing:

- Remove all `console.log` calls or gate them behind `import.meta.env.DEV`
- Audit permissions in `manifest.json`, request only what you actually use
- Test the unpacked `dist` folder in a fresh Chrome profile (no dev flags)
- Verify the popup opens and closes without JavaScript errors
- Check that the service worker registers correctly at `chrome://extensions`

Package your extension for the store:

```bash
Zip the dist folder contents (not the folder itself)
cd dist && zip -r ../my-extension.zip .
```

Submit the zip at the Chrome Web Store Developer Dashboard along with screenshots and a privacy policy if you handle any user data.

## What Svelte Devtools Shows You

The official [Svelte DevTools browser extension](https://chrome.google.com/webstore/detail/svelte-devtools) adds a Svelte panel to Chrome DevTools. When you're building an extension with Svelte, you can install Svelte DevTools alongside your own extension to inspect component trees and store values in real time.

Inside the Svelte panel, you'll see your component hierarchy, the current value of every store, and which props are passed where. This is especially useful when debugging reactive state that's supposed to update in response to Chrome API events, you can watch store values change live as you interact with the browser.

Your extension is now ready for the Chrome Web Store. The combination of Svelte's developer experience and Chrome's powerful APIs enables you to build sophisticated browser tools with minimal overhead.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-svelte-devtools)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome DevTools Console Commands: A Practical Guide for Developers](/chrome-devtools-console-commands/)
- [Chrome DevTools Performance Profiling: A Practical Guide](/chrome-devtools-performance-profiling/)
- [Agentic AI Coding Tools Comparison 2026: A Practical.](/agentic-ai-coding-tools-comparison-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



