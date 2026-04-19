---
layout: default
title: "Auto Meeting Summary Chrome Extension Guide (2026)"
description: "Build a Chrome extension that automatically captures and summarizes meeting transcripts. Complete implementation guide with code examples for developers."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [chrome-extension, meeting-summary, productivity, javascript, manifest-v3, claude-skills]
author: "Claude Skills Guide"
permalink: /chrome-extension-auto-meeting-summary/
reviewed: true
score: 8
geo_optimized: true
---
Chrome extensions have transformed how we capture and process information from web-based meeting platforms. Building an auto meeting summary extension requires understanding browser APIs, content scripts, and message passing between different extension components. This guide walks you through creating a functional Chrome extension that captures meeting transcripts and generates summaries automatically.

## Understanding the Architecture

A meeting summary extension operates across three distinct contexts: the content script runs within the meeting page, the background service worker handles long-running tasks, and the popup provides user controls. Each component has specific permissions and capabilities that determine what you can capture.

Modern Chrome extensions use Manifest V3, which imposes restrictions on background pages. Instead of persistent background scripts, you work with service workers that activate on events and terminate after periods of inactivity. This architecture affects how you handle transcript capture and processing.

The core workflow involves detecting meeting activity, capturing transcript data from the DOM or via accessibility APIs, storing the data locally using chrome.storage, and processing it when the meeting ends.

## Setting Up the Manifest

Your extension begins with the manifest file that declares capabilities and permissions:

```json
{
 "manifest_version": 3,
 "name": "Auto Meeting Summary",
 "version": "1.0",
 "description": "Automatically capture and summarize meeting transcripts",
 "permissions": [
 "storage",
 "activeTab",
 "scripting"
 ],
 "host_permissions": [
 "*://*.zoom.us/*",
 "*://*.meet.google.com/*",
 "*://*.teams.microsoft.com/*"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html"
 },
 "content_scripts": [{
 "matches": [
 "*://*.zoom.us/*",
 "*://*.meet.google.com/*",
 "*://*.teams.microsoft.com/*"
 ],
 "js": ["content.js"],
 "run_at": "document_idle"
 }]
}
```

Notice the host permissions target specific meeting platforms. You should limit permissions to only the domains you intend to support rather than using broad wildcards.

## Capturing Meeting Transcripts

Content scripts run in the context of the meeting page and can access the DOM. Different platforms expose transcripts through varying mechanisms. Google Meet, for instance, displays captions in the DOM that you can observe:

```javascript
// content.js - Transcript capture for Google Meet
let transcriptData = [];
let observer = null;

function startCapturing() {
 // Find caption containers - selectors vary by platform
 const captionSelector = '.iYTRBd, [aria-label*="closed caption"]';
 
 observer = new MutationObserver((mutations) => {
 mutations.forEach((mutation) => {
 mutation.addedNodes.forEach((node) => {
 if (node.nodeType === Node.ELEMENT_NODE) {
 const text = node.textContent?.trim();
 if (text && text.length > 5 && text.length < 500) {
 const entry = {
 timestamp: new Date().toISOString(),
 text: text,
 speaker: detectSpeaker(node)
 };
 transcriptData.push(entry);
 }
 }
 });
 });
 });
 
 const target = document.querySelector('body');
 observer.observe(target, {
 childList: true,
 subtree: true,
 characterData: true
 });
}

function detectSpeaker(node) {
 // Platform-specific speaker detection
 const speakerElement = node.closest('[data-speaker-name]') 
 || node.querySelector('[data-speaker-name]');
 return speakerElement?.dataset.speakerName || 'Unknown';
}

function stopCapturing() {
 if (observer) {
 observer.disconnect();
 observer = null;
 }
 return transcriptData;
}

// Message handling for background script communication
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'getTranscript') {
 sendResponse({ transcript: transcriptData });
 } else if (message.action === 'startCapture') {
 startCapturing();
 sendResponse({ status: 'capturing' });
 } else if (message.action === 'stopCapture') {
 const data = stopCapturing();
 sendResponse({ transcript: data });
 }
 return true;
});
```

This approach uses MutationObserver to detect new caption elements as they appear. The selector strategy requires platform-specific tuning since each meeting service structures their DOM differently.

## Background Service Worker

The service worker orchestrates the extension lifecycle and handles storage:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 chrome.storage.local.set({ meetings: [], isCapturing: false });
});

// Listen for tab updates to detect meeting pages
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
 if (changeInfo.status === 'complete' && tab.url) {
 const meetingDomains = ['zoom.us', 'meet.google.com', 'teams.microsoft.com'];
 const isMeeting = meetingDomains.some(domain => tab.url.includes(domain));
 
 if (isMeeting) {
 chrome.action.setBadgeText({ tabId, text: '' });
 chrome.action.setBadgeBackgroundColor({ tabId, color: '#4CAF50' });
 }
 }
});

// Handle messages from popup or content scripts
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'saveMeeting') {
 chrome.storage.local.get(['meetings'], (result) => {
 const meetings = result.meetings || [];
 const newMeeting = {
 id: Date.now(),
 url: sender.tab?.url,
 transcript: message.transcript,
 summary: message.summary,
 timestamp: new Date().toISOString()
 };
 meetings.push(newMeeting);
 chrome.storage.local.set({ meetings });
 sendResponse({ saved: true });
 });
 return true;
 }
 
 if (message.action === 'getMeetings') {
 chrome.storage.local.get(['meetings'], (result) => {
 sendResponse({ meetings: result.meetings || [] });
 });
 return true;
 }
});
```

The badge indicator provides visual feedback when the extension detects an active meeting page. This creates immediate user awareness without requiring popup interaction.

## Implementing Summary Generation

Rather than embedding complex NLP logic in the extension, you can use external APIs for summarization. This keeps your extension lightweight and avoids API key exposure by handling requests server-side or through a proxy:

```javascript
// summary.js - Client-side summary generation
async function generateSummary(transcript) {
 const combinedText = transcript.map(t => t.text).join(' ');
 
 // Truncate for API limits
 const truncatedText = combinedText.slice(0, 10000);
 
 try {
 const response = await fetch('YOUR_SUMMARY_API_ENDPOINT', {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({
 text: truncatedText,
 max_length: 300
 })
 });
 
 const data = await response.json();
 return data.summary;
 } catch (error) {
 console.error('Summary generation failed:', error);
 return generateSimpleSummary(transcript);
 }
}

function generateSimpleSummary(transcript) {
 // Fallback: extract key sentences based on length and position
 const sentences = transcript
 .map(t => t.text)
 .join('. ')
 .split(/[.!?]+/)
 .filter(s => s.trim().length > 20);
 
 // First and last sentences plus middle ones
 const first = sentences[0] || '';
 const last = sentences[sentences.length - 1] || '';
 const middle = sentences.slice(1, -1).filter((_, i) => i % 3 === 0);
 
 return [first, ...middle, last].join('. ').trim();
}
```

The simple fallback ensures users always receive some form of summary even when external APIs fail. This improves reliability for critical meeting capture scenarios.

## Building the Popup Interface

The popup provides manual controls for starting and stopping capture:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 300px; padding: 16px; font-family: system-ui, sans-serif; }
 button { width: 100%; padding: 10px; margin: 8px 0; cursor: pointer; }
 .start { background: #4CAF50; color: white; border: none; }
 .stop { background: #f44336; color: white; border: none; }
 #status { margin-top: 12px; padding: 8px; border-radius: 4px; }
 .capturing { background: #e8f5e9; }
 .idle { background: #f5f5f5; }
 </style>
</head>
<body>
 <h3>Meeting Summary</h3>
 <button id="startBtn" class="start">Start Capture</button>
 <button id="stopBtn" class="stop">Stop & Summarize</button>
 <div id="status" class="idle">Status: Idle</div>
 <div id="summary"></div>
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.getElementById('startBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 chrome.tabs.sendMessage(tab.id, { action: 'startCapture' });
 updateStatus('Capturing meeting...', 'capturing');
});

document.getElementById('stopBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 
 chrome.tabs.sendMessage(tab.id, { action: 'stopCapture' }, async (response) => {
 const summary = await generateSummary(response.transcript);
 
 chrome.runtime.sendMessage({
 action: 'saveMeeting',
 transcript: response.transcript,
 summary: summary
 });
 
 displaySummary(summary);
 updateStatus('Meeting saved', 'idle');
 });
});

function updateStatus(text, className) {
 const status = document.getElementById('status');
 status.textContent = `Status: ${text}`;
 status.className = className;
}

function displaySummary(summary) {
 document.getElementById('summary').innerHTML = 
 `<h4>Summary:</h4><p>${summary}</p>`;
}
```

## Considerations for Production

Real-world deployment requires handling several edge cases. Captions may not appear in the DOM on all platforms, particularly when using native applications or browser extensions from meeting providers. You might need to explore the chrome.debugger API for caption access or accept that some platforms require user-initiated transcript export.

Rate limiting and quota management matter for API-based summaries. Implement caching to avoid regenerating summaries for unchanged transcripts, and consider using chrome.storage.session for temporary data during active meetings.

Privacy concerns affect user adoption. Clearly communicate what data your extension captures, offer opt-in settings for cloud sync, and store sensitive transcripts locally by default.

Building a solid auto meeting summary extension takes iteration across different platforms. Start with one meeting provider, perfect the transcript capture for that specific platform, then expand to others. The architecture outlined here provides a foundation you can adapt based on your target users' preferred meeting tools.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-auto-meeting-summary)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Screen Recorder for Meetings: A.](/chrome-extension-screen-recorder-meetings/)
- [Chrome Extension Development in 2026: A Practical Manifest V3 Guide](/chrome-extension-development-2026/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [Meeting Scheduler Chrome Extension Guide (2026)](/meeting-scheduler-chrome-extension/)
- [AI Youtube Summary Chrome Extension Guide (2026)](/ai-youtube-summary-chrome-extension/)
- [Meeting Transcription Live Chrome Extension Guide (2026)](/chrome-extension-meeting-transcription-live/)
- [Time Zone Meeting Planner Chrome Extension Guide (2026)](/chrome-extension-time-zone-meeting-planner/)
- [Auto Summarize Articles Chrome Extension Guide (2026)](/chrome-extension-auto-summarize-articles/)
- [Auto Caption Video Chrome Extension Guide (2026)](/chrome-extension-auto-caption-video/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


