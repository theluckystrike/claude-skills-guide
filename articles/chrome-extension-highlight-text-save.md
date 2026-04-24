---

layout: default
title: "Build a Text Highlighter Chrome (2026)"
description: "Build a Chrome extension that highlights and saves text from any page. Covers selection API, IndexedDB storage, tagging, and cross-device sync."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-highlight-text-save/
geo_optimized: true
last_tested: "2026-04-21"
---

# Chrome Extension Highlight Text Save

Text selection and saving is one of the most common workflows for developers and power users. Whether you're researching documentation, collecting code snippets, or gathering references from multiple sources, the ability to highlight text and save it efficiently can significantly improve productivity. This guide explores how Chrome extensions handle text highlighting and saving, with practical implementation details for developers who want to build their own solutions.

## Understanding the Selection API

The foundation of any highlight-and-save functionality lies in the Window.getSelection() API. This browser-native method returns a Selection object representing the text currently highlighted by the user. Here's how to capture selected text in a Chrome extension:

```javascript
// content.js - Runs in the context of web pages
document.addEventListener('mouseup', function(event) {
 const selection = window.getSelection();
 const selectedText = selection.toString().trim();
 
 if (selectedText.length > 0) {
 // Send the selected text to the extension's background script
 chrome.runtime.sendMessage({
 action: 'textSelected',
 text: selectedText,
 pageUrl: window.location.href,
 pageTitle: document.title
 });
 }
});
```

This approach captures text whenever the user releases the mouse button after making a selection. The extension then receives the selected text along with metadata about the source page.

## Implementing Context Menus

Chrome extensions can add items to the browser's context menu, providing a natural way to trigger save actions. Here's how to set this up:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 chrome.contextMenus.create({
 id: 'saveHighlight',
 title: 'Save Highlighted Text',
 contexts: ['selection']
 });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
 if (info.menuItemId === 'saveHighlight') {
 saveToStorage(info.selectionText, tab.url, tab.title);
 }
});

function saveToStorage(text, url, title) {
 const highlight = {
 id: Date.now(),
 text: text,
 url: url,
 title: title,
 timestamp: new Date().toISOString(),
 tags: []
 };
 
 chrome.storage.local.get(['highlights'], function(result) {
 const highlights = result.highlights || [];
 highlights.push(highlight);
 chrome.storage.local.set({ highlights: highlights });
 });
}
```

This implementation creates a context menu option that appears whenever text is selected. When clicked, it saves the highlight to Chrome's local storage with metadata including the source URL, page title, and timestamp.

## Storage Options for Highlights

Chrome extensions offer several storage mechanisms, each with different characteristics:

- chrome.storage.local: Stores data locally with no size limit (within reasonable bounds). Ideal for personal use.
- chrome.storage.sync: Synchronizes data across devices when the user is signed into Chrome. Limited to approximately 100KB.
- IndexedDB: Better for large datasets or when you need complex querying capabilities.

For most highlight-and-save use cases, chrome.storage.local provides the best balance of simplicity and capacity. Here's how to retrieve saved highlights:

```javascript
// popup.js - Runs when the extension popup is opened
document.addEventListener('DOMContentLoaded', function() {
 chrome.storage.local.get(['highlights'], function(result) {
 const highlights = result.highlights || [];
 const container = document.getElementById('highlights-list');
 
 highlights.forEach(function(highlight) {
 const item = document.createElement('div');
 item.className = 'highlight-item';
 item.innerHTML = `
 <p class="highlight-text">${escapeHtml(highlight.text)}</p>
 <p class="highlight-source">
 <a href="${highlight.url}">${highlight.title}</a>
 </p>
 <p class="highlight-date">${new Date(highlight.timestamp).toLocaleDateString()}</p>
 `;
 container.appendChild(item);
 });
 });
});

function escapeHtml(text) {
 const div = document.createElement('div');
 div.textContent = text;
 return div.innerHTML;
}
```

## Adding Search and Organization

Once you've accumulated several highlights, search functionality becomes essential. Here's a practical approach to implementing search:

```javascript
function searchHighlights(query) {
 return new Promise(function(resolve) {
 chrome.storage.local.get(['highlights'], function(result) {
 const highlights = result.highlights || [];
 const lowerQuery = query.toLowerCase();
 
 const matches = highlights.filter(function(h) {
 return h.text.toLowerCase().includes(lowerQuery) ||
 h.title.toLowerCase().includes(lowerQuery);
 });
 
 resolve(matches);
 });
 });
}
```

Adding tags to highlights enables even more powerful organization:

```javascript
function addTag(highlightId, tag) {
 chrome.storage.local.get(['highlights'], function(result) {
 const highlights = result.highlights.map(function(h) {
 if (h.id === highlightId) {
 if (!h.tags.includes(tag)) {
 h.tags.push(tag);
 }
 }
 return h;
 });
 chrome.storage.local.set({ highlights: highlights });
 });
}
```

## Export Functionality

The ability to export highlights in various formats significantly increases their utility. Here's how to implement export to JSON and Markdown:

```javascript
function exportToJSON() {
 chrome.storage.local.get(['highlights'], function(result) {
 const blob = new Blob([JSON.stringify(result.highlights, null, 2)], 
 { type: 'application/json' });
 downloadBlob(blob, 'highlights.json');
 });
}

function exportToMarkdown() {
 chrome.storage.local.get(['highlights'], function(result) {
 const md = result.highlights.map(h => 
 `> ${h.text}\n\nSource: [${h.title}](${h.url})`).join('\n\n---\n\n');
 const blob = new Blob([md], { type: 'text/markdown' });
 downloadBlob(blob, 'highlights.md');
 });
}

function downloadBlob(blob, filename) {
 const url = URL.createObjectURL(blob);
 const a = document.createElement('a');
 a.href = url;
 a.download = filename;
 a.click();
 URL.revokeObjectURL(url);
}
```

## Popular Extensions for Highlight and Save

If you prefer using existing solutions rather than building your own, several quality options are available:

OneNote Web Clipper integrates with Microsoft OneNote, offering solid organization features including notebooks, sections, and tags. The extension can save full pages, selected regions, or just highlighted text.

Evernote Web Clipper provides similar functionality with Evernote's powerful search and organization capabilities. The service supports text recognition in images and excellent cross-platform synchronization.

Raindrop.io serves as a bookmark manager with strong highlighting capabilities. It offers a visual approach to organizing saved content with collections, tags, and a clean reading interface.

Google Keep (via Chrome's built-in features) offers the simplest integration, select text and right-click to save directly to Keep, with automatic synchronization to Android and iOS apps.

## Building Your Own Extension

Creating a custom highlight-and-save extension requires only a few files. Here's the essential structure:

```
highlight-saver/
 manifest.json
 content.js
 background.js
 popup.html
 popup.js
 styles.css
```

The manifest.json defines the extension's permissions and entry points:

```json
{
 "manifest_version": 3,
 "name": "Highlight Saver",
 "version": "1.0",
 "permissions": [
 "storage",
 "contextMenus",
 "activeTab"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content.js"]
 }],
 "action": {
 "default_popup": "popup.html"
 }
}
```

This basic structure provides the foundation for a fully functional highlight-and-save extension. From here, you can add features like keyboard shortcuts, cloud synchronization, highlight formatting, and integration with third-party services.

The Chrome extension platform provides solid APIs for capturing and storing text selections. Whether you need a simple personal tool or a feature-rich solution with cross-device synchronization, the building blocks are readily available and well-documented in Chrome's official extension documentation.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-highlight-text-save)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


