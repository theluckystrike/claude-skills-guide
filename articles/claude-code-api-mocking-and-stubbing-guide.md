---
layout: default
title: "Claude Code API Mocking and Stubbing Guide"
description: "Master API mocking and stubbing in Claude Code workflows. Learn to build reliable test doubles, intercept HTTP calls, and develop offline with practical examples."
date: 2026-03-14
author: "theluckystrike"
permalink: /claude-code-api-mocking-and-stubbing-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
---

# Claude Code API Mocking and Stubbing Guide

Building reliable AI-assisted workflows requires controlling external dependencies. When Claude Code interacts with APIs during development or testing, you need predictable responses without relying on live services. This guide covers practical approaches to mocking and stubbing HTTP interactions within Claude Code skill workflows.

## Understanding the Mocking Challenge

Claude Code skills often trigger HTTP requests through tools like `bash` (using curl), Python scripts, or Node.js code. These requests might hit third-party APIs for data enrichment, testing webhooks, or retrieving external resources. In testing scenarios or offline development, you cannot depend on those external services being available or returning consistent data.

API mocking replaces real HTTP calls with local interceptors that return predefined responses. Stubbing provides fake implementations for specific functions or methods. Both techniques give you complete control over your integration points.

## Building a Local Mock Server

The most straightforward approach involves running a local mock server that intercepts requests. For skills that make HTTP calls, you can redirect traffic to localhost using environment variables or configuration files.

Create a simple mock server using Python's Flask:

```python
from flask import Flask, jsonify, request

app = Flask(__name__)

MOCK_RESPONSES = {
    "/api/users": {
        "users": [
            {"id": 1, "name": "Alice"},
            {"id": 2, "name": "Bob"}
        ]
    },
    "/api/products": {
        "products": [
            {"id": 101, "name": "Widget", "price": 29.99}
        ]
    }
}

@app.route("/api/<path:endpoint>", methods=["GET", "POST"])
def handle_mock(endpoint):
    if endpoint in MOCK_RESPONSES:
        return jsonify(MOCK_RESPONSES[endpoint])
    return jsonify({"error": "Not found"}), 404

if __name__ == "__main__":
    app.run(port=3000)
```

Run this server alongside your Claude Code session. Configure your API client to point to `http://localhost:3000` instead of the production URL. The skill's code remains unchanged—you simply redirect the endpoint through configuration.

## Using Claude's Skill System for Mocking

Claude's skill architecture supports creating specialized skills that handle specific API interactions. You can build a dedicated skill that manages mock responses for particular services.

Consider a skill that intercepts requests to a payment gateway:

```markdown
---
name: payment-mock
description: "Mocks payment gateway responses for testing"
tools: [Bash, Read, Write]
---

# Payment Mock Skill

This skill intercepts payment gateway calls and returns predictable responses for testing.

## Mock Response Patterns

For test environments, respond with:

- **Successful payment**: Return `{"status": "success", "transaction_id": "TXN_TEST_123"}`
- **Failed payment**: Return `{"status": "failed", "error": "insufficient_funds"}`
- **Pending payment**: Return `{"status": "pending"}`

## Configuration

Set `PAYMENT_GATEWAY_URL=http://localhost:3001/mock` in your environment when testing.
```

This approach works well when your skill logic explicitly calls the mock. For skills using the `tdd` skill for test-driven development, configure your test environment to use mock endpoints.

## Intercepting Requests with Proxy Skills

A more sophisticated approach uses a local proxy that intercepts all HTTP traffic. Tools like `mitmproxy` or simple Node.js proxies can capture and redirect requests based on rules.

Create a proxy skill that wraps your HTTP calls:

```python
import requests
import os

class MockProxy:
    def __init__(self):
        self.mock_mode = os.getenv("MOCK_MODE", "false").lower() == "true"
        self.mock_server = os.getenv("MOCK_SERVER", "http://localhost:8080")
    
    def request(self, method, url, **kwargs):
        if self.mock_mode and url.startswith("https://api.example.com"):
            url = url.replace("https://api.example.com", self.mock_server)
        
        return requests.request(method, url, **kwargs)
```

Your skill code then uses this proxy instead of direct requests calls. Toggle `MOCK_MODE=true` when running tests or developing offline.

## Stubbing with JavaScript and Node.js

For skills written in JavaScript or TypeScript, libraries like `nock` provide powerful request interception:

```javascript
const nock = require('nock');

nock('https://api.external-service.com')
  .get('/users/123')
  .reply(200, {
    id: 123,
    name: 'Test User',
    email: 'test@example.com'
  });

async function fetchUser(userId) {
  const response = await fetch(`https://api.external-service.com/users/${userId}`);
  return response.json();
}
```

This pattern integrates cleanly with skills that run Node.js scripts. Combine with the `pdf` skill for generating test reports, or use with the `frontend-design` skill when mocking API-driven UI components.

## Combining Mocks with Claude Skills

The real power emerges when you combine mocking strategies with Claude's skill system. Use the `supermemory` skill to store mock response templates across sessions. When you need to test a new integration, retrieve the appropriate mock from your knowledge base.

For end-to-end testing workflows, sequence your skills:

1. Use `tdd` skill to define test cases
2. Activate mock servers for external dependencies
3. Run your integration code
4. Verify results against expected outputs

This approach scales from simple unit tests to complex integration scenarios involving multiple external services.

## Best Practices for Reliable Mocks

Match your mock responses to production schemas exactly. Include the same field names, types, and nested structures. When the real API returns pagination, your mock should too.

Version your mocks alongside your code. As APIs evolve, update your mock responses to reflect the current contract. Store mocks in version control so your team shares consistent test data.

Log mock invocations during testing. Knowing which endpoints were called helps debug test failures and identifies missing mock coverage.

## Conclusion

API mocking and stubbing within Claude Code workflows gives you reliable, repeatable testing without external dependencies. Whether you use local servers, proxy interceptors, or library-based request hijacking, the goal remains the same: predictable responses that let you develop and test with confidence.

Build mocks that mirror production contracts, version them with your code, and integrate them smoothly into your skill workflows. Your tests will run faster, fail more predictably, and free you from waiting on third-party services.


## Related Reading

- [What Is the Best Claude Skill for REST API Development?](/claude-skills-guide/what-is-the-best-claude-skill-for-rest-api-development/)
- [Claude Code Tutorials Hub](/claude-skills-guide/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
