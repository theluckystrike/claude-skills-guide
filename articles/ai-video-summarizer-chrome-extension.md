---
layout: default
title: "Build an AI Video Summarizer Extension (2026)"
description: "Build a Chrome extension that summarizes YouTube, Vimeo, and Coursera videos using AI. Complete implementation with transcript extraction and LLM calls."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: theluckystrike
permalink: /ai-video-summarizer-chrome-extension/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---



Building an AI-powered video summarizer as a Chrome extension opens up powerful possibilities for extracting key insights from long-form video content without watching the entire video. Whether you need quick summaries of educational courses, meeting recordings, or tutorial videos, combining Chrome extension architecture with modern AI APIs creates a tool that transforms how you consume video content.

This guide walks you through creating a complete Chrome extension that detects video pages, extracts metadata, and generates concise summaries using OpenAI or Anthropic APIs. The extension architecture handles message passing between content scripts and background workers, manages API rate limits, and presents results through an intuitive overlay interface.

## Extension Architecture Overview

The AI video summarizer extension consists of three core components working together. Content scripts running on video pages detect playable media and extract metadata. Background workers handle API communication, caching, and storage. A floating overlay panel displays generated summaries directly on the video page.

The manifest configuration defines the extension permissions and entry points. Your manifest must declare permissions for active tab access, storage, and script injection:

```json
{
 "manifest_version": 3,
 "name": "AI Video Summarizer",
 "version": "1.0",
 "permissions": ["activeTab", "storage", "scripting"],
 "host_permissions": ["*://*.youtube.com/*", "*://*.vimeo.com/*", "*://*.coursera.org/*"],
 "background": {
 "service_worker": "background.js"
 },
 "content_scripts": [{
 "matches": ["*://*.youtube.com/*", "*://*.vimeo.com/*", "*://*.coursera.org/*"],
 "js": ["content.js"]
 }]
}
```

This configuration limits the extension to major video platforms while enabling the necessary browser APIs for cross-component communication.

## Video Detection and Metadata Extraction

Content scripts run on matching video pages and use the Page Visibility API to detect when a video is playing. The script extracts video metadata including title, duration, and platform-specific information:

```javascript
// content.js - runs on video pages
function detectVideoMetadata() {
 const url = window.location.href;
 let metadata = { url, title: document.title, platform: null };

 if (url.includes('youtube.com')) {
 metadata.platform = 'youtube';
 metadata.videoId = new URLSearchParams(url.split('?')[1]).get('v');
 const titleElement = document.querySelector('h1.ytd-video-primary-info-renderer');
 metadata.title = titleElement?.textContent?.trim() || metadata.title;
 } else if (url.includes('vimeo.com')) {
 metadata.platform = 'vimeo';
 const titleElement = document.querySelector('.vp-title h1');
 metadata.title = titleElement?.textContent?.trim() || metadata.title;
 } else if (url.includes('coursera.org')) {
 metadata.platform = 'coursera';
 const titleElement = document.querySelector('.rc-CourseHeader h1');
 metadata.title = titleElement?.textContent?.trim() || metadata.title;
 }

 return metadata;
}

// Listen for visibility changes to trigger summary generation
document.addEventListener('visibilitychange', () => {
 if (document.visibilityState === 'visible') {
 const metadata = detectVideoMetadata();
 chrome.runtime.sendMessage({ type: 'VIDEO_DETECTED', payload: metadata });
 }
});
```

This metadata extraction approach handles the three primary video platforms while remaining extensible for additional sources. The visibility change listener ensures the extension responds when users navigate between tabs.

## AI Integration Pattern

The background service worker manages all communication with AI APIs. This architecture keeps API keys secure and enables caching strategies. The worker receives video metadata from content scripts, checks for cached summaries, and calls the AI API when needed:

```javascript
// background.js
const OPENAI_API_KEY_STORAGE_KEY = 'openai_api_key';
const ANTHROPIC_API_KEY_STORAGE_KEY = 'anthropic_api_key';
const CACHE_PREFIX = 'summary_cache_';

async function generateSummary(videoMetadata, preferences) {
 const cacheKey = CACHE_PREFIX + btoa(videoMetadata.url).slice(0, 50);
 
 // Check cache first
 const cached = await chrome.storage.local.get(cacheKey);
 if (cached[cacheKey]) {
 return cached[cacheKey];
 }

 // Determine which AI provider to use
 const useAnthropic = preferences?.provider === 'anthropic';
 const keyStorageKey = useAnthropic ? ANTHROPIC_API_KEY_STORAGE_KEY : OPENAI_API_KEY_STORAGE_KEY;
 
 const keys = await chrome.storage.local.get(keyStorageKey);
 const apiKey = keys[keyStorageKey];

 if (!apiKey) {
 return { error: 'API key not configured. Please set your API key in extension settings.' };
 }

 // Build the prompt based on video metadata
 const prompt = buildSummaryPrompt(videoMetadata, preferences);
 
 let response;
 if (useAnthropic) {
 response = await callAnthropic(apiKey, prompt);
 } else {
 response = await callOpenAI(apiKey, prompt);
 }

 // Cache the result
 const result = { summary: response, timestamp: Date.now() };
 await chrome.storage.local.set({ [cacheKey]: result });
 
 return result;
}

function buildSummaryPrompt(metadata, preferences) {
 const maxLength = preferences?.maxLength || 200;
 const format = preferences?.format || 'bullet';
 
 return `Summarize this video in ${maxLength} words or less.
 
Video Title: ${metadata.title}
Platform: ${metadata.platform}
URL: ${metadata.url}

Provide the summary in ${format} format highlighting:
- Main topics covered
- Key takeaways
- Actionable insights`;
}
```

The caching mechanism prevents redundant API calls for the same video, reducing costs and improving response times. The extension supports both OpenAI and Anthropic providers, letting users choose their preferred AI service.

## Summary Display Overlay

The floating panel UI appears as an overlay on the video page, providing summary display without navigating away. Content scripts inject the overlay HTML and handle user interactions:

```javascript
// Inject overlay HTML and styles
function createSummaryOverlay(summary, metadata) {
 const overlay = document.createElement('div');
 overlay.id = 'ai-video-summarizer-overlay';
 overlay.innerHTML = `
 <style>
 #ai-video-summarizer-overlay {
 position: fixed;
 bottom: 20px;
 right: 20px;
 width: 380px;
 max-height: 500px;
 background: #1a1a2e;
 border-radius: 12px;
 box-shadow: 0 8px 32px rgba(0,0,0,0.3);
 z-index: 9999;
 font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
 overflow: hidden;
 }
 .summarizer-header {
 padding: 16px;
 background: #16213e;
 display: flex;
 justify-content: space-between;
 align-items: center;
 }
 .summarizer-content {
 padding: 16px;
 max-height: 400px;
 overflow-y: auto;
 color: #e8e8e8;
 line-height: 1.6;
 }
 .summarizer-close {
 background: none;
 border: none;
 color: #888;
 cursor: pointer;
 font-size: 20px;
 }
 </style>
 <div class="summarizer-header">
 <span style="color: #fff; font-weight: 600;">Video Summary</span>
 <button class="summarizer-close">&times;</button>
 </div>
 <div class="summarizer-content">
 ${summary}
 </div>
 `;
 
 document.body.appendChild(overlay);
 
 // Handle close button
 overlay.querySelector('.summarizer-close').addEventListener('click', () => {
 overlay.remove();
 });
 
 return overlay;
}
```

The overlay styling uses a modern dark theme that complements video platform aesthetics. The close button and escape key handling provide intuitive dismissal.

## Message Passing Between Components

Chrome extensions use message passing for communication between content scripts and background workers. This pattern enables secure inter-component communication while keeping sensitive operations in the service worker:

```javascript
// Content script sends message to background
chrome.runtime.sendMessage({
 type: 'REQUEST_SUMMARY',
 payload: { metadata: videoMetadata, preferences: userPreferences }
});

// Background worker listens and responds
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'REQUEST_SUMMARY') {
 generateSummary(message.payload.metadata, message.payload.preferences)
 .then(result => sendResponse(result))
 .catch(error => sendResponse({ error: error.message }));
 return true; // Keep channel open for async response
 }
});
```

The return value `true` signals that the response is asynchronous, allowing the background worker to complete API calls before responding.

## Handling Long Videos with Transcript Chunking

Videos exceeding typical API context windows require transcript extraction and chunking. YouTube provides transcript APIs, while other platforms may require screen reader extraction:

```javascript
async function extractTranscript(videoMetadata) {
 if (videoMetadata.platform === 'youtube') {
 // YouTube transcript extraction via API
 const transcriptUrl = `https://subtitles.googleapis.com/v1/subtitles?videoId=${videoMetadata.videoId}&key=${YOUTUBE_API_KEY}`;
 const response = await fetch(transcriptUrl);
 const data = await response.json();
 
 return data.snippets
 .map(snippet => snippet.text)
 .join(' ');
 }
 
 // For other platforms, return placeholder
 // Implement based on specific platform capabilities
 return null;
}

async function chunkTranscript(transcript, maxChunkSize = 8000) {
 const words = transcript.split(/\s+/);
 const chunks = [];
 let currentChunk = [];
 let currentLength = 0;
 
 for (const word of words) {
 if (currentLength + word.length > maxChunkSize && currentChunk.length > 0) {
 chunks.push(currentChunk.join(' '));
 currentChunk = [];
 currentLength = 0;
 }
 currentChunk.push(word);
 currentLength += word.length + 1;
 }
 
 if (currentChunk.length > 0) {
 chunks.push(currentChunk.join(' '));
 }
 
 return chunks;
}
```

Chunking enables processing of full-length courses and lengthy presentations while staying within API token limits. Each chunk generates a partial summary that gets combined into a final overview.

## Performance Optimization Through Caching

Implementing browser storage caching dramatically improves perceived performance and reduces API costs. Cache invalidation strategies ensure summaries stay current:

```javascript
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

async function getCachedSummary(url) {
 const cacheKey = CACHE_PREFIX + btoa(url).slice(0, 50);
 const cached = await chrome.storage.local.get(cacheKey);
 
 if (cached[cacheKey]) {
 const { summary, timestamp } = cached[cacheKey];
 
 // Check if cache is still valid
 if (Date.now() - timestamp < CACHE_DURATION) {
 return { summary, cached: true };
 }
 
 // Expired - remove old cache entry
 await chrome.storage.local.remove(cacheKey);
 }
 
 return null;
}
```

The caching layer respects API rate limits by storing results locally and checking timestamps before making new requests.

## Configuration and User Preferences

Allowing users to configure their preferred AI provider and API keys creates a flexible experience. Storage management handles secure key storage:

```javascript
// Save API key securely
async function saveApiKey(provider, apiKey) {
 const keyStorageKey = provider === 'anthropic' 
 ? ANTHROPIC_API_KEY_STORAGE_KEY 
 : OPENAI_API_KEY_STORAGE_KEY;
 
 await chrome.storage.local.set({ [keyStorageKey]: apiKey });
}

// Options page would include:
// - Provider selection (OpenAI/Anthropic)
// - API key input fields
// - Summary length preference
// - Default platform settings
```

Extension settings pages let users input their API credentials without exposing them in the extension code. The options page should validate keys before saving and provide clear error messages for misconfiguration.

Building this extension requires balancing API costs, user experience, and platform compatibility. The architecture presented here provides a solid foundation that scales from personal use to broader distribution. With the foundation in place, you can extend support to additional video platforms, integrate different AI models, or add features like timestamped highlights and saved collections.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=ai-video-summarizer-chrome-extension)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Summarizer Chrome Extension: Build Your Own Text Summarization Tool](/ai-summarizer-chrome-extension/)
- [AI Flashcard Maker Chrome Extension: Build Your Own Learning Tool](/ai-flashcard-maker-chrome-extension/)
- [AI PDF Summarizer Chrome Extension: A Developer Guide](/ai-pdf-summarizer-chrome-extension/)
- [Video Downloader Chrome Extension Guide (2026)](/chrome-extension-video-downloader/)
- [AI Webpage Summarizer Chrome Extension Guide (2026)](/ai-webpage-summarizer-chrome-extension/)
- [Auto Caption Video Chrome Extension Guide (2026)](/chrome-extension-auto-caption-video/)

Built by theluckystrike. More at https://zovo.one




