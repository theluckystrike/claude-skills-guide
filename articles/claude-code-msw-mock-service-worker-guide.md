---
layout: default
title: "Claude Code MSW Mock Service Worker Guide"
description: "Learn how to use MSW (Mock Service Worker) with Claude Code for API mocking, frontend development, and testing. Practical examples and workflow integration."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, msw, mock-service-worker, api-mocking, testing, frontend-development]
author: theluckystrike
reviewed: true
score: 7
permalink: /claude-code-msw-mock-service-worker-guide/
---

# Claude Code MSW Mock Service Worker Guide

Mock Service Worker (MSW) has become the standard for intercepting network requests in browser and Node.js environments. When combined with Claude Code, you get a powerful development workflow where AI assistance helps you create, maintain, and debug API mocks efficiently. This guide covers practical approaches to using MSW with Claude Code for frontend development and testing.

## Setting Up MSW in Your Project

Before integrating with Claude Code, you need MSW installed in your project. The setup process involves installing the package and generating service worker files. MSW version 2.x uses a slightly different approach than earlier versions, so ensure you follow the current documentation.

Install MSW as a development dependency:

```bash
npm install msw --save-dev
```

Initialize the service worker files:

```bash
npx msw init ./public --save
```

This creates the necessary service worker script in your public directory. The next step involves creating your mock handlers that define how network requests get intercepted.

## Creating Mock Handlers with Claude Code

When you need to create mock handlers, Claude Code can accelerate the process significantly. Describe your API endpoints and expected responses, and Claude helps generate the handler code.

For example, to mock a user API endpoint, your handler would look like:

```javascript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('https://api.example.com/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
    ]);
  }),
  http.post('https://api.example.com/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: 3, ...body },
      { status: 201 }
    );
  })
];
```

Claude Code can help you expand these handlers to cover edge cases, error responses, and more complex scenarios. When working on a new feature, describe the expected API contract to Claude, and it generates comprehensive mock handlers.

## Integrating MSW with Test Environments

Testing is where MSW truly shines, and combining it with Claude's testing capabilities creates a robust development workflow. The tdd skill in Claude Code works well with MSW to create test-first development patterns.

Set up MSW in your test file:

```javascript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

Configure your test setup to start and reset the server:

```javascript
import { beforeAll, afterAll, afterEach } from 'vitest';
import { server } from './server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

With this setup, each test runs with a clean mock server state. Claude Code can help you write tests that verify your components handle various API responses correctly.

## Using the frontend-design Skill with MSW

The frontend-design skill in Claude Code complements MSW nicely when building component libraries. When prototyping UI components that fetch data, you can use MSW to provide consistent mock data while designing the interface.

For instance, when building a user profile component, set up your mock handler first:

```javascript
http.get('/api/profile', () => {
  return HttpResponse.json({
    username: 'developer',
    avatar: 'https://example.com/avatar.png',
    bio: 'Full-stack developer',
    joined: '2024-01-15'
  });
});
```

Then work with the frontend-design skill to iterate on the component structure while MSW handles the data layer. This separation of concerns lets you focus on UI/UX decisions without worrying about backend availability.

## Advanced MSW Patterns with Claude Code

As your application grows, your mock infrastructure needs to scale. Claude Code can help you implement advanced patterns like conditional handlers, response delays, and layered mocks.

### Conditional Responses Based on Request Headers

```javascript
http.get('/api/data', ({ request }) => {
  const authHeader = request.headers.get('Authorization');
  
  if (!authHeader) {
    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }
  
  return HttpResponse.json({ data: 'Protected content' });
});
```

### Simulating Network Latency

```javascript
http.get('/api/slow-endpoint', async () => {
  await new Promise(resolve => setTimeout(resolve, 2000));
  return HttpResponse.json({ message: 'Delayed response' });
});
```

### Using Query Parameters

```javascript
http.get('/api/users', ({ request }) => {
  const url = new URL(request.url);
  const role = url.searchParams.get('role');
  
  const users = [
    { id: 1, name: 'Admin User', role: 'admin' },
    { id: 2, name: 'Regular User', role: 'user' }
  ];
  
  const filtered = role 
    ? users.filter(u => u.role === role)
    : users;
  
  return HttpResponse.json(filtered);
});
```

These patterns become valuable when testing different application states or demonstrating loading scenarios.

## MSW with the supermemory Skill

For larger projects with complex API contracts, maintaining mock consistency across components and tests becomes challenging. The supermemory skill can help you track API versions, endpoint changes, and mock updates over time.

When working on long-term projects, use supermemory to document your mock configurations:

```markdown
# API Mocks Documentation

## User API
- GET /api/users - Returns user list
- POST /api/users - Creates new user
- GET /api/users/:id - Returns single user

## Known Issues
- Mock delay of 500ms on /api/users for loading states
```

This documentation stays searchable and helps team members understand the mock behavior without diving into handler code.

## Production Considerations

While MSW excels in development and testing, some teams use it in production for demo environments or when API access is restricted. For production use, ensure your mock handlers accurately reflect your actual API behavior.

Consider environment-specific configurations:

```javascript
const isDevelopment = process.env.NODE_ENV === 'development';

export const handlers = isDevelopment 
  ? [...devHandlers] 
  : [];
```

This approach ensures mocks only activate in appropriate environments.

## Debugging MSW with Claude Code

When mocks don't behave as expected, debugging becomes essential. MSW provides detailed console output about intercepted requests. Share these logs with Claude Code to diagnose issues:

1. Check the request URL matches your handler definition
2. Verify HTTP method matches
3. Confirm response format matches what your component expects
4. Review any custom middleware or response modifiers

Claude Code can analyze your handler code and suggest corrections based on the error messages you encounter.

## Conclusion

MSW combined with Claude Code creates a powerful development workflow for frontend applications. Whether you're prototyping new features, writing tests with the tdd skill, or designing components with frontend-design, mock APIs provide the consistency and control you need. Start with simple handlers and gradually adopt advanced patterns as your project complexity grows.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
