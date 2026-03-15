---

layout: default
title: "Claude Code for Core Web Vitals Workflow Tutorial"
description: "Learn how to use Claude Code to analyze, optimize, and monitor your site's Core Web Vitals. Practical workflow with code examples for LCP, INP, FID, and CLS."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-core-web-vitals-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---


# Claude Code for Core Web Vitals Workflow Tutorial

Core Web Vitals have become essential metrics for web performance, directly impacting both user experience and search engine rankings. In this tutorial, you'll learn how to use Claude Code to systematically analyze, optimize, and monitor your site's Core Web Vitals: Largest Contentful Paint (LCP), Interaction to Next Paint (INP), First Input Delay (FID), and Cumulative Layout Shift (CLS).

**Largest Contentful Paint (LCP)** measures loading performance—specifically when the largest content element in the viewport becomes visible. LCP should occur within 2.5 seconds of when the page first starts loading.

**Interaction to Next Paint (INP)** replaced First Input Delay (FID) in March 2024. INP measures responsiveness by tracking all user interactions and reporting the longest delay between the interaction and the browser's response. A good INP score is 200 milliseconds or less.

**Cumulative Layout Shift (CLS)** measures visual stability—how much content shifts unexpectedly during page load. A good CLS score is 0.1 or less.

## Setting Up Your Project for Web Vitals Analysis

Before diving into optimization workflows, ensure your project is properly configured for Claude Code to analyze. Create a dedicated skill or prompt context for web vitals work.

First, initialize your project with necessary dependencies:

```bash
npm init -y
npm install --save-dev @web-vitals/web-vitals lighthouse
```

Create a `web-vitals-config.json` file to store your baseline metrics:

```json
{
  "url": "https://your-site.com",
  "thresholds": {
    "lcp": 2500,
    "fid": 100,
    "cls": 0.1
  },
  "budget": {
    "lcp": "good",
    "fid": "good",
    "cls": "good"
  }
}
```

For lab testing during development, integrate Lighthouse CI into your build process:

```javascript
// lighthouse-config.js
module.exports = {
  ci: {
    collect: {
      staticDistDir: './dist',
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1500 }],
        'largest-contentful-paint': ['warn', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['warn', { maxNumericValue: 0.1 }],
        'interactive': ['warn', { maxNumericValue: 3000 }],
      },
    },
  },
};
```

Run this configuration with `lhci autorun` to get consistent performance metrics on every build. Claude Code can help you integrate this into your CI/CD pipeline and alert you when metrics degrade.

For field data, set up the web-vitals library to collect real-user data:

```javascript
// analytics/web-vitals.js
import { onCLS, onFID, onLCP, onINP } from 'web-vitals';

function sendToAnalytics({ name, delta, id }) {
  // Replace with your analytics endpoint
  fetch('/api/vitals', {
    method: 'POST',
    body: JSON.stringify({ name, delta, id }),
  });
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onINP(sendToAnalytics);
```

## Collecting Field Data via the PageSpeed Insights API

In addition to RUM instrumentation, you can query Google's Chrome User Experience Report (CrUX) directly through the PageSpeed Insights API. This gives you the 75th-percentile values that Google uses for ranking—how real users on the open web experience your site, not just users who have your analytics snippet installed.

Store your API key as an environment variable:

```bash
export GOOGLE_API_KEY="your-api-key-here"
```

Create a script that fetches field data for a single URL:

```bash
#!/bin/bash
# fetch-cwv-field-data.sh

URL="$1"
API_KEY="$2"

if [ -z "$URL" ] || [ -z "$API_KEY" ]; then
  echo "Usage: $0 <url> <api-key>"
  exit 1
fi

curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${URL}&key=${API_KEY}&strategy=mobile&category=PERFORMANCE" | jq '.loadingExperience.metrics'
```

To monitor a set of pages, create a `urls.txt` file and iterate over it:

```bash
#!/bin/bash
# collect-all-cwv.sh

API_KEY="$1"
OUTPUT_DIR="cwv-data"

mkdir -p "$OUTPUT_DIR"

while read -r url; do
  filename=$(echo "$url" | sed 's|https://||' | sed 's|/|_|g' | sed 's|\.|_|g')
  ./fetch-cwv-field-data.sh "$url" "$API_KEY" > "$OUTPUT_DIR/${filename}.json"
  echo "Collected: $url"
done < urls.txt
```

Once you have the raw JSON snapshots, a Python script can parse them and generate a readable report:

```python
import json
import os
from datetime import datetime

def analyze_cwv_data(data_dir):
    results = []

    for filename in os.listdir(data_dir):
        if not filename.endswith('.json'):
            continue

        with open(os.path.join(data_dir, filename)) as f:
            data = json.load(f)

        url = filename.replace('_', '/').replace('.json', '')
        url = 'https://' + url if not url.startswith('http') else url

        metrics = data.get('loadingExperience', {}).get('metrics', {})

        lcp = metrics.get('LARGEST_CONTENTFUL_PAINT_MS75', {}).get('percentile', 0)
        fid = metrics.get('FIRST_INPUT_DELAY_MS75', {}).get('percentile', 0)
        cls = metrics.get('CUMULATIVE_LAYOUT_SHIFT_SCORE75', {}).get('percentile', 0)

        results.append({
            'url': url,
            'lcp': lcp / 1000 if lcp else 0,  # Convert to seconds
            'fid': fid,
            'cls': cls / 100  # Convert to decimal
        })

    return results

def generate_report(results):
    print(f"Core Web Vitals Field Data Report - {datetime.now().date()}\n")
    print(f"{'URL':<40} {'LCP':>8} {'FID':>8} {'CLS':>8} {'Status'}")
    print("-" * 80)

    for r in results:
        lcp_status = "OK" if r['lcp'] < 2.5 else "WARN"
        fid_status = "OK" if r['fid'] < 100 else "WARN"
        cls_status = "OK" if r['cls'] < 0.1 else "WARN"

        print(f"{r['url']:<40} {r['lcp']:>7.2f}s {r['fid']:>7.0f}ms {r['cls']:>7.3f}  {lcp_status} {fid_status} {cls_status}")
```

Field data fluctuates daily based on network conditions, device types, and user geography. Run collection on a weekly or bi-weekly schedule to get meaningful trends rather than reacting to single-day noise. When field data shows a problem, use Lighthouse (lab data) to reproduce and diagnose the root cause in a controlled environment.

## Analyzing Current Performance with Claude Code

Once your project is ready, use Claude Code to run comprehensive audits. The key is to automate Lighthouse runs and parse the results programmatically.

### Creating a Performance Analysis Script

Create a `analyze-vitals.js` script that Claude Code can execute:

```javascript
const lighthouse = require('lighthouse');
const { chromium } = require('playwright');

async function analyzeWebVitals(url) {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const result = await lighthouse(url, {
    port: 9222,
    output: 'json',
    onlyCategories: ['performance'],
    throttlingMethod: 'simulate',
    throttling: {
      rttMs: 40,
      throughputKbps: 10240,
      cpuSlowdownMultiplier: 1,
    },
  });

  const metrics = result.lhr.audits;
  return {
    lcp: metrics['largest-contentful-paint'].numericValue,
    fid: metrics['max-potential-fid'].numericValue,
    cls: metrics['cumulative-layout-shift'].value,
    lcpScore: metrics['largest-contentful-paint'].score,
    fidScore: metrics['max-potential-fid'].score,
    clsScore: metrics['cumulative-layout-shift'].score,
  };
}
```

### Building Your Claude Code Analysis Skill

Create a skill that parses Lighthouse reports and surfaces targeted improvements:

```markdown
# Core Web Vitals Analyzer

## Instructions

You are a web performance expert specializing in Core Web Vitals optimization. When provided with Lighthouse results or web-vitals data, analyze the metrics and provide:

1. **Metric Analysis**: Explain what each Core Web Vitals score means for user experience
2. **Root Causes**: Identify likely causes for any failing or warning metrics
3. **Actionable Recommendations**: Provide specific, implementable fixes ranked by impact
4. **Code Examples**: Where applicable, show before/after code patterns

Focus on practical solutions that balance performance gains with development effort.
```

### Interpreting Results

After running your analysis, Claude Code can interpret the results and provide actionable recommendations:

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP | < 2.5s | 2.5s - 4.0s | > 4.0s |
| FID | < 100ms | 100ms - 300ms | > 300ms |
| CLS | < 0.1 | 0.1 - 0.25 | > 0.25 |

## Optimizing Largest Contentful Paint (LCP)

LCP measures when the largest content element becomes visible. Common causes of poor LCP include slow server response times, render-blocking resources, and unoptimized images.

### Image Optimization Workflow

Use Claude Code to automate image optimization:

```javascript
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function optimizeImages(imageDir, outputDir) {
  const images = fs.readdirSync(imageDir);

  for (const image of images) {
    const inputPath = path.join(imageDir, image);
    const outputPath = path.join(outputDir, image.replace(/\.\w+$/, '.webp'));

    await sharp(inputPath)
      .resize(1200, null, { withoutEnlargement: true })
      .webp({ quality: 80 })
      .toFile(outputPath);

    console.log(`Optimized: ${image} -> ${path.basename(outputPath)}`);
  }
}
```

### Preloading Critical Resources

Ask Claude Code to generate preloading directives for your HTML:

```html
<!-- Add to <head> for critical resources -->
<link rel="preload" as="image" href="/images/hero.webp" fetchpriority="high">
<link rel="preload" as="font" href="/fonts/main-font.woff2" crossorigin>
<link rel="preconnect" href="https://fonts.googleapis.com">
```

## Reducing First Input Delay (FID) and Improving INP

FID measures the time between a user's first interaction and the browser's ability to respond. INP goes further, tracking the longest interaction delay across the entire session. High FID/INP typically results from heavy JavaScript execution blocking the main thread.

### JavaScript Code Splitting

Work with Claude Code to implement code splitting:

```javascript
// Instead of importing everything at once
import { Button, Modal, Charts, Analytics } from './components';

// Use dynamic imports
const Modal = () => import('./components/Modal');
const Charts = () => import('./components/Charts');
```

### Deferring Non-Critical Scripts

Generate proper script deferral patterns:

```html
<!-- Critical scripts load immediately -->
<script src="/js/critical.js" defer></script>

<!-- Non-critical scripts load after page is interactive -->
<script src="/js/vendor.js" defer></script>
<script src="/js/app.js" defer></script>

<!-- Third-party scripts use loading="lazy" -->
<script src="https://analytics.example.com/tracker.js" async></script>
```

### Deferring Expensive Work with requestIdleCallback

Use this pattern to defer non-critical JavaScript and break up long tasks that block INP:

```javascript
// Defer heavy computations until idle
function deferExpensiveWork() {
  if ('requestIdleCallback' in window) {
    requestIdleCallback(() => {
      performHeavyComputation();
    });
  } else {
    setTimeout(performHeavyComputation, 1);
  }
}

// Break up long tasks
async function processLargeDataset(data) {
  const chunkSize = 100;
  for (let i = 0; i < data.length; i += chunkSize) {
    await new Promise(resolve => setTimeout(resolve, 0));
    processChunk(data.slice(i, i + chunkSize));
  }
}
```

## Fixing Cumulative Layout Shift (CLS)

CLS measures visual stability—how much content shifts unexpectedly during page load. Common causes include images without dimensions, dynamically injected content, and font loading delays.

### Setting Image Dimensions

Prompt Claude Code to scan your codebase for missing image dimensions:

```javascript
const cheerio = require('cheerio');
const fs = require('fs');

function findImagesWithoutDimensions(htmlDir) {
  const files = fs.readdirSync(htmlDir).filter(f => f.endsWith('.html'));
  const issues = [];

  for (const file of files) {
    const html = fs.readFileSync(path.join(htmlDir, file), 'utf8');
    const $ = cheerio.load(html);

    $('img').each((i, img) => {
      const $img = $(img);
      if (!$img.attr('width') || !$img.attr('height')) {
        issues.push({
          file,
          src: $img.attr('src'),
          alt: $img.attr('alt')
        });
      }
    });
  }

  return issues;
}
```

Always include explicit dimensions and reserve space for dynamic content:

```html
<!-- Always specify dimensions -->
<img src="image.jpg" width="800" height="600" alt="Description">
```

```css
/* Reserve space for dynamic content */
.ad-container {
  min-height: 250px;
  contain: content;
}

/* Skeleton loading placeholders */
.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s infinite;
}
```

### Font Loading Optimization

Implement font display swap to prevent FOIT/FOUT:

```css
@font-face {
  font-family: 'MainFont';
  src: url('/fonts/main-font.woff2') format('woff2');
  font-display: swap;
  font-weight: 400;
  font-style: normal;
}
```

## Building a Continuous Monitoring Workflow

Set up automated monitoring with Claude Code to track Web Vitals over time:

```javascript
const { performance } = require('perf_hooks');

function measureWebVitals() {
  return new Promise((resolve) => {
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        const metric = entry.name;
        const value = entry.value;

        // Send to analytics
        console.log(`${metric}: ${value}`);
      }
    }).observe({ entryTypes: ['largest-contentful-paint', 'first-input', 'layout-shift'] });
  });
}
```

To catch regressions across deployments, create a tracking script that compares metrics over time:

```javascript
// scripts/track-metrics.js
const { readFileSync } = require('fs');

async function getLighthouseScore() {
  // Fetch from your CI/CD integration
  const report = JSON.parse(readFileSync('./lighthouse-report.json', 'utf8'));
  return {
    lcp: report.audits['largest-contentful-paint'].numericValue,
    inp: report.audits['max-potential-fid'].numericValue,
    cls: report.audits['cumulative-layout-shift'].numericValue,
  };
}

const scores = getLighthouseScore();
console.log(`LCP: ${scores.lcp}ms, INP: ${scores.inp}ms, CLS: ${scores.cls}`);
```

Run this script after every deployment to catch regressions immediately.

## Actionable Next Steps

1. **Run your first audit**: Use Lighthouse via Claude Code to establish a baseline
2. **Prioritize LCP first**: It typically has the biggest impact on user experience
3. **Implement image optimization**: Use WebP format with proper dimensions
4. **Review JavaScript bundles**: Remove unused code and implement lazy loading
5. **Set up continuous monitoring**: Track metrics in production to catch regressions

By integrating Claude Code into your development workflow, you can systematically improve your Core Web Vitals scores and deliver better experiences to your users. The key is to automate the measurement process and make performance optimization an integral part of your development cycle rather than an afterthought.

Remember that Core Web Vitals are user-centric metrics—improving them directly translates to better user satisfaction and improved search visibility. Let Claude Code help you achieve and maintain excellent performance scores consistently.

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
