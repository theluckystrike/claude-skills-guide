---

layout: default
title: "Chrome Extension Workload Balance Tracker: A Developer's."
description: "Learn how to build a Chrome extension that tracks and balances your workload across projects. Practical code examples and implementation tips for."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-workload-balance-tracker/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


Building a Chrome extension for workload balance tracking gives developers and power users a powerful tool to manage their time across multiple projects. Unlike generic time trackers, a workload balance tracker helps you understand how your effort is distributed and alerts you when certain projects or task types receive too much or too little attention.

This guide walks you through creating a Chrome extension that monitors your active browsing time, categorizes it by project, and provides insights into your workload distribution.

## Understanding the Core Architecture

A workload balance tracker Chrome extension relies on several key components: the background service worker for tracking time, the storage system for persisting data, and the popup UI for displaying current status. The extension must track which tabs are active and for how long, then categorize this time based on URL patterns or user-defined rules.

The manifest V3 structure forms the foundation:

```json
{
  "manifest_version": 3,
  "name": "Workload Balance Tracker",
  "version": "1.0",
  "permissions": ["activeTab", "storage", "tabs"],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  }
}
```

The `activeTab` permission grants access to the currently active tab when the user invokes the extension, while `tabs` permission provides the ability to query all open tabs and detect URL changes across windows.

## Tracking Active Tab Time

The core functionality involves detecting when the active tab changes and recording the duration spent on each URL. Here's how to implement the time tracking logic:

```javascript
// background.js
let activeTabId = null;
let startTime = null;

chrome.tabs.onActivated.addListener(async (activeInfo) => {
  if (activeTabId) {
    await recordTime(activeTabId);
  }
  activeTabId = activeInfo.tabId;
  startTime = Date.now();
});

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tabId === activeTabId) {
    recordTime(tabId).then(() => {
      startTime = Date.now();
    });
  }
});

async function recordTime(tabId) {
  if (!startTime) return;
  
  const duration = Date.now() - startTime;
  const tab = await chrome.tabs.get(tabId);
  const category = categorizeUrl(tab.url);
  
  await updateStorage(category, duration);
}

function categorizeUrl(url) {
  // Map URLs to project categories
  const patterns = {
    'github': /github\.com/,
    'jira': /jira\./,
    'docs': /docs\./,
    'email': /mail\.|gmail\./
  };
  
  for (const [category, pattern] of Object.entries(patterns)) {
    if (pattern.test(url)) return category;
  }
  return 'other';
}
```

This implementation records time spent on each category whenever the user switches tabs or a page finishes loading. The `categorizeUrl` function uses regex patterns to classify URLs into projects like GitHub, Jira, documentation, or email.

## Data Storage and Retrieval

Chrome's storage API provides the persistence layer. Using `chrome.storage.local` keeps data on the user's machine without requiring a backend:

```javascript
async function updateStorage(category, duration) {
  const result = await chrome.storage.local.get(category);
  const current = result[category] || { total: 0, sessions: 0 };
  
  current.total += duration;
  current.sessions += 1;
  
  const data = {};
  data[category] = current;
  await chrome.storage.local.set(data);
}
```

For more complex analysis, you might want to store timestamps for each session:

```javascript
async function logSession(category, duration) {
  const session = {
    timestamp: Date.now(),
    duration: duration,
    date: new Date().toISOString().split('T')[0]
  };
  
  const key = `sessions_${category}`;
  const result = await chrome.storage.local.get(key);
  const sessions = result[key] || [];
  
  sessions.push(session);
  
  // Keep only last 30 days
  const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
  const filtered = sessions.filter(s => s.timestamp > thirtyDaysAgo);
  
  await chrome.storage.local.set({ [key]: filtered });
}
```

## Building the Popup Interface

The popup displays current workload distribution and allows quick configuration:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; padding: 16px; font-family: system-ui; }
    .stat { margin: 8px 0; }
    .bar { height: 20px; background: #e0e0e0; border-radius: 4px; overflow: hidden; }
    .fill { height: 100%; background: #4285f4; transition: width 0.3s; }
    .category { display: flex; justify-content: space-between; font-size: 12px; }
  </style>
</head>
<body>
  <h3>Workload Balance</h3>
  <div id="stats"></div>
  <button id="exportBtn">Export Data</button>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const stats = document.getElementById('stats');
  const data = await chrome.storage.local.get(null);
  
  let totalTime = 0;
  for (const key in data) {
    if (data[key].total) totalTime += data[key].total;
  }
  
  for (const [category, info] of Object.entries(data)) {
    if (!info.total) continue;
    const percentage = (info.total / totalTime * 100).toFixed(1);
    const hours = (info.total / 3600000).toFixed(1);
    
    stats.innerHTML += `
      <div class="stat">
        <div class="category">
          <span>${category}</span>
          <span>${hours}h (${percentage}%)</span>
        </div>
        <div class="bar">
          <div class="fill" style="width: ${percentage}%"></div>
        </div>
      </div>
    `;
  }
});
```

## Adding Balance Alerts

To make the extension truly useful for workload management, implement threshold alerts:

```javascript
async function checkBalance() {
  const data = await chrome.storage.local.get(null);
  const thresholds = await chrome.storage.local.get('thresholds');
  
  const totalTime = Object.values(data).reduce((sum, item) => 
    sum + (item.total || 0), 0);
  
  for (const [category, info] of Object.entries(data)) {
    const percentage = (info.total / totalTime) * 100;
    const threshold = thresholds[category] || 40;
    
    if (percentage > threshold) {
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icon.png',
        title: 'Workload Alert',
        message: `${category} at ${percentage.toFixed(1)}% (threshold: ${threshold}%)`
      });
    }
  }
}
```

Run this check periodically using Chrome's alarms API:

```javascript
chrome.alarms.create('balanceCheck', { periodInMinutes: 30 });
chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'balanceCheck') checkBalance();
});
```

## Practical Use Cases

This extension serves multiple scenarios. Developers tracking time across repositories, Jira tickets, and documentation can identify when they're spending too much time in one area. Freelancers managing multiple client projects get visibility into how their browser time allocates to each client. Researchers can track time spent on different sources and publications.

The exported data integrates with external tools for billing or reporting. A CSV export feature converts stored sessions into spreadsheet-compatible format:

```javascript
document.getElementById('exportBtn').addEventListener('click', async () => {
  const data = await chrome.storage.local.get(null);
  let csv = 'Category,Date,Duration (ms),Sessions\n';
  
  for (const [key, value] of Object.entries(data)) {
    if (key.startsWith('sessions_')) {
      const category = key.replace('sessions_', '');
      for (const session of value) {
        csv += `${category},${session.date},${session.duration},1\n`;
      }
    }
  }
  
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  chrome.downloads.download({ url, filename: 'workload_data.csv' });
});
```

## Extending the Implementation

Beyond the core functionality, consider adding these features: project switching that automatically categorizes based on active project context, Pomodoro-style work intervals with break reminders, weekly reports emailed or saved to cloud storage, and integration with task management APIs to correlate time with specific tasks or issues.

The extension architecture supports easy expansion. Adding new categories requires only updating the pattern matching logic. Storage scaling handles extended use through periodic cleanup of old sessions and optional cloud sync for users who need cross-device access.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
