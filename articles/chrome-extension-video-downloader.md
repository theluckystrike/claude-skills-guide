---
layout: default
title: "Video Downloader Chrome Extension Guide (2026)"
description: "Claude Code guide: learn how to build a Chrome extension for downloading videos from websites. Technical implementation, APIs, code examples, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-video-downloader/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---
Chrome Extension Video Downloader: A Developer Guide

Building a Chrome extension that downloads videos from websites requires understanding browser extension architecture, network request interception, and media handling. This guide covers the technical implementation for developers and power users who want to understand how video downloaders work or build their own.

## How Video Downloader Extensions Work

Video downloader extensions operate by intercepting network requests, identifying media URLs, and providing a mechanism to save content locally. The core challenge lies in the diversity of video delivery methods across websites, some serve direct MP4 files, others use HLS streams, and many employ adaptive bitrate streaming with fragmented media segments.

Most Chrome extensions approach this problem in one of three ways:

1. Network request monitoring. Inspecting all HTTP requests to identify media URLs
2. DOM scanning. Looking for video elements and their source attributes
3. Content script injection. Analyzing page scripts to find video data endpoints

Each approach has trade-offs in reliability, performance, and compatibility.

## Setting Up the Extension

Every Chrome extension starts with a manifest file. For a video downloader, you'll need specific permissions:

```json
{
 "manifest_version": 3,
 "name": "Video Downloader Pro",
 "version": "1.0.0",
 "description": "Download videos from any website",
 "permissions": [
 "activeTab",
 "scripting",
 "storage",
 "webRequest"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html"
 },
 "icons": {
 "16": "icon16.png",
 "48": "icon48.png",
 "128": "icon128.png"
 }
}
```

The critical permissions here are `webRequest` for intercepting network traffic and `scripting` for DOM manipulation. Note that `webRequest` requires host permissions for the domains you want to monitor.

## Implementing Network Request Interception

The most reliable method for capturing video URLs involves monitoring network requests. Here's how to implement this in your background service worker:

```javascript
// background.js
const videoPatterns = [
 /\.mp4$/,
 /\.webm$/,
 /\.m3u8$/,
 /\bvideo\b/i,
 /\bmedia\b/i,
 /\bblob\b/
];

let detectedVideos = [];

chrome.webRequest.onCompleted.addListener(
 (details) => {
 const url = details.url;
 
 // Check if URL matches video patterns
 const isVideo = videoPatterns.some(pattern => pattern.test(url));
 
 if (isVideo) {
 // Avoid duplicates
 if (!detectedVideos.find(v => v.url === url)) {
 detectedVideos.push({
 url: url,
 type: details.mimeType,
 tabId: details.tabId,
 timestamp: Date.now()
 });
 
 // Notify popup if open
 chrome.runtime.sendMessage({
 action: 'videoDetected',
 video: { url, type: details.mimeType }
 });
 }
 }
 },
 { urls: ['<all_urls>'] }
);

// Clear detected videos when tab closes
chrome.tabs.onRemoved.addListener((tabId) => {
 detectedVideos = detectedVideos.filter(v => v.tabId !== tabId);
});
```

This approach captures completed network requests and filters them based on URL patterns and MIME types. It works well for direct video files but requires additional handling for streaming formats.

## DOM-Based Video Detection

For websites that serve videos through player interfaces rather than direct URLs, DOM scanning provides a complementary approach:

```javascript
// content.js - Inject into web pages
class VideoScanner {
 constructor() {
 this.videos = [];
 this.observer = null;
 }

 scan() {
 const videoElements = document.querySelectorAll('video');
 
 videoElements.forEach(video => {
 const sources = Array.from(video.querySelectorAll('source'));
 const videoUrl = video.src || video.currentSrc;
 
 if (videoUrl && !this.hasVideo(videoUrl)) {
 this.videos.push({
 url: videoUrl,
 type: video.type || 'video/mp4',
 poster: video.poster,
 duration: video.duration,
 width: video.videoWidth,
 height: video.videoHeight
 });
 }
 });

 // Also check for iframes (embedded players)
 const iframes = document.querySelectorAll('iframe[src*="video"], iframe[src*="player"]');
 iframes.forEach(iframe => {
 console.log('Potential video embed:', iframe.src);
 });

 return this.videos;
 }

 hasVideo(url) {
 return this.videos.some(v => v.url === url);
 }

 startObserving() {
 this.observer = new MutationObserver(() => {
 this.scan();
 });

 this.observer.observe(document.body, {
 childList: true,
 subtree: true
 });
 }

 stopObserving() {
 if (this.observer) {
 this.observer.disconnect();
 }
 }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
 const scanner = new VideoScanner();
 
 // Initial scan
 const videos = scanner.scan();
 if (videos.length > 0) {
 chrome.runtime.sendMessage({
 action: 'videosFound',
 videos: videos,
 tabId: chrome.runtime.id
 });
 }

 // Watch for dynamically added videos
 scanner.startObserving();
});
```

This content script scans the page for video elements and monitors changes, capturing both direct video URLs and embedded player sources.

## Handling HLS Streams

Many modern websites use HLS (HTTP Live Streaming) for video delivery. Downloading HLS streams requires fetching the manifest and combining segments:

```javascript
// hls-downloader.js
class HLSDownloader {
 constructor(m3u8Url) {
 this.baseUrl = new URL(m3u8Url);
 this.segments = [];
 }

 async fetchManifest() {
 const response = await fetch(this.baseUrl.href);
 const text = await response.text();
 return this.parseManifest(text);
 }

 parseManifest(manifestText) {
 const lines = manifestText.split('\n');
 const segments = [];
 
 for (const line of lines) {
 const trimmed = line.trim();
 
 if (trimmed && !trimmed.startsWith('#')) {
 // Resolve relative URLs
 const segmentUrl = trimmed.startsWith('http')
 ? trimmed
 : new URL(trimmed, this.baseUrl.href).href;
 segments.push(segmentUrl);
 }
 }
 
 return segments;
 }

 async downloadSegments(progressCallback) {
 const segments = await this.fetchManifest();
 const total = segments.length;
 
 for (let i = 0; i < segments.length; i++) {
 const response = await fetch(segments[i]);
 const buffer = await response.arrayBuffer();
 this.segments.push(buffer);
 
 if (progressCallback) {
 progressCallback({
 current: i + 1,
 total: total,
 percent: Math.round(((i + 1) / total) * 100)
 });
 }
 }
 
 return this.segments;
 }

 async combineSegments() {
 const totalLength = this.segments.reduce(
 (acc, buffer) => acc + buffer.byteLength, 0
 );
 
 const combined = new Uint8Array(totalLength);
 let offset = 0;
 
 for (const segment of this.segments) {
 combined.set(new Uint8Array(segment), offset);
 offset += segment.byteLength;
 }
 
 return combined;
 }
}
```

This implementation fetches the HLS manifest, downloads each segment, and combines them into a single file. For production use, you'd want to add error handling and retry logic.

## Building the Download Interface

The popup interface provides users with controls to manage downloads:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; font-family: system-ui, -apple-system, sans-serif; }
 .header { padding: 12px; background: #1a1a1a; color: white; }
 .video-list { max-height: 300px; overflow-y: auto; }
 .video-item { padding: 12px; border-bottom: 1px solid #eee; }
 .video-item:hover { background: #f5f5f5; }
 .video-url { 
 font-size: 12px; 
 word-break: break-all; 
 color: #666;
 margin-top: 4px;
 }
 .download-btn {
 background: #0066cc;
 color: white;
 border: none;
 padding: 8px 16px;
 border-radius: 4px;
 cursor: pointer;
 width: 100%;
 margin-top: 8px;
 }
 .download-btn:hover { background: #0052a3; }
 .empty-state { padding: 24px; text-align: center; color: #666; }
 </style>
</head>
<body>
 <div class="header">
 <h3>Video Downloader</h3>
 </div>
 <div id="videoList" class="video-list"></div>
 <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
 const videoList = document.getElementById('videoList');

 chrome.runtime.onMessage.addListener((message) => {
 if (message.action === 'videoDetected') {
 addVideoItem(message.video);
 } else if (message.action === 'videosFound') {
 message.videos.forEach(video => addVideoItem(video));
 }
 });

 function addVideoItem(video) {
 // Avoid duplicates
 if (document.querySelector(`[data-url="${video.url}"]`)) return;

 const item = document.createElement('div');
 item.className = 'video-item';
 item.dataset.url = video.url;
 
 const typeLabel = video.type || 'Unknown type';
 const filename = extractFilename(video.url);

 item.innerHTML = `
 <strong>${filename}</strong>
 <div class="video-url">${video.type || 'video/*'}</div>
 <button class="download-btn" data-url="${video.url}">Download</button>
 `;

 item.querySelector('.download-btn').addEventListener('click', () => {
 chrome.downloads.download({
 url: video.url,
 filename: sanitizeFilename(filename)
 });
 });

 videoList.appendChild(item);
 }

 function extractFilename(url) {
 try {
 const pathname = new URL(url).pathname;
 return pathname.split('/').pop() || 'video';
 } catch {
 return 'video';
 }
 }

 function sanitizeFilename(name) {
 return name.replace(/[^a-z0-9._-]/gi, '_');
 }
});
```

## Requesting Videos from Content Scripts

To connect your popup with content script detection, add this messaging pattern:

```javascript
// Request current page videos when popup opens
chrome.runtime.sendMessage({ action: 'getVideos' }, (response) => {
 if (response && response.videos) {
 response.videos.forEach(video => addVideoItem(video));
 }
});
```

Add corresponding handling in your content script to respond with detected videos.

## Legal and Ethical Considerations

When building video downloader extensions, consider the following:

- Terms of Service. Many websites prohibit automated downloading. Review and respect these terms.
- Copyright. Downloading copyrighted content for redistribution violates laws in most jurisdictions.
- Personal Use. Downloading content you have legal access to for personal offline viewing is generally acceptable.
- DRM. Extensions cannot bypass Digital Rights Management protections.

Build tools that help users save their own content from services they legitimately access, and avoid facilitating unauthorized content distribution.

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Test on various websites:

- Direct MP4 video pages
- YouTube (as a learning exercise, though You'll face challenges)
- Streaming platforms
- Social media sites with video embeds

Check the Network tab in DevTools to see what requests your extension captures and refine your patterns accordingly.

## Conclusion

Building a Chrome video downloader extension requires combining multiple techniques: network request monitoring, DOM scanning, and stream handling. The implementations shown here provide a foundation that you can extend based on specific use cases.

Start with the network interception approach for direct video files, add DOM scanning for embedded players, and implement HLS handling for streaming services. Test thoroughly across different websites since each has unique video delivery mechanisms.

Focus on creating a reliable, user-friendly tool that respects legal boundaries and serves legitimate personal use cases.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-video-downloader)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [How to Build an AI Video Summarizer Chrome Extension](/ai-video-summarizer-chrome-extension/)
- [Chrome Extension Auto Caption Video: A Developer Guide](/chrome-extension-auto-caption-video/)
- [Chrome Extension YouTube Thumbnail Downloader: A.](/chrome-extension-youtube-thumbnail-downloader/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

