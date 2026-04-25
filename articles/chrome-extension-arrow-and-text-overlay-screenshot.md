---

layout: default
title: "Chrome Extension Arrow and Text Overlay"
description: "Learn how to build a Chrome extension that captures screenshots with arrow and text overlays. Practical examples for developers and power users."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-arrow-and-text-overlay-screenshot/
reviewed: true
score: 8
categories: [integrations, guides]
tags: [chrome-extension, javascript, screenshot-api]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

# Chrome Extension Arrow and Text Overlay Screenshot Guide

Screenshot annotations have become essential for documentation, bug reporting, and communication. Building a Chrome extension that captures screenshots and allows users to add arrows and text overlays gives you full control over visual communication without relying on third-party services. This guide walks through the implementation, from browser permissions to canvas-based rendering.

## Understanding the Chrome Screenshot API

Chrome provides the `chrome.tabs.captureVisibleTab()` API for capturing screenshots of the current tab. This method returns a PNG data URL that you can manipulate using the HTML5 Canvas API. The key advantage is that users can capture exactly what they see, including dynamically rendered content.

```javascript
// background.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'captureScreenshot') {
 chrome.tabs.captureVisibleTab(
 { format: 'png', quality: 100 },
 (dataUrl) => {
 if (chrome.runtime.lastError) {
 sendResponse({ error: chrome.runtime.lastError.message });
 } else {
 sendResponse({ imageData: dataUrl });
 }
 }
 );
 return true; // Required for async response
 }
});
```

This basic capture gives you the foundation. Next, you need to build the overlay system that lets users draw arrows and add text.

## Project Structure

A well-organized extension structure keeps your code maintainable:

```
arrow-text-screenshot/
 manifest.json
 background.js
 popup.html
 popup.js
 editor.html
 editor.js
 styles.css
 icons/
 icon16.png
 icon48.png
 icon128.png
```

The manifest.json declares the necessary permissions:

```json
{
 "manifest_version": 3,
 "name": "Arrow & Text Screenshot",
 "version": "1.0",
 "permissions": ["activeTab", "tabCapture"],
 "host_permissions": ["<all_urls>"],
 "action": {
 "default_popup": "popup.html"
 }
}
```

## Building the Annotation Editor

The core of your extension is the canvas-based editor. This allows users to draw arrows and place text on top of the captured screenshot.

First, set up the HTML structure for the editor:

```html
<!-- editor.html -->
<!DOCTYPE html>
<html>
<head>
 <link rel="stylesheet" href="styles.css">
</head>
<body>
 <div class="toolbar">
 <button id="arrowTool">Arrow</button>
 <button id="textTool">Text</button>
 <button id="saveBtn">Save</button>
 </div>
 <canvas id="editorCanvas"></canvas>
 <script src="editor.js"></script>
</body>
</html>
```

Now implement the drawing logic in editor.js:

```javascript
// editor.js
let canvas, ctx;
let currentTool = 'arrow';
let annotations = [];
let isDrawing = false;
let startX, startY;

document.addEventListener('DOMContentLoaded', () => {
 canvas = document.getElementById('editorCanvas');
 ctx = canvas.getContext('2d');
 
 // Load the captured image
 const imageData = localStorage.getItem('screenshotData');
 if (imageData) {
 const img = new Image();
 img.onload = () => {
 canvas.width = img.width;
 canvas.height = img.height;
 ctx.drawImage(img, 0, 0);
 };
 img.src = imageData;
 }
 
 // Event listeners for drawing
 canvas.addEventListener('mousedown', startDrawing);
 canvas.addEventListener('mousemove', draw);
 canvas.addEventListener('mouseup', stopDrawing);
});

function startDrawing(e) {
 isDrawing = true;
 const rect = canvas.getBoundingClientRect();
 startX = e.clientX - rect.left;
 startY = e.clientY - rect.top;
}

function draw(e) {
 if (!isDrawing) return;
 
 const rect = canvas.getBoundingClientRect();
 const currentX = e.clientX - rect.left;
 const currentY = e.clientY - rect.top;
 
 // Redraw all annotations
 redrawCanvas();
 
 // Draw current annotation preview
 if (currentTool === 'arrow') {
 drawArrow(startX, startY, currentX, currentY, '#ff0000');
 }
}

function stopDrawing(e) {
 if (!isDrawing) return;
 isDrawing = false;
 
 const rect = canvas.getBoundingClientRect();
 const endX = e.clientX - rect.left;
 const endY = e.clientY - rect.top;
 
 annotations.push({
 type: currentTool,
 startX, startY,
 endX, endY,
 color: '#ff0000',
 text: currentTool === 'text' ? prompt('Enter text:') : null
 });
 
 redrawCanvas();
}
```

The arrow drawing function uses canvas paths to create professional-looking arrows:

```javascript
function drawArrow(fromX, fromY, toX, toY, color) {
 const headLength = 15;
 const angle = Math.atan2(toY - fromY, toX - fromX);
 
 ctx.strokeStyle = color;
 ctx.fillStyle = color;
 ctx.lineWidth = 3;
 
 // Draw the line
 ctx.beginPath();
 ctx.moveTo(fromX, fromY);
 ctx.lineTo(toX, toY);
 ctx.stroke();
 
 // Draw the arrowhead
 ctx.beginPath();
 ctx.moveTo(toX, toY);
 ctx.lineTo(
 toX - headLength * Math.cos(angle - Math.PI / 6),
 toY - headLength * Math.sin(angle - Math.PI / 6)
 );
 ctx.lineTo(
 toX - headLength * Math.cos(angle + Math.PI / 6),
 toY - headLength * Math.sin(angle + Math.PI / 6)
 );
 ctx.closePath();
 ctx.fill();
}

function redrawCanvas() {
 const imageData = localStorage.getItem('screenshotData');
 const img = new Image();
 img.onload = () => {
 ctx.drawImage(img, 0, 0);
 annotations.forEach(ann => {
 if (ann.type === 'arrow') {
 drawArrow(ann.startX, ann.startY, ann.endX, ann.endY, ann.color);
 } else if (ann.type === 'text') {
 ctx.font = '20px Arial';
 ctx.fillStyle = ann.color;
 ctx.fillText(ann.text, ann.startX, ann.startY);
 }
 });
 };
 img.src = imageData;
}
```

## Handling the Extension Workflow

The popup serves as the entry point, triggering the capture and opening the editor:

```javascript
// popup.js
document.getElementById('captureBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 chrome.tabs.sendMessage(tab.id, { action: 'capture' }, async (response) => {
 if (response && response.imageData) {
 localStorage.setItem('screenshotData', response.imageData);
 chrome.runtime.openOptionsPage();
 }
 });
});
```

The content script handles the actual capture within the page context:

```javascript
// content.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'capture') {
 chrome.tabs.captureVisibleTab(
 { format: 'png', quality: 100 },
 (dataUrl) => {
 sendResponse({ imageData: dataUrl });
 }
 );
 return true;
 }
});
```

## Advanced Features for Power Users

Consider implementing these enhancements for a more solid tool:

1. Color picker: Allow users to select custom colors for arrows and text
2. Undo/redo: Maintain a history stack of annotation states
3. Export formats: Support PNG, JPEG, and WebP output
4. Keyboard shortcuts: Add hotkeys for quick tool switching
5. Clipboard integration: Copy directly to clipboard after editing

The clipboard export feature is particularly useful:

```javascript
function copyToClipboard(canvas) {
 canvas.toBlob(blob => {
 const item = new ClipboardItem({ 'image/png': blob });
 navigator.clipboard.write([item]);
 });
}
```

## Step-by-Step: From Capture to Export

1. Navigate to the page you want to capture
2. Click the extension icon in the toolbar
3. The popup's capture button calls `chrome.tabs.captureVisibleTab`
4. The PNG data URL is passed to the editor page via `chrome.storage.session`
5. The editor canvas loads the image and waits for user input
6. Select "Arrow" mode and click-drag to place an arrow
7. Select "Text" mode, click a location, and type your annotation
8. Use the color picker to change annotation colors
9. Click "Save" to download the annotated PNG, or "Copy" to send directly to clipboard

## Advanced: Blur Tool for Sensitive Data

Screenshots for documentation often contain passwords or PII. Add a pixelate-to-blur region tool:

```javascript
function blurRegion(x, y, width, height, blockSize = 10) {
 const imageData = ctx.getImageData(x, y, width, height);
 for (let bx = 0; bx < width; bx += blockSize) {
 for (let by = 0; by < height; by += blockSize) {
 const idx = (by * width + bx) * 4;
 const r = imageData.data[idx];
 const g = imageData.data[idx + 1];
 const b = imageData.data[idx + 2];
 for (let px = bx; px < Math.min(bx + blockSize, width); px++) {
 for (let py = by; py < Math.min(by + blockSize, height); py++) {
 const i = (py * width + px) * 4;
 imageData.data[i] = r;
 imageData.data[i + 1] = g;
 imageData.data[i + 2] = b;
 }
 }
 }
 }
 ctx.putImageData(imageData, x, y);
}
```

## Advanced: Undo / Redo Stack

Implement an undo stack using annotation history:

```javascript
const history = [[]];
let historyIndex = 0;

function pushHistory() {
 history.splice(historyIndex + 1);
 history.push([...annotations]);
 historyIndex = history.length - 1;
}

function undo() {
 if (historyIndex > 0) {
 historyIndex--;
 annotations = [...history[historyIndex]];
 redrawCanvas();
 }
}

document.addEventListener('keydown', (e) => {
 if (e.ctrlKey && e.key === 'z') undo();
 if (e.ctrlKey && e.key === 'y') {
 if (historyIndex < history.length - 1) {
 historyIndex++;
 annotations = [...history[historyIndex]];
 redrawCanvas();
 }
 }
});
```

Call `pushHistory()` in `stopDrawing` after each annotation is committed.

## Comparison with Desktop Annotation Tools

| Tool | Setup | Blur tool | Clipboard export | Cost |
|---|---|---|---|---|
| This extension | Build yourself | Add it yourself | Yes (canvas.toBlob) | Free |
| Snagit | Desktop install | Yes | Yes | $62.99 |
| Greenshot | Desktop install | Yes | Yes | Free |
| CleanShot X (macOS) | Desktop install | Yes | Yes | $29 |

The extension wins on zero install friction. no desktop app required, works across all operating systems inside Chrome.

## Troubleshooting Common Issues

`captureVisibleTab` returning a blank image: Try `{ format: 'jpeg', quality: 90 }` as a fallback if the PNG capture returns blank on hardware-accelerated pages.

Canvas blurry on high-DPI displays: Account for `window.devicePixelRatio` when sizing the canvas:

```javascript
const dpr = window.devicePixelRatio || 1;
canvas.width = image.width * dpr;
canvas.height = image.height * dpr;
canvas.style.width = image.width + 'px';
canvas.style.height = image.height + 'px';
ctx.scale(dpr, dpr);
```

Clipboard API not working in extension context: The copy must be triggered directly by a button click. not from a `setTimeout` or async callback. to satisfy the user gesture requirement.

Editor page not opening: Register the editor as an options page or open it explicitly:

```javascript
chrome.tabs.create({ url: chrome.runtime.getURL('editor.html') });
```

## Security and Performance Considerations

- Request only the minimum necessary permissions (`activeTab` and `tabCapture` are sufficient for basic capture)
- Process heavy image operations in a background offscreen document using `chrome.offscreen` to avoid freezing the popup UI
- For extensions that handle sensitive documentation screenshots, add an auto-clear feature that removes the image from storage after a configurable timeout
- The blur tool is essential before sharing screenshots in public bug trackers or documentation systems

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-arrow-and-text-overlay-screenshot)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Keyword Density Checker: A Developer's Guide](/chrome-extension-keyword-density-checker/)
- [Colorpick Eyedropper Alternative Chrome Extension in 2026](/colorpick-eyedropper-alternative-chrome-extension-2026/)
- [Chrome Enterprise VPN Integration - A Practical Guide.](/chrome-enterprise-vpn-integration/)
- [Best Screenshot Chrome Extensions 2026](/best-screenshot-chrome-extension-2026/)
- [Webcam Overlay Recording Chrome Extension Guide (2026)](/chrome-extension-webcam-overlay-recording/)
- [AI Text Expander Chrome Extension Guide (2026)](/ai-text-expander-chrome-extension/)
- [Full Page Screenshot Chrome Extension](/full-page-screenshot-chrome-extension/)
- [Chrome Extension Highlight Text Save](/chrome-extension-highlight-text-save/)
- [Awesome Screenshot Alternative — Developer Comparison 2026](/awesome-screenshot-alternative-chrome-extension-2026/)
- [Text To Speech Chrome Extension Guide (2026)](/chrome-extension-text-to-speech/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


