---
layout: default
title: "Chrome Extension Export Highlights Notes: A Practical Guide"
description: "Learn how to export highlights and notes from Chrome extensions. Practical examples, API approaches, and code snippets for developers building reading and annotation tools."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-export-highlights-notes/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
---

{% raw %}

Chrome extensions that handle reading, annotation, and note-taking have become essential tools for developers, researchers, and knowledge workers. Whether you're building a read-it-later app, a research assistant, or a productivity tool, understanding how to export highlights and notes programmatically opens up powerful integration possibilities.

This guide covers practical approaches to exporting highlights and notes from Chrome extensions, with code examples you can adapt for your own projects.

## Understanding the Data Structure

Before exporting, you need to understand how Chrome extensions typically store highlights and notes. Most extensions use one of these approaches:

- **IndexedDB**: Browser-native NoSQL storage, good for large datasets
- **localStorage**: Simple key-value storage with size limitations (typically 5-10MB)
- **chrome.storage API**: Extension-specific storage with sync capabilities

Here's a typical data structure for highlights:

```javascript
// Example highlight object structure
const highlight = {
  id: "hl_abc123",
  pageUrl: "https://example.com/article",
  pageTitle: "Understanding Chrome Extensions",
  text: "This is the highlighted passage",
  color: "#ffeb3b",
  note: "Important concept for my project",
  createdAt: "2026-03-15T10:30:00Z",
  position: {
    startOffset: 1420,
    endOffset: 1460,
    startContainer: "p.content",
    endContainer: "p.content"
  }
};
```

## Exporting via chrome.storage API

The `chrome.storage` API is the standard way extensions persist data. Here's how to export highlights and notes:

```javascript
// background.js - Export all highlights
async function exportAllHighlights() {
  const result = await chrome.storage.local.get('highlights');
  const highlights = result.highlights || [];
  
  // Convert to JSON
  const jsonData = JSON.stringify(highlights, null, 2);
  
  // Create downloadable file
  const blob = new Blob([jsonData], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  
  const a = document.createElement('a');
  a.href = url;
  a.download = `highlights-export-${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  
  URL.revokeObjectURL(url);
}
```

## Exporting to Markdown Format

Markdown is particularly useful because it integrates with note-taking apps like Obsidian, Notion, and Roam Research:

```javascript
function exportToMarkdown(highlights, pageTitle, pageUrl) {
  let md = `# ${pageTitle}\n\n`;
  md += `Source: ${pageUrl}\n`;
  md += `Exported: ${new Date().toISOString()}\n\n`;
  md += `---\n\n`;
  
  highlights.forEach((hl, index) => {
    md += `## Highlight ${index + 1}\n\n`;
    md += `> ${hl.text}\n\n`;
    if (hl.note) {
      md += `**Note:** ${hl.note}\n\n`;
    }
    md += `---\n\n`;
  });
  
  return md;
}
```

## Building an Export Popup UI

Users need a simple interface to trigger exports. Here's a popup implementation:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; padding: 16px; font-family: system-ui; }
    button {
      width: 100%; padding: 10px; margin: 8px 0;
      background: #4a90d9; color: white; border: none;
      border-radius: 4px; cursor: pointer;
    }
    button:hover { background: #357abd; }
    select { width: 100%; padding: 8px; margin: 8px 0; }
  </style>
</head>
<body>
  <h3>Export Highlights</h3>
  <select id="format">
    <option value="json">JSON</option>
    <option value="markdown">Markdown</option>
    <option value="csv">CSV</option>
  </select>
  <button id="exportBtn">Export Current Page</button>
  <button id="exportAllBtn">Export All Highlights</button>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.getElementById('exportBtn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getHighlights' }, (highlights) => {
    const format = document.getElementById('format').value;
    downloadHighlights(highlights, format, tab.title, tab.url);
  });
});
```

## Handling Cross-Extension Data Sharing

If you're building multiple extensions or integrating with web services, consider using the Cross-Extension Messaging API:

```javascript
// Sending extension - manifest.json must declare permissions
// "permissions": ["nativeMessaging"]

// Sending the message
chrome.runtime.sendMessage(extensionId, {
  type: 'EXPORT_HIGHLIGHTS',
  data: highlightsData
}, (response) => {
  console.log('Export completed:', response.status);
});
```

## CSV Export for Spreadsheet Analysis

Sometimes you need data in a format suitable for spreadsheets:

```javascript
function exportToCSV(highlights) {
  const headers = ['Date', 'Page Title', 'URL', 'Highlight Text', 'Note', 'Color'];
  const rows = highlights.map(hl => [
    hl.createdAt,
    `"${hl.pageTitle.replace(/"/g, '""')}"`,
    hl.pageUrl,
    `"${hl.text.replace(/"/g, '""')}"`,
    `"${(hl.note || '').replace(/"/g, '""')}"`,
    hl.color
  ]);
  
  return [headers.join(','), ...rows.map(r => r.join(','))].join('\n');
}
```

## Automating Exports with Background Scripts

For power users, automatic scheduled exports are valuable:

```javascript
// background.js
chrome.alarms.create('dailyExport', { periodInMinutes: 1440 }); // 24 hours

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'dailyExport') {
    performScheduledExport();
  }
});

async function performScheduledExport() {
  const result = await chrome.storage.local.get('highlights');
  const highlights = result.highlights || [];
  
  // Save to Downloads folder
  const blob = new Blob([JSON.stringify(highlights)], { type: 'application/json' });
  await chrome.downloads.download({
    url: URL.createObjectURL(blob),
    filename: `highlights-backup-${Date.now()}.json`,
    saveAs: false
  });
}
```

## Security Considerations

When exporting user data, keep these security practices in mind:

1. **Validate data before export** to prevent injection attacks
2. **Sanitize HTML content** if exporting to HTML format
3. **Request minimal permissions** - only what's needed for your export feature
4. **Clear sensitive data** from temporary variables after export completes

## Conclusion

Exporting highlights and notes from Chrome extensions requires understanding storage APIs, data formatting, and user interface patterns. The approaches covered here—JSON, Markdown, CSV, and automated exports—provide a foundation for building robust export functionality.

These patterns work whether you're extending an existing annotation tool or building a new reading companion. Start with the data structure that matches your needs, then layer in export formats as your users require them.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
