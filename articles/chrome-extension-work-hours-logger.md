---
layout: default
title: "Work Hours Logger Chrome Extension"
description: "Claude Code extension tip: learn how to build and use Chrome extensions for tracking work hours. Explore implementation patterns, time tracking APIs,..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-work-hours-logger/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
---
Time tracking remains a persistent challenge for developers and professionals working in browser-centric environments. Whether you're billing clients, tracking project hours, or analyzing your productivity patterns, a well-built Chrome extension work hours logger can automate much of this manual effort. This guide explores how these extensions work, what APIs they use, and how developers can build custom solutions.

## How Chrome Extension Work Hours Loggers Work

Chrome extensions that track work hours typically operate through one or more of these mechanisms:

1. Active tab tracking. Monitoring which tab is currently active and for how long
2. Domain-based categorization. Grouping time by website or application domain
3. Manual time entry. Providing interfaces for users to log their hours explicitly
4. Idle detection. Identifying when the user is away from their machine

Most production extensions combine these approaches. The simplest implementations start with active tab tracking, then add layers of sophistication as users request more detailed reporting.

## Key Chrome APIs for Time Tracking

Building a work hours logger requires familiarity with several Chrome extension APIs:

chrome.idle

The idle API detects when a user is away from their machine:

```javascript
chrome.idle.setDetectionInterval(60); // Detect idle after 60 seconds

chrome.idle.onStateChanged.addListener((newState) => {
 if (newState === 'idle') {
 // User went idle. pause tracking
 console.log('User became idle at:', new Date());
 } else if (newState === 'active') {
 // User returned. resume tracking
 console.log('User became active at:', new Date());
 }
});
```

This API helps prevent tracking time when you're away from your desk, making your logs more accurate.

chrome.history

The history API provides access to browsing history, enabling domain-based time categorization:

```javascript
chrome.history.search({
 text: '',
 startTime: Date.now() - 86400000, // Last 24 hours
 maxResults: 10000
}, (results) => {
 const domainTime = {};
 
 results.forEach((item) => {
 const domain = new URL(item.url).hostname;
 const duration = item.lastVisitTime - (item.lastVisitTime - (item.visitDuration || 0));
 
 domainTime[domain] = (domainTime[domain] || 0) + (item.visitDuration || 0);
 });
 
 console.log('Time by domain:', domainTime);
});
```

chrome.storage

For persisting tracked time data locally:

```javascript
// Save work session
chrome.storage.local.set({
 workSessions: [{
 start: Date.now() - 3600000,
 end: Date.now(),
 domain: 'github.com',
 project: 'client-project'
 }]
});

// Retrieve sessions
chrome.storage.local.get(['workSessions'], (result) => {
 console.log('Stored sessions:', result.workSessions);
});
```

## Building a Simple Work Hours Logger

Here's a minimal implementation that tracks active tab time:

manifest.json

```json
{
 "manifest_version": 3,
 "name": "Work Hours Logger",
 "version": "1.0",
 "permissions": ["activeTab", "storage", "idle"],
 "background": {
 "service_worker": "background.js"
 }
}
```

background.js

```javascript
let currentTab = null;
let sessionStart = Date.now();

function getCurrentTab() {
 return chrome.tabs.query({ active: true, currentWindow: true })
 .then(tabs => tabs[0]);
}

function logSession(tab) {
 if (!tab || !tab.url || tab.url.startsWith('chrome://')) return;
 
 const duration = Date.now() - sessionStart;
 const session = {
 url: tab.url,
 title: tab.title,
 startTime: sessionStart,
 endTime: Date.now(),
 duration: duration
 };
 
 chrome.storage.local.get(['sessions'], (result) => {
 const sessions = result.sessions || [];
 sessions.push(session);
 chrome.storage.local.set({ sessions });
 });
}

// Track tab changes
chrome.tabs.onActivated.addListener(async (activeInfo) => {
 const newTab = await chrome.tabs.get(activeInfo.tabId);
 
 if (currentTab) {
 logSession(currentTab);
 }
 
 currentTab = newTab;
 sessionStart = Date.now();
});

// Track window focus changes
chrome.windows.onFocusChanged.addListener((windowId) => {
 if (windowId === chrome.windows.WINDOW_ID_NONE && currentTab) {
 logSession(currentTab);
 currentTab = null;
 }
});
```

This basic implementation captures how long you spend on each tab. Extend it with idle detection to exclude away time, and add a popup UI for manual categorization.

## Features Power Users Should Look For

When evaluating or building a work hours logger, these features distinguish basic trackers from powerful productivity tools:

Project and client tagging. The ability to assign time entries to specific projects or clients is essential for freelancers and agencies billing hourly.

Export capabilities. CSV, JSON, and integration with invoicing tools like FreshBooks or QuickBooks save hours of manual data entry.

Daily/weekly summaries. Visual dashboards showing where your time goes help identify productivity patterns and potential time sinks.

Idle detection tuning. Customizable idle thresholds matter because everyone has different work patterns. Some people take long breaks; others switch context frequently.

Cross-browser sync. If you use multiple browsers, syncing data across them provides a complete picture of your work time.

## Popular Chrome Extensions for Work Hours Logging

Several extensions implement these patterns:

Toggl Track offers one of the most solid implementations with project management, client billing, and detailed reporting. The Chrome extension integrates with their web timer and provides one-click tracking from browser tabs.

Clockwise focuses on calendar-based time tracking, showing how your meetings consume your day and identifying optimization opportunities.

 rescuetime takes a passive approach, tracking all browser activity automatically and providing weekly productivity scores. It categorizes sites as productive or distracting without manual input.

ActivityWatch takes a developer-friendly approach, open-source, self-hosted, and highly customizable. It runs locally, giving you complete control over your data.

## Building for Specific Use Cases

A chrome extension work hours logger for developers might track time spent in documentation, code review, and issue tracking. Customize your implementation by filtering domains:

```javascript
const PROJECT_DOMAINS = {
 'github.com': 'coding',
 'stackoverflow.com': 'research',
 'notion.so': 'documentation',
 'linear.app': 'project-management'
};

function categorizeSession(url) {
 const domain = new URL(url).hostname;
 return PROJECT_DOMAINS[domain] || 'other';
}
```

For agencies tracking multiple clients, add client-based grouping and rate configuration per project. Store rates in chrome.storage.sync to keep them consistent across devices.

## Privacy Considerations

Work hours loggers collect sensitive data about your activity. Consider these privacy aspects when building or choosing an extension:

Local storage vs cloud sync. Local-only storage keeps your data on your machine but prevents cross-device access. Cloud sync enables convenience but introduces data handling by third parties.

Data retention policies. How long does the extension keep historical data? Can you export and delete everything?

Permissions requested. Extensions requesting access to "all sites" can see everything you do. Minimize permissions to what's strictly necessary for the tracking functionality.

Building your own logger gives you complete control over these decisions. Self-hosting with ActivityWatch or similar tools puts you in charge of your data.

---

Whether you need simple time tracking for personal productivity or detailed billing for client work, a chrome extension work hours logger can automate the process. Start with active tab tracking, add idle detection for accuracy, and layer on project categorization as your needs grow. The Chrome APIs provide everything needed to build powerful time tracking directly in your browser.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-work-hours-logger)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)
- [AI Code Assistant Chrome Extension: Practical Guide for.](/ai-code-assistant-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)




