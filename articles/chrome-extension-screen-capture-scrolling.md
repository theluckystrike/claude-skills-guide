---

layout: default
title: "Chrome Extension Screen Capture Scrolling: Complete Implementation Guide"
description: "Learn how to build Chrome extensions that capture scrolling screenshots. Practical code examples, APIs, and techniques for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-screen-capture-scrolling/
---

{% raw %}
# Chrome Extension Screen Capture Scrolling: Complete Implementation Guide

Building a Chrome extension that captures full-page screenshots of scrolling websites requires understanding several browser APIs and handling edge cases around dynamic content. This guide provides practical implementation patterns for developers who want to create robust screen capture tools.

## Understanding the Core Challenge

Standard screen capture APIs only capture what is visible in the viewport. When you need to capture an entire page that extends beyond the visible area, you must programmatically scroll through the page, capture each viewport, and stitch the images together. This introduces complexity around scroll position management, image stitching, and handling pages with lazy-loaded content.

The fundamental approach involves three steps: scroll to the top, capture the visible area, scroll down by the viewport height, repeat until reaching the bottom, then vertically concatenate all captured images.

## Setting Up Your Extension Project

Every Chrome extension requires a manifest file. For screen capture functionality, you need manifest V3 with specific permissions:

```json
{
  "manifest_version": 3,
  "name": "Full Page Screenshot",
  "version": "1.0",
  "permissions": ["activeTab", "scripting"],
  "action": {
    "default_popup": "popup.html"
  },
  "host_permissions": ["<all_urls>"]
}
```

The `activeTab` permission allows capture only on user-initiated actions, and `<all_urls>` grants access to capture any webpage. For production extensions, consider requesting host permissions more selectively.

## Capturing the Visible Viewport

The Chrome scripting API provides the ability to execute code within the context of the active tab. Your content script or injected function will use the `chrome.tabs.captureVisibleTab` method:

```javascript
async function captureViewport(tabId) {
  const dataUrl = await chrome.tabs.captureVisibleTab(tabId, {
    format: 'png',
    quality: 100
  });
  return dataUrl;
}
```

This returns a data URL containing the PNG image of the current viewport. For high-DPI displays, you may want to adjust the capture settings to account for device pixel ratio.

## Implementing the Scroll-and-Capture Loop

The core logic scrolls through the page and captures each segment:

```javascript
async function captureFullPage(tabId) {
  const viewportHeight = await chrome.tabs.executeScript(tabId, {
    code: 'window.innerHeight'
  });
  
  const totalHeight = await chrome.tabs.executeScript(tabId, {
    code: 'document.documentElement.scrollHeight'
  });
  
  const images = [];
  let currentPosition = 0;
  
  while (currentPosition < totalHeight) {
    await chrome.tabs.executeScript(tabId, {
      code: `window.scrollTo(0, ${currentPosition})`
    });
    
    // Wait for scroll to complete and any lazy content to load
    await new Promise(resolve => setTimeout(resolve, 300));
    
    const capture = await chrome.tabs.captureVisibleTab(tabId, {
      format: 'png',
      quality: 100
    });
    
    images.push(capture);
    currentPosition += viewportHeight[0];
  }
  
  // Restore original scroll position
  await chrome.tabs.executeScript(tabId, {
    code: 'window.scrollTo(0, 0)'
  });
  
  return images;
}
```

This basic implementation works for static pages but requires additional handling for dynamic content.

## Handling Dynamic and Lazy-Loaded Content

Modern websites load content dynamically as you scroll. To capture this content properly, you need to trigger the loading mechanisms before capturing each viewport segment.

For pages using infinite scroll, you can simulate scroll events to trigger content loading:

```javascript
async function scrollAndWaitForContent(tabId, viewportHeight) {
  const initialHeight = await chrome.tabs.executeScript(tabId, {
    code: 'document.documentElement.scrollHeight'
  });
  
  // Scroll to bottom briefly to trigger any lazy loading
  await chrome.tabs.executeScript(tabId, {
    code: 'window.scrollTo(0, document.documentElement.scrollHeight)'
  });
  
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  const newHeight = await chrome.tabs.executeScript(tabId, {
    code: 'document.documentElement.scrollHeight'
  });
  
  return { initialHeight: initialHeight[0], newHeight: newHeight[0] };
}
```

You may need to repeat this process multiple times for pages with extensive lazy loading, checking if the page height increases after each simulated scroll.

## Image Stitching on the Client Side

After capturing all viewport segments, you need to combine them into a single image. This typically happens in your extension's background script or a dedicated worker:

```javascript
function stitchImages(dataUrls) {
  return new Promise((resolve) => {
    const images = dataUrls.map(url => {
      const img = new Image();
      img.src = url;
      return img;
    });
    
    Promise.all(images.map(img => 
      new Promise(resolve => img.onload = resolve)
    )).then(() => {
      const canvas = document.createElement('canvas');
      const width = images[0].width;
      const height = images.reduce((sum, img) => sum + img.height, 0);
      
      canvas.width = width;
      canvas.height = height;
      
      const ctx = canvas.getContext('2d');
      let currentY = 0;
      
      images.forEach(img => {
        ctx.drawImage(img, 0, currentY);
        currentY += img.height;
      });
      
      resolve(canvas.toDataURL('image/png'));
    });
  });
}
```

The canvas approach gives you flexibility to add borders, watermarks, or other post-processing effects.

## Handling Fixed Elements and Overlays

A common problem with viewport capture is that fixed-position elements (headers, sidebars, popups) appear in every segment. To handle this, you can temporarily hide fixed elements before capturing:

```javascript
async function hideFixedElements(tabId) {
  await chrome.tabs.executeScript(tabId, {
    code: `
      document.querySelectorAll('header, footer, .fixed, [style*="position: fixed"]').forEach(el => {
        el.dataset.originalDisplay = el.style.display;
        el.style.display = 'none';
      });
    `
  });
}

async function restoreFixedElements(tabId) {
  await chrome.tabs.executeScript(tabId, {
    code: `
      document.querySelectorAll('[data-original-display]').forEach(el => {
        el.style.display = el.dataset.originalDisplay;
        delete el.dataset.originalDisplay;
      });
    `
  });
}
```

Run `hideFixedElements` before your capture loop and `restoreFixedElements` after completing the capture.

## Extension Architecture Recommendations

For production extensions, structure your code with clear separation of concerns:

- **Popup UI**: Handles user interaction and triggers capture
- **Background script**: Orchestrates the capture process and manages image processing
- **Content script**: Handles page-specific adjustments like hiding fixed elements

Consider adding options for users to configure capture quality, include/exclude certain page elements, and choose output formats.

## Common Pitfalls to Avoid

Several issues frequently trip up developers implementing scroll capture:

- **Race conditions**: Not waiting long enough after scroll events causes blurry or incomplete captures
- **Memory limits**: Capturing very long pages can exhaust memory; consider chunking and saving incrementally
- **Viewport dimensions**: Using `window.innerHeight` may not account for toolbars and browser chrome
- **Cross-origin frames**: Frames with cross-origin content may not capture correctly due to security restrictions

## Conclusion

Building a Chrome extension for full-page screen capture requires careful handling of scroll behavior, dynamic content loading, and image stitching. The patterns outlined here provide a solid foundation for creating robust capture tools. Start with the basic scroll-and-capture loop, then add sophistication as needed for specific use cases.

For further exploration, consider implementing features like automatic scrolling speed adjustment based on page complexity, support for horizontal scrolling pages, or integration with cloud storage APIs for automatic backup of captured images.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
