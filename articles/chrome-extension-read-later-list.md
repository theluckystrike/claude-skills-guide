---
render_with_liquid: false
layout: default
title: "Building a Chrome Extension for a Read"
description: "A practical guide for developers to build a Chrome extension that saves articles for later reading, with local storage and browser action integration."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-read-later-list/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
score: 7
reviewed: true
geo_optimized: true
---


Building a Chrome Extension for a Read Later List

A read later list is one of the most useful browser extensions you can build. Whether you're researching a topic, collecting tutorials, or saving articles for weekend reading, having a custom solution gives you full control over your data. This guide walks you through building a functional Chrome extension that saves URLs, titles, and snippets locally.

## Understanding the Architecture

Chrome extensions consist of several components that work together. For a read later list, you'll need:

- manifest.json. The configuration file that tells Chrome about your extension
- popup.html. The interface users see when clicking the extension icon
- popup.js. Handles the logic for adding, displaying, and removing items
- background.js. Optional, for handling events when the popup isn't open

The entire extension can run without a backend server since Chrome provides the `chrome.storage` API for persistent data.

## Setting Up the Manifest

Every extension starts with the manifest file. Here's a minimal configuration for a read later list:

```json
{
 "manifest_version": 3,
 "name": "Read Later List",
 "version": "1.0",
 "description": "Save articles for later reading",
 "permissions": ["storage", "activeTab"],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 }
}
```

The `storage` permission enables the `chrome.storage.local` API, which persists data across browser sessions. The `activeTab` permission lets you access the current page's URL and title when saving.

## Building the Popup Interface

The popup provides the user interface for your extension. Keep it simple and functional:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; padding: 12px; font-family: system-ui; }
 .input-group { display: flex; gap: 8px; margin-bottom: 12px; }
 input { flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
 button { padding: 8px 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
 button:hover { background: #0056b3; }
 ul { list-style: none; padding: 0; margin: 0; }
 li { display: flex; justify-content: space-between; align-items: center; padding: 8px; border-bottom: 1px solid #eee; }
 li:last-child { border-bottom: none; }
 a { color: #007bff; text-decoration: none; font-size: 14px; }
 .delete-btn { background: #dc3545; padding: 4px 8px; font-size: 12px; }
 </style>
</head>
<body>
 <div class="input-group">
 <input type="text" id="urlInput" placeholder="Enter URL">
 <button id="saveBtn">Save</button>
 </div>
 <ul id="list"></ul>
 <script src="popup.js"></script>
</body>
</html>
```

This interface includes an input field for URLs, a save button, and a list that displays saved items. The styling keeps everything compact and usable.

## Implementing the Logic

The JavaScript handles saving, loading, and deleting items. Here's the core implementation:

```javascript
const list = document.getElementById('list');
const urlInput = document.getElementById('urlInput');
const saveBtn = document.getElementById('saveBtn');

// Load saved items on popup open
document.addEventListener('DOMContentLoaded', loadItems);

// Save new item
saveBtn.addEventListener('click', async () => {
 const url = urlInput.value.trim();
 if (!url) return;

 // Get current tab if no URL provided
 if (!url.startsWith('http')) {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 saveItem(tab.url, tab.title);
 } else {
 saveItem(url, url);
 }
 
 urlInput.value = '';
 loadItems();
});

function saveItem(url, title) {
 const item = { id: Date.now(), url, title };
 
 chrome.storage.local.get(['readLaterList'], (result) => {
 const list = result.readLaterList || [];
 list.unshift(item); // Add to beginning
 chrome.storage.local.set({ readLaterList: list });
 });
}

function loadItems() {
 chrome.storage.local.get(['readLaterList'], (result) => {
 const items = result.readLaterList || [];
 list.innerHTML = items.map(item => `
 <li>
 <a href="${item.url}" target="_blank">${item.title}</a>
 <button class="delete-btn" data-id="${item.id}">Delete</button>
 </li>
 `).join('');
 
 // Attach delete handlers
 document.querySelectorAll('.delete-btn').forEach(btn => {
 btn.addEventListener('click', (e) => deleteItem(e.target.dataset.id));
 });
 });
}

function deleteItem(id) {
 chrome.storage.local.get(['readLaterList'], (result) => {
 const list = result.readLaterList || [];
 const filtered = list.filter(item => item.id != id);
 chrome.storage.local.set({ readLaterList: filtered });
 loadItems();
 });
}
```

This script automatically captures the current tab's URL when the input is empty, making it convenient to save pages quickly.

## Auto-Save from Context Menu

Adding a context menu option lets users save pages without opening the popup:

```javascript
// Add to manifest.json permissions: "contextMenus"

// In background.js
chrome.runtime.onInstalled.addListener(() => {
 chrome.contextMenus.create({
 id: 'saveToReadLater',
 title: 'Save to Read Later List',
 contexts: ['page']
 });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
 if (info.menuItemId === 'saveToReadLater') {
 const item = { id: Date.now(), url: tab.url, title: tab.title };
 
 chrome.storage.local.get(['readLaterList'], (result) => {
 const list = result.readLaterList || [];
 list.unshift(item);
 chrome.storage.local.set({ readLaterList: list });
 });
 }
});
```

This creates a right-click menu option that instantly saves the current page to your list.

## Handling Storage Limits

Chrome provides 5MB of local storage by default, which is sufficient for thousands of articles. If you need more or want cloud sync, consider these approaches:

- chrome.storage.sync. Automatically syncs across devices when users are signed into Chrome
- IndexedDB. For structured data or larger content like article previews
- Export/Import. Let users backup their list as JSON

```javascript
// Using sync instead of local
chrome.storage.sync.set({ readLaterList: list }, () => {
 console.log('Data synced across devices');
});
```

## Adding Search Functionality

For power users with large lists, search becomes essential:

```javascript
function searchItems(query) {
 chrome.storage.local.get(['readLaterList'], (result) => {
 const items = result.readLaterList || [];
 const filtered = items.filter(item => 
 item.title.toLowerCase().includes(query.toLowerCase()) ||
 item.url.toLowerCase().includes(query.toLowerCase())
 );
 displayItems(filtered);
 });
}
```

Add an input field in your popup and trigger `searchItems` on input change.

## Loading and Testing Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select your extension folder

Any changes to your files require clicking the reload icon on your extension card.

## Extending the Features

Once the core functionality works, consider adding:

- Markdown parsing. Render article previews from metadata
- Tags and folders. Organize saved articles
- Read status. Mark items as read/unread
- Export options. Generate PDF or HTML archives
- Keyboard shortcuts. Speed up workflow with custom bindings

The Chrome Extensions documentation provides comprehensive APIs for implementing each of these features.

## Conclusion

Building a read later list extension demonstrates fundamental Chrome extension concepts while creating a genuinely useful tool. The combination of storage APIs, popup interfaces, and context menus provides a solid foundation that you can extend based on your needs. Since everything runs locally, users maintain full control over their data without privacy concerns.

Start with the basics outlined here, then iterate based on how you actually use the extension. The best features often emerge from personal workflow requirements.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-read-later-list)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Building a CLI DevTool with Claude Code: A Practical.](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Building AI Coding Culture in Engineering Teams](/building-ai-coding-culture-in-engineering-teams/)
- [Building Apps with Claude API: Anthropic SDK Python Guide](/building-apps-with-claude-api-anthropic-sdk-python-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



