---
layout: default
title: "How to Improve Your Chrome Lighthouse Score: A Practical Guide"
description: "Learn practical techniques to improve your Chrome Lighthouse score with code examples. Optimize performance, accessibility, best practices, and SEO for better user experience and search rankings."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-lighthouse-score-improve/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
---

# How to Improve Your Chrome Lighthouse Score: A Practical Guide

Google Lighthouse has become the standard tool for measuring web performance, accessibility, best practices, and SEO. A high Lighthouse score directly impacts your users' experience and affects search engine rankings. This guide provides actionable techniques to improve your Chrome Lighthouse score across all four core categories.

## Running Lighthouse in Chrome

Before diving into optimization, you need to know how to run Lighthouse. Open Chrome DevTools (F12 or Cmd+Option+I), navigate to the Lighthouse tab, and click "Analyze page load". For more consistent results, use the CLI version:

```bash
npm install -g lighthouse
lighthouse https://example.com --view --preset desktop
```

The CLI version provides reproducible results without browser extensions interfering with the measurement.

## Performance Optimization

Performance is usually the hardest category to optimize. Here are the most effective techniques:

### Optimize Images

Images often account for the largest portion of page weight. Use modern formats and proper sizing:

```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Descriptive text" width="800" height="600" loading="lazy">
</picture>
```

The `loading="lazy"` attribute defers loading off-screen images, significantly improving initial page load time. Always specify explicit `width` and `height` attributes to prevent layout shifts.

### Implement Efficient Caching

Configure your server to cache static assets appropriately:

```apache
# Apache .htaccess
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/avif "access plus 1 year"
  ExpiresByType image/webp "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

For Nginx, use the `expires` directive:

```nginx
location ~* \.(avif|webp|jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, no-transform";
}
```

### Reduce JavaScript Payload

Large JavaScript bundles block rendering. Implement code splitting:

```javascript
// webpack.config.js example
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        },
      },
    },
  },
};
```

Use dynamic imports for routes that aren't immediately needed:

```javascript
// Instead of static import
// import { HeavyComponent } from './HeavyComponent';

// Use dynamic import
const HeavyComponent = () => import('./HeavyComponent');
```

### Eliminate Render-Blocking Resources

Move CSS to the head and defer non-critical JavaScript:

```html
<head>
  <link rel="stylesheet" href="critical.css">
</head>
<body>
  <header>...</header>
  <main>...</main>
  <script defer src="non-critical.js"></script>
</body>
```

The `defer` attribute executes the script after HTML parsing completes, without blocking the initial render.

## Accessibility Improvements

Accessibility affects users with disabilities and often correlates with overall code quality.

### Proper Semantic HTML

Use semantic elements instead of generic divs:

```html
<!-- Instead of -->
<div class="header">...</div>
<div class="nav">...</div>
<div class="main">...</div>
<div class="footer">...</div>

<!-- Use -->
<header>...</header>
<nav>...</nav>
<main>...</main>
<footer>...</footer>
```

### Form Accessibility

Every form input needs a proper label:

```html
<!-- Incorrect -->
<input type="email" placeholder="Email">

<!-- Correct -->
<label for="email">Email address</label>
<input type="email" id="email" name="email" required>
```

### Color Contrast

Ensure text meets WCAG contrast ratios (4.5:1 for normal text, 3:1 for large text). Use tools like the WebAIM Contrast Checker to verify colors.

### Keyboard Navigation

All interactive elements must be focusable and operable via keyboard:

```css
:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 2px;
}
```

## Best Practices

This category covers security and modern web standards.

### HTTPS

Ensure your site serves all content over HTTPS. If you're using HTTP, redirect all requests:

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

### Modern Image Formats

Serve images in AVIF or WebP format when supported:

```javascript
function getSupportedFormat() {
  const avif = document.createElement('canvas').toDataURL('image/avif');
  return avif.startsWith('data:image/avif') ? 'avif' : 
         document.createElement('canvas').toDataURL('image/webp').startsWith('data:image/webp') ? 'webp' : 'jpeg';
}
```

### Remove Console Errors

Fix JavaScript errors that appear in the console. Common issues include:

- Using deprecated APIs
- Failing to load required resources
- Syntax errors in inline scripts

### Proper charset Declaration

Declare character encoding in your HTML:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  ...
</head>
```

## SEO Optimization

Search engine visibility depends on proper SEO implementation.

### Meta Tags

Include essential meta tags in your head section:

```html
<head>
  <title>Page Title | Site Name</title>
  <meta name="description" content="A compelling description of the page content, around 150-160 characters.">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="canonical" href="https://example.com/page/">
  
  <!-- Open Graph -->
  <meta property="og:title" content="Page Title">
  <meta property="og:description" content="Description for social sharing">
  <meta property="og:image" content="https://example.com/image.jpg">
  <meta property="og:url" content="https://example.com/page/">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
</head>
```

### Document Structure

Use proper heading hierarchy:

```html
<h1>Main Heading</h1>
<p>Introduction paragraph...</p>

<h2>Section Heading</h2>
<p>Section content...</p>

<h3>Subsection Heading</h3>
<p>Subsection content...</p>
```

Never skip heading levels (don't go from h1 to h3).

### Crawlable Links

Ensure search engines can crawl your links:

```html
<!-- Good - crawlable -->
<a href="/about">About Us</a>

<!-- Avoid - not crawlable -->
<a href="javascript:void(0)" onclick="navigate('/about')">About Us</a>
```

If you use JavaScript for navigation, ensure proper implementation with the History API.

## Measuring and Iterating

Lighthouse scores fluctuate based on network conditions and system load. Run tests multiple times and consider using the `--preset` flag for consistent results:

```bash
lighthouse https://example.com --preset=desktop --throttling.cpuSlowdownMultiplier=4 --form-factor=desktop --screenEmulation.disabled
```

Track scores over time by exporting results to JSON and comparing:

```bash
lighthouse https://example.com --output json --output-path results.json
```

A common pattern is to integrate Lighthouse into your CI/CD pipeline to prevent regression:

```yaml
# GitHub Actions example
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v10
  with:
    urls: |
      https://example.com
    budgetPath: ./lighthouse-budget.json
```

Create a budget file to enforce minimum scores:

```json
{
  "ci": {
    "assert": {
      "categories": {
        "performance": ["error", { "minScore": 0.9 }],
        "accessibility": ["error", { "minScore": 0.9 }],
        "best-practices": ["error", { "minScore": 0.9 }],
        "seo": ["error", { "minScore": 0.9 }]
      }
    }
  }
}
```

## Conclusion

Improving your Chrome Lighthouse score requires systematic optimization across performance, accessibility, best practices, and SEO. Start with the biggest impact items: image optimization, caching, and reducing JavaScript payload. Iterate by measuring after each change and tracking scores over time. A score above 90 in all categories indicates a well-optimized website that provides excellent user experience.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
