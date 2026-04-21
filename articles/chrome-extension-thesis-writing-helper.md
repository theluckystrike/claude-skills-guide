---
layout: default
title: "Build a Thesis Writing Chrome Extension (2026)"
description: "Build a Chrome extension for thesis writing with auto-save, citation management, word count tracking, and reference integration. Full implementation."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: theluckystrike
permalink: /chrome-extension-thesis-writing-helper/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---

# Chrome Extension Thesis Writing Helper

Building a Chrome extension specifically designed for thesis writing addresses the unique challenges researchers face: managing citations, tracking progress across multiple drafts, organizing reference materials, and maintaining consistent formatting. This guide walks you through creating a production-ready Chrome extension that handles these tasks directly in the browser.

Thesis writers spend enormous time context-switching between their writing environment, citation managers, reference databases, and drafts. A well-built Chrome extension can eliminate most of that friction by bringing those tools into the browser itself, right where the writing happens.

## Extension Architecture Overview

A thesis writing helper extension consists of three core components working together. The popup interface provides quick access to common tasks like word counting and citation insertion. Content scripts inject functionality directly into academic websites and word processors. Background scripts handle data persistence and cross-tab synchronization.

Before you start, ensure you have the Chrome Extensions Developer Tools installed and a basic understanding of JavaScript, HTML, and CSS. The manifest V3 format is required for all new extensions.

Here is a quick comparison of how the three components divide responsibilities:

| Component | Runs In | Purpose |
|---|---|---|
| Popup (popup.js) | Extension popup window | UI for user actions: insert citation, view stats, manage refs |
| Content script (content.js) | Page context | Reads/modifies page DOM, detects text areas, shows floating panels |
| Background (background.js) | Service worker | Data persistence, alarms, cross-tab message routing |

Understanding this split is important before writing a single line of code. A common mistake is putting storage logic inside the content script, which can cause data loss when tabs unload.

## Project Setup

Create your extension structure:

```
thesis-helper/
 manifest.json
 popup/
 popup.html
 popup.css
 popup.js
 content/
 content.js
 background/
 background.js
 icons/
 icon16.png
 icon48.png
 icon128.png
```

The manifest.json file defines your extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Thesis Writing Helper",
 "version": "1.0.0",
 "description": "Streamline thesis writing with auto-save, citations, and reference management",
 "permissions": [
 "storage",
 "activeTab",
 "scripting",
 "alarms"
 ],
 "action": {
 "default_popup": "popup/popup.html",
 "default_icon": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content/content.js"]
 }],
 "background": {
 "service_worker": "background/background.js"
 }
}
```

Note the addition of the `alarms` permission. This is important for scheduling reliable auto-saves using `chrome.alarms` instead of `setInterval`, which the Manifest V3 service worker will terminate during idle periods.

## Core Feature Implementation

## Auto-Save and Draft Management

The most critical feature for thesis writers is automatic draft saving. Use Chrome's storage API to persist content periodically:

```javascript
// background.js - Auto-save handler
chrome.storage.local.set({
 [`draft_${Date.now()}`]: {
 content: document.body.innerText,
 url: window.location.href,
 timestamp: new Date().toISOString()
 }
});
```

Implement a debounced save function that triggers after the user stops typing for a specified interval:

```javascript
// content.js - Debounced auto-save
let saveTimeout;

function debounceSave(content) {
 clearTimeout(saveTimeout);
 saveTimeout = setTimeout(() => {
 chrome.runtime.sendMessage({
 type: 'SAVE_DRAFT',
 payload: {
 content,
 url: window.location.href,
 timestamp: Date.now()
 }
 });
 }, 2000); // Save after 2 seconds of inactivity
}
```

In the background service worker, handle the save message and also enforce a draft limit so you do not fill up local storage over a long writing session:

```javascript
// background.js - Draft storage with rotation
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'SAVE_DRAFT') {
 saveDraft(message.payload).then(sendResponse);
 return true; // Keep channel open for async response
 }
});

async function saveDraft(payload) {
 const key = `draft_${payload.timestamp}`;
 await chrome.storage.local.set({ [key]: payload });

 // Enforce 50-draft limit to prevent storage overflow
 const all = await chrome.storage.local.get(null);
 const draftKeys = Object.keys(all)
 .filter(k => k.startsWith('draft_'))
 .sort();

 if (draftKeys.length > 50) {
 const toRemove = draftKeys.slice(0, draftKeys.length - 50);
 await chrome.storage.local.remove(toRemove);
 }

 return { saved: true, key };
}
```

## Word Count and Progress Tracking

Thesis writing requires careful progress monitoring. Create a content script that analyzes text areas and displays live statistics:

```javascript
// content.js - Word count analyzer
function analyzeText(element) {
 const text = element.value || element.innerText;
 const words = text.trim().split(/\s+/).filter(w => w.length > 0);
 const characters = text.length;
 const charactersNoSpaces = text.replace(/\s/g, '').length;
 const paragraphs = text.split(/\n\n+/).filter(p => p.trim().length > 0);

 return {
 words: words.length,
 characters,
 charactersNoSpaces,
 paragraphs: paragraphs.length,
 readingTime: Math.ceil(words.length / 200) // 200 WPM average
 };
}
```

Many thesis writers work with a chapter-level word count goal rather than a single total. Extend the analyzer to support targets:

```javascript
// content.js - Progress toward a word count goal
function progressBar(current, target) {
 const pct = Math.min(100, Math.round((current / target) * 100));
 return {
 percent: pct,
 remaining: Math.max(0, target - current),
 over: Math.max(0, current - target)
 };
}

// Example: show chapter progress in the metrics panel
const target = 8000; // chapter word target
const stats = analyzeText(activeTextArea);
const progress = progressBar(stats.words, target);
console.log(`${stats.words} / ${target} words (${progress.percent}%)`);
```

Display these metrics in a floating panel that users can toggle:

```javascript
// content.js - Floating metrics panel
function createMetricsPanel() {
 const panel = document.createElement('div');
 panel.id = 'thesis-helper-metrics';
 panel.innerHTML = `
 <div class="metric">
 <span class="label">Words:</span>
 <span class="value" id="th-word-count">0</span>
 </div>
 <div class="metric">
 <span class="label">Characters:</span>
 <span class="value" id="th-char-count">0</span>
 </div>
 <div class="metric">
 <span class="label">Reading Time:</span>
 <span class="value" id="th-read-time">0 min</span>
 </div>
 `;
 panel.style.cssText = `
 position: fixed;
 bottom: 20px;
 right: 20px;
 background: #f8f9fa;
 padding: 12px 16px;
 border-radius: 8px;
 box-shadow: 0 2px 10px rgba(0,0,0,0.1);
 font-family: -apple-system, BlinkMacSystemFont, sans-serif;
 font-size: 14px;
 z-index: 999999;
 `;
 document.body.appendChild(panel);
 return panel;
}
```

## Citation Management

Integrate citation insertion using a structured format. Store citation templates that users can customize:

```javascript
// background.js - Citation management
const citationFormats = {
 apa: (author, year, title, source) =>
 `${author} (${year}). ${title}. ${source}.`,
 mla: (author, title, source, year) =>
 `${author}. "${title}." ${source}, ${year}.`,
 chicago: (author, title, source, year) =>
 `${author}. "${title}." ${source} (${year}).`
};

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.type === 'INSERT_CITATION') {
 const { format, data } = request.payload;
 const formatted = citationFormats[format](...Object.values(data));
 sendResponse({ citation: formatted });
 }
 return true;
});
```

Here is how the three main citation styles differ for the same source so you can verify your output:

| Style | Example Output |
|---|---|
| APA | Smith, J. (2023). Deep learning in NLP. Journal of AI Research. |
| MLA | Smith, Jane. "Deep learning in NLP." Journal of AI Research, 2023. |
| Chicago | Smith, Jane. "Deep learning in NLP." Journal of AI Research (2023). |

A popup form that captures author, year, title, and source fields lets users generate any of these on demand without memorizing format rules.

## Reference Library Integration

Build a reference manager that stores and organizes sources. Use Chrome's storage to maintain a searchable database:

```javascript
// background.js - Reference library
class ReferenceLibrary {
 constructor() {
 this.references = [];
 this.load();
 }

 async load() {
 const result = await chrome.storage.local.get('references');
 this.references = result.references || [];
 }

 async add(reference) {
 const id = crypto.randomUUID();
 const entry = { ...reference, id, added: Date.now() };
 this.references.push(entry);
 await chrome.storage.local.set({ references: this.references });
 return entry;
 }

 search(query) {
 const lower = query.toLowerCase();
 return this.references.filter(r =>
 r.title?.toLowerCase().includes(lower) ||
 r.author?.toLowerCase().includes(lower) ||
 r.tags?.some(t => t.toLowerCase().includes(lower))
 );
 }
}
```

You can extend this class with a `remove(id)` and `update(id, changes)` method to handle corrections without rebuilding the entire reference list:

```javascript
async remove(id) {
 this.references = this.references.filter(r => r.id !== id);
 await chrome.storage.local.set({ references: this.references });
}

async update(id, changes) {
 const index = this.references.findIndex(r => r.id === id);
 if (index === -1) return null;
 this.references[index] = { ...this.references[index], ...changes };
 await chrome.storage.local.set({ references: this.references });
 return this.references[index];
}
```

## Detecting the Active Writing Area

One practical challenge is detecting which text element the user is actually typing in. Academic writing happens in a wide range of interfaces: Google Docs, Notion, Overleaf, institutional CMS platforms, and plain textarea elements. A heuristic approach works well:

```javascript
// content.js - Find the most likely active writing area
function findActiveEditor() {
 const focused = document.activeElement;

 // Standard textarea or contenteditable
 if (
 focused &&
 (focused.tagName === 'TEXTAREA' ||
 focused.contentEditable === 'true')
 ) {
 return focused;
 }

 // Google Docs uses a canvas-backed editor with a hidden input
 const docsEditor = document.querySelector('.kix-appview-editor');
 if (docsEditor) return docsEditor;

 // Notion uses a custom contenteditable structure
 const notionEditor = document.querySelector(
 '[data-content-editable-root="true"]'
 );
 if (notionEditor) return notionEditor;

 // Overleaf CodeMirror
 const cmEditor = document.querySelector('.CodeMirror');
 if (cmEditor && cmEditor.CodeMirror) {
 return {
 value: cmEditor.CodeMirror.getValue(),
 _isCodeMirror: true
 };
 }

 return null;
}
```

This detection logic should run on every `focusin` and `input` event so the metrics panel always reflects the right element.

## Loading and Testing Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" and select your extension directory
4. Test each feature by opening a document or academic website

Use Chrome's developer tools to debug content scripts and background service workers. The console output appears in the respective dev tool context. For the background service worker, click the "Inspect views: service worker" link on the extension card in `chrome://extensions/`.

A useful debugging pattern is to add a `__DEBUG__` flag at the top of each script file and wrap verbose logs:

```javascript
const __DEBUG__ = true;

function dbg(...args) {
 if (__DEBUG__) console.log('[ThesisHelper]', ...args);
}

dbg('Content script loaded on', window.location.href);
```

Set `__DEBUG__ = false` before publishing to the Chrome Web Store.

## Storage Limits and What to Watch For

Chrome's `storage.local` allows up to 10 MB by default, which is plenty for citations and short drafts but can fill up if you store full thesis chapters. Keep individual draft saves to summarized snapshots rather than the full document text when possible. The `chrome.storage.sync` API has much tighter limits (100 KB total) but syncs across the user's devices, making it good for preferences and the reference library index but not raw draft content.

| Storage Type | Limit | Best For |
|---|---|---|
| storage.local | 10 MB | Drafts, full reference entries, cached content |
| storage.sync | 100 KB | User preferences, small reference index |
| IndexedDB | Hundreds of MB | Price history, large document archives |

If users write long theses and save frequently, consider compressing content before storing it using the CompressionStream API available in modern Chrome versions.

## Advanced: Cross-Tab Draft Synchronization

Researchers often work across multiple tabs simultaneously. Keep drafts in sync using the `chrome.storage.onChanged` event:

```javascript
chrome.storage.onChanged.addListener((changes, area) => {
 if (area !== 'local') return;
 Object.keys(changes).forEach(key => {
 if (key.startsWith('draft_')) {
 const newDraft = changes[key].newValue;
 if (newDraft && newDraft.url !== window.location.href) {
 showSyncBanner(new Date(newDraft.timestamp).toLocaleTimeString());
 }
 }
 });
});
```

## Comparison with Standalone Writing Tools

| Feature | This Extension | Scrivener | Microsoft Word |
|---|---|---|---|
| Browser-native | Yes | No | Web app only |
| Works in Google Docs | Yes (content script) | No | No |
| Citation management | Custom | Via plugin | Via plugin |
| Auto-save | Yes | Yes | Yes |
| Price | Free (build it) | $59 | Microsoft 365 |

The extension approach is most powerful for researchers who write in browser-based editors like Google Docs, Overleaf, or Notion. it extends these platforms without requiring a separate application.

## Troubleshooting Common Issues

Content script not injecting into Google Docs: Google Docs renders inside an iframe. Add `all_frames: true` to your content script declaration and ensure the `matches` pattern includes `https://docs.google.com/*`.

Auto-save overwriting newer content: Use a monotonic version counter instead of wall time for draft versioning to handle clock drift across devices:

```javascript
async function getNextDraftVersion() {
 const { draftCounter = 0 } = await chrome.storage.local.get('draftCounter');
 const next = draftCounter + 1;
 await chrome.storage.local.set({ draftCounter: next });
 return next;
}
```

Word count panel blocking content: Make the panel draggable and persist its position in `localStorage`:

```javascript
let isDragging = false, dragOffsetX, dragOffsetY;
panel.addEventListener('mousedown', (e) => {
 isDragging = true;
 dragOffsetX = e.clientX - panel.offsetLeft;
 dragOffsetY = e.clientY - panel.offsetTop;
});
document.addEventListener('mousemove', (e) => {
 if (!isDragging) return;
 panel.style.left = e.clientX - dragOffsetX + 'px';
 panel.style.top = e.clientY - dragOffsetY + 'px';
});
document.addEventListener('mouseup', () => {
 isDragging = false;
 localStorage.setItem('panelPos', JSON.stringify({ left: panel.style.left, top: panel.style.top }));
});
```

## Extension Best Practices

When building thesis writing tools, prioritize data reliability above all else. Implement conflict resolution for auto-saved drafts to prevent data loss when users work across multiple devices. Use encryption for sensitive research notes stored in Chrome's sync storage.

Performance matters for extensions that run continuously. Minimize DOM manipulation in content scripts and use `MutationObserver` efficiently to detect content changes without polling. Your extension should remain lightweight even when processing large thesis documents with hundreds of pages.

Use `chrome.alarms` for periodic operations like draft cleanup rather than `setInterval`. The service worker can be terminated at any time by Chrome, and `setInterval` timers do not survive that termination. Alarms persist and will wake the service worker when they fire:

```javascript
// background.js - Reliable periodic cleanup using alarms
chrome.alarms.create('draftCleanup', { periodInMinutes: 60 });

chrome.alarms.onAlarm.addListener((alarm) => {
 if (alarm.name === 'draftCleanup') {
 pruneDrafts();
 }
});
```

This pattern ensures the cleanup runs even if the user leaves the browser idle for hours, which is common during long writing sessions where the researcher steps away from the desk.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-thesis-writing-helper)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI SEO Writing Chrome Extension: A Developer's Guide](/ai-seo-writing-chrome-extension/)
- [AI Spreadsheet Helper Chrome Extension: A Developer's Guide](/ai-spreadsheet-helper-chrome-extension/)
- [AI Study Helper Chrome Extension: A Developer's Guide](/ai-study-helper-chrome-extension/)
- [Chrome Extension Wolfram Alpha Helper](/chrome-extension-wolfram-alpha-helper/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


