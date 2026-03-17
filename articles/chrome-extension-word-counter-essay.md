---
layout: default
title: "How to Build a Chrome Extension Word Counter for Essay Writing"
description: "Learn how to create a Chrome extension that counts words, characters, and paragraphs in real-time for essay writing. Complete implementation guide for developers."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-word-counter-essay/
---

{% raw %}
Building a Chrome extension for counting words in essays is a practical project that combines JavaScript DOM manipulation, Chrome's extension APIs, and real-time text analysis. This guide walks you through creating a fully functional word counter extension tailored for essay writing workflows.

## Why Build a Custom Word Counter Extension

Pre-built word counters exist, but they often lack the specificity writers need. A custom extension can track:

- Word count and character count
- Paragraph count
- Reading time estimates
- Real-time updates as you type
- Support for specific essay platforms

For developers, this project demonstrates essential Chrome extension concepts including content scripts, popup UI, and message passing between components.

## Project Structure

A Chrome extension requires a manifest file and your source files. Here's the minimal structure:

```
word-counter-extension/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
└── styles.css
```

## Manifest Configuration

The manifest.json defines your extension's capabilities:

```json
{
  "manifest_version": 3,
  "name": "Essay Word Counter",
  "version": "1.0",
  "description": "Real-time word counter for essay writing",
  "permissions": ["activeTab", "scripting"],
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

Manifest V3 is the current standard, replacing the deprecated V2. Note the `content_scripts` array runs on every page matching the pattern, enabling real-time text analysis.

## Content Script for Real-Time Counting

The content script injects into web pages and monitors text input:

```javascript
// content.js
function countText() {
  const selection = window.getSelection().toString();
  const bodyText = document.body.innerText;
  
  // Count words (split by whitespace, filter empty)
  const words = bodyText.trim().split(/\s+/).filter(w => w.length > 0);
  const characters = bodyText.replace(/\s/g, '').length;
  const paragraphs = bodyText.split(/\n\n+/).filter(p => p.trim().length > 0);
  
  // Estimate reading time (average 200 words per minute)
  const readingTime = Math.ceil(words.length / 200);
  
  return {
    words: words.length,
    characters: characters,
    paragraphs: paragraphs.length,
    readingTime: readingTime
  };
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getCounts') {
    const counts = countText();
    sendResponse(counts);
  }
});
```

This script counts words by splitting on whitespace, filters out empty strings, and calculates reading time based on 200 words per minute—a standard reading pace.

## Popup UI Implementation

The popup displays statistics when users click the extension icon:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="stats-container">
    <h2>Essay Stats</h2>
    <div class="stat-item">
      <span class="label">Words:</span>
      <span id="word-count" class="value">-</span>
    </div>
    <div class="stat-item">
      <span class="label">Characters:</span>
      <span id="char-count" class="value">-</span>
    </div>
    <div class="stat-item">
      <span class="label">Paragraphs:</span>
      <span id="para-count" class="value">-</span>
    </div>
    <div class="stat-item">
      <span class="label">Reading Time:</span>
      <span id="read-time" class="value">-</span>
    </div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

## Popup Script for Data Retrieval

The popup script requests counts from the content script:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getCounts' }, (response) => {
    if (response) {
      document.getElementById('word-count').textContent = response.words;
      document.getElementById('char-count').textContent = response.characters;
      document.getElementById('para-count').textContent = response.paragraphs;
      document.getElementById('read-time').textContent = `${response.readingTime} min`;
    } else {
      document.getElementById('word-count').textContent = 'N/A';
    }
  });
});
```

The communication pattern here—sending a message from popup to content script—demonstrates inter-component messaging in Chrome extensions.

## Styling the Popup

Basic styling improves usability:

```css
/* styles.css */
body {
  width: 250px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  padding: 16px;
  margin: 0;
}

.stats-container {
  background: #f9f9f9;
  border-radius: 8px;
  padding: 12px;
}

h2 {
  margin: 0 0 12px;
  font-size: 16px;
  color: #333;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
  border-bottom: 1px solid #eee;
}

.stat-item:last-child {
  border-bottom: none;
}

.label {
  color: #666;
  font-size: 13px;
}

.value {
  font-weight: 600;
  color: #222;
}
```

## Loading and Testing

To test your extension:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension directory
4. Visit any page with text and click your extension icon

The counts should appear instantly. If they show "N/A", the content script may not have loaded—try refreshing the page.

## Advanced Enhancements

Once the basics work, consider adding:

- **Target word count tracking**: Set a goal and show progress
- **Platform-specific rules**: Different limits for different essay submission sites
- **Keyboard shortcut**: Use `chrome.commands` to toggle the popup
- **Local storage**: Remember settings across sessions
- **Dark mode**: Match system preferences for late-night writing sessions

## Common Pitfalls

Several issues commonly trip up developers:

- **Content script not loading**: Ensure `matches` in manifest covers your target URLs
- **Cross-origin restrictions**: Content scripts have limited DOM access on cross-origin frames
- **Performance**: Debounce text analysis if monitoring typing in real-time
- **Manifest version**: Only Manifest V3 extensions are accepted for new publications

## Publishing Your Extension

To share your extension:

1. Create a developer account at the Chrome Web Store
2. Package your extension as a ZIP file
3. Upload and provide store listing details
4. Pay the one-time developer fee ($5)

Your extension can reach millions of users searching for writing tools.

## Conclusion

Building a word counter Chrome extension teaches core extension development concepts while creating a genuinely useful tool for essay writers. The architecture—content scripts for page interaction, popup for display, and message passing between them—forms the foundation for more complex extensions.

The code above provides a working foundation. Customize the counting logic, enhance the UI, and adapt it for specific writing platforms to differentiate your extension in the Chrome Web Store.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
