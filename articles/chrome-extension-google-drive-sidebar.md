---
render_with_liquid: false
layout: default
title: "Google Drive Sidebar Chrome Extension"
description: "Build a Chrome extension with Google Drive sidebar integration for file browsing, search, and quick access. Drive API auth and manifest config included."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: theluckystrike
permalink: /chrome-extension-google-drive-sidebar/
categories: [guides]
tags: [chrome-extension, google-drive, sidebar, developer-tools, productivity, api]
reviewed: true
score: 8
geo_optimized: true
---
# Chrome Extension Google Drive Sidebar: Build Your Own

A Google Drive sidebar in your Chrome extension opens up powerful productivity possibilities. You can let users browse their Drive files, preview documents, or attach files from Drive without leaving their current tab. This guide walks you through building this functionality from scratch.

## Understanding the Architecture

A Chrome extension with a Drive sidebar combines several components. The sidebar panel displays in the host page using a content script or declarative net request. The background service worker handles API communication with Google. OAuth 2.0 authentication grants access to the user's Drive data. The Drive API provides file listing, metadata, and content retrieval.

Chrome's side panel API, introduced in Manifest V3, makes this significantly easier than the old approach of injecting iframes. You can now create a dedicated sidebar that persists across page navigations within a domain.

## Setting Up the Manifest

Your extension needs proper permissions to access Google Drive and display a side panel. Here's a complete manifest configuration:

```json
{
 "manifest_version": 3,
 "name": "Drive File Browser",
 "version": "1.0.0",
 "description": "Browse and attach Google Drive files from a sidebar",
 "permissions": [
 "sidePanel",
 "storage",
 "identity"
 ],
 "host_permissions": [
 "https://drive.google.com/*",
 "https://www.googleapis.com/*"
 ],
 "action": {
 "default_title": "Open Drive Sidebar"
 },
 "side_panel": {
 "default_path": "sidepanel.html"
 },
 "background": {
 "service_worker": "background.js"
 },
 "oauth2": {
 "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
 "scopes": [
 "https://www.googleapis.com/auth/drive.readonly"
 ]
 }
}
```

The `side_panel` key tells Chrome this extension provides a side panel experience. The OAuth 2.0 configuration enables identity verification without exposing credentials.

## Implementing OAuth Authentication

Google requires OAuth 2.0 for Drive API access. The Chrome identity API simplifies this process significantly:

```javascript
// background.js - Authentication handler
chrome.identity.getAuthToken({ interactive: true }, (token) => {
 if (chrome.runtime.lastError) {
 console.error('Auth error:', chrome.runtime.lastError);
 return;
 }
 console.log('Got access token:', token.substring(0, 20) + '...');
 // Store token for API calls
 chrome.storage.local.set({ driveToken: token });
});
```

This triggers Google's consent flow. Users see a popup asking for permission to access their Drive files. Once granted, you receive a token valid for one hour. Implement token refresh for longer sessions:

```javascript
// Refresh expired tokens
async function refreshToken() {
 const response = await fetch('https://oauth2.googleapis.com/token', {
 method: 'POST',
 headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
 body: new URLSearchParams({
 client_id: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
 refresh_token: storedRefreshToken,
 grant_type: 'refresh_token'
 })
 });
 const data = await response.json();
 return data.access_token;
}
```

## Querying the Drive API

With authentication working, you can fetch files, folders, and metadata. The Drive v3 API uses a RESTful approach with JSON responses:

```javascript
// List files from user's Drive
async function listDriveFiles(token, query = '') {
 const params = new URLSearchParams({
 q: query || "trashed=false",
 fields: 'files(id,name,mimeType,modifiedTime,thumbnailLink)',
 pageSize: 50,
 orderBy: 'modifiedTime desc'
 });

 const response = await fetch(
 `https://www.googleapis.com/drive/v3/files?${params}`,
 {
 headers: { Authorization: `Bearer ${token}` }
 }
 );

 if (!response.ok) {
 throw new Error(`API error: ${response.status}`);
 }

 const data = await response.json();
 return data.files;
}
```

Filter files by type using MIME types. For folders, use `mimeType = 'application/vnd.google-apps.folder'`. For Google Docs, use `mimeType contains 'vnd.google-apps'`. The API returns native links that you can convert to preview URLs.

## Building the Sidebar UI

The side panel HTML serves as your sidebar interface. Keep it lightweight since it loads in every matching tab:

```html
<!-- sidepanel.html -->
<!DOCTYPE html>
<html>
<head>
 <style>
 * { box-sizing: border-box; }
 body {
 width: 320px;
 padding: 12px;
 font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
 margin: 0;
 }
 .search-box {
 width: 100%;
 padding: 8px 12px;
 border: 1px solid #ddd;
 border-radius: 6px;
 margin-bottom: 12px;
 }
 .file-list {
 list-style: none;
 padding: 0;
 margin: 0;
 }
 .file-item {
 padding: 10px;
 border-bottom: 1px solid #eee;
 cursor: pointer;
 display: flex;
 align-items: center;
 gap: 8px;
 }
 .file-item:hover { background: #f5f5f5; }
 .file-icon { width: 24px; height: 24px; }
 .file-name { flex: 1; overflow: hidden; text-overflow: ellipsis; }
 </style>
</head>
<body>
 <input type="text" class="search-box" placeholder="Search Drive files..." id="search">
 <ul class="file-list" id="fileList"></ul>
 <script src="sidepanel.js"></script>
</body>
</html>
```

## Connecting the Sidebar to Your Logic

The side panel JavaScript handles user interaction and API communication:

```javascript
// sidepanel.js
document.addEventListener('DOMContentLoaded', async () => {
 const fileList = document.getElementById('fileList');
 const searchInput = document.getElementById('search');

 // Load stored token
 const { driveToken } = await chrome.storage.local.get('driveToken');
 
 if (!driveToken) {
 fileList.innerHTML = '<li class="file-item">Please sign in first</li>';
 return;
 }

 // Fetch and render files
 async function loadFiles(query = '') {
 try {
 const files = await listDriveFiles(driveToken, query);
 renderFiles(files);
 } catch (err) {
 fileList.innerHTML = `<li class="file-item">Error: ${err.message}</li>`;
 }
 }

 function renderFiles(files) {
 fileList.innerHTML = files.map(file => `
 <li class="file-item" data-id="${file.id}" data-name="${file.name}">
 <img class="file-icon" src="${file.thumbnailLink || 'default-icon.png'}" alt="">
 <span class="file-name">${file.name}</span>
 </li>
 `).join('');
 }

 // Handle file clicks
 fileList.addEventListener('click', (e) => {
 const item = e.target.closest('.file-item');
 if (item) {
 const fileId = item.dataset.id;
 const fileName = item.dataset.name;
 // Send to content script or background
 chrome.runtime.sendMessage({
 action: 'fileSelected',
 fileId,
 fileName
 });
 }
 });

 // Search debounce
 let debounceTimer;
 searchInput.addEventListener('input', () => {
 clearTimeout(debounceTimer);
 debounceTimer = setTimeout(() => {
 const query = searchInput.value 
 ? `name contains '${searchInput.value}'` 
 : '';
 loadFiles(query);
 }, 300);
 });

 // Initial load
 loadFiles();
});
```

## Enabling the Sidebar Toggle

Users need a way to open and close your sidebar. The sidePanel API provides this:

```javascript
// background.js - Toggle sidebar on action click
chrome.sidePanel.setOptions({
 path: 'sidepanel.html',
 enabled: true
});

chrome.action.onClicked.addListener(async (tab) => {
 // Check if side panel is already open
 const { id } = tab;
 try {
 await chrome.sidePanel.open({ tabId: id });
 } catch (err) {
 console.error('Failed to open side panel:', err);
 }
});
```

This opens the sidebar when users click your extension icon. You can also programmatically open it based on page conditions or keyboard shortcuts.

## Practical Use Cases

A Drive sidebar extension serves multiple workflows. Support teams can pull knowledge base documents while browsing helpdesk tickets. Developers can reference Drive-stored API docs alongside code. Content creators can attach Drive assets to CMS entries without tab switching.

For deeper integration, consider implementing file upload from the sidebar, folder tree navigation, or direct sharing capabilities. Each adds value but increases complexity, start simple and iterate based on user feedback.

## Step-by-Step: Building the Drive Sidebar

1. Request OAuth2 access: add `identity` to your manifest permissions and call `chrome.identity.getAuthToken({ interactive: true })` to get a Google OAuth2 token scoped to `https://www.googleapis.com/auth/drive.readonly` (or `.file` for write access).
2. List recent files: call `GET https://www.googleapis.com/drive/v3/files?orderBy=modifiedTime desc&pageSize=20&fields=files(id,name,mimeType,webViewLink,modifiedTime)` using the token in the `Authorization` header.
3. Inject the sidebar: use a content script to append a fixed-position sidebar `<div>` to the right side of the page on domains the user specifies (e.g., their company's Jira or project management tool).
4. Render the file list: display file name, type icon, and last-modified date. Make each entry a link that opens the Drive file in a new tab.
5. Add search: call `GET https://www.googleapis.com/drive/v3/files?q=name contains 'query'` to search Drive without leaving the current page.
6. Persist the sidebar state: store whether the sidebar is open or closed in `chrome.storage.sync` so it maintains its state across sessions and devices.

## Google Drive API Integration

```javascript
async function listRecentFiles(token) {
 const response = await fetch(
 'https://www.googleapis.com/drive/v3/files?' +
 new URLSearchParams({
 orderBy: 'modifiedTime desc',
 pageSize: '20',
 fields: 'files(id,name,mimeType,webViewLink,modifiedTime,iconLink)',
 }),
 { headers: { Authorization: `Bearer ${token}` } }
 );
 if (!response.ok) throw new Error(`Drive API error: ${response.status}`);
 const { files } = await response.json();
 return files;
}
```

The `fields` parameter restricts the response to only the properties you need, reducing payload size significantly for users with large Drives.

## Comparison with Native Drive Interfaces

| Access method | Speed | Offline | Context switching | Customization |
|---|---|---|---|---|
| This extension | Fast (cached) | No | None (stays in current tab) | Full |
| drive.google.com | Normal | Limited | Full tab switch | None |
| Google Drive desktop app | Fast | Yes | App switch | Limited |
| Drive for Docs/Sheets sidebar | Built-in | No | None | None |

The extension is most valuable when users need to reference Drive files while working in a third-party web app. It eliminates the tab-switching overhead that interrupts flow.

## Advanced: Recent Files Badge

Show a badge on the extension icon when new files have been shared with the user in the last 24 hours:

```javascript
async function checkForNewShares(token) {
 const yesterday = new Date(Date.now() - 86400000).toISOString();
 const resp = await fetch(
 `https://www.googleapis.com/drive/v3/files?q=sharedWithMe and modifiedTime > '${yesterday}'&fields=files(id,name)`,
 { headers: { Authorization: `Bearer ${token}` } }
 );
 const { files } = await resp.json();
 if (files.length > 0) {
 chrome.action.setBadgeText({ text: String(files.length) });
 chrome.action.setBadgeBackgroundColor({ color: '#4285f4' });
 }
}
```

Run this check on a 30-minute alarm to keep the badge current without hammering the API.

## Troubleshooting

OAuth token expiring mid-session: `chrome.identity.getAuthToken` returns cached tokens that expire after 1 hour. If a Drive API call returns 401, call `chrome.identity.removeCachedAuthToken({ token })` and then `getAuthToken` again to force a token refresh.

Sidebar injecting on all pages instead of target domains: Add a content script `matches` filter in the manifest for only the specific domains where the sidebar is useful (e.g., `["https://jira.yourcompany.com/*", "https://linear.app/*"]`). This also reduces unnecessary permissions.

Drive API returning 403 for some files: If the user's Drive contains files owned by an organization with domain-restricted sharing, the API may return files that cannot be opened by the extension's OAuth client. Filter the file list to exclude items where `capabilities.canDownload` is false.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-google-drive-sidebar)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Asana Task Manager: A Developer's Guide](/chrome-extension-asana-task-manager/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)
- [Chrome Extension Google Serp P — Honest Review 2026](/chrome-extension-google-serp-preview/)
- [Google Workspace Chrome Policies — Developer Guide](/google-workspace-chrome-policies/)
- [Google Calendar Sidebar Chrome Extension Guide (2026)](/chrome-extension-google-calendar-sidebar/)
- [Chrome Extension Google Docs Citation Addon](/chrome-extension-google-docs-citation-addon/)
- [ChatGPT For Google Chrome Extension Guide (2026)](/chatgpt-for-google-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


