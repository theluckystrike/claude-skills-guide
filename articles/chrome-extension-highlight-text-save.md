---
layout: default
title: "How to Build a Chrome Extension to Highlight and Save Text"
description: "Learn to create a Chrome extension that captures highlighted text and saves it for later. Complete implementation guide with code examples."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-highlight-text-save/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
---

# How to Build a Chrome Extension to Highlight and Save Text

Building a Chrome extension that captures highlighted text and stores it for later retrieval is a practical project that teaches you the fundamentals of Chrome's extension APIs. Whether you want to create a research tool, a bookmarking system, or a note-taking assistant, the ability to detect and save text selections forms the foundation for many useful extensions.

This guide walks you through building a complete Chrome extension that detects text highlights, saves them to local storage, and provides a simple interface to manage your saved snippets.

## Understanding the Extension Architecture

Chrome extensions consist of several components that work together. For a highlight-and-save extension, you need:

- **manifest.json**: The configuration file that defines your extension's capabilities
- **background script**: Handles long-running tasks and storage operations
- **content script**: Injected into web pages to detect user interactions
- **popup HTML/JS**: The user interface that displays saved highlights

The communication flow works like this: when a user highlights text on any webpage, the content script detects the selection and sends the highlighted text to the background script, which stores it in Chrome's storage API. The popup then retrieves and displays these saved snippets.

## Creating the Manifest File

Every Chrome extension requires a manifest.json file that declares permissions and defines the extension structure. For our highlight-save extension, we need the `storage` permission to persist saved text and `activeTab` permission to access the current page's content.

```json
{
  "manifest_version": 3,
  "name": "Text Saver",
  "version": "1.0",
  "description": "Highlight and save text from any webpage",
  "permissions": [
    "storage",
    "activeTab"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }]
}
```

This manifest declares version 3 of Chrome's extension API, specifies the background service worker, defines a popup interface, and configures the content script to run on all websites.

## Implementing the Content Script

The content script runs in the context of web pages and detects when users select text. We listen for the `mouseup` event, which fires after the user releases the mouse button following a selection.

```javascript
// content.js
document.addEventListener('mouseup', function(event) {
  const selection = window.getSelection();
  const selectedText = selection.toString().trim();
  
  if (selectedText.length > 0) {
    // Create a notification that text was captured
    showSaveNotification(selectedText);
  }
});

function showSaveNotification(text) {
  // Create a floating button near the selection
  const button = document.createElement('button');
  button.textContent = 'Save';
  button.className = 'save-text-btn';
  button.style.cssText = `
    position: absolute;
    z-index: 999999;
    padding: 6px 12px;
    background: #4285f4;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-family: sans-serif;
    font-size: 12px;
  `;
  
  // Position the button near the selection
  const range = window.getSelection().getRangeAt(0);
  const rect = range.getBoundingClientRect();
  button.style.top = `${window.scrollY + rect.bottom + 5}px`;
  button.style.left = `${window.scrollX + rect.left}px`;
  
  // Handle save action
  button.addEventListener('click', function() {
    chrome.runtime.sendMessage({
      action: 'saveHighlight',
      text: text,
      url: window.location.href,
      title: document.title,
      timestamp: Date.now()
    });
    button.remove();
    alert('Text saved!');
  });
  
  document.body.appendChild(button);
  
  // Remove button if user clicks elsewhere
  setTimeout(() => {
    if (document.body.contains(button)) {
      button.remove();
    }
  }, 3000);
}
```

This script shows a "Save" button near the highlighted text when the user releases the mouse. Clicking the button sends the selected text along with metadata (URL, page title, timestamp) to the background script for storage.

## Building the Background Service Worker

The background script handles storage operations and serves as the bridge between content scripts and the popup interface. Service workers in manifest v3 are event-driven and run independently of any webpage.

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'saveHighlight') {
    const newHighlight = {
      id: Date.now(),
      text: message.text,
      url: message.url,
      title: message.title,
      timestamp: message.timestamp
    };
    
    chrome.storage.local.get(['highlights'], function(result) {
      const highlights = result.highlights || [];
      highlights.unshift(newHighlight); // Add to beginning of array
      chrome.storage.local.set({ highlights: highlights }, function() {
        sendResponse({ success: true, highlight: newHighlight });
      });
    });
    
    return true; // Keep message channel open for async response
  }
  
  if (message.action === 'getHighlights') {
    chrome.storage.local.get(['highlights'], function(result) {
      sendResponse({ highlights: result.highlights || [] });
    });
    return true;
  }
  
  if (message.action === 'deleteHighlight') {
    chrome.storage.local.get(['highlights'], function(result) {
      const highlights = result.highlights || [];
      const filtered = highlights.filter(h => h.id !== message.id);
      chrome.storage.local.set({ highlights: filtered }, function() {
        sendResponse({ success: true });
      });
    });
    return true;
  }
});
```

This background script listens for three message types: saving new highlights, retrieving all saved highlights, and deleting specific highlights. It uses Chrome's local storage API, which persists data even after the browser closes.

## Creating the Popup Interface

The popup provides the user interface for viewing and managing saved text. It appears when clicking the extension icon in the Chrome toolbar.

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 320px; padding: 16px; font-family: sans-serif; }
    h2 { margin-top: 0; font-size: 16px; }
    .highlight-item {
      border-bottom: 1px solid #eee;
      padding: 12px 0;
    }
    .highlight-text {
      font-size: 14px;
      line-height: 1.4;
      margin-bottom: 8px;
    }
    .highlight-meta {
      font-size: 11px;
      color: #666;
    }
    .highlight-url {
      color: #4285f4;
      text-decoration: none;
    }
    .delete-btn {
      background: #d93025;
      color: white;
      border: none;
      padding: 4px 8px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 11px;
      margin-top: 8px;
    }
    .empty-state {
      color: #666;
      text-align: center;
      padding: 20px;
    }
  </style>
</head>
<body>
  <h2>Saved Highlights</h2>
  <div id="highlights-list"></div>
  <script src="popup.js"></script>
</body>
</html>
```

## Managing Highlights in the Popup

The popup JavaScript retrieves saved highlights from storage and renders them in a scrollable list. Each highlight shows the saved text, the source page, and a delete button.

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', function() {
  loadHighlights();
});

function loadHighlights() {
  chrome.runtime.sendMessage({ action: 'getHighlights' }, function(response) {
    const container = document.getElementById('highlights-list');
    const highlights = response.highlights || [];
    
    if (highlights.length === 0) {
      container.innerHTML = '<div class="empty-state">No highlights saved yet. Highlight text on any page and click Save.</div>';
      return;
    }
    
    container.innerHTML = highlights.map(highlight => `
      <div class="highlight-item">
        <div class="highlight-text">${escapeHtml(highlight.text)}</div>
        <div class="highlight-meta">
          <a href="${escapeHtml(highlight.url)}" class="highlight-url" target="_blank">${escapeHtml(highlight.title)}</a>
        </div>
        <button class="delete-btn" data-id="${highlight.id}">Delete</button>
      </div>
    `).join('');
    
    // Attach delete handlers
    container.querySelectorAll('.delete-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        deleteHighlight(parseInt(this.dataset.id));
      });
    });
  });
}

function deleteHighlight(id) {
  chrome.runtime.sendMessage({ action: 'deleteHighlight', id: id }, function() {
    loadHighlights();
  });
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
```

## Loading Your Extension

To test the extension in Chrome, navigate to chrome://extensions/ and enable Developer mode in the top right corner. Click "Load unpacked" and select the folder containing your extension files. The extension icon should appear in your toolbar.

When you highlight text on any webpage, a "Save" button appears near your selection. Click it to store the text, then click the extension icon to view your saved highlights in a list.

## Extending the Functionality

This basic implementation provides a foundation you can build upon. Consider adding features like search functionality to find saved highlights, tags or categories for organization, sync across devices using Chrome's sync storage, export capabilities to save highlights as JSON or Markdown, or keyboard shortcuts for faster text capture.

Chrome's storage API supports both local storage (limited to the device) and sync storage (synchronized across all your Chrome instances where you're signed in). Switching to sync storage requires changing `chrome.storage.local` to `chrome.storage.sync` in your background script.

The highlight detection approach demonstrated here works well for most use cases. For more complex requirements, you might explore the Selection API's finer-grained control over text ranges or implement context menus for additional capture options.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
