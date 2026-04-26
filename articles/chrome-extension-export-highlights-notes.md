---
layout: default
title: "Export Highlights Notes Chrome (2026)"
description: "Claude Code extension tip: learn how to export highlights and notes from Chrome extensions. Practical examples, API approaches, and code snippets for..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-export-highlights-notes/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
---
Chrome extensions that handle reading, annotation, and note-taking have become essential tools for developers, researchers, and knowledge workers. Whether you're building a read-it-later app, a research assistant, or a productivity tool, understanding how to export highlights and notes programmatically opens up powerful integration possibilities.

This guide covers practical approaches to exporting highlights and notes from Chrome extensions, with code examples you can adapt for your own projects.

## Understanding the Data Structure

Before exporting, you need to understand how Chrome extensions typically store highlights and notes. Most extensions use one of these approaches:

- IndexedDB: Browser-native NoSQL storage, good for large datasets
- localStorage: Simple key-value storage with size limitations (typically 5-10MB)
- chrome.storage API: Extension-specific storage with sync capabilities

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

Choosing the right storage backend up front matters a great deal. `localStorage` works for small highlight sets but will hit its quota limit once a user accumulates hundreds of annotated pages. `IndexedDB` scales to tens of thousands of records without complaint, but requires more boilerplate. The `chrome.storage` API sits in the middle: it offers a clean async interface, built-in sync across devices, and a quota of around 100 KB for `sync` or roughly unlimited for `local`. For most annotation extensions, `chrome.storage.local` is the right starting point.

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

One edge case worth handling is paginated storage. If users have thousands of highlights stored under multiple keys, a single `get('highlights')` call returns nothing. A more solid pattern uses `chrome.storage.local.get(null)` to retrieve everything, then filters by key prefix:

```javascript
async function exportAllHighlightsPaginated() {
 const allData = await chrome.storage.local.get(null);
 const highlights = Object.entries(allData)
 .filter(([key]) => key.startsWith('hl_'))
 .map(([, value]) => value);

 return highlights;
}
```

This pattern also makes it straightforward to export highlights grouped by domain or by date range without loading the entire dataset into memory at once.

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
 md += `Note: ${hl.note}\n\n`;
 }
 md += `---\n\n`;
 });

 return md;
}
```

If your users work with Obsidian specifically, you can enhance this output with frontmatter YAML so each exported file becomes a proper Obsidian note with tags and backlinks:

```javascript
function exportToObsidianMarkdown(highlights, pageTitle, pageUrl, tags) {
 const tagList = (tags || []).map(t => ` - ${t}`).join('\n');
 let md = `---\n`;
 md += `title: "${pageTitle}"\n`;
 md += `source: "${pageUrl}"\n`;
 md += `exported: "${new Date().toISOString()}"\n`;
 if (tagList) md += `tags:\n${tagList}\n`;
 md += `---\n\n`;

 highlights.forEach((hl) => {
 md += `> ${hl.text}\n\n`;
 if (hl.note) md += `${hl.note}\n\n`;
 md += `---\n\n`;
 });

 return md;
}
```

Roam Research users prefer a slightly different format with `((block-uid))` references, but a basic block-level export works well with `[[page title]]` syntax as wiki-style links.

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

A common UX improvement is to show a highlight count badge in the popup so users know how many annotations exist for the current page before exporting. You can fetch this from storage when the popup opens:

```javascript
// popup.js - show count on load
document.addEventListener('DOMContentLoaded', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const result = await chrome.storage.local.get('highlights');
 const all = result.highlights || [];
 const pageCount = all.filter(h => h.pageUrl === tab.url).length;
 document.getElementById('count').textContent =
 `${pageCount} highlight${pageCount !== 1 ? 's' : ''} on this page`;
});
```

## Comparing Export Format Options

Different downstream workflows demand different formats. The table below summarizes when to reach for each:

| Format | Best For | Drawbacks |
|--------|----------|-----------|
| JSON | Developer pipelines, re-import, full fidelity | Not human-readable without tooling |
| Markdown | Obsidian, Notion, Roam, static sites | Loses color and position metadata |
| CSV | Spreadsheet analysis, Airtable, data science | No nesting; notes must be single-line |
| HTML | Email, web sharing, printing | Larger file size, requires sanitization |
| Plain text | Quick copy-paste, minimal setup | Loses all structure and metadata |

For teams building annotation tools, offering JSON as the canonical format plus Markdown and CSV as convenience exports covers the majority of user workflows without significant added complexity.

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

Cross-extension messaging requires that the receiving extension explicitly whitelists the sender's ID in its manifest. This is a useful pattern when you split annotation storage into one extension and export/sync into another, keeping each extension's surface area small.

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

One detail worth noting: some highlight text contains newlines, which will break the CSV row structure unless you strip or escape them before writing to the field. A safe approach is to replace newlines with a space inside quoted fields:

```javascript
function sanitizeForCSV(text) {
 return `"${(text || '').replace(/"/g, '""').replace(/\n/g, ' ').trim()}"`;
}
```

Running the resulting CSV through a validator like csvlint before shipping to users will catch these edge cases before they become support tickets.

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

For incremental backups rather than full dumps, track a `lastExportTimestamp` in storage and filter highlights created after that timestamp:

```javascript
async function performIncrementalExport() {
 const meta = await chrome.storage.local.get('lastExportTimestamp');
 const since = meta.lastExportTimestamp || 0;

 const result = await chrome.storage.local.get('highlights');
 const newHighlights = (result.highlights || []).filter(
 h => new Date(h.createdAt).getTime() > since
 );

 if (newHighlights.length === 0) return;

 const blob = new Blob([JSON.stringify(newHighlights)], { type: 'application/json' });
 await chrome.downloads.download({
 url: URL.createObjectURL(blob),
 filename: `highlights-incremental-${Date.now()}.json`,
 saveAs: false
 });

 await chrome.storage.local.set({ lastExportTimestamp: Date.now() });
}
```

This pattern keeps individual export files small and makes it practical to store months of backup history without bloating the user's Downloads folder.

## Real-World Scenario: Research Workflow Integration

Consider a researcher who highlights academic papers and needs to push those highlights into a Zotero-compatible notes format. The export logic would look like this:

1. Capture highlights with `position` metadata intact so citations can reference exact passage locations.
2. On export, group by `pageUrl` and map each group to a Zotero note item using the Zotero API's `notes` field format.
3. Tag each note with the highlight color mapped to a Zotero tag (e.g., yellow = "important", red = "disagree").

This kind of integration turns a simple annotation extension into a full research pipeline tool. The extension itself stays lightweight. the export format is the integration surface.

## Security Considerations

When exporting user data, keep these security practices in mind:

1. Validate data before export to prevent injection attacks
2. Sanitize HTML content if exporting to HTML format
3. Request minimal permissions - only what's needed for your export feature
4. Clear sensitive data from temporary variables after export completes

A fifth consideration often overlooked: revoke object URLs promptly. `URL.createObjectURL()` holds a reference to the blob in memory until either the document unloads or `URL.revokeObjectURL()` is called explicitly. For large exports, failing to revoke can cause measurable memory pressure in long-running extension contexts.

```javascript
// Always revoke after triggering the download
const url = URL.createObjectURL(blob);
a.href = url;
a.click();
// Revoke on next tick to ensure the download has started
setTimeout(() => URL.revokeObjectURL(url), 100);
```

## Conclusion

Exporting highlights and notes from Chrome extensions requires understanding storage APIs, data formatting, and user interface patterns. The approaches covered here, JSON, Markdown, CSV, and automated exports, provide a foundation for building solid export functionality.

These patterns work whether you're extending an existing annotation tool or building a new reading companion. Start with the data structure that matches your needs, then layer in export formats as your users require them. Incremental exports, paginated storage reads, and Obsidian-compatible Markdown output are all straightforward additions once the core pipeline is in place. The key is treating the export format as a first-class feature rather than an afterthought, because for knowledge workers, the ability to own and move their data is often more important than any individual annotation feature.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-export-highlights-notes)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Enterprise Release Schedule 2026: A Practical Guide](/chrome-enterprise-release-schedule-2026/)
- [Chrome Enterprise Stable Channel Management: A Practical Guide](/chrome-enterprise-stable-channel-management/)
- [Chrome Extension Bibliography Generator: A Practical Guide](/chrome-extension-bibliography-generator/)
- [How to Export Passwords from Chrome Safely](/export-passwords-chrome-safely/)
- [Flash Sale Notification Chrome Extension Guide (2026)](/chrome-extension-flash-sale-notification/)
- [Noise Cancellation Chrome Extension Guide (2026)](/noise-cancellation-chrome-extension/)
- [Pinterest Pin Scheduler Chrome Extension Guide (2026)](/chrome-extension-pinterest-pin-scheduler/)
- [Chrome Extension Retrospective Board: Agile Tools](/chrome-extension-retrospective-board/)
- [Best Violentmonkey Alternatives for Chrome 2026](/violentmonkey-alternative-chrome-extension-2026/)
- [Chrome Browser Token Enrollment — Developer Guide](/chrome-browser-token-enrollment/)
- [Lightshot Alternative Chrome Extension 2026](/lightshot-alternative-chrome-extension-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Integration with Notion via API

Push highlights directly to a Notion page using the Notion API:

```javascript
async function pushToNotion(highlight, notionPageId, apiKey) {
 const response = await fetch(`https://api.notion.com/v1/blocks/${notionPageId}/children`, {
 method: 'PATCH',
 headers: {
 'Authorization': 'Bearer ' + apiKey,
 'Content-Type': 'application/json',
 'Notion-Version': '2022-06-28'
 },
 body: JSON.stringify({
 children: [{
 object: 'block', type: 'quote',
 quote: { rich_text: [{ type: 'text', text: { content: highlight.text } }] }
 }]
 })
 });
 return response.json();
}
```

Store the Notion API key and page ID in `chrome.storage.sync` so the integration persists across devices.

## Advanced: Obsidian Vault Export

Generate Obsidian-compatible markdown with YAML frontmatter for Dataview compatibility:

```javascript
function exportToObsidian(highlights, pageTitle) {
 const safeTitle = pageTitle.replace(/[\/\\?%*:|"<>]/g, '-');
 let md = `---\ntags: [highlights, web-clip]\nsource: "${pageTitle}"\ndate: ${new Date().toISOString().slice(0,10)}\n---\n\n`;

 highlights.forEach((hl, i) => {
 md += `> [!quote] Highlight ${i + 1}\n`;
 md += `> ${hl.text}\n\n`;
 if (hl.note) md += `Note: ${hl.note}\n\n`;
 });

 return md;
}
```

## Comparison with Existing Tools

| Tool | Export formats | Sync | Price |
|---|---|---|---|
| This extension | JSON, MD, CSV (you decide) | chrome.storage.sync | Free (build it) |
| Hypothesis | JSON, CSV | Cloud account | Free/Pro |
| Readwise | Markdown, Obsidian plugin | Cloud sync | $7.99/month |
| Liner | PDF, text | Cloud | Freemium |

Building your own gives complete control over formats and integrations. Readwise remains the most polished commercial option for users who want a no-build solution.

## Troubleshooting Common Issues

`URL.createObjectURL` failing in service worker: Service workers cannot use `createObjectURL`. Convert the blob to a data URL instead:

```javascript
function blobToDataURL(blob) {
 return new Promise((resolve) => {
 const reader = new FileReader();
 reader.onloadend = () => resolve(reader.result);
 reader.readAsDataURL(blob);
 });
}
```

CSV breaking on commas: Always double-quote text fields and escape internal quotes by doubling them. Verify you are not bypassing the escape logic when concatenating fields.

Exported JSON too large: Compress large exports using the Compression Streams API (Chrome 80+):

```javascript
async function compressJSON(data) {
 const stream = new Blob([data]).stream().pipeThrough(new CompressionStream('gzip'));
 return new Response(stream).blob();
}
```

These patterns work whether you are extending an existing annotation tool or building a new reading companion from scratch. Start with the data structure that matches your needs, then layer in export formats as your users require them.


**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

