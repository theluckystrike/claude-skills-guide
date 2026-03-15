---

layout: default
title: "How to Spoof User Agent in Chrome for Development and Testing"
description: "Learn practical methods to spoof user agent strings in Chrome for cross-browser testing, debugging, and development. Includes code examples and CLI tools."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /spoof-user-agent-chrome/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
---


{% raw %}

# How to Spoof User Agent in Chrome for Development and Testing

Changing your user agent in Chrome is a common need for web developers testing responsive designs, debugging browser-specific issues, or simulating different devices. This guide covers practical methods to spoof user agent strings in Chrome, from built-in developer tools to automation frameworks.

## Understanding the User Agent String

Every HTTP request includes a User-Agent header that identifies the browser and operating system to servers. Websites use this information to serve appropriate content, but it also enables tracking and can cause issues when you need to test how your site appears to different browsers.

The user agent string follows a patterns like:

```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
```

When you spoof this string, you can see how servers respond to different browsers without maintaining multiple installations.

## Method 1: Chrome DevTools Device Emulation

The simplest approach uses Chrome's built-in developer tools.

1. Open DevTools (F12 or Cmd+Option+I on Mac)
2. Click the device toggle icon or press Cmd+Shift+M
3. Select a device from the dropdown, or click "Edit" to add custom devices
4. The device emulation automatically sets a matching user agent

This method is quick but limited—you can only choose from preset device configurations.

## Method 2: Chrome Launch Flags for Custom User Agent

For more control, launch Chrome with command-line flags to set a specific user agent.

### macOS

```bash
open -a Google\ Chrome --args --user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
```

### Windows

```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --user-agent="Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
```

This approach works well for testing specific browser scenarios. Each Chrome window opened from this command uses the custom user agent.

## Method 3: Chrome Extensions for User Agent Switching

Several extensions provide UI-based user agent switching:

- **User-Agent Switcher**: Click to swap between preset user agents
- **Tampermonkey**: Run scripts that modify headers on specific domains
- **ModHeader**: Modify request and response headers including User-Agent

Install from the Chrome Web Store, then configure your desired user agents through the extension interface. This method offers the best balance of convenience and flexibility.

## Method 4: Puppeteer and Playwright for Automated Testing

For programmatic testing, Puppeteer and Playwright let you set custom user agents in code:

### Puppeteer Example

```javascript
const puppeteer = require('puppeteer');

async function testWithUserAgent() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  
  const userAgent = await page.evaluate(() => navigator.userAgent);
  console.log('Current user agent:', userAgent);
  
  await browser.close();
}

testWithUserAgent();
```

### Playwright Example

```javascript
const { chromium } = require('playwright');

async function testWithCustomUA() {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15'
  });
  
  const page = await context.newPage();
  const ua = await page.evaluate(() => navigator.userAgent);
  console.log('Emulated user agent:', ua);
  
  await browser.close();
}

testWithCustomUA();
```

These frameworks are ideal for CI/CD pipelines and automated cross-browser testing.

## Method 5: Setting Headers in Network Requests

For more advanced scenarios where you need to test specific request headers, use a local proxy or the Chrome DevTools Protocol:

```javascript
const puppeteer = require('puppeteer');

async function testWithCustomHeaders() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.setExtraHTTPHeaders({
    'X-Custom-Header': 'custom-value',
    'User-Agent': 'MyCustomBrowser/1.0'
  });
  
  await page.goto('https://example.com');
  await browser.close();
}
```

This approach lets you test custom headers alongside or instead of the standard User-Agent.

## Practical Testing Scenarios

Here are common use cases where spoofing becomes essential:

**Responsive Design Testing**: Verify your site renders correctly on mobile devices, tablets, and desktops without physically accessing each device.

**API Development**: Test how your backend handles requests from different browser clients, including old browsers your users might still run.

**Analytics Validation**: Confirm your analytics tools correctly identify browser types and versions.

**Bot Detection**: Understand how your site appears to search engine crawlers and automated tools.

## Verification Techniques

After setting a custom user agent, verify it works:

1. **Check in DevTools**: Navigate to a site like `whatmyuseragent.com` or inspect the Network tab to see the sent headers.

2. **Console Check**: In the Chrome console:

```javascript
console.log(navigator.userAgent);
```

3. **Server-Side Logging**: Add logging to your backend to inspect incoming User-Agent headers during testing.

## Common Pitfalls to Avoid

Some websites actively detect user agent spoofing through JavaScript APIs that reveal the actual browser, canvas fingerprinting, or behavioral analysis. If you encounter detection, you may need more sophisticated approaches like running actual虚拟机 or using browser automation tools with anti-detection features.

Also remember that changing the user agent doesn't change browser behavior—JavaScript APIs like `navigator.appVersion` or feature detection still reflect the actual Chrome capabilities.

## Conclusion

Chrome provides multiple paths to spoof user agent strings, from quick DevTools emulation to programmatic automation with Puppeteer or Playwright. Choose the method matching your needs: quick visual testing, persistent sessions, or automated CI/CD pipelines.

For regular testing workflows, extensions offer convenience. For automated testing at scale, Puppeteer or Playwright provide the flexibility and repeatability your development process requires.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
