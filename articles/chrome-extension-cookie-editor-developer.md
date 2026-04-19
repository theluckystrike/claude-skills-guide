---
layout: default
title: "Cookie Editor Developer Chrome Extension Guide (2026)"
description: "Master cookie manipulation in Chrome extensions. Practical code examples, API usage patterns, and security best practices for developers building."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-cookie-editor-developer/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
geo_optimized: true
---
Chrome extensions provide powerful capabilities for managing browser cookies, enabling developers to build sophisticated tools for session management, testing, and debugging. Understanding how to read, write, and delete cookies through the Chrome Extension API opens up numerous possibilities for automation and developer productivity.

This guide covers practical implementations for developers building cookie management features into Chrome extensions, from basic API usage to a complete popup editor with import/export support.

## Understanding the Chrome Cookies API

Chrome extensions interact with cookies through the `chrome.cookies` API, which provides methods for querying, setting, and removing cookies across all URLs. Unlike standard JavaScript cookie access, the cookies API works with HTTP-only cookies and can access cookies set on any domain.

The API is available in background service workers, content scripts (with limitations), and popup pages. It uses a callback-based interface that can be wrapped in Promises for cleaner async/await code, which is what all examples in this guide use.

## Manifest V3 vs Manifest V2

Most new extensions should target Manifest V3 (MV3), which Chrome now requires for new submissions to the Web Store. The cookies API works the same way in both versions, but the manifest structure differs:

```json
{
 "manifest_version": 3,
 "name": "Cookie Editor Extension",
 "version": "1.0",
 "permissions": [
 "cookies",
 "tabs",
 "activeTab"
 ],
 "host_permissions": [
 "<all_urls>"
 ],
 "background": {
 "service_worker": "background.js"
 },
 "action": {
 "default_popup": "popup.html"
 }
}
```

In MV2, `background` used `scripts` and `persistent`. In MV3, it uses a `service_worker`. The cookies API calls themselves are identical.

## Required Permissions

Before using the cookies API, you must declare the appropriate permissions in your extension's manifest:

```json
{
 "name": "Cookie Editor Extension",
 "version": "1.0",
 "permissions": [
 "cookies",
 "tabs"
 ],
 "host_permissions": [
 "<all_urls>"
 ]
}
```

The `cookies` permission allows API access, while `host_permissions` determines which domains your extension can access. Using `<all_urls>` grants access to all websites, but you can restrict this to specific domains for better security.

For a developer tool scoped to your own staging environments, use targeted host permissions:

```json
"host_permissions": [
 "https://*.myapp.dev/*",
 "https://*.myapp.com/*"
]
```

This minimizes the extension's footprint and makes it easier to pass Chrome Web Store review.

## Reading Cookies

Retrieving cookies for a specific URL requires the `chrome.cookies.get()` method:

```javascript
// Get a specific cookie by name
async function getCookie(url, name) {
 return new Promise((resolve) => {
 chrome.cookies.get({ url, name }, (cookie) => {
 resolve(cookie);
 });
 });
}

// Example usage
const sessionCookie = await getCookie('https://example.com', 'session_id');
console.log(sessionCookie.value);
```

For retrieving all cookies associated with a domain, use `chrome.cookies.getAll()`:

```javascript
async function getAllCookiesForDomain(domain) {
 return new Promise((resolve) => {
 chrome.cookies.getAll({ domain }, (cookies) => {
 resolve(cookies);
 });
 });
}

// Get all cookies for example.com
const cookies = await getAllCookiesForDomain('.example.com');
cookies.forEach(cookie => {
 console.log(`${cookie.name}: ${cookie.value}`);
});
```

The `getAll()` method accepts various filters including domain, name, path, secure, and session status. You can combine filters to narrow results:

```javascript
// Get only secure, non-session cookies for a domain
async function getSecurePersistentCookies(domain) {
 return new Promise((resolve) => {
 chrome.cookies.getAll({ domain, secure: true, session: false }, resolve);
 });
}
```

Note that `getAll()` with a `domain` filter uses a suffix match, it returns cookies for the exact domain and all subdomains. Pass `.example.com` to explicitly include subdomain cookies, or `example.com` (without the leading dot) to match only that exact domain.

## Setting Cookies

Creating or updating cookies uses `chrome.cookies.set()`:

```javascript
async function setCookie(url, name, value, options = {}) {
 const defaultOptions = {
 url: url,
 name: name,
 value: value,
 path: '/',
 secure: false,
 httpOnly: false,
 expirationDate: Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60) // 7 days
 };

 const cookieOptions = { ...defaultOptions, ...options };

 return new Promise((resolve) => {
 chrome.cookies.set(cookieOptions, (cookie) => {
 if (chrome.runtime.lastError) {
 console.error('Cookie set failed:', chrome.runtime.lastError);
 resolve(null);
 } else {
 resolve(cookie);
 }
 });
 });
}

// Set a session cookie
await setCookie('https://api.example.com', 'auth_token', 'abc123', {
 secure: true,
 httpOnly: true
});
```

When setting cookies, remember that Chrome automatically handles the domain property. If you omit it, Chrome derives the domain from the URL. For subdomain cookies, prefix the domain with a dot.

A common pattern in developer tools is duplicating a cookie from one environment to another, for example, copying a session token from production to staging:

```javascript
async function copyCookieToUrl(sourceCookie, targetUrl) {
 const { name, value, path, secure, httpOnly, sameSite, expirationDate } = sourceCookie;

 return setCookie(targetUrl, name, value, {
 path,
 secure,
 httpOnly,
 sameSite,
 expirationDate
 });
}
```

## Deleting Cookies

Removing cookies requires `chrome.cookies.remove()`:

```javascript
async function deleteCookie(url, name) {
 return new Promise((resolve) => {
 chrome.cookies.remove({ url, name }, (details) => {
 resolve(details);
 });
 });
}

// Delete a specific cookie
await deleteCookie('https://example.com', 'old_session');
```

To clear all cookies for a domain, iterate through all cookies and remove each one:

```javascript
async function clearAllCookiesForDomain(domain) {
 const cookies = await getAllCookiesForDomain(domain);

 for (const cookie of cookies) {
 const protocol = cookie.secure ? 'https:' : 'http:';
 const cookieUrl = `${protocol}//${cookie.domain}${cookie.path}`;
 await deleteCookie(cookieUrl, cookie.name);
 }
}
```

You can also add a result summary to know what was cleared:

```javascript
async function clearAllCookiesForDomain(domain) {
 const cookies = await getAllCookiesForDomain(domain);
 let cleared = 0;

 for (const cookie of cookies) {
 const protocol = cookie.secure ? 'https:' : 'http:';
 const cookieUrl = `${protocol}//${cookie.domain}${cookie.path}`;
 const result = await deleteCookie(cookieUrl, cookie.name);
 if (result) cleared++;
 }

 console.log(`Cleared ${cleared} of ${cookies.length} cookies for ${domain}`);
 return cleared;
}
```

## Cookie Attributes Explained

Understanding cookie attributes helps you manage cookies correctly:

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Cookie identifier |
| `value` | string | Cookie data |
| `domain` | string | Allowed domains (prefix with `.` for subdomains) |
| `path` | string | URL path scope (default `/`) |
| `secure` | boolean | HTTPS-only transmission |
| `httpOnly` | boolean | JavaScript access blocked |
| `sameSite` | string | Cross-site request policy |
| `expirationDate` | number | Unix timestamp for expiry (omit for session cookie) |
| `session` | boolean | Read-only; true if no expiration date |
| `storeId` | string | Cookie store identifier (useful for incognito tabs) |

The `sameSite` attribute accepts `'strict'`, `'lax'`, or `'no_restriction'`. Modern browsers default to `'lax'`, so explicitly setting this attribute ensures consistent behavior. Use `'strict'` for authentication cookies to prevent CSRF, and `'no_restriction'` (equivalent to `SameSite=None`) when you explicitly need cross-site cookies, which also requires `secure: true`.

## Listening for Cookie Changes

The `chrome.cookies.onChanged` event fires whenever any cookie is created, modified, or removed. This is useful for building reactive UIs that stay in sync with actual browser state:

```javascript
chrome.cookies.onChanged.addListener((changeInfo) => {
 const { cookie, removed, cause } = changeInfo;

 console.log(`Cookie ${removed ? 'removed' : 'set'}: ${cookie.name}`);
 console.log(`Cause: ${cause}`); // 'explicit', 'evicted', 'expired', 'overwrite'

 // Update your UI or trigger other logic
 if (cookie.domain.includes('myapp.com')) {
 refreshCookieDisplay();
 }
});
```

The `cause` field tells you why the change happened:
- `explicit`. the extension or a page deliberately set or removed the cookie
- `overwrite`. a new `set` call replaced an existing cookie
- `expired`. the browser expired the cookie
- `evicted`. the browser evicted it due to storage pressure
- `expired_overwrite`. a cookie was set with a past expiration to delete it

## Building a Cookie Editor Popup

A practical cookie editor extension includes a popup interface for viewing and editing cookies. Here is a complete example with add, edit, and delete functionality:

```javascript
// popup.js - Load and display cookies
document.addEventListener('DOMContentLoaded', async () => {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 const url = new URL(tab.url);

 const cookies = await new Promise((resolve) => {
 chrome.cookies.getAll({ domain: url.hostname }, resolve);
 });

 const cookieList = document.getElementById('cookie-list');
 cookies.forEach(cookie => {
 const row = document.createElement('div');
 row.className = 'cookie-row';
 row.innerHTML = `
 <span class="cookie-name">${cookie.name}</span>
 <span class="cookie-value">${cookie.value.substring(0, 20)}...</span>
 <button data-name="${cookie.name}" class="edit-btn">Edit</button>
 <button data-name="${cookie.name}" class="delete-btn">Delete</button>
 `;
 cookieList.appendChild(row);
 });

 // Handle deletion
 document.querySelectorAll('.delete-btn').forEach(btn => {
 btn.addEventListener('click', async (e) => {
 const name = e.target.dataset.name;
 await deleteCookie(url.href, name);
 location.reload();
 });
 });

 // Handle edit. populate the edit form
 document.querySelectorAll('.edit-btn').forEach(btn => {
 btn.addEventListener('click', (e) => {
 const name = e.target.dataset.name;
 const cookie = cookies.find(c => c.name === name);
 document.getElementById('edit-name').value = cookie.name;
 document.getElementById('edit-value').value = cookie.value;
 document.getElementById('edit-form').style.display = 'block';
 });
 });

 // Save edits
 document.getElementById('save-btn').addEventListener('click', async () => {
 const name = document.getElementById('edit-name').value;
 const value = document.getElementById('edit-value').value;
 await setCookie(url.href, name, value);
 location.reload();
 });
});
```

The corresponding HTML for the popup:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
 <meta charset="utf-8">
 <style>
 body { width: 400px; font-family: sans-serif; padding: 8px; }
 .cookie-row { display: flex; align-items: center; gap: 8px; margin: 4px 0; }
 .cookie-name { font-weight: bold; min-width: 120px; }
 .cookie-value { flex: 1; color: #555; overflow: hidden; text-overflow: ellipsis; }
 #edit-form { display: none; margin-top: 12px; border-top: 1px solid #ccc; padding-top: 12px; }
 input { width: 100%; margin-bottom: 8px; padding: 4px; }
 </style>
</head>
<body>
 <h3>Cookies</h3>
 <div id="cookie-list"></div>
 <div id="edit-form">
 <input id="edit-name" type="text" placeholder="Cookie name" readonly>
 <input id="edit-value" type="text" placeholder="Cookie value">
 <button id="save-btn">Save</button>
 </div>
 <script src="popup.js"></script>
</body>
</html>
```

## Exporting and Importing Cookies

A powerful feature for developer tools is the ability to export a full cookie set to JSON and re-import it later, useful for preserving authenticated sessions across environments or test runs:

```javascript
// Export all cookies for the current tab's domain
async function exportCookies(domain) {
 const cookies = await getAllCookiesForDomain(domain);
 const json = JSON.stringify(cookies, null, 2);

 // Trigger download
 const blob = new Blob([json], { type: 'application/json' });
 const url = URL.createObjectURL(blob);
 chrome.downloads.download({
 url,
 filename: `cookies_${domain}_${Date.now()}.json`
 });
}

// Import cookies from a JSON file
async function importCookies(targetUrl, cookieData) {
 const cookies = JSON.parse(cookieData);
 let imported = 0;

 for (const cookie of cookies) {
 const result = await setCookie(targetUrl, cookie.name, cookie.value, {
 path: cookie.path,
 secure: cookie.secure,
 httpOnly: cookie.httpOnly,
 sameSite: cookie.sameSite,
 expirationDate: cookie.expirationDate
 });
 if (result) imported++;
 }

 return imported;
}
```

Note that `chrome.downloads` requires adding `"downloads"` to your manifest permissions.

## Security Considerations

When building cookie management features, follow these security practices:

Minimum Permissions: Request only the host permissions your extension actually needs. Instead of `<all_urls>`, specify exact domains when possible. Chrome Web Store review scrutinizes extensions that request broad permissions, targeted permissions also improve user trust.

Secure Cookie Handling: When setting cookies for authentication, always use `secure: true` and `httpOnly: true` to prevent XSS attacks:

```javascript
await setCookie('https://example.com', 'session', token, {
 secure: true,
 httpOnly: true,
 sameSite: 'strict'
});
```

Validate Inputs: Always validate cookie names and values before setting them. Cookie names must not contain certain characters, and extremely long values can cause unexpected behavior:

```javascript
function isValidCookieName(name) {
 // Cookie names cannot contain whitespace, separators, or control characters
 return /^[a-zA-Z0-9_\-\.]+$/.test(name) && name.length < 4096;
}

function isValidCookieValue(value) {
 // Values should not contain semicolons, commas, or whitespace
 return !/[;\s,]/.test(value) && value.length < 4096;
}
```

Avoid Storing Sensitive Data: Your extension popup and background scripts are JavaScript running in the browser. Do not log cookie values containing authentication tokens to the console or send them to external servers. If your extension syncs data, use Chrome's storage API with `sync` scope carefully, it is not encrypted.

Content Security Policy: Add a strict CSP to your manifest to prevent injection attacks into the extension itself:

```json
"content_security_policy": {
 "extension_pages": "script-src 'self'; object-src 'none';"
}
```

## Common Use Cases for Developers

Chrome extension cookie manipulation serves various development scenarios:

- Session Testing: Quickly modify session cookies to test authentication flows without logging out and back in
- Environment Switching: Copy session cookies from staging to production (or vice versa) to test the same user state in different environments
- API Development: Set and refresh API tokens without manual browser login, especially useful when tokens expire frequently during development
- Cross-Domain Testing: Test cookie-based features across subdomains to verify domain and path scoping behavior
- Debugging Auth Issues: Inspect all cookie attributes (not just name and value) to diagnose SameSite, Secure, or HttpOnly misconfigurations
- Automated Testing: Use a background extension to inject test session cookies before each Playwright or Puppeteer test run
- Cookie Backup and Restore: Export cookies before a browser clear, then restore them to resume work without re-authenticating everywhere

## Debugging Cookie Operations

When cookie operations fail silently, check `chrome.runtime.lastError` immediately after any API call, Chrome clears it after each callback:

```javascript
chrome.cookies.set(options, (cookie) => {
 if (chrome.runtime.lastError) {
 console.error('Set failed:', chrome.runtime.lastError.message);
 // Common errors:
 // - "No host permissions for cookies at url"
 // - "Cookie 'name' could not be set at url"
 return;
 }
 console.log('Cookie set successfully:', cookie);
});
```

Common failure reasons:
- The URL is not covered by your `host_permissions`
- You're trying to set an `httpOnly` cookie from a content script (not allowed)
- The domain doesn't match the URL
- You're trying to set a `secure` cookie on an `http://` URL

Building a cookie editor extension requires understanding the Chrome cookies API, proper permission configuration, and security best practices. The methods covered here provide the foundation for creating powerful cookie management tools tailored to your development workflow.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-cookie-editor-developer)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Session Storage Editor: Complete.](/chrome-extension-session-storage-editor/)
- [AI Calendar Assistant Chrome Extension: A Developer's Guide](/ai-calendar-assistant-chrome-extension/)
- [AI Form Filler Chrome Extension: A Developer and Power.](/ai-form-filler-chrome-extension/)
- [PDF Editor Free Chrome Extension Guide (2026)](/chrome-extension-pdf-editor-free/)
- [SVG Editor Chrome Extension Guide (2026)](/chrome-extension-svg-editor/)
- [JSON Formatter Chrome Extension — Honest Review 2026](/json-formatter-chrome-extension-best/)
- [Claude AI Chrome Extension — Setup Guide (2026)](/claude-ai-chrome-extension/)
- [AI Presentation Maker Chrome Extension Guide (2026)](/ai-presentation-maker-chrome-extension/)
- [Latex Equation Editor Chrome Extension Guide (2026)](/chrome-extension-latex-equation-editor/)
- [Chrome Energy Saver Mode — Developer Guide (2026)](/chrome-energy-saver-mode/)
- [AI Headline Writer Chrome Extension Guide (2026)](/ai-headline-writer-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


