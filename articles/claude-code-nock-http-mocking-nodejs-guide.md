---



layout: default
title: "Claude Code Nock HTTP Mocking Nodejs Guide"
description: "Learn how to use Nock for HTTP mocking in Node.js with Claude Code. Master intercepting HTTP requests, creating mock endpoints, and testing API integrations."
date: 2026-03-18
author: "Claude Skills Guide"
permalink: /claude-code-nock-http-mocking-nodejs-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, nodejs, testing, http-mocking]
---



# Claude Code Nock HTTP Mocking Nodejs Guide

Nock is a powerful HTTP mocking library for Node.js that allows you to intercept and mock HTTP requests. When combined with Claude Code, you can create reliable tests for your API integrations without relying on external services. This guide covers practical techniques for using Nock effectively with Claude Code for testing Node.js applications.

## Understanding Nock Basics

Nock works by overriding the Node.js `http` and `https` modules, allowing you to intercept outgoing requests and return predefined responses. This is invaluable for testing code that makes HTTP calls to external APIs, third-party services, or even internal microservices.

To get started with Nock, install it as a development dependency:

```bash
npm install nock --save-dev
```

### Simple Request Interception

The most basic use of Nock is intercepting a specific URL and returning a mock response. Here's how you can set up a simple mock:

```javascript
const nock = require('nock');
const axios = require('axios');

// Mock an API endpoint
const scope = nock('https://api.example.com')
  .get('/users')
  .reply(200, [
    { id: 1, name: 'John Doe' },
    { id: 2, name: 'Jane Smith' }
  ]);

// Your code makes the actual request
async function fetchUsers() {
  const response = await axios.get('https://api.example.com/users');
  return response.data;
}

// Test it
fetchUsers().then(users => {
  console.log(users);
});
```

## Setting Up Nock with Claude Code

When working with Claude Code, you can leverage Nock to test your code while receiving intelligent suggestions for improving your test coverage. Here's a typical workflow:

### Step 1: Identify HTTP Dependencies

First, have Claude Code analyze your codebase to identify all HTTP endpoints your code depends on:

```javascript
// Ask Claude to help identify HTTP calls
// Claude can scan your code and suggest which endpoints need mocking
```

### Step 2: Create Mock Scopes

Organize your Nock scopes logically to match your application's API integration points:

```javascript
const nock = require('nock');

// Create reusable scopes for different services
const githubScope = nock('https://api.github.com')
  .persist()  // Keep the mock active for multiple requests
  .get('/users/{username}')
  .reply(200, {
    login: 'theluckystrike',
    public_repos: 42,
    followers: 100
  });

const stripeScope = nock('https://api.stripe.com')
  .post('/v1/charges')
  .reply(200, {
    id: 'ch_1234567890',
    amount: 2000,
    currency: 'usd',
    status: 'succeeded'
  });
```

### Step 3: Scope Filtering for Dynamic URLs

When dealing with dynamic URLs, such as URLs with query parameters or path variables, Nock provides scope filtering:

```javascript
const nock = require('nock');

const scope = nock('https://api.weather.com')
  .filteringPath(path => '/forecast')
  .get('/forecast')
  .reply(200, {
    temperature: 72,
    conditions: 'sunny'
  });
```

## Advanced Nock Patterns

### Matching Headers and Query Parameters

For more precise mocking, you can match specific headers or query parameters:

```javascript
const nock = require('nock');

const scope = nock('https://api.example.com')
  .matchHeader('Authorization', 'Bearer token123')
  .query({ format: 'json', limit: 10 })
  .get('/data')
  .reply(200, { data: 'mocked response' });
```

### Mocking Error Responses

Test your error handling by mocking various HTTP error scenarios:

```javascript
const nock = require('nock');

// Mock a 404 Not Found error
nock('https://api.example.com')
  .get('/missing-resource')
  .reply(404, { error: 'Resource not found' });

// Mock a 500 Internal Server Error
nock('https://api.example.com')
  .get('/server-error')
  .reply(500, { error: 'Internal server error' });

// Mock a network error
nock('https://api.example.com')
  .get('/network-error')
  .replyWithError('Connection refused');
```

### Using Reply With Function

For dynamic responses, you can use a function to generate the reply:

```javascript
const nock = require('nock');

const scope = nock('https://api.example.com')
  .post('/webhooks', body => {
    return body.event === 'payment_received';
  })
  .reply(200, (uri, requestBody) => {
    return {
      status: 'processed',
      receivedAt: new Date().toISOString()
    };
  });
```

## Best Practices for Nock with Claude Code

### 1. Clean Up After Tests

Always clean up Nock interceptors to prevent test pollution:

```javascript
afterEach(() => {
  nock.cleanAll();
  nock.cleanHistory();
});
```

### 2. Use Environment Variables for API URLs

Structure your code to use environment variables for API endpoints, making it easier to switch between real and mocked APIs:

```javascript
const API_BASE = process.env.API_BASE || 'https://api.example.com';

async function getUser(id) {
  const response = await axios.get(`${API_BASE}/users/${id}`);
  return response.data;
}
```

### 3. Disable Network Connections in Tests

Ensure your tests don't make real network calls:

```javascript
beforeEach(() => {
  nock.disableNetConnect();
});

afterEach(() => {
  nock.enableNetConnect();
  nock.cleanAll();
});
```

### 4. Document Your Mock Expectations

When working with Claude Code, document what each mock is testing:

```javascript
/**
 * Mocks GitHub API user endpoint
 * Used for testing user profile display functionality
 * Returns mock user data with known repositories
 */
const githubUserMock = nock('https://api.github.com')
  .get('/users/testuser')
  .reply(200, {
    login: 'testuser',
    name: 'Test User',
    public_repos: 5
  });
```

## Common Pitfalls to Avoid

### Persisting Scopes Accidentally

Be careful with `.persist()` - only use it when you need the same mock to handle multiple requests:

```javascript
// Good: Use persist for retriable operations
const retryableScope = nock('https://api.example.com')
  .persist()
  .get('/data')
  .reply(200, { data: 'cached' });

// Bad: Don't persist for one-off requests unless needed
```

### Not Matching Request Body Correctly

When POSTing data, ensure your mock matches the expected body format:

```javascript
// Correct: Match the exact body structure
nock('https://api.example.com')
  .post('/users', {
    name: 'John',
    email: 'john@example.com'
  })
  .reply(201, { id: 1 });
```

### Forgetting to Clean Between Tests

Always clean Nock state between tests to avoid flaky test results:

```javascript
describe('User API', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  it('fetches user by ID', async () => {
    // test code
  });

  it('creates a new user', async () => {
    // test code
  });
});
```

## Conclusion

Nock is an essential tool for testing Node.js applications that rely on HTTP APIs. By combining Nock with Claude Code's intelligent assistance, you can create comprehensive test suites that verify your API integrations without the complexity of setting up mock servers or relying on external services during testing.

Remember to keep your mocks close to your actual API contracts, clean up after each test, and use environment variables to make your code testable. With these practices, you'll have reliable, fast tests that give you confidence in your application's HTTP integration logic.
