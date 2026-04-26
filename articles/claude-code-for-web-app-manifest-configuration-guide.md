---

layout: default
title: "Configure Web App Manifest with Claude (2026)"
description: "Configure web app manifests for PWA projects using Claude Code. Icons, display modes, start URL, and installability settings with code examples."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-web-app-manifest-configuration-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
last_tested: "2026-04-21"
geo_optimized: true
---


Claude Code for Web App Manifest Configuration Guide

Web app manifests are the backbone of modern progressive web applications (PWAs) and define how your application behaves when installed on a user's device. When working with Claude Code, understanding how to properly configure these manifests ensures your AI-assisted projects are production-ready and installable. This guide walks you through the essential configurations, common pitfalls, and best practices for web app manifest files in Claude Code projects.

## Understanding Web App Manifests

A web app manifest is a JSON file that provides metadata about your web application. It controls how your app appears in the user's home screen, what icon to display, and how it should launch. Claude Code can help you generate, validate, and optimize these manifests as part of your development workflow.

The manifest file is typically named `manifest.json` and is linked from your HTML using a `<link>` tag in the `<head>` section:

```html
<link rel="manifest" href="/manifest.json">
```

Before diving into individual fields, it helps to understand what a complete, production-quality manifest looks like. Here is a full example that covers the most commonly required properties:

```json
{
 "name": "TaskMaster Pro",
 "short_name": "TaskMaster",
 "description": "A productivity app for managing tasks and projects.",
 "start_url": "/?source=pwa",
 "scope": "/",
 "display": "standalone",
 "orientation": "portrait-primary",
 "theme_color": "#2563eb",
 "background_color": "#ffffff",
 "categories": ["productivity", "utilities"],
 "lang": "en-US",
 "dir": "ltr",
 "icons": [
 {
 "src": "/icons/icon-72.png",
 "sizes": "72x72",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-96.png",
 "sizes": "96x96",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-128.png",
 "sizes": "128x128",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-144.png",
 "sizes": "144x144",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-152.png",
 "sizes": "152x152",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-192.png",
 "sizes": "192x192",
 "type": "image/png",
 "purpose": "any"
 },
 {
 "src": "/icons/icon-384.png",
 "sizes": "384x384",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-512.png",
 "sizes": "512x512",
 "type": "image/png",
 "purpose": "any maskable"
 }
 ],
 "screenshots": [
 {
 "src": "/screenshots/desktop.png",
 "sizes": "1280x800",
 "type": "image/png",
 "form_factor": "wide"
 },
 {
 "src": "/screenshots/mobile.png",
 "sizes": "390x844",
 "type": "image/png",
 "form_factor": "narrow"
 }
 ],
 "shortcuts": [
 {
 "name": "New Task",
 "short_name": "Add",
 "description": "Create a new task",
 "url": "/tasks/new",
 "icons": [{ "src": "/icons/add-96.png", "sizes": "96x96" }]
 }
 ]
}
```

You can ask Claude Code to generate this file from a single prompt: `Create a complete web app manifest for a productivity PWA named TaskMaster, using blue (#2563eb) as the primary color, with icon entries for all standard sizes and two app shortcuts.`

## Essential Manifest Fields

Every web app manifest should include these fundamental properties to function correctly:

name and short_name

The `name` field provides the full application name displayed during installation, while `short_name` appears on the user's home screen when there isn't enough space for the full name.

```json
{
 "name": "My Awesome PWA Application",
 "short_name": "AwesomeApp"
}
```

Keep `short_name` under 12 characters. Android launchers truncate labels differently depending on the device grid density, and labels longer than 12 characters are frequently cut off mid-word. Claude Code can generate appropriate name variations based on your project context, ensuring consistency across platforms.

icons

The `icons` array defines the visual identity of your installed app. You must provide at least a 192x192 pixel icon, though providing multiple sizes is recommended:

```json
{
 "icons": [
 {
 "src": "/icons/icon-192.png",
 "sizes": "192x192",
 "type": "image/png"
 },
 {
 "src": "/icons/icon-512.png",
 "sizes": "512x512",
 "type": "image/png",
 "purpose": "any maskable"
 }
 ]
}
```

The `purpose` field with `"maskable"` value ensures your icon looks good on all Android devices with rounded corners. A maskable icon must keep its key visual content within the central 80% of the image (the "safe zone"), because Android's adaptive icon system can crop the outer 20% in a circle, squircle, or other shape.

To generate all icon sizes automatically from a single source image, use a Node.js tool like `sharp`:

```javascript
const sharp = require('sharp');
const sizes = [72, 96, 128, 144, 152, 192, 384, 512];

async function generateIcons(sourceFile) {
 for (const size of sizes) {
 await sharp(sourceFile)
 .resize(size, size)
 .toFile(`./public/icons/icon-${size}.png`);
 console.log(`Generated ${size}x${size} icon`);
 }
}

generateIcons('./src/assets/logo.svg');
```

Ask Claude Code to scaffold this script with: `Write a Node.js script using sharp to resize a source SVG into all standard PWA icon sizes and output them to public/icons/`.

start_url and scope

The `start_url` specifies which page to load when the app launches, while `scope` defines the navigation scope:

```json
{
 "start_url": "/?source=pwa",
 "scope": "/"
}
```

Adding a query parameter like `?source=pwa` to `start_url` lets your analytics platform distinguish launches from the home screen icon versus the browser. Set `start_url` to `"."` to have the app launch from the same URL that the user installed it from, which is useful for tracking installation sources.

The `scope` field restricts which URLs are considered part of your app. If a user navigates outside the scope, the browser opens a regular tab. A common mistake is setting scope too narrowly. For example, if your app lives at `/app/`, your scope must be `/app/`, and setting it to `/` while `start_url` is `/app/` is valid but the reverse is not.

display

The `display` mode controls the browser chrome appearance:

```json
{
 "display": "standalone"
}
```

| Value | Browser UI | Best for |
|---|---|---|
| `fullscreen` | No browser UI at all | Games, immersive media |
| `standalone` | No address bar, has status bar | Most productivity and utility apps |
| `minimal-ui` | Back/forward and URL visible | Content apps where URL sharing matters |
| `browser` | Full browser UI | No installation intent; testing only |

For most production PWAs, `standalone` is the right default. It removes the address bar while keeping the system status bar, giving users a native-app feel without hiding the clock or battery indicator.

## Advanced Configuration Options

theme_color and background_color

These properties control the UI appearance during app loading and in task switchers:

```json
{
 "theme_color": "#1a73e8",
 "background_color": "#ffffff"
}
```

The `theme_color` tints the browser toolbar and the task-switcher header on Android. It should match the `<meta name="theme-color">` value in your HTML `<head>` so there is no color flash during navigation. The `background_color` fills the splash screen shown while the app's CSS is loading. choose your page background color so the transition is smooth.

You can support dark mode by also setting the meta theme-color in your HTML:

```html
<meta name="theme-color" content="#1a73e8" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0d47a1" media="(prefers-color-scheme: dark)">
```

Note that as of early 2026, the manifest `theme_color` property itself does not support media queries. only the meta tag does.

categories

The `categories` field helps app stores categorize your application:

```json
{
 "categories": ["productivity", "utilities"]
}
```

Use standard categories recognized by app stores to improve discoverability. The W3C spec lists a non-exhaustive set of recommended values including `books`, `business`, `education`, `entertainment`, `finance`, `fitness`, `food`, `games`, `government`, `health`, `kids`, `lifestyle`, `magazines`, `medical`, `music`, `navigation`, `news`, `personalization`, `photo`, `politics`, `productivity`, `security`, `shopping`, `social`, `sports`, `travel`, `utilities`, `weather`.

orientation

Specify the default screen orientation for your app:

```json
{
 "orientation": "portrait-primary"
}
```

| Value | Behavior |
|---|---|
| `any` | No lock; user can rotate freely |
| `natural` | Device default; portrait on phones, landscape on tablets |
| `portrait` | Portrait only (primary or secondary) |
| `portrait-primary` | Portrait only, locked to primary rotation |
| `landscape` | Landscape only (primary or secondary) |
| `landscape-primary` | Landscape only, locked to primary rotation |

Lock orientation only when your layout genuinely cannot function in both modes. Forcing portrait on a tablet frustrates users and can lead to negative reviews.

shortcuts

App shortcuts appear when a user long-presses your home screen icon and provide quick entry points into key actions:

```json
{
 "shortcuts": [
 {
 "name": "New Task",
 "short_name": "Add",
 "description": "Create a new task quickly",
 "url": "/tasks/new",
 "icons": [
 { "src": "/icons/shortcut-add-96.png", "sizes": "96x96" }
 ]
 },
 {
 "name": "Today's Tasks",
 "short_name": "Today",
 "description": "View tasks due today",
 "url": "/tasks?filter=today",
 "icons": [
 { "src": "/icons/shortcut-today-96.png", "sizes": "96x96" }
 ]
 }
 ]
}
```

Android supports up to four shortcuts. Prioritize the actions users perform most frequently. Each shortcut URL must be within the manifest `scope`.

screenshots

The `screenshots` array provides images used in app stores and install dialogs to preview your app before installation:

```json
{
 "screenshots": [
 {
 "src": "/screenshots/desktop-dashboard.png",
 "sizes": "1280x800",
 "type": "image/png",
 "form_factor": "wide",
 "label": "Dashboard view on desktop"
 },
 {
 "src": "/screenshots/mobile-tasks.png",
 "sizes": "390x844",
 "type": "image/png",
 "form_factor": "narrow",
 "label": "Task list on mobile"
 }
 ]
}
```

Use `form_factor: "wide"` for desktop screenshots and `form_factor: "narrow"` for mobile. Chrome on Android uses these in the enhanced install dialog to show users what the app looks like before they install it, which increases conversion rates.

## Working with Claude Code

Claude Code can assist you in several ways when configuring web app manifests:

## Generating Initial Manifests

Ask Claude Code to create a basic manifest by providing your project details:

```
Create a web app manifest for my React PWA with the name "TaskMaster",
using blue (#2563eb) as the theme color, include icon entries for all
standard sizes from 72x72 to 512x512, two app shortcuts for New Task
and Today's Tasks, and two screenshots for mobile and desktop.
```

Claude Code will produce a complete JSON file you can place at `public/manifest.json` immediately. From there you can refine specific fields rather than writing from scratch.

## Validating Manifests

Claude Code can review your manifest for common issues:

- Missing required fields
- Incorrect icon sizes
- Invalid URLs
- Inconsistent theme colors
- Icons referenced in shortcuts that fall outside the declared icon array
- Screenshots with mismatched `form_factor` and image dimensions

Paste your manifest and ask: `Review this web app manifest for missing fields, incorrect values, and any properties that would prevent Chrome from showing the install prompt.`

## Generating the Icon Build Script

Ask Claude Code to write an automated icon pipeline for your CI/CD process:

```
Write a Node.js script that reads a source PNG at src/logo.png, generates
all standard PWA icon sizes (72, 96, 128, 144, 152, 192, 384, 512), saves
them to public/icons/, and also creates a 512x512 maskable version with
10% white padding around the logo to ensure safe-zone compliance.
```

Claude Code will produce a ready-to-run script using `sharp` or `jimp`, saving significant manual effort.

## Dynamic Manifest Updates

For single-page applications, you might need to update manifest properties dynamically based on user preferences or runtime conditions:

```javascript
if ('serviceWorker' in navigator) {
 navigator.serviceWorker.register('/sw.js').then(() => {
 const manifest = {
 name: localStorage.getItem('appName') || 'My App',
 theme_color: localStorage.getItem('themeColor') || '#2563eb'
 };
 // Update manifest link
 const link = document.querySelector('link[rel="manifest"]');
 link.href = `data:application/json,${encodeURIComponent(JSON.stringify(manifest))}`;
 });
}
```

This technique is useful for white-label applications where tenant branding (colors, app name) differs per account. Note that dynamically injecting a data URI manifest is not fully supported in all browsers. test on iOS Safari and Firefox before relying on it in production.

## Manifest Validation with Workbox

If you are using Workbox for your service worker, Claude Code can help you integrate manifest validation into your build process:

```javascript
// In your build script
const { validateManifest } = require('./scripts/validate-manifest');

const manifest = require('./public/manifest.json');
const errors = validateManifest(manifest);

if (errors.length > 0) {
 console.error('Manifest validation failed:');
 errors.forEach(e => console.error(` - ${e}`));
 process.exit(1);
}
```

Ask Claude Code to write the `validateManifest` function that checks for all required fields, valid icon sizes, correct URL formats, and correct use of `purpose` values.

## Common Configuration Mistakes to Avoid

1. Missing Icon Files

Always ensure the icon files referenced in your manifest actually exist in your project. Broken icon references prevent PWA installation on most devices. Chrome's installability check specifically validates that the 192x192 and 512x512 icons are fetchable and return valid image data.

Add a CI step to verify all manifest icon paths exist:

```bash
node -e "
const fs = require('fs');
const path = require('path');
const manifest = require('./public/manifest.json');
manifest.icons.forEach(icon => {
 const filepath = path.join('public', icon.src);
 if (!fs.existsSync(filepath)) {
 console.error('Missing icon: ' + filepath);
 process.exit(1);
 }
});
console.log('All icons found.');
"
```

2. Incorrect Start URL

The `start_url` must be accessible and return valid content. Using relative paths like `"."` is safer than absolute paths that might change between environments. In staging environments, absolute URLs often point to production, causing your test installation to open the wrong site.

3. Scope Mismatches

The `scope` should include all pages that are part of your application. Pages outside the scope won't benefit from service worker caching and may break navigation. A common mistake is hosting the app at `/app/` but setting scope to `/`, which works but means the service worker intercepts requests for `/` (including your marketing site). an often-unintended consequence.

4. CORS Issues with Icons

If your icons are served from a CDN, ensure proper CORS headers are configured, or host icons locally to avoid installation failures. The manifest fetch itself must succeed with CORS, and each icon URL must be reachable. A CDN misconfiguration that blocks the manifest JSON will silently prevent installation without obvious error messages to end users.

5. Forgetting to Update icons When You Rebrand

Teams that rebrand often update their source logo but forget to regenerate the icon set referenced in the manifest. The old icon sits in the CDN cache, and users who already installed the PWA see the old branding indefinitely. Automate icon generation in your build pipeline so it is never a manual step.

6. Using the Wrong purpose Values

As of the current spec, valid `purpose` values are `any`, `maskable`, and `monochrome`. Some older guides recommend `"any maskable"` as a space-separated list (which is valid) but using only `"maskable"` for a non-maskable icon causes Android to crop the image incorrectly. Always test maskable icons using the [Maskable.app](https://maskable.app) tool before shipping.

## Testing Your Manifest

After creating your manifest, verify it works correctly:

1. Open Chrome DevTools and navigate to the Application tab
2. Click on Manifest to see all properties parsed correctly
3. Look for any warnings or errors in the Installability section
4. Use Lighthouse to run a full PWA audit (`npx lighthouse https://yourapp.com --view`)
5. Test the actual install prompt on a physical Android device, not just the DevTools emulator
6. On iOS, use Safari and check that the home screen icon and splash screen appear correctly

Claude Code can help you interpret these test results and suggest fixes for any issues found. Paste the Lighthouse PWA audit JSON output and ask: `Identify which manifest properties are causing the failing PWA checks and provide corrected JSON for each.`

## Automated Manifest Testing with Playwright

For CI pipelines, you can use Playwright to verify the manifest is served correctly on every deploy:

```javascript
// tests/manifest.spec.js
const { test, expect } = require('@playwright/test');

test('manifest is valid and installable', async ({ page }) => {
 await page.goto('/');

 // Verify manifest link exists
 const manifestHref = await page.$eval(
 'link[rel="manifest"]',
 el => el.href
 );
 expect(manifestHref).toBeTruthy();

 // Fetch and parse the manifest
 const response = await page.request.get(manifestHref);
 expect(response.status()).toBe(200);

 const manifest = await response.json();

 // Required fields
 expect(manifest.name).toBeTruthy();
 expect(manifest.short_name).toBeTruthy();
 expect(manifest.start_url).toBeTruthy();
 expect(manifest.display).toBe('standalone');

 // Icon requirements
 const has192 = manifest.icons.some(i => i.sizes === '192x192');
 const has512 = manifest.icons.some(i => i.sizes === '512x512');
 expect(has192).toBe(true);
 expect(has512).toBe(true);
});
```

Ask Claude Code to expand this test suite to also validate that every icon URL returns a 200 status and that color values are valid hex strings.

## Manifest Field Reference

Here is a quick-reference table of all manifest properties with their support status:

| Field | Required | Chrome | Firefox | Safari | Notes |
|---|---|---|---|---|---|
| `name` | Yes | Yes | Yes | Yes | Full app name |
| `short_name` | Recommended | Yes | Yes | Yes | Max ~12 chars |
| `start_url` | Yes | Yes | Yes | Partial | Include analytics param |
| `scope` | Recommended | Yes | Yes | No | Limits SW scope |
| `display` | Recommended | Yes | Yes | Partial | Use `standalone` |
| `theme_color` | Recommended | Yes | No | No | Toolbar tint |
| `background_color` | Recommended | Yes | Yes | No | Splash screen bg |
| `icons` | Yes | Yes | Yes | Yes | Min 192+512 |
| `categories` | Optional | Yes | No | No | App store hints |
| `orientation` | Optional | Yes | Yes | No | Lock rotation |
| `shortcuts` | Optional | Yes | No | No | Long-press menu |
| `screenshots` | Optional | Yes | No | No | Install dialog |
| `lang` | Recommended | Yes | Yes | Yes | BCP 47 language tag |

## Best Practices Summary

- Always provide both 192x192 and 512x512 icon sizes as a minimum
- Use maskable icons for Android compatibility, keeping content in the central 80% safe zone
- Set a meaningful `short_name` that fits on home screens (under 12 characters)
- Choose `display: standalone` for the native app feel
- Match `theme_color` to your primary brand color and sync it with the HTML meta tag
- Add a `?source=pwa` query parameter to `start_url` for analytics tracking
- Include app `shortcuts` for your two or three most-used actions
- Add `screenshots` to improve install dialog conversion rates
- Automate icon generation in your build pipeline to prevent stale icons after rebrands
- Test on real devices, not just emulators
- Run a Playwright test on every deploy to catch manifest regressions early
- Keep your manifest in version control alongside your source code

By following these guidelines and using Claude Code's assistance, you can create web app manifests that provide excellent user experiences and ensure your applications are installable across all major platforms.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-for-web-app-manifest-configuration-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Bolt.new Review: AI Web App Builder 2026](/bolt-new-review-ai-web-app-builder-2026/)
- [Claude Code for Bolt.new Web App Workflow Guide](/claude-code-for-bolt-new-web-app-workflow-guide/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

