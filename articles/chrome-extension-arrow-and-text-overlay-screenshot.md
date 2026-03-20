---

layout: default
title: "Chrome Extension Arrow and Text Overlay Screenshot Guide"
description: "Learn how to build a Chrome extension that captures screenshots with arrow and text overlays. Practical examples for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-arrow-and-text-overlay-screenshot/
reviewed: true
score: 8
categories: [integrations, guides]
tags: [chrome-extension, javascript, screenshot-api]
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
├── manifest.json
├── background.js
├── popup.html
├── popup.js
├── editor.html
├── editor.js
├── styles.css
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
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

Consider implementing these enhancements for a more robust tool:

1. **Color picker**: Allow users to select custom colors for arrows and text
2. **Undo/redo**: Maintain a history stack of annotation states
3. **Export formats**: Support PNG, JPEG, and WebP output
4. **Keyboard shortcuts**: Add hotkeys for quick tool switching
5. **Clipboard integration**: Copy directly to clipboard after editing

The clipboard export feature is particularly useful:

```javascript
function copyToClipboard(canvas) {
  canvas.toBlob(blob => {
    const item = new ClipboardItem({ 'image/png': blob });
    navigator.clipboard.write([item]);
  });
}
```

## Security and Performance Considerations

When building screenshot extensions, keep these best practices in mind:

- Request only the permissions your extension actually needs
- Process images in the background script to avoid UI blocking
- Use `chrome.offscreen` API for heavy image processing
- Implement rate limiting to prevent abuse

For extensions that handle sensitive data, consider adding a blur option for masking sensitive information before export.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
