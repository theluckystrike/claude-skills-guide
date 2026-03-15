---

layout: default
title: "Chrome Extension Batch Image Download: A Developer Guide"
description: "Learn how to build a Chrome extension for batch downloading images from any webpage. Complete with code examples and practical implementation guide."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-batch-image-download/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


{% raw %}
# Chrome Extension Batch Image Download: A Developer Guide

Building a Chrome extension that downloads multiple images from a webpage simultaneously requires understanding the Chrome APIs, file handling, and user interface design. This guide walks you through creating a functional batch image downloader extension from scratch.

## Understanding the Architecture

A Chrome extension for batch image downloading consists of three core components: a manifest file defining permissions and structure, a content script that extracts image URLs from the page, and a background script or popup that orchestrates the download process.

The manifest version 3 approach provides better security and performance than version 2. Your extension needs permissions for `activeTab`, `downloads`, and `scripting` to function properly.

### Project Structure

```
batch-image-downloader/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
└── icon.png
```

## Implementation Guide

### Manifest Configuration

Create your `manifest.json` with the necessary permissions:

```json
{
  "manifest_version": 3,
  "name": "Batch Image Downloader",
  "version": "1.0",
  "description": "Download multiple images from any webpage",
  "permissions": [
    "activeTab",
    "scripting",
    "downloads"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "host_permissions": [
    "<all_urls>"
  ]
}
```

### Content Script for Image Extraction

The content script runs on the target page and collects all image URLs. You need to filter out tracking pixels, icons, and other non-essential images.

```javascript
// content.js
function extractImages() {
  const images = Array.from(document.querySelectorAll('img'));
  const imageUrls = images
    .map(img => img.src)
    .filter(src => {
      // Filter out small images, tracking pixels, and data URLs
      const isDataUrl = src.startsWith('data:');
      const isTrackingPixel = img.width < 50 || img.height < 50;
      return !isDataUrl && !isTrackingPixel;
    })
    .filter((url, index, self) => self.indexOf(url) === index); // Remove duplicates
  
  return imageUrls;
}

// Listen for messages from the popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getImages') {
    const images = extractImages();
    sendResponse({ images: images });
  }
});
```

### Popup Interface

The popup provides the user interface for selecting and downloading images:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; padding: 16px; font-family: system-ui; }
    .header { font-size: 16px; font-weight: bold; margin-bottom: 12px; }
    .image-list { max-height: 300px; overflow-y: auto; border: 1px solid #ddd; }
    .image-item { padding: 8px; border-bottom: 1px solid #eee; display: flex; align-items: center; }
    .image-item img { width: 40px; height: 40px; object-fit: cover; margin-right: 8px; }
    .image-item label { flex: 1; font-size: 12px; overflow: hidden; text-overflow: ellipsis; }
    .download-btn { width: 100%; padding: 10px; background: #4CAF50; color: white; border: none; cursor: pointer; margin-top: 12px; }
    .download-btn:hover { background: #45a049; }
    .count { font-size: 12px; color: #666; margin-bottom: 8px; }
  </style>
</head>
<body>
  <div class="header">Batch Image Downloader</div>
  <div class="count" id="count">Found 0 images</div>
  <div class="image-list" id="imageList"></div>
  <button class="download-btn" id="downloadBtn">Download Selected</button>
  <script src="popup.js"></script>
</body>
</html>
```

### Popup Logic

The popup script communicates with the content script and handles the download process:

```javascript
// popup.js
let imageUrls = [];

document.addEventListener('DOMContentLoaded', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  // Inject content script and get images
  const results = await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    function: extractImages
  });
  
  imageUrls = results[0].result;
  displayImages(imageUrls);
});

function displayImages(urls) {
  const list = document.getElementById('imageList');
  document.getElementById('count').textContent = `Found ${urls.length} images`;
  
  urls.forEach((url, index) => {
    const item = document.createElement('div');
    item.className = 'image-item';
    item.innerHTML = `
      <input type="checkbox" id="img_${index}" checked>
      <img src="${url}" onerror="this.style.display='none'">
      <label for="img_${index}">${url.split('/').pop()}</label>
    `;
    list.appendChild(item);
  });
}

document.getElementById('downloadBtn').addEventListener('click', async () => {
  const checkboxes = document.querySelectorAll('.image-item input[type="checkbox"]:checked');
  const selectedUrls = Array.from(checkboxes).map(cb => {
    const index = cb.id.split('_')[1];
    return imageUrls[index];
  });
  
  for (const url of selectedUrls) {
    const filename = url.split('/').pop().split('?')[0] || 'image.jpg';
    await chrome.downloads.download({
      url: url,
      filename: `downloads/${filename}`
    });
  }
});

function extractImages() {
  const images = Array.from(document.querySelectorAll('img'));
  return images
    .map(img => img.src)
    .filter(src => !src.startsWith('data:'))
    .filter((url, index, self) => self.indexOf(url) === index);
}
```

## Advanced Filtering Techniques

For power users, consider implementing additional filters based on image dimensions, file types, or domain restrictions. You can extend the content script to capture more metadata:

```javascript
function extractImagesAdvanced() {
  const images = Array.from(document.querySelectorAll('img'));
  return images
    .filter(img => img.naturalWidth >= 200 && img.naturalHeight >= 200)
    .map(img => ({
      src: img.src,
      width: img.naturalWidth,
      height: img.naturalHeight,
      alt: img.alt,
      domain: new URL(img.src).hostname
    }))
    .filter(img => !img.src.startsWith('data:'));
}
```

## Handling Common Challenges

### Cross-Origin Restrictions

Some images load from CDNs or external domains. Your extension needs the `host_permissions` in the manifest to access these resources. For images that require authentication or have CORS restrictions, consider using `fetch` with `mode: 'no-cors'` or proxy through a backend service.

### Filename Conflicts

When downloading multiple images, filename collisions become likely. Implement a timestamp or UUID prefix:

```javascript
function generateUniqueFilename(originalName, index) {
  const timestamp = Date.now();
  const ext = originalName.split('.').pop() || 'jpg';
  const name = originalName.split('.').slice(0, -1).join('.') || 'image';
  return `${timestamp}_${index}_${name}.${ext}`;
}
```

### Large Batch Downloads

For pages with hundreds of images, implement pagination or chunking to avoid overwhelming the browser:

```javascript
async function downloadInBatches(urls, batchSize = 10) {
  for (let i = 0; i < urls.length; i += batchSize) {
    const batch = urls.slice(i, i + batchSize);
    await Promise.all(batch.map(url => chrome.downloads.download({ url })));
    await new Promise(r => setTimeout(r, 1000)); // Delay between batches
  }
}
```

## Loading Your Extension

To test your extension in Chrome:

1. Navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select your extension's directory

## Conclusion

Building a batch image downloader extension requires careful attention to user experience, performance, and edge cases. The implementation above provides a solid foundation that you can customize for specific use cases. Consider adding features like custom download directories, filename templates, or integration with cloud storage services to differentiate your extension.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
