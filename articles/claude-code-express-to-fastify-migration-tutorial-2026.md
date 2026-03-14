---
layout: default
title: "Express to Fastify Migration with Claude Code (2026)"
description: "Migrate Express.js applications to Fastify using Claude Code. Step-by-step process, code conversion patterns, and automated migration workflows."
date: 2026-03-13
categories: [tutorials]
tags: [claude-code, claude-skills, express, fastify, migration, nodejs, javascript]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-express-to-fastify-migration-tutorial-2026/
---

# Claude Code Express to Fastify Migration Tutorial 2026

[Fastify has become the preferred choice for Node.js developers seeking better performance](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/), built-in TypeScript support, and a more modern API. If you're maintaining an Express.js application in 2026, migrating to Fastify can reduce response times by up to 40% while providing better schema validation and plugin architecture. This tutorial shows you how to use Claude Code and its ecosystem of skills to streamline the migration process.

## Why Migrate from Express to Fastify

Express.js served the Node.js community well for over a decade, but Fastify addresses many of its shortcomings. Fastify offers serialization at roughly three times the speed of Express, native support for async/await without wrapper libraries, and a schema-based validation system that eliminates manual input checking. The plugin system is more intuitive, and the TypeScript support is first-class rather than an afterthought.

Before starting your migration, ensure your current Express application has adequate test coverage. The [**tdd** skill](/claude-skills-guide/best-claude-skills-for-developers-2026/) from Claude Code can help you establish test patterns if your project lacks them. Run your existing test suite to establish a baseline, then begin the incremental migration.

## Setting Up Your Migration Environment

[Create a parallel Fastify project alongside your existing Express application](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) This approach lets you migrate route by route without disrupting production traffic.

```bash
# Initialize new Fastify project
npm init fastify@latest myapp-fastify
cd myapp-fastify

# Install dependencies matching your Express app
npm install express@^4.18.0
```

The migration works best when you copy your existing Express route handlers and adapt them to Fastify's interface. The [**supermemory** skill](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) helps maintain context across your migration sessions, remembering which routes you've converted and any issues encountered.

## Converting Route Handlers

Express and Fastify share similar routing syntax, but the request/response objects differ significantly. Here's a side-by-side comparison:

**Express Handler:**
```javascript
app.get('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  const user = getUserById(userId);
  res.json(user);
});
```

**Fastify Handler:**
```javascript
fastify.get('/api/users/:id', async (request, reply) => {
  const userId = request.params.id;
  const user = await getUserById(userId);
  return user;
});
```

The key differences: Fastify uses `request` instead of `req`, `reply` instead of `res`, and supports direct return values instead of calling `res.json()`. For complex migrations, the **frontend-design** skill can help generate consistent handler patterns across your codebase.

## Handling Middleware and Plugins

Express middleware doesn't work directly in Fastify. You have two options: wrap Express middleware using `fastify-express` or rewrite using Fastify's native plugin system.

### Option 1: Wrapping Express Middleware

```javascript
const fastify = require('fastify')({ logger: true });
const express = require('express');
const cookieParser = require('cookie-parser');

fastify.register(require('fastify-express'));
fastify.use(cookieParser());
```

This approach provides quick compatibility but doesn't deliver Fastify's full performance benefits.

### Option 2: Native Fastify Plugins

For better performance, convert middleware to Fastify plugins:

```javascript
const fp = require('fastify-plugin');

async function cookiePlugin(fastify, options) {
  fastify.decorateRequest('cookies', {});
  
  fastify.addHook('onRequest', async (request, reply) => {
    request.cookies = request.headers.cookie
      ? Object.fromEntries(request.headers.cookie.split('; ').map(c => c.split('=')))
      : {};
  });
}

fastify.register(fp(cookiePlugin));
```

The **pdf** skill can generate migration documentation as you progress, capturing decisions and code changes for your team.

## Schema-Based Validation

Fastify's JSON Schema validation replaces Express route-level validation. Define schemas alongside your routes:

```javascript
const userSchema = {
  params: {
    type: 'object',
    properties: {
      id: { type: 'string', pattern: '^[0-9]+$' }
    },
    required: ['id']
  },
  response: {
    200: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string' },
        email: { type: 'string', format: 'email' }
      }
    }
  }
};

fastify.get('/api/users/:id', { schema: userSchema }, async (request, reply) => {
  return await getUserById(request.params.id);
});
```

This approach eliminates manual validation code and provides automatic documentation generation.

## Error Handling Differences

Express error handling uses middleware with four parameters. Fastify uses a different pattern with custom error handlers:

```javascript
// Express style
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong' });
});

// Fastify style
fastify.setErrorHandler((error, request, reply) => {
  request.log.error(error);
  const statusCode = error.statusCode || 500;
  reply.code(statusCode).send({ error: error.message });
});
```

## Testing the Migration

The **tdd** skill accelerates your migration testing by generating comprehensive test suites. Create parallel tests for both implementations during the transition:

```bash
# Run both servers on different ports
# Express on 3000, Fastify on 3001

# Test Fastify routes
curl http://localhost:3001/api/users/123
```

Compare response times, status codes, and payload formats between implementations. The **canvas-design** skill can help visualize performance metrics if you need to present findings to stakeholders.

## Incremental Migration Strategy

Rather than a complete rewrite, migrate route by route:

1. Set up Fastify alongside Express in the same repository
2. Create a proxy that routes traffic based on path prefix
3. Migrate non-critical routes first (health checks, static content)
4. Migrate API endpoints in order of complexity
5. Run canary deployments with a percentage of traffic

```javascript
// Simple proxy setup
app.use('/fastify', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true
}));
```

This strategy reduces risk and lets you validate performance improvements incrementally.

## Performance Verification

After migrating key routes, benchmark using tools like autocannon or wrk:

```bash
# Install autocannon
npm i -g autocannon

# Benchmark Fastify
autocannon -c 100 -d 10 http://localhost:3001/api/users/1
```

Compare results against your Express baseline. Most teams see significant improvements in p99 latency after completing the migration.

## Conclusion

Migrating from Express to Fastify requires thoughtful refactoring but delivers substantial performance and developer experience improvements. Claude Code's ecosystem—including the **tdd** skill for test-driven migration, **supermemory** for tracking progress, **pdf** for documentation, and **frontend-design** for code patterns—makes the process more manageable. Start with non-critical routes, establish validation schemas early, and verify performance at each step.
---

## Related Reading

- [Best Claude Skills for Developers 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — The tdd and supermemory skills power migration workflows
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — Trigger skills automatically during migration and refactoring tasks
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Manage token usage during long migration sessions

Built by theluckystrike — More at [zovo.one](https://zovo.one)
