---

layout: default
title: "AI YouTube Summary Chrome Extension: Build Your Own"
description: "Learn how to build an AI-powered YouTube summary Chrome extension from scratch. Practical code examples, architecture patterns, and implementation strategies for developers."
date: 2026-03-15
author: theluckystrike
permalink: /ai-youtube-summary-chrome-extension/
---

# AI YouTube Summary Chrome Extension: Build Your Own

YouTube hosts millions of hours of video content, but extracting specific information from long-form videos remains time-consuming. An AI-powered YouTube summary Chrome extension can transcribe video content, generate concise summaries, and allow users to search within video transcripts. This guide walks through building one from scratch.

## Why Build a Custom YouTube Summary Extension

Pre-built solutions exist, but custom extensions offer advantages. You control the AI model, privacy handling, and feature set. For developers, this means integrating with your preferred LLM API, customizing summary length and style, and embedding the extension directly into your workflow.

The core functionality involves capturing video metadata, extracting audio for transcription, and processing text through an AI model. Understanding each component helps you build exactly what you need.

## Extension Architecture

A YouTube summary extension consists of three main parts:

- **Content script**: Runs on YouTube pages, extracts video ID and metadata
- **Background service worker**: Handles API communication and storage
- **Popup UI**: Displays summaries and controls

Here's the project structure:

```
youtube-summary-extension/
├── manifest.json
├── background.js
├── content.js
├── popup.html
├── popup.js
└── styles.css
```

## Setting Up the Manifest

The manifest defines permissions and entry points. You need access to YouTube URLs and storage:

```json
{
  "manifest_version": 3,
  "name": "AI YouTube Summary",
  "version": "1.0",
  "description": "Generate AI-powered summaries for YouTube videos",
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["https://www.youtube.com/*"],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html"
  },
  "content_scripts": [{
    "matches": ["https://www.youtube.com/*"],
    "js": ["content.js"]
  }]
}
```

## Extracting Video Information

The content script runs on YouTube pages and captures video data when the page loads. Modern YouTube is a single-page application, so you need to detect URL changes:

```javascript
// content.js
function getVideoId() {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get('v');
}

function getVideoTitle() {
  const titleElement = document.querySelector('h1.ytd-video-primary-info-renderer');
  return titleElement ? titleElement.textContent.trim() : '';
}

// Observe YouTube's navigation
let lastUrl = location.href;
new MutationObserver(() => {
  const url = location.href;
  if (url !== lastUrl) {
    lastUrl = url;
    onUrlChange();
  }
}).observe(document, { subtree: true, childList: true });

function onUrlChange() {
  const videoId = getVideoId();
  if (videoId) {
    const videoData = {
      id: videoId,
      title: getVideoTitle(),
      url: window.location.href
    };
    chrome.runtime.sendMessage({
      action: 'videoDetected',
      data: videoData
    });
  }
}
```

## Handling API Communication

The background service worker receives messages from the content script and manages API calls. This separation keeps your API keys secure:

```javascript
// background.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'videoDetected') {
    storeVideoInfo(request.data);
  }
  
  if (request.action === 'generateSummary') {
    generateSummary(request.videoData)
      .then(summary => sendResponse({ summary }))
      .catch(error => sendResponse({ error: error.message }));
    return true;
  }
});

async function generateSummary(videoData) {
  const { apiKey, model } = await getSettings();
  
  const prompt = `Create a concise summary of this YouTube video titled "${videoData.title}". 
  Focus on the main topics, key points, and conclusions. Keep it under 200 words.`;
  
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: model || 'claude-3-haiku-20240307',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: prompt
      }]
    })
  });
  
  const data = await response.json();
  return data.content[0].text;
}

async function getSettings() {
  return new Promise(resolve => {
    chrome.storage.local.get(['apiKey', 'model'], result => {
      resolve(result);
    });
  });
}
```

## Building the Popup Interface

The popup provides the user interface for viewing and managing summaries:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    <h2>YouTube Summary</h2>
    <div id="videoInfo"></div>
    <button id="summarizeBtn">Generate Summary</button>
    <div id="summary" class="hidden"></div>
    <div id="error" class="hidden"></div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.getElementById('summarizeBtn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getVideoData' }, async (response) => {
    if (!response || !response.videoData) {
      showError('No video detected');
      return;
    }
    
    showLoading();
    
    chrome.runtime.sendMessage({
      action: 'generateSummary',
      videoData: response.videoData
    }, (result) => {
      if (result.error) {
        showError(result.error);
      } else {
        showSummary(result.summary);
      }
    });
  });
});

function showSummary(text) {
  document.getElementById('summary').textContent = text;
  document.getElementById('summary').classList.remove('hidden');
  document.getElementById('error').classList.add('hidden');
}
```

## Advanced Features to Consider

Once the basic summary works, consider adding these enhancements:

### Transcript Extraction

YouTube provides automatic captions. Extract them directly for more accurate summaries:

```javascript
async function getTranscript(videoId) {
  // YouTube's transcript API endpoint
  const url = `https://www.youtube.com/api/timedtext?v=${videoId}&lang=en`;
  const response = await fetch(url);
  const text = await response.text();
  
  // Parse XML to extract text segments
  const parser = new DOMParser();
  const doc = parser.parseFromString(text, 'text/xml');
  const segments = doc.querySelectorAll('text');
  
  return Array.from(segments).map(s => s.textContent).join(' ');
}
```

### Keyboard Shortcuts

Power users appreciate keyboard navigation. Add commands in the manifest:

```json
"commands": {
  "generate-summary": {
    "suggested_key": "Ctrl+Shift+S",
    "description": "Generate summary for current video"
  }
}
```

### Summary History

Store summaries for offline access:

```javascript
chrome.storage.local.set({
  [`summary_${videoId}`]: {
    summary: text,
    timestamp: Date.now(),
    title: videoTitle
  }
});
```

## Performance Considerations

Extensions run in the browser, so efficiency matters. Cache API responses, debounce URL change detection, and lazy-load non-essential features. The AI API calls are the slowest component — always show loading states and consider caching summaries by video ID.

## Conclusion

Building an AI YouTube summary extension gives you complete control over how video content is processed and presented. Start with the core flow — detect video, send to API, display summary — then add features like transcript extraction, history, and keyboard shortcuts based on your needs.

The architecture shown here separates concerns cleanly: content scripts handle page interaction, background workers manage API communication, and the popup provides user controls. This pattern scales well as you add more AI-powered features.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
