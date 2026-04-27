---
sitemap: false

layout: default
title: "Chrome Extension Word Counter for Essay (2026)"
description: "Claude Code extension tip: build a Chrome extension that counts words in essays and documents. Practical code examples, implementation patterns, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-word-counter-essay/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---


Chrome Extension Word Counter for Essay Writing: A Developer Guide

When you need to track word count while writing essays, blog posts, or any lengthy document, a well-built Chrome extension becomes an indispensable tool. This guide shows you how to create a word counter extension tailored for essay writing, with real-time counting, character tracking, and reading time estimates.

## Why Build a Custom Word Counter Extension

Most writing platforms include basic word counting, but they often fall short for essay writers who need additional metrics. A custom extension gives you control over:

- Real-time word and character counts across any website
- Reading time estimation based on average reading speeds
- Goal tracking with customizable word count targets
- Support for textareas, contenteditable elements, and rich text editors

The Chrome extension API provides everything you need to monitor user input across different input types.

## Project Structure

A Chrome extension requires a specific directory structure. For a word counter, you'll need:

```
word-counter-extension/
 manifest.json
 popup.html
 popup.js
 content.js
 styles.css
 icons/
 icon16.png
 icon48.png
 icon128.png
```

The manifest defines your extension's capabilities and permissions. For a word counter targeting essay writing sites, you'll need permissions to access the active tab and inject content scripts.

## Creating the Manifest

Your extension's manifest.json defines its behavior and permissions:

```json
{
 "manifest_version": 3,
 "name": "Essay Word Counter",
 "version": "1.0.0",
 "description": "Track word count, character count, and reading time for essays",
 "permissions": ["activeTab", "scripting"],
 "action": {
 "default_popup": "popup.html",
 "default_icon": {
 "16": "icons/icon16.png",
 "48": "icons/icon48.png",
 "128": "icons/icon128.png"
 }
 },
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content.js"],
 "css": ["styles.css"]
 }]
}
```

The content_scripts section injects your counting logic into every page, enabling word counting on any writing platform.

## Content Script: Counting Words in Real Time

The content script runs in the context of the page and monitors user input. Here's a solid implementation:

```javascript
class WordCounter {
 constructor() {
 this.targetElements = [
 'textarea',
 '[contenteditable="true"]',
 '.editor',
 '.prose-editor',
 '[data-placeholder="Write something..."]'
 ];
 this.init();
 }

 init() {
 this.targetElements.forEach(selector => {
 document.querySelectorAll(selector).forEach(element => {
 element.addEventListener('input', () => this.count());
 element.addEventListener('paste', () => {
 setTimeout(() => this.count(), 0);
 });
 });
 });

 // Also check for dynamic elements using MutationObserver
 const observer = new MutationObserver(mutations => {
 mutations.forEach(mutation => {
 mutation.addedNodes.forEach(node => {
 if (node.nodeType === 1) {
 this.checkAndAttach(node);
 }
 });
 });
 });

 observer.observe(document.body, { childList: true, subtree: true });
 this.count();
 }

 checkAndAttach(element) {
 this.targetElements.forEach(selector => {
 if (element.matches?.(selector) || element.querySelector(selector)) {
 element.addEventListener('input', () => this.count());
 this.count();
 }
 });
 }

 count() {
 const text = this.getTextFromPage();
 const stats = this.calculateStats(text);
 this.updateDisplay(stats);
 this.sendToPopup(stats);
 }

 getTextFromPage() {
 const textareas = document.querySelectorAll('textarea');
 const editableElements = document.querySelectorAll('[contenteditable="true"]');
 
 let text = '';
 textareas.forEach(el => text += el.value + ' ');
 editableElements.forEach(el => text += el.innerText + ' ');
 
 return text;
 }

 calculateStats(text) {
 const cleanText = text.trim();
 const words = cleanText ? cleanText.split(/\s+/).filter(w => w.length > 0) : [];
 const characters = cleanText.replace(/\s/g, '').length;
 const charactersWithSpaces = cleanText.length;
 
 // Average reading speed: 200 words per minute for essays
 const readingTime = Math.ceil(words.length / 200);
 const speakingTime = Math.ceil(words.length / 130);

 return {
 words: words.length,
 characters,
 charactersWithSpaces,
 readingTime,
 speakingTime,
 paragraphs: cleanText ? cleanText.split(/\n\n+/).filter(p => p.trim().length > 0).length : 0,
 sentences: cleanText ? cleanText.split(/[.!?]+/).filter(s => s.trim().length > 0).length : 0
 };
 }

 updateDisplay(stats) {
 let display = document.getElementById('word-counter-display');
 if (!display) {
 display = document.createElement('div');
 display.id = 'word-counter-display';
 display.className = 'word-counter-floating';
 document.body.appendChild(display);
 }

 display.innerHTML = `
 <div class="wc-stat">${stats.words} words</div>
 <div class="wc-stat">${stats.characters} chars</div>
 <div class="wc-stat">${stats.readingTime} min read</div>
 `;
 }

 sendToPopup(stats) {
 chrome.runtime.sendMessage({
 type: 'WORD_COUNT_UPDATE',
 stats: stats
 });
 }
}

new WordCounter();
```

This implementation handles multiple input types, dynamically added elements, and provides comprehensive statistics.

## The Popup Interface

The popup displays your word count when clicking the extension icon:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body {
 width: 280px;
 padding: 16px;
 font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
 }
 .stat-row {
 display: flex;
 justify-content: space-between;
 padding: 8px 0;
 border-bottom: 1px solid #eee;
 }
 .stat-label { color: #666; }
 .stat-value { font-weight: 600; }
 .goal-section {
 margin-top: 16px;
 padding: 12px;
 background: #f5f5f5;
 border-radius: 8px;
 }
 .progress-bar {
 height: 8px;
 background: #e0e0e0;
 border-radius: 4px;
 margin-top: 8px;
 overflow: hidden;
 }
 .progress-fill {
 height: 100%;
 background: #4CAF50;
 transition: width 0.3s ease;
 }
 </style>
</head>
<body>
 <h3>Essay Word Counter</h3>
 
 <div class="stat-row">
 <span class="stat-label">Words</span>
 <span class="stat-value" id="word-count">0</span>
 </div>
 <div class="stat-row">
 <span class="stat-label">Characters</span>
 <span class="stat-value" id="char-count">0</span>
 </div>
 <div class="stat-row">
 <span class="stat-label">Paragraphs</span>
 <span class="stat-value" id="para-count">0</span>
 </div>
 <div class="stat-row">
 <span class="stat-label">Reading Time</span>
 <span class="stat-value" id="read-time">0 min</span>
 </div>

 <div class="goal-section">
 <div class="stat-row">
 <span class="stat-label">Goal</span>
 <span class="stat-value" id="goal-display">500 words</span>
 </div>
 <div class="progress-bar">
 <div class="progress-fill" id="progress-fill" style="width: 0%"></div>
 </div>
 </div>

 <script src="popup.js"></script>
</body>
</html>
```

The popup receives updates from the content script via Chrome's messaging system.

## Handling Reading Time Calculations

For essay writing, accurate reading time matters. Different formulas apply:

- Slow reading: 100-150 words per minute
- Average reading: 200-250 words per minute 
- Fast reading: 300+ words per minute
- Speaking pace: 130-150 words per minute (useful for presentation timing)

You can make this configurable in your extension, allowing users to choose their preferred baseline.

## Advanced Features to Consider

Once the basics work, consider adding these features:

Goal tracking: Store word count goals in chrome.storage and show progress visually. This motivates essay writers working toward specific lengths.

Session statistics: Track writing sessions by storing start time and total words written. This helps identify productivity patterns.

Export functionality: Allow users to export their writing statistics as JSON or CSV for analysis.

Platform-specific handling: Different platforms like Google Docs, Medium, and WordPress have unique DOM structures. Add specific selectors for popular writing platforms.

## Testing Your Extension

Before publishing, test thoroughly across different scenarios:

1. Load your extension in Developer Mode via chrome://extensions
2. Test on Google Docs, Notion, Medium, and plain textareas
3. Verify paste events trigger accurate counting
4. Check that dynamically added editors get tracked
5. Test with various text formats including markdown

## Conclusion

Building a word counter Chrome extension for essay writing combines straightforward DOM manipulation with Chrome's extension APIs. The key is handling diverse input types gracefully and providing the statistics that matter to writers, word count, character count, and reading time.

With this foundation, you can expand into more sophisticated features like grammar checking, style analysis, or integration with writing goals. The extension architecture gives you flexibility to add whatever features serve your target users best.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-word-counter-essay)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI SEO Writing Chrome Extension: A Developer's Guide](/ai-seo-writing-chrome-extension/)
- [AI Writing Assistant Chrome Extension Free: A Developer's Guide](/ai-writing-assistant-chrome-extension-free/)
- [AI Writing Tools for Real Estate Listings 2026: A.](/ai-writing-tools-for-real-estate-listings-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

