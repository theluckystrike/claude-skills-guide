---
sitemap: false

layout: default
title: "Build a Watermark Images Chrome (2026)"
description: "Claude Code extension tip: build a Chrome extension that adds watermarks to images before download. Covers Canvas API overlay, text positioning,..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-watermark-images/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
last_tested: "2026-04-21"
---

# How to Build a Chrome Extension for Watermarking Images

Building a Chrome extension for watermarking images is a practical project that combines web development skills with real utility. Whether you need to protect your photography, add branding to screenshots, or automate batch processing, a custom extension gives you full control without relying on third-party services.

This guide walks through creating a functional image watermarking extension from scratch. You'll learn the core APIs, understand the extension architecture, and have working code you can extend for your specific needs.

## Extension Architecture Overview

A Chrome extension for image watermarking consists of three main components:

1. Manifest file - Defines permissions and extension structure
2. Content script - Injected into web pages to detect images
3. Background script - Handles processing logic and file operations
4. Popup UI - User interface for configuring watermark settings

For watermarking specifically, you'll work primarily with the Canvas API for image manipulation and the Chrome Downloads API for saving processed images.

## Setting Up the Manifest

Your extension begins with the manifest.json file. This configuration declares what your extension can access:

```json
{
 "manifest_version": 3,
 "name": "Image Watermark Pro",
 "version": "1.0",
 "description": "Add custom watermarks to images on any webpage",
 "permissions": [
 "activeTab",
 "downloads",
 "scripting"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
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

The manifest_version 3 is the current standard. Key permissions include `activeTab` for accessing the current page, `downloads` for saving processed images, and `scripting` for executing code in page contexts.

## The Popup Interface

The popup provides the user interface where users configure their watermark settings. Create a simple HTML form:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 300px; padding: 16px; font-family: system-ui; }
 .form-group { margin-bottom: 12px; }
 label { display: block; margin-bottom: 4px; font-size: 12px; }
 input, select { width: 100%; padding: 8px; box-sizing: border-box; }
 button { width: 100%; padding: 10px; background: #4a90d9; color: white; border: none; cursor: pointer; }
 button:hover { background: #357abd; }
 </style>
</head>
<body>
 <h3>Image Watermark</h3>
 <div class="form-group">
 <label>Watermark Text</label>
 <input type="text" id="watermarkText" placeholder="© Your Name">
 </div>
 <div class="form-group">
 <label>Position</label>
 <select id="position">
 <option value="bottom-right">Bottom Right</option>
 <option value="bottom-left">Bottom Left</option>
 <option value="top-right">Top Right</option>
 <option value="top-left">Top Left</option>
 <option value="center">Center</option>
 </select>
 </div>
 <div class="form-group">
 <label>Font Size</label>
 <input type="number" id="fontSize" value="24">
 </div>
 <div class="form-group">
 <label>Opacity (0-1)</label>
 <input type="number" id="opacity" value="0.5" step="0.1" min="0" max="1">
 </div>
 <button id="processBtn">Apply Watermark</button>
 <script src="popup.js"></script>
</body>
</html>
```

This popup collects all necessary configuration. The form includes text input, position selection, font size, and opacity controls.

## Core Watermarking Logic

The actual image processing happens through the Canvas API. Here's a solid implementation:

```javascript
async function watermarkImage(imageUrl, settings) {
 return new Promise((resolve, reject) => {
 const img = new Image();
 img.crossOrigin = 'anonymous';
 
 img.onload = () => {
 const canvas = document.createElement('canvas');
 const ctx = canvas.getContext('2d');
 
 canvas.width = img.width;
 canvas.height = img.height;
 
 // Draw original image
 ctx.drawImage(img, 0, 0);
 
 // Configure watermark text
 ctx.font = `${settings.fontSize}px Arial`;
 ctx.fillStyle = `rgba(255, 255, 255, ${settings.opacity})`;
 ctx.textAlign = 'center';
 ctx.textBaseline = 'middle';
 
 // Calculate text position
 const textMetrics = ctx.measureText(settings.text);
 const textWidth = textMetrics.width;
 const textHeight = settings.fontSize;
 
 let x, y;
 const padding = 20;
 
 switch (settings.position) {
 case 'bottom-right':
 x = canvas.width - textWidth / 2 - padding;
 y = canvas.height - textHeight - padding;
 break;
 case 'bottom-left':
 x = textWidth / 2 + padding;
 y = canvas.height - textHeight - padding;
 break;
 case 'top-right':
 x = canvas.width - textWidth / 2 - padding;
 y = textHeight + padding;
 break;
 case 'top-left':
 x = textWidth / 2 + padding;
 y = textHeight + padding;
 break;
 case 'center':
 default:
 x = canvas.width / 2;
 y = canvas.height / 2;
 }
 
 // Draw shadow for better visibility
 ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
 ctx.shadowBlur = 4;
 ctx.shadowOffsetX = 2;
 ctx.shadowOffsetY = 2;
 
 // Draw watermark
 ctx.fillText(settings.text, x, y);
 
 resolve(canvas.toDataURL('image/png'));
 };
 
 img.onerror = reject;
 img.src = imageUrl;
 });
}
```

This function loads an image, creates an off-screen canvas, draws the original image, then overlays the watermark text at the calculated position. The shadow effect improves text visibility on any background.

## Connecting Popup to Content Script

The popup communicates with content scripts through message passing. In your popup.js:

```javascript
document.getElementById('processBtn').addEventListener('click', async () => {
 const settings = {
 text: document.getElementById('watermarkText').value,
 position: document.getElementById('position').value,
 fontSize: parseInt(document.getElementById('fontSize').value),
 opacity: parseFloat(document.getElementById('opacity').value)
 };
 
 // Get active tab and send message to content script
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 chrome.tabs.sendMessage(tab.id, { action: 'processImages', settings }, async (response) => {
 if (response && response.processed) {
 // Download the watermarked image
 for (const dataUrl of response.images) {
 await chrome.downloads.download({
 url: dataUrl,
 filename: `watermarked_${Date.now()}.png`
 });
 }
 }
 });
});
```

The content script listens for these messages and processes images on the page.

## Content Script Implementation

The content script runs in the context of web pages and handles image detection:

```javascript
// content.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'processImages') {
 processPageImages(message.settings).then(results => {
 sendResponse({ processed: true, images: results });
 });
 return true; // Keep message channel open for async response
 }
});

async function processPageImages(settings) {
 const images = document.querySelectorAll('img');
 const results = [];
 
 for (const img of images) {
 try {
 // Skip tiny images and icons
 if (img.naturalWidth < 100 || img.naturalHeight < 100) continue;
 
 const watermarked = await watermarkImage(img.src, settings);
 results.push(watermarked);
 } catch (e) {
 console.error('Failed to process image:', e);
 }
 }
 
 return results;
}

// Include watermarkImage function here (same as above)
```

This script finds all meaningful images on the page and applies the watermark to each one.

## Handling Cross-Origin Images

A common challenge is watermarking images from different domains. The Canvas API throws a security error when trying to export tainted canvases. Solutions include:

1. Use CORS-enabled images - Add `crossorigin="anonymous"` to image requests
2. Proxy through your server - Fetch images server-side with proper CORS headers
3. Use the ImageCapture API - For captured media streams

For most web images, adding `crossOrigin: 'anonymous'` to the image loading code works. Some sites require server-side proxying.

## Advanced: Adding Image Upload

For users who want to watermark local images, add a file input to your popup:

```javascript
document.getElementById('uploadBtn').addEventListener('change', async (e) => {
 const file = e.target.files[0];
 if (!file) return;
 
 const reader = new FileReader();
 reader.onload = async (event) => {
 const settings = getSettingsFromForm();
 const watermarked = await watermarkImage(event.target.result, settings);
 
 await chrome.downloads.download({
 url: watermarked,
 filename: `watermarked_${file.name}`
 });
 };
 reader.readAsDataURL(file);
});
```

This allows processing images that haven't been uploaded to the web yet.

## Deployment Steps

To publish your extension:

1. Test locally - Load unpacked in chrome://extensions
2. Create icons - 16x16, 48x48, and 128x128 PNG files
3. Prepare screenshots - Create 1280x800 PNG screenshots for the store
4. Zip your files - Include manifest, HTML, JS, CSS, and icons
5. Submit to Chrome Web Store - $5 one-time developer registration fee

## Conclusion

Building an image watermarking extension demonstrates practical use of Chrome extension APIs while creating a genuinely useful tool. The Canvas API provides powerful image manipulation capabilities, and the extension architecture cleanly separates UI, logic, and content interaction.

From here, you can extend functionality by adding custom logo uploads, batch processing controls, different watermark styles (tiled, diagonal), or integration with cloud storage. The foundation established here scales to more complex image processing workflows.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-watermark-images)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Flashcard Maker Chrome Extension: Build Your Own Learning Tool](/ai-flashcard-maker-chrome-extension/)
- [AI Quiz Generator Chrome Extension: Build Your Own Quiz Tool](/ai-quiz-generator-chrome-extension/)
- [AI Reply Generator Chrome Extension for Gmail: Build.](/ai-reply-generator-chrome-extension-gmail/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

