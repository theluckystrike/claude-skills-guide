---

layout: default
title: "Building a Chrome Extension for Timezone Conversion in."
description: "Learn how to build a Chrome extension that handles timezone conversion for remote teams. Includes practical code examples and implementation patterns."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-timezone-converter-remote/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


Building a Chrome extension for timezone conversion solves a real pain point for remote teams. When you're coordinating across time zones, manually calculating meeting times or checking multiple time conversion websites becomes tedious. A well-designed Chrome extension puts timezone conversion directly in your browser, making it accessible whenever you need it.

This guide walks through building a Chrome extension that converts timezones, with a focus on remote team workflows. You'll find practical code examples that you can adapt for your own use cases.

## Understanding the Core Requirements

A timezone converter Chrome extension needs several key capabilities:

1. **Detect or accept input times** in various formats
2. **Store multiple timezone preferences** for quick access
3. **Convert between timezones accurately**, accounting for daylight saving time
4. **Display results clearly** in the extension popup or on web pages
5. **Handle edge cases** like invalid inputs and timezone boundary issues

Modern JavaScript provides robust date handling through the `Intl` API and `Date` object, reducing the need for external libraries.

## Project Structure

A typical Chrome extension for timezone conversion includes these files:

```
timezone-converter/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
├── styles.css
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```

The manifest file defines the extension's capabilities and permissions.

## Implementing the Manifest

The manifest version 3 format provides the foundation for your extension:

```json
{
  "manifest_version": 3,
  "name": "Timezone Converter for Remote Teams",
  "version": "1.0.0",
  "description": "Convert timezones easily for remote team coordination",
  "permissions": ["storage", "activeTab"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "icons": {
    "16": "icons/icon16.png",
    "48": "icons/icon48.png",
    "128": "icons/icon128.png"
  }
}
```

## Building the Popup Interface

The popup provides the main user interface for quick conversions. Keep it lightweight and focused on the primary use case.

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="converter-container">
    <h2>Timezone Converter</h2>
    
    <div class="input-group">
      <label for="time-input">Time</label>
      <input type="time" id="time-input" value="12:00">
    </div>
    
    <div class="input-group">
      <label for="source-timezone">From Timezone</label>
      <select id="source-timezone"></select>
    </div>
    
    <div class="input-group">
      <label for="target-timezone">To Timezone</label>
      <select id="target-timezone"></select>
    </div>
    
    <button id="convert-btn">Convert</button>
    
    <div id="result" class="result-box"></div>
    
    <div class="saved-zones">
      <h3>Quick Zones</h3>
      <div id="quick-zones"></div>
    </div>
  </div>
  
  <script src="popup.js"></script>
</body>
</html>
```

## JavaScript Implementation

The core conversion logic uses JavaScript's `Intl` API for accurate timezone handling:

```javascript
// Get list of all supported timezones
function getTimezoneList() {
  return Intl.supportedValuesOf('timeZone');
}

// Convert time between timezones
function convertTime(timeStr, sourceZone, targetZone) {
  const [hours, minutes] = timeStr.split(':').map(Number);
  
  // Create a date in the source timezone
  const now = new Date();
  const sourceDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 
                               hours, minutes, 0);
  
  // Get the ISO string and append the source timezone
  const sourceISO = sourceDate.toLocaleString('en-US', { 
    timeZone: sourceZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  });
  
  // Parse and convert to target timezone
  const targetOptions = {
    timeZone: targetZone,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    weekday: 'short',
    month: 'short',
    day: 'numeric'
  };
  
  const formatter = new Intl.DateTimeFormat('en-US', targetOptions);
  const targetDate = new Date(sourceDate.toLocaleString('en-US', { timeZone: sourceZone }));
  
  return formatter.format(targetDate);
}

// Populate timezone dropdowns
function populateTimezones() {
  const timezones = getTimezoneList();
  const sourceSelect = document.getElementById('source-timezone');
  const targetSelect = document.getElementById('target-timezone');
  
  timezones.forEach(tz => {
    const option1 = new Option(tz, tz);
    const option2 = new Option(tz, tz);
    sourceSelect.add(option1);
    targetSelect.add(option2);
  });
  
  // Set defaults
  sourceSelect.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
  targetSelect.value = 'UTC';
}
```

## Adding Remote Team Features

For remote teams, storing common team timezones makes the extension more useful:

```javascript
// Save a frequently used timezone pair
function saveQuickZone(name, timezone) {
  chrome.storage.local.get(['quickZones'], (result) => {
    const zones = result.quickZones || [];
    zones.push({ name, timezone });
    chrome.storage.local.set({ quickZones: zones });
    renderQuickZones();
  });
}

// Display saved zones for one-click conversion
function renderQuickZones() {
  chrome.storage.local.get(['quickZones'], (result) => {
    const container = document.getElementById('quick-zones');
    const zones = result.quickZones || [];
    
    container.innerHTML = zones.map(zone => `
      <button class="quick-zone-btn" data-zone="${zone.timezone}">
        ${zone.name} (${zone.timezone})
      </button>
    `).join('');
  });
}
```

## Content Script for Page Analysis

For power users, you can add a content script that detects times on web pages and offers conversion:

```javascript
// content.js - Run on web pages
function detectTimesOnPage() {
  const textNodes = document.evaluate(
    '//text()[contains(., "AM") or contains(., "PM") or contains(., ":00")]',
    document,
    null,
    XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
    null
  );
  
  // Analyze detected times and offer conversion overlay
  for (let i = 0; i < textNodes.snapshotLength; i++) {
    const node = textNodes.snapshotItem(i);
    // Add click listener to offer conversion
    node.addEventListener('click', () => showConversionPopup(node.textContent));
  }
}

function showConversionPopup(originalText) {
  // Implementation for inline conversion popup
  const popup = document.createElement('div');
  popup.className = 'tz-converter-popup';
  popup.textContent = `Convert "${originalText}"?`;
  document.body.appendChild(popup);
}
```

## Styling for Usability

Clean styling makes the extension pleasant to use:

```css
.converter-container {
  width: 320px;
  padding: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.input-group {
  margin-bottom: 12px;
}

.input-group label {
  display: block;
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.input-group input,
.input-group select {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.result-box {
  margin-top: 16px;
  padding: 12px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 16px;
  font-weight: 500;
}

.quick-zone-btn {
  display: block;
  width: 100%;
  margin: 4px 0;
  padding: 6px 10px;
  background: #e8f0fe;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  text-align: left;
}

.quick-zone-btn:hover {
  background: #d2e3fc;
}
```

## Deployment and Testing

To test your extension locally:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select your extension directory
4. The extension icon appears in your browser toolbar

For distribution through the Chrome Web Store, you'll need to create a developer account and package your extension as a ZIP file.

## Extensions for Common Remote Team Scenarios

Consider adding these features based on your team's needs:

- **Meeting planner**: Visual timeline showing overlap working hours across timezones
- **World clock dashboard**: Display multiple clocks in the popup
- **Meeting link generator**: Create calendar links with converted times
- **Notification system**: Alert when meeting times approach in any timezone

## Conclusion

Building a timezone converter Chrome extension combines web development skills with practical utility for remote teams. The extension uses JavaScript's native `Intl` API for accurate conversions without heavy dependencies. Start with the core conversion functionality, then add features like saved timezones and page-level detection as your users request them.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
