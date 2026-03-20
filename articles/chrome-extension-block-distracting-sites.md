---

layout: default
title: "Chrome Extension Block Distracting Sites: A Developer Guide"
description: "Learn how to build a chrome extension to block distracting sites using Manifest V3, custom blocklists, and programmatic controls."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-block-distracting-sites/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
Building a chrome extension to block distracting sites gives you granular control over your browsing environment. Unlike generic blockers, a custom solution lets you define exact blocking rules, integrate with your workflow, and extend functionality as needs change. This guide walks through the implementation using Chrome's declarative NetRequest API for Manifest V3 compliance.

## Understanding the Blocking Mechanism

Chrome extensions can block network requests through the `declarativeNetRequest` API, which replaces the older `webRequest` blocking in Manifest V2. This approach is more performant and privacy-conscious since the blocking logic runs in Chrome's network layer rather than in your extension's background script.

The core concept involves defining rules in a JSON file that specify which requests to block, modify, or redirect. Each rule contains conditions (matching patterns) and actions (what to do when matched).

## Project Structure

A minimal chrome extension for blocking distracting sites requires four files:

```
block-distracting-sites/
├── manifest.json
├── rules.json
├── background.js
└── popup.html
```

## manifest.json Configuration

The manifest declares the necessary permissions and declares the rules file:

```json
{
  "manifest_version": 3,
  "name": "Focus Blocker",
  "version": "1.0",
  "description": "Block distracting sites to improve productivity",
  "permissions": [
    "declarativeNetRequest",
    "storage"
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

The `declarativeNetRequest` permission enables the blocking capability, while `storage` allows saving user preferences. The `host_permissions` with `<all_urls>` lets the extension evaluate requests across all domains.

## Defining Blocking Rules

The rules.json file contains the actual blocking logic. Each rule needs a unique ID and specifies conditions and actions:

```json
{
  "rules": [
    {
      "id": 1,
      "priority": 1,
      "action": {
        "type": "block"
      },
      "condition": {
        "urlFilter": "twitter\\.com",
        "resourceTypes": ["main_frame"]
      }
    },
    {
      "id": 2,
      "priority": 1,
      "action": {
        "type": "block"
      },
      "condition": {
        "urlFilter": "reddit\\.com",
        "resourceTypes": ["main_frame"]
      }
    },
    {
      "id": 3,
      "priority": 1,
      "action": {
        "type": "redirect",
        "redirect": {
          "url": "https://github.com"
        }
      },
      "condition": {
        "urlFilter": "youtube\\.com",
        "resourceTypes": ["main_frame"]
      }
    }
  ]
}
```

This configuration blocks Twitter and Reddit entirely while redirecting YouTube to GitHub. The `urlFilter` uses regex patterns, giving you flexibility in matching domains and paths. The `resourceTypes` array specifies which request types to evaluate—`main_frame` targets top-level page loads.

## Dynamic Rule Management

Static rules work for fixed blocklists, but a truly useful extension needs dynamic management. The background script handles updating rules based on user input:

```javascript
// background.js
const RULE_ID_START = 1000;

// Load saved rules from storage on startup
chrome.storage.local.get(['blocklist', 'enabled'], (result) => {
  if (result.enabled && result.blocklist) {
    updateBlockingRules(result.blocklist);
  }
});

// Function to update blocking rules dynamically
function updateBlockingRules(sites) {
  const rules = sites.map((site, index) => ({
    id: RULE_ID_START + index,
    priority: 1,
    action: { type: 'block' },
    condition: {
      urlFilter: site.replace(/\./g, '\\.'),
      resourceTypes: ['main_frame']
    }
  }));

  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: rules,
    removeRuleIds: rules.map(r => r.id)
  });
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'updateRules') {
    updateBlockingRules(message.sites);
    sendResponse({ success: true });
  }
  return true;
});
```

This script initializes blocking rules from stored preferences and listens for messages to update rules in real-time. The rule IDs start at 1000 to avoid conflicts with any static rules defined in rules.json.

## User Interface with Popup

The popup provides controls for managing the blocklist:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; padding: 16px; font-family: system-ui; }
    textarea { width: 100%; height: 150px; margin-bottom: 12px; }
    button { background: #0066cc; color: white; border: none; padding: 8px 16px; cursor: pointer; }
    .status { margin-top: 12px; color: green; }
  </style>
</head>
<body>
  <h3>Focus Blocker</h3>
  <textarea id="blocklist" placeholder="Enter domains to block (one per line)"></textarea>
  <button id="save">Save Blocklist</button>
  <div id="status" class="status"></div>
  <script src="popup.js"></script>
</body>
</html>
```

The corresponding popup.js handles user interactions:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
  // Load existing blocklist
  chrome.storage.local.get(['blocklist'], (result) => {
    if (result.blocklist) {
      document.getElementById('blocklist').value = result.blocklist.join('\n');
    }
  });

  document.getElementById('save').addEventListener('click', () => {
    const blocklist = document.getElementById('blocklist')
      .value.split('\n')
      .map(s => s.trim())
      .filter(s => s.length > 0);

    chrome.storage.local.set({ blocklist, enabled: true }, () => {
      // Notify background script to update rules
      chrome.runtime.sendMessage({
        action: 'updateRules',
        sites: blocklist
      });

      document.getElementById('status').textContent = 'Saved!';
      setTimeout(() => {
        document.getElementById('status').textContent = '';
      }, 2000);
    });
  });
});
```

## Advanced Features

### Time-Based Blocking

You can extend functionality to block sites only during certain hours:

```javascript
// Schedule blocking during work hours
function checkSchedule() {
  const now = new Date();
  const hour = now.getHours();
  const isWorkHour = hour >= 9 && hour < 17;

  chrome.storage.local.get(['workBlocklist'], (result) => {
    if (isWorkHour && result.workBlocklist) {
      updateBlockingRules(result.workBlocklist);
    } else {
      // Clear rules during non-work hours
      chrome.declarativeNetRequest.updateDynamicRules({
        removeRuleIds: result.workBlocklist.map((_, i) => 1000 + i)
      });
    }
  });
}

// Check every minute
setInterval(checkSchedule, 60000);
```

### Whitelist Mode

Instead of blocking specific sites, implement an allowlist that only permits certain domains:

```javascript
const allowlistRules = sites.map((site, index) => ({
  id: 2000 + index,
  priority: 100,
  action: { type: 'allow' },
  condition: {
    urlFilter: site.replace(/\./g, '\\.'),
    resourceTypes: ['main_frame']
  }
}));

// Block everything else with a lower priority rule
allowlistRules.push({
  id: 2999,
  priority: 1,
  action: { type: 'block' },
  condition: {
    urlFilter: '.*',
    resourceTypes: ['main_frame']
  }
});
```

## Testing Your Extension

Load your extension in Chrome by navigating to `chrome://extensions/`, enabling Developer mode, and clicking "Load unpacked". Select your extension directory.

Test the blocking by attempting to visit sites in your blocklist. The page should fail to load for blocked domains. Check the extension's service worker logs in the DevTools console for debugging information.

## Limitations and Considerations

The declarativeNetRequest API has constraints to be aware of. You can define up to 50,000 dynamic rules, but Chrome evaluates them in priority order. Regex patterns should be specific to avoid performance impacts. Also note that the API doesn't support blocking WebSocket connections or chrome:// URLs.

For users who need more advanced features like password-protected blocking or detailed analytics, consider integrating a backend service or combining with other APIs.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
