---
layout: default
title: "Permissions Explained Chrome Extension"
description: "Claude Code extension tip: learn how Chrome extension permissions work, what each permission means, and how to manage them safely. Essential guide for..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-permissions-explained/
reviewed: true
score: 8
categories: [tutorials]
tags: [chrome, extensions, security, browser]
geo_optimized: true
---
# Chrome Extension Permissions Explained: A Developer's Guide

Chrome extensions add powerful functionality to your browser, but every extension needs specific permissions to work. Understanding these permissions helps you make informed decisions about what you install and how extensions interact with your data.

This guide breaks down Chrome extension permissions, explains what each one means, and shows you how to review and manage them effectively, whether you are a developer designing an extension from scratch or a power user deciding what to install.

What Are Chrome Extension Permissions?

When you install a Chrome extension, it requests permission to access certain browser features or data. These permissions are defined in the extension's manifest file (manifest.json) and determine what the extension can read or modify.

Think of permissions as a security gate, each one represents a specific capability the extension needs. The more permissions an extension requests, the more access it has to your browsing data. Chrome's permission model is intentionally explicit: extensions cannot access capabilities they have not declared in their manifest, and for many sensitive permissions, users see a prompt before granting access.

The manifest file serves as the contract between the extension and the browser. Here is what a minimal but realistic manifest looks like for a Manifest V3 extension:

```json
{
 "manifest_version": 3,
 "name": "Page Word Counter",
 "version": "1.0",
 "description": "Counts words on the current page.",
 "permissions": ["storage", "contextMenus"],
 "host_permissions": ["<all_urls>"],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html"
 }
}
```

Every permission listed in that manifest was a deliberate choice with a security tradeoff. Understanding those tradeoffs is what this guide is about.

## Common Permission Types and What They Mean

## Host Permissions

Host permissions allow extensions to access content on specific websites or all websites:

```json
{
 "host_permissions": [
 "https://*.google.com/*",
 "<all_urls>"
 ]
}
```

- Specific domains (like `https://*.google.com/*`): The extension can only access pages on those domains
- All URLs (`<all_urls>`): The extension can read and modify content on every website you visit. This is the most powerful permission.

Extensions with host permissions can:
- Read the content of web pages
- Modify page content
- Capture form data
- Read cookies and session data

The scope of host permissions deserves emphasis. An extension with `<all_urls>` access and a content script that runs on every page has the technical ability to read every form field you type into, including passwords, credit card numbers, and authentication tokens, before the data is encrypted and sent. Most extensions with broad host permissions are not doing anything malicious, but the permission grants the capability whether or not the developer uses it.

For developers, the best practice is to be as specific as possible. If your extension only needs to work on GitHub, declare `https://github.com/*` rather than `<all_urls>`. Users see what sites you are accessing, and a narrower scope builds trust.

## API Permissions

These permissions grant access to specific Chrome APIs:

| Permission | What It Allows |
|------------|----------------|
| `tabs` | Access browser tab information, create/close tabs |
| `storage` | Store data locally or sync with your Google account |
| `cookies` | Read and modify cookies for any site |
| `history` | Read and modify browsing history |
| `bookmarks` | Read and modify your bookmarks |
| `downloads` | Manage file downloads |
| `notifications` | Display desktop notifications |
| `contextMenus` | Add items to right-click menu |
| `webRequest` | Intercept or modify network requests |
| `declarativeNetRequest` | Block or modify network requests (safer than webRequest) |

A few of these deserve expanded explanation:

`tabs`: Sounds benign but exposes more than tab management. With `tabs`, an extension can read the URL and title of every tab you have open, even tabs on sites it does not have host permission for. A tab with a sensitive document title or URL in a corporate environment could expose information the developer did not intend to share.

`webRequest`: The legacy network interception API (deprecated in Manifest V3 for most use cases). Extensions using this permission can see the full contents of every network request and response going through your browser, including API keys sent in headers, authentication tokens, and raw response data. This is why ad blockers were historically powerful, and why this permission is high-risk in untrusted extensions.

`declarativeNetRequest`: The Manifest V3 replacement for `webRequest`. Instead of letting the extension see and modify traffic directly, you declare a ruleset of what to block or redirect. The browser engine applies the rules without giving the extension access to the actual request contents. It is meaningfully safer, which is why the Chrome team pushed for this migration.

`cookies`: Read and modify cookies for any site. This includes session cookies that authenticate you to web applications. An extension with cookie access and `<all_urls>` host permission can read your session cookies and, in theory, use them to access your accounts.

## The Tabs Permission Nuance

The `tabs` permission interacts with host permissions in a way that surprises many developers. Without host permissions, `tabs` gives you access to tab IDs but not to the URL or title of those tabs. With host permissions added, those fields become readable for matching hosts. This means you sometimes see extensions that appear to only need `tabs` but also request `<all_urls>` host permissions, the combined set enables them to see the URLs of every open tab.

```javascript
// With tabs permission but no host permissions:
chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
 console.log(tabs[0].url); // Returns undefined or empty
});

// With tabs permission AND matching host_permissions:
chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
 console.log(tabs[0].url); // Returns the actual URL
});
```

## Manifest V2 vs. Manifest V3: Permissions Changes

If you are maintaining an older extension or evaluating one, understanding the MV2 to MV3 migration matters. The key permission changes:

| Feature | Manifest V2 | Manifest V3 |
|---|---|---|
| Background pages | Persistent background pages | Service workers (ephemeral) |
| Network interception | `webRequest` (read + modify) | `declarativeNetRequest` (rules only) |
| Remote code execution | Allowed | Blocked |
| Content Security Policy | Less strict | Stricter defaults |
| `blocking` webRequest | Allowed | Blocked (only observing allowed) |

Extensions still on MV2 are being phased out. Chrome began showing warnings for MV2 extensions in 2024 and started disabling them in 2025 for Enterprise users with a grace period. If you see an extension warning in Chrome about the manifest version, that is why.

For users: an MV2 extension requesting `webRequest` with blocking capability had significantly more power over your browser traffic than the MV3 equivalent. The migration is a genuine security improvement, not just a platform change.

## How to Check Extension Permissions

## Before Installing

1. Visit the extension's Chrome Web Store page
2. Look for the "Permissions" section on the right side
3. Review what data the extension can access

The Chrome Web Store does not always show the full permission list in the visible UI, some permissions are disclosed only in the privacy practices section or within the extension's own privacy policy link. For a complete view, look at the extension's source code if it is available on GitHub, or use the extension's manifest directly.

## After Installation

1. Click the puzzle piece icon in Chrome's toolbar
2. Click the three dots next to any extension
3. Select "Manage extension"
4. Review permissions under "Permissions" tab

You can also navigate directly to `chrome://extensions` and click "Details" on any installed extension. The details page shows declared permissions in plain language, site access level, and whether the extension can run in Incognito mode.

## Using Chrome's Safety Check

Chrome's built-in Safety Check (Settings > Privacy and security > Safety Check) can identify harmful extensions. Run it regularly to stay secure.

## Inspecting the Raw Manifest

For a developer-level view, you can read the extension's manifest directly from your filesystem. On macOS, installed extensions live at:

```
~/Library/Application Support/Google/Chrome/Default/Extensions/
```

Each extension has its own directory named by its extension ID. Inside you will find versioned subdirectories with the manifest.json:

```bash
Find all installed extension manifests
find ~/Library/Application\ Support/Google/Chrome/Default/Extensions/ \
 -name "manifest.json" -maxdepth 3
```

Reading the raw manifest shows you exactly what the extension declared, with no UI abstraction in the way. Pay particular attention to `content_scripts` entries, these define when and where JavaScript runs in page context:

```json
{
 "content_scripts": [
 {
 "matches": ["<all_urls>"],
 "js": ["content.js"],
 "run_at": "document_start"
 }
 ]
}
```

`run_at: "document_start"` means the script executes before any page content loads, this is the most powerful timing, giving the script access to the page before any user interaction or data entry has occurred.

## Permission Categories by Risk Level

## Low Risk Permissions

These permissions generally don't expose sensitive data:

- `alarms` - Schedule tasks
- `idle` - Detect when your computer is idle
- `unlimitedStorage` - Store large amounts of data locally
- `power` - Keep your system awake
- `notifications` - Display desktop notifications
- `contextMenus` - Add items to right-click context menu

Low-risk permissions typically interact with browser features in isolation, scheduling tasks or showing notifications does not require reading your data.

## Medium Risk Permissions

These can access some user data but are commonly needed:

- `tabs` - Access tab titles and URLs
- `bookmarks` - Read your bookmarks
- `downloads` - Manage downloads
- `contextMenus` - Add menu items

Medium-risk permissions expose data that is less sensitive in isolation, your bookmarks and download history reveal browsing habits but are less immediately exploitable than authentication data. That said, an extension that harvests your bookmarks and sends them to a remote server is still a meaningful privacy violation.

## High Risk Permissions

These provide extensive access and warrant extra scrutiny:

- `<all_urls>` - Access all website content
- `cookies` - Access authentication sessions
- `history` - Read browsing history
- `webRequest` - Intercept network traffic
- `nativeMessaging` - Communicate with native applications installed on your system

The `nativeMessaging` permission deserves particular attention, it allows an extension to communicate with a native application on your computer, bypassing the browser sandbox entirely. A malicious extension with `nativeMessaging` and a corresponding native host installed could execute arbitrary code on your system.

## Risk Assessment Matrix

| Permission | Data Exposed | Reversible If Abused | Justifiable For |
|---|---|---|---|
| `<all_urls>` host | All page content, form data | No | Productivity tools, ad blockers |
| `cookies` | Auth sessions | Partially (logout + re-auth) | SSO tools, cookie managers |
| `history` | Full browsing history | No | History search tools |
| `webRequest` | Network traffic contents | No | Security monitoring |
| `nativeMessaging` | System access | No | Desktop integration tools |
| `tabs` | Tab URLs and titles | Yes | Tab managers |
| `storage` | Extension-stored data only | Yes | Most extensions |
| `notifications` | No user data read | Yes | Alert and reminder tools |

## Best Practices for Developers

## Request Minimal Permissions

Only ask for permissions your extension actually needs:

```json
{
 "permissions": ["storage", "contextMenus"],
 "host_permissions": ["https://yourdomain.com/*"]
}
```

Chrome Web Store reviewers flag extensions that request permissions beyond what the functionality justifies. More importantly, users who see a narrow permission set are more likely to trust and install your extension. Every unnecessary permission is a reason for a potential user to abandon the install.

A practical approach: implement the extension first with minimal permissions, then add permissions only when you actually write the code that needs them. This prevents the common pattern of cargo-culting permissions from other extensions' manifests.

## Use Optional Permissions

Split required and optional permissions:

```json
{
 "permissions": ["storage"],
 "optional_permissions": ["bookmarks", "history"]
}
```

This lets users install your extension without granting every permission upfront. You then request optional permissions programmatically when the user specifically invokes a feature that needs them:

```javascript
document.getElementById('enable-history-sync').addEventListener('click', () => {
 chrome.permissions.request(
 { permissions: ['history'] },
 (granted) => {
 if (granted) {
 startHistorySync();
 } else {
 showPermissionDeniedMessage();
 }
 }
 );
});
```

This pattern aligns permission grants with user intent, the user asked for history sync, Chrome prompts for the history permission, the connection between the feature and the permission is obvious. Compare that to requesting history permission at install time with no context, and it is clear why optional permissions improve both trust and conversion rates.

## Explain Why You Need Each Permission

Add a permission rationale in your extension's description:

> "This extension needs access to tabs to display the current page's information in the popup."

For extensions submitted to the Chrome Web Store, the policy now requires a privacy disclosure for extensions that handle user data. But even for permissions that do not technically require disclosure, explaining your permission usage in the store listing builds user confidence and reduces support questions about why you need certain access.

## Use Declarative Net Request Instead of WebRequest

For network filtering, use `declarativeNetRequest` instead of `webRequest`, it doesn't require access to read request content:

```json
{
 "permissions": ["declarativeNetRequest"],
 "host_permissions": ["<all_urls>"]
}
```

With `declarativeNetRequest`, you define your filtering rules as a static JSON ruleset:

```json
[
 {
 "id": 1,
 "priority": 1,
 "action": { "type": "block" },
 "condition": {
 "urlFilter": "||ads.example.com^",
 "resourceTypes": ["script", "image", "xmlhttprequest"]
 }
 }
]
```

The browser applies these rules without your extension ever seeing the actual request data. For ad blockers, tracker blockers, and content filters, this covers the vast majority of use cases with a substantially smaller attack surface.

## How to Revoke Permissions

## Method 1: Extension Settings

1. Go to `chrome://extensions`
2. Find the extension
3. Click "Details"
4. Under "Permissions," click "Remove" next to any permission

not all permissions can be individually revoked from this UI. Some are all-or-nothing, you either have the extension installed with its declared permissions or you do not.

## Method 2: Manage Site Access

Chrome lets you control which sites an extension can access on a per-site basis, even if the extension declared `<all_urls>`:

1. Click the puzzle piece icon in the toolbar
2. Click the pin or settings icon next to the extension
3. Choose "On click," "On [specific site]," or "On all sites"

The "On click" option is particularly useful for powerful extensions you trust but want to use deliberately rather than have running passively on every page.

## Method 3: Disable Problematic Extensions

If an extension behaves suspiciously, disable it entirely:
- Go to `chrome://extensions`
- Toggle off the extension

Disabling rather than removing lets you preserve the extension's stored data in case you decide to re-enable it after investigation. If you determine the extension is definitively problematic, remove it entirely.

## Method 4: Use Incognito Mode

Extensions don't run in Incognito by default. Only enable trusted extensions for Incognito when necessary.

To check which extensions are allowed in Incognito: go to `chrome://extensions`, click Details on any extension, and look for the "Allow in Incognito" toggle. Be conservative here, an extension with broad permissions running in Incognito can read browsing that you specifically chose to do in a private session.

## Signs of Problematic Extensions

Watch for these red flags:

- Requesting more permissions than their functionality suggests
- Poor reviews mentioning data privacy
- Developer doesn't have a verifiable website
- Extension was just published with few reviews
- Requests access to "all data on all websites" unnecessarily

Additional signals worth checking:

- Updates that add new permissions: A legitimate extension should not suddenly need new sensitive permissions after months of use. If Chrome prompts you to approve new permissions for an existing extension, read carefully before accepting.
- Obfuscated JavaScript: While minification is normal, heavily obfuscated code in an open-source or consumer extension is a warning sign. Legitimate extensions generally do not need to hide what they are doing.
- Remote code loading: MV3 blocks this, but for MV2 extensions or side-loaded extensions, check if the background script fetches and executes code from a remote URL. This lets the extension's behavior change after install without triggering another review.
- Mismatch between description and permissions: A currency converter that requests `history`, `cookies`, and `webRequest` has no obvious reason for that access. The gap between stated functionality and requested permissions is the clearest signal.

## The Bottom Line

Chrome extension permissions exist to protect your privacy and security. As a developer, request only what you need and explain why. As a user, review permissions before installing and regularly audit your extensions.

For developers, the discipline of minimal permissions pays dividends beyond security: it makes your extension easier to review, easier to reason about, and more likely to pass Chrome Web Store review without back-and-forth. An extension that does exactly what it says with exactly the access it needs is the goal.

For users, the most actionable habit is checking permissions at install time rather than after. Once an extension is installed and you have been using it for months, the mental barrier to removing it is much higher. A few seconds of review before clicking "Add to Chrome" is the most effective filter you have.

A good rule of thumb: if an extension requests access to "all data on all websites" but doesn't need that for its core function, look for an alternative that requests less.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-extension-permissions-explained)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for Go Fuzz Workflow Tutorial Guide](/claude-code-for-go-fuzz-workflow-tutorial-guide/)
- [Claude Code for Mythril Workflow Tutorial](/claude-code-for-mythril-workflow-tutorial/)
- [Claude Code for OSS Security Policy Workflow Tutorial](/claude-code-for-oss-security-policy-workflow-tutorial/)

Built by theluckystrike. More at https://zovo.one


