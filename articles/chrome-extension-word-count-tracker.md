---
layout: default
title: "Chrome Extension Word Count Tracker: A Developer's Guide"
description: "Learn how to build and use Chrome extensions for tracking word counts in real-time. Practical examples, code snippets, and implementation guide for developers."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-word-count-tracker/
---

{% raw %}
Building a word count tracker as a Chrome extension is a practical project that teaches you the fundamentals of Chrome extension development while creating a genuinely useful tool for writers, developers, and content creators. This guide walks you through creating a word count tracker extension from scratch, covering the manifest structure, content scripts, popup UI, and real-time text analysis.

## Why Build a Word Count Tracker?

Chrome extensions have access to the DOM of web pages, making them ideal for analyzing text content across any website. Whether you're writing in Google Docs, drafting emails in Gmail, or composing messages in Slack, a word count tracker provides immediate feedback on your writing progress.

The core functionality involves three main components: detecting text input on web pages, calculating word and character counts, and displaying that information in a user-friendly interface. Modern implementations can track these metrics in real-time as users type.

## Project Structure

A Chrome extension requires at minimum three files: the manifest, a background script or service worker, and a popup or content script. For a word count tracker, you'll structure your project like this:

```
word-count-tracker/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
└── styles.css
```

This separation of concerns keeps your code organized and makes debugging easier. Each file handles a specific aspect of the extension's functionality.

## Manifest Configuration

The manifest.json file defines your extension's capabilities and permissions. For a word count tracker that needs to access web page content, you'll request the appropriate permissions:

```json
{
  "manifest_version": 3,
  "name": "Word Count Tracker",
  "version": "1.0",
  "description": "Track word and character counts in real-time across any website",
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

The manifest_version 3 is the current standard for Chrome extensions. Notice we're using the scripting permission instead of the older tabs permission, which provides better security and performance.

## Content Script for Text Detection

The content script runs on every page and detects text input. This is where the real work happens:

```javascript
// content.js
let wordCount = 0;
let charCount = 0;
let isTracking = false;

function countWords(text) {
  const trimmed = text.trim();
  if (trimmed.length === 0) return 0;
  return trimmed.split(/\s+/).filter(word => word.length > 0).length;
}

function countCharacters(text) {
  return text.length;
}

function analyzePage() {
  // Look for common text input areas
  const textAreas = document.querySelectorAll('textarea, [contenteditable="true"]');
  const inputs = document.querySelectorAll('input[type="text"]');
  
  let totalText = '';
  
  textAreas.forEach(el => {
    totalText += ' ' + el.innerText + ' ' + el.value;
  });
  
  inputs.forEach(el => {
    totalText += ' ' + el.value;
  });
  
  wordCount = countWords(totalText);
  charCount = countCharacters(totalText);
  
  // Send update to popup or background
  chrome.runtime.sendMessage({
    type: 'UPDATE_COUNT',
    wordCount,
    charCount
  });
}

// Listen for input changes
document.addEventListener('input', () => {
  analyzePage();
});

// Also listen for dynamic content changes
const observer = new MutationObserver(() => {
  analyzePage();
});

observer.observe(document.body, {
  childList: true,
  subtree: true,
  characterData: true
});
```

This script uses a MutationObserver to detect changes to the page content, ensuring it catches text entered dynamically through JavaScript frameworks or single-page applications.

## Popup Interface

The popup provides the user interface that appears when clicking the extension icon. It receives data from the content script and displays it:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="stats-container">
    <div class="stat-item">
      <span class="stat-label">Words</span>
      <span class="stat-value" id="word-count">0</span>
    </div>
    <div class="stat-item">
      <span class="stat-label">Characters</span>
      <span class="stat-value" id="char-count">0</span>
    </div>
  </div>
  <div class="controls">
    <button id="toggle-tracking">Pause Tracking</button>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

```css
/* styles.css */
body {
  width: 200px;
  padding: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.stats-container {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.stat-item {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 12px;
  color: #666;
  text-transform: uppercase;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

button {
  width: 100%;
  padding: 8px;
  background: #4a90d9;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background: #357abd;
}
```

## Connecting Components with Popup Script

The popup script listens for messages from the content script and updates the display:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
  const wordCountEl = document.getElementById('word-count');
  const charCountEl = document.getElementById('char-count');
  
  chrome.runtime.onMessage.addListener((message) => {
    if (message.type === 'UPDATE_COUNT') {
      wordCountEl.textContent = message.wordCount;
      charCountEl.textContent = message.charCount;
    }
  });
  
  document.getElementById('toggle-tracking').addEventListener('click', function() {
    this.textContent = this.textContent === 'Pause Tracking' 
      ? 'Resume Tracking' 
      : 'Pause Tracking';
  });
});
```

## Testing Your Extension

To test your extension in development:

1. Navigate to chrome://extensions in your browser
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" and select your extension folder
4. The extension icon appears in your toolbar
5. Visit any website with text input and watch the counts update

For debugging, right-click the extension icon and select "Inspect popup" to open Chrome DevTools for your extension. This helps identify JavaScript errors and test your code in real-time.

## Advanced Features to Consider

Once you have the basics working, consider adding these features:

- **Per-element tracking**: Show word counts for individual text areas
- **Reading time estimate**: Calculate based on average reading speed (200-250 words per minute)
- **Session statistics**: Track total words written across browsing sessions
- **Custom dictionaries**: Exclude certain words from counts
- **Keyboard shortcuts**: Quick toggle for enabling or disabling tracking

## Common Pitfalls

Several issues commonly affect word count extensions:

- Shadow DOM elements may not be accessible to content scripts
- Password fields should never be analyzed for privacy
- Some modern web frameworks render content dynamically, requiring additional event listeners
- Cross-origin iframes have limited DOM access

## Conclusion

Building a Chrome extension for word counting demonstrates core concepts that apply to many extension types: DOM manipulation, message passing between components, and creating responsive user interfaces. The architecture shown here scales well for adding features like goal tracking, historical logging, or integration with task management tools.

The extension works immediately on any website with text input, making it immediately useful for your daily workflow. Start with this foundation and customize it to match your specific needs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
