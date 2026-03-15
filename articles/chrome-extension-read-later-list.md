---

layout: default
title: "Chrome Extension Read Later List: Building Your Own with Modern APIs"
description: "Learn how to build a Chrome extension for managing a read later list. Covers storage APIs, manifest V3, and practical implementation patterns for developers."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-read-later-list/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


# Chrome Extension Read Later List: Building Your Own with Modern APIs

Creating a "read later" list is one of the most practical projects for learning Chrome extension development. This guide walks you through building a fully functional read later extension using Manifest V3, the Chrome Storage API, and modern JavaScript patterns.

## Why Build Your Own Read Later Extension

Pre-built solutions exist, but building your own offers several advantages. You gain complete control over data storage, synchronization behavior, and UI customization. For developers, this project demonstrates core Chrome extension concepts that apply to nearly any extension type.

The key APIs you'll work with include the `chrome.storage` API for persistence, `chrome.contextMenus` for adding context menu items, and `chrome.tabs` for capturing current page information.

## Project Structure

A Chrome extension requires a specific directory structure. Create these files:

```
read-later-extension/
├── manifest.json
├── background.js
├── popup.html
├── popup.js
├── styles.css
└── icon.png
```

## The Manifest File

Manifest V3 is the current standard. Here's a complete manifest configuration:

```json
{
  "manifest_version": 3,
  "name": "Read Later List",
  "version": "1.0",
  "description": "Save pages to read later with tags and notes",
  "permissions": [
    "storage",
    "contextMenus",
    "tabs"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "background": {
    "service_worker": "background.js"
  }
}
```

The `permissions` array is critical. Without `storage`, you cannot persist saved articles. The `contextMenus` permission enables right-click saving, and `tabs` lets you access page metadata.

## Background Service Worker

The background script runs in the background and handles events like context menu clicks:

```javascript
// background.js
chrome.contextMenus.create({
  id: "saveToReadLater",
  title: "Save to Read Later",
  contexts: ["page", "link"]
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "saveToReadLater") {
    const url = info.linkUrl || info.pageUrl;
    const title = info.pageTitle || "Untitled";
    
    chrome.storage.local.get(["readLaterList"], (result) => {
      const list = result.readLaterList || [];
      list.push({
        id: Date.now(),
        url: url,
        title: title,
        savedAt: new Date().toISOString(),
        tags: [],
        read: false
      });
      
      chrome.storage.local.set({ readLaterList: list }, () => {
        console.log("Article saved:", title);
      });
    });
  }
});
```

This script creates a context menu item that appears when users right-click any page or link. When clicked, it extracts the URL and title, then saves them to Chrome's local storage.

## Popup Interface

The popup provides the user interface for viewing and managing saved articles:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    <h2>Read Later List</h2>
    <div id="articleList"></div>
    <div class="controls">
      <button id="clearAll">Clear All</button>
    </div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

Keep the popup minimal. It loads every time the user clicks the extension icon, so fast performance matters.

## Storage API Patterns

The Chrome Storage API differs from localStorage in important ways. Data persists across browser sessions and can be accessed synchronously within the extension context:

```javascript
// popup.js
document.addEventListener("DOMContentLoaded", () => {
  loadArticles();
});

function loadArticles() {
  chrome.storage.local.get(["readLaterList"], (result) => {
    const articles = result.readLaterList || [];
    const container = document.getElementById("articleList");
    
    if (articles.length === 0) {
      container.innerHTML = "<p class='empty'>No saved articles</p>";
      return;
    }
    
    container.innerHTML = articles.map(article => `
      <div class="article ${article.read ? 'read' : ''}">
        <a href="${article.url}" target="_blank">${article.title}</a>
        <span class="date">${formatDate(article.savedAt)}</span>
        <button class="delete" data-id="${article.id}">×</button>
      </div>
    `).join("");
    
    // Add delete handlers
    container.querySelectorAll(".delete").forEach(btn => {
      btn.addEventListener("click", (e) => {
        deleteArticle(parseInt(e.target.dataset.id));
      });
    });
  });
}

function deleteArticle(id) {
  chrome.storage.local.get(["readLaterList"], (result) => {
    const list = result.readLaterList.filter(item => item.id !== id);
    chrome.storage.local.set({ readLaterList: list }, loadArticles);
  });
}

function formatDate(isoString) {
  return new Date(isoString).toLocaleDateString();
}
```

## Adding Tags and Notes

A basic list is useful, but tags transform it into a powerful organization system:

```javascript
function addTagsToArticle(id, tags) {
  chrome.storage.local.get(["readLaterList"], (result) => {
    const list = result.readLaterList.map(item => {
      if (item.id === id) {
        return { ...item, tags: tags.split(",").map(t => t.trim()) };
      }
      return item;
    });
    chrome.storage.local.set({ readLaterList: list });
  });
}
```

Store tags as an array of strings. This pattern works similarly for adding notes or other metadata.

## Synchronization Across Devices

Chrome's sync storage automatically synchronizes data across all signed-in devices:

```javascript
// Use chrome.storage.sync instead of chrome.storage.local
chrome.storage.sync.set({ readLaterList: list }, () => {
  console.log("Synced across devices");
});
```

Sync storage has a quota of approximately 100KB, suitable for text-based article metadata. For larger collections, implement a custom sync solution using your own backend.

## Best Practices for Production

Validate all URLs before saving to prevent storage pollution:

```javascript
function isValidUrl(string) {
  try {
    new URL(string);
    return true;
  } catch (_) {
    return false;
  }
}
```

Implement error handling for storage quota exceeded:

```javascript
chrome.storage.local.set({ readLaterList: list }, () => {
  if (chrome.runtime.lastError) {
    console.error("Storage error:", chrome.runtime.lastError.message);
  }
});
```

## Loading and Testing

To load your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension directory
4. Pin the extension to your toolbar for quick access

Use the Chrome DevTools for debugging. Right-click your extension icon and select "Inspect popup" to open DevTools directly for that context.

## Summary

Building a read later extension teaches fundamental Chrome extension development concepts. The Storage API provides reliable persistence, context menus enable intuitive interactions, and service workers handle background tasks. These same patterns apply to countless extension types beyond bookmark management.

With this foundation, you can extend functionality with features like reading time estimates, article archiving, or integration with note-taking applications. The Chrome extension platform provides robust APIs for creating sophisticated productivity tools.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
