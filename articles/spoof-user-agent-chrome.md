---
layout: default
title: "How to Spoof User Agent in Chrome (2026)"
description: "Claude Code guide: learn practical methods to spoof user agent strings in Chrome for cross-browser testing, debugging, and development. Includes code..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /spoof-user-agent-chrome/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
geo_optimized: true
---
## How to Spoof User Agent in Chrome for Development and Testing

Changing your user agent in Chrome is a common need for web developers testing responsive designs, debugging browser-specific issues, or simulating different devices. This guide covers practical methods to spoof user agent strings in Chrome, from built-in developer tools to automation frameworks.

## Understanding the User Agent String

Every HTTP request includes a User-Agent header that identifies the browser and operating system to servers. Websites use this information to serve appropriate content, but it also enables tracking and can cause issues when you need to test how your site appears to different browsers.

The user agent string follows a pattern like:

```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
```

Breaking this down:
- `Mozilla/5.0`. legacy compatibility token, present in virtually all modern browsers
- `Windows NT 10.0; Win64; x64`. operating system and architecture
- `AppleWebKit/537.36`. the rendering engine
- `Chrome/120.0.0.0`. the actual browser name and version
- `Safari/537.36`. another legacy compatibility token

When you spoof this string, you can see how servers respond to different browsers without maintaining multiple installations. Servers use the UA string for content negotiation, feature flags, analytics bucketing, and sometimes delivering entirely different page layouts.

## Why the UA String Still Matters

Despite client hints and feature detection becoming more common, the User-Agent header remains widely used. CDN edge rules, A/B testing platforms, mobile redirect logic, and paywall systems all inspect UA strings. A server might redirect `Mobile Safari` UAs to an `m.` subdomain, serve a different ad network to Chrome vs Firefox, or gate certain features behind specific browser versions. Understanding this is what makes user agent spoofing a genuine debugging tool rather than a curiosity.

## Method 1: Chrome DevTools Device Emulation

The simplest approach uses Chrome's built-in developer tools.

1. Open DevTools (F12 or Cmd+Option+I on Mac)
2. Click the device toggle icon or press Cmd+Shift+M
3. Select a device from the dropdown, or click "Edit" to add custom devices
4. The device emulation automatically sets a matching user agent

This method is quick but limited. you can only choose from preset device configurations. However, there is a way to set a fully custom string without any extensions:

1. Open DevTools
2. Press Escape to open the console drawer
3. Click the three-dot menu in the drawer and select "Network conditions"
4. Uncheck "Use browser default" next to "User agent"
5. Type any UA string you want into the text field

This custom UA persists for the entire DevTools session, across all page navigations, until you close DevTools or re-enable the default. It is the fastest path to a one-off custom string that does not require installing anything.

Limitation: DevTools UA spoofing only applies to HTTP requests. JavaScript's `navigator.userAgent` will also reflect the custom value, but some browser fingerprinting APIs (like `navigator.userAgentData`) may still reveal the real browser identity.

## Method 2: Chrome Launch Flags for Custom User Agent

For more control, launch Chrome with command-line flags to set a specific user agent. This approach applies the UA globally at the process level. every request from that Chrome instance uses the custom string.

macOS

```bash
open -a Google\ Chrome --args --user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
```

## Windows

```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --user-agent="Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
```

## Linux

```bash
google-chrome --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
```

You must quit all existing Chrome windows first. Chrome is a single-process application by default. if any Chrome instance is already running, the new window will join the existing process and ignore the flag.

A useful pattern on macOS for testing alongside a normal Chrome session is to use Chrome Canary or a separate profile directory:

```bash
open -a "Google Chrome Canary" --args --user-agent="Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
```

This lets you have one Chrome window with a normal UA and one with a spoofed UA running simultaneously.

## Method 3: Chrome Extensions for User Agent Switching

Several extensions provide UI-based user agent switching with no command-line knowledge required:

- User-Agent Switcher and Manager: Comprehensive preset list covering every major browser, OS, and bot. Supports per-domain rules so you can spoof UA on one site while using the real UA everywhere else.
- ModHeader: Full HTTP header editor. Useful when you need to modify User-Agent alongside other headers like `Accept-Language`, `Referer`, or custom auth headers.
- Requestly: Intercept and modify requests with conditional logic. Good for staging environments where you want to swap UA based on URL patterns.

Install from the Chrome Web Store, then configure your desired user agents through the extension interface. This method offers the best balance of convenience and flexibility for manual testing sessions.

Per-domain rules are a feature worth looking for. If you're testing your own site's mobile redirect logic, you want the spoofed UA only on your domain. not everywhere. ModHeader and Requestly both support this; the basic User-Agent Switcher extensions typically do not.

## Method 4: Puppeteer and Playwright for Automated Testing

For programmatic testing, Puppeteer and Playwright let you set custom user agents in code. This is the right approach for CI/CD pipelines, regression test suites, and any situation where you need reproducible results.

## Puppeteer Example

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

## Playwright Example

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

## Testing Multiple User Agents in Parallel

Playwright's context model makes it straightforward to test multiple UAs in the same test run:

```javascript
const { chromium } = require('playwright');

const agents = [
 {
 name: 'Chrome Desktop',
 ua: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
 },
 {
 name: 'iPhone Safari',
 ua: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
 },
 {
 name: 'Googlebot',
 ua: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
 }
];

async function runTests() {
 const browser = await chromium.launch();

 await Promise.all(agents.map(async (agent) => {
 const context = await browser.newContext({ userAgent: agent.ua });
 const page = await context.newPage();
 await page.goto('https://your-site.com');

 const title = await page.title();
 console.log(`[${agent.name}] Page title: ${title}`);

 // Check if a mobile redirect happened
 const url = page.url();
 console.log(`[${agent.name}] Final URL: ${url}`);

 await context.close();
 }));

 await browser.close();
}

runTests();
```

This pattern is useful for smoke-testing that your mobile redirect logic, bot-specific content, and desktop layout all work correctly. in a single test run.

## Method 5: Setting Headers in Network Requests

For more advanced scenarios where you need to test specific request headers, use `setExtraHTTPHeaders` in Puppeteer or Playwright's route interception:

## Puppeteer: Extra Headers

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

## Playwright: Route Interception for Fine-Grained Control

```javascript
const { chromium } = require('playwright');

async function testWithRoutedHeaders() {
 const browser = await chromium.launch();
 const context = await browser.newContext();
 const page = await context.newPage();

 // Only modify UA for requests to a specific API endpoint
 await page.route('/api/', async (route) => {
 const headers = {
 ...route.request().headers(),
 'user-agent': 'InternalTestClient/2.0',
 'x-test-run': 'true'
 };
 await route.continue({ headers });
 });

 await page.goto('https://your-app.com');
 await browser.close();
}
```

Route interception is particularly useful when you need the browser's real UA for most requests (so the page renders normally) but want a custom UA for specific API calls your application makes.

## Practical Testing Scenarios

Here are the most common situations where UA spoofing is genuinely necessary:

Mobile redirect testing: Many sites redirect `m.example.com` or serve a different layout based on UA. You need to verify this logic works before deploying changes to your redirect rules. DevTools emulation or a Playwright test covers this well.

Crawler-specific content: Some sites serve a simplified HTML version to Googlebot for SEO purposes (or to game crawlers). Testing with Googlebot's UA lets you verify what search engines actually see. Compare the Googlebot render against your normal Chrome render.

Old browser compatibility: Enterprise clients sometimes run outdated browsers. Set a Chrome 80 or even IE 11 UA and observe how your site behaves. especially relevant if you have browser detection that renders feature-flagged content.

Third-party SDKs with UA gates: Analytics platforms, chat widgets, and A/B testing tools sometimes disable themselves for certain UAs. If you suspect a third-party SDK is misbehaving for a segment of users, spoofing that segment's UA in DevTools while watching the Network tab reveals what the SDK actually does.

Rate limiting and bot protection: Some WAF rules trigger differently based on UA. If users report getting blocked unexpectedly, reproducing their UA string in your test environment can help isolate whether the WAF rule is the culprit.

## Comparison of Methods

| Method | Setup Time | Persistence | Automation Support | Per-Domain Rules |
|--------|-----------|-------------|-------------------|-----------------|
| DevTools Network Conditions | Seconds | Session only | No | No |
| Launch flags | Minutes | Per launch | With scripts | No |
| Extensions (ModHeader, etc.) | Minutes | Persistent | No | Yes |
| Puppeteer/Playwright | Hours (first time) | In code | Yes | Yes (via routing) |

## Verification Techniques

After setting a custom user agent, verify it actually took effect:

1. Check with an external tool: Navigate to `https://httpbin.org/user-agent`. it returns JSON showing exactly what UA the server received.

2. Console check: In the Chrome console:

```javascript
console.log(navigator.userAgent);
```

3. Network tab inspection: Open DevTools, go to Network, reload the page, click any request, and look at the Request Headers. The `user-agent` header shows exactly what was sent.

4. Server-side logging: Add a log line to your backend that prints `req.headers['user-agent']`. This is the ground truth. it confirms the header arrived at your server, not just that the browser reported it locally.

## Common Pitfalls to Avoid

Navigator.userAgentData is not spoofed: Chrome 90+ introduced the User-Agent Client Hints API (`navigator.userAgentData`). Basic UA spoofing does not affect this API. Detection scripts that call `navigator.userAgentData.getHighEntropyValues()` will still see the real browser. Playwright can override this through `browser.newContext({ userAgentData: ... })` but it requires careful setup.

The UA does not change rendering behavior: Changing the user agent string does not make Chrome render pages like Firefox or Safari. CSS engine differences, JavaScript API availability, and font rendering all remain Chrome-specific. UA spoofing tests server-side logic and content delivery. not actual cross-browser rendering fidelity. For that, you need to run the actual browser.

Cached responses ignore UA changes: If your CDN or server caches responses without varying on the User-Agent header (missing `Vary: User-Agent`), you may get a cached response from the previous UA even after spoofing. Clear cache or use a cache-busting query parameter when testing UA-dependent content.

Extension conflicts: If you have both a UA switcher extension and are also setting a UA via DevTools Network Conditions, the behavior can be unpredictable depending on which one takes effect last. Use one method at a time to avoid confusion.

## Conclusion

Chrome provides multiple paths to spoof user agent strings, from quick DevTools emulation to programmatic automation with Puppeteer or Playwright. Choose the method matching your needs: quick visual testing, persistent sessions, or automated CI/CD pipelines.

For one-off debugging, the DevTools Network Conditions panel is the fastest option with zero setup. For team workflows where you need consistent test coverage across UA variants, a Playwright test suite that parameterizes over a list of user agents gives you repeatable, reviewable results. For persistent manual testing sessions, an extension like ModHeader with per-domain rules strikes the right balance between convenience and precision.

The key insight is that UA spoofing tests server and delivery logic. it does not substitute for running actual browsers. Use it as part of a broader cross-browser strategy, not as a replacement for it.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=spoof-user-agent-chrome)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [DuckDuckGo vs Chrome Privacy: A Developer & Power User Guide](/duckduckgo-vs-chrome-privacy/)
- [NordPass Chrome Review: A Developer and Power User's.](/nordpass-chrome-review/)
- [AI Calendar Assistant Chrome Extension: A Developer's Guide](/ai-calendar-assistant-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)




