---
layout: default
title: "Claude Code API Mocking Development Guide"
description: "A practical guide to API mocking with Claude Code. Learn how to stub HTTP responses, test error scenarios, and integrate mocking into your development."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, api-mocking, testing, development, http-mocking]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-api-mocking-development-guide/
---

# Claude Code API Mocking Development Guide

API mocking is a fundamental technique for developers who need to test code without relying on external services. Whether you are building integrations with third-party APIs, testing error handling logic, or working in an environment with limited network access, mocking lets you control exactly how your application responds to HTTP requests. This guide shows you how to incorporate API mocking into your Claude Code workflow using practical patterns and tools that integrate smoothly with your development process.

## Why API Mocking Matters

When your application depends on external APIs, testing becomes complicated. External services may be unavailable, rate-limited, or return inconsistent data during development. You might also need to test specific error conditions that are difficult to reproduce with real services, such as 500 errors, timeouts, or malformed responses.

Mocking solves these problems by letting you define expected responses on your own terms. Instead of waiting for a payment gateway to return a specific error code or hoping a third-party service experiences a outage, you create stubs that behave exactly as you need. This approach accelerates development cycles and makes your tests more reliable and repeatable.

## Setting Up a Local Mock Server

The simplest way to mock APIs in your Claude Code workflow is to run a local mock server. Several tools work well for this purpose, but a common choice is a lightweight HTTP server that responds to configured routes.

Start by creating a simple mock server using Node.js. First, initialize a new project and install Express:

```bash
mkdir api-mock && cd api-mock
npm init -y
npm install express
```

Create a file named `mock-server.js` with the following content:

```javascript
const express = require('express');
const app = express();
app.use(express.json());

// Stub for successful user response
app.get('/api/users/:id', (req, res) => {
  res.json({
    id: req.params.id,
    name: 'Test User',
    email: 'test@example.com'
  });
});

// Stub for payment processing
app.post('/api/payments', (req, res) => {
  const { amount, currency } = req.body;
  
  if (!amount || amount <= 0) {
    return res.status(400).json({
      error: 'Invalid amount'
    });
  }
  
  res.json({
    transactionId: 'txn_' + Math.random().toString(36).substr(2, 9),
    status: 'completed',
    amount,
    currency
  });
});

// Stub for rate limit error
app.get('/api/rate-limited', (req, res) => {
  res.status(429).json({
    error: 'Rate limit exceeded',
    retryAfter: 60
  });
});

app.listen(3000, () => {
  console.log('Mock server running on http://localhost:3000');
});
```

Start the server with:

```bash
node mock-server.js
```

Your mock server now listens on port 3000, returning predefined responses for different endpoints. You can add more routes as needed, configuring them to match your application's actual API calls.

## Integrating Mocks with Your Application

Once your mock server runs, point your application to it instead of the production API. The method depends on your tech stack, but environment variables are the most common approach.

For a Node.js application using Axios, you might configure the base URL like this:

```javascript
const API_BASE = process.env.API_BASE || 'https://api.example.com';

const client = axios.create({
  baseURL: API_BASE,
  timeout: 5000
});
```

During development or testing, set the environment variable to your mock server:

```bash
export API_BASE=http://localhost:3000
```

Your application now talks to the mock server, returning controlled responses without making any external network calls.

## Testing Error Scenarios

One of the most valuable aspects of mocking is the ability to test error conditions that are otherwise difficult to trigger. Your mock server can simulate various HTTP status codes, network timeouts, and malformed responses.

Extend your mock server to handle these scenarios:

```javascript
// Simulate server error
app.get('/api/server-error', (req, res) => {
  res.status(500).json({
    error: 'Internal server error'
  });
});

// Simulate connection timeout
app.get('/api/timeout', (req, res) => {
  setTimeout(() => {
    res.json({ status: 'ok' });
  }, 30000);
});

// Simulate malformed JSON
app.get('/api/malformed', (req, res) => {
  res.set('Content-Type', 'application/json');
  res.send('{ invalid json }');
});
```

With these endpoints, you can verify that your application handles failures gracefully. Check that error messages display correctly, that retry logic activates when appropriate, and that your logging captures the necessary information for debugging.

## Automating Mock Configuration

Claude Code excels at automating repetitive tasks, and mock server configuration is no exception. You can create a skill that generates mock configurations based on your API specifications, then applies them to your mock server automatically.

For example, if you document your API responses in a JSON schema or OpenAPI specification, Claude Code can parse that file and generate corresponding mock endpoints. This approach ensures your mocks stay in sync with your actual API contracts.

Combine this with the **tdd** skill to run your tests against the mock server, verifying that your code handles both successful and error responses correctly. The **pdf** skill can also help by extracting API documentation from existing PDF files and generating mock configurations from documented endpoint specifications.

## Using Claude Skills for Enhanced Mocking

Several Claude skills improve your API mocking workflow. The **supermemory** skill helps you maintain context across development sessions, remembering which mock configurations you have used for different test scenarios. This is particularly useful when working on complex integrations that require multiple mock setups.

The **frontend-design** skill benefits from mocking when testing UI components that depend on API data. You can mock various response scenarios and verify that your components render correctly under different conditions.

For projects using the **nock** library directly in Node.js tests, you can generate nock configurations programmatically. This approach lets you define mocks alongside your test files without running a separate server.

## Cleaning Up and Best Practices

When you finish testing, stop your mock server to free up resources:

```bash
# Find and kill the mock server process
pkill -f "node mock-server.js"
```

Follow these best practices for effective API mocking:

- **Keep mocks simple** — Start with basic responses and add complexity only as needed for your tests
- **Version your mocks** — As your API evolves, maintain corresponding versions of your mock configurations
- **Document mock behavior** — Clearly note what each mock endpoint returns and under what conditions
- **Use mock servers for development** — They provide faster feedback than waiting for external services

## Summary

API mocking transforms how you develop and test applications that depend on external services. By running a local mock server, you gain control over HTTP responses, can test edge cases including errors and timeouts, and reduce reliance on network connectivity. Claude Code's bash execution and file handling capabilities make it straightforward to start, configure, and manage mock servers as part of your regular workflow.

Combine mocking with Claude skills like **tdd** for test-driven workflows, **supermemory** for persistent context, and **pdf** for extracting API specifications from documentation. These tools work together to create a robust development environment where you can build reliable integrations without waiting for external services.

## Related Reading

- [Claude Code API Contract Testing Guide](/claude-skills-guide/claude-code-api-contract-testing-guide/) — Contract testing and mocking work together
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/) — Mocking enables TDD for external dependencies
- [Claude Code API Backward Compatibility Guide](/claude-skills-guide/claude-code-api-backward-compatibility-guide/) — Mocks help test backward compatibility
- [Claude Skills Tutorials Hub](/claude-skills-guide/tutorials-hub/) — More testing workflow guides

Built by theluckystrike — More at [zovo.one](https://zovo.one)
