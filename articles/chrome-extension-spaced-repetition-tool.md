---
layout: default
title: "Chrome Extension Spaced Repetition Tool: Building Memory."
description: "Learn how to build a Chrome extension spaced repetition tool for memorizing programming concepts, API documentation, and technical vocabulary."
date: 2026-03-15
author: "theluckystrike"
permalink: /chrome-extension-spaced-repetition-tool/
categories: [guides]
tags: [spaced-repetition, chrome-extension, memory, learning, developer-tools, flashcards]
reviewed: true
score: 7
---

# Chrome Extension Spaced Repetition Tool: Building Memory Systems for Developers

Spaced repetition remains one of the most effective learning techniques available. When applied to developer learning—whether memorizing API parameters, syntax rules, or design patterns—a well-built Chrome extension spaced repetition tool can dramatically accelerate your technical knowledge retention. This guide walks you through building one from scratch.

## Why Developers Need Spaced Repetition

Programming requires memorizing vast amounts of information: command-line flags, library APIs, regex patterns, keyboard shortcuts. Traditional study sessions lead to rapid forgetting. Spaced repetition combats this by presenting information at increasing intervals, strengthening neural pathways through repeated retrieval practice.

A Chrome extension offers advantages over standalone apps. It can capture content directly from documentation pages, Stack Overflow answers, and tutorial sites. The learning happens where you already work—your browser—rather than requiring context switching to a separate application.

## Core Architecture

A Chrome extension spaced repetition system consists of three primary components:

1. **Storage Layer**: IndexedDB for card data and review schedules
2. **Content Scripts**: Extract selected text and inject review UI into web pages
3. **Background Service**: Manages review logic and handles extension lifecycle

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

- **API Methods**: Specific function signatures and return types
- **Regex Patterns**: Common patterns with explanation
- **Command Line**: CLI flags and their effects
- **Concept Definitions**: Architecture patterns, terminology
- **Keyboard Shortcuts**: IDE and browser shortcuts

Review during natural breaks—after completing a task, while waiting for builds, or at scheduled intervals. The key is consistency over duration. Fifteen minutes daily outperforms occasional hour-long cram sessions.

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


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
