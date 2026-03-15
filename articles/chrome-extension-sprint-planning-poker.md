---


layout: default
title: "Chrome Extension Sprint Planning Poker: Build Your Own Agile Estimation Tool"
description: "Learn how to build a Chrome extension for sprint planning poker. Practical code examples, architecture patterns, and implementation strategies for developers."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-sprint-planning-poker/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
---


# Chrome Extension Sprint Planning Poker: Build Your Own Agile Estimation Tool

Sprint planning poker has become an essential tool for Agile teams seeking consensus on story point estimates. While many teams rely on standalone web applications, building a Chrome extension for sprint planning poker offers unique advantages: offline capability, tight integration with project management tools, and complete control over the user experience. This guide walks you through building a functional sprint planning poker Chrome extension from scratch.

## Why Build a Chrome Extension for Sprint Planning Poker

Browser-based planning poker tools require internet connectivity and often come with feature limitations or subscription costs. A custom Chrome extension gives you several benefits that standalone tools cannot match.

First, you gain offline functionality. Teams working in locations with unreliable internet or those who prefer local-first tools can continue estimating stories without disruption. Second, you can integrate directly with your existing project management system—whether Jira, Linear, or a custom solution—by reading page content and injecting estimates automatically. Third, you own the data. No third-party servers store your estimation history, making compliance with data residency requirements straightforward.

The extension architecture also allows you to use Chrome's native capabilities, including storage synchronization across devices, native notifications, and the ability to interact with any webpage your team uses.

## Project Structure and Manifest Configuration

Every Chrome extension begins with a manifest file that defines capabilities and permissions. For a sprint planning poker extension, you'll need the following structure:

```
sprint-poker-extension/
├── manifest.json
├── popup.html
├── popup.js
├── content.js
├── background.js
├── styles.css
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```

Your manifest.json defines the extension's configuration:

```json
{
  "manifest_version": 3,
  "name": "Sprint Planning Poker",
  "version": "1.0.0",
  "description": "Agile estimation tool for sprint planning",
  "permissions": [
    "storage",
    "activeTab",
    "notifications"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }]
}
```

The manifest declares three key permissions. Storage allows persisting estimation history and user preferences across sessions. ActiveTab enables the extension to interact with the currently visible page for integration purposes. Notifications provide feedback when team members submit estimates.

## Core Functionality: The Estimation Interface

The popup interface serves as the primary user interaction point. When clicked, it displays the estimation interface where users select their vote:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="poker-container">
    <h2>Planning Poker</h2>
    <div class="session-info">
      <input type="text" id="sessionId" placeholder="Session ID">
      <button id="joinSession">Join</button>
    </div>
    <div class="card-selection">
      <button class="poker-card" data-value="1">1</button>
      <button class="poker-card" data-value="2">2</button>
      <button class="poker-card" data-value="3">3</button>
      <button class="poker-card" data-value="5">5</button>
      <button class="poker-card" data-value="8">8</button>
      <button class="poker-card" data-value="13">13</button>
      <button class="poker-card" data-value="21">21</button>
      <button class="poker-card" data-value="?">?</button>
    </div>
    <div class="vote-status" id="voteStatus"></div>
    <button id="revealVotes" class="action-btn">Reveal Votes</button>
    <button id="clearVotes" class="action-btn secondary">Clear</button>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

The card values follow the standard Fibonacci sequence used in many Agile teams, though you can customize these based on your team's preferences.

## Managing State and Synchronization

The extension needs to handle both local state and synchronization with other team members. Chrome's storage API provides the foundation:

```javascript
// background.js - handles cross-tab communication
chrome.storage.sync.get(['votes', 'sessionId'], (result) => {
  const votes = result.votes || {};
  const sessionId = result.sessionId || null;
  
  // Broadcast vote updates to all extension views
  chrome.runtime.sendMessage({
    type: 'VOTE_UPDATE',
    votes: votes,
    sessionId: sessionId
  });
});

// Listen for votes from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'SUBMIT_VOTE') {
    const { sessionId, userId, vote, userName } = message;
    
    chrome.storage.sync.get(['votes'], (result) => {
      const votes = result.votes || {};
      votes[userId] = { vote, userName, timestamp: Date.now() };
      
      chrome.storage.sync.set({ votes }, () => {
        // Notify all connected clients
        chrome.runtime.sendMessage({
          type: 'VOTE_UPDATE',
          votes: votes,
          sessionId: sessionId
        });
        sendResponse({ success: true });
      });
    });
    return true;
  }
});
```

This pattern uses Chrome's message passing system to keep all extension views synchronized. When a user submits a vote, the background script updates storage and broadcasts the change to every open popup and content script.

## Content Script Integration

For deeper integration with project management tools, the content script can read page context and suggest estimations:

```javascript
// content.js
// Extracts story information from Jira, Linear, or similar tools
function extractStoryInfo() {
  const storyPatterns = {
    'jira': {
      id: '[data-testid="issue-key"]',
      title: '[data-testid="issue-title"]',
      description: '[data-testid="issue-description"]'
    },
    'linear': {
      id: '[data-issue-id]',
      title: '[data-keyboard-shortcut="Issue: View issue details"]',
      description: '.issue-description'
    }
  };
  
  // Detect which tool is active
  for (const [tool, selectors] of Object.entries(storyPatterns)) {
    const element = document.querySelector(selectors.id);
    if (element) {
      return {
        tool: tool,
        id: element.textContent.trim(),
        title: document.querySelector(selectors.title)?.textContent.trim(),
        description: document.querySelector(selectors.description)?.textContent.trim()
      };
    }
  }
  return null;
}

// Send story info to popup when requested
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'GET_STORY_INFO') {
    const storyInfo = extractStoryInfo();
    sendResponse(storyInfo);
  }
});
```

This enables the extension to display relevant story context directly in the estimation interface, helping team members make more informed estimates.

## Styling the Extension

A clean, functional design improves adoption. Use CSS variables for theming and keep the interface focused:

```css
/* styles.css */
:root {
  --primary: #4f46e5;
  --primary-hover: #4338ca;
  --bg: #ffffff;
  --surface: #f9fafb;
  --text: #111827;
  --border: #e5e7eb;
}

.poker-container {
  width: 320px;
  padding: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.card-selection {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin: 16px 0;
}

.poker-card {
  padding: 12px 8px;
  border: 2px solid var(--border);
  border-radius: 8px;
  background: var(--bg);
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s ease;
}

.poker-card:hover {
  border-color: var(--primary);
  background: var(--surface);
}

.poker-card.selected {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
}
```

## Local Storage for Offline Support

Implementing offline capability requires careful handling of storage and synchronization logic:

```javascript
// popup.js - offline vote handling
class VoteManager {
  constructor() {
    this.offlineQueue = [];
    this.isOnline = navigator.onLine;
    
    window.addEventListener('online', () => this.syncOfflineVotes());
    window.addEventListener('offline', () => this.handleOffline());
  }
  
  async submitVote(sessionId, userId, vote) {
    const voteData = {
      sessionId,
      userId,
      vote,
      timestamp: Date.now(),
      synced: this.isOnline
    };
    
    if (!this.isOnline) {
      this.offlineQueue.push(voteData);
      this.saveToLocalStorage();
      return { status: 'offline', queued: true };
    }
    
    return this.submitToServer(voteData);
  }
  
  async syncOfflineVotes() {
    const queued = this.loadFromLocalStorage();
    for (const vote of queued) {
      await this.submitToServer(vote);
    }
    this.offlineQueue = [];
    this.clearLocalStorage();
  }
}
```

This class queues votes locally when offline and automatically syncs them when connectivity returns, ensuring no estimation data is lost.

## Deployment and Testing

To test your extension during development, navigate to `chrome://extensions` in Chrome, enable Developer mode, and click "Load unpacked". Select your extension directory. The extension reloads automatically when you make changes to the files.

For team distribution, package the extension using the "Pack extension" button in the developer tools, which generates a .crx file. You can distribute this directly to team members or publish to the Chrome Web Store after creating a developer account.

## Summary

Building a Chrome extension for sprint planning poker gives your team complete control over the estimation experience. The architecture demonstrated here—using manifest V3, Chrome storage APIs, and content scripts—provides a solid foundation that scales from simple local tools to fully synchronized team applications. You can extend this further with features like estimation history tracking, integration with more project management tools, or real-time collaboration through WebSockets.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
