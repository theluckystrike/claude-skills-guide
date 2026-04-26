---
layout: default
title: "How to Use npm Nock HTTP Mocking (2026)"
description: "Use npm nock for HTTP mocking in Node.js with Claude Code. Practical examples for intercepting requests and testing APIs efficiently. Tested on Node.js."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, nock, http-mocking, nodejs, testing, tdd]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-nock-http-mocking-nodejs-guide/
geo_optimized: true
---

# Claude Code Nock HTTP Mocking Node.js Guide

Building reliable Node.js applications requires testing HTTP integrations without depending on external services. Nock provides HTTP interception capabilities that make this possible, and when combined with Claude Code's skills, you can create solid testing workflows for your Node.js projects. This guide covers everything from initial setup to advanced patterns for sequential mocks, recording real responses, and integrating Nock into Express application tests.

## What is Nock and Why Use It

Nock is an HTTP mocking library for Node.js that intercepts outgoing HTTP requests at the `http`/`https` module level and returns predefined responses. Instead of making real network calls to APIs like Stripe, GitHub, or your own microservices during tests, Nock simulates those responses locally.

The primary benefits include faster test execution, elimination of network flakiness, ability to test error scenarios that are difficult to reproduce with live APIs, and running tests in CI/CD pipelines without external dependencies or rate limits.

## How Nock Compares to Alternatives

| Tool | Approach | Works With | Best For |
|---|---|---|---|
| Nock | Patches Node.js `http` module | All HTTP libraries using `http` internally | Unit and integration tests |
| MSW (Mock Service Worker) | Service Worker (browser) or Node interceptor | Fetch API, axios, etc. | Shared mocks across frontend and backend |
| WireMock | Standalone HTTP server | Any HTTP client in any language | Polyglot environments |
| `jest.mock()` manual mocks | Mocks the module directly | axios, fetch | When you own the HTTP wrapper |
| `nock-record` / `polly.js` | Records then replays real responses | HTTP clients | Snapshot-style contract testing |

Nock is the right choice when you are writing Node.js unit and integration tests and want zero setup overhead. no separate server process, no shared mock server configuration, just a few lines in your test file.

When you use Nock with Claude Code, you can describe the HTTP interactions you need to mock using natural language, and Claude will generate the appropriate Nock configurations while you work on your implementation.

## Setting Up Nock in Your Node.js Project

Install Nock as a development dependency in your project:

```bash
npm install --save-dev nock
```

For TypeScript projects, Nock ships its own type definitions from version 13 onwards so a separate `@types/nock` package is not needed:

```bash
Nock 13+ includes types. no @types/nock required
npm install --save-dev nock
```

Nock works by monkey-patching the native `http` and `https` modules. Any library that uses these modules internally. axios, node-fetch, got, undici in compatibility mode. will have its requests intercepted. Libraries that use their own TCP stack (such as some gRPC clients) are not affected.

## Verifying Nock is Active

A quick sanity check before writing your first mock:

```javascript
const nock = require('nock');

// Prevent any real HTTP calls from going out. useful in CI
nock.disableNetConnect();

// Allow only localhost connections (for test servers)
nock.disableNetConnect();
nock.enableNetConnect('127.0.0.1');
```

Setting `nock.disableNetConnect()` in a global test setup file means any unmocked HTTP call will throw an error instead of silently hitting a real server. This is the recommended CI configuration. it catches tests that accidentally depend on network access.

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
const { getUser } = require('../src/userService');

describe('getUser', () => {
 beforeAll(() => {
 nock.disableNetConnect();
 });

 afterEach(() => {
 nock.cleanAll();
 });

 afterAll(() => {
 nock.enableNetConnect();
 });

 it('should return user data from API', async () => {
 nock('https://api.example.com')
 .get('/users/123')
 .reply(200, {
 id: '123',
 name: 'John Doe',
 email: 'john@example.com'
 });

 const user = await getUser('123');

 expect(user.name).toBe('John Doe');
 expect(user.email).toBe('john@example.com');
 });
});
```

The `nock.cleanAll()` in `afterEach` is important. it ensures interceptors registered in one test do not bleed into the next.

## Mocking Different HTTP Scenarios

Nock excels at testing various HTTP scenarios that would be difficult to test with live APIs.

## Testing Error Responses

```javascript
it('should handle 404 responses gracefully', async () => {
 nock('https://api.example.com')
 .get('/users/999')
 .reply(404, { error: 'User not found', code: 'USER_NOT_FOUND' });

 await expect(getUser('999')).rejects.toThrow('User not found');
});

it('should handle 500 server errors', async () => {
 nock('https://api.example.com')
 .get('/users/123')
 .reply(500, { error: 'Internal server error' });

 await expect(getUser('123')).rejects.toThrow();
});

it('should handle network-level connection errors', async () => {
 nock('https://api.example.com')
 .get('/users/123')
 .replyWithError('Connection refused');

 await expect(getUser('123')).rejects.toThrow('Connection refused');
});
```

Note the difference between `.reply(500, ...)` (which returns an HTTP error response) and `.replyWithError(...)` (which simulates a connection-level failure like a DNS error or connection reset). Both are important to test.

## Testing Request Headers and Bodies

Nock can assert that your code sends the correct headers and request bodies, not just that it handles responses correctly:

```javascript
it('should send authentication header', async () => {
 nock('https://api.example.com', {
 reqheaders: {
 'Authorization': 'Bearer my-token',
 'Content-Type': 'application/json',
 }
 })
 .post('/users', { name: 'Jane', role: 'editor' })
 .reply(201, { id: '456', name: 'Jane' });

 const result = await createUser({ name: 'Jane', role: 'editor' });
 expect(result.id).toBe('456');
});

it('should send correct query parameters', async () => {
 nock('https://api.example.com')
 .get('/users')
 .query({ page: '1', limit: '20', sort: 'created_at' })
 .reply(200, { users: [], total: 0 });

 const result = await listUsers({ page: 1, limit: 20, sort: 'created_at' });
 expect(result.users).toEqual([]);
});
```

If the interceptor has `reqheaders` defined and your code does not send them, Nock will not match the request and it will either hit the network (if connect is enabled) or throw (if `disableNetConnect` is active). This makes it an implicit assertion on outbound request correctness.

## Simulating Network Delays

Testing timeout handling and slow responses is straightforward with Nock's `.delay()` modifier:

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

it('should timeout after 1 second', async () => {
 nock('https://api.example.com')
 .get('/users/123')
 .delay(3000) // Longer than our client timeout
 .reply(200, { id: '123' });

 // Assuming your HTTP client has a 1 second timeout configured
 await expect(getUser('123')).rejects.toThrow(/timeout/i);
});
```

## Using Claude Code with Nock

The `tdd` skill in Claude Code works particularly well with Nock. When you need to test HTTP-dependent code, you can invoke the skill and describe your API interactions.

Activate the skill by typing:

```
/tdd
```

Then describe what you need:

> "I have a function that calls the GitHub API to fetch repository details. I need tests that verify it handles rate limiting (429 responses with Retry-After headers), authentication failures (401), missing repositories (404), and successful responses with the full repository object."

Claude will generate Nock interceptors for each scenario, complete with proper status codes, response headers, and response bodies. It will also scaffold the corresponding Jest `describe`/`it` blocks and assertions.

This workflow is especially useful when integrating with a new third-party API. Rather than reading documentation to determine what error responses look like, you can paste example API responses directly into the conversation and Claude will build the Nock fixtures from them.

For projects that involve PDF generation from web content, you might combine the `tdd` skill with the `pdf` skill to test scenarios where your application fetches remote data and converts it to PDF format. using Nock to intercept the HTTP fetch so no real network call is needed during tests.

## Advanced Nock Patterns

## Matching with Regular Expressions

When your URL contains dynamic segments (resource IDs, UUIDs, slugs), use regex matching instead of literal paths:

```javascript
nock('https://api.example.com')
 .get(/\/users\/[\w-]+/) // Match any user ID including UUIDs
 .reply(200, (uri) => {
 const id = uri.split('/').pop();
 return { id, name: `User ${id}`, createdAt: new Date().toISOString() };
 });
```

The reply factory function receives the URI and can generate dynamic responses based on path segments, which is useful for building mock APIs that behave like the real thing across a range of inputs.

## Sequential and Conditional Responses

Test retry logic by returning errors on the first call and success on subsequent calls:

```javascript
it('should retry on 503 and succeed', async () => {
 // First call fails
 nock('https://api.example.com')
 .get('/users/123')
 .reply(503, { error: 'Service temporarily unavailable' });

 // Second call succeeds
 nock('https://api.example.com')
 .get('/users/123')
 .reply(200, { id: '123', name: 'John Doe' });

 const user = await getUserWithRetry('123');
 expect(user.name).toBe('John Doe');
});
```

Nock interceptors are consumed in order and each is used once by default. Registering two interceptors for the same path means the first request hits the first interceptor, and the second request hits the second.

## Persisting Mocks for Development

For local development without external services, persist mocks across multiple calls:

```javascript
// test/setup.js. loaded once before all tests
const nock = require('nock');

nock('https://api.example.com')
 .persist()
 .get('/config')
 .reply(200, { featureFlags: { newDashboard: true } });

// This mock will match every GET /config call without being consumed
```

## Intercepting Paginated APIs

APIs that return paginated results require sequential mocks with different query parameters:

```javascript
it('should fetch all pages', async () => {
 nock('https://api.example.com')
 .get('/items')
 .query({ page: 1, limit: 100 })
 .reply(200, {
 items: Array.from({ length: 100 }, (_, i) => ({ id: i + 1 })),
 hasNextPage: true,
 });

 nock('https://api.example.com')
 .get('/items')
 .query({ page: 2, limit: 100 })
 .reply(200, {
 items: Array.from({ length: 50 }, (_, i) => ({ id: i + 101 })),
 hasNextPage: false,
 });

 const allItems = await fetchAllItems();
 expect(allItems).toHaveLength(150);
});
```

## Mocking OAuth Token Exchange

Testing OAuth flows requires intercepting both the token endpoint and subsequent authenticated calls:

```javascript
it('should exchange code for token and fetch user profile', async () => {
 nock('https://auth.example.com')
 .post('/oauth/token', {
 code: 'auth-code-123',
 grant_type: 'authorization_code',
 })
 .reply(200, {
 access_token: 'mock-access-token',
 token_type: 'Bearer',
 expires_in: 3600,
 });

 nock('https://api.example.com', {
 reqheaders: { Authorization: 'Bearer mock-access-token' },
 })
 .get('/me')
 .reply(200, { id: '1', email: 'user@example.com' });

 const profile = await loginWithCode('auth-code-123');
 expect(profile.email).toBe('user@example.com');
});
```

## Combining Nock with Express/Fastify Integration Tests

For comprehensive integration testing of your own HTTP server, combine Supertest (which fires real HTTP requests against a locally started server) with Nock (which intercepts outbound calls from that server to external APIs):

```javascript
const request = require('supertest');
const nock = require('nock');
const app = require('../src/app'); // Your Express app

describe('GET /api/users/:id', () => {
 beforeAll(() => nock.disableNetConnect({ allow: '127.0.0.1' }));
 afterEach(() => nock.cleanAll());
 afterAll(() => nock.enableNetConnect());

 it('returns 200 with user data', async () => {
 // Mock the downstream microservice your Express handler calls
 nock('https://users-service.internal')
 .get('/users/42')
 .reply(200, { id: 42, name: 'Alice', role: 'admin' });

 const response = await request(app)
 .get('/api/users/42')
 .set('Authorization', 'Bearer test-jwt')
 .expect(200);

 expect(response.body.name).toBe('Alice');
 });

 it('returns 404 when downstream returns 404', async () => {
 nock('https://users-service.internal')
 .get('/users/99')
 .reply(404, { error: 'Not found' });

 await request(app)
 .get('/api/users/99')
 .set('Authorization', 'Bearer test-jwt')
 .expect(404);
 });
});
```

This pattern gives you end-to-end coverage of your own routing, middleware, authentication, and error-handling logic while keeping all external dependencies mocked.

## Recording Real Responses as Fixtures

When integrating with a new third-party API, the fastest way to get accurate Nock fixtures is to record real responses once and replay them in tests. The `nock-record` package provides this capability:

```javascript
// One-time recording script. run against real API
const nock = require('nock');

nock.recorder.rec({
 dont_print: true,
 output_objects: true,
});

// Run your actual code
await callRealGitHubApi();

const calls = nock.recorder.play();
require('fs').writeFileSync(
 './test/fixtures/github-api.json',
 JSON.stringify(calls, null, 2)
);
```

Then in tests, load the recorded fixture:

```javascript
const nock = require('nock');
const fixtures = require('./fixtures/github-api.json');

beforeEach(() => {
 nock.define(fixtures);
});
```

This approach is particularly valuable for complex APIs with deeply nested response schemas that would be tedious to write by hand.

## Organizing Nock Fixtures

For large applications with many API integrations, centralize mock definitions to avoid duplication across test files.

A recommended directory structure:

```
test/
 mocks/
 github/
 repo-success.json
 repo-not-found.json
 rate-limited.json
 stripe/
 charge-success.json
 charge-declined.json
 webhook-payment-intent.json
 helpers/
 nock-setup.js <- shared beforeAll/afterEach lifecycle
 integration/
 github-service.test.js
 payment-service.test.js
```

A shared helper keeps lifecycle management consistent:

```javascript
// test/helpers/nock-setup.js
const nock = require('nock');

function setupNock() {
 beforeAll(() => nock.disableNetConnect({ allow: '127.0.0.1' }));
 afterEach(() => {
 // Warn if any interceptors were registered but never used
 const pendingMocks = nock.pendingMocks();
 if (pendingMocks.length) {
 console.warn('Unused nock interceptors:', pendingMocks);
 }
 nock.cleanAll();
 });
 afterAll(() => nock.enableNetConnect());
}

module.exports = { setupNock };
```

Using `nock.pendingMocks()` to warn about unused interceptors catches a subtle class of bugs: when your code stops making a call you expected it to make, stale interceptors silently accumulate.

## Best Practices

Keep your Nock configurations organized by placing them in dedicated fixture files. Name your mock files descriptively, like `mocks/github-api-repository-success.json` or `mocks/stripe-payment-failed.json`.

Always call `nock.cleanAll()` in `afterEach` (not `afterAll`) to prevent mock leakage between tests. A mock registered in one test can silently intercept a request in a later test if you only clean up at the suite level.

Set `nock.disableNetConnect()` globally in CI. This ensures tests never accidentally hit live endpoints, keeps CI fast, and prevents test failures caused by network connectivity issues or rate limits in external services.

Use `.replyWithError()` as well as `.reply(500, ...)`. they test different failure modes. A 500 response exercises your HTTP error handling path; a connection error exercises your network failure path (timeouts, DNS failures, connection resets).

For TypeScript projects, define interfaces for your API response shapes and use them in both your mock data and your type assertions. This ensures your mocks stay in sync with the types your production code depends on.

## Conclusion

Nock provides essential HTTP mocking capabilities for Node.js testing, and when paired with Claude Code's skills like `tdd`, you can rapidly generate comprehensive test coverage for HTTP-dependent code. This combination ensures your applications handle various API scenarios gracefully without relying on external services.

The patterns covered here. error scenarios, header assertions, sequential mocks for retry logic, OAuth flow testing, and Express integration tests. give you the tools to test every HTTP interaction your application depends on. Combined with fixture organization and the `disableNetConnect` discipline, your test suite becomes a reliable safety net that catches regressions without ever touching a live API.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-nock-http-mocking-nodejs-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [What Is the Best Claude Skill for REST API Development?](/what-is-the-best-claude-skill-for-rest-api-development/)
- [Claude Code Tutorials Hub](/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Code Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


