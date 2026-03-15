---
layout: default
title: "Building a Chrome Extension DOM Inspector Tool: A Developer's Guide"
description: "Learn how to build a Chrome extension DOM inspector tool from scratch. Complete implementation guide with code examples for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-dom-inspector-tool/
---

# Building a Chrome Extension DOM Inspector Tool

A DOM inspector lets you examine and manipulate the structure of any webpage in real time. While Chrome DevTools provides excellent built-in functionality, building your own extension gives you custom features, tighter workflow integration, and a deeper understanding of how browsers expose the DOM.

This guide walks through creating a functional Chrome extension that inspects DOM elements, displays their properties, and allows real-time attribute editing.

## Project Structure

A Chrome extension requires a manifest file and at least one background or content script. For a DOM inspector, you'll need:

```
dom-inspector/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
└── styles.css
```

The manifest defines permissions and entry points. The content script runs in the context of web pages, while the popup provides the extension's UI.

## Manifest Configuration

Your manifest.json defines the extension's capabilities:

```json
{
  "manifest_version": 3,
  "name": "Custom DOM Inspector",
  "version": "1.0",
  "description": "Inspect and edit DOM elements with custom tools",
  "permissions": ["activeTab", "scripting"],
  "host_permissions": ["<all_urls>"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"],
    "css": ["styles.css"]
  }]
}
```

The `activeTab` permission lets you interact with the currently open page. The `scripting` permission enables programmatic script injection when needed.

## Content Script: Element Selection

The content script handles element selection on the page. It listens for messages from the popup and highlights selected elements:

```javascript
// content.js
let currentElement = null;
let overlay = null;

// Create highlight overlay
function createOverlay() {
  overlay = document.createElement('div');
  overlay.id = 'dom-inspector-overlay';
  overlay.style.cssText = `
    position: absolute;
    border: 2px solid #0066ff;
    background: rgba(0, 102, 255, 0.1);
    pointer-events: none;
    z-index: 2147483647;
    display: none;
  `;
  document.body.appendChild(overlay);
}

function highlightElement(element) {
  if (!overlay) createOverlay();
  
  const rect = element.getBoundingClientRect();
  overlay.style.display = 'block';
  overlay.style.left = `${rect.left + window.scrollX}px`;
  overlay.style.top = `${rect.top + window.scrollY}px`;
  overlay.style.width = `${rect.width}px`;
  overlay.style.height = `${rect.height}px`;
  
  currentElement = element;
}

function clearHighlight() {
  if (overlay) {
    overlay.style.display = 'none';
  }
  currentElement = null;
}

// Handle messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'inspect') {
    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('click', handleClick, { once: true });
  } else if (request.action === 'stopInspecting') {
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('click', handleClick);
    clearHighlight();
  } else if (request.action === 'getElementInfo') {
    if (currentElement) {
      sendResponse({
        tagName: currentElement.tagName,
        id: currentElement.id,
        className: currentElement.className,
        attributes: Array.from(currentElement.attributes).map(attr => ({
          name: attr.name,
          value: attr.value
        })),
        innerHTML: currentElement.innerHTML.substring(0, 200),
        textContent: currentElement.textContent.substring(0, 200)
      });
    }
  }
  return true;
});

function handleMouseMove(event) {
  event.target.style.cursor = 'crosshair';
}

function handleClick(event) {
  event.preventDefault();
  event.stopPropagation();
  
  highlightElement(event.target);
  document.removeEventListener('mousemove', handleMouseMove);
  
  // Notify popup
  chrome.runtime.sendMessage({ 
    action: 'elementSelected',
    element: event.target.tagName 
  });
}
```

The script creates a visual overlay that follows hovered elements during inspection mode. When you click an element, it captures that element and reports back to the popup.

## Popup Interface

The popup provides buttons to start inspection and displays element information:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 320px; padding: 16px; font-family: system-ui, sans-serif; }
    button {
      width: 100%;
      padding: 10px;
      margin-bottom: 12px;
      background: #0066ff;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 14px;
    }
    button:hover { background: #0052cc; }
    button.active { background: #cc0000; }
    .info-section { margin-top: 12px; }
    .info-label { font-weight: bold; font-size: 12px; color: #666; }
    .info-value { font-size: 13px; word-break: break-all; margin-bottom: 8px; }
    .tag { color: #0066ff; font-weight: bold; }
  </style>
</head>
<body>
  <button id="inspectBtn">Start Inspection</button>
  
  <div id="elementInfo" style="display: none;">
    <div class="info-section">
      <div class="info-label">Tag</div>
      <div class="info-value" id="tagName"></div>
    </div>
    <div class="info-section">
      <div class="info-label">ID</div>
      <div class="info-value" id="elementId"></div>
    </div>
    <div class="info-section">
      <div class="info-label">Classes</div>
      <div class="info-value" id="elementClasses"></div>
    </div>
    <div class="info-section">
      <div class="info-label">Attributes</div>
      <div class="info-value" id="elementAttributes"></div>
    </div>
  </div>
  
  <script src="popup.js"></script>
</body>
</html>
```

## Popup Logic

The popup script manages the inspection workflow and displays collected element data:

```javascript
// popup.js
let isInspecting = false;

document.getElementById('inspectBtn').addEventListener('click', async () => {
  const btn = document.getElementById('inspectBtn');
  
  if (!isInspecting) {
    // Start inspection
    isInspecting = true;
    btn.textContent = 'Stop Inspection';
    btn.classList.add('active');
    
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    chrome.tabs.sendMessage(tab.id, { action: 'inspect' });
  } else {
    // Stop inspection
    isInspecting = false;
    btn.textContent = 'Start Inspection';
    btn.classList.remove('active');
    
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    chrome.tabs.sendMessage(tab.id, { action: 'stopInspecting' });
  }
});

// Listen for element selection
chrome.runtime.onMessage.addListener((request) => {
  if (request.action === 'elementSelected') {
    displayElementInfo();
  }
});

async function displayElementInfo() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getElementInfo' }, (info) => {
    if (!info) return;
    
    document.getElementById('elementInfo').style.display = 'block';
    document.getElementById('tagName').textContent = `<${info.tagName}>`;
    document.getElementById('elementId').textContent = info.id || '(none)';
    document.getElementById('elementClasses').textContent = info.className || '(none)';
    document.getElementById('elementAttributes').textContent = 
      info.attributes.map(a => `${a.name}="${a.value}"`).join(', ') || '(none)';
  });
}
```

## Loading Your Extension

To test the extension:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension folder
4. Navigate to any webpage and click the extension icon
5. Click "Start Inspection" and hover over elements
6. Click an element to see its properties

## Practical Applications

A custom DOM inspector becomes valuable in several scenarios:

**Automated testing verification** — Inspect elements to validate that your JavaScript frameworks render the expected structure. Capture element states during test failures.

**Accessibility auditing** — Quick inspection reveals missing ARIA attributes, improper heading hierarchies, or unlabeled interactive elements.

**Debugging dynamic content** — Single-page applications often modify the DOM extensively. A custom inspector helps track exactly what changes when interactions occur.

**Design system verification** — Confirm that components render with expected classes and data attributes across different pages.

## Extending the Inspector

Once the base works, consider adding these features:

- **Attribute editing** — Modify element attributes directly from the popup and see changes immediately
- **CSS inspection** — Display computed styles for selected elements
- **DOM tree navigation** — Show parent/child relationships in a collapsible tree view
- **Element search** — Find elements by selector or text content
- **Export functionality** — Copy element HTML or attributes to clipboard

The Chrome Extensions documentation provides comprehensive details on content scripts, message passing, and storage APIs. Start with the basics, then layer in features as your needs evolve.

Built by theluckystrike — More at [zovo.one](https://zovo.one)