---
layout: default
title: "Build an Image Compressor Chrome (2026)"
description: "Build a Chrome extension that compresses images before upload. Covers Canvas API resizing, WebP conversion, quality settings, and batch processing."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-compress-images-before-upload/
categories: [guides]
tags: [chrome-extension, image-compression, javascript, browser-api, developer-tools]
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-21"
---

# Chrome Extension Compress Images Before Upload: Practical Guide

Image-heavy web applications often face performance bottlenecks when users upload large files directly from their devices. A Chrome extension that compresses images before upload can reduce bandwidth usage, improve upload speeds, and enhance the user experience without requiring server-side processing. This guide walks through building a practical image compression extension using modern browser APIs.

## Understanding the Compression Pipeline

The core approach involves intercepting file input events, processing the image data in the browser using the Canvas API or the OffscreenCanvas API available in service workers, and replacing the original file with a compressed version before the upload completes.

Modern browsers provide several APIs for image compression. The Canvas API allows drawing images and exporting them at reduced quality. The ImageCodec API (still experimental) offers more control over encoding parameters. For broad compatibility, canvas-based compression remains the most reliable approach.

Here is the basic compression function using the Canvas API:

```javascript
// compression.js - core compression logic
async function compressImage(file, options = {}) {
 const {
 maxWidth = 1920,
 maxHeight = 1080,
 quality = 0.8,
 format = 'image/jpeg'
 } = options;

 const bitmap = await createImageBitmap(file);
 const canvas = document.createElement('canvas');
 const ctx = canvas.getContext('2d');

 let width = bitmap.width;
 let height = bitmap.height;

 // Calculate scaled dimensions maintaining aspect ratio
 if (width > maxWidth) {
 height = (maxWidth / width) * height;
 width = maxWidth;
 }
 if (height > maxHeight) {
 width = (maxHeight / height) * width;
 height = maxHeight;
 }

 canvas.width = width;
 canvas.height = height;
 ctx.drawImage(bitmap, 0, 0, width, height);

 return new Promise((resolve) => {
 canvas.toBlob((blob) => {
 resolve(new File([blob], file.name, { type: format }));
 }, format, quality);
 });
}
```

## Extension Architecture

The extension needs three main components: a content script that detects file inputs, a background worker for handling heavy processing, and proper messaging between them.

## Manifest Configuration

The manifest file declares the necessary permissions and defines the extension structure:

```json
{
 "manifest_version": 3,
 "name": "Image Compressor",
 "version": "1.0",
 "description": "Compresses images before upload",
 "permissions": ["scripting", "activeTab"],
 "host_permissions": ["<all_urls>"],
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content-script.js"],
 "run_at": "document_idle"
 }],
 "background": {
 "service_worker": "background.js"
 }
}
```

## Content Script Implementation

The content script monitors for file input changes and communicates with the background worker:

```javascript
// content-script.js
const PROCESSED_FILES = new WeakMap();

async function handleFileInput(input) {
 if (!input.accept?.includes('image')) return;

 input.addEventListener('change', async (event) => {
 const files = Array.from(event.target.files);
 const compressedFiles = [];

 for (const file of files) {
 if (!file.type.startsWith('image/')) continue;
 
 const response = await chrome.runtime.sendMessage({
 action: 'compress',
 file: file,
 options: {
 maxWidth: 2048,
 maxHeight: 2048,
 quality: 0.85
 }
 });

 if (response.blob) {
 const compressedFile = new File(
 [response.blob],
 file.name.replace(/\.[^.]+$/, '.jpg'),
 { type: 'image/jpeg' }
 );
 compressedFiles.push(compressedFile);
 PROCESSED_FILES.set(input, compressedFile);
 }
 }

 if (compressedFiles.length > 0) {
 const dataTransfer = new DataTransfer();
 compressedFiles.forEach(f => dataTransfer.items.add(f));
 input.files = dataTransfer.files;
 
 input.dispatchEvent(new Event('change', { bubbles: true }));
 }
 }, { once: true });
}

// Observe all file inputs on the page
const observer = new MutationObserver((mutations) => {
 mutations.forEach((mutation) => {
 mutation.addedNodes.forEach((node) => {
 if (node.tagName === 'INPUT' && node.type === 'file') {
 handleFileInput(node);
 }
 if (node.querySelectorAll) {
 node.querySelectorAll('input[type="file"]').forEach(handleFileInput);
 }
 });
 });
});

observer.observe(document.body, { childList: true, subtree: true });
```

## Background Worker Handling

Since extensions run in an isolated context, passing File objects directly to the background worker requires transferables or alternative approaches. One reliable method uses Message Channels for asynchronous processing:

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'compress') {
 compressInBackground(message.file, message.options)
 .then(blob => sendResponse({ blob }))
 .catch(err => sendResponse({ error: err.message }));
 return true; // Keep message channel open for async response
 }
});

async function compressInBackground(file, options) {
 // Use OffscreenCanvas in service worker context
 const offscreen = new OffscreenCanvas(100, 100);
 const ctx = offscreen.getContext('2d');
 
 const bitmap = await file.decode?.() || await createImageBitmap(file);
 
 let width = bitmap.width;
 let height = bitmap.height;
 const maxDim = options.maxWidth || 2048;
 
 if (width > maxDim || height > maxDim) {
 const ratio = Math.min(maxDim / width, maxDim / height);
 width = Math.floor(width * ratio);
 height = Math.floor(height * ratio);
 }
 
 offscreen.width = width;
 offscreen.height = height;
 ctx.drawImage(bitmap, 0, 0, width, height);
 
 return offscreen.convertToBlob({
 type: 'image/jpeg',
 quality: options.quality || 0.85
 });
}
```

## Handling Edge Cases

Several scenarios require additional consideration. Drag-and-drop zones do not use standard file inputs, so you need to intercept the drop event and process the DataTransfer object. Multiple file selection requires handling each file individually, with parallel processing. Form submissions where the form is populated programmatically may bypass input change listeners.

For drag-and-drop handling, add this to your content script:

```javascript
document.addEventListener('drop', async (event) => {
 const items = event.dataTransfer.items;
 if (!items) return;

 for (const item of items) {
 if (item.kind === 'file' && item.type.startsWith('image/')) {
 event.preventDefault();
 const file = item.getAsFile();
 // Process through compression pipeline
 const compressed = await compressImage(file);
 // Replace in dataTransfer
 event.dataTransfer.items.remove(item);
 event.dataTransfer.items.add(compressed);
 }
 }
}, true);
```

## Optimizing Performance

Processing large images can impact the browser UI thread. OffscreenCanvas in the background worker prevents interface freezing, but transferring large ImageBitmaps still carries overhead. Consider implementing progressive compression that starts with a lower quality preview and increases quality in the background.

Caching compressed results prevents re-compressing the same image during retries. Use a WeakMap to store results keyed by the original file reference:

```javascript
const COMPRESSION_CACHE = new WeakMap();

async function getCompressedImage(file, options) {
 const cached = COMPRESSION_CACHE.get(file);
 if (cached && cached.optionsMatch(options)) {
 return cached.blob;
 }

 const blob = await compressImage(file, options);
 COMPRESSION_CACHE.set(file, { blob, options, timestamp: Date.now() });
 return blob;
}
```

## Testing and Debugging

Use Chrome's extension debugging tools to verify the compression pipeline. The Application panel shows service worker state, while the Console logs messages from both content and background scripts. Test with various image formats including PNG, WebP, and HEIC (on supported systems) to ensure broad compatibility.

Monitor compression ratios in production by logging before and after file sizes:

```javascript
console.log(`Compressed ${file.name}: ${(file.size / 1024).toFixed(1)}KB → ${(blob.size / 1024).toFixed(1)}KB (${Math.round((1 - blob.size / file.size) * 100)}% reduction)`);
```

## Summary

Building an image compression Chrome extension requires understanding browser APIs, extension messaging patterns, and performance considerations. The Canvas and OffscreenCanvas APIs provide reliable cross-browser compression without server dependencies. By intercepting file inputs in content scripts and processing in the background worker, you can transparently reduce upload sizes while maintaining compatibility with existing web forms.

The implementation above provides a foundation that handles standard file inputs, drag-and-drop zones, and provides caching for repeated uploads. Adjust quality settings and maximum dimensions based on your specific use case requirements.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-compress-images-before-upload)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Edit Images: A Practical Guide for Developers](/chrome-extension-edit-images/)
- [Chrome Extension Resize Images: A Practical Guide for Developers](/chrome-extension-resize-images/)
- [AI Code Assistant Chrome Extension: Practical Guide for.](/ai-code-assistant-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

