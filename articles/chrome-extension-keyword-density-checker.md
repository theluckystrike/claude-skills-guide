---
layout: default
title: "Chrome Extension Keyword Density Checker (2026)"
description: "Learn how to build and use a Chrome extension for keyword density analysis. Includes code examples, implementation patterns, and practical usage for."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-keyword-density-checker/
reviewed: true
score: 8
categories: [integrations, guides]
tags: [chrome-extension, seo, keyword-research]
geo_optimized: true
---

# Chrome Extension Keyword Density Checker: A Developer's Guide

Keyword density remains a useful metric for content optimization, even as search engines have evolved beyond simple word-count algorithms. For developers building SEO tools or content creators who want quick analysis without leaving their browser, a Chrome extension for keyword density checking provides immediate value.

This guide covers how to build a keyword density checker as a Chrome extension, the core algorithms involved, and practical approaches for implementing this tool efficiently. By the end, you'll have a functional extension and a clear picture of where to take it next.

## Understanding Keyword Density Calculation

Keyword density represents the percentage of times a specific keyword or phrase appears relative to the total word count on a page. The basic formula is straightforward:

```
density = (keyword_count / total_words) * 100
```

For multi-word phrases, you calculate based on the target phrase rather than individual words. A typical "good" density falls between 1-3%, though this varies by content type and industry. Exact thresholds matter less than consistency. you're mostly trying to confirm that important terms are present without tipping into obvious stuffing.

Modern implementations go beyond simple counting. A solid checker should handle:

- Case-insensitive matching
- Partial word matches (optional)
- Multiple keyword tracking
- Exclusion of common stop words
- Analysis of both visible content and metadata

One subtlety worth understanding early: `document.body.innerText` gives you visible text but excludes content hidden via CSS (`display: none`, `visibility: hidden`). This is usually what you want for density analysis. hidden content doesn't contribute to the reading experience. but it means your numbers may differ slightly from server-side analysis tools that parse raw HTML.

## Building the Extension Structure

A Chrome extension requires a manifest file, background scripts, and content scripts. Here's the essential structure for a keyword density checker:

## Manifest Configuration

```json
{
 "manifest_version": 3,
 "name": "Keyword Density Checker",
 "version": "1.0",
 "description": "Analyze keyword density on any webpage",
 "permissions": ["activeTab", "scripting", "storage"],
 "action": {
 "default_popup": "popup.html"
 },
 "host_permissions": ["<all_urls>"]
}
```

The manifest defines the extension's permissions and the popup interface users interact with. The `storage` permission is worth adding upfront. you'll almost certainly want to persist the user's keyword list between sessions so they don't have to retype it every time they open the extension.

## Content Script for Page Analysis

The content script extracts text from the active page and performs the density calculation:

```javascript
function analyzePageContent(keywords) {
 const bodyText = document.body.innerText;
 const words = bodyText.split(/\s+/).filter(w => w.length > 0);
 const totalWords = words.length;

 const results = keywords.map(keyword => {
 const regex = new RegExp(keyword, 'gi');
 const matches = bodyText.match(regex) || [];
 const count = matches.length;
 const density = (count / totalWords) * 100;

 return {
 keyword,
 count,
 density: density.toFixed(2)
 };
 });

 return { totalWords, results };
}
```

This function extracts all visible text, splits it into words, and calculates density for each target keyword.

One issue with the regex approach above: a pattern like `"cat"` will match inside "concatenate" and "category". If you want whole-word matching only, wrap the keyword in word-boundary assertions:

```javascript
const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
```

Whether you want whole-word matching depends on your use case. For short, generic keywords, whole-word matching prevents false positives. For branded terms or technical jargon that appear as substrings, you may prefer the looser match.

## Popup Interface

The popup provides user input for keywords and displays results:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 300px; padding: 16px; font-family: system-ui; }
 input { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; }
 button { width: 100%; padding: 8px; background: #4a90d9; color: white; border: none; cursor: pointer; border-radius: 4px; }
 button:hover { background: #357abd; }
 .result { margin-top: 12px; padding: 8px; background: #f5f5f5; border-radius: 4px; }
 .density-bar { height: 6px; background: #4a90d9; border-radius: 3px; margin-top: 4px; }
 .warning { color: #c0392b; font-size: 12px; }
 </style>
</head>
<body>
 <h3>Keyword Density</h3>
 <input type="text" id="keywords" placeholder="Enter keywords (comma separated)">
 <button id="analyze">Analyze Page</button>
 <div id="output"></div>
 <script src="popup.js"></script>
</body>
</html>
```

The small additions to the original. `box-sizing: border-box` on the input, hover state on the button, density bar, warning class. go a long way toward making the tool feel polished. Users are more likely to reach for an extension that looks intentional.

## Popup Script with Result Rendering

The popup.js file connects the button click to the content script and renders results:

```javascript
// popup.js
document.getElementById('analyze').addEventListener('click', async () => {
 const raw = document.getElementById('keywords').value;
 const keywords = raw.split(',').map(k => k.trim()).filter(k => k.length > 0);

 if (keywords.length === 0) return;

 // Save keywords for next session
 chrome.storage.local.set({ lastKeywords: raw });

 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 const results = await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: analyzePageContent,
 args: [keywords]
 });

 renderResults(results[0].result, document.getElementById('output'));
});

// Restore last used keywords on open
chrome.storage.local.get('lastKeywords', ({ lastKeywords }) => {
 if (lastKeywords) document.getElementById('keywords').value = lastKeywords;
});

function renderResults(data, container) {
 const { totalWords, results } = data;
 container.innerHTML = `<p><strong>Total words:</strong> ${totalWords}</p>`;

 results.forEach(r => {
 const density = parseFloat(r.density);
 const isHigh = density > 4;
 const barWidth = Math.min(density * 20, 100); // scale for visual

 container.innerHTML += `
 <div class="result">
 <strong>${r.keyword}</strong>: ${r.count} times (${r.density}%)
 ${isHigh ? '<span class="warning"> is over-optimized</span>' : ''}
 <div class="density-bar" style="width: ${barWidth}%"></div>
 </div>`;
 });
}
```

## Advanced Features for Power Users

Beyond basic counting, consider implementing these features for a more capable tool.

## Stop Word Filtering

Raw word counts include common words like "the", "and", "is" that inflate the total and distort density figures. Filtering them gives a more meaningful denominator:

```javascript
const STOP_WORDS = new Set([
 'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to',
 'for', 'of', 'with', 'by', 'from', 'is', 'was', 'are', 'were',
 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did',
 'will', 'would', 'could', 'should', 'may', 'might', 'it', 'its',
 'this', 'that', 'these', 'those', 'i', 'you', 'he', 'she', 'we', 'they'
]);

function countMeaningfulWords(text) {
 return text
 .toLowerCase()
 .split(/\s+/)
 .filter(w => w.length > 0 && !STOP_WORDS.has(w.replace(/[^a-z]/g, '')))
 .length;
}
```

With stop words excluded, a density of 3% in the filtered count is a more informative signal than 3% in the raw count, because you're measuring how prominent the keyword is relative to the meaningful content. not filler words.

## Real-Time Analysis

Monitor page changes and update density automatically:

```javascript
const observer = new MutationObserver(() => {
 const keywords = getKeywordsFromInput();
 const analysis = analyzePageContent(keywords);
 updatePopupDisplay(analysis);
});

observer.observe(document.body, {
 childList: true,
 subtree: true,
 characterData: true
});
```

This approach catches dynamically loaded content but requires debouncing to avoid excessive calculations.

## Page Section Analysis

Different sections of a page warrant different keyword emphasis. Allow users to analyze specific elements:

```javascript
function analyzeElement(element, keyword) {
 const text = element.innerText;
 const words = text.split(/\s+/).length;
 const matches = (text.match(new RegExp(keyword, 'gi')) || []).length;

 return {
 element: element.tagName,
 words,
 density: ((matches / words) * 100).toFixed(2)
 };
}

function analyzeHeadings(keyword) {
 const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
 return Array.from(headings).map(h => analyzeElement(h, keyword));
}
```

Heading analysis is particularly useful. A keyword appearing in H1 and at least one H2 is a healthy signal. If the keyword is absent from all headings but appears frequently in body text, that's worth flagging. it suggests the page structure doesn't reinforce the topic clearly.

## Export Functionality

Power users often need to export data for reports:

```javascript
function exportToCSV(results) {
 const headers = ['Keyword', 'Count', 'Density (%)', 'In H1', 'In H2'];
 const rows = results.map(r => [
 r.keyword,
 r.count,
 r.density,
 r.inH1 ? 'Yes' : 'No',
 r.inH2 ? 'Yes' : 'No'
 ]);

 const csv = [headers, ...rows]
 .map(row => row.map(cell => `"${cell}"`).join(','))
 .join('\n');

 const blob = new Blob([csv], { type: 'text/csv' });
 const url = URL.createObjectURL(blob);

 chrome.downloads.download({ url, filename: 'keyword-density.csv' });
}
```

Note the addition of `"${cell}"` quoting around each cell. this prevents issues when keyword values contain commas.

## Performance Considerations

When analyzing pages with extensive content, performance matters. Implement these optimizations:

1. Text caching: Store extracted text and only recalculate when the page changes
2. Web Workers: Move heavy computation off the main thread
3. Debouncing: Limit analysis frequency during page interactions
4. Selective extraction: Target specific elements rather than processing entire documents

```javascript
function debounce(func, wait) {
 let timeout;
 return function(...args) {
 clearTimeout(timeout);
 timeout = setTimeout(() => func.apply(this, args), wait);
 };
}

const debouncedAnalyze = debounce(analyzePageContent, 300);
```

For very long-form pages (documentation sites, legal documents, novels), the word split and regex matching can take a noticeable amount of time. Moving it to a Web Worker keeps the UI responsive:

```javascript
// worker.js
self.onmessage = function({ data }) {
 const { text, keywords } = data;
 const words = text.split(/\s+/).filter(w => w.length > 0);
 const totalWords = words.length;

 const results = keywords.map(keyword => {
 const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
 const count = (text.match(regex) || []).length;
 return { keyword, count, density: ((count / totalWords) * 100).toFixed(2) };
 });

 self.postMessage({ totalWords, results });
};

// In your content script
const worker = new Worker(chrome.runtime.getURL('worker.js'));
worker.postMessage({ text: document.body.innerText, keywords });
worker.onmessage = ({ data }) => sendResponse(data);
```

Remember to add the worker file to your manifest's `web_accessible_resources` so the content script can load it via `chrome.runtime.getURL`.

## Comparison: Density Checker Approaches

| Method | Accuracy | Works Offline | Real-Time | Handles Dynamic Content |
|---|---|---|---|---|
| Chrome Extension | High (live DOM) | Yes (after install) | Yes (with MutationObserver) | Yes |
| Online Tool (Yoast, SEMrush) | Medium (raw HTML parsing) | No | No | No |
| CMS Plugin (Yoast SEO) | High (editor context) | Yes | Yes | Yes (within editor) |
| Console Snippet | High (live DOM) | Yes | No | Yes (manual re-run) |
| Build-time linter | Medium (static analysis) | Yes | Yes (on save) | No |

A Chrome extension wins on flexibility: it works on any site you don't control, including competitor pages, and it gives you live DOM data rather than cached HTML. CMS plugins are more convenient for your own content but don't generalize.

## Practical Usage Patterns

A keyword density checker becomes valuable in these common scenarios:

Content Auditing: Before publishing, verify that target keywords appear at appropriate frequencies without over-optimization. This helps avoid penalties from search engines that penalize keyword stuffing.

Competitive Analysis: Analyze competitor pages to understand their keyword emphasis. Compare multiple pages to identify patterns in successful content. A useful workflow is to open the top three ranking pages for a query, run the density checker on each, and note the range. that range is a reasonable target for your own content.

Site Audits: Review your own pages to ensure important content maintains proper keyword distribution across headings, paragraphs, and metadata. The heading analysis feature is especially valuable here: if your target keyword doesn't appear in any heading, that's a quick win to address.

Learning Tool: For those new to SEO, seeing actual density numbers provides concrete feedback on how keywords are distributed in real-world content. It demystifies what "keyword prominence" means in practice.

Pre-Publish Checklist: Add a density check as the final step before hitting publish. Confirm the primary keyword appears in H1, at least one H2, the first 100 words, and the meta description. This kind of structured checklist is easy to automate in the extension itself:

```javascript
function runPublishChecklist(keyword, pageData) {
 return {
 inH1: pageData.h1Text.toLowerCase().includes(keyword.toLowerCase()),
 inFirstH2: pageData.h2Texts[0]?.toLowerCase().includes(keyword.toLowerCase()) || false,
 inFirst100Words: pageData.first100Words.toLowerCase().includes(keyword.toLowerCase()),
 inMetaDescription: pageData.metaDescription.toLowerCase().includes(keyword.toLowerCase()),
 densityInRange: parseFloat(pageData.density) >= 1 && parseFloat(pageData.density) <= 3
 };
}
```

Returning a checklist object makes it trivial to render a pass/fail summary in the popup.

## Integration with Development Workflow

Developers can integrate density checking into their workflow through several approaches:

- Bookmarklets: Quick analysis without installing extensions
- Browser DevTools: Analyze pages directly in the console
- Build Pipeline: Validate content during deployment
- CMS Plugins: Add density checking to content editing interfaces

Each approach serves different use cases. The Chrome extension provides the most accessible entry point for regular use.

For build pipeline integration, you can port the core algorithm to a Node.js script and run it as part of a CI check on new or modified content files:

```javascript
// density-check.js. run in Node.js CI
const fs = require('fs');
const path = require('path');

function checkFile(filePath, keywords) {
 const content = fs.readFileSync(filePath, 'utf8');
 // Strip front matter and HTML tags for plain text
 const text = content
 .replace(/^---[\s\S]*?---/, '')
 .replace(/<[^>]+>/g, ' ');

 const words = text.split(/\s+/).filter(w => w.length > 0);
 const totalWords = words.length;

 keywords.forEach(keyword => {
 const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
 const count = (text.match(regex) || []).length;
 const density = (count / totalWords * 100).toFixed(2);
 if (parseFloat(density) > 4) {
 console.warn(`[WARN] ${path.basename(filePath)}: "${keyword}" density ${density}%. is over-optimized`);
 }
 });
}
```

This surfaces the same checks your Chrome extension runs, but catches issues before content reaches production.

## What to Build Next

A working keyword density checker is a solid foundation. Here are natural next steps:

- TF-IDF scoring: Supplement raw density with term frequency–inverse document frequency to measure how distinctive a keyword is on the page relative to the broader web.
- LSI keyword suggestions: After analyzing the target keyword, surface semantically related terms that competitors use but your page doesn't. these represent content gaps.
- Density history: Track density across multiple visits to the same URL to monitor whether content changes improved or degraded keyword coverage.
- Batch analysis: Let users paste a list of URLs and analyze all of them in sequence, writing results to a single CSV.

The Chrome extension format scales well for all of these additions. Because the core architecture separates content extraction (content script), logic (background service worker), and display (popup), each feature can be added without disrupting the others.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-keyword-density-checker)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Arrow and Text Overlay Screenshot Guide](/chrome-extension-arrow-and-text-overlay-screenshot/)
- [Colorpick Eyedropper Alternative Chrome Extension in 2026](/colorpick-eyedropper-alternative-chrome-extension-2026/)
- [Chrome Enterprise VPN Integration - A Practical Guide.](/chrome-enterprise-vpn-integration/)
- [Best SimilarWeb Alternatives for Chrome 2026](/similarweb-alternative-chrome-extension-2026/)
- [Timezone Converter Remote Chrome Extension Guide (2026)](/chrome-extension-timezone-converter-remote/)
- [User Agent Switcher Developer Chrome Extension Guide (2026)](/chrome-extension-user-agent-switcher-developer/)
- [Knowledge Wiki Team Chrome Extension Guide (2026)](/chrome-extension-knowledge-wiki-team/)
- [LastPass Alternative Chrome Extension 2026](/lastpass-alternative-chrome-extension-2026/)
- [Page Ruler Alternative Chrome Extension 2026](/page-ruler-alternative-chrome-extension-2026/)
- [AI Voice Typing Chrome Extension Guide (2026)](/ai-voice-typing-chrome-extension/)
- [Virtual Background Chrome Extension Guide (2026)](/virtual-background-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


