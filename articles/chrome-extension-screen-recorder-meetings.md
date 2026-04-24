---
layout: default
title: "Screen Recorder Meetings Chrome (2026)"
description: "Learn how to build a Chrome extension that records screen and audio during meetings. Complete implementation guide with code examples for developers."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-screen-recorder-meetings/
categories: [guides]
tags: [chrome-extension, screen-recorder, meetings, javascript, manifest-v3, productivity, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---
## Chrome Extension Screen Recorder for Meetings: A Developer Guide

Building a Chrome extension for screen recording during meetings opens up powerful possibilities for developers and power users who need to capture, review, and share meeting content. Whether you're creating documentation, conducting code reviews, or archiving important discussions, a well-built screen recorder extension provides significant value.

This guide walks you through building a functional Chrome extension that captures screen, audio, and meeting content using modern web APIs.

## Understanding Chrome Screen Recording Capabilities

Chrome provides the `getDisplayMedia` API, which enables web applications to request screen capture. This API is the foundation for any screen recording extension. Combined with the MediaStream Recording API, you can capture video and audio streams and save them as video files.

The key APIs you'll work with include:

- getDisplayMedia(): Initiates screen capture via browser prompt
- MediaRecorder: Records media streams into chunks
- chrome.storage: Persists recordings locally
- chrome.downloads: Saves files to the user's device

Chrome extensions benefit from additional capabilities compared to regular web apps. Extensions can use background service workers for continuous recording, popup interfaces for quick controls, and context menus for recording initiation.

## Project Structure

Create your extension with the following structure:

```
screen-recorder/
 manifest.json
 popup.html
 popup.js
 background.js
 content.js
 recorder.js
 icons/
 icon16.png
 icon48.png
 icon128.png
```

## Setting Up the Manifest

Your manifest.json declares the necessary permissions for screen capture and file storage:

```json
{
 "manifest_version": 3,
 "name": "Meeting Screen Recorder",
 "version": "1.0",
 "description": "Record screen and audio during meetings",
 "permissions": [
 "storage",
 "downloads",
 "activeTab",
 "scripting"
 ],
 "host_permissions": [
 "*://*.zoom.us/*",
 "*://*.meet.google.com/*",
 "*://*.teams.microsoft.com/*",
 "*://*.webex.com/*"
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
 "icons": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
}
```

The `host_permissions` section includes common meeting platforms. Adjust these based on your target use cases.

## Implementing the Core Recorder

Create a `recorder.js` module that handles the recording logic:

```javascript
class MeetingRecorder {
 constructor() {
 this.mediaRecorder = null;
 this.recordedChunks = [];
 this.stream = null;
 this.startTime = null;
 }

 async startRecording(options = {}) {
 const defaultOptions = {
 video: true,
 audio: true,
 systemAudio: false
 };

 const finalOptions = { ...defaultOptions, ...options };

 try {
 // Request screen capture
 const displayStream = await navigator.mediaDevices.getDisplayMedia({
 video: {
 displaySurface: 'monitor'
 },
 audio: finalOptions.systemAudio
 });

 // Combine with microphone if requested
 if (finalOptions.audio) {
 const audioStream = await navigator.mediaDevices.getUserMedia({
 audio: {
 echoCancellation: true,
 noiseSuppression: true,
 sampleRate: 44100
 }
 });

 // Combine audio tracks
 const audioTracks = audioStream.getAudioTracks();
 displayStream.addTrack(audioTracks[0]);
 }

 this.stream = displayStream;
 this.recordedChunks = [];
 this.startTime = Date.now();

 // Set up MediaRecorder
 const mimeType = this.getSupportedMimeType();
 this.mediaRecorder = new MediaRecorder(this.stream, {
 mimeType,
 videoBitsPerSecond: 2500000 // 2.5 Mbps
 });

 this.mediaRecorder.ondataavailable = (event) => {
 if (event.data.size > 0) {
 this.recordedChunks.push(event.data);
 }
 };

 // Handle stream ending (user stops sharing)
 this.stream.getVideoTracks()[0].onended = () => {
 this.stopRecording();
 };

 this.mediaRecorder.start(1000); // Collect data every second
 return true;

 } catch (error) {
 console.error('Recording failed:', error);
 throw error;
 }
 }

 getSupportedMimeType() {
 const types = [
 'video/webm;codecs=vp9,opus',
 'video/webm;codecs=vp8,opus',
 'video/webm'
 ];

 for (const type of types) {
 if (MediaRecorder.isTypeSupported(type)) {
 return type;
 }
 }
 return 'video/webm';
 }

 stopRecording() {
 return new Promise((resolve) => {
 if (!this.mediaRecorder || this.mediaRecorder.state === 'inactive') {
 resolve(null);
 return;
 }

 this.mediaRecorder.onstop = () => {
 const blob = new Blob(this.recordedChunks, {
 type: this.getSupportedMimeType()
 });

 const duration = Math.round((Date.now() - this.startTime) / 1000);
 const filename = `meeting-recording-${Date.now()}.webm`;

 resolve({
 blob,
 filename,
 duration,
 startTime: this.startTime
 });
 };

 // Stop all tracks
 this.stream.getTracks().forEach(track => track.stop());
 this.mediaRecorder.stop();
 });
 }

 pauseRecording() {
 if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
 this.mediaRecorder.pause();
 }
 }

 resumeRecording() {
 if (this.mediaRecorder && this.mediaRecorder.state === 'paused') {
 this.mediaRecorder.resume();
 }
 }
}
```

## Building the Popup Interface

Create `popup.html` for user controls:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body {
 width: 320px;
 padding: 16px;
 font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
 }
 .status {
 padding: 8px 12px;
 border-radius: 6px;
 margin-bottom: 12px;
 font-size: 14px;
 }
 .status.inactive {
 background: #f3f4f6;
 color: #374151;
 }
 .status.recording {
 background: #fee2e2;
 color: #991b1b;
 }
 .btn {
 width: 100%;
 padding: 10px;
 border: none;
 border-radius: 6px;
 font-size: 14px;
 font-weight: 500;
 cursor: pointer;
 margin-bottom: 8px;
 }
 .btn-primary {
 background: #2563eb;
 color: white;
 }
 .btn-primary:hover {
 background: #1d4ed8;
 }
 .btn-danger {
 background: #dc2626;
 color: white;
 }
 .btn-danger:hover {
 background: #b91c1c;
 }
 .options {
 margin: 12px 0;
 }
 .options label {
 display: block;
 margin: 8px 0;
 font-size: 13px;
 }
 .timer {
 text-align: center;
 font-size: 24px;
 font-weight: 600;
 margin: 12px 0;
 font-variant-numeric: tabular-nums;
 }
 input[type="checkbox"] {
 margin-right: 8px;
 }
 </style>
</head>
<body>
 <div id="status" class="status inactive">Ready to record</div>
 
 <div id="timer" class="timer" style="display: none;">00:00:00</div>
 
 <div class="options">
 <label>
 <input type="checkbox" id="includeAudio" checked>
 Include microphone audio
 </label>
 <label>
 <input type="checkbox" id="includeSystem">
 Include system audio
 </label>
 </div>
 
 <button id="startBtn" class="btn btn-primary">Start Recording</button>
 <button id="stopBtn" class="btn btn-danger" style="display: none;">Stop Recording</button>
 
 <script src="popup.js"></script>
</body>
</html>
```

## Implementing Popup Logic

Create `popup.js` to connect the UI with the recorder:

```javascript
let recorder = null;
let timerInterval = null;

document.addEventListener('DOMContentLoaded', () => {
 loadState();
 
 document.getElementById('startBtn').addEventListener('click', startRecording);
 document.getElementById('stopBtn').addEventListener('click', stopRecording);
});

async function startRecording() {
 const includeAudio = document.getElementById('includeAudio').checked;
 const includeSystem = document.getElementById('includeSystem').checked;

 try {
 // Send message to background to start recording
 const response = await chrome.runtime.sendMessage({
 action: 'startRecording',
 options: { audio: includeAudio, systemAudio: includeSystem }
 });

 if (response.success) {
 updateUI('recording');
 startTimer();
 }
 } catch (error) {
 alert('Failed to start recording: ' + error.message);
 }
}

async function stopRecording() {
 try {
 const response = await chrome.runtime.sendMessage({
 action: 'stopRecording'
 });

 if (response.success && response.file) {
 // Download the recording
 await chrome.downloads.download({
 url: response.file.url,
 filename: response.file.filename,
 saveAs: true
 });
 
 updateUI('inactive');
 stopTimer();
 }
 } catch (error) {
 alert('Failed to save recording: ' + error.message);
 }
}

function updateUI(state) {
 const status = document.getElementById('status');
 const startBtn = document.getElementById('startBtn');
 const stopBtn = document.getElementById('stopBtn');
 const timer = document.getElementById('timer');

 if (state === 'recording') {
 status.textContent = 'Recording in progress';
 status.className = 'status recording';
 startBtn.style.display = 'none';
 stopBtn.style.display = 'block';
 timer.style.display = 'block';
 } else {
 status.textContent = 'Ready to record';
 status.className = 'status inactive';
 startBtn.style.display = 'block';
 stopBtn.style.display = 'none';
 timer.style.display = 'none';
 }
}

function startTimer() {
 const timerEl = document.getElementById('timer');
 const startTime = Date.now();
 
 timerInterval = setInterval(() => {
 const elapsed = Math.floor((Date.now() - startTime) / 1000);
 const hours = Math.floor(elapsed / 3600);
 const minutes = Math.floor((elapsed % 3600) / 60);
 const seconds = elapsed % 60;
 
 timerEl.textContent = 
 String(hours).padStart(2, '0') + ':' +
 String(minutes).padStart(2, '0') + ':' +
 String(seconds).padStart(2, '0');
 }, 1000);
}

function stopTimer() {
 if (timerInterval) {
 clearInterval(timerInterval);
 timerInterval = null;
 }
}

async function loadState() {
 // Check if recording is already in progress
 const result = await chrome.storage.local.get(['recordingState']);
 if (result.recordingState === 'recording') {
 updateUI('recording');
 startTimer();
 }
}
```

## Handling Background Tasks

Create `background.js` to manage the recorder instance:

```javascript
let currentRecorder = null;

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'startRecording') {
 handleStartRecording(message.options)
 .then(result => sendResponse({ success: true, result }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 return true; // Keep message channel open for async response
 }

 if (message.action === 'stopRecording') {
 handleStopRecording()
 .then(result => sendResponse({ success: true, file: result }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 return true;
 }
});

async function handleStartRecording(options) {
 currentRecorder = new MeetingRecorder();
 await currentRecorder.startRecording(options);
 
 await chrome.storage.local.set({ recordingState: 'recording' });
 return { started: true };
}

async function handleStopRecording() {
 if (!currentRecorder) {
 throw new Error('No recording in progress');
 }

 const result = await currentRecorder.stopRecording();
 
 // Create object URL for download
 const url = URL.createObjectURL(result.blob);
 
 await chrome.storage.local.set({ recordingState: 'inactive' });
 currentRecorder = null;
 
 return {
 url,
 filename: result.filename
 };
}
```

## Key Implementation Considerations

When building a screen recorder for meetings, several factors require attention:

Platform Compatibility: Different meeting platforms have varying levels of DOM accessibility. Some provide transcript elements you can capture, while others require more creative approaches using screen capture alone.

Storage Management: Video files grow quickly. Implement cleanup logic to remove old recordings from local storage. The `chrome.storage.local` has a 10MB limit, so you'll need to use `chrome.downloads` or external storage for larger files.

Permissions Flow: Users must explicitly grant screen capture permission. The browser's picker dialog cannot be customized, so provide clear instructions about what to expect.

Audio Handling: System audio capture requires additional permissions and behaves differently across operating systems. macOS requires specific screen recording permissions in System Preferences.

## Privacy and Ethics

When building recording tools, always consider privacy implications. Implement clear indicators when recording is active, respect platform terms of service, and consider adding features like automatic pause when sensitive content appears.

## Summary

Building a Chrome extension for meeting screen recording combines several powerful APIs into a useful productivity tool. The core implementation uses `getDisplayMedia` for capture, `MediaRecorder` for encoding, and Chrome's download API for saving files.

This guide provides a foundation you can extend with features like automatic transcription integration, cloud storage sync, or meeting timestamp markers. The modular architecture allows you to customize functionality based on your specific meeting workflows.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-screen-recorder-meetings)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Auto Meeting Summary: A Developer Guide](/chrome-extension-auto-meeting-summary/)
- [Chrome Extension Development in 2026: A Practical Manifest V3 Guide](/chrome-extension-development-2026/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)




