---
layout: default
title: "Chrome Extension Linear Issue Tracker: A Developer's Guide"
description: "Learn how to build a Chrome extension that integrates with Linear for issue tracking. Complete implementation guide with code examples."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-linear-issue-tracker/
---

{% raw %}
# Chrome Extension Linear Issue Tracker: A Developer's Guide

Linear has become a popular choice for engineering teams managing projects and issues. Building a Chrome extension that integrates with Linear's API opens up powerful workflow possibilities—from quick issue creation directly from your browser to real-time notifications and streamlined task management. This guide walks you through building a functional Chrome extension for Linear issue tracking.

## Understanding the Linear API

Linear provides a GraphQL API that gives you programmatic access to issues, projects, teams, and workflows. Before building your extension, you need to understand how authentication works and what data you can access.

Linear uses API keys for authentication. You generate these from your Linear workspace settings. Keep your API key secure—never expose it in client-side code. For a Chrome extension, you'll store the key in `chrome.storage.sync` or use the Identity API for OAuth authentication.

The core GraphQL operations you'll need are:

- `issues` - Query and create issues
- `issueLabels` - Access labels for categorization
- `users` - Get team member information
- `workflowStates` - Understand issue states (backlog, todo, in progress, done)

## Setting Up Your Extension Project

Create a new directory for your extension and set up the basic files:

```bash
mkdir linear-issue-tracker-extension
cd linear-issue-tracker-extension
mkdir -p popup icons background
```

Your `manifest.json` defines the extension's capabilities:

```json
{
  "manifest_version": 3,
  "name": "Linear Issue Tracker",
  "version": "1.0",
  "description": "Track and create Linear issues from your browser",
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["https://api.linear.app/*"],
  "action": {
    "default_popup": "popup/popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "background/background.js"
  }
}
```

## Building the Popup Interface

The popup provides the main user interface for quick issue creation and viewing. Here's a practical implementation using vanilla JavaScript:

```javascript
// popup/popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const apiKey = await getApiKey();
  if (!apiKey) {
    showSetupPrompt();
    return;
  }
  loadRecentIssues();
});

async function createIssue(title, description, labels) {
  const query = `
    mutation CreateIssue($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue {
          id
          identifier
          title
        }
      }
    }
  `;

  const response = await fetch('https://api.linear.app/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': apiKey
    },
    body: JSON.stringify({
      query,
      variables: {
        input: {
          title,
          description,
          labelIds: labels
        }
      }
    })
  });

  return response.json();
}
```

## Implementing Background Sync

Background scripts handle periodic sync operations and keep your local cache updated:

```javascript
// background/background.js
const LINEAR_API = 'https://api.linear.app/graphql';

async function fetchIssues(apiKey, cursor = null) {
  const query = `
    query GetIssues($first: Int, $after: String) {
      issues(first: $first, after: $after) {
        nodes {
          id
          identifier
          title
          description
          state {
            name
          }
          labels {
            nodes {
              name
              color
            }
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  `;

  const response = await fetch(LINEAR_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': apiKey
    },
    body: JSON.stringify({
      query,
      variables: { first: 50, after: cursor }
    })
  });

  return response.json();
}

// Periodic sync every 5 minutes
chrome.alarms.create('syncIssues', { periodInMinutes: 5 });

chrome.alarms.onAlarm.addListener(async (alarm) => {
  if (alarm.name === 'syncIssues') {
    const { apiKey } = await chrome.storage.sync.get('apiKey');
    if (apiKey) {
      const data = await fetchIssues(apiKey);
      await chrome.storage.local.set({ cachedIssues: data.data.issues.nodes });
    }
  }
});
```

## Handling Authentication Securely

Security matters when dealing with API keys. Implement a settings page where users can store their Linear API key:

```javascript
// popup/settings.js
async function saveApiKey(apiKey) {
  // Validate the key works before saving
  const testResponse = await fetch('https://api.linear.app/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': apiKey
    },
    body: JSON.stringify({
      query: `query { viewer { id } }`
    })
  });

  if (testResponse.ok) {
    await chrome.storage.sync.set({ apiKey });
    return true;
  }
  return false;
}
```

## Adding Context Menu Integration

A powerful feature for developers is creating issues from selected text anywhere in Chrome:

```javascript
// background/background.js
chrome.contextMenus.create({
  id: 'createLinearIssue',
  title: 'Create Linear Issue',
  contexts: ['selection']
});

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId === 'createLinearIssue') {
    const { apiKey } = await chrome.storage.sync.get('apiKey');
    if (apiKey) {
      // Open a small modal or redirect to popup with pre-filled data
      chrome.storage.local.set({
        pendingIssue: {
          title: `Issue from: ${tab.title}`,
          description: info.selectionText
        }
      });
      chrome.action.openPopup();
    }
  }
});
```

## Practical Use Cases for Developers

This extension becomes valuable in real workflows. Here are practical scenarios:

**Code Review Feedback**: Select problematic code in GitHub or your codebase, right-click, and create a Linear issue immediately. The issue captures the code context and links back to its source.

**Meeting Notes to Tasks**: During meetings, select action items and quickly create issues without switching context. The extension can pre-populate team and project fields based on your working context.

**Bug Reporting**: When you encounter a bug in production, select the error message and create an issue in one click. Your cached list of labels helps categorize bugs appropriately.

## Performance Considerations

Chrome extensions run in a constrained environment. Optimize your implementation:

- Cache frequently accessed data in `chrome.storage.local` to reduce API calls
- Use pagination when fetching large issue lists
- Implement debouncing for search functionality
- Lazy-load issue details on demand rather than fetching everything upfront

## Extending the Functionality

Once the core features work, consider adding:

- Keyboard shortcuts for quick issue creation
- Desktop notifications for issue updates
- Integration with other developer tools (GitHub, Slack)
- Search across your Linear issues directly from the extension

The Linear GraphQL API offers extensive capabilities. Explore the schema to add features like sprint management, team workload visualization, or custom dashboards.

---

This guide provides a foundation for building a Chrome extension that integrates Linear issue tracking into your daily workflow. The combination of a browser extension with Linear's API creates efficient workflows for developers who spend significant time in their browsers.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
