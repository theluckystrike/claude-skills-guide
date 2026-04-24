---

layout: default
title: "Claude Code Lighthouse Score"
description: "Practical automation strategies for improving Lighthouse scores using Claude Code skills, with code examples and workflows for developers."
date: 2026-03-13
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, claude-skills, lighthouse, performance, automation]
reviewed: true
score: 8
permalink: /claude-code-lighthouse-score-improvement-automation-guide/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[Performance optimization is a continuous process, not a one-time fix](/best-claude-code-skills-to-install-first-2026/) Automating Lighthouse score improvements with Claude Code skills transforms reactive debugging into proactive performance management. This guide covers practical workflows for identifying bottlenecks, applying fixes automatically, and maintaining high scores over time.

## Understanding the Lighthouse Automation Challenge

[Lighthouse measures five core categories: Performance, Accessibility, Best Practices, SEO, and Progressive Web App compliance](/best-claude-code-skills-to-install-first-2026/) Each category requires specific attention, and manually checking these metrics after every code change quickly becomes tedious. The solution lies in automating both the detection and remediation of performance issues.

Claude Code skills provide the building blocks for this automation. The [frontend-design skill](/best-claude-code-skills-for-frontend-development/) offers initial site audits, while the tdd skill helps ensure performance tests pass before deployment. For persistent memory across sessions, the [supermemory skill](/claude-skills-token-optimization-reduce-api-costs/) stores historical scores and tracks trends.

## Setting Up Automated Lighthouse Audits

The first step involves creating a reliable audit pipeline. Rather than running Lighthouse manually, integrate it directly into your development workflow. A simple Node.js script handles the core functionality:

```javascript
// lighthouse-audit.js
import { chromium } from 'playwright';
import { lighthouse } from 'lighthouse';
import fs from 'fs/promises';

async function runAudit(url, outputPath) {
 const browser = await chromium.launch();
 const page = await browser.newPage();
 
 const results = await lighthouse(url, {
 port: 9222,
 output: 'json',
 onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
 throttlingMethod: 'simulate',
 throttling: {
 rttMs: 40,
 throughputKbps: 10240,
 cpuSlowdownMultiplier: 1,
 },
 });

 await fs.writeFile(outputPath, JSON.stringify(results.lhr, null, 2));
 await browser.close();
 
 return results.lhr;
}
```

This script runs audits programmatically and stores results for comparison. Schedule it to run after deployments or integrate it into pull request checks.

## Automating Performance Fixes

Once you have baseline scores, focus on the highest-impact improvements. Common automation targets include image optimization, JavaScript bundle reduction, and critical CSS extraction.

## Image Optimization Pipeline

Large images often cause the biggest performance hits. Automate image processing with a build-step integration:

```javascript
// optimize-images.js
import sharp from 'sharp';
import glob from 'fast-glob';

async function optimizeImages() {
 const images = await glob('src//*.{png,jpg,jpeg,webp}');
 
 for (const image of images) {
 const output = image.replace(/src\//, 'dist/').replace(/\.(png|jpg|jpeg)$/, '.webp');
 await sharp(image)
 .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
 .webp({ quality: 80 })
 .toFile(output);
 
 console.log(`Optimized: ${image} -> ${output}`);
 }
}
```

This converts images to WebP format and resizes them appropriately. Run this as part of your build process to ensure all images meet modern standards.

## JavaScript Bundle Analysis

The frontend-design skill excels at analyzing bundle composition. Create a workflow that identifies large dependencies and suggests alternatives:

```javascript
// analyze-bundle.js
import { rollup } from 'rollup';
import analyze from 'rollup-plugin-analyzer';

export async function analyzeBundle(bundlePath) {
 const bundle = await rollup({
 input: bundlePath,
 plugins: [analyze({ summaryOnly: true })],
 });

 const output = await bundle.generate({ format: 'esm' });
 return output;
}
```

This reveals exactly which modules contribute to bundle size, enabling targeted optimization efforts.

## Integrating with Continuous Integration

Automating Lighthouse scores means integrating checks into your CI pipeline. GitHub Actions provides a straightforward implementation:

```yaml
name: Lighthouse CI
on: [push, pull_request]
jobs:
 lighthouse:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: actions/setup-node@v4
 with:
 node-version: '20'
 - run: npm ci
 - run: npm run build
 - name: Run Lighthouse
 uses: treosh/lighthouse-ci-action@v10
 with:
 urls: |
 https://your-app.com
 uploadArtifacts: true
 temporaryPublicStorage: true
 configPath: ./lighthouserc.json
```

Set thresholds in your configuration to fail builds when scores drop below acceptable levels. This prevents performance regressions from reaching production.

## Lighthouse CI Configuration File

Install `@lhci/cli` and create a `lighthouserc.js` with metric-specific assertions and resource budgets:

```bash
npm install --save-dev @lhci/cli
```

```javascript
// lighthouserc.js
module.exports = {
 ci: {
 collect: {
 staticFileDistDir: './dist',
 numberOfRuns: 3,
 url: ['http://localhost:3000'],
 },
 upload: {
 target: 'temporary-public-storage',
 serverBaseUrl: process.env.LHCI_SERVER_URL,
 token: process.env.LHCI_TOKEN,
 },
 assert: {
 assertions: {
 'categories:performance': ['error', { minScore: 0.9 }],
 'categories:accessibility': ['error', { minScore: 0.9 }],
 'first-contentful-paint': ['warn', { maxNumericValue: 2000 }],
 'largest-contentful-paint': ['error', { maxNumericValue: 4000 }],
 'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
 'resource-summary:javascript:size': ['error', { maxNumericValue: 170000 }],
 'resource-summary:image:size': ['error', { maxNumericValue: 500000 }],
 'third-party-summary': ['warn', { maxNumericWeight: 0.3 }],
 },
 },
 },
};
```

These budgets catch issues before they become severe. When a JavaScript bundle exceeds 170KB or third-party scripts load too slowly, your build fails.

## Local Server CI Pattern

For testing against a locally built server rather than a live URL, start the server in the background:

```yaml
- name: Start server
 run: npm start &

- name: Wait for server
 run: sleep 10

- name: Run Lighthouse CI
 run: npx lhci autorun
 env:
 LHCI_TOKEN: ${{ secrets.LHCI_TOKEN }}
```

## Custom Claude Skill for Lighthouse CI

Create a dedicated skill that gives Claude context for interpreting Lighthouse CI failures:

```markdown
---
name: lighthouse-ci
description: Analyze Lighthouse CI results and suggest performance improvements
---

You are a performance optimization expert. When provided with Lighthouse CI results:
1. Identify the lowest-scoring categories and specific audits
2. Look for patterns in failing audits (e.g., image optimization, JavaScript blocking)
3. Note any regressions from previous runs
4. Provide specific code changes or configuration adjustments to fix each issue
```

When a CI build fails, pass the results directly: "Claude, the Lighthouse CI build failed with a 0.7 performance score. The first-contentful-paint is 3.2s and largest-contentful-paint is 4.8s. Can you analyze this and suggest fixes?"

## Tracking Performance Over Time

The supermemory skill proves invaluable for historical tracking. Store scores in a time-series format:

```javascript
// track-scores.js
import fs from 'fs/promises';

const scorePath = './data/lighthouse-scores.json';

async function trackScore(category, score) {
 const data = await fs.readFile(scorePath, 'utf-8').catch(() => '{}');
 const scores = JSON.parse(data);
 
 if (!scores[category]) scores[category] = [];
 
 scores[category].push({
 timestamp: new Date().toISOString(),
 score: score,
 });
 
 await fs.writeFile(scorePath, JSON.stringify(scores, null, 2));
}
```

Over time, this data reveals patterns: certain code changes consistently impact performance, or specific pages require ongoing attention.

## Accessibility Automation

The frontend-design skill includes accessibility auditing capabilities. Automate remediation by catching issues early:

```javascript
// accessibility-check.js
import { AxePuppeteer } from '@axe-core/puppeteer';
import puppeteer from 'puppeteer';

async function checkAccessibility(url) {
 const browser = await puppeteer.launch();
 const page = await browser.newPage();
 
 await page.goto(url);
 
 const results = await new AxePuppeteer(page).analyze();
 
 await browser.close();
 
 return results;
}
```

This runs axe-core audits against any page, identifying accessibility violations that impact both user experience and SEO scores.

## Best Practices and SEO Checks

Beyond performance, Lighthouse evaluates best practices and SEO. Automate these checks alongside performance metrics. The pdf skill helps generate reports for stakeholders who need visual documentation of improvements.

A comprehensive workflow processes all categories:

```javascript
// full-audit.js
import { runAudit } from './lighthouse-audit.js';
import { checkAccessibility } from './accessibility-check.js';
import { optimizeImages } from './optimize-images.js';

async function fullAudit() {
 console.log('Starting full audit...');
 
 const lhr = await runAudit('https://your-app.com', './reports/lighthouse.json');
 const a11y = await checkAccessibility('https://your-app.com');
 
 console.log('Performance:', lhr.categories.performance.score);
 console.log('Accessibility:', lhr.categories.accessibility.score);
 console.log('Best Practices:', lhr.categories['best-practices'].score);
 console.log('SEO:', lhr.categories.seo.score);
 
 return { lhr, a11y };
}
```

## Maintaining High Scores

Automation solves the initial optimization problem, but maintenance requires ongoing attention. Implement these practices:

Set score thresholds. Define minimum acceptable scores (typically 90+) and fail builds that fall below them.

Monitor trends. Use the supermemory skill to track scores over time and alert on downward trends before they become critical.

Automate remediation. Some fixes lend themselves to automation (image optimization, minification), while others require human review (content quality, complex accessibility issues).

Test in production-like environments. Staging environments should mirror production to ensure accurate Lighthouse results.

## Conclusion

Automating Lighthouse score improvement with Claude Code skills transforms performance from a manual, sporadic task into a systematic process. The frontend-design, tdd, supermemory, and pdf skills work together to audit, test, track, and report on performance metrics.

Start with automated audits, then layer in optimization scripts for the highest-impact fixes. Integrate everything into your CI pipeline to catch regressions before they reach production. With proper automation, maintaining Lighthouse scores of 90+ becomes achievable without dedicated performance teams.
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-lighthouse-score-improvement-automation-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Skills for Frontend and UI Development](/best-claude-code-skills-for-frontend-development/). Frontend skills for performance optimization and building high-scoring production UIs
- [Best Claude Skills for Developers 2026](/best-claude-skills-for-developers-2026/). The tdd and pdf skills power automated performance testing and reporting workflows
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Keep automated Lighthouse audit sessions economical
- [Claude Code Semantic HTML Improvement Guide](/claude-code-semantic-html-improvement-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


