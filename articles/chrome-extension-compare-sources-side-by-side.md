---

layout: default
title: "How to Compare Sources Side by Side (2026)"
description: "Learn how to build or use Chrome extensions that compare sources side by side for code review, diff checking, and content comparison."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-compare-sources-side-by-side/
reviewed: true
score: 8
categories: [comparisons]
tags: [claude-code, claude-skills]
geo_optimized: true
---


How to Compare Sources Side by Side in Chrome Extensions

Comparing two sources side by side is a common task for developers reviewing code changes, writers checking document revisions, or anyone needing to spot differences between two pieces of text. Chrome extensions offer powerful ways to bring this capability directly into your browser, eliminating the need to copy-paste content into external tools.

This guide covers how to build a Chrome extension that compares sources side by side, existing extensions you can use today, and practical implementation details for developers. By the end, you will have a working extension with real diff highlighting and enough understanding to extend it for your own workflow.

## Why Compare Sources in Your Browser

Browser-based comparison tools save time when working with web content. Instead of downloading files or opening separate applications, you can compare sources while browsing documentation, reviewing pull requests, or analyzing competing websites.

The side-by-side view presents two panels showing the original and modified content, making it easy to spot additions, deletions, and modifications at a glance. This approach works particularly well for:

- Code reviews on platforms without built-in diff views
- Comparing API documentation versions across two tabs
- Checking email templates or HTML snippets for subtle errors
- Analyzing competitor website copy for SEO or positioning changes
- Validating that a CMS export matches a source document

Beyond convenience, keeping comparisons inside the browser reduces the risk of accidentally pasting sensitive content into an online third-party tool. A local extension processes everything client-side, which matters for legal documents, internal specs, or user data.

## When a Browser Extension Beats a Desktop Tool

Desktop diff tools like FileMerge, WinMerge, or VS Code's built-in diff are excellent for file-based comparisons. But they require you to save the text first, which adds friction when your sources live on web pages. An extension lets you grab content from a rendered page. after JavaScript has executed and templates have resolved. and compare it instantly. That is especially useful when reviewing live documentation against a draft, or checking whether a deployed webpage matches a staging version.

## Building a Basic Comparison Extension

Creating a Chrome extension for side-by-side comparison involves three main components: a popup for user input, a content script for page interaction, and a diff library for the comparison logic.

## Project Structure

```
compare-sources/
 manifest.json
 popup.html
 popup.js
 content.js
 diff-worker.js
 icon.png
```

manifest.json

```json
{
 "manifest_version": 3,
 "name": "Compare Sources Side by Side",
 "version": "1.0",
 "description": "Compare two sources side by side in your browser",
 "permissions": ["activeTab", "scripting"],
 "action": {
 "default_popup": "popup.html"
 },
 "content_scripts": [
 {
 "matches": ["<all_urls>"],
 "js": ["content.js"],
 "run_at": "document_idle"
 }
 ]
}
```

Note that `content_scripts` is declared in the manifest here so the content script is ready when the popup sends a message. Alternatively, you can inject it dynamically using `chrome.scripting.executeScript`, which is cleaner if you only need the script on demand.

popup.html

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 420px; padding: 16px; font-family: system-ui; }
 textarea { width: 100%; height: 90px; margin-bottom: 8px; font-family: monospace; font-size: 12px; box-sizing: border-box; }
 .controls { display: flex; gap: 8px; }
 button { background: #4285f4; color: white; border: none; padding: 8px 16px; cursor: pointer; border-radius: 4px; flex: 1; }
 button:hover { background: #3367d6; }
 #grabBtn { background: #34a853; }
 #grabBtn:hover { background: #2d9148; }
 label { font-size: 12px; color: #555; display: block; margin-bottom: 4px; }
 </style>
</head>
<body>
 <h3 style="margin:0 0 12px">Compare Sources</h3>
 <label>Source A (original)</label>
 <textarea id="source1" placeholder="Paste first source here..."></textarea>
 <label>Source B (modified)</label>
 <textarea id="source2" placeholder="Paste second source here..."></textarea>
 <div class="controls">
 <button id="compareBtn">Compare Side by Side</button>
 <button id="grabBtn" title="Grab page source into Source A">Grab Page</button>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

The "Grab Page" button is a practical addition: it pulls the current page's text content into the first textarea, so you can quickly compare the live page against a clipboard paste without leaving the browser.

popup.js

```javascript
document.getElementById('compareBtn').addEventListener('click', async () => {
 const source1 = document.getElementById('source1').value;
 const source2 = document.getElementById('source2').value;

 if (!source1.trim() || !source2.trim()) {
 alert('Please fill in both sources before comparing.');
 return;
 }

 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 chrome.tabs.sendMessage(tab.id, {
 action: 'openComparison',
 source1,
 source2
 });

 window.close(); // Close the popup so the view fills the screen
});

document.getElementById('grabBtn').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

 const results = await chrome.scripting.executeScript({
 target: { tabId: tab.id },
 func: () => document.body.innerText
 });

 if (results && results[0]) {
 document.getElementById('source1').value = results[0].result;
 }
});
```

## Content Script for Display

```javascript
// content.js
chrome.runtime.onMessage.addListener((message) => {
 if (message.action === 'openComparison') {
 createComparisonView(message.source1, message.source2);
 }
});

function computeLineDiff(oldText, newText) {
 const oldLines = oldText.split('\n');
 const newLines = newText.split('\n');
 const result = [];

 // Simple LCS-based line diff
 const m = oldLines.length;
 const n = newLines.length;
 const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));

 for (let i = 1; i <= m; i++) {
 for (let j = 1; j <= n; j++) {
 if (oldLines[i - 1] === newLines[j - 1]) {
 dp[i][j] = dp[i - 1][j - 1] + 1;
 } else {
 dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
 }
 }
 }

 let i = m, j = n;
 while (i > 0 || j > 0) {
 if (i > 0 && j > 0 && oldLines[i - 1] === newLines[j - 1]) {
 result.unshift({ type: 'same', value: oldLines[i - 1] });
 i--; j--;
 } else if (j > 0 && (i === 0 || dp[i][j - 1] >= dp[i - 1][j])) {
 result.unshift({ type: 'added', value: newLines[j - 1] });
 j--;
 } else {
 result.unshift({ type: 'removed', value: oldLines[i - 1] });
 i--;
 }
 }

 return result;
}

function buildPanel(lines, includeTypes) {
 const pre = document.createElement('pre');
 pre.style.cssText = 'margin:0;padding:16px;font-size:13px;line-height:1.5;white-space:pre-wrap;word-break:break-word;';
 lines.forEach(line => {
 if (!includeTypes.includes(line.type)) return;
 const div = document.createElement('div');
 div.textContent = line.value;
 if (line.type === 'added') div.style.background = '#e6ffed';
 if (line.type === 'removed') div.style.background = '#ffeef0';
 pre.appendChild(div);
 });
 return pre;
}

function createComparisonView(source1, source2) {
 const existing = document.getElementById('side-by-side-compare');
 if (existing) existing.remove();

 const diff = computeLineDiff(source1, source2);

 const container = document.createElement('div');
 container.id = 'side-by-side-compare';
 container.style.cssText = [
 'position:fixed;top:0;left:0;right:0;bottom:0;',
 'background:#fff;z-index:2147483647;display:flex;flex-direction:column;',
 'font-family:monospace;'
 ].join('');

 // Header bar
 const header = document.createElement('div');
 header.style.cssText = 'display:flex;align-items:center;padding:8px 16px;background:#f1f3f4;border-bottom:1px solid #dadce0;gap:12px;';
 const title = document.createElement('span');
 title.textContent = 'Side-by-Side Comparison';
 title.style.fontWeight = 'bold';

 const stats = document.createElement('span');
 const added = diff.filter(l => l.type === 'added').length;
 const removed = diff.filter(l => l.type === 'removed').length;
 stats.textContent = `+${added} lines / -${removed} lines`;
 stats.style.cssText = 'font-size:12px;color:#555;flex:1;';

 const closeBtn = document.createElement('button');
 closeBtn.textContent = 'Close (Esc)';
 closeBtn.style.cssText = 'background:#ea4335;color:white;border:none;padding:6px 14px;cursor:pointer;border-radius:4px;';
 closeBtn.onclick = () => container.remove();

 header.append(title, stats, closeBtn);

 // Column labels
 const labels = document.createElement('div');
 labels.style.cssText = 'display:flex;border-bottom:1px solid #dadce0;';
 ['Source A (original)', 'Source B (modified)'].forEach(label => {
 const lbl = document.createElement('div');
 lbl.textContent = label;
 lbl.style.cssText = 'flex:1;padding:6px 16px;font-size:12px;font-weight:bold;color:#555;';
 labels.appendChild(lbl);
 });

 // Panels
 const panels = document.createElement('div');
 panels.style.cssText = 'display:flex;flex:1;overflow:hidden;';

 const leftScroll = document.createElement('div');
 leftScroll.style.cssText = 'flex:1;overflow:auto;border-right:2px solid #dadce0;';
 leftScroll.appendChild(buildPanel(diff, ['same', 'removed']));

 const rightScroll = document.createElement('div');
 rightScroll.style.cssText = 'flex:1;overflow:auto;';
 rightScroll.appendChild(buildPanel(diff, ['same', 'added']));

 // Sync scrolling between panels
 let syncing = false;
 leftScroll.addEventListener('scroll', () => {
 if (syncing) return;
 syncing = true;
 rightScroll.scrollTop = leftScroll.scrollTop;
 syncing = false;
 });
 rightScroll.addEventListener('scroll', () => {
 if (syncing) return;
 syncing = true;
 leftScroll.scrollTop = rightScroll.scrollTop;
 syncing = false;
 });

 panels.append(leftScroll, rightScroll);
 container.append(header, labels, panels);
 document.body.appendChild(container);

 // Keyboard close
 document.addEventListener('keydown', function escClose(e) {
 if (e.key === 'Escape') {
 container.remove();
 document.removeEventListener('keydown', escClose);
 }
 });
}
```

This implementation adds synchronized scrolling between the two panels, a stats bar showing how many lines changed, and keyboard support to close with Escape. The diff algorithm is a built-in LCS implementation that avoids any external dependency, making the extension self-contained and simpler to distribute.

## Integrating a Full Diff Library for Production Use

The built-in LCS diff above handles line-level changes well. For character-level highlighting within changed lines. showing exactly which words changed. integrate the `diff-match-patch` library from Google. It is small (about 35KB), has no dependencies, and works well in extensions.

Add the library file to your project, then update the content script:

```javascript
// After computing the line diff, enhance modified lines with word-level diff
function wordDiff(oldLine, newLine) {
 const dmp = new diff_match_patch();
 const diffs = dmp.diff_main(oldLine, newLine);
 dmp.diff_cleanupSemantic(diffs);
 return diffs; // Array of [operation, text] where -1=delete, 0=equal, 1=insert
}

function buildInlineSpans(diffs, side) {
 // side: 'left' shows deletions, 'right' shows insertions
 const frag = document.createDocumentFragment();
 diffs.forEach(([op, text]) => {
 const span = document.createElement('span');
 span.textContent = text;
 if (op === -1 && side === 'left') span.style.background = '#ff9999';
 if (op === 1 && side === 'right') span.style.background = '#99ff99';
 if (op === 0 || (op === -1 && side === 'right') || (op === 1 && side === 'left')) {
 // Show equal text on both sides; skip insertions on left, deletions on right
 if (op !== 0) return;
 }
 frag.appendChild(span);
 });
 return frag;
}
```

Word-level diffs are particularly useful for documentation and prose comparison, where the meaning of a sentence can change with a single word swap that a line-level diff would only show as a full line replacement.

## Using Existing Comparison Extensions

Several established extensions handle side-by-side comparison without requiring custom development:

Diff Checker offers a straightforward interface where you paste or load content from URLs. It highlights additions in green and deletions in red, with options for character-level or word-level comparison. The free tier handles most use cases.

Text Compare works well for comparing selected text from any webpage. Right-click to select "Compare Selected Text" and it opens a comparison view with your selections. It is fast for ad-hoc comparisons.

CodeMirror-based extensions provide syntax highlighting during comparison, which is essential when reviewing code changes. These preserve formatting and indentation, making them suitable for developers comparing JavaScript, JSON, or HTML.

| Extension | Best For | Diff Level | Offline |
|---|---|---|---|
| Diff Checker | General text, documents | Line + char | Partial |
| Text Compare | Quick page selections | Line | Yes |
| Mergely (web) | JSON, XML, code | Syntax-aware | No |
| Custom build | Your specific workflow | Configurable | Yes |

Building your own gives you full control over what the tool does: you can add integrations, store history, or pre-process text (stripping HTML tags, normalizing whitespace) before diffing.

## Performance Considerations

When comparing large sources, keep these issues in mind:

Web Workers for heavy diffs. The LCS algorithm is O(m*n) in the worst case. Comparing two 10,000-line files will block the main thread for hundreds of milliseconds. Move the diff computation into a Web Worker:

```javascript
// diff-worker.js
self.onmessage = function(e) {
 const { source1, source2 } = e.data;
 const diff = computeLineDiff(source1, source2); // same function as above
 self.postMessage(diff);
};

// In content.js, use the worker:
function runDiffAsync(source1, source2, callback) {
 const worker = new Worker(chrome.runtime.getURL('diff-worker.js'));
 worker.onmessage = (e) => {
 worker.terminate();
 callback(e.data);
 };
 worker.postMessage({ source1, source2 });
}
```

Virtual scrolling. For documents with thousands of lines, rendering all diff rows at once strains the browser. A virtual scroller renders only the visible rows, reducing DOM node count dramatically. Libraries like `virtual-scroller` or a simple manual implementation based on `IntersectionObserver` work well here.

Debounce on live input. If you add a live comparison mode (updating as the user types), debounce the diff computation by 300-500ms so you are not running it on every keystroke.

Lazy-load the diff library. If your extension is used for other tasks too, only load the diff library when the comparison view is actually opened. Use dynamic `import()` or inject the script tag at that point.

## Security and Privacy

When building comparison extensions that handle sensitive content, the default should be client-side-only processing:

- Do not send either source to an external server. All diffing should happen in the extension context.
- If you cache previous comparisons using `chrome.storage.local`, be explicit in your privacy policy about what is stored and for how long.
- Avoid requesting permissions beyond `activeTab` and `scripting`. Both are sufficient for the extension described here.
- Be cautious with `all_urls` in content script matches. it grants the extension access to every page the user visits. If you only need the comparison view to appear on demand, inject the content script dynamically instead of registering it globally.

For enterprise teams building internal comparison tools, consider packaging the extension as an unpacked extension loaded via Chrome's developer mode rather than publishing it to the store. This keeps sensitive internal tooling off public channels.

## Common Mistakes and How to Avoid Them

Forgetting to declare content scripts. If `content.js` is not listed in the manifest or injected dynamically, `chrome.tabs.sendMessage` will fail silently. Always check the console in the target tab for errors.

Assuming same-origin access. Content scripts run in the tab's context but cannot directly read `window` variables set by the page. Use `chrome.scripting.executeScript` with `world: 'MAIN'` if you need access to the page's JavaScript scope.

Not handling large inputs gracefully. Pasting a 50,000-word document into a textarea is slow. Add an input size warning and consider limiting the popup textarea to a reasonable character count, directing users to a full-page options UI for large comparisons.

Breaking keyboard accessibility. When your comparison view covers the whole page, the user's focus context is lost. Set `tabindex="0"` on the container and call `container.focus()` after mounting it, so keyboard users can navigate the view immediately.

## Extending the Extension Further

Once the core comparison view works, several additions make it substantially more useful:

URL comparison mode. Add a second input mode where users enter two URLs. The extension fetches both (using the background service worker to avoid CORS restrictions) and compares their text content. Useful for checking live vs. staging pages.

History panel. Store the last five comparisons in `chrome.storage.local` and show them in the popup. Developers frequently need to re-check the same pair of sources after making a change.

Export as unified diff. Add a "Copy Diff" button that formats the result as a standard unified diff patch, suitable for pasting into a bug report or code review comment.

Regex filter. Let users filter the diff view to show only lines matching a pattern. This is invaluable when comparing large configuration files where you only care about a subset of keys.

## Conclusion

Chrome extensions provide a flexible way to compare sources side by side without leaving your browser. Whether you build a custom solution or use existing tools, the key is choosing an approach that fits your specific workflow. The implementation in this guide. with synchronized scrolling, LCS-based line diffs, and a clean stats bar. is a solid foundation for daily use.

For simple text comparisons, the basic implementation works immediately. For code review or detailed analysis, integrate `diff-match-patch` for word-level highlighting and add a Web Worker to keep the UI responsive on large inputs. For teams with privacy requirements, keep everything client-side and avoid publishing to the Web Store when internal distribution is sufficient.

Start with the manifest and content script above, verify the diff output in the browser console, and extend from there based on what your actual workflow demands.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-compare-sources-side-by-side)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [EditThisCookie Alternative: Best Chrome Extensions for.](/editthiscookie-alternative-chrome-extension-2026/)
- [1Password Alternative Chrome Extension in 2026](/1password-alternative-chrome-extension-2026/)
- [1Password vs Bitwarden Chrome: Which Password Manager.](/1password-vs-bitwarden-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



