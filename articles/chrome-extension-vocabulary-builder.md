---


layout: default
title: "Chrome Extension Vocabulary Builder: A Developer Guide"
description: "Learn how to build a vocabulary builder Chrome extension from scratch. Practical code examples, storage patterns, and APIs for developers and power users."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-vocabulary-builder/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


{% raw %}
# Chrome Extension Vocabulary Builder: A Developer Guide

Building a vocabulary builder Chrome extension is one of the most practical projects you can undertake as a developer. These extensions help users learn new words while browsing, capture unfamiliar terms from web content, and review them using spaced repetition systems. This guide covers the architecture, implementation patterns, and key APIs you'll need to create a fully functional vocabulary builder.

## Core Architecture Overview

A vocabulary builder extension operates across three main components: a content script that captures selected text, a background service worker for managing storage and sync, and a popup interface for reviewing saved words. Understanding how data flows between these components is essential before writing any code.

The most critical design decision is your storage strategy. Chrome provides three primary options: chrome.storage.local for local data, chrome.storage.sync for cross-device synchronization, and IndexedDB for large datasets with complex querying needs. For a vocabulary builder, chrome.storage.sync strikes the right balance between simplicity and functionality.

## Setting Up the Manifest

Every extension begins with the manifest.json file. Here's a minimal configuration for a vocabulary builder:

```json
{
  "manifest_version": 3,
  "name": "Vocabulary Builder",
  "version": "1.0",
  "description": "Capture and learn new words while browsing",
  "permissions": [
    "storage",
    "contextMenus",
    "activeTab"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }],
  "background": {
    "service_worker": "background.js"
  }
}
```

The contextMenus permission enables right-click integration, allowing users to save words directly from the context menu. The activeTab permission lets your content script access the currently selected text without requiring host permissions for every website.

## Capturing Text with Content Scripts

The content script runs on every page and handles text selection. Here's a practical implementation:

```javascript
// content.js
document.addEventListener('mouseup', function(event) {
  const selection = window.getSelection().toString().trim();
  
  if (selection.length > 0 && selection.length < 100) {
    // Store temporarily for the background script
    chrome.runtime.sendMessage({
      type: 'TEXT_SELECTED',
      text: selection,
      url: window.location.href,
      title: document.title
    });
  }
});
```

This script listens for mouseup events and captures selections between 0 and 100 characters. The length constraint prevents accidentally saving entire paragraphs while filtering out single characters.

## Managing Data in the Background

The background service worker acts as the central hub for data management. It receives messages from content scripts and handles storage operations:

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'TEXT_SELECTED') {
    saveWord(message.text, message.url, message.title);
  }
});

async function saveWord(word, sourceUrl, sourceTitle) {
  const result = await chrome.storage.sync.get('vocabulary');
  const vocabulary = result.vocabulary || [];
  
  // Check for duplicates
  const exists = vocabulary.some(entry => entry.word.toLowerCase() === word.toLowerCase());
  
  if (!exists) {
    vocabulary.push({
      word: word,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
      timestamp: Date.now(),
      reviewCount: 0,
      mastery: 0
    });
    
    await chrome.storage.sync.set({ vocabulary });
    
    // Show notification
    chrome.runtime.sendMessage({
      type: 'WORD_SAVED',
      word: word
    });
  }
}
```

This implementation prevents duplicate entries by checking existing words case-insensitively. Each entry stores metadata including the source URL, page title, timestamp, and learning progress metrics.

## Building the Popup Interface

The popup provides the primary interface for reviewing saved words. Here's a functional implementation:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 320px; padding: 16px; font-family: system-ui; }
    .word-list { max-height: 400px; overflow-y: auto; }
    .word-item {
      padding: 12px;
      border-bottom: 1px solid #eee;
      cursor: pointer;
    }
    .word-item:hover { background: #f5f5f5; }
    .word { font-weight: bold; font-size: 16px; }
    .source { font-size: 12px; color: #666; }
    .stats { font-size: 11px; color: #999; margin-top: 4px; }
    .empty { text-align: center; color: #666; padding: 40px; }
  </style>
</head>
<body>
  <h2>Vocabulary Builder</h2>
  <div id="wordList" class="word-list"></div>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const result = await chrome.storage.sync.get('vocabulary');
  const vocabulary = result.vocabulary || [];
  const wordList = document.getElementById('wordList');
  
  if (vocabulary.length === 0) {
    wordList.innerHTML = '<div class="empty">No words saved yet. Select text on any page to save new words.</div>';
    return;
  }
  
  vocabulary.forEach((entry, index) => {
    const item = document.createElement('div');
    item.className = 'word-item';
    item.innerHTML = `
      <div class="word">${entry.word}</div>
      <div class="source">${entry.sourceTitle}</div>
      <div class="stats">Reviewed ${entry.reviewCount} times • Mastery: ${entry.mastery}%</div>
    `;
    
    item.addEventListener('click', () => markAsReviewed(index));
    wordList.appendChild(item);
  });
});

async function markAsReviewed(index) {
  const result = await chrome.storage.sync.get('vocabulary');
  const vocabulary = result.vocabulary || [];
  
  vocabulary[index].reviewCount++;
  vocabulary[index].mastery = Math.min(100, vocabulary[index].mastery + 20);
  
  await chrome.storage.sync.set({ vocabulary });
  location.reload();
}
```

This popup displays all saved words with their review statistics. Clicking a word increments its review count and mastery level, implementing a simple spaced repetition mechanic.

## Adding Context Menu Integration

Context menus provide an alternative save method that's especially useful for mobile users and those who prefer keyboard-driven workflows:

```javascript
// background.js - add to existing code
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'saveWord',
    title: 'Save to Vocabulary',
    contexts: ['selection']
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'saveWord') {
    saveWord(info.selectionText, tab.url, tab.title);
  }
});
```

This creates a right-click menu option that appears whenever text is selected, giving users a clear path to save words without relying on automatic detection.

## Advanced Features to Consider

Once you have the basics working, several enhancements can significantly improve user experience. Dictionary integration via the Dictionary API allows automatic definitions when words are saved. Text-to-speech using the Web Speech API enables pronunciation practice. Export functionality lets users download their vocabulary as CSV or JSON for backup or analysis.

For production extensions, consider adding sync conflict resolution, offline support using the Cache API, and analytics to understand how users interact with your extension.

## Testing and Debugging

Chrome provides excellent developer tools for extension development. Load your unpacked extension via chrome://extensions, enable developer mode, and use the service worker console for logging. The content script console appears in the DevTools of each page where the extension runs.

Always test with real-world content—news articles, academic papers, and technical documentation each present unique challenges for text selection and capture.

---

Building a vocabulary builder extension teaches you fundamental Chrome extension patterns while creating something genuinely useful. The modular architecture separates concerns cleanly, making it easy to add features incrementally. Start with the basics outlined here, then expand based on user feedback and your own learning goals.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
