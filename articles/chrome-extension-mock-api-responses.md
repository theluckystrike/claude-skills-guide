---
layout: default
title: "How to Mock API Responses in Chrome Extensions"
description: "A practical guide to intercepting and mocking API responses in Chrome extensions for development and testing."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-mock-api-responses/
---

{% raw %}

When building Chrome extensions that interact with external APIs, you often need to mock responses during development or testing. Rather than relying on actual API calls or setting up a complex backend, you can intercept network requests directly within your extension. This guide shows you how to mock API responses in Chrome extensions using the declarative NetRequest API and background service workers.

## Why Mock API Responses in Extensions

Mocking API responses offers several advantages. You can test your extension without hitting rate limits or incurring API costs. You can simulate edge cases and error responses that are difficult to reproduce with real APIs. Development becomes faster when you do not depend on external services being available. Additionally, you can create reproducible test scenarios for debugging.

## Using the Declarative NetRequest API

Chrome provides the `declarativeNetRequest` API, which allows you to modify network requests without needing permission to read page content. This API is powerful and works in the background, making it ideal for mocking API responses.

### Step 1: Declare Permissions

First, add the required permissions to your `manifest.json` file:

```json
{
  "name": "API Mocker Extension",
  "version": "1.0",
  "manifest_version": 3,
  "permissions": [
    "declarativeNetRequest"
  ],
  "host_permissions": [
    "*://api.example.com/*"
  ]
}
```

You also need to create a ruleset file that defines your mock responses.

### Step 2: Define Mock Rules

Create a file named `rules.json` in your extension's directory:

```json
{
  "rules": [
    {
      "id": 1,
      "priority": 1,
      "action": {
        "type": "redirect",
        "redirect": {
          "extensionPath": "/mock-data/users.json"
        }
      },
      "condition": {
        "urlFilter": "https://api.example.com/users",
        "resourceTypes": ["xmlhttprequest", "fetch"]
      }
    }
  ]
}
```

This rule intercepts requests to `api.example.com/users` and redirects them to a local JSON file.

### Step 3: Register the Ruleset

In your background service worker, register the ruleset when the extension loads:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: [
      {
        id: 1,
        priority: 1,
        action: {
          type: "redirect",
          redirect: { extensionPath: "/mock-data/users.json" }
        },
        condition: {
          urlFilter: "https://api.example.com/users",
          resourceTypes: ["xmlhttprequest", "fetch"]
        }
      }
    ]
  });
});
```

## Creating Mock Response Data

Create a directory named `mock-data` in your extension and add JSON files that mimic the real API responses:

```json
// mock-data/users.json
{
  "users": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
  ],
  "total": 2
}
```

For more complex scenarios, you can serve different responses based on request parameters using multiple rules with different priorities.

## Mocking Different Response Types

### Mocking Error Responses

You can simulate error conditions by using the `block` action or serving custom error pages:

```javascript
{
  "rules": [
    {
      "id": 2,
      "priority": 1,
      "action": {
        "type": "redirect",
        "redirect": {
          "extensionPath": "/mock-data/error-500.json"
        }
      },
      "condition": {
        "urlFilter": "https://api.example.com/error-test",
        "resourceTypes": ["xmlhttprequest"]
      }
    }
  ]
}
```

### Mocking Dynamic Responses

For responses that need to vary based on request context, consider combining the NetRequest API with a custom response handler. You can use a redirect to your own extension page that then serves dynamic content:

```javascript
// In your background script
{
  "action": {
    "type": "redirect",
    "redirect": {
      "url": "chrome-extension://" + chrome.runtime.id + "/mock-handler.html?original=" + encodeURIComponent(request.url)
    }
  }
}
```

## Managing Rules Efficiently

As your extension grows, you may need multiple mock rules. Store them in a structured way:

```
/extension
  /mock-rules
    users.json
    products.json
    auth.json
  rules.json
  background.js
```

You can update rules programmatically to switch between mock and live APIs:

```javascript
function enableMocks() {
  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: mockRules,
    removeRuleIds: liveRules.map(r => r.id)
  });
}

function disableMocks() {
  chrome.declarativeNetRequest.updateDynamicRules({
    addRules: liveRules,
    removeRuleIds: mockRules.map(r => r.id)
  });
}
```

## Testing Your Mocks

Use Chrome's developer tools to verify your mocks are working. Open the Network tab in your extension's background service worker context and make API calls. You should see the requests being intercepted and redirected to your mock files.

You can also add logging to verify rules are applied:

```javascript
chrome.declarativeNetRequest.onRuleMatchedDebug.addListener((info) => {
  console.log("Rule matched:", info.rule.ruleId, info.request.url);
});
```

## Performance Considerations

The declarative NetRequest API processes rules efficiently, but keep these tips in mind. Limit the number of rules to avoid memory overhead. Use specific URL filters rather than broad patterns. Remove unused rules when they are no longer needed.

## Conclusion

Mocking API responses in Chrome extensions is straightforward with the declarative NetRequest API. By defining rules in your manifest and background scripts, you can intercept network requests and serve custom responses without complex backend setup. This approach accelerates development, improves testing, and gives you full control over your extension's API interactions.

Start with simple redirects to local JSON files, then expand to handle dynamic responses and error scenarios as your needs grow.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
