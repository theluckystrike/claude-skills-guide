---


layout: default
title: "Chrome Extension Arrow and Text Overlay Screenshot: A."
description: "Learn how to build a Chrome extension that adds arrows and text overlays to screenshots. Complete implementation guide with code examples for developers."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-arrow-and-text-overlay-screenshot/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


# Chrome Extension Arrow and Text Overlay Screenshot: A Developer Guide

Building a Chrome extension that captures screenshots and allows users to add arrows and text overlays transforms how you document bugs, create tutorials, and communicate visual feedback. This guide walks you through building a fully functional screenshot annotation extension from scratch.

## Understanding the Core Architecture

A screenshot annotation extension requires three main components working together. First, the content script captures the visible page or selected region. Second, an overlay canvas sits on top of the captured image where users draw annotations. Third, the background service worker handles storage and export operations.

The Chrome APIs you will use most frequently include `chrome.tabs.captureVisibleTab` for capturing screenshots, `chrome.downloads` for saving files, and the HTML5 Canvas API for rendering arrows and text. Each piece serves a specific purpose in creating a seamless user experience.

## Setting Up the Extension Structure

Create your extension directory with the following file structure:

```
screenshot-annotator/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
├── background.js
└── styles.css
```

Your manifest.json defines the extension capabilities:

```json
{
  "manifest_version": 3,
  "name": "Screenshot Annotator",
  "version": "1.0",
  "description": "Capture screenshots with arrow and text annotations",
  "permissions": ["tabs", "downloads", "activeTab"],
  "action": {
    "default_popup": "popup.html"
  },
  "host_permissions": ["<all_urls>"]
}
```

The `activeTab` permission is critical here because it limits the extension to only accessing the current active tab, which simplifies the approval process for the Chrome Web Store.

## Implementing Screenshot Capture

The capture functionality lives in your popup script. When users click the extension icon, you trigger the screenshot capture process:

```javascript
// popup.js
document.getElementById('captureBtn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  // Capture the visible area of the tab
  const dataUrl = await chrome.tabs.captureVisibleTab(tab.windowId, {
    format: 'png'
  });
  
  // Store for later use in the annotation editor
  localStorage.setItem('pendingScreenshot', dataUrl);
  window.open('editor.html');
});
```

This approach captures the entire visible viewport. If you need region selection, you would implement a click-and-drag selector in your content script before capturing.

## Building the Annotation Canvas

The editor page contains a canvas element where users draw their annotations. You load the captured image as a canvas background, then layer user interactions on top:

```javascript
// editor.js
const canvas = document.getElementById('editorCanvas');
const ctx = canvas.getContext('2d');
const img = new Image();

img.onload = () => {
  canvas.width = img.width;
  canvas.height = img.height;
  ctx.drawImage(img, 0, 0);
};

img.src = localStorage.getItem('pendingScreenshot');
```

The key to smooth annotation drawing is maintaining a state object that tracks each annotation. When users add an arrow, you store its start point, end point, color, and thickness. When they add text, you store the text content, position, font size, and color.

## Drawing Arrows with Canvas

Arrows require calculating the angle between start and end points, then drawing both the line and the arrowhead:

```javascript
function drawArrow(ctx, startX, startY, endX, endY, color, lineWidth) {
  const headLength = 15;
  const angle = Math.atan2(endY - startY, endX - startX);
  
  ctx.beginPath();
  ctx.moveTo(startX, startY);
  ctx.lineTo(endX, endY);
  ctx.strokeStyle = color;
  ctx.lineWidth = lineWidth;
  ctx.stroke();
  
  // Draw arrowhead
  ctx.beginPath();
  ctx.moveTo(endX, endY);
  ctx.lineTo(
    endX - headLength * Math.cos(angle - Math.PI / 6),
    endY - headLength * Math.sin(angle - Math.PI / 6)
  );
  ctx.lineTo(
    endX - headLength * Math.cos(angle + Math.PI / 6),
    endY - headLength * Math.sin(angle + Math.PI / 6)
  );
  ctx.closePath();
  ctx.fillStyle = color;
  ctx.fill();
}
```

This function handles the geometry calculations. You call it within your mouse event handlers when the user is drawing an arrow annotation.

## Adding Text Overlays

Text overlays require tracking mouse position and rendering text with a background rectangle for readability:

```javascript
function drawText(ctx, text, x, y, fontSize, color) {
  ctx.font = `${fontSize}px Arial`;
  const metrics = ctx.measureText(text);
  const padding = 8;
  
  // Draw background rectangle
  ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
  ctx.fillRect(
    x - padding,
    y - fontSize,
    metrics.width + padding * 2,
    fontSize + padding
  );
  
  // Draw text
  ctx.fillStyle = color;
  ctx.fillText(text, x, y);
}
```

The background rectangle ensures text remains readable regardless of the underlying screenshot content. Adjust the opacity and padding values based on user preferences.

## Managing Annotation State

Store all annotations in an array that you update as users add new elements:

```javascript
let annotations = [];

function addAnnotation(type, data) {
  annotations.push({ type, data, id: Date.now() });
  redrawCanvas();
}

function redrawCanvas() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.drawImage(img, 0, 0);
  
  annotations.forEach(ann => {
    if (ann.type === 'arrow') {
      drawArrow(ctx, ann.data.startX, ann.data.startY, 
                ann.data.endX, ann.data.endY, 
                ann.data.color, ann.data.lineWidth);
    } else if (ann.type === 'text') {
      drawText(ctx, ann.data.text, ann.data.x, ann.data.y,
               ann.data.fontSize, ann.data.color);
    }
  });
}
```

This approach makes undo functionality straightforward—you simply remove the last item from the array and call `redrawCanvas()`.

## Exporting the Final Image

When users finish their annotations, export the canvas to a PNG file:

```javascript
function saveScreenshot() {
  canvas.toBlob(async (blob) => {
    const url = URL.createObjectURL(blob);
    await chrome.downloads.download({
      url: url,
      filename: `screenshot-${Date.now()}.png`,
      saveAs: true
    });
  }, 'image/png');
}
```

The `chrome.downloads.download` API triggers the browser's download manager, giving users control over where to save the file.

## Adding Undo and Clear Functionality

Power users expect undo capability. Add keyboard shortcuts and buttons:

```javascript
document.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
    annotations.pop();
    redrawCanvas();
  }
});

document.getElementById('clearBtn').addEventListener('click', () => {
  annotations = [];
  redrawCanvas();
});
```

These handlers integrate smoothly with the annotation system you built earlier.

## Security and Performance Considerations

When handling screenshots, be mindful of memory usage. Large screenshots can consume significant RAM, so consider resizing images that exceed 4000 pixels in either dimension. Also, always validate any data passed between your popup and editor windows to prevent injection attacks.

For extensions that will be published, ensure you declare all permissions explicitly in the manifest. The Chrome Web Store rejects extensions that request unnecessary permissions or use evaluation-only APIs.

## Summary

Building a Chrome extension for screenshot annotation requires understanding how capture, canvas rendering, and state management work together. The core pattern involves capturing the visible tab, rendering annotations on a canvas layer, maintaining an annotation array for undo support, and exporting the final result through the downloads API.

With these fundamentals, you can extend the extension to support shapes, freehand drawing, blur regions for privacy, and team collaboration features. The architecture scales well because each annotation type is independent—adding new drawing tools requires only new render functions and state entries.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
