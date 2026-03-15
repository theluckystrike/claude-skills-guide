---

layout: default
title: "How to Spoof User Agent in Chrome: A Developer's Guide"
description: "Learn multiple methods to spoof user agent strings in Chrome for testing, development, and debugging. Covers DevTools, extensions, and programmatic approaches."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /spoof-user-agent-chrome/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
---


# How to Spoof User Agent in Chrome: A Developer's Guide

User agent spoofing is a essential technique for web developers and QA engineers testing cross-browser compatibility, debugging device-specific issues, or simulating different client environments. Chrome provides several built-in and extension-based methods to modify your user agent string without changing your browser installation.

This guide covers practical approaches for changing your user agent in Chrome, from quick DevTools tweaks to programmatic solutions using automation tools.

## Understanding the User Agent String

Every HTTP request includes a User-Agent header that identifies the browser, operating system, and version to web servers. The typical format looks like this:

```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
```

Websites use this information for analytics, feature detection, and sometimes content delivery decisions. When you need to test how your site behaves with different browsers or devices, spoofing becomes necessary.

## Method 1: Chrome DevTools Network Conditions

Chrome's built-in Developer Tools provide the quickest way to change your user agent without installing anything:

1. Open DevTools (F12 or Cmd+Option+I on macOS)
2. Click the three-dot menu in the top-right corner
3. Select "More tools" → "Network conditions"
4. Uncheck "Use browser default" next to User agent
5. Select a preset or enter a custom string

This method affects only the current tab and persists until you close the browser. The DevTools must remain open for the setting to take effect.

Custom user agent example for mobile testing:

```
Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1
```

## Method 2: Chrome Command-Line Flag

For more persistent user agent changes across sessions, you can launch Chrome with a command-line flag:

**macOS:**

```bash
open -a "Google Chrome" --args --user-agent="Mozilla/5.0 (Linux; Android 11) Chrome/120.0.0.0 Mobile Safari/537.36"
```

**Windows:**

```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" --user-agent="Mozilla/5.0 (Linux; Android 11) Chrome/120.0.0.0 Mobile Safari/537.36"
```

This approach applies to all tabs in the new window. Create a desktop shortcut with the flag for repeated use with the same user agent.

## Method 3: Chrome Extensions

Several extensions provide user agent switching with presets and custom options:

**User-Agent Switcher** is a popular choice with over 4 million users. After installation:

1. Click the extension icon in your toolbar
2. Select from built-in presets (Chrome, Firefox, Safari, Edge, mobile devices)
3. Add custom user agents as needed

**UA Inspector** offers more advanced features including user agent parsing and preset management for specific testing scenarios.

When choosing extensions, verify the permissions and prefer open-source options to ensure your data remains private.

## Method 4: Programmatic Spoofing with Puppeteer

For automated testing and CI/CD pipelines, programmatic control is essential. Puppeteer provides straightforward user agent manipulation:

```javascript
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  // Set custom user agent
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  
  // Verify the user agent
  const userAgent = await page.evaluate(() => navigator.userAgent);
  console.log('User agent:', userAgent);
  
  // Navigate and test
  await page.goto('https://example.com');
  
  await browser.close();
})();
```

To simulate mobile devices, Puppeteer includes built-in device descriptors:

```javascript
const puppeteer = require('puppeteer');
const devices = require('puppeteer/devices');

// iPhone 14 Pro simulation
(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.emulate(devices['iPhone 14 Pro']);
  
  await page.goto('https://example.com');
  await browser.close();
})();
```

## Method 5: Playwright for Cross-Browser Testing

Playwright offers similar capabilities with cross-browser support:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    
    # Set custom user agent
    page.set_extra_http_headers({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    })
    
    page.goto('https://example.com')
    browser.close()
```

Playwright also supports device emulation:

```python
page = browser.new_page(viewport={'width': 390, 'height': 844}, user_agent='Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) iOS/16.0 Mobile/15E148 Safari/604.1')
```

## Common Use Cases

**Responsive design testing**: Verify your responsive breakpoints work across different viewport sizes and user agents without physical devices.

**API debugging**: Test how your backend handles requests from different client types, including legacy browsers or specific mobile apps.

**Analytics validation**: Confirm your analytics tracking fires correctly for different browser and device combinations.

**Feature detection bypass testing**: Some services restrict features based on user agent; spoofing helps test fallback behaviors.

## Best Practices

When spoofing user agents, keep these considerations in mind:

- Always test with actual browsers eventually—spoofing cannot replicate all browser behaviors
- Document your testing methodology if spoofing is part of QA processes
- Use programmatic tools for repeatable, automated test suites
- Be aware that sophisticated servers may detect spoofing through JavaScript feature detection

Built by theluckystrike — More at [zovo.one](https://zovo.one)
