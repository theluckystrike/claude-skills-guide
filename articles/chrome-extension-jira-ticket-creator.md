---
layout: default
title: "Jira Ticket Creator Chrome Extension"
description: "Claude Code extension tip: learn how to build a Chrome extension that creates Jira tickets directly from your browser. Includes code examples, API..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-jira-ticket-creator/
categories: [guides, productivity]
tags: [chrome-extension, jira, ticket-creator, automation, developer-tools, workflow]
reviewed: true
score: 7
geo_optimized: true
---
# Chrome Extension Jira Ticket Creator: Automate Issue Tracking

Creating Jira tickets often requires switching contexts, navigating through multiple menus, and manually filling in repetitive fields. A Chrome extension that creates Jira tickets directly from your browser eliminates this friction, letting you capture issues while you work. This guide walks through building a functional Jira ticket creator extension, from API authentication to form handling and deployment.

## Understanding the Architecture

A Chrome extension for Jira ticket creation consists of three main components: a popup interface for entering ticket details, a background script handling Jira API communication, and the manifest configuration tying everything together. The extension communicates with Jira Cloud via REST API, requiring OAuth 2.0 or API token authentication depending on your Jira setup.

The typical workflow involves the user clicking the extension icon, filling in a short form with summary, description, and issue type, then submitting to create the ticket in your configured Jira project. The extension then returns the newly created ticket key and a direct link to open it.

Understanding how these parts interact helps you debug issues and plan enhancements. Here is how data flows through the system:

1. User opens the popup and fills in the form
2. `popup.js` validates input and sends a message to `background.js` via `chrome.runtime.sendMessage`
3. `background.js` formats the Jira API payload and issues a `fetch` request
4. Jira Cloud REST API processes the request and returns the new issue key
5. `background.js` sends the result back to the popup
6. The popup displays a success link or error message

This separation of concerns is important. The background service worker persists longer than the popup (which closes the moment the user clicks elsewhere), making it the right place to hold credentials and execute network requests.

## Comparing Authentication Approaches

Before writing any code, decide how you will authenticate with Jira. Your choice affects security, setup complexity, and whether the extension can be distributed to teammates.

| Method | Use Case | Security | Complexity |
|---|---|---|---|
| API Token (Basic Auth) | Personal or team tools | Moderate. token has full account access | Low. one token per user |
| OAuth 2.0 (3LO) | Public or distributed extensions | High. scoped, revocable tokens | High. requires app registration and redirect flow |
| Personal Access Token (PAT) | Jira Server / Data Center | Moderate | Low. similar to API token |
| Service Account Token | CI/CD or shared team extensions | Moderate. shared credential risk | Low to Medium |

For a personal productivity extension used only by you or a small team with Jira Cloud, API token authentication is the right default. For an extension you intend to publish on the Chrome Web Store to arbitrary users, OAuth 2.0 is required.

This guide uses API token authentication. The OAuth approach involves additional redirect URI handling and Atlassian app registration that is outside the scope of a simple extension, but the Jira Cloud REST API supports both interchangeably.

## Setting Up Jira API Access

Before building the extension, you need API credentials. For Jira Cloud, generate an API token from your Atlassian account settings at `id.atlassian.com/manage-profile/security/api-tokens`. Store your Jira domain, email, and token securely. you will need these for the extension configuration.

For Jira Server or Data Center, you may use basic authentication with your username and password instead, or generate a personal access token from your profile settings. The API base URL follows this pattern:

```
https://your-domain.atlassian.net/rest/api/3/issue
```

Verify your credentials work by making a test request:

```bash
curl -u your-email@domain.com:YOUR_API_TOKEN \
 -X GET "https://your-domain.atlassian.net/rest/api/3/myself" \
 -H "Content-Type: application/json"
```

A successful response returns a JSON object with your account ID, display name, and email address, confirming authentication is working.

You should also verify you can list the projects your account can access, since you will need a valid project key for the ticket creation form:

```bash
curl -u your-email@domain.com:YOUR_API_TOKEN \
 -X GET "https://your-domain.atlassian.net/rest/api/3/project" \
 -H "Content-Type: application/json"
```

Note the `key` field from each project in the response. These short uppercase strings (like `PROJ`, `ENG`, `OPS`) are what users will enter in the extension form.

## Creating the Extension Structure

Create a new directory for your extension and add the following files:

```
jira-ticket-creator/
 manifest.json
 popup.html
 popup.js
 background.js
 settings.html
 settings.js
 styles.css
```

The `settings.html` and `settings.js` files are additions beyond the minimal version. they allow users to enter their own Jira credentials without modifying the source code, which is essential for distributing the extension to teammates.

The manifest.json defines the extension capabilities:

```javascript
{
 "manifest_version": 3,
 "name": "Jira Ticket Creator",
 "version": "1.0",
 "description": "Create Jira tickets directly from your browser",
 "permissions": ["activeTab", "storage"],
 "host_permissions": ["https://*.atlassian.net/*"],
 "action": {
 "default_popup": "popup.html",
 "default_icon": "icon.png"
 },
 "background": {
 "service_worker": "background.js"
 },
 "options_page": "settings.html"
}
```

The `host_permissions` field grants the extension access to Jira domains, which is required for making API calls. Without this, `fetch` requests to `atlassian.net` will be blocked by the browser's CORS policy. The `storage` permission allows saving user credentials and preferences between sessions.

One thing to watch: Manifest V3 uses a service worker for the background script instead of a persistent background page. Service workers can be terminated when idle, so you should not rely on in-memory state in `background.js`. Use `chrome.storage` for anything that needs to persist.

## Building the Popup Interface

The popup provides the user interface for entering ticket details. Keep it focused on the essential fields most teams need:

```html
<!DOCTYPE html>
<html>
<head>
 <meta charset="UTF-8">
 <link rel="stylesheet" href="styles.css">
</head>
<body>
 <form id="ticket-form">
 <h2>Create Jira Ticket</h2>

 <label for="project-key">Project Key</label>
 <input type="text" id="project-key" placeholder="e.g., PROJ" required>

 <label for="summary">Summary</label>
 <input type="text" id="summary" placeholder="Brief description" required>

 <label for="description">Description</label>
 <textarea id="description" rows="4" placeholder="Detailed information..."></textarea>

 <label for="issue-type">Issue Type</label>
 <select id="issue-type">
 <option value="Bug">Bug</option>
 <option value="Task">Task</option>
 <option value="Story">Story</option>
 <option value="Epic">Epic</option>
 </select>

 <label for="priority">Priority</label>
 <select id="priority">
 <option value="Medium">Medium</option>
 <option value="High">High</option>
 <option value="Low">Low</option>
 <option value="Critical">Critical</option>
 </select>

 <button type="submit" id="create-btn">Create Ticket</button>
 <button type="button" id="settings-btn">Settings</button>
 <div id="status"></div>
 </form>
 <script src="popup.js"></script>
</body>
</html>
```

The CSS in `styles.css` should keep the popup compact. Chrome enforces a maximum popup width around 800 pixels, but users expect something closer to 300–400 pixels:

```css
body {
 width: 340px;
 padding: 12px;
 font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
 font-size: 13px;
}

h2 {
 margin: 0 0 12px;
 font-size: 15px;
 color: #172B4D;
}

label {
 display: block;
 margin-top: 8px;
 margin-bottom: 3px;
 font-weight: 600;
 color: #253858;
}

input, textarea, select {
 width: 100%;
 padding: 6px 8px;
 border: 1px solid #DFE1E6;
 border-radius: 3px;
 box-sizing: border-box;
 font-size: 13px;
}

input:focus, textarea:focus, select:focus {
 outline: none;
 border-color: #0052CC;
 box-shadow: 0 0 0 2px rgba(0, 82, 204, 0.2);
}

button {
 margin-top: 12px;
 padding: 7px 14px;
 border: none;
 border-radius: 3px;
 cursor: pointer;
 font-size: 13px;
 font-weight: 600;
}

#create-btn {
 background: #0052CC;
 color: white;
 width: 100%;
}

#create-btn:hover {
 background: #0065FF;
}

#create-btn:disabled {
 background: #B3D4FF;
 cursor: not-allowed;
}

#settings-btn {
 background: none;
 color: #0052CC;
 padding: 4px 0;
 width: 100%;
 margin-top: 6px;
}

#status {
 margin-top: 10px;
 font-size: 12px;
 min-height: 16px;
}

#status a {
 color: #0052CC;
 font-weight: 600;
}

.error {
 color: #DE350B;
}
```

## Handling Form Submission and API Calls

The popup.js script handles form submission, loads saved settings, and communicates with the background script. A key improvement over the minimal version is auto-loading the project key from storage so users do not have to retype it every time:

```javascript
// popup.js

const STORAGE_KEYS = ['projectKey', 'jiraDomain', 'jiraEmail', 'jiraToken'];

async function loadSavedValues() {
 const saved = await chrome.storage.sync.get(STORAGE_KEYS);
 if (saved.projectKey) {
 document.getElementById('project-key').value = saved.projectKey;
 }
 if (!saved.jiraDomain || !saved.jiraEmail || !saved.jiraToken) {
 document.getElementById('status').textContent = 'Configure credentials in Settings first.';
 document.getElementById('create-btn').disabled = true;
 }
}

document.addEventListener('DOMContentLoaded', loadSavedValues);

document.getElementById('settings-btn').addEventListener('click', () => {
 chrome.runtime.openOptionsPage();
});

document.getElementById('ticket-form').addEventListener('submit', async (e) => {
 e.preventDefault();

 const status = document.getElementById('status');
 const submitBtn = document.getElementById('create-btn');

 submitBtn.disabled = true;
 status.className = '';
 status.textContent = 'Creating ticket...';

 const projectKey = document.getElementById('project-key').value.trim().toUpperCase();

 // Save the project key for next time
 await chrome.storage.sync.set({ projectKey });

 const ticketData = {
 fields: {
 project: { key: projectKey },
 summary: document.getElementById('summary').value.trim(),
 description: {
 type: 'doc',
 version: 1,
 content: [{
 type: 'paragraph',
 content: [{
 type: 'text',
 text: document.getElementById('description').value.trim() || ' '
 }]
 }]
 },
 issuetype: { name: document.getElementById('issue-type').value },
 priority: { name: document.getElementById('priority').value }
 }
 };

 try {
 const response = await chrome.runtime.sendMessage({
 action: 'createJiraTicket',
 data: ticketData
 });

 if (response.success) {
 status.innerHTML = `Created: <a href="${response.url}" target="_blank">${response.key}</a>`;
 document.getElementById('summary').value = '';
 document.getElementById('description').value = '';
 } else {
 status.className = 'error';
 status.textContent = 'Error: ' + response.error;
 }
 } catch (err) {
 status.className = 'error';
 status.textContent = 'Failed to communicate with background script.';
 }

 submitBtn.disabled = false;
});
```

Note the `fields` wrapper added to `ticketData`. Jira's REST API v3 expects the issue fields nested under a `fields` key. this is a common mistake that causes confusing `400 Bad Request` errors when first building the integration.

## Managing Authentication in the Background

The background script holds your API credentials and makes the actual Jira API calls. For security, store credentials in Chrome's `storage.sync` API rather than hardcoding them. `storage.sync` encrypts data at rest and syncs across the user's Chrome profile on different devices:

```javascript
// background.js

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.action === 'createJiraTicket') {
 createTicket(message.data).then(sendResponse);
 return true; // Required: tells Chrome to wait for async response
 }
});

async function getConfig() {
 return chrome.storage.sync.get(['jiraDomain', 'jiraEmail', 'jiraToken']);
}

async function createTicket(ticketData) {
 const config = await getConfig();

 if (!config.jiraDomain || !config.jiraEmail || !config.jiraToken) {
 return { success: false, error: 'Missing Jira credentials. Open Settings to configure.' };
 }

 const domain = config.jiraDomain.replace(/^https?:\/\//, '').replace(/\/$/, '');
 const url = `https://${domain}/rest/api/3/issue`;
 const credentials = btoa(`${config.jiraEmail}:${config.jiraToken}`);

 let response;
 try {
 response = await fetch(url, {
 method: 'POST',
 headers: {
 'Authorization': `Basic ${credentials}`,
 'Content-Type': 'application/json',
 'Accept': 'application/json'
 },
 body: JSON.stringify(ticketData)
 });
 } catch (networkErr) {
 return { success: false, error: 'Network error. Check your connection and Jira domain.' };
 }

 if (!response.ok) {
 let errorMessage = `HTTP ${response.status}`;
 try {
 const errorBody = await response.json();
 if (errorBody.errors) {
 errorMessage = Object.values(errorBody.errors).join(', ');
 } else if (errorBody.errorMessages && errorBody.errorMessages.length) {
 errorMessage = errorBody.errorMessages.join(', ');
 }
 } catch (_) {
 // Non-JSON error body, use status code
 }
 return { success: false, error: errorMessage };
 }

 const result = await response.json();
 return {
 success: true,
 key: result.key,
 url: `https://${domain}/browse/${result.key}`
 };
}
```

The `return true` inside the message listener is critical. Without it, Chrome closes the message channel before the async `createTicket` function completes, and `sendResponse` never reaches the popup. For related guidance, see [Claude Code Playwright E2E — Complete Developer Guide](/claude-code-playwright-e2e-testing-guide/).

## Adding a Settings Page

A settings page lets users enter their own credentials without touching the code. This is what makes the extension shareable:

```html
<!-- settings.html -->
<!DOCTYPE html>
<html>
<head>
 <meta charset="UTF-8">
 <title>Jira Ticket Creator. Settings</title>
 <style>
 body { font-family: -apple-system, sans-serif; max-width: 500px; margin: 40px auto; padding: 0 20px; }
 label { display: block; margin-top: 16px; font-weight: 600; }
 input { width: 100%; padding: 8px; border: 1px solid #DFE1E6; border-radius: 3px; margin-top: 4px; box-sizing: border-box; }
 button { margin-top: 20px; padding: 8px 20px; background: #0052CC; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 14px; }
 #status { margin-top: 12px; color: #006644; font-size: 13px; }
 </style>
</head>
<body>
 <h2>Jira Ticket Creator Settings</h2>

 <label for="domain">Jira Domain</label>
 <input type="text" id="domain" placeholder="your-company.atlassian.net">

 <label for="email">Atlassian Account Email</label>
 <input type="email" id="email" placeholder="you@company.com">

 <label for="token">API Token</label>
 <input type="password" id="token" placeholder="Paste your API token here">

 <button id="save-btn">Save Settings</button>
 <div id="status"></div>

 <script src="settings.js"></script>
</body>
</html>
```

```javascript
// settings.js

async function loadSettings() {
 const saved = await chrome.storage.sync.get(['jiraDomain', 'jiraEmail', 'jiraToken']);
 if (saved.jiraDomain) document.getElementById('domain').value = saved.jiraDomain;
 if (saved.jiraEmail) document.getElementById('email').value = saved.jiraEmail;
 if (saved.jiraToken) document.getElementById('token').value = saved.jiraToken;
}

document.addEventListener('DOMContentLoaded', loadSettings);

document.getElementById('save-btn').addEventListener('click', async () => {
 const domain = document.getElementById('domain').value.trim();
 const email = document.getElementById('email').value.trim();
 const token = document.getElementById('token').value.trim();

 if (!domain || !email || !token) {
 document.getElementById('status').style.color = '#DE350B';
 document.getElementById('status').textContent = 'All fields are required.';
 return;
 }

 await chrome.storage.sync.set({
 jiraDomain: domain,
 jiraEmail: email,
 jiraToken: token
 });

 document.getElementById('status').style.color = '#006644';
 document.getElementById('status').textContent = 'Settings saved.';
});
```

## Capturing Page Context Automatically

One of the most useful enhancements is automatically populating the description with information from the current browser tab. When a user is looking at a bug on a staging site, they almost always want the URL in the ticket. The `activeTab` permission lets you read this without any additional user prompts:

```javascript
// In popup.js, add to DOMContentLoaded handler:

async function prefillFromCurrentTab() {
 try {
 const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
 if (tab && tab.url && !tab.url.startsWith('chrome://')) {
 const descField = document.getElementById('description');
 if (!descField.value) {
 descField.value = `Page: ${tab.url}\nTitle: ${tab.title}`;
 }
 }
 } catch (_) {
 // Silently fail. tab access can be denied on some pages
 }
}

document.addEventListener('DOMContentLoaded', () => {
 loadSavedValues();
 prefillFromCurrentTab();
});
```

This single addition saves a copy-paste step on almost every ticket. Users can always clear or edit the pre-filled description.

## Common Errors and How to Fix Them

| Error | Likely Cause | Fix |
|---|---|---|
| `401 Unauthorized` | Wrong email or API token | Re-generate the token; confirm you are using the email linked to your Atlassian account |
| `403 Forbidden` | Account lacks create permission on the project | Ask your Jira admin to grant you create-issue permission |
| `400 Bad Request: issue type not found` | Issue type name mismatch | Use the exact name from your project's issue type settings (case-sensitive) |
| `400 Bad Request: project not found` | Wrong project key | Confirm the key in Jira project settings. it is not the project name |
| `Could not communicate with background` | Manifest V3 service worker terminated | Reload the extension; verify `return true` is in the message listener |
| CORS error in popup | Making fetch from popup instead of background | All API calls must go through `background.js`, not `popup.js` |

The CORS error is the most common architectural mistake. Chrome extensions can bypass CORS restrictions only in background scripts that have `host_permissions` configured. not in popup scripts. Always route API calls through the background service worker.

## Testing and Deployment

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Select your extension directory and test the workflow:

1. Click "Settings" and enter your Jira domain, email, and API token
2. Return to the popup and enter a valid project key from your Jira instance
3. Fill in summary and description
4. Select an issue type and priority
5. Click Create Ticket

The extension should create the ticket and display a clickable link to the newly created issue. Check your Jira project to confirm the ticket appears with correct details.

For debugging, open the background service worker's DevTools from `chrome://extensions/` by clicking the "service worker" link next to your extension. This gives you a console where `console.log` output from `background.js` appears.

When testing errors, deliberately enter a wrong API token to confirm the error handling path displays a readable message. Then try a nonexistent project key to verify the `400` error parsing works.

To distribute the extension to teammates without publishing to the Chrome Web Store, zip the extension directory and share it. Recipients load it via "Load unpacked" the same way. For a formal internal rollout, consider packaging it as a `.crx` file and hosting it on an internal site, though Chrome now restricts installation of externally hosted `.crx` files to managed enterprise devices.

To publish publicly on the Chrome Web Store, you need a developer account ($5 one-time fee), screenshots, a privacy policy describing credential handling, and a review that typically takes a few days.

## Extending the Extension

Once the basic version works, several enhancements significantly improve daily usefulness:

Quick Templates: Store two or three pre-defined ticket formats (bug report, task, feature request) and let users pick a template to pre-fill the form. Templates live in `chrome.storage.sync` alongside credentials.

Label and Component Support: Jira tickets often require labels or components. Add these as optional fields fetched dynamically from the Jira API when the popup opens:

```javascript
async function fetchComponents(domain, email, token, projectKey) {
 const url = `https://${domain}/rest/api/3/project/${projectKey}/components`;
 const response = await fetch(url, {
 headers: { 'Authorization': `Basic ${btoa(email + ':' + token)}` }
 });
 if (!response.ok) return [];
 const data = await response.json();
 return data.map(c => ({ id: c.id, name: c.name }));
}
```

Context Menu Integration: Register a context menu item that triggers from any selected text on a page. When the user right-clicks highlighted text and chooses "Create Jira Ticket", the extension opens a popup with the selected text pre-filled as the summary. Context menus are registered in `background.js`:

```javascript
chrome.runtime.onInstalled.addListener(() => {
 chrome.contextMenus.create({
 id: 'create-jira-ticket',
 title: 'Create Jira Ticket from "%s"',
 contexts: ['selection']
 });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
 if (info.menuItemId === 'create-jira-ticket') {
 chrome.storage.session.set({ prefillSummary: info.selectionText });
 chrome.action.openPopup();
 }
});
```

Keyboard Shortcut: Register a keyboard shortcut in the manifest to open the popup without touching the mouse:

```javascript
"commands": {
 "_execute_action": {
 "suggested_key": {
 "default": "Alt+J",
 "mac": "Command+Shift+J"
 },
 "description": "Open Jira Ticket Creator"
 }
}
```

AI-Assisted Descriptions: Integrate with Claude or another AI API to generate a structured bug report from a screenshot or copied error message. The user pastes the stack trace, clicks "Generate Description", and the extension fills in a well-formatted bug report automatically. This is particularly powerful for teams that struggle with low-information tickets. See also [Generate GraphQL Schemas with Claude Code](/claude-code-graphql-schema-generation-guide/) for more on this topic.

A well-built Jira ticket creator extension reduces context switching and standardizes how your team captures issues. The foundation established here scales with your workflow needs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-jira-ticket-creator)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Shopping List Organizer: A Developer Guide](/chrome-extension-shopping-list-organizer/)
- [Claude Code Package.json Scripts Automation Workflow Guide](/claude-code-package-json-scripts-automation-workflow-guide/)
- [Chrome Extension OneNote Clipper Setup Guide](/chrome-extension-onenote-clipper-setup/)
- [Refined GitHub Chrome Extension Guide (2026)](/refined-github-chrome-extension/)
- [Best Readability Alternatives for Chrome 2026](/readability-alternative-chrome-extension-2026/)
- [How to Mock API Responses in Chrome Extensions](/chrome-extension-mock-api-responses/)
- [GitLab Productivity Chrome Extension Guide (2026)](/gitlab-chrome-extension-productivity/)
- [Toby Alternative Chrome Extension in 2026](/toby-alternative-chrome-extension-2026/)
- [Chrome Extension Sprint Planning Poker](/chrome-extension-sprint-planning-poker/)
- [Chrome Extension Regex Tester: Build or Find Tools](/chrome-extension-regex-tester/)
- [Font Identifier Chrome Extension Guide (2026)](/chrome-extension-font-identifier/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


