---
layout: default
title: "Claude Code API Mocking and Stubbing Guide"
description: "Master API mocking and stubbing in Claude Code skills. Build reliable test doubles, mock external services, and create deterministic development workflows."
date: 2026-03-14
categories: [guides]
tags: [claude-code, api-mocking, stubbing, testing, development]
author: theluckystrike
reviewed: true
score: 0
permalink: /claude-code-api-mocking-and-stubbing-guide/
---

# Claude Code API Mocking and Stubbing Guide

API mocking and stubbing are essential techniques for building reliable Claude Code skills that interact with external services. When developing skills that need to call third-party APIs, test against real services, or simulate responses, understanding how to properly mock and stub these interactions ensures your skills work consistently across different environments and test scenarios.

This guide covers practical approaches to mocking and stubbing APIs within Claude Code skills, with examples using popular tools and patterns.

## Why API Mocking Matters for Claude Skills

Skills that interact with APIs face several challenges that mocking solves:

- **External dependencies**: Real API calls can fail due to network issues, rate limits, or service outages
- **Test reliability**:depending on live services makes tests flaky and slow
- **Development workflow**: You may need to develop against an API that isn't yet available
- **Cost control**: API calls incur costs; mocking reduces unnecessary spending during testing

The `tdd` skill and similar testing-focused skills benefit greatly from proper API mocking, allowing you to write tests that run reliably without network dependencies.

## Basic API Stubbing with JSON Files

The simplest approach to mocking APIs is creating static JSON response files. This works well for predictable endpoints and when you need deterministic test data.

Create a mock directory structure:

```
.mocks/
  api/
    users/
      list.json
      123.json
    posts/
      recent.json
```

Then in your skill instructions, specify how to use these mocks:

```
When the skill needs to fetch user data:
1. Check if a mock exists at .mocks/api/users/{user_id}.json
2. If it exists, read and return that data instead of making an API call
3. If no mock exists, proceed with the actual API call but log a warning

Mock data format should match the actual API response structure exactly.
```

This pattern works well with skills like `supermemory` that manage data retrieval—you can swap real calls for mock files based on environment configuration.

## Using MSW for JavaScript Projects

[MSW](https://mswjs.io/) (Mock Service Worker) provides a more sophisticated mocking solution that intercepts requests at the network level. For skills that work with JavaScript or Node.js projects, MSW offers a clean approach.

Add MSW to your project:

```bash
npm install msw --save-dev
```

Create a mock handler file:

```javascript
// .claude/mocks/handlers.js
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('https://api.example.com/users', () => {
    return HttpResponse.json({
      users: [
        { id: 1, name: 'Alice', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' }
      ]
    });
  }),
  
  http.get('https://api.example.com/users/:id', ({ params }) => {
    const user = { id: params.id, name: 'Test User', email: 'test@example.com' };
    return HttpResponse.json(user);
  }),
  
  http.post('https://api.example.com/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ ...body, id: 999 }, { status: 201 });
  })
];
```

Initialize MSW in your test setup:

```javascript
// .claude/mocks/browser.js
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

For the `frontend-design` skill, you might include instructions to set up MSW mocks alongside component development, ensuring the frontend can be tested without real backend services.

## HTTP Stubbing with Node.js

For server-side mocking in Node.js environments, you can use libraries like `nock` or `wiremock` (via HTTP). Here's how `nock` works:

```javascript
const nock = require('nock');

nock('https://api.example.com')
  .get('/users')
  .reply(200, [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' }
  ]);

nock('https://api.example.com')
  .post('/users')
  .reply(201, { id: 3, name: 'Charlie', created: true });
```

In your skill instructions, you can guide when to activate mocks:

```
Before running integration tests:
1. If NODE_ENV=test, require nock and activate mocks from .claude/mocks/nock-setup.js
2. The nock setup file should export a function that applies all necessary mocks
3. After tests complete, clean up mocks with nock.cleanAll()

Do not activate mocks in production environments.
```

## Environment-Based Mock Switching

A robust skill should switch between real APIs and mocks based on environment. Use environment variables to control this behavior:

```javascript
const BASE_URL = process.env.API_URL || 'https://api.example.com';
const USE_MOCKS = process.env.USE_MOCKS === 'true';

async function fetchUsers() {
  if (USE_MOCKS) {
    return mockFetchUsers();
  }
  return realFetchUsers();
}

async function mockFetchUsers() {
  const fs = require('fs');
  const data = fs.readFileSync('.mocks/api/users.json', 'utf8');
  return JSON.parse(data);
}

async function realFetchUsers() {
  const response = await fetch(`${BASE_URL}/users`);
  return response.json();
}
```

Your skill can then provide environment-specific guidance:

```
Environment configuration:
- Development: USE_MOCKS=true (use local mock data)
- Staging: USE_MOCKS=false (hit staging API if available)
- Production: USE_MOCKS=false, ensure all calls go to production

Check the .env file in the project root for current configuration.
```

## Mocking with Claude Code Hooks

Claude Code hooks provide another mechanism for intercepting and mocking API calls. You can create a skill that uses hooks to redirect requests:

```yaml
---
name: api-mock
description: Intercepts API calls and returns mock data for testing
tools:
  - Read
  - Bash
  - Write
hooks:
  on_tool_call:
    - name: intercept-http
      condition: "tool_name == 'WebFetch' && url includes 'api.example.com'"
      action: return_mock_response
---

When this skill is active:
1. Monitor all WebFetch calls for API endpoints
2. Match the URL against mock patterns in .mocks/api/
3. Return mock data if a match is found
4. Log each mock substitution for debugging
```

This approach integrates with skills that use `WebFetch` to pull external data, like `supermemory` or research-focused skills.

## Best Practices for API Mocking

Follow these practices to ensure your mocks are reliable and maintainable:

**Match real API responses exactly**: Your mock responses should have the same structure, field types, and nested objects as actual API responses. This prevents subtle bugs when switching from mocks to real APIs.

```
When creating mock data:
1. Copy an actual API response as a template
2. Modify only the values you need to control
3. Preserve all fields even if unused (some code may depend on them)
4. Add a _mock: true flag to identify mocked responses in logs
```

**Version your mocks**: As APIs evolve, maintain versioned mock directories:

```
.mocks/
  v1/
    users.json
  v2/
    users.json
```

Update your skill to reference the correct version based on the API version the project uses.

**Handle errors and edge cases**: Create mocks for error scenarios:

```
.mocks/
  api/
    errors/
      404.json
      500.json
      rate-limited.json
```

Test how your skill handles these conditions rather than only testing success paths.

## Integrating with Testing Skills

The `tdd` skill works particularly well with API mocks because tests can run against controlled, predictable responses. When writing tests:

```javascript
describe('UserService', () => {
  beforeAll(() => {
    // Activate mocks before tests
    nock.disableNetConnect();
    require('./mocks/user-service');
  });
  
  afterAll(() => {
    nock.cleanAll();
    nock.enableNetConnect();
  });
  
  test('fetches user list', async () => {
    const users = await UserService.list();
    expect(users).toHaveLength(2);
    expect(users[0].name).toBe('Alice');
  });
});
```

Include setup and teardown instructions in your skill so tests run cleanly with mocks active.

## Related Skills and Tools

Several Claude skills work well alongside API mocking:

- **tdd**: Write tests against mocked APIs for fast, reliable test execution
- **frontend-design**: Mock backend responses while developing frontend components
- **pdf**: Generate test documentation that includes mock API responses
- **supermemory**: Store and retrieve mock response templates across projects

---

## Related Reading

- [Claude Code WireMock API Mocking Guide](/claude-skills-guide/claude-code-wiremock-api-mocking-guide/) — Using WireMock for more advanced API stubbing scenarios with recording and playback
- [Skill .md File Format Complete Specification](/claude-skills-guide/skill-md-file-format-complete-specification-guide/) — Understanding how to define hooks and tool restrictions for mock-enabled skills
- [Claude Code Hooks Chaining Guide](/claude-skills-guide/claude-code-hooks-chaining-guide/) — Building complex interception chains that include API mocking layers

Built by theluckystrike — More at [zovo.one](https://zovo.one)
