---
layout: default
title: "Chrome Devtools Network Throttling"
description: "Learn how to use Chrome DevTools network throttling to test your web applications under slow network conditions. Includes practical examples and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-devtools-network-throttling/
reviewed: true
score: 8
categories: [guides]
geo_optimized: true
---
# Chrome DevTools Network Throttling: Simulate Slow Connections for Better Apps

Network conditions vary wildly across the globe. Your application might load instantly on a fiber connection in New York but become unusable on a 3G network in a rural area. Chrome DevTools includes a powerful network throttling feature that lets you simulate various network conditions directly in your browser. This capability is essential for building resilient, user-friendly applications.

## Opening the Network Throttling Panel

To access network throttling in Chrome DevTools:

1. Open Chrome and navigate to your target website
2. Press `F12` or right-click and select Inspect to open DevTools
3. Click the Network tab
4. Look for the dropdown that says "No throttling". this is your throttling control

You'll find preset options including Fast 3G, Slow 3G, Fast 4G, and Offline. Selecting any of these immediately limits network requests to simulate that connection type.

## Understanding Network Presets

Chrome provides four built-in presets designed to match real-world conditions:

| Preset | Download | Upload | Latency |
|--------|----------|--------|---------|
| Fast 3G | 1.6 Mbps | 150 Kbps | 400 ms |
| Slow 3G | 400 Kbps | 50 Kbps | 400 ms |
| Fast 4G | 10 Mbps | 4 Mbps | 20 ms |
| Offline | 0 | 0 | 0 |

These presets give you a baseline for testing, but you often need more specific conditions.

## Creating Custom Throttling Profiles

The built-in presets work for quick tests, but custom profiles let you match specific scenarios. Chrome allows you to add custom network conditions through the DevTools settings.

To create a custom profile:

1. Click the gear icon () in the top-right of DevTools
2. Navigate to Throttling under the Devices section
3. Click Add custom profile
4. Configure your desired download speed, upload speed, and latency

Here's a practical example for simulating a typical satellite internet connection:

```
Download: 5 Mbps
Upload: 1 Mbps
Latency: 600 ms
```

This configuration helps you understand how your app behaves on high-latency connections where every request carries a significant delay.

## Testing API Calls with Throttling

When your application makes API requests, slow networks expose issues that fast connections hide. Here's how to identify common problems:

## Detecting Missing Loading States

Open your application with Slow 3G throttling enabled. Click through your app's key interactions. If users see blank screens or frozen interfaces while waiting for data, you need loading indicators.

A simple loading component in React might look like this:

```jsx
function UserProfile({ userId }) {
 const [user, setUser] = useState(null);
 const [loading, setLoading] = useState(true);

 useEffect(() => {
 fetch(`/api/users/${userId}`)
 .then(res => res.json())
 .then(data => {
 setUser(data);
 setLoading(false);
 });
 }, [userId]);

 if (loading) {
 return <Spinner aria-label="Loading user data..." />;
 }

 return <ProfileCard user={user} />;
}
```

With throttling enabled, this loading state becomes visible and testable.

## Finding Unoptimized Images

Slow networks reveal image loading problems quickly. Enable throttling and navigate through pages with images. Watch for:

- Layout shifts as images load
- Images that are too large for the viewport
- Missing `srcset` attributes forcing full-resolution downloads

Use Chrome's Network tab to sort by size and identify the heaviest requests. Then optimize accordingly.

## Catching Timeout Issues

API requests that work fine on fast connections might timeout on slow networks. Check your fetch requests:

```javascript
// Default fetch has no timeout - it will wait indefinitely
const response = await fetch('/api/data');

// Add AbortController for timeout handling
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 10000);

try {
 const response = await fetch('/api/data', {
 signal: controller.signal
 });
 const data = await response.json();
 clearTimeout(timeoutId);
 return data;
} catch (error) {
 if (error.name === 'AbortError') {
 console.log('Request timed out - show retry option');
 }
 throw error;
}
```

This pattern gives users a clear way to recover from failed requests.

## Throttling and Performance Budgets

Network throttling pairs well with performance budgets. Set a performance budget in Lighthouse and run tests with throttling enabled:

```javascript
// lighthouse.config.js
module.exports = {
 passes: [{
 passName: 'defaultPass',
 network: {
 throttling: {
 download: 1600 * 1024 / 8, // 1.6 Mbps
 upload: 150 * 1024 / 8, // 150 Kbps
 latency: 400 // 400ms
 }
 }
 }],
 budgets: [
 {
 resourceSizes: [
 { resourceType: 'total', budget: 500 },
 { resourceType: 'script', budget: 200 },
 { resourceType: 'image', budget: 150 }
 ]
 }
 ]
};
```

Running Lighthouse with these settings ensures your app meets performance targets on constrained networks.

## Automating Throttling with Puppeteer

For continuous integration, you can programmatically apply throttling using Puppeteer:

```javascript
const puppeteer = require('puppeteer');

(async () => {
 const browser = await puppeteer.launch();
 const page = await browser.newPage();

 // Set custom throttling
 const client = await page.target().createCDPSession();
 await client.send('Network.emulateNetworkConditions', {
 offline: false,
 downloadThroughput: 400 * 1024 / 8, // 400 Kbps
 uploadThroughput: 50 * 1024 / 8, // 50 Kbps
 latency: 400 // 400ms
 });

 await page.goto('https://your-app.com');
 // Run your tests...

 await browser.close();
})();
```

This approach integrates throttling into your automated test suite, catching performance regressions before they reach production.

## Common Throttling Mistakes to Avoid

A few pitfalls trip up developers when using network throttling:

Testing only on fast networks. Always verify your app works on the slowest connection your users might have.

Forgetting to disable throttling. Leaving throttling enabled after testing leads to confusing behavior during normal development.

Ignoring latency. Download speed matters, but latency affects how quickly each request starts. Slow 3G's 400ms latency makes each API call feel sluggish regardless of the data size.

Testing in isolation. Network conditions affect everything simultaneously. Test complete user flows, not just individual components.

## Real-World Application

Consider a checkout flow in an e-commerce application. With fast 4G, a user clicks through in seconds. Enable Slow 3G and you might discover:

- The payment form times out before submitting
- Loading states appear too late
- Progress indicators freeze mid-process
- Large product images block the final confirmation step

These are the issues that lose customers in production. Finding them early saves support tickets and improves conversion rates.

## Summary

Chrome DevTools network throttling is a practical tool for building applications that work well for everyone, regardless of their connection speed. By simulating slow networks during development, you catch real-world problems before your users encounter them. Start with the built-in presets, create custom profiles for specific scenarios, and integrate throttling into your automated testing pipeline.

Your users on slow connections will thank you.

Built by the luckystrike. More at [zovo.one](https://zovo.one)

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-devtools-network-throttling)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Angular DevTools Chrome Extension Setup: A Complete Guide](/angular-devtools-chrome-extension-setup/)
- [Axe DevTools Chrome Extension Guide: Automated.](/axe-devtools-chrome-extension-guide/)
- [Chrome Autofill Slow: Causes and Solutions for Developers](/chrome-autofill-slow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


