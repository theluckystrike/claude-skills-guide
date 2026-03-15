---
layout: default
title: "Chrome Extension SEO Checker: Developer Guide"
description: "Build a Chrome extension SEO checker from scratch. Practical code examples, manifest configuration, and implementation patterns for developers and power users."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-seo-checker/
---

{% raw %}
# Chrome Extension SEO Checker: Developer Guide

A Chrome extension SEO checker brings analysis capabilities directly into your browser. Instead of copying URLs into standalone tools, you can validate meta tags, check heading structure, analyze internal linking, and audit technical SEO factors while browsing. This guide shows you how to build a functional SEO checker extension from scratch.

## Core Components

An SEO checker extension has three main parts:

1. **Content script** — Extracts page HTML and structural elements
2. **Analysis engine** — Processes data and calculates SEO metrics  
3. **Popup interface** — Displays results with actionable feedback

## Manifest Configuration

Every Chrome extension requires a manifest file. For an SEO checker, you need Manifest V3 with specific permissions:

```json
{
  "manifest_version": 3,
  "name": "Page SEO Analyzer",
  "version": "1.0.0",
  "description": "Analyze on-page SEO factors directly in your browser",
  "permissions": ["activeTab", "scripting", "storage"],
  "host_permissions": ["<all_urls>"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icon16.png",
      "48": "icon48.png",
      "128": "icon128.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  }
}
```

The `host_permissions` with `<all_urls>` allows your extension to analyze any webpage.

## Content Script for Data Extraction

The content script runs on the current page and extracts SEO elements:

```javascript
// content.js
class SEOAnalyzer {
  extract() {
    const data = {
      title: {
        tag: document.querySelector('title')?.textContent || '',
        length: document.querySelector('title')?.textContent.length || 0
      },
      description: {
        content: document.querySelector('meta[name="description"]')?.content || '',
        length: document.querySelector('meta[name="description"]')?.content?.length || 0
      },
      robots: document.querySelector('meta[name="robots"]')?.content || 'index,follow',
      canonical: document.querySelector('link[rel="canonical"]')?.href || '',
      headings: {
        h1: Array.from(document.querySelectorAll('h1')).map(el => el.textContent.trim()),
        h2: Array.from(document.querySelectorAll('h2')).map(el => el.textContent.trim()),
        h3: Array.from(document.querySelectorAll('h3')).map(el => el.textContent.trim())
      },
      links: {
        internal: this.getInternalLinks(),
        external: this.getExternalLinks(),
        total: document.querySelectorAll('a[href]').length
      },
      images: {
        total: document.querySelectorAll('img').length,
        withAlt: document.querySelectorAll('img[alt]').length,
        withoutAlt: document.querySelectorAll('img:not([alt])').length
      },
      og: {
        title: document.querySelector('meta[property="og:title"]')?.content || '',
        description: document.querySelector('meta[property="og:description"]')?.content || '',
        image: document.querySelector('meta[property="og:image"]')?.content || '',
        url: document.querySelector('meta[property="og:url"]')?.content || ''
      },
      structure: {
        wordCount: this.getWordCount(),
        hasSchema: document.querySelector('[type="application/ld+json"]') !== null
      }
    };
    return data;
  }

  getInternalLinks() {
    const domain = window.location.hostname;
    return Array.from(document.querySelectorAll('a[href]'))
      .filter(a => a.hostname === domain).map(a => a.href);
  }

  getExternalLinks() {
    const domain = window.location.hostname;
    return Array.from(document.querySelectorAll('a[href]'))
      .filter(a => a.hostname !== domain && a.hostname !== '').map(a => a.href);
  }

  getWordCount() {
    const body = document.body || document.documentElement;
    const text = body.innerText || body.textContent;
    return text.split(/\s+/).filter(word => word.length > 0).length;
  }
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'analyzePage') {
    const analyzer = new SEOAnalyzer();
    sendResponse(analyzer.extract());
  }
});
```

## Analysis Logic

The analysis logic evaluates extracted data and provides scores:

```javascript
// analyzer.js
class SEOAnalyzer {
  analyze(data) {
    const issues = [];
    const passed = [];
    let score = 100;

    // Title checks
    if (!data.title.tag) {
      issues.push({ type: 'error', message: 'Missing title tag' });
      score -= 15;
    } else if (data.title.length < 30) {
      issues.push({ type: 'warning', message: `Title too short (${data.title.length} chars). Aim for 30-60.` });
      score -= 5;
    } else if (data.title.length > 60) {
      issues.push({ type: 'warning', message: `Title too long (${data.title.length} chars). Keep under 60.` });
      score -= 5;
    } else {
      passed.push({ message: 'Title tag is optimal' });
    }

    // Description checks
    if (!data.description.content) {
      issues.push({ type: 'error', message: 'Missing meta description' });
      score -= 10;
    } else if (data.description.length < 120) {
      issues.push({ type: 'warning', message: `Meta description too short (${data.description.length} chars). Aim for 150-160.` });
      score -= 3;
    } else if (data.description.length > 160) {
      issues.push({ type: 'warning', message: `Meta description too long (${data.description.length} chars). Keep under 160.` });
      score -= 3;
    } else {
      passed.push({ message: 'Meta description is optimal' });
    }

    // H1 checks
    if (data.headings.h1.length === 0) {
      issues.push({ type: 'error', message: 'Missing H1 heading' });
      score -= 10;
    } else if (data.headings.h1.length > 1) {
      issues.push({ type: 'warning', message: `Multiple H1 headings found (${data.headings.h1.length}). Use only one.` });
      score -= 5;
    } else {
      passed.push({ message: 'H1 heading is correct' });
    }

    // Image alt checks
    if (data.images.withoutAlt > 0) {
      issues.push({ type: 'warning', message: `${data.images.withoutAlt} images missing alt text` });
      score -= (data.images.withoutAlt * 2);
    }

    // Internal linking
    if (data.links.internal.length < 3 && data.structure.wordCount > 500) {
      issues.push({ type: 'warning', message: 'Limited internal links for page content length' });
      score -= 5;
    }

    // Schema markup
    if (data.structure.hasSchema) {
      passed.push({ message: 'Schema markup detected' });
    } else {
      issues.push({ type: 'info', message: 'Consider adding structured data (JSON-LD)' });
    }

    return {
      score: Math.max(0, score),
      issues,
      passed,
      metrics: {
        titleLength: data.title.length,
        descriptionLength: data.description.length,
        wordCount: data.structure.wordCount,
        internalLinks: data.links.internal.length,
        imagesWithAlt: data.images.withAlt,
        imagesTotal: data.images.total,
        hasSchema: data.structure.hasSchema
      }
    };
  }
}
```

## Popup Interface

The popup displays analysis results:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 360px; padding: 16px; font-family: -apple-system, sans-serif; font-size: 14px; }
    .score-header { text-align: center; padding: 20px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border-radius: 8px; margin-bottom: 16px; }
    .score-value { font-size: 48px; font-weight: 700; }
    .score-label { font-size: 14px; opacity: 0.9; }
    .section { margin-bottom: 16px; }
    .section-title { font-size: 12px; text-transform: uppercase; color: #666; margin-bottom: 8px; font-weight: 600; }
    .issue { padding: 8px 12px; border-radius: 4px; margin-bottom: 6px; font-size: 13px; }
    .issue.error { background: #ffebee; color: #c62828; border-left: 3px solid #c62828; }
    .issue.warning { background: #fff3e0; color: #e65100; border-left: 3px solid #e65100; }
    .issue.info { background: #e3f2fd; color: #1565c0; border-left: 3px solid #1565c0; }
    .issue.passed { background: #e8f5e9; color: #2e7d32; border-left: 3px solid #2e7d32; }
    .metrics-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .metric { background: #f5f5f5; padding: 10px; border-radius: 4px; text-align: center; }
    .metric-value { font-size: 18px; font-weight: 600; color: #333; }
    .metric-label { font-size: 11px; color: #666; }
    button { width: 100%; padding: 12px; background: #667eea; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; }
    button:hover { background: #5a6fd6; }
    button:disabled { background: #ccc; }
  </style>
</head>
<body>
  <div class="score-header">
    <div class="score-value" id="score">--</div>
    <div class="score-label">SEO Score</div>
  </div>
  <button id="analyzeBtn">Analyze This Page</button>
  <div id="results" style="display: none;">
    <div class="section"><div class="section-title">Issues</div><div id="issuesList"></div></div>
    <div class="section"><div class="section-title">Passed Checks</div><div id="passedList"></div></div>
    <div class="section"><div class="section-title">Metrics</div><div class="metrics-grid" id="metricsGrid"></div></div>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

## Popup Logic

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const analyzeBtn = document.getElementById('analyzeBtn');
  const resultsDiv = document.getElementById('results');
  
  analyzeBtn.addEventListener('click', async () => {
    analyzeBtn.disabled = true;
    analyzeBtn.textContent = 'Analyzing...';
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    try {
      const data = await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        func: () => new Promise((resolve) => 
          chrome.runtime.sendMessage({ action: 'analyzePage' }, resolve)
        )
      });
      
      const analyzer = new SEOAnalyzer();
      const results = analyzer.analyze(data[0].result);
      displayResults(results);
      resultsDiv.style.display = 'block';
    } catch (error) {
      analyzeBtn.textContent = 'Error analyzing page';
    }
    analyzeBtn.disabled = false;
    analyzeBtn.textContent = 'Analyze This Page';
  });
  
  function displayResults(results) {
    const scoreEl = document.getElementById('score');
    scoreEl.textContent = results.score;
    scoreEl.style.color = results.score >= 80 ? '#4caf50' : 
                           results.score >= 50 ? '#ff9800' : '#f44336';
    
    document.getElementById('issuesList').innerHTML = results.issues.length > 0 
      ? results.issues.map(i => `<div class="issue ${i.type}">${i.message}</div>`).join('')
      : '<div class="issue passed">No issues found</div>';
    
    document.getElementById('passedList').innerHTML = results.passed.map(p => 
      `<div class="issue passed">${p.message}</div>`).join('');
    
    const m = results.metrics;
    document.getElementById('metricsGrid').innerHTML = `
      <div class="metric"><div class="metric-value">${m.titleLength}</div><div class="metric-label">Title Length</div></div>
      <div class="metric"><div class="metric-value">${m.descriptionLength}</div><div class="metric-label">Description Length</div></div>
      <div class="metric"><div class="metric-value">${m.wordCount}</div><div class="metric-label">Word Count</div></div>
      <div class="metric"><div class="metric-value">${m.internalLinks}</div><div class="metric-label">Internal Links</div></div>
      <div class="metric"><div class="metric-value">${m.imagesWithAlt}/${m.imagesTotal}</div><div class="metric-label">Images with Alt</div></div>
      <div class="metric"><div class="metric-value">${m.hasSchema ? '✓' : '✗'}</div><div class="metric-label">Schema Markup</div></div>
    `;
  }
});
```

## Advanced Features

Consider extending with these power user features:

- **Keyword density analysis** — Calculate target keyword frequency
- **Readability scores** — Implement Flesch-Kincaid formulas
- **Core Web Vitals** — Use Performance API for LCP, FID, CLS
- **Export functionality** — Generate JSON reports for documentation

## Testing Your Extension

Load your extension at `chrome://extensions/`, enable Developer mode, and click "Load unpacked". Test across different page types:

- Homepage with extensive SEO optimization
- Blog posts with long-form content  
- Product pages with structured data
- Landing pages with minimal content

## Conclusion

Building a Chrome extension SEO checker combines DOM manipulation with SEO best practices. The core implementation extracts page elements, evaluates them against standard criteria, and presents actionable results. The architecture scales well—add new checks by extending the analyzer class without modifying extraction logic.

Start with this foundation, then customize scoring weights based on your specific requirements.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
