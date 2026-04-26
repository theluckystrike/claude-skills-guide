---
layout: default
title: "Spaced Repetition Tool Chrome Extension (2026)"
description: "Claude Code extension tip: learn how to build a Chrome extension spaced repetition tool for memorizing programming concepts, API documentation, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "theluckystrike"
permalink: /chrome-extension-spaced-repetition-tool/
categories: [guides]
tags: [spaced-repetition, chrome-extension, memory, learning, developer-tools, flashcards]
reviewed: true
score: 7
geo_optimized: true
---
# Chrome Extension Spaced Repetition Tool: Building Memory Systems for Developers

Spaced repetition remains one of the most effective learning techniques available. When applied to developer learning, whether memorizing API parameters, syntax rules, or design patterns, a well-built Chrome extension spaced repetition tool can dramatically accelerate your technical knowledge retention. This guide walks you through building one from scratch.

## Why Developers Need Spaced Repetition

Programming requires memorizing vast amounts of information: command-line flags, library APIs, regex patterns, keyboard shortcuts. Traditional study sessions lead to rapid forgetting. Spaced repetition combats this by presenting information at increasing intervals, strengthening neural pathways through repeated retrieval practice.

A Chrome extension offers advantages over standalone apps. It can capture content directly from documentation pages, Stack Overflow answers, and tutorial sites. The learning happens where you already work, your browser, rather than requiring context switching to a separate application.

## Core Architecture

A Chrome extension spaced repetition system consists of three primary components:

1. Storage Layer: IndexedDB for card data and review schedules
2. Content Scripts: Extract selected text and inject review UI into web pages
3. Background Service: Manages review logic and handles extension lifecycle

The SM-2 algorithm (used by Anki) calculates optimal review intervals. Each card stores a difficulty rating, and after each review, the algorithm adjusts when you should see that card again.

## Implementing the Storage Layer

IndexedDB provides better performance and capacity than chrome.storage for large card collections. Here is a basic schema:

```javascript
// db.js - IndexedDB setup for card storage
const DB_NAME = 'spaced-repetition-db';
const DB_VERSION = 1;

export function openDatabase() {
 return new Promise((resolve, reject) => {
 const request = indexedDB.open(DB_NAME, DB_VERSION);
 
 request.onupgradeneeded = (event) => {
 const db = event.target.result;
 if (!db.objectStoreNames.contains('cards')) {
 const store = db.createObjectStore('cards', { keyPath: 'id', autoIncrement: true });
 store.createIndex('nextReview', 'nextReview', { unique: false });
 store.createIndex('deck', 'deck', { unique: false });
 }
 };
 
 request.onsuccess = () => resolve(request.result);
 request.onerror = () => reject(request.error);
 });
}

export async function addCard(deck, front, back) {
 const db = await openDatabase();
 const tx = db.transaction('cards', 'readwrite');
 const store = tx.objectStore('cards');
 
 const card = {
 deck,
 front,
 back,
 ease: 2.5,
 interval: 0,
 repetitions: 0,
 nextReview: Date.now(),
 created: Date.now()
 };
 
 store.add(card);
 return tx.complete;
}
```

## Building the Content Script

The content script handles two responsibilities: capturing selected text to create cards and displaying review prompts when triggered.

```javascript
// content-script.js
const REVIEW_MODAL_ID = 'sr-review-modal';

function createModal() {
 if (document.getElementById(REVIEW_MODAL_ID)) return;
 
 const modal = document.createElement('div');
 modal.id = REVIEW_MODAL_ID;
 modal.style.cssText = `
 position: fixed; top: 20%; left: 50%; transform: translateX(-50%);
 background: #1e1e1e; color: #fff; padding: 24px; border-radius: 8px;
 z-index: 999999; max-width: 500px; width: 90%;
 font-family: system-ui, sans-serif; box-shadow: 0 4px 20px rgba(0,0,0,0.5);
 `;
 document.body.appendChild(modal);
 return modal;
}

function showReviewCard(card) {
 const modal = createModal();
 modal.innerHTML = `
 <div class="sr-card">
 <p style="font-size: 18px; margin-bottom: 16px;">${card.front}</p>
 <hr style="border-color: #444; margin: 16px 0;">
 <p style="color: #aaa;">${card.back}</p>
 <div style="margin-top: 20px; display: flex; gap: 8px;">
 <button data-rating="again" style="background: #e74c3c;">Again</button>
 <button data-rating="hard" style="background: #f39c12;">Hard</button>
 <button data-rating="good" style="background: #27ae60;">Good</button>
 <button data-rating="easy" style="background: #3498db;">Easy</button>
 </div>
 </div>
 `;
 
 modal.querySelectorAll('button').forEach(btn => {
 btn.addEventListener('click', async (e) => {
 const rating = e.target.dataset.rating;
 await chrome.runtime.sendMessage({ action: 'rateCard', cardId: card.id, rating });
 modal.remove();
 });
 });
}

// Listen for review triggers from background
chrome.runtime.onMessage.addListener((message) => {
 if (message.action === 'showReview') {
 showReviewCard(message.card);
 }
});
```

## Implementing the SM-2 Algorithm

The background script manages the review schedule using a JavaScript implementation of SuperMemo-2:

```javascript
// background.js - SM-2 algorithm implementation
function calculateNextReview(card, rating) {
 const ratings = { again: 0, hard: 1, good: 3, easy: 5 };
 const quality = ratings[rating];
 
 let { ease, interval, repetitions } = card;
 
 if (quality < 3) {
 repetitions = 0;
 interval = 1;
 } else {
 if (repetitions === 0) {
 interval = 1;
 } else if (repetitions === 1) {
 interval = 6;
 } else {
 interval = Math.round(interval * ease);
 }
 repetitions++;
 }
 
 ease = ease + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
 ease = Math.max(1.3, ease);
 
 const nextReview = Date.now() + (interval * 24 * 60 * 60 * 1000);
 
 return { ease, interval, repetitions, nextReview };
}

async function getCardsForReview() {
 const db = await openDatabase();
 const tx = db.transaction('cards', 'readonly');
 const store = tx.objectStore('cards');
 const index = store.index('nextReview');
 const range = IDBKeyRange.upperBound(Date.now());
 
 return new Promise((resolve) => {
 const request = index.getAll(range);
 request.onsuccess = () => resolve(request.result.slice(0, 20));
 });
}
```

## Creating Cards from Browser Content

One powerful feature is capturing content directly from web pages:

```javascript
// Add card creation via context menu
chrome.contextMenus?.create({
 id: 'create-spaced-repetition-card',
 title: 'Create Flashcard from Selection',
 contexts: ['selection']
});

chrome.contextMenus?.onClicked.addListener(async (info, tab) => {
 if (info.menuItemId === 'create-spaced-repetition-card') {
 const selection = info.selectionText;
 // Store the selected text for card creation
 chrome.storage.local.set({ pendingCard: { front: selection, url: tab.url } });
 
 // Open a modal or redirect to card creation
 chrome.tabs.sendMessage(tab.id, { 
 action: 'openCardCreator', 
 front: selection 
 });
 }
});
```

## Practical Usage Patterns

When using your spaced repetition tool effectively, organize cards into focused decks. For developers, useful deck categories include:

- API Methods: Specific function signatures and return types
- Regex Patterns: Common patterns with explanation
- Command Line: CLI flags and their effects
- Concept Definitions: Architecture patterns, terminology
- Keyboard Shortcuts: IDE and browser shortcuts

Review during natural breaks, after completing a task, while waiting for builds, or at scheduled intervals. The key is consistency over duration. Fifteen minutes daily outperforms occasional hour-long cram sessions.

## Extension Manifest Requirements

Your manifest.json must declare appropriate permissions:

```json
{
 "manifest_version": 3,
 "name": "Dev Memory",
 "version": "1.0",
 "permissions": [
 "storage",
 "contextMenus",
 "activeTab"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "content_scripts": [{
 "matches": ["<all_urls>"],
 "js": ["content-script.js"]
 }],
 "background": {
 "service_worker": "background.js"
 }
}
```

## Next Steps

This foundation supports numerous enhancements: sync across devices using a backend, import/export card decks, track learning statistics, integrate with Obsidian or Notion for bidirectional linking, or add image support for visual memorization.

Building your own Chrome extension spaced repetition tool gives you full control over your learning system. Tailor card formats, review algorithms, and interface interactions to match your workflow precisely. The investment in setup pays dividends as you systematically consolidate technical knowledge over time.

## Step-by-Step Guide: Shipping a Spaced Repetition Extension

Here is a concrete approach to taking a spaced repetition extension from prototype to published Chrome extension.

Step 1. Set up your development environment. Create a project directory with a manifest.json, a content-script.js, a background.js service worker, and a popup.html with its associated popup.js. Claude Code generates the initial file structure with the correct Manifest V3 format, a build script using esbuild for bundling, and hot reload configuration so changes are reflected immediately during development.

Step 2. Implement the card data model first. Before building UI, define your card schema and the CRUD operations for IndexedDB. Claude Code generates the database module with typed card objects (front, back, ease, interval, repetitions, nextReview), all wrapped in a clean async API. Test this module in isolation before connecting it to the UI.

Step 3. Build the card creation flow. Users need a fast way to capture content as cards. Claude Code generates the context menu integration that creates a card from selected text, the popup form for manually entering cards, and the content script that highlights saved content on pages where cards were created.

Step 4. Implement the review session. The review session is the core experience. Claude Code generates the session manager that loads due cards, tracks the current card index, handles rating callbacks, and updates card schedules in IndexedDB. The session UI shows one card at a time, reveals the answer on click, and presents four rating buttons.

Step 5. Add a daily reminder notification. Chrome extensions can send desktop notifications to remind users to complete their daily reviews. Claude Code generates the alarm-based reminder that fires at the user's configured daily review time, checks the number of cards due, and sends a notification with the due count.

## Common Pitfalls

Using Manifest V2 APIs in a Manifest V3 extension. Chrome has sunset Manifest V2 and will reject new V2 extensions from the Web Store. The most common V2 APIs used accidentally are chrome.extension.getBackgroundPage() (replaced by service workers) and persistent background pages. Claude Code reviews your extension code and flags any V2 API usage.

Losing IndexedDB data on extension update. When you update your extension, the IndexedDB database persists but only if you handle schema migrations correctly. If you bump the DB_VERSION without handling the onupgradeneeded event for the new version, the old database structure causes errors. Claude Code generates the migration handler that upgrades the schema without losing existing card data.

Not handling storage quota limits. Chrome extensions have storage limits. For IndexedDB, the limit is a percentage of available disk space. Claude Code generates the storage usage monitor that checks remaining quota before adding large batches of cards and warns users when they are approaching the limit.

Not requesting permissions narrowly. The Chrome Web Store review process rejects extensions that request broader permissions than they use. Claude Code audits your manifest permissions against your actual API usage and recommends the minimum set of permissions.

Testing only in Chrome. If you plan to publish to the Firefox Add-ons store or Edge Add-ons, test in those browsers early. Manifest V3 support differs across browsers. Claude Code generates a compatibility notes file that documents known differences between Chrome, Firefox, and Edge for the APIs your extension uses.

## Best Practices

Separate content script logic from background logic clearly. Content scripts run in the context of web pages and have access to the DOM. Background service workers run in a separate context with access to extension APIs. Communication between them uses chrome.runtime.sendMessage. Claude Code generates the message protocol type definitions that make the communication contract explicit and type-safe.

Use the sync storage API for settings and IndexedDB for cards. Chrome provides chrome.storage.sync (synced across devices, 100KB limit) and chrome.storage.local (local only, 10MB limit). Use sync storage for user preferences. Use IndexedDB for card data. Claude Code generates the settings module that uses the appropriate storage API for each setting.

Add keyboard shortcuts for review ratings. Power users rate cards much faster with keyboard shortcuts (1 for Again, 2 for Hard, 3 for Good, 4 for Easy). Claude Code generates the keyboard event listener that maps number keys to rating buttons during a review session, with a visual indicator showing which key maps to which rating.

Implement undo for rating mistakes. Accidentally rating a card incorrectly changes its schedule significantly. An undo stack that remembers the last few rating actions lets users correct mistakes. Claude Code generates the undo system with a keyboard shortcut and an undo button in the review UI.

## Study Algorithm Customization

The SM-2 algorithm that powers most spaced repetition systems was designed in the 1980s for flashcard memorization. Modern research suggests several improvements that Claude Code can generate for your extension.

Leech detection and handling. Cards that you repeatedly rate "Again" despite multiple reviews are called leeches. they waste study time without being learned. Claude Code generates the leech detection algorithm that tracks the ratio of "Again" ratings to total reviews for each card, flags cards exceeding a configurable threshold (typically 8 or more lapses), and moves them to a suspended state with a notification prompting you to rewrite the card as multiple simpler cards.

Interleaved practice scheduling. Blocking practice. studying all cards from one topic before moving to the next. produces worse long-term retention than interleaved practice that mixes topics. Claude Code generates the scheduler modification that groups due cards by deck and interleaves them in round-robin order, ensuring you switch topics every few cards rather than burning through one deck at a time.

Contextual review sessions. Some knowledge is easier to recall in the context where it was learned. Claude Code generates the session context tagging system that associates cards with the URL where they were created, and a context-aware review mode that opens the original source page alongside the review card. useful for vocabulary learned in specific articles or code patterns seen in particular repositories.

Adaptive daily limits. Fixed daily review limits cause card backlogs after missed days. Claude Code generates the adaptive limit algorithm that increases the daily review target after missed days (catching up gradually) and decreases it when your retention rate drops below a threshold (preventing overwhelm), keeping your review load sustainable without manual adjustment.

## Integration Patterns

Obsidian plugin integration. Claude Code generates a companion Obsidian plugin that reads flashcard definitions from your vault's markdown files and syncs them to your Chrome extension's IndexedDB through a local API. This lets you manage cards in Obsidian and review them in the browser.

GitHub Gist sync. For users who want to back up their card decks without setting up a server, Claude Code generates the GitHub Gist sync module that exports your card decks as JSON, stores them in a private Gist, and imports them back on a new device.

Anki-compatible export. Claude Code generates the Anki deck export function that converts your IndexedDB cards into an Anki-compatible format. Users who want to move to Anki or share their decks with Anki users can export with one click from the extension popup.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-spaced-repetition-tool)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [How to Find Chrome Extensions That Use Memory for Enhanced Productivity](/find-chrome-extension-using-memory/)
- [Chrome Extension Markdown Editor: Build Your Own Browser-Based Writing Tool](/chrome-extension-markdown-editor/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [Chrome Extension Discount Code Aggregator](/chrome-extension-discount-code-aggregator/)
- [Best Free Time Tracking Chrome Extensions for Developers](/time-tracking-chrome-extension-free/)
- [Screencastify Alternative Chrome Extension in 2026](/screencastify-alternative-chrome-extension-2026/)
- [Clearbit Alternative Chrome Extension in 2026](/clearbit-alternative-chrome-extension-2026/)
- [Proton Pass Chrome — Honest Review 2026](/proton-pass-chrome-review/)
- [Chrome Signage Kiosk Digital Display — Developer Guide](/chrome-signage-kiosk-digital-display/)
- [Wireframe Builder Chrome Extension Guide (2026)](/chrome-extension-wireframe-builder/)
- [Guest Mode vs Incognito in Chrome — Differences (2026)](/chrome-guest-mode-vs-incognito/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


