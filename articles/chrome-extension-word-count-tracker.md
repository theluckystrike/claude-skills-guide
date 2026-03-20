---

layout: default
title: "Chrome Extension Word Count Tracker: A Developer Guide"
description: "Learn how to build a word count tracker Chrome extension. Practical code examples, APIs, and implementation patterns for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-word-count-tracker/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
---

{% raw %}
# Chrome Extension Word Count Tracker: A Developer Guide

A word count tracker Chrome extension serves as a practical tool for writers, content creators, and developers who need to monitor text metrics across web pages. Whether you're tracking article length, monitoring character counts in forms, or analyzing content density, building this extension teaches you fundamental Chrome extension development patterns that apply to countless other projects.

This guide walks you through creating a fully functional word count tracker from scratch, covering the manifest configuration, content script implementation, popup UI, and storage mechanisms.

## Understanding the Core Architecture

A word count tracker extension operates through three primary components working in concert. The content script analyzes text on the current page, the popup provides a quick-access interface for viewing statistics, and the background worker handles cross-tab communication and persistent storage.

The manifest file defines which permissions your extension requires and how each component interacts with web pages. For a word count tracker, you'll need `activeTab` permission to access page content and `storage` to save user preferences.

## Setting Up Your Extension

Create a new directory for your extension project and add the manifest file:

```json
{
  "manifest_version": 3,
  "name": "Word Count Tracker",
  "version": "1.0",
  "description": "Track word and character counts on any web page",
  "permissions": ["activeTab", "storage"],
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

This manifest grants your extension access to analyze text on any webpage while maintaining user privacy by requiring the active tab permission.

## Implementing the Content Script

The content script runs within the context of web pages and performs the actual text analysis. Create a `content.js` file that extracts text from page elements:

```javascript
function countWords(text) {
  const cleaned = text.trim();
  if (!cleaned) return 0;
  return cleaned.split(/\s+/).length;
}

function countCharacters(text, includeSpaces = false) {
  if (includeSpaces) {
    return text.length;
  }
  return text.replace(/\s/g, '').length;
}

function analyzePage() {
  const bodyText = document.body.innerText;
  const selection = window.getSelection().toString();
  
  return {
    page: {
      words: countWords(bodyText),
      characters: countCharacters(bodyText),
      charactersNoSpaces: countCharacters(bodyText, false)
    },
    selection: {
      words: countWords(selection),
      characters: countCharacters(selection),
      charactersNoSpaces: countCharacters(selection, false)
    }
  };
}

// Listen for messages from popup or background
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'analyze') {
    const stats = analyzePage();
    sendResponse(stats);
  }
});
```

This content script provides two levels of analysis: full page statistics and selected text statistics. The message listener allows other extension components to request analysis on demand.

## Building the Popup Interface

The popup provides users with quick access to word count data without leaving their current page. Create `popup.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 280px; padding: 16px; font-family: system-ui, sans-serif; }
    h2 { margin: 0 0 12px; font-size: 16px; }
    .stats { display: grid; gap: 8px; }
    .stat-row { display: flex; justify-content: space-between; }
    .label { color: #666; }
    .value { font-weight: 600; }
    .section { margin-top: 16px; padding-top: 12px; border-top: 1px solid #eee; }
    .section-title { font-size: 12px; color: #999; text-transform: uppercase; margin-bottom: 8px; }
  </style>
</head>
<body>
  <h2>Word Count Tracker</h2>
  <div class="stats">
    <div class="stat-row">
      <span class="label">Words</span>
      <span class="value" id="pageWords">-</span>
    </div>
    <div class="stat-row">
      <span class="label">Characters</span>
      <span class="value" id="pageChars">-</span>
    </div>
  </div>
  <div class="section">
    <div class="section-title">Selection</div>
    <div class="stat-row">
      <span class="label">Words</span>
      <span class="value" id="selWords">-</span>
    </div>
    <div class="stat-row">
      <span class="label">Characters</span>
      <span class="value" id="selChars">-</span>
    </div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

Now create the popup JavaScript to communicate with the content script:

```javascript
document.addEventListener('DOMContentLoaded', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'analyze' }, (response) => {
    if (chrome.runtime.lastError) {
      document.getElementById('pageWords').textContent = 'N/A';
      return;
    }
    
    if (response) {
      document.getElementById('pageWords').textContent = response.page.words;
      document.getElementById('pageChars').textContent = response.page.characters;
      document.getElementById('selWords').textContent = response.selection.words;
      document.getElementById('selChars').textContent = response.selection.characters;
    }
  });
});
```

## Adding Persistent Storage

To track word counts over time or save user preferences, leverage the Chrome storage API. Add configuration options for excluding certain elements:

```javascript
// In popup.js - save preferences
async function savePreferences(settings) {
  await chrome.storage.sync.set({ wordCountSettings: settings });
}

// In content.js - apply settings
async function getSettings() {
  return new Promise((resolve) => {
    chrome.storage.sync.get('wordCountSettings', (result) => {
      resolve(result.wordCountSettings || {});
    });
  });
}

async function analyzePage() {
  const settings = await getSettings();
  const excludeSelectors = settings.excludeSelectors || ['script', 'style', 'nav', 'footer'];
  
  // Filter out unwanted elements
  const clone = document.body.cloneNode(true);
  excludeSelectors.forEach(selector => {
    clone.querySelectorAll(selector).forEach(el => el.remove());
  });
  
  const bodyText = clone.innerText;
  // ... rest of analysis
}
```

## Loading and Testing Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" and select your extension directory
4. Visit any webpage and click the extension icon to see word counts

The extension immediately analyzes the current page and displays statistics in the popup. You can also select text on the page to see counts for just that selection.

## Extending the Functionality

Once the core word counting works, consider adding these enhancements:

- **Real-time updates**: Use a MutationObserver to update counts when page content changes dynamically
- **Goals and targets**: Allow users to set word count goals and visualize progress
- **Export functionality**: Save statistics to a CSV file for tracking over time
- **Keyboard shortcut**: Add a command shortcut for quick access
- **Dark mode**: Match the popup styling to system preferences

```javascript
// Real-time monitoring example
const observer = new MutationObserver((mutations) => {
  const stats = analyzePage();
  chrome.runtime.sendMessage({ action: 'updateStats', stats: stats });
});

observer.observe(document.body, {
  childList: true,
  subtree: true,
  characterData: true
});
```

Building a word count tracker teaches you essential Chrome extension development skills that transfer directly to more complex projects. The patterns shown here—content script analysis, popup communication, storage integration, and real-time updates—form the foundation for building productivity tools, accessibility checkers, and data extraction extensions.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
