---

layout: default
title: "Building a Chrome Extension for Standup Meeting Notes"
description: "Learn how to create a Chrome extension to capture, organize, and export your daily standup meeting notes efficiently."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-standup-meeting-notes/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
---


{% raw %}

As developers, we attend daily standups where capturing quick notes can make or break our productivity throughout the day. A well-built Chrome extension for standup meeting notes can transform how you track your progress, blockers, and plans. This guide walks you through building a functional Chrome extension tailored for standup note-taking.

## Why Build a Custom Standup Notes Extension

Most note-taking apps require too many clicks to capture quick updates. Browser-based standup notes should be accessible in seconds. A custom Chrome extension gives you:

- One-click access from your browser toolbar
- Quick-entry fields for yesterday, today, and blockers
- Local storage for offline access
- Export capabilities for documentation

## Project Structure

A Chrome extension requires a manifest file and your source files. Create this directory structure:

```
standup-notes-extension/
├── manifest.json
├── popup.html
├── popup.js
├── popup.css
└── icon.png
```

## The Manifest File

Every Chrome extension starts with `manifest.json`. This file tells Chrome about your extension's capabilities:

```json
{
  "manifest_version": 3,
  "name": "Standup Notes",
  "version": "1.0",
  "description": "Quick notes for daily standups",
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "permissions": ["storage"]
}
```

Manifest V3 is the current standard. The `storage` permission enables Chrome's sync storage, keeping your notes available across devices.

## The Popup Interface

Your popup is what users see when clicking the extension icon. Design it for speed:

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="popup.css">
</head>
<body>
  <div class="container">
    <h2>Daily Standup</h2>
    <label>Yesterday:</label>
    <textarea id="yesterday" rows="2"></textarea>
    
    <label>Today:</label>
    <textarea id="today" rows="2"></textarea>
    
    <label>Blockers:</label>
    <textarea id="blockers" rows="2"></textarea>
    
    <div class="buttons">
      <button id="saveBtn">Save</button>
      <button id="exportBtn">Export</button>
      <button id="clearBtn">Clear</button>
    </div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

Three text areas match the standard standup format. Users can quickly type their updates without navigating complex menus.

## Styling the Popup

Keep the CSS minimal but functional:

```css
body {
  width: 320px;
  padding: 16px;
  font-family: -apple-system, BlinkMacSystemFont, sans-serif;
}

.container h2 {
  margin: 0 0 16px 0;
  font-size: 18px;
}

label {
  display: block;
  margin: 12px 0 4px;
  font-weight: 600;
  font-size: 12px;
  color: #555;
}

textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 13px;
  resize: none;
}

textarea:focus {
  outline: none;
  border-color: #4285f4;
}

.buttons {
  display: flex;
  gap: 8px;
  margin-top: 16px;
}

button {
  flex: 1;
  padding: 8px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

#saveBtn { background: #4285f4; color: white; }
#exportBtn { background: #34a853; color: white; }
#clearBtn { background: #ea4335; color: white; }
```

The fixed width ensures consistent rendering. The colors follow a simple, familiar palette.

## Core Functionality in JavaScript

The JavaScript handles saving, loading, and exporting notes:

```javascript
document.addEventListener('DOMContentLoaded', () => {
  loadNotes();
  
  document.getElementById('saveBtn').addEventListener('click', saveNotes);
  document.getElementById('exportBtn').addEventListener('click', exportNotes);
  document.getElementById('clearBtn').addEventListener('click', clearNotes);
});

function saveNotes() {
  const notes = {
    yesterday: document.getElementById('yesterday').value,
    today: document.getElementById('today').value,
    blockers: document.getElementById('blockers').value,
    savedAt: new Date().toISOString()
  };
  
  chrome.storage.sync.set({ standupNotes: notes }, () => {
    showFeedback('Notes saved!');
  });
}

function loadNotes() {
  chrome.storage.sync.get('standupNotes', (result) => {
    if (result.standupNotes) {
      document.getElementById('yesterday').value = result.standupNotes.yesterday || '';
      document.getElementById('today').value = result.standupNotes.today || '';
      document.getElementById('blockers').value = result.standupNotes.blockers || '';
    }
  });
}

function exportNotes() {
  const notes = `## Standup Notes - ${new Date().toLocaleDateString()}

### Yesterday
${document.getElementById('yesterday').value}

### Today
${document.getElementById('today').value}

### Blockers
${document.getElementById('blockers').value}`;

  const blob = new Blob([notes], { type: 'text/markdown' });
  const url = URL.createObjectURL(blob);
  
  const a = document.createElement('a');
  a.href = url;
  a.download = `standup-${new Date().toISOString().split('T')[0]}.md`;
  a.click();
}

function clearNotes() {
  document.getElementById('yesterday').value = '';
  document.getElementById('today').value = '';
  document.getElementById('blockers').value = '';
  chrome.storage.sync.remove('standupNotes');
}

function showFeedback(message) {
  const feedback = document.createElement('div');
  feedback.textContent = message;
  feedback.style.cssText = 'position:fixed;bottom:10px;left:10px;background:#333;color:white;padding:8px 12px;border-radius:4px;font-size:12px;';
  document.body.appendChild(feedback);
  setTimeout(() => feedback.remove(), 2000);
}
```

The export function generates a Markdown file, making it easy to paste into GitHub issues, Slack, or documentation wikis.

## Loading Your Extension

To test your extension:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select your extension directory

Your extension now appears in the toolbar. Click it to start capturing standup notes.

## Practical Usage Tips

Once installed, integrate the extension into your workflow:

**Morning Routine**: Open the extension first thing. Type what you accomplished yesterday while your coffee brews.

**During Standup**: Keep the popup open. Update the "today" section as teammates share their updates.

**After Standup**: Click export to save a Markdown copy to your downloads folder. Paste directly into your team's Slack channel or project management tool.

**Weekly Review**: Accumulated Markdown files become documentation of your progress. Search through them during performance reviews or sprint retrospectives.

## Extending the Extension

This foundation supports many enhancements:

- Add keyboard shortcuts for faster data entry
- Integrate with Slack or Teams webhooks to post directly
- Include templates for different meeting types
- Add timestamps for individual bullet points
- Sync with external services like Notion or Jira

The Chrome storage API handles synchronization across your devices automatically. Users signed into Chrome will see their notes on any machine where they sign in.

## Conclusion

A custom Chrome extension for standup meeting notes removes friction from daily routines. The three-field structure matches how teams communicate. Markdown export integrates with existing workflows. Storage sync ensures nothing gets lost.

Start with this basic version. Refine the fields based on your team's specific format. The extension evolves with your needs, becoming an indispensable part of your daily development workflow.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
