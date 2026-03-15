---
layout: default
title: "Chrome DevTools Lighthouse Audit Guide"
description: "Master Chrome DevTools Lighthouse audits: run performance, accessibility, SEO, and best practices audits with practical examples."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-devtools-lighthouse-audit-guide/
---

# Chrome DevTools Lighthouse Audit Guide

Lighthouse is a built-in auditing tool in Chrome DevTools that analyzes web pages across five categories: Performance, Accessibility, Best Practices, SEO, and Progressive Web App compliance. This guide shows you how to run Lighthouse audits, interpret results, and use the findings to improve your web projects.

## Accessing Lighthouse in Chrome DevTools

Open Chrome DevTools using `F12`, `Cmd+Opt+I` (Mac), or `Ctrl+Shift+I` (Windows/Linux). Navigate to the **Lighthouse** tab—it's the fourth icon in theDevTools toolbar, shaped like a small lighthouse.

The Lighthouse panel presents configuration options before you run an audit:

- **Mode**: Choose between Navigation (single page load) and Timespan (monitoring over time)
- **Device**: Select **Desktop** or **Mobile** to simulate different viewport sizes and network conditions
- **Categories**: Check the boxes for Performance, Accessibility, Best Practices, SEO, and PWA

Click **Analyze page load** to begin. Lighthouse loads the page, runs its tests, and presents scores and recommendations within 30-60 seconds.

## Understanding Your Lighthouse Scores

Lighthouse scores range from 0 to 100 for each category. Here's the general scale:

- **0-49**: Needs improvement (red)
- **50-89**: Needs improvement (orange)  
- **90-100**: Good (green)

The overall Performance score is a weighted average of several metrics:

| Metric | Weight | What It Measures |
|--------|--------|------------------|
| First Contentful Paint (FCP) | 15% | Time until first content renders |
| Largest Contentful Paint (LCP) | 25% | Time until largest content element renders |
| Total Blocking Time (TBT) | 25% | Main thread blocking duration |
| Cumulative Layout Shift (CLS) | 25% | Visual stability during load |
| Speed Index | 10% | How quickly content becomes visible |

A score of 90 or above typically indicates a well-optimized page, but context matters—content-heavy sites may naturally score lower.

## Running Your First Audit

Navigate to any URL and run a Lighthouse audit with all categories enabled. The output provides a comprehensive health check of your page. Each failed audit includes expandable sections explaining the issue, its impact, and specific remediation steps.

For example, a failing **Performance** audit might flag an image that lacks explicit dimensions:

```
Image elements do not have explicit width and height attributes.
Width and height attributes should be set to reduce layout shifts
and improve Core Web Vitals.
```

The fix is straightforward—add width and height attributes to your `<img>` tags:

```html
<img src="hero-image.jpg" width="800" height="600" alt="Description">
```

## Auditing for Accessibility

Accessibility audits verify that your site can be used by people with disabilities. Lighthouse checks for:

- ARIA attributes and labels
- Color contrast ratios
- Keyboard navigation support
- Image alt text
- Document structure (heading hierarchy, landmark regions)

Run an accessibility audit on your page. If it fails, focus on the highest-impact issues first. Missing alt text on images is easy to fix and immediately improves screen reader compatibility:

```html
<!-- Bad: Missing alt attribute -->
<img src="chart.png">

<!-- Good: Descriptive alt text -->
<img src="chart.png" alt="Bar chart showing 40% growth in Q4">
```

## SEO Audits and Technical Optimization

The SEO category checks fundamental technical requirements for search engine indexing:

- Document has a `<title>` tag
- Meta description is present
- Viewport is configured correctly
- Links are crawlable
- Structured data is valid (when present)

A common SEO failure is missing or duplicate meta descriptions. Fix this by adding unique descriptions to each page:

```html
<head>
  <title>Page Title | Your Website</title>
  <meta name="description" content="A concise description of this page's content, typically 150-160 characters.">
</head>
```

Lighthouse also verifies that your robots meta tag doesn't block indexing:

```html
<meta name="robots" content="index, follow">
```

## Best Practices and Security Audits

The Best Practices category covers modern web standards and security:

- HTTPS usage
- No console errors
- Proper doctype declaration
- No vulnerable JavaScript libraries
- Correct aspect ratios on images

If Lighthouse detects HTTP resources on an HTTPS page, it flags mixed content issues. Audit your third-party scripts and ensure all resources load over HTTPS:

```javascript
// Before: Mixed content
<script src="http://cdn.example.com/library.js"></script>

// After: Secure content
<script src="https://cdn.example.com/library.js"></script>
```

## Automating Lighthouse with CLI

For continuous integration workflows, run Lighthouse from the command line. Install the CLI globally:

```bash
npm install -g lighthouse
```

Run an audit and save results as HTML:

```bash
lighthouse https://example.com --output html --output-path ./report.html
```

For JSON output that you can parse programmatically:

```bash
lighthouse https://example.com --output json --output-path ./report.json
```

The JSON format is useful for tracking scores over time or integrating with dashboards.

## Interpreting and Acting on Results

Lighthouse provides actionable recommendations, but prioritize based on your goals:

1. **Performance**: Start with image optimization, then address JavaScript blocking and caching
2. **Accessibility**: Fix missing labels and heading structure first—these have the broadest impact
3. **SEO**: Ensure proper meta tags and crawlable content
4. **Best Practices**: Address security warnings immediately

Re-audit after making changes to verify improvements. Track your scores in a spreadsheet or CI pipeline to monitor trends.

## Conclusion

Chrome DevTools Lighthouse provides a fast, free way to audit your web pages across multiple quality dimensions. Run audits during development to catch issues early, before deployment. Use the CLI for automated testing in your build pipeline. Address high-impact issues first and re-audit to confirm your fixes work.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
