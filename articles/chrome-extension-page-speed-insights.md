---
layout: default
title: "Page Speed Insights Chrome Extension"
description: "Claude Code extension tip: learn how to build Chrome extensions that analyze page speed performance using Lighthouse and the Page Speed Insights API...."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-page-speed-insights/
categories: [guides]
reviewed: true
score: 0
tags: [chrome-extension, page-speed, lighthouse, web-performance]
geo_optimized: true
---
# Chrome Extension Page Speed Insights: A Developer Guide

Performance optimization remains one of the most critical aspects of modern web development. Users abandon sites that load slowly, and search engines penalize sluggish pages in rankings. For developers building Chrome extensions focused on performance analysis, integrating Page Speed Insights provides a powerful way to deliver actionable metrics directly in the browser.

This guide walks you through building a Chrome extension that uses Google's Page Speed Insights API and Lighthouse to analyze web pages in real-time. You'll learn the technical foundation, practical implementation patterns, and how to present meaningful data to users.

## Understanding the Page Speed Insights API

The Page Speed Insights API combines Lighthouse performance audits with real-user data to provide comprehensive performance metrics. The API returns scores from 0 to 100 across multiple categories, including Largest Contentful Paint (LCP), First Input Delay (FID), Cumulative Layout Shift (CLS), and Total Blocking Time (TBT).

For Chrome extensions, you have two primary approaches:

1. Direct API calls to the Page Speed Insights REST API
2. Lighthouse integration running directly in the extension context

Each approach has trade-offs. The REST API is simpler but requires network requests and has rate limits. Running Lighthouse locally provides more control but increases extension complexity.

## Setting Up Your Extension Structure

A basic Chrome extension for page speed analysis needs a manifest file, background service worker, and content scripts or popup interface. Here's the essential structure:

```
page-speed-extension/
 manifest.json
 background.js
 popup.html
 popup.js
 icons/
 icon16.png
 icon48.png
 icon128.png
```

The manifest defines permissions and declares the extension's capabilities:

```json
{
 "manifest_version": 3,
 "name": "Page Speed Analyzer",
 "version": "1.0",
 "permissions": ["activeTab", "storage"],
 "host_permissions": ["https://www.googleapis.com/*"],
 "action": {
 "default_popup": "popup.html"
 }
}
```

## Implementing the Analysis Logic

The core functionality lives in your popup or background script. Here's a practical implementation that calls the Page Speed Insights API:

```javascript
async function analyzePageSpeed(url) {
 const apiKey = 'YOUR_API_KEY'; // Get from Google Cloud Console
 const apiUrl = `https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${encodeURIComponent(url)}&key=${apiKey}`;
 
 const response = await fetch(apiUrl);
 const data = await response.json();
 
 return {
 performanceScore: data.lighthouseResult.categories.performance.score * 100,
 lcp: data.lighthouseResult.audits['largest-contentful-paint'].numericValue,
 cls: data.lighthouseResult.audits['cumulative-layout-shift'].numericValue,
 tbt: data.lighthouseResult.audits['total-blocking-time'].numericValue,
 fcp: data.lighthouseResult.audits['first-contentful-paint'].numericValue
 };
}
```

This function returns the core Web Vitals that matter most for user experience. The performance score provides a quick overall assessment, while individual metrics help identify specific optimization opportunities.

## Building the User Interface

Your popup should present results in a clear, actionable format. Here's a practical popup implementation:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 350px; padding: 16px; font-family: system-ui, sans-serif; }
 .score { font-size: 48px; font-weight: bold; text-align: center; }
 .metric { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
 .metric-value { font-weight: 600; }
 .good { color: #0cce6b; }
 .needs-improvement { color: #ffa400; }
 .poor { color: #ff4e42; }
 </style>
</head>
<body>
 <h2>Page Speed Analysis</h2>
 <div id="score" class="score">--</div>
 <div id="metrics"></div>
 <button id="analyze">Analyze Current Page</button>
 <script src="popup.js"></script>
</body>
</html>
```

The corresponding JavaScript connects the UI to your analysis logic:

```javascript
document.getElementById('analyze').addEventListener('click', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const results = await analyzePageSpeed(tab.url);
 
 displayResults(results);
});

function displayResults(results) {
 const scoreEl = document.getElementById('score');
 scoreEl.textContent = Math.round(results.performanceScore);
 scoreEl.className = 'score ' + getScoreClass(results.performanceScore);
 
 const metricsHtml = `
 <div class="metric">
 <span>Largest Contentful Paint</span>
 <span class="metric-value">${(results.lcp / 1000).toFixed(2)}s</span>
 </div>
 <div class="metric">
 <span>Cumulative Layout Shift</span>
 <span class="metric-value">${results.cls.toFixed(3)}</span>
 </div>
 <div class="metric">
 <span>Total Blocking Time</span>
 <span class="metric-value">${results.tbt}ms</span>
 </div>
 `;
 document.getElementById('metrics').innerHTML = metricsHtml;
}

function getScoreClass(score) {
 if (score >= 90) return 'good';
 if (score >= 50) return 'needs-improvement';
 return 'poor';
}
```

## Using Lighthouse Programmatically

For more advanced use cases, running Lighthouse directly in your extension provides deeper insights without API rate limits. This approach uses the Lighthouse Puppeteer or standalone package:

```javascript
import lighthouse from 'lighthouse';

async function runLighthouseLocal(url) {
 const options = {
 logLevel: 'info',
 output: 'json',
 onlyCategories: ['performance'],
 throttlingMethod: 'simulate',
 };
 
 const result = await lighthouse(url, options);
 return result.lhr;
}
```

This method requires bundling Lighthouse with your extension or loading it from a background script. The advantage is unlimited analysis without API costs and access to all Lighthouse audits.

## Presenting Actionable Recommendations

Raw metrics help developers understand current performance, but actionable recommendations solve problems. Extend your extension to show specific improvement suggestions:

```javascript
function extractRecommendations(lighthouseResult) {
 const audits = lighthouseResult.audits;
 const recommendations = [];
 
 if (audits['render-blocking-resources'].details.items.length > 0) {
 recommendations.push({
 title: 'Eliminate render-blocking resources',
 impact: 'High',
 items: audits['render-blocking-resources'].details.items
 });
 }
 
 if (audits['uses-optimized-images'].details.items.length > 0) {
 recommendations.push({
 title: 'Optimize images',
 impact: 'Medium',
 items: audits['uses-optimized-images'].details.items
 });
 }
 
 return recommendations;
}
```

## Handling Common Challenges

When building page speed analysis extensions, you'll encounter several practical challenges:

CORS restrictions prevent direct API calls from content scripts. Always make API requests from your background script or popup context.

Authentication requires users to obtain an API key from Google Cloud Console. Consider implementing OAuth for production extensions to avoid exposing keys.

Rate limiting affects both API and local Lighthouse runs. Cache results and implement debouncing to prevent excessive analysis requests.

Tab state matters when analyzing. Ensure the target page has fully loaded before running analysis by checking `tab.status === 'complete'`.

## Practical Applications

Chrome extensions analyzing page speed serve various use cases. Development teams use them for quick performance checks during development. QA engineers incorporate them into testing workflows. Site owners monitor competitor performance. SEO specialists track optimization progress over time.

The key to building a useful tool is presenting data in context. Don't just show scores, explain what they mean and provide concrete next steps for improvement.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-page-speed-insights)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Lighthouse Audit Runner: A Developer Guide](/chrome-extension-lighthouse-audit-runner/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


