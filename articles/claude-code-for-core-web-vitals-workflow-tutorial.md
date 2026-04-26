---
layout: default
title: "Claude Code for Core Web Vitals (2026)"
description: "Improve Core Web Vitals scores with Claude Code. Covers LCP optimization, CLS fixes, INP improvements, and automated Lighthouse auditing workflows."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-core-web-vitals-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
score: 7
reviewed: true
render_with_liquid: false
geo_optimized: true
last_tested: "2026-04-21"
---

{% raw %}
Claude Code for Core Web Vitals Workflow Tutorial

Core Web Vitals have become essential metrics for web performance, directly impacting user experience and search engine rankings. Google's Core Web Vitals, Largest Contentful Paint (LCP), First Input Delay (FID), and Cumulative Layout Shift (CLS), measure loading performance, interactivity, and visual stability. This tutorial shows you how to use Claude Code to create efficient workflows for measuring, monitoring, and optimizing these critical metrics.

## Understanding Core Web Vitals Metrics

Before diving into workflows, let's review what each metric measures, what counts as a passing score, and why it matters for your users:

| Metric | Measures | Good | Needs Improvement | Poor |
|--------|----------|------|-------------------|------|
| LCP | Loading performance | ≤ 2.5s | 2.5s – 4.0s | > 4.0s |
| FID | Interactivity | ≤ 100ms | 100ms – 300ms | > 300ms |
| CLS | Visual stability | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |
| INP* | Interaction responsiveness | ≤ 200ms | 200ms – 500ms | > 500ms |

*Interaction to Next Paint (INP) replaced FID as an official Core Web Vital in March 2024. Lighthouse still reports FID, but Google Search Console and CrUX now use INP.

- Largest Contentful Paint (LCP): Marks when the largest visible content element, a hero image, a heading, or a block of text, finishes loading. Slow server response times, render-blocking resources, and un-optimized images are the most common culprits.
- First Input Delay (FID): Measures the delay between a user's first interaction (click, tap, key press) and the browser's response. Long JavaScript tasks on the main thread push this number up.
- Cumulative Layout Shift (CLS): Tracks unexpected layout movement during the page's lifetime. Images without explicit dimensions, late-loading ads, and dynamically injected content all contribute.
- Interaction to Next Paint (INP): The successor to FID, INP measures the full duration of every interaction, not just the first one, and reports the worst-case latency.

Claude Code can help you audit all four metrics, identify root causes, and implement fixes systematically. practical workflows.

## Setting Up Your Web Vitals Testing Environment

First, create a Claude Code skill that helps you run Web Vitals audits consistently. This skill encapsulates the tools and prompts needed across sessions:

```yaml
---
name: web-vitals
description: "Audit and analyze Core Web Vitals for web applications"
tools: [Bash, WebFetch, Read, Write]
---

Run a Lighthouse audit on the provided URL, save the JSON report,
then extract LCP, FID/INP, and CLS scores.
Report the values with pass/fail status and list the top 3 opportunities.
```

The skill can use multiple tools to fetch pages, run Lighthouse audits, and analyze results. Before running audits, ensure you have the necessary tools installed:

```bash
npm install -g lighthouse
npm install -g @lhci/cli # Lighthouse CI for automated pipelines
```

Verify the installation and capture a baseline report:

```bash
lighthouse --version
lighthouse https://example.com \
 --only-categories=performance \
 --output=json \
 --output-path=baseline.json \
 --chrome-flags="--headless"
```

## Workflow 1: Running Quick Web Vitals Audits

The most common workflow is running a quick audit on a URL to get baseline metrics. Create a simple bash function to run Lighthouse and extract the scores you actually care about:

```bash
#!/usr/bin/env bash
audit.sh. run Lighthouse and print Core Web Vitals summary
set -euo pipefail

URL="${1:?Usage: audit.sh <url>}"
REPORT_FILE="lighthouse-$(date +%Y%m%d-%H%M%S).json"

lighthouse "$URL" \
 --only-categories=performance \
 --output=json \
 --output-path="$REPORT_FILE" \
 --chrome-flags="--headless --no-sandbox" \
 --quiet

echo "=== Core Web Vitals: $URL ==="
node - <<'EOF' "$REPORT_FILE"
const report = require(process.argv[2]);
const audits = report.audits;
const metrics = {
 'LCP': audits['largest-contentful-paint'],
 'FID': audits['max-potential-fid'],
 'INP': audits['interaction-to-next-paint'],
 'CLS': audits['cumulative-layout-shift'],
 'TTFB': audits['server-response-time'],
 'TBT': audits['total-blocking-time'],
};
for (const [name, audit] of Object.entries(metrics)) {
 if (!audit) continue;
 const score = audit.score !== null ? (audit.score * 100).toFixed(0) : 'N/A';
 const value = audit.displayValue ?? audit.numericValue;
 const status = audit.score >= 0.9 ? ' PASS' : audit.score >= 0.5 ? '~ NEEDS WORK' : ' FAIL';
 console.log(` ${name.padEnd(5)} ${String(value).padEnd(12)} score=${score} ${status}`);
}
EOF
```

After running the audit, you can point Claude Code at the JSON output and ask for deeper analysis:

```
Read lighthouse-20260315-143022.json and explain:
1. Why the LCP score is failing
2. Which JavaScript files are contributing to TBT
3. Suggest the three highest-impact fixes in priority order
```

Claude Code will parse the JSON, identify the `lcp-lazy-loaded`, `render-blocking-resources`, and `unused-javascript` audits, and give you specific file names and sizes rather than generic advice.

## Workflow 2: Batch Testing Multiple Pages

For larger sites, you need to test multiple pages systematically. Create a workflow that reads a list of URLs and runs audits on each, then aggregates the results into a single report:

```bash
#!/usr/bin/env bash
batch-audit.sh
set -euo pipefail

URLS_FILE="${1:-urls.txt}"
REPORT_DIR="reports/$(date +%Y%m%d)"
mkdir -p "$REPORT_DIR"

declare -A PASS_COUNT
declare -A FAIL_COUNT

while IFS= read -r url; do
 [[ -z "$url" || "$url" == "#"* ]] && continue

 slug=$(echo "$url" | sed 's|https\?://||;s|/|-|g;s|-$||')
 output_file="$REPORT_DIR/${slug}.json"

 echo "Auditing: $url"
 lighthouse "$url" \
 --only-categories=performance \
 --output=json \
 --output-path="$output_file" \
 --chrome-flags="--headless --no-sandbox" \
 --quiet 2>/dev/null || { echo " SKIPPED (audit failed)"; continue; }

 # Extract pass/fail per metric
 node -e "
 const r = require('$output_file');
 const a = r.audits;
 const lcp = a['largest-contentful-paint']?.score ?? 0;
 const cls = a['cumulative-layout-shift']?.score ?? 0;
 const tbt = a['total-blocking-time']?.score ?? 0;
 const pass = lcp >= 0.9 && cls >= 0.9 && tbt >= 0.9;
 console.log(pass ? 'PASS' : 'FAIL', '$url');
 "
done < "$URLS_FILE"

echo "Reports saved to $REPORT_DIR/"
```

After the batch run, load all the JSON files into Claude Code with a single prompt:

```
Read all JSON files in reports/20260315/ and build a markdown table with columns:
URL | LCP | CLS | INP | TBT | Overall Score | Status

Highlight any page where LCP > 2.5s or CLS > 0.1.
```

This batch approach lets you track performance across your entire site without manually opening each report. Store the reports directory in Git to compare runs over time.

## Workflow 3: Automated Regression Detection

Set up a GitHub Actions workflow that runs Web Vitals audits on every pull request and blocks merges that regress your scores:

```yaml
name: Core Web Vitals
on: [pull_request]
jobs:
 lighthouse:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Setup Node
 uses: actions/setup-node@v4
 with:
 node-version: 20

 - name: Install Lighthouse CI
 run: npm install -g @lhci/cli

 - name: Run Lighthouse CI
 run: lhci autorun
 env:
 LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

The Lighthouse CI configuration lives in `lighthouserc.js` at the project root:

```js
// lighthouserc.js
module.exports = {
 ci: {
 collect: {
 url: [
 'https://staging.example.com/',
 'https://staging.example.com/blog/',
 'https://staging.example.com/product/demo/',
 ],
 numberOfRuns: 3,
 settings: {
 chromeFlags: '--headless --no-sandbox',
 },
 },
 assert: {
 assertions: {
 'categories:performance': ['error', { minScore: 0.85 }],
 'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
 'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
 'total-blocking-time': ['warn', { maxNumericValue: 300 }],
 'interaction-to-next-paint': ['error', { maxNumericValue: 200 }],
 },
 },
 upload: {
 target: 'temporary-public-storage',
 },
 },
};
```

The `assert` block compares every audit run against hard thresholds. An `error` level assertion fails the CI job and blocks the PR merge; a `warn` level logs a warning but still allows the merge. Claude Code can help you tune these thresholds based on your historical data:

```
Review the last 10 Lighthouse CI runs saved in lhci-history.json.
Suggest thresholds for each Core Web Vital assertion that:
- Fail the build on genuine regressions
- Allow normal variance (±5%) without false positives
- Match our P75 field data from CrUX
```

## Workflow 4: Real User Monitoring Integration

Lab tests measure a controlled environment. Real users have different devices, networks, and browser extensions. Combine Claude Code with real user monitoring (RUM) data for a complete picture.

## Collecting Field Data with the web-vitals Library

Add the `web-vitals` npm package to your frontend to collect INP, LCP, and CLS from actual users:

```js
// vitals.js. add to your main bundle entry point
import { onCLS, onINP, onLCP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics({ name, value, rating, id }) {
 fetch('/api/vitals', {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({
 metric: name,
 value: Math.round(name === 'CLS' ? value * 1000 : value),
 rating, // 'good' | 'needs-improvement' | 'poor'
 id,
 url: location.href,
 userAgent: navigator.userAgent,
 timestamp: Date.now(),
 }),
 keepalive: true,
 });
}

onCLS(sendToAnalytics);
onINP(sendToAnalytics);
onLCP(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

## Querying the Chrome UX Report API

For public-facing sites Google collects field data automatically. Export it via the CrUX API:

```bash
Fetch CrUX data. requires a free API key from Google Cloud Console
curl "https://chromeuxreport.googleapis.com/v1/records:queryRecord?key=$CRUX_API_KEY" \
 -H "Content-Type: application/json" \
 -d '{
 "url": "https://example.com/",
 "formFactor": "PHONE",
 "metrics": [
 "largest_contentful_paint",
 "interaction_to_next_paint",
 "cumulative_layout_shift",
 "first_contentful_paint"
 ]
 }' | jq '.record.metrics'
```

Feed the CrUX JSON to Claude Code and ask it to compare field data against your Lighthouse lab results:

```
Compare crux-march.json (field data) with lighthouse-march.json (lab data).
For each metric, note whether field P75 is better or worse than lab results.
Explain likely reasons for any gaps larger than 30%.
```

## Lab vs. Field Data Comparison

Understanding the gap between lab and field performance is important for prioritizing fixes:

| Scenario | Lab (Lighthouse) | Field (CrUX P75) | Likely Gap Cause |
|----------|-----------------|-----------------|-----------------|
| Hero image LCP | 1.8s | 3.4s | Mobile network latency not simulated |
| CLS after load | 0.05 | 0.18 | Third-party widgets injecting content after TTI |
| INP on product page | N/A | 280ms | Event handler doing sync DOM work not caught in lab |
| TBT / FID | 180ms | 45ms | Lab uses simulated slow CPU; real users have faster devices |

Claude Code can help you interpret these discrepancies and decide which metric to prioritize based on your actual user demographics.

## Common Optimization Patterns

Claude Code can help you implement proven optimization techniques. Here are patterns for each metric, with concrete before/after examples.

## Optimizing LCP

LCP measures when the largest content element becomes visible. The most impactful optimizations:

1. Preload the LCP element

Before:
```html
<img src="/hero.jpg" alt="Hero image">
```

After:
```html
<link rel="preload" as="image" href="/hero.avif"
 imagesrcset="/hero-480.avif 480w, /hero-960.avif 960w, /hero-1440.avif 1440w"
 imagesizes="100vw">
<img src="/hero.avif"
 srcset="/hero-480.avif 480w, /hero-960.avif 960w, /hero-1440.avif 1440w"
 sizes="100vw"
 alt="Hero image"
 fetchpriority="high">
```

The `fetchpriority="high"` attribute (supported in all modern browsers) tells the browser this image is critical and should jump the preload queue. The `<link rel="preload">` ensures the browser discovers it before parsing the `<body>`.

2. Eliminate render-blocking stylesheets

Before:
```html
<head>
 <link rel="stylesheet" href="/styles/full-bundle.css">
</head>
```

After (inline critical CSS + async load the rest):
```html
<head>
 <style>
 /* Critical above-fold CSS only. generated by critical-css tool */
 body { margin: 0; font-family: system-ui; }
 .hero { min-height: 60vh; background: #f5f5f5; }
 </style>
 <link rel="preload" as="style" href="/styles/full-bundle.css"
 onload="this.rel='stylesheet'">
 <noscript><link rel="stylesheet" href="/styles/full-bundle.css"></noscript>
</head>
```

Ask Claude Code to generate the critical CSS extraction command for your specific stack:
```
Using the critical npm package, extract above-fold CSS for these 5 URLs
and output inline <style> blocks ready to paste into our base layout template.
```

3. Optimize server response time

If your TTFB (Time to First Byte) exceeds 600ms, LCP will almost certainly fail regardless of other optimizations. Claude Code can audit your server response and suggest caching strategies:

```bash
Measure TTFB from multiple locations using curl
for region in us-east eu-west ap-south; do
 echo "=== $region ==="
 curl -o /dev/null -s -w "TTFB: %{time_starttransfer}s\n" \
 --connect-timeout 10 \
 -H "X-Test-Region: $region" \
 https://example.com/
done
```

## Optimizing FID and INP

FID and INP both stem from the same root cause: long JavaScript tasks blocking the main thread. The key strategies:

1. Break up long tasks with scheduler.yield()

Before (single long synchronous operation):
```js
function processLargeDataset(items) {
 return items.map(item => expensiveTransform(item));
}
```

After (chunked with yielding):
```js
async function processLargeDataset(items) {
 const results = [];
 const CHUNK_SIZE = 50;

 for (let i = 0; i < items.length; i += CHUNK_SIZE) {
 const chunk = items.slice(i, i + CHUNK_SIZE);
 results.push(...chunk.map(item => expensiveTransform(item)));

 // Yield to the browser after each chunk
 if (i + CHUNK_SIZE < items.length) {
 await scheduler.yield(); // Chromium 115+
 // Fallback: await new Promise(r => setTimeout(r, 0));
 }
 }
 return results;
}
```

2. Defer third-party scripts

Third-party scripts are frequently the largest contributor to Total Blocking Time. Use a facade pattern to load them only when needed:

```html
<!-- Replace the eager embed with a lightweight facade -->
<div class="chat-facade" id="chat-placeholder">
 <button onclick="loadChatWidget()">Chat with us</button>
</div>

<script>
function loadChatWidget() {
 const script = document.createElement('script');
 script.src = 'https://cdn.chatprovider.com/widget.js';
 script.async = true;
 document.head.appendChild(script);
 document.getElementById('chat-placeholder').remove();
}
</script>
```

3. Reduce bundle size with code splitting

Ask Claude Code to analyze your webpack or Vite bundle:
```
Run `npx vite-bundle-visualizer` on the production build output,
then read the generated stats.html and identify:
- The 5 largest modules by parsed size
- Any modules loaded on the home page that are only used on the checkout page
- Tree-shaking opportunities in our utility imports
```

## Optimizing CLS

CLS measures visual stability during page load. Preventing layout shifts requires reserving space before content loads.

1. Always set explicit image dimensions

Before:
```html
<img src="/product.jpg" alt="Product photo">
```

After:
```html
<img src="/product.jpg" alt="Product photo" width="800" height="600">
```

Or use the CSS aspect-ratio property for responsive images:
```css
.product-image-wrapper {
 aspect-ratio: 4 / 3;
 width: 100%;
 overflow: hidden;
}

.product-image-wrapper img {
 width: 100%;
 height: 100%;
 object-fit: cover;
}
```

2. Reserve space for dynamic content

Ads, embeds, and cookie banners are common CLS triggers. Reserve their space upfront:

```css
/* Ad slot. fixed height prevents layout shift when ad loads */
.ad-slot-leaderboard {
 min-height: 90px; /* standard leaderboard height */
 width: 100%;
 background: #f9f9f9; /* visible placeholder while ad loads */
}

/* Cookie banner. position fixed so it doesn't push content */
.cookie-banner {
 position: fixed;
 bottom: 0;
 left: 0;
 right: 0;
 z-index: 999;
}
```

3. Optimize font loading to prevent FOUT-driven shifts

```css
@font-face {
 font-family: 'Brand Sans';
 src: url('/fonts/brand-sans.woff2') format('woff2');
 font-display: optional; /* No FOUT. falls back to system font if not ready */
 font-weight: 400;
}
```

And preload the font in your HTML head:
```html
<link rel="preload" as="font" type="font/woff2"
 href="/fonts/brand-sans.woff2" crossorigin>
```

Using `font-display: optional` eliminates font-swap layout shift entirely by only using the web font if it has already been cached or loads within the first 100ms of the page load.

## Diagnosing CLS with Claude Code

CLS is notoriously difficult to debug because the shift may happen after the initial load. Use Claude Code to write a diagnostic script that captures shift sources in the browser:

```js
// cls-debug.js. paste into DevTools console or inject as a script
const observer = new PerformanceObserver((list) => {
 for (const entry of list.getEntries()) {
 if (!entry.hadRecentInput) {
 console.group(`CLS shift. value: ${entry.value.toFixed(4)}`);
 for (const source of entry.sources ?? []) {
 console.log('Element:', source.node);
 console.log('Previous rect:', source.previousRect);
 console.log('Current rect:', source.currentRect);
 }
 console.groupEnd();
 }
 }
});
observer.observe({ type: 'layout-shift', buffered: true });
```

Copy the console output and paste it into Claude Code:
```
Here is the CLS debug output from our homepage on mobile.
Identify which elements are causing the largest shifts and
suggest the CSS or HTML changes needed to fix each one.
```

## Continuous Monitoring Strategy

For sustainable performance improvement, establish a layered monitoring strategy:

| Layer | Tool | Frequency | Purpose |
|-------|------|-----------|---------|
| Lab tests | Lighthouse CLI | On every PR | Catch regressions before deploy |
| Staging audits | Lighthouse CI | Daily on main branch | Track trend over time |
| Production RUM | web-vitals JS | Continuously | Measure real user experience |
| Field data | CrUX API | Weekly | Cross-reference with Google's data |
| Alerting | PagerDuty / Slack | On threshold breach | Notify team of degradation |

Claude Code can automate much of this pipeline. A practical alerting script that runs on a schedule:

```bash
#!/usr/bin/env bash
daily-vitals-check.sh. run via cron or GitHub Actions schedule
set -euo pipefail

SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:?}"
SITE_URL="https://example.com"
THRESHOLD_LCP=2500 # milliseconds
THRESHOLD_CLS=100 # CLS * 1000

REPORT=$(mktemp /tmp/lh-XXXXX.json)
lighthouse "$SITE_URL" \
 --only-categories=performance \
 --output=json \
 --output-path="$REPORT" \
 --chrome-flags="--headless --no-sandbox" \
 --quiet

FAILED=$(node -e "
 const r = require('$REPORT');
 const lcp = r.audits['largest-contentful-paint'].numericValue;
 const cls = r.audits['cumulative-layout-shift'].numericValue * 1000;
 const failures = [];
 if (lcp > $THRESHOLD_LCP) failures.push('LCP ' + Math.round(lcp) + 'ms (limit $THRESHOLD_LCP ms)');
 if (cls > $THRESHOLD_CLS) failures.push('CLS ' + cls.toFixed(1) + ' (limit $THRESHOLD_CLS)');
 console.log(failures.join(', '));
")

if [[ -n "$FAILED" ]]; then
 curl -s -X POST "$SLACK_WEBHOOK" \
 -H 'Content-Type: application/json' \
 -d "{\"text\": \":warning: Core Web Vitals alert for $SITE_URL: $FAILED\"}"
fi

rm -f "$REPORT"
```

Schedule this with a GitHub Actions `schedule` trigger (daily at 6am UTC) so failures alert your team before users notice.

## Conclusion

Claude Code transforms Core Web Vitals optimization from a manual, sporadic process into an automated, systematic workflow. By integrating Lighthouse audits into your development pipeline, setting up regression detection, and following proven optimization patterns, you can maintain excellent Core Web Vitals scores consistently.

Start with quick audits on your key pages to establish baseline metrics. Then move to batch testing to understand your worst-performing URLs. Add CI integration to catch regressions automatically. Finally, layer in RUM data so you know what real users on real devices are experiencing, not just what a headless Chrome in a datacenter reports.

Claude Code handles the heavy lifting at every step, generating audit scripts, interpreting JSON output, suggesting fixes with working code, and building monitoring pipelines, so you can focus on the optimizations that matter most.

Remember: good Core Web Vitals scores not only improve user experience but also contribute to better search rankings. Make them a priority in your development workflow.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-core-web-vitals-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for gRPC Web Workflow Tutorial](/claude-code-for-grpc-web-workflow-tutorial/)
- [Claude Code for Infura Web3 Workflow Tutorial](/claude-code-for-infura-web3-workflow-tutorial/)
- [Claude Code for Web Share API Workflow Tutorial](/claude-code-for-web-share-api-workflow-tutorial/)
- [Claude Code for Soda Core Data Quality Workflow](/claude-code-for-soda-core-data-quality-workflow/)
- [Claude Code for Web Workers Workflow Guide](/claude-code-for-web-workers-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


