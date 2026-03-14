---
layout: default
title: "Claude Code Nock HTTP Mocking Node.js Guide"
description: "Learn how to use Nock for HTTP mocking in Node.js with Claude Code. Practical examples for intercepting HTTP requests, testing APIs, and building reliable test suites."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, nock, http-mocking, nodejs, testing, tdd]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-nock-http-mocking-nodejs-guide/
---

# Claude Code Nock HTTP Mocking Node.js Guide

Building reliable Node.js applications requires testing HTTP integrations without depending on external services. Nock provides HTTP interception capabilities that make this possible, and when combined with Claude Code's skills, you can create robust testing workflows for your Node.js projects.

## What is Nock and Why Use It

Nock is an HTTP mocking library for Node.js that intercepts outgoing HTTP requests and returns predefined responses. Instead of making real network calls to APIs like Stripe, GitHub, or your own microservices during tests, Nock simulates those responses locally.

The primary benefits include faster test execution, elimination of network flakiness, ability to test error scenarios that are difficult to reproduce with live APIs, and running tests in CI/CD pipelines without external dependencies.

When you use Nock with Claude Code, you can describe the HTTP interactions you need to mock using natural language, and Claude will generate the appropriate Nock configurations while you work on your implementation.

## Setting Up Nock in Your Node.js Project

Install Nock as a development dependency in your project:

```bash
npm install --save-dev nock
```

For TypeScript projects, you may need the type definitions:

```bash
npm install --save-dev @types/nock
```

Nock works by intercepting requests made through the native `http` module, as well as libraries like `axios` and `node-fetch` that use `http` under the hood.

## Basic Nock Interception Example

Consider a simple function that fetches user data from an external API:

```javascript
// src/userService.js
const https = require('https');

async function getUser(userId) {
  return new Promise((resolve, reject) => {
    https.get(`https://api.example.com/users/${userId}`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    }).on('error', reject);
  });
}

module.exports = { getUser };
```

To test this with Nock, create a test file:

```javascript
// tests/userService.test.js
const nock = require('nock');
const { getUser = require('../src/userService');

describe('getUser', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  it('should return user data from API', async () => {
    // Set up the mock
    nock('https://api.example.com')
      .get('/users/123')
      .reply(200, {
        id: '123',
        name: 'John Doe',
        email: 'john@example.com'
      });

    const user = await getUser('123');
    
    expect(user.name).toBe('John Doe');
  });
});
```

## Mocking Different HTTP Scenarios

Nock excels at testing various HTTP scenarios that would be difficult to test with live APIs.

### Testing Error Responses

```javascript
it('should handle API errors', async () => {
  nock('https://api.example.com')
    .get('/users/999')
    .reply(404, { error: 'User not found' });

  await expect(getUser('999')).rejects.toThrow();
});
```

### Testing Request Headers and Bodies

```javascript
it('should send authentication header', async () => {
  nock('https://api.example.com', {
    reqheaders: {
      'Authorization': 'Bearer my-token'
    }
  })
  .post('/users', { name: 'Jane' })
  .reply(201, { id: '456', name: 'Jane' });

  const result = await createUser({ name: 'Jane' });
  expect(result.id).toBe('456');
});
```

### Simulating Network Delays

```javascript
it('should handle slow API responses', async () => {
  nock('https://api.example.com')
    .get('/users/123')
    .delay(2000) // 2 second delay
    .reply(200, { id: '123', name: 'Slow User' });

  const start = Date.now();
  await getUser('123');
  const duration = Date.now() - start;
  
  expect(duration).toBeGreaterThanOrEqual(2000);
});
```

## Using Claude Code with Nock

The tdd skill in Claude Code works particularly well with Nock. When you need to test HTTP-dependent code, you can invoke the skill and describe your API interactions.

Activate the skill by typing:

```
/tdd
```

Then describe what you need:

> "I have a function that calls the GitHub API to fetch repository details. I need tests that verify it handles rate limiting (429 responses), authentication failures (401), and successful responses with the repository data."

Claude will generate Nock interceptors for each scenario, complete with proper status codes and response bodies.

For projects that involve PDF generation from web content, you might combine the tdd skill with the pdf skill to test scenarios where your application fetches data and converts it to PDF format.

## Advanced Nock Patterns

### Matching with Regular Expressions

```javascript
nock('https://api.example.com')
  .get(/\/users\/\d+/) // Match any user ID
  .reply(200, (uri) => {
    const id = uri.match(/\/users\/(\d+)/)[1];
    return { id, name: `User ${id}` };
  });
```

### Persisting Mocks for Development

For local development without external services:

```javascript
nock('https://api.example.com')
  .persist()
  .get('/users/me')
  .reply(200, { id: '1', name: 'Dev User' });
```

### Mocking HTTPS with Custom Certificates

```javascript
nock('https://api.example.com', { 'allowUnmocked': false })
  .get('/users')
  .reply(200, [{ id: '1', name: 'Test User' }]);
```

## Combining Nock with Integration Testing

For comprehensive testing, combine Nock with integration tests using the supermemory skill to maintain context across test runs, or with the frontend-design skill if your Node.js application serves a frontend.

When testing Express or Fastify applications, you can use Nock to mock external API calls while your route handlers execute normally, giving you confidence that both your routing logic and external integrations work correctly.

## Best Practices

Keep your Nock configurations organized by placing them in dedicated fixture files. Name your mock files descriptively, like `mocks/github-api-repository-success.json` or `mocks/stripe-payment-failed.json`.

Use `nock.cleanAll()` in your test cleanup to prevent mock leakage between tests. For complex applications, consider creating helper functions that set up common mock patterns.

## Conclusion

Nock provides essential HTTP mocking capabilities for Node.js testing, and when paired with Claude Code's skills like tdd, you can rapidly generate comprehensive test coverage for HTTP-dependent code. This combination ensures your applications handle various API scenarios gracefully without relying on external services.

The ability to simulate success, error, and edge-case responses gives you confidence in your code's robustness while keeping your test suite fast and reliable.

---


## Related Reading

- [What Is the Best Claude Skill for REST API Development?](/claude-skills-guide/what-is-the-best-claude-skill-for-rest-api-development/)
- [Claude Code Tutorials Hub](/claude-skills-guide/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
