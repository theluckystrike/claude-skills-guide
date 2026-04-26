---
layout: default
title: "Build a Text-to-Speech Chrome Extension (2026)"
description: "Claude Code extension tip: build a Chrome extension with text-to-speech using Web Speech API. Covers voice selection, rate control, SSML support, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-text-to-speech/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
last_tested: "2026-04-21"
---
Chrome Extension Text to Speech: A Developer Guide

Text-to-speech functionality in Chrome extensions transforms written content into spoken audio, opening doors for accessibility tools, language learning applications, and productivity boosters. This guide covers the technical implementation, from Web Speech API integration to custom audio solutions, with real-world code patterns you can drop into your own projects.

## Understanding Text-to-Speech Options in Chrome

Chrome provides two primary pathways for text-to-speech: the native Web Speech API and the Chrome ttsEngine API. The Web Speech API offers the quickest implementation path, working directly in content scripts without requiring additional permissions. The ttsEngine API gives you deeper control over speech synthesis, enabling custom voice options and advanced playback control.

The Web Speech API's `SpeechSynthesis` interface is available in all modern Chrome versions, making it a reliable choice for basic implementations. For extensions requiring offline capability or premium voice quality, you'll need to explore third-party TTS services or implement the ttsEngine API.

Here is a comparison of the main approaches to help you choose:

| Approach | Setup Complexity | Voice Quality | Offline Support | Cost |
|---|---|---|---|---|
| Web Speech API | Low | System voices (varies) | Yes | Free |
| Chrome ttsEngine API | Medium | Custom or system | Depends on impl. | Free |
| Google Cloud TTS | Medium | Neural / WaveNet voices | No | Pay per char |
| Amazon Polly | Medium | Neural / standard | No | Pay per char |
| Coqui TTS (self-hosted) | High | Good (open source) | Yes | Free (server cost) |

For most extension projects, the Web Speech API covers the vast majority of use cases. Upgrade to a cloud service when voice quality is a product requirement or when you need languages not supported by the user's OS.

## Building Your First Text-to-Speech Extension

Every Chrome extension begins with a manifest file. For text-to-speech functionality, you'll need manifest V3 with specific permissions:

```json
{
 "manifest_version": 3,
 "name": "Simple TTS Reader",
 "version": "1.0",
 "permissions": ["activeTab", "scripting", "storage", "contextMenus"],
 "action": {
 "default_popup": "popup.html"
 },
 "background": {
 "service_worker": "background.js"
 }
}
```

Note that `contextMenus` and `storage` are added here compared to a minimal setup. they are both low-risk permissions that dramatically expand what your extension can do and are worth including from the start.

The popup interface provides the user controls. Create a simple HTML file with play, pause, and stop buttons:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 220px; padding: 12px; font-family: system-ui; }
 button { width: 100%; margin: 5px 0; padding: 8px; cursor: pointer; }
 select { width: 100%; margin: 5px 0; padding: 6px; }
 label { font-size: 12px; color: #555; }
 input[type=range] { width: 100%; }
 </style>
</head>
<body>
 <button id="speak">Read Page</button>
 <button id="speakSelected">Read Selection</button>
 <button id="pause">Pause</button>
 <button id="stop">Stop</button>
 <hr>
 <label>Voice</label>
 <select id="voiceSelect"></select>
 <label>Rate: <span id="rateVal">1.0</span></label>
 <input type="range" id="rate" min="0.5" max="2.0" step="0.1" value="1.0">
 <label>Pitch: <span id="pitchVal">1.0</span></label>
 <input type="range" id="pitch" min="0.5" max="2.0" step="0.1" value="1.0">
 <script src="popup.js"></script>
</body>
</html>
```

The popup script handles the core TTS logic using the Web Speech API:

```javascript
// popup.js
let currentTab = null;

async function getTab() {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 return tab;
}

function inject(fn, args = []) {
 return chrome.scripting.executeScript({
 target: { tabId: currentTab.id },
 func: fn,
 args,
 });
}

document.getElementById('speak').addEventListener('click', async () => {
 currentTab = await getTab();
 const rate = parseFloat(document.getElementById('rate').value);
 const pitch = parseFloat(document.getElementById('pitch').value);
 const voiceName = document.getElementById('voiceSelect').value;

 inject((rate, pitch, voiceName) => {
 window.speechSynthesis.cancel();
 const text = document.body.innerText.trim();
 const utterance = new SpeechSynthesisUtterance(text);
 utterance.rate = rate;
 utterance.pitch = pitch;

 const voices = window.speechSynthesis.getVoices();
 const voice = voices.find(v => v.name === voiceName);
 if (voice) utterance.voice = voice;

 window.speechSynthesis.speak(utterance);
 }, [rate, pitch, voiceName]);
});

document.getElementById('pause').addEventListener('click', async () => {
 currentTab = await getTab();
 inject(() => {
 if (window.speechSynthesis.speaking && !window.speechSynthesis.paused) {
 window.speechSynthesis.pause();
 } else if (window.speechSynthesis.paused) {
 window.speechSynthesis.resume();
 }
 });
});

document.getElementById('stop').addEventListener('click', async () => {
 currentTab = await getTab();
 inject(() => window.speechSynthesis.cancel());
});

// Rate and pitch display
document.getElementById('rate').addEventListener('input', (e) => {
 document.getElementById('rateVal').textContent = e.target.value;
 chrome.storage.sync.set({ rate: e.target.value });
});

document.getElementById('pitch').addEventListener('input', (e) => {
 document.getElementById('pitchVal').textContent = e.target.value;
 chrome.storage.sync.set({ pitch: e.target.value });
});
```

This basic implementation reads the entire page content. For more refined control, consider extracting specific elements or providing text selection options.

## Implementing Selective Text Reading

Power users often want to read specific paragraphs or selected text rather than entire pages. Modify your content script to handle text selection:

```javascript
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'speakSelected') {
 const selected = window.getSelection().toString().trim();
 if (!selected) {
 sendResponse({ status: 'nothing selected' });
 return;
 }
 const utterance = new SpeechSynthesisUtterance(selected);
 utterance.onend = () => sendResponse({ status: 'completed' });
 utterance.onerror = (e) => sendResponse({ status: 'error', error: e.error });
 window.speechSynthesis.speak(utterance);
 return true; // Keep the message channel open for async response
 }
});
```

Add a context menu item in your background script to enable right-click access:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
 chrome.contextMenus.create({
 id: 'speakSelection',
 title: 'Speak Selected Text',
 contexts: ['selection']
 });

 chrome.contextMenus.create({
 id: 'stopSpeech',
 title: 'Stop Speaking',
 contexts: ['page', 'selection']
 });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
 if (info.menuItemId === 'speakSelection') {
 chrome.tabs.sendMessage(tab.id, { action: 'speakSelected' });
 }
 if (info.menuItemId === 'stopSpeech') {
 chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: () => window.speechSynthesis.cancel(),
 });
 }
});
```

This pattern allows users to highlight any text and have it read aloud immediately, without opening the popup at all.

## Working with Voice Options

The Web Speech API provides access to system voices through `speechSynthesis.getVoices()`. Different voices support different languages and have varying quality levels:

```javascript
function populateVoiceList() {
 const voices = window.speechSynthesis.getVoices();
 const select = document.getElementById('voiceSelect');
 select.innerHTML = '';
 voices.forEach(voice => {
 const option = document.createElement('option');
 option.value = voice.name;
 option.textContent = `${voice.name} (${voice.lang})${voice.default ? ' *' : ''}`;
 select.appendChild(option);
 });
}

// getVoices() is async. it fires onvoiceschanged when ready
if (window.speechSynthesis.onvoiceschanged !== undefined) {
 window.speechSynthesis.onvoiceschanged = populateVoiceList;
}
populateVoiceList(); // Also try immediately in case voices are already loaded
```

On macOS and Windows, you typically get 10–40+ voices including high-quality neural options like "Samantha" (macOS) or "Microsoft Zira" (Windows). ChromeOS and Linux installations often have fewer, lower-quality options, which is why cloud TTS is appealing for production tools targeting diverse platforms.

For a production extension, build a voice selector that lets users choose from available options. Store the preference in chrome.storage for persistence across sessions:

```javascript
// Save voice preference
document.getElementById('voiceSelect').addEventListener('change', (e) => {
 chrome.storage.sync.set({ selectedVoice: e.target.value });
});

// Restore saved preferences on popup load
chrome.storage.sync.get(['selectedVoice', 'rate', 'pitch'], (result) => {
 if (result.selectedVoice) {
 const option = [...document.getElementById('voiceSelect').options]
 .find(o => o.value === result.selectedVoice);
 if (option) option.selected = true;
 }
 if (result.rate) {
 document.getElementById('rate').value = result.rate;
 document.getElementById('rateVal').textContent = result.rate;
 }
 if (result.pitch) {
 document.getElementById('pitch').value = result.pitch;
 document.getElementById('pitchVal').textContent = result.pitch;
 }
});
```

## Chunking Long Text for Reliable Playback

One of the most common bugs in TTS extensions is that Chrome's speech synthesis silently stops mid-way through long texts. This is a known Chrome bug where `speechSynthesis` pauses after roughly 15 seconds and never resumes. The fix is to split text into manageable chunks:

```javascript
function speakInChunks(text, options = {}) {
 // Split on sentence boundaries to avoid mid-sentence cuts
 const sentences = text.match(/[^.!?]+[.!?]+/g) || [text];
 const chunks = [];
 let current = '';

 for (const sentence of sentences) {
 if ((current + sentence).length > 200) {
 if (current) chunks.push(current.trim());
 current = sentence;
 } else {
 current += sentence;
 }
 }
 if (current.trim()) chunks.push(current.trim());

 let index = 0;

 function speakNext() {
 if (index >= chunks.length) return;
 const utterance = new SpeechSynthesisUtterance(chunks[index]);
 if (options.voice) utterance.voice = options.voice;
 if (options.rate) utterance.rate = options.rate;
 if (options.pitch) utterance.pitch = options.pitch;

 utterance.onend = () => {
 index++;
 speakNext();
 };
 utterance.onerror = (e) => {
 console.error('TTS chunk error:', e.error, 'chunk index:', index);
 index++;
 speakNext(); // Skip errored chunk and continue
 };

 window.speechSynthesis.speak(utterance);
 }

 window.speechSynthesis.cancel(); // Clear any existing queue
 speakNext();
}
```

This chunking approach solves the silent-stop bug and gives users a smoother experience across all OS/Chrome version combinations.

## Advanced: Custom Audio Generation

When the Web Speech API falls short. due to voice quality, offline requirements, or specific formatting needs. consider integrating external TTS services. Popular options include Google Cloud Text-to-Speech, Amazon Polly, and open-source solutions like Coqui TTS.

A practical approach uses a background worker to fetch audio and deliver it to content scripts:

```javascript
// background.js
const TTS_API_URL = 'https://your-tts-api.com/synthesize';

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
 if (request.action === 'fetchAudio') {
 fetch(TTS_API_URL, {
 method: 'POST',
 headers: {
 'Content-Type': 'application/json',
 'Authorization': `Bearer ${request.apiKey}`,
 },
 body: JSON.stringify({ text: request.text, voice: request.voice })
 })
 .then(response => {
 if (!response.ok) throw new Error(`TTS API error: ${response.status}`);
 return response.blob();
 })
 .then(blob => {
 const url = URL.createObjectURL(blob);
 sendResponse({ url });
 })
 .catch(err => {
 console.error('Audio fetch failed:', err);
 sendResponse({ error: err.message });
 });

 return true; // Required for async sendResponse
 }
});
```

Then play the audio in your content script:

```javascript
chrome.runtime.sendMessage(
 { action: 'fetchAudio', text: selectedText, voice: 'en-US-Neural2-F' },
 (response) => {
 if (response.error) {
 console.error(response.error);
 return;
 }
 const audio = new Audio(response.url);
 audio.play();
 audio.onended = () => URL.revokeObjectURL(response.url);
 }
);
```

This hybrid approach combines the simplicity of Web Speech API for basic needs with the power of external services for advanced requirements.

## Testing and Debugging

Chrome provides useful debugging tools for TTS extensions. Access the console in your extension's popup or background page to monitor speech synthesis events. The Web Speech API fires events for state changes:

```javascript
utterance.onstart = () => console.log('Speech started');
utterance.onpause = () => console.log('Speech paused');
utterance.onresume = () => console.log('Speech resumed');
utterance.onend = () => console.log('Speech finished');
utterance.onerror = (e) => console.error('Speech error:', e.error);
utterance.onboundary = (e) => {
 // Fires at word or sentence boundaries. useful for highlighting
 console.log(`Boundary: ${e.name} at char ${e.charIndex}`);
};
```

The `onboundary` event is particularly valuable for building a word-highlight feature. you can use `e.charIndex` to track which word is being spoken and highlight it in the DOM in real time.

Test across different Chrome versions and platforms, as voice availability varies significantly between operating systems. Specifically test:

- macOS with multiple voices (Siri voices require user opt-in)
- Windows with Microsoft neural voices
- ChromeOS which has a limited voice set
- Linux where voice availability depends on installed packages

## Performance Considerations

Text-to-speech can impact page performance if not managed carefully. Always cancel previous utterances before starting new ones:

```javascript
window.speechSynthesis.cancel(); // Clear queue before new speech
window.speechSynthesis.speak(utterance);
```

For long texts, consider splitting content into chunks (see the chunking section above) to prevent memory issues and provide better user control over playback. Also keep these principles in mind:

- Avoid injecting heavy scripts into every page. use `activeTab` permission and inject only on demand
- Cache voice lists instead of re-querying `getVoices()` on every popup open
- If integrating with an external API, debounce API calls to avoid redundant charges when a user selects text but quickly deselects it
- Clean up `ObjectURL` instances created by `URL.createObjectURL()` after audio finishes playing

## Real-World Use Cases

Understanding where TTS extensions actually get used helps you design better ones:

Accessibility tools. Screen reader supplements for users with dyslexia, low vision, or motor impairments who cannot use a physical screen reader. These tools benefit most from word-level highlighting and per-user voice/rate settings stored in `chrome.storage.sync`.

Language learning. Reading foreign-language articles aloud with native-language voices helps learners build listening skills alongside reading. Pair TTS with a language detection API to auto-select the correct voice for the page's language.

Research and focus. Listening while reading increases retention for many people. Power users often run TTS at 1.5–2.0x speed. Make rate control a first-class feature.

Content moderation and review pipelines. Internal tools where staff review large volumes of text documents can use TTS to reduce eye fatigue during long review sessions.

Building a Chrome extension with text-to-speech functionality combines straightforward Web Speech API usage with the architectural flexibility Chrome extensions provide. Start with basic page reading, then expand based on user feedback. whether that means adding voice selection, offline support, or integration with external TTS services.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-text-to-speech)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Text to Speech Chrome Extension: A Developer Guide](/ai-text-to-speech-chrome-extension/)
- [Building a Chrome Extension Text Expander from Scratch](/chrome-extension-text-expander/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



