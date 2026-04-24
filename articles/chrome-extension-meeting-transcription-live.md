---
layout: default
title: "Meeting Transcription Live Chrome"
description: "Learn how to build Chrome extensions for real-time meeting transcription. Technical implementation, APIs, and best practices for developers."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-meeting-transcription-live/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---
Building a Chrome extension for live meeting transcription requires understanding browser permissions, Web Speech API integration, and audio capture mechanisms. This guide covers the technical implementation for developers and power users who want to create or customize real-time transcription tools.

## Understanding the Core Components

A live meeting transcription extension relies on three main pillars: audio capture, speech recognition, and display/output. Chrome provides APIs for each layer, though each comes with specific constraints you need to work around.

The Web Speech API serves as the foundation for speech-to-text conversion. Modern Chrome versions support both `SpeechRecognition` and `webkitSpeechRecognition` interfaces. These APIs process audio streams locally within the browser, which has privacy implications worth considering for enterprise deployments.

```javascript
// Initialize speech recognition
const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
const recognition = new SpeechRecognition();

recognition.continuous = true;
recognition.interimResults = true;
recognition.lang = 'en-US';

recognition.onresult = (event) => {
 for (let i = event.resultIndex; i < event.results.length; i++) {
 const transcript = event.results[i][0].transcript;
 const isFinal = event.results[i].isFinal;
 // Handle interim vs final results
 }
};
```

The `continuous` flag keeps recognition active across pauses, while `interimResults` provides real-time feedback as speakers talk. Setting the correct language code matters significantly for accuracy, always match it to your expected speakers.

## Choosing Your Recognition Approach

Before writing any code, decide which speech recognition backend fits your requirements. The options differ significantly in cost, accuracy, and complexity:

| Approach | Accuracy | Cost | Latency | Speaker Labels | Offline |
|---|---|---|---|---|---|
| Web Speech API (Chrome) | Good | Free | ~200 ms | No | No |
| AssemblyAI Streaming | Excellent | $0.003/min | ~300 ms | Yes | No |
| Deepgram Nova-2 | Excellent | $0.0043/min | ~200 ms | Yes | No |
| OpenAI Whisper (server) | Very Good | $0.006/min | ~1-2 s | No | No |
| Whisper.cpp (local) | Very Good | Free | 2-10 s | No | Yes |

The Web Speech API is the right starting point for prototyping and personal use because it requires no API key and zero infrastructure. For team deployments where accuracy and speaker labeling matter, AssemblyAI's streaming API delivers the best developer experience with a generous free tier.

## Audio Source Handling

Meeting transcription extensions must handle multiple audio sources: microphone input, system audio (via tab capture), and external sources. Chrome's `getUserMedia` API handles microphone access, while `chrome.tabCapture` enables capturing audio from browser tabs running video conferencing software.

```javascript
// Request microphone access
async function getMicrophoneStream() {
 try {
 const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
 return stream;
 } catch (err) {
 console.error('Microphone access denied:', err);
 }
}

// Capture tab audio (requires permissions)
async function captureTabAudio(tabId) {
 const stream = await chrome.tabCapture.capture({
 audio: true,
 video: false
 });
 return stream;
}
```

The `chrome.tabCapture` API requires the `tabCapture` permission in your manifest and triggers a user prompt. Tab capture only works when the extension icon is clicked, this is a security restriction you cannot bypass.

For Zoom, Google Meet, and similar platforms, you may need to inject content scripts to access their audio streams directly. This approach works because the audio is already decoded in the page context:

```javascript
// Content script injection pattern
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'getAudioData') {
 const audioElement = document.querySelector('audio');
 // Process audio element for transcription
 sendResponse({ success: true });
 }
});
```

## Manifest Configuration

Your `manifest.json` must declare the right permissions. For a full-featured transcription extension:

```json
{
 "manifest_version": 3,
 "name": "Live Meeting Transcriber",
 "version": "1.0",
 "permissions": [
 "tabCapture",
 "scripting",
 "activeTab",
 "storage",
 "downloads"
 ],
 "host_permissions": [
 "*://*.zoom.us/*",
 "*://*.meet.google.com/*",
 "*://*.teams.microsoft.com/*"
 ],
 "background": {
 "service_worker": "background.js"
 }
}
```

Manifest V3 introduced stricter background worker limits. Speech recognition creates unique challenges because `SpeechRecognition` objects must remain instantiated. Consider using a persistent background page (via `"background": {"page": "background.html"}}` instead of service worker) if you need continuous recognition, though this approach has limitations.

Adding `downloads` to the permissions list enables the extension to export transcripts as `.txt` or `.json` files without any browser prompts beyond the standard save dialog.

## Complete Background Worker with Reconnection Logic

The background script is the heart of the extension. It manages the recognition lifecycle, handles disconnects, and routes messages to the popup and content scripts:

```javascript
// background.js
let recognition = null;
let shouldRecord = false;
let currentSession = null;
let transcriptBuffer = [];

function createRecognition() {
 const SR = self.SpeechRecognition || self.webkitSpeechRecognition;
 if (!SR) {
 console.error('SpeechRecognition not supported in this context');
 return null;
 }

 const r = new SR();
 r.continuous = true;
 r.interimResults = true;
 r.lang = 'en-US';
 r.maxAlternatives = 1;

 r.onresult = (event) => {
 for (let i = event.resultIndex; i < event.results.length; i++) {
 const result = event.results[i];
 const text = result[0].transcript.trim();
 const isFinal = result.isFinal;

 const entry = {
 text,
 isFinal,
 timestamp: new Date().toISOString(),
 confidence: result[0].confidence || null
 };

 // Broadcast to any open popup
 chrome.runtime.sendMessage({ type: 'TRANSCRIPT_UPDATE', entry }).catch(() => {});

 if (isFinal) {
 transcriptBuffer.push(entry);
 persistEntry(entry);
 }
 }
 };

 r.onend = () => {
 if (shouldRecord) {
 setTimeout(() => {
 if (shouldRecord && recognition) {
 try { recognition.start(); } catch (e) {}
 }
 }, 150);
 }
 };

 r.onerror = (event) => {
 if (event.error === 'no-speech') {
 // Silent room. expected, do not log
 return;
 }
 if (event.error === 'not-allowed') {
 chrome.runtime.sendMessage({ type: 'ERROR', error: 'Microphone permission denied' }).catch(() => {});
 shouldRecord = false;
 return;
 }
 console.error('Speech recognition error:', event.error);
 };

 return r;
}

async function persistEntry(entry) {
 if (!currentSession) return;
 const key = `session_${currentSession}`;
 const existing = await chrome.storage.local.get([key]);
 const entries = existing[key]?.entries || [];
 entries.push(entry);
 await chrome.storage.local.set({ [key]: { started: currentSession, entries } });
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'START_RECORDING') {
 shouldRecord = true;
 currentSession = Date.now().toString();
 transcriptBuffer = [];
 recognition = createRecognition();
 if (recognition) recognition.start();
 sendResponse({ success: true, sessionId: currentSession });
 }

 if (message.type === 'STOP_RECORDING') {
 shouldRecord = false;
 if (recognition) {
 recognition.stop();
 recognition = null;
 }
 sendResponse({ success: true, sessionId: currentSession });
 currentSession = null;
 }

 if (message.type === 'GET_STATUS') {
 sendResponse({ isRecording: shouldRecord, sessionId: currentSession });
 }

 return true;
});
```

The 150 ms restart delay in `onend` is intentional. Calling `recognition.start()` immediately after `onend` fires can cause a race condition where Chrome rejects the start because the prior instance has not fully released its audio handle yet.

## Real-Time Display and Timestamping

Live transcription requires efficient UI updates. React to the DOM directly from your content script or popup, but batch updates to prevent performance degradation:

```javascript
class TranscriptionDisplay {
 constructor() {
 this.buffer = [];
 this.updateInterval = null;
 this.interimEl = null;
 }

 start() {
 this.updateInterval = setInterval(() => this.flush(), 500);
 }

 stop() {
 clearInterval(this.updateInterval);
 this.flush();
 }

 addEntry(text, timestamp, speaker = 'Unknown') {
 this.buffer.push({ text, timestamp, speaker });
 }

 setInterim(text) {
 if (!this.interimEl) {
 this.interimEl = document.createElement('div');
 this.interimEl.className = 'transcript-line interim';
 document.getElementById('transcription-output').appendChild(this.interimEl);
 }
 this.interimEl.textContent = text;
 }

 flush() {
 if (this.buffer.length === 0) return;

 const display = document.getElementById('transcription-output');

 // Remove the interim element before appending final lines
 if (this.interimEl && this.interimEl.parentNode) {
 this.interimEl.parentNode.removeChild(this.interimEl);
 this.interimEl = null;
 }

 const fragment = document.createDocumentFragment();
 this.buffer.forEach(entry => {
 const line = document.createElement('div');
 line.className = 'transcript-line';
 line.innerHTML = `<span class="timestamp">${entry.timestamp}</span> <span class="speaker">${entry.speaker}:</span> ${entry.text}`;
 fragment.appendChild(line);
 });

 display.appendChild(fragment);
 display.scrollTop = display.scrollHeight;
 this.buffer = [];
 }
}
```

Using `createDocumentFragment` for batch inserts prevents multiple reflows when flushing several buffered lines at once. The interim element trick, inserting a mutable DOM node for in-progress speech, then replacing it with a final node on commit, mirrors how native captioning UIs behave and makes the live display feel responsive without flickering.

Adding timestamps helps users navigate long transcripts. Store sessions in `chrome.storage` to enable searching past meetings:

```javascript
// Save transcript to storage
async function saveTranscript(sessionId, transcriptData) {
 await chrome.storage.local.set({
 [`transcript_${sessionId}`]: {
 timestamp: Date.now(),
 entries: transcriptData
 }
 });
}
```

## Handling API Limitations

The Web Speech API has constraints you should plan for. It requires an active internet connection for Chrome's cloud-based recognition (free tier). Recognition accuracy varies by accent, audio quality, and background noise. The API may stop unexpectedly, implement solid reconnection logic:

```javascript
recognition.onend = () => {
 // Automatically restart recognition
 if (shouldContinueRecording) {
 setTimeout(() => recognition.start(), 100);
 }
};

recognition.onerror = (event) => {
 console.error('Recognition error:', event.error);
 if (event.error === 'no-speech') {
 // Expected in silent moments, restart quietly
 recognition.start();
 }
};
```

A common problem in long meetings is the Chrome speech API silently stopping after approximately 60 seconds without detecting speech. Adding a heartbeat check every 30 seconds catches stalled sessions before the user notices:

```javascript
let heartbeat = null;
let lastActivityAt = Date.now();

recognition.onresult = (event) => {
 lastActivityAt = Date.now();
 // ... existing result handling
};

function startHeartbeat() {
 heartbeat = setInterval(() => {
 const stale = Date.now() - lastActivityAt > 55000; // 55 seconds
 if (stale && shouldRecord) {
 console.log('Heartbeat: restarting stalled recognition');
 recognition.stop(); // onend handler will restart it
 }
 }, 15000);
}
```

## Integrating AssemblyAI Streaming for Production

When Web Speech API accuracy is insufficient, AssemblyAI's streaming WebSocket API is the most developer-friendly upgrade path. It returns word-level timestamps and speaker labels without requiring any server infrastructure from your side:

```javascript
async function startAssemblyAIStream(audioStream) {
 const { apiKey } = await chrome.storage.sync.get(['assemblyApiKey']);
 if (!apiKey) throw new Error('AssemblyAI API key not configured');

 // Get a temporary auth token (recommended over sending the key client-side)
 const tokenRes = await fetch('https://api.assemblyai.com/v2/realtime/token', {
 method: 'POST',
 headers: { authorization: apiKey, 'content-type': 'application/json' },
 body: JSON.stringify({ expires_in: 3600 })
 });
 const { token } = await tokenRes.json();

 const ws = new WebSocket(
 `wss://api.assemblyai.com/v2/realtime/ws?sample_rate=16000&token=${token}`
 );

 const audioContext = new AudioContext({ sampleRate: 16000 });
 const source = audioContext.createMediaStreamSource(audioStream);
 const processor = audioContext.createScriptProcessor(4096, 1, 1);

 source.connect(processor);
 processor.connect(audioContext.destination);

 processor.onaudioprocess = (e) => {
 if (ws.readyState !== WebSocket.OPEN) return;
 const float32 = e.inputBuffer.getChannelData(0);
 const int16 = convertFloat32ToInt16(float32);
 ws.send(int16.buffer);
 };

 ws.onmessage = (msg) => {
 const data = JSON.parse(msg.data);
 if (data.message_type === 'FinalTranscript') {
 const entry = {
 text: data.text,
 isFinal: true,
 timestamp: new Date().toISOString(),
 words: data.words // word-level timing
 };
 chrome.runtime.sendMessage({ type: 'TRANSCRIPT_UPDATE', entry }).catch(() => {});
 persistEntry(entry);
 }
 };

 return { ws, processor, audioContext };
}

function convertFloat32ToInt16(buffer) {
 const out = new Int16Array(buffer.length);
 for (let i = 0; i < buffer.length; i++) {
 out[i] = Math.max(-32768, Math.min(32767, buffer[i] * 32768));
 }
 return out;
}
```

The PCM conversion from Float32 to Int16 is required because AssemblyAI's streaming endpoint expects raw linear PCM audio, not WebM or Opus compressed data. The `ScriptProcessor` approach is deprecated in favor of `AudioWorklet`, but remains the more compatible option for Chrome extensions where the worklet module loading path is constrained by extension sandboxing.

## Speaker Diarization Challenges

Distinguishing between speakers remains difficult with the base Web Speech API. Several approaches help:

1. Spatial audio analysis: Use Web Audio API to analyze audio input directionality when multiple microphones exist
2. Voice activity detection: Segment audio by pause patterns to estimate speaker changes
3. External services: Integrate with AssemblyAI, Deepgram, or similar APIs that provide speaker diarization

For enterprise use, combining Chrome extension capture with backend AI services typically yields the best results:

```javascript
// Send audio chunks to external service
async function sendToTranscriptionService(audioBlob) {
 const formData = new FormData();
 formData.append('audio', audioBlob, 'segment.webm');

 const response = await fetch('https://api.transcription.service/v1/transcribe', {
 method: 'POST',
 headers: {
 'Authorization': `Bearer ${apiKey}`
 },
 body: formData
 });

 return response.json();
}
```

A simpler speaker-labeling heuristic that works without external APIs is pause-based segmentation. When the recognition fires a `FinalTranscript` after a gap of more than 2 seconds, increment the speaker counter and assign the next speaker label. It is not perfect, but it produces readable transcripts for two-person calls:

```javascript
let lastFinalAt = 0;
let speakerIndex = 0;
const SPEAKERS = ['Speaker A', 'Speaker B', 'Speaker C', 'Speaker D'];

recognition.onresult = (event) => {
 for (let i = event.resultIndex; i < event.results.length; i++) {
 if (!event.results[i].isFinal) continue;

 const now = Date.now();
 const gap = now - lastFinalAt;

 if (lastFinalAt > 0 && gap > 2000) {
 speakerIndex = (speakerIndex + 1) % SPEAKERS.length;
 }

 const text = event.results[i][0].transcript.trim();
 const speaker = SPEAKERS[speakerIndex];
 lastFinalAt = now;

 display.addEntry(text, new Date().toLocaleTimeString(), speaker);
 }
};
```

## Exporting Transcripts

After a meeting, users need to act on the transcript. Add export functionality directly to the popup:

```javascript
async function exportTranscript(sessionId, format = 'txt') {
 const key = `session_${sessionId}`;
 const data = await chrome.storage.local.get([key]);
 const session = data[key];
 if (!session) return;

 let content;
 let filename;
 let mimeType;

 if (format === 'json') {
 content = JSON.stringify(session, null, 2);
 filename = `transcript_${sessionId}.json`;
 mimeType = 'application/json';
 } else {
 content = session.entries
 .filter(e => e.isFinal)
 .map(e => `[${e.timestamp}] ${e.text}`)
 .join('\n');
 filename = `transcript_${sessionId}.txt`;
 mimeType = 'text/plain';
 }

 const blob = new Blob([content], { type: mimeType });
 const url = URL.createObjectURL(blob);

 await chrome.downloads.download({
 url,
 filename,
 saveAs: true
 });

 // Clean up the object URL after a short delay
 setTimeout(() => URL.revokeObjectURL(url), 5000);
}
```

The `chrome.downloads.download` call requires the `downloads` permission in `manifest.json`. Using `saveAs: true` prompts the standard file picker, which is the correct behavior for user-generated content.

## Extension Architecture Recommendations

For production deployments, structure your extension with clear separation:

- Background service: Handles API communication, storage, and long-running recognition
- Content script: Injects UI and captures page audio when needed
- Popup: Provides quick controls and current session status
- Options page: Configures API keys, language preferences, and storage limits

This separation keeps memory usage low and makes debugging easier. Test extensively across Chrome versions, as speech API behavior varies.

For a production extension, add a storage quota check. `chrome.storage.local` has a 10 MB default limit that a long meeting can approach if you store raw audio or many transcripts. Either enforce a maximum number of stored sessions or compress older entries:

```javascript
async function enforceStorageQuota(maxSessions = 20) {
 const all = await chrome.storage.local.get(null);
 const sessionKeys = Object.keys(all)
 .filter(k => k.startsWith('session_'))
 .sort(); // ascending by timestamp embedded in key

 if (sessionKeys.length > maxSessions) {
 const toDelete = sessionKeys.slice(0, sessionKeys.length - maxSessions);
 await chrome.storage.local.remove(toDelete);
 console.log(`Storage quota: removed ${toDelete.length} old sessions`);
 }
}
```

Call `enforceStorageQuota` at the start of each new recording session to keep the extension self-managing without requiring user intervention.

Building a Chrome extension for live meeting transcription involves navigating browser APIs, managing audio streams, and handling the inherent limitations of client-side speech recognition. Start with the Web Speech API for prototyping, then evaluate external services for production accuracy requirements.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-meeting-transcription-live)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Auto Meeting Summary: A Developer Guide](/chrome-extension-auto-meeting-summary/)
- [Chrome Extension Meeting Agenda Template: A Developer's.](/chrome-extension-meeting-agenda-template/)
- [Building a Chrome Extension for Standup Meeting Notes](/chrome-extension-standup-meeting-notes/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


