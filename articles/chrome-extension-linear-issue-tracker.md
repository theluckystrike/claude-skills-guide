---
layout: default
title: "Fix Chrome Extension Linear Issue (2026)"
description: "Learn how to build and use Chrome extensions for Linear issue tracking. Practical code examples, API integration patterns, and best practices for."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-linear-issue-tracker/
categories: [guides]
tags: [chrome-extension, linear, issue-tracker, productivity, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---
Linear is a popular issue tracking tool among development teams. Integrating Linear directly into your Chrome browser through a custom extension can significantly streamline your workflow. This guide covers everything you need to know about building and using Chrome extensions for Linear issue tracking.

Why Build a Linear Chrome Extension?

Linear's web interface works well, but a dedicated Chrome extension provides faster access to common actions without switching tabs. You can create quick shortcuts for:

- Creating issues from any webpage
- Viewing assigned issues without opening Linear
- Logging time on issues instantly
- Checking issue status at a glance

For developers who frequently reference Linear throughout the day, these small time savings accumulate quickly.

## Core Components of a Linear Chrome Extension

A functional Linear Chrome extension requires several key components:

Manifest File (manifest.json)

Every Chrome extension starts with a manifest file that defines permissions and capabilities:

```json
{
 "manifest_version": 3,
 "name": "Linear Quick Tracker",
 "version": "1.0.0",
 "description": "Quick issue creation and tracking for Linear",
 "permissions": [
 "storage",
 "activeTab",
 "scripting"
 ],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 },
 "host_permissions": [
 "https://linear.app/*"
 ],
 "oauth2": {
 "client_id": "YOUR_CLIENT_ID",
 "scopes": ["read", "write"]
 }
}
```

The OAuth2 configuration allows users to authenticate with their Linear account securely.

Popup Interface (popup.html)

The popup provides the main user interface when clicking the extension icon:

```html
<!DOCTYPE html>
<html>
<head>
 <style>
 body { width: 320px; padding: 16px; font-family: system-ui; }
 input, textarea, select { width: 100%; margin-bottom: 12px; padding: 8px; }
 button { width: 100%; padding: 10px; background: #5E6AD2; color: white; border: none; cursor: pointer; }
 button:hover { background: #4a55b0; }
 .issue-list { margin-top: 16px; border-top: 1px solid #eee; }
 .issue-item { padding: 8px 0; border-bottom: 1px solid #eee; }
 </style>
</head>
<body>
 <h3>Linear Quick Tracker</h3>
 <select id="teamSelect">
 <option value="">Select Team</option>
 </select>
 <input type="text" id="issueTitle" placeholder="Issue title">
 <textarea id="issueDescription" rows="3" placeholder="Description (optional)"></textarea>
 <select id="prioritySelect">
 <option value="0">No priority</option>
 <option value="1">Urgent</option>
 <option value="2">High</option>
 <option value="3">Medium</option>
 <option value="4">Low</option>
 </select>
 <button id="createIssue">Create Issue</button>
 <div class="issue-list" id="recentIssues"></div>
 <script src="popup.js"></script>
</body>
</html>
```

## Linear API Integration

The Linear API uses GraphQL, which gives you precise control over what data you fetch and modify. You'll need an API key from Linear's developer settings.

## Authentication

Store your API key securely using Chrome's storage API:

```javascript
// popup.js - Authentication setup
const LINEAR_API_KEY_STORAGE_KEY = 'linear_api_key';
const LINEAR_API_URL = 'https://api.linear.app/graphql';

async function getApiKey() {
 const result = await chrome.storage.local.get(LINEAR_API_KEY_STORAGE_KEY);
 return result[LINEAR_API_KEY_STORAGE_KEY];
}

async function setApiKey(apiKey) {
 await chrome.storage.local.set({ [LINEAR_API_KEY_STORAGE_KEY]: apiKey });
}
```

## Creating Issues via GraphQL

The core functionality involves creating issues through Linear's GraphQL API:

```javascript
async function createLinearIssue(title, description, teamId, priority) {
 const apiKey = await getApiKey();
 
 const mutation = `
 mutation IssueCreate($input: IssueCreateInput!) {
 issueCreate(input: $input) {
 success
 issue {
 id
 identifier
 title
 url
 }
 }
 }
 `;

 const variables = {
 input: {
 teamId: teamId,
 title: title,
 description: description || null,
 priority: priority
 }
 };

 const response = await fetch(LINEAR_API_URL, {
 method: 'POST',
 headers: {
 'Content-Type': 'application/json',
 'Authorization': apiKey,
 },
 body: JSON.stringify({ query: mutation, variables })
 });

 const data = await response.json();
 
 if (data.data?.issueCreate?.success) {
 return data.data.issueCreate.issue;
 } else {
 throw new Error(data.errors?.[0]?.message || 'Failed to create issue');
 }
}
```

## Fetching Assigned Issues

Retrieve issues assigned to the current user:

```javascript
async function getAssignedIssues() {
 const apiKey = await getApiKey();
 
 const query = `
 query {
 issues(filter: { assignee: { isMe: { eq: true } } }) {
 nodes {
 id
 identifier
 title
 priority
 state {
 name
 }
 createdAt
 url
 }
 }
 }
 `;

 const response = await fetch(LINEAR_API_URL, {
 method: 'POST',
 headers: {
 'Content-Type': 'application/json',
 'Authorization': apiKey,
 },
 body: JSON.stringify({ query })
 });

 const data = await response.json();
 return data.data?.issues?.nodes || [];
}
```

## Building the Popup Logic

Connect the UI components with your API functions:

```javascript
document.addEventListener('DOMContentLoaded', async () => {
 const apiKey = await getApiKey();
 
 if (!apiKey) {
 showSetupPrompt();
 return;
 }

 await loadTeams();
 await loadAssignedIssues();
 
 document.getElementById('createIssue').addEventListener('click', async () => {
 const title = document.getElementById('issueTitle').value;
 const description = document.getElementById('issueDescription').value;
 const teamId = document.getElementById('teamSelect').value;
 const priority = parseInt(document.getElementById('prioritySelect').value);

 if (!title || !teamId) {
 alert('Please provide a title and select a team');
 return;
 }

 try {
 const issue = await createLinearIssue(title, description, teamId, priority);
 alert(`Issue created: ${issue.identifier}`);
 document.getElementById('issueTitle').value = '';
 document.getElementById('issueDescription').value = '';
 } catch (error) {
 alert(`Error: ${error.message}`);
 }
 });
});

async function loadTeams() {
 const apiKey = await getApiKey();
 const query = `{ teams { nodes { id name } } }`;
 
 const response = await fetch(LINEAR_API_URL, {
 method: 'POST',
 headers: {
 'Content-Type': 'application/json',
 'Authorization': apiKey,
 },
 body: JSON.stringify({ query })
 });

 const teams = (await response.json()).data?.teams?.nodes || [];
 const select = document.getElementById('teamSelect');
 
 teams.forEach(team => {
 const option = document.createElement('option');
 option.value = team.id;
 option.textContent = team.name;
 select.appendChild(option);
 });
}
```

## Advanced Features to Consider

Once you have the basics working, consider adding these enhancements:

Keyboard Shortcuts: Define commands in your manifest for quick actions without opening the popup.

Context Menus: Add items to the right-click menu to create issues from selected text on any webpage.

Desktop Notifications: Use the Chrome Notifications API to alert users when they're assigned new issues.

Background Sync: Periodically check for new assigned issues and display badge counts on the extension icon.

## Security Best Practices

When building extensions that handle API keys and sensitive data:

- Never hardcode API keys in your source code
- Use `chrome.storage.local` with encryption for sensitive credentials
- Request minimum necessary permissions in your manifest
- Implement proper error handling for API failures
- Consider using Linear's OAuth flow instead of API keys for production extensions

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Select your extension's directory.

Test thoroughly:
- Create issues across different teams
- Verify priority settings work correctly
- Check that error states display appropriately
- Test with invalid and expired API keys

## Conclusion

Building a Chrome extension for Linear issue tracking gives you instant access to your workflow without browser tab switching. The GraphQL API provides flexible data access, and Chrome's extension APIs enable rich integration with the browser itself.

Start with the basic issue creation flow, then add features like assigned issue viewing and quick actions based on your team's specific needs. The investment in building this extension pays dividends in time saved throughout your development workday.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=chrome-extension-linear-issue-tracker)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)
- [AI Bookmark Manager for Chrome: Organizing Your Web Knowledge](/ai-bookmark-manager-chrome/)
- [AI Code Assistant Chrome Extension: Practical Guide for.](/ai-code-assistant-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


