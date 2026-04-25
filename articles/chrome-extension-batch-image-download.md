---
layout: default
title: "Batch Image Download Chrome Extension"
description: "Learn how to build a Chrome extension for batch image downloading. Practical code examples, APIs, and implementation patterns for developers and power."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-batch-image-download/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
Chrome Extension Batch Image Download: A Developer Guide

Building a Chrome extension that downloads multiple images from a webpage automatically is a valuable skill for developers and power users. Whether you're collecting reference images for a design project, archiving visual content, or gathering training data for machine learning, understanding how to programmatically extract and save images at scale saves countless hours of manual work.

This guide covers the technical implementation of batch image downloading in Chrome extensions, from manifest configuration to handling complex scenarios like lazy-loaded images and cross-origin resources.

## Understanding the Core Components

A batch image download extension operates through three main Chrome extension APIs: the Content Script API for DOM interaction, the chrome.downloads API for file saving, and the chrome.runtime API for communication between extension components.

The manifest file defines the extension's capabilities. For batch image downloading, you need specific permissions in your manifest.json:

```json
{
 "manifest_version": 3,
 "name": "Batch Image Downloader",
 "version": "1.0",
 "permissions": [
 "downloads",
 "activeTab",
 "scripting"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "action": {
 "default_popup": "popup.html"
 }
}
```

The `activeTab` permission ensures your extension can access only the currently active tab, maintaining user privacy. The `scripting` permission allows executing JavaScript to extract image URLs from the page.

## Extracting Image URLs from Webpages

The core challenge is identifying which elements on a page contain images worth downloading. You need a content script that scans the DOM and collects image sources. Here's a practical implementation:

```javascript
// content-script.js
function collectImageUrls(options = {}) {
 const {
 minWidth = 0,
 minHeight = 0,
 excludePatterns = [],
 includeDataUrl = false
 } = options;

 const images = Array.from(document.querySelectorAll('img'));
 const urlSet = new Set();

 images.forEach(img => {
 // Skip images that don't meet size requirements
 if (img.naturalWidth < minWidth || img.naturalHeight < minHeight) {
 return;
 }

 let src = img.src || img.currentSrc;
 
 // Handle lazy-loaded images
 if (!src) {
 src = img.dataset.src || img.dataset.lazySrc;
 }

 if (!src) return;

 // Apply exclusion patterns
 const shouldExclude = excludePatterns.some(pattern => 
 src.includes(pattern)
 );
 
 if (shouldExclude) return;

 // Optionally include base64 data URLs
 if (!includeDataUrl && src.startsWith('data:')) {
 return;
 }

 urlSet.add(src);
 });

 return Array.from(urlSet);
}

// Execute when called from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'collectImages') {
 const urls = collectImageUrls(message.options);
 sendResponse({ urls });
 }
});
```

This script handles several real-world scenarios: standard img tags, lazy-loaded images with data attributes, and filtering based on image dimensions. The dimension check is particularly useful because many pages embed tiny tracking images or icons that you probably don't want.

## Handling Cross-Origin Images

A significant challenge arises when images are hosted on different domains than the page itself. Chrome's security model prevents content scripts from reading responses from cross-origin URLs directly. You have two primary approaches to solve this.

The first approach uses fetch with a proxy. Your background script can request cross-origin images because extensions have broader permissions:

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'downloadBatch') {
 downloadImages(message.urls, message.folderName)
 .then(results => sendResponse({ success: true, results }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 }
 return true; // Keep message channel open for async response
});

async function downloadImages(urls, folderName) {
 const results = [];
 
 for (const url of urls) {
 try {
 // Fetch image data with CORS headers
 const response = await fetch(url, {
 mode: 'cors',
 credentials: 'include'
 });
 
 const blob = await response.blob();
 const arrayBuffer = await blob.arrayBuffer();
 
 // Generate filename from URL
 const urlObj = new URL(url);
 const filename = urlObj.pathname.split('/').pop() || 'image';
 
 // Save using Downloads API
 const downloadId = await chrome.downloads.download({
 url: url,
 filename: `${folderName}/${filename}`,
 saveAs: false
 });
 
 results.push({ url, success: true, downloadId });
 } catch (error) {
 results.push({ url, success: false, error: error.message });
 }
 }
 
 return results;
}
```

The second approach uses the fact that the Downloads API can accept blob URLs. However, this requires converting images to blobs first, which adds complexity.

## Building the User Interface

Your popup interface should give users control over which images to download. Here's a practical popup implementation:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; padding: 16px; font-family: system-ui; }
 .option-group { margin-bottom: 12px; }
 label { display: block; margin-bottom: 4px; font-size: 13px; }
 input[type="number"] { width: 100%; padding: 6px; }
 button {
 width: 100%; padding: 10px; background: #4a90d9;
 color: white; border: none; border-radius: 4px;
 cursor: pointer; font-size: 14px;
 }
 button:disabled { background: #ccc; }
 #status { margin-top: 12px; font-size: 12px; }
 </style>
</head>
<body>
 <h3>Batch Image Download</h3>
 
 <div class="option-group">
 <label>Minimum Width (px)</label>
 <input type="number" id="minWidth" value="200">
 </div>
 
 <div class="option-group">
 <label>Minimum Height (px)</label>
 <input type="number" id="minHeight" value="200">
 </div>
 
 <button id="scanBtn">Scan for Images</button>
 <button id="downloadBtn" disabled>Download All</button>
 
 <div id="status"></div>
 
 <script src="popup.js"></script>
</body>
</html>
```

The corresponding popup JavaScript coordinates between the user interface and your content script:

```javascript
// popup.js
let collectedUrls = [];

document.getElementById('scanBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 const minWidth = parseInt(document.getElementById('minWidth').value) || 0;
 const minHeight = parseInt(document.getElementById('minHeight').value) || 0;
 
 const results = await chrome.tabs.sendMessage(tab.id, {
 action: 'collectImages',
 options: { minWidth, minHeight }
 });
 
 collectedUrls = results.urls;
 document.getElementById('status').textContent = 
 `Found ${collectedUrls.length} images`;
 document.getElementById('downloadBtn').disabled = false;
});

document.getElementById('downloadBtn').addEventListener('click', async () => {
 const folderName = `images_${Date.now()}`;
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 const results = await chrome.tabs.sendMessage(tab.id, {
 action: 'downloadBatch',
 urls: collectedUrls,
 folderName
 });
 
 document.getElementById('status').textContent = 
 `Downloaded ${results.results.filter(r => r.success).length} images`;
});
```

## Advanced Considerations

Several edge cases require additional handling for production-ready extensions.

Dynamic content: Single-page applications and infinite scroll pages load images dynamically. Consider adding an observation mode using MutationObserver to detect new images as they appear.

File naming conflicts: When downloading multiple images, filename collisions are likely. Implement a hash-based naming system or append timestamps to ensure uniqueness:

```javascript
function generateUniqueFilename(url, index) {
 const hash = hashCode(url);
 const ext = url.split('.').pop().split('?')[0] || 'jpg';
 return `${hash}_${index}.${ext}`;
}

function hashCode(str) {
 let hash = 0;
 for (let i = 0; i < str.length; i++) {
 const char = str.charCodeAt(i);
 hash = ((hash << 5) - hash) + char;
 hash = hash & hash;
 }
 return Math.abs(hash).toString(16);
}
```

Rate limiting: Aggressive batch downloads can trigger rate limiting or temporarily block your IP. Implement delays between downloads:

```javascript
async function downloadWithDelay(urls, delayMs = 500) {
 for (let i = 0; i < urls.length; i++) {
 await downloadImage(urls[i]);
 await new Promise(resolve => setTimeout(resolve, delayMs));
 }
}
```

## Testing Your Extension

Before distributing your extension, test it across different types of websites. Pay particular attention to:

- Sites using React, Vue, or Angular (framework-specific DOM patterns)
- Image galleries with lightbox overlays
- E-commerce product pages with multiple image sizes
- Social media feeds with lazy-loaded content

Chrome's developer tools make debugging straightforward. Use chrome://extensions, enable "Developer mode," and click "Load unpacked" to test your extension during development.

Building a solid batch image download extension requires handling many real-world edge cases, but the core patterns covered here provide a solid foundation. With these components in place, you can extend functionality to support downloading videos, documents, or any other file type by adapting the content script selectors and download logic.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-batch-image-download)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Way to Batch Claude Code Requests to Reduce API Calls](/best-way-to-batch-claude-code-requests-reduce-api-calls/)
- [Chrome Downloads Slow: A Developer's Guide to Fixing Download Performance](/chrome-downloads-slow/)
- [Chrome Enterprise Bundle Download: A Developer's Guide](/chrome-enterprise-bundle-download/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



