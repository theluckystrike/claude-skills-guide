---
layout: default
title: "Annotate Web Pages Chrome Extension"
description: "Learn how to build Chrome extensions to annotate web pages. Practical code examples, implementation techniques, and tips for developers and power users."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-annotate-web-pages/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
Chrome Extension Annotate Web Pages: Build Your Own Annotation Tool

Web annotation transforms passive reading into active engagement. Whether you're a researcher collecting evidence, a developer documenting bugs, or a student highlighting study materials, the ability to annotate web pages directly in your browser provides immediate value. Building a Chrome extension for page annotation is a practical project that demonstrates core extension APIs while creating a genuinely useful tool.

## Why Build a Web Annotation Extension

Browser-based annotations solve several real problems that developers and power users face daily:

- Research collection: Mark and annotate sources while browsing documentation, articles, or forums
- Bug tracking: Highlight UI issues and add context directly on production pages
- Collaboration: Share annotated screenshots with team members
- Personal organization: Create a visual reference system for ongoing projects

The Chrome platform provides all necessary APIs to implement these features without requiring external servers or complex backend infrastructure.

## Project Structure

A basic annotation extension requires these files:

```
annotate-pages/
 manifest.json
 background.js
 content.js
 popup.html
 popup.js
 styles.css
```

The manifest defines permissions and entry points, background scripts handle extension lifecycle, content scripts interact with page DOM, and popup UI provides the annotation interface.

## The Manifest File

Chrome extensions use Manifest V3, which requires declarative permissions and service worker-based background scripts.

```json
{
 "manifest_version": 3,
 "name": "Page Annotator",
 "version": "1.0",
 "description": "Annotate web pages with highlights and notes",
 "permissions": [
 "storage",
 "activeTab",
 "scripting"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 },
 "background": {
 "service_worker": "background.js"
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content.js"],
 "css": ["styles.css"]
 }]
}
```

This manifest requests storage for saving annotations and scripting permissions for DOM manipulation. The host permission covers all URLs since users may need to annotate any website.

## Content Script: Injecting Annotation Features

The content script runs on every page and handles the core annotation functionality, creating highlights and managing annotation data.

```javascript
// content.js
(function() {
 let annotations = [];
 
 // Load existing annotations for this page
 const pageUrl = window.location.href;
 
 chrome.storage.local.get([pageUrl], (result) => {
 if (result[pageUrl]) {
 annotations = result[pageUrl];
 restoreAnnotations();
 }
 });
 
 // Listen for messages from popup or background
 chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'addAnnotation') {
 addAnnotation(message.data);
 } else if (message.action === 'getAnnotations') {
 sendResponse(annotations);
 } else if (message.action === 'clearAnnotations') {
 clearAllAnnotations();
 }
 });
 
 function addAnnotation(data) {
 const annotation = {
 id: Date.now(),
 text: data.text || '',
 note: data.note || '',
 color: data.color || '#ffeb3b',
 position: data.position,
 timestamp: new Date().toISOString()
 };
 
 annotations.push(annotation);
 saveAnnotations();
 renderAnnotation(annotation);
 }
 
 function renderAnnotation(annotation) {
 const marker = document.createElement('div');
 marker.className = 'annotation-marker';
 marker.style.cssText = `
 position: absolute;
 background: ${annotation.color};
 opacity: 0.4;
 pointer-events: none;
 z-index: 999999;
 `;
 
 if (annotation.position) {
 marker.style.left = annotation.position.left + 'px';
 marker.style.top = annotation.position.top + 'px';
 marker.style.width = annotation.position.width + 'px';
 marker.style.height = annotation.position.height + 'px';
 }
 
 document.body.appendChild(marker);
 }
 
 function saveAnnotations() {
 const data = {};
 data[pageUrl] = annotations;
 chrome.storage.local.set(data);
 }
 
 function restoreAnnotations() {
 annotations.forEach(renderAnnotation);
 }
 
 function clearAllAnnotations() {
 annotations = [];
 saveAnnotations();
 document.querySelectorAll('.annotation-marker').forEach(el => el.remove());
 }
})();
```

This script maintains an array of annotations, persists them to Chrome's local storage keyed by URL, and renders visual markers on the page. The timestamp enables future features like sorting or filtering by date.

## Background Service Worker

The service worker manages extension state and handles keyboard shortcuts. Since Manifest V3 uses event-driven service workers, we register listeners for extension events.

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 console.log('Page Annotator extension installed');
});

// Handle keyboard shortcuts
chrome.commands.onCommand.addListener((command) => {
 if (command === 'annotate-selection') {
 chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
 chrome.tabs.sendMessage(tabs[0].id, { 
 action: 'quickAnnotate' 
 });
 });
 }
});

// Context menu for right-click annotation
chrome.contextMenus.create({
 id: 'annotateSelection',
 title: 'Annotate Selection',
 contexts: ['selection']
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
 if (info.menuItemId === 'annotateSelection') {
 chrome.tabs.sendMessage(tab.id, {
 action: 'annotateSelection',
 selectionText: info.selectionText
 });
 }
});
```

The background script registers a keyboard shortcut for quick annotation and adds a context menu option. Users can select text and right-click to annotate, or use the configured keyboard shortcut.

## Popup Interface

The popup provides the primary user interface for viewing and managing annotations.

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; padding: 12px; font-family: system-ui; }
 h2 { margin: 0 0 12px; font-size: 16px; }
 .annotation-list { max-height: 400px; overflow-y: auto; }
 .annotation-item {
 padding: 10px;
 margin-bottom: 8px;
 background: #f5f5f5;
 border-radius: 6px;
 cursor: pointer;
 }
 .annotation-item:hover { background: #eee; }
 .annotation-note { font-size: 13px; margin-top: 4px; }
 .annotation-meta { 
 font-size: 11px; color: #666; margin-top: 6px; 
 }
 .btn {
 padding: 8px 16px;
 background: #4285f4;
 color: white;
 border: none;
 border-radius: 4px;
 cursor: pointer;
 margin-top: 8px;
 }
 .btn-danger { background: #dc3545; }
 </style>
</head>
<body>
 <h2>Page Annotations</h2>
 <div id="annotationList" class="annotation-list"></div>
 <button id="clearBtn" class="btn btn-danger">Clear All</button>
 <script src="popup.js"></script>
</body>
</html>
```

## Popup Logic

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
 loadAnnotations();
 
 document.getElementById('clearBtn').addEventListener('click', () => {
 chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
 chrome.tabs.sendMessage(tabs[0].id, { 
 action: 'clearAnnotations' 
 });
 loadAnnotations();
 });
 });
 
 function loadAnnotations() {
 chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
 chrome.tabs.sendMessage(tabs[0].id, { 
 action: 'getAnnotations' 
 }, (annotations) => {
 displayAnnotations(annotations || []);
 });
 });
 }
 
 function displayAnnotations(annotations) {
 const container = document.getElementById('annotationList');
 container.innerHTML = '';
 
 if (annotations.length === 0) {
 container.innerHTML = '<p style="color: #666;">No annotations yet</p>';
 return;
 }
 
 annotations.forEach((ann, index) => {
 const div = document.createElement('div');
 div.className = 'annotation-item';
 div.innerHTML = `
 <div style="font-weight: 500;">${ann.text || 'Selection'}</div>
 <div class="annotation-note">${ann.note}</div>
 <div class="annotation-meta">
 ${new Date(ann.timestamp).toLocaleString()}
 </div>
 `;
 container.appendChild(div);
 });
 }
});
```

## Advanced Features to Consider

Once the basic annotation system works, these enhancements provide additional value:

Color-coded categories: Allow users to assign colors to annotations representing different categories, bugs (red), questions (yellow), ideas (green). Store the color in the annotation object and filter by color in the popup.

Export functionality: Add an option to export annotations as JSON or Markdown. This enables integration with external note-taking systems.

```javascript
function exportAnnotations(annotations) {
 const markdown = annotations.map(ann => 
 `- ${ann.text}: ${ann.note} (${ann.timestamp})`
 ).join('\n');
 
 const blob = new Blob([markdown], { type: 'text/markdown' });
 const url = URL.createObjectURL(blob);
 chrome.downloads.download({ url, filename: 'annotations.md' });
}
```

Annotation search: Implement a global search across all saved annotations using chrome.storage.index or maintain a separate search index.

## Loading and Testing

To test your extension during development:

1. Open `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension directory
4. Navigate to any webpage and try creating annotations

For continuous development, use Chrome's auto-reload feature by enabling "Allow in incognito" or manually clicking the reload button after making changes.

## Production Considerations

Before publishing to the Chrome Web Store, address these requirements:

- Privacy policy: Clearly explain what data you collect and how it's stored
- Manifest V3 compliance: Ensure all features work without remote code execution
- Performance: Content scripts load on every page, keep them minimal and efficient
- Error handling: Wrap storage operations in try-catch blocks to handle quota exceeded or unavailable storage

Building a web annotation extension demonstrates fundamental Chrome extension patterns while creating a genuinely useful tool for daily browser work.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-annotate-web-pages)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Employee Recognition Tool: Build Your Own](/chrome-extension-employee-recognition-tool/)
- [Chrome Extension Google Drive Sidebar: Build Your Own](/chrome-extension-google-drive-sidebar/)
- [Chrome Extension Markdown Editor: Build Your Own Browser-Based Writing Tool](/chrome-extension-markdown-editor/)
- [Chrome Preload Pages Setting — Developer Guide](/chrome-preload-pages-setting/)
- [Translate Pages Chrome Extension Guide (2026)](/chrome-extension-translate-pages/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



