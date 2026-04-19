---
layout: default
title: "Express to Fastify Migration with Claude Code (2026)"
description: "Migrate Express.js applications to Fastify using Claude Code. Step-by-step process, code conversion patterns, and automated migration workflows."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, express, fastify, migration, nodejs, javascript]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-express-to-fastify-migration-tutorial-2026/
geo_optimized: true
---

# Claude Code Express to Fastify Migration Tutorial 2026

[Fastify has become the preferred choice for Node.js developers seeking better performance](/best-claude-code-skills-to-install-first-2026/), built-in TypeScript support, and a more modern API. If you're maintaining an Express.js application in 2026, migrating to Fastify can reduce response times by up to 40% while providing better schema validation and plugin architecture. This tutorial shows you how to use Claude Code and its ecosystem of skills to streamline the migration process.

## Why Migrate from Express to Fastify

Express.js served the Node.js community well for over a decade, but Fastify addresses many of its shortcomings. Fastify offers serialization at roughly three times the speed of Express, native support for async/await without wrapper libraries, and a schema-based validation system that eliminates manual input checking. The plugin system is more intuitive, and the TypeScript support is first-class rather than an afterthought.

## Performance Comparison

The numbers are not marginal. Benchmarks from the Fastify project and independent tests consistently show:

| Framework | Requests/sec (simple JSON) | Latency p99 | Memory (idle) |
|-----------|:--------------------------:|:-----------:|:-------------:|
| Express 4.x | ~15,000 | ~12 ms | ~45 MB |
| Fastify 4.x | ~45,000 | ~4 ms | ~38 MB |
| Fastify 5.x | ~52,000 | ~3.5 ms | ~36 MB |

These figures are from a single-core `autocannon` benchmark against a simple JSON endpoint on Node.js 22. Real-world differences depend on your route complexity, database I/O, and middleware stack. but the trend holds across nearly every benchmark configuration.

## Feature Comparison

| Feature | Express 4.x | Fastify 4/5 |
|---------|:-----------:|:-----------:|
| Async/await native support | No (needs wrapper) | Yes |
| JSON Schema validation | No (manual or library) | Built-in |
| Auto serialization | No | Yes |
| TypeScript types | DefinitelyTyped (@types) | Built-in |
| Plugin encapsulation | No | Yes (scope isolation) |
| OpenAPI generation | Manual | Via fastify-swagger |
| Built-in logging | No | Yes (pino) |
| Hook system | Middleware chain | Named lifecycle hooks |

Before starting your migration, ensure your current Express application has adequate test coverage. The [tdd skill](/best-claude-skills-for-developers-2026/) from Claude Code can help you establish test patterns if your project lacks them. Run your existing test suite to establish a baseline, then begin the incremental migration.

## Setting Up Your Migration Environment

[Create a parallel Fastify project alongside your existing Express application](/claude-tdd-skill-test-driven-development-workflow/) This approach lets you migrate route by route without disrupting production traffic.

```bash
Initialize new Fastify project
npm init fastify@latest myapp-fastify
cd myapp-fastify

Install dependencies matching your Express app
npm install express@^4.18.0
```

For a greenfield Fastify setup without the scaffolding tool:

```bash
mkdir myapp-fastify && cd myapp-fastify
npm init -y
npm install fastify
npm install --save-dev @types/node typescript tsx
```

A minimal working Fastify server to confirm your environment:

```javascript
// server.js
const fastify = require('fastify')({ logger: true });

fastify.get('/health', async (request, reply) => {
 return { status: 'ok', timestamp: new Date().toISOString() };
});

const start = async () => {
 try {
 await fastify.listen({ port: 3001, host: '0.0.0.0' });
 } catch (err) {
 fastify.log.error(err);
 process.exit(1);
 }
};

start();
```

```bash
node server.js
curl http://localhost:3001/health
{"status":"ok","timestamp":"2026-03-13T10:00:00.000Z"}
```

The migration works best when you copy your existing Express route handlers and adapt them to Fastify's interface. The [supermemory skill](/claude-skills-token-optimization-reduce-api-costs/) helps maintain context across your migration sessions, remembering which routes you've converted and any issues encountered.

## Converting Route Handlers

Express and Fastify share similar routing syntax, but the request/response objects differ significantly. Here's a side-by-side comparison:

Express Handler:
```javascript
app.get('/api/users/:id', (req, res) => {
 const userId = req.params.id;
 const user = getUserById(userId);
 res.json(user);
});
```

Fastify Handler:
```javascript
fastify.get('/api/users/:id', async (request, reply) => {
 const userId = request.params.id;
 const user = await getUserById(userId);
 return user;
});
```

The key differences: Fastify uses `request` instead of `req`, `reply` instead of `res`, and supports direct return values instead of calling `res.json()`. For complex migrations, the frontend-design skill can help generate consistent handler patterns across your codebase.

## Full Route Object Reference

Understanding every property difference prevents subtle bugs during migration:

| Express | Fastify | Notes |
|---------|---------|-------|
| `req.params` | `request.params` | Identical shape |
| `req.query` | `request.query` | Identical shape |
| `req.body` | `request.body` | Requires `@fastify/formbody` for form data |
| `req.headers` | `request.headers` | Identical shape |
| `req.ip` | `request.ip` | Same, but reads from `X-Forwarded-For` if `trustProxy` set |
| `req.hostname` | `request.hostname` | Same |
| `res.json(data)` | `return data` or `reply.send(data)` | Both work in Fastify |
| `res.status(code)` | `reply.code(code)` | Chainable: `reply.code(201).send(data)` |
| `res.set(header, value)` | `reply.header(header, value)` | Same chaining |
| `res.redirect(url)` | `reply.redirect(url)` | Same |
| `res.sendFile(path)` | `reply.sendFile(path)` | Requires `@fastify/static` |

## Converting POST Handlers with Body Parsing

Express uses `express.json()` middleware globally. Fastify parses JSON by default:

```javascript
// Express. requires middleware
app.use(express.json());
app.post('/api/users', (req, res) => {
 const { name, email } = req.body;
 const user = createUser({ name, email });
 res.status(201).json(user);
});

// Fastify. no middleware needed for JSON
fastify.post('/api/users', async (request, reply) => {
 const { name, email } = request.body;
 const user = await createUser({ name, email });
 reply.code(201);
 return user;
});
```

For `multipart/form-data` (file uploads), add `@fastify/multipart`:

```bash
npm install @fastify/multipart
```

```javascript
const multipart = require('@fastify/multipart');
fastify.register(multipart);

fastify.post('/upload', async (request, reply) => {
 const data = await request.file();
 const buffer = await data.toBuffer();
 // process buffer...
 return { filename: data.filename, size: buffer.length };
});
```

## Handling Middleware and Plugins

Express middleware doesn't work directly in Fastify. You have two options: wrap Express middleware using `fastify-express` or rewrite using Fastify's native plugin system.

## Option 1: Wrapping Express Middleware

```javascript
const fastify = require('fastify')({ logger: true });
const express = require('express');
const cookieParser = require('cookie-parser');

fastify.register(require('fastify-express'));
fastify.use(cookieParser());
```

This approach provides quick compatibility but doesn't deliver Fastify's full performance benefits.

## Option 2: Native Fastify Plugins

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

`fastify-plugin` (`fp`) unwraps the plugin from Fastify's scope encapsulation, making the decorator visible to the entire application. Without `fp`, decorators and hooks added inside a plugin are scoped to that plugin's child context only.

## Common Express Middleware to Fastify Plugin Mappings

| Express Middleware | Fastify Equivalent | Install Command |
|--------------------|--------------------|-----------------|
| `cookie-parser` | `@fastify/cookie` | `npm i @fastify/cookie` |
| `cors` | `@fastify/cors` | `npm i @fastify/cors` |
| `helmet` | `@fastify/helmet` | `npm i @fastify/helmet` |
| `express-session` | `@fastify/session` | `npm i @fastify/session` |
| `express.static()` | `@fastify/static` | `npm i @fastify/static` |
| `multer` | `@fastify/multipart` | `npm i @fastify/multipart` |
| `compression` | `@fastify/compress` | `npm i @fastify/compress` |
| `express-rate-limit` | `@fastify/rate-limit` | `npm i @fastify/rate-limit` |
| JWT verification | `@fastify/jwt` | `npm i @fastify/jwt` |

Most official packages are maintained by the Fastify core team and follow the same plugin interface, so configuration is consistent across all of them.

## Registering Common Plugins

```javascript
const fastify = require('fastify')({ logger: true });

// CORS
await fastify.register(require('@fastify/cors'), {
 origin: process.env.ALLOWED_ORIGINS?.split(',') || true,
 credentials: true
});

// Helmet (security headers)
await fastify.register(require('@fastify/helmet'));

// Rate limiting
await fastify.register(require('@fastify/rate-limit'), {
 max: 100,
 timeWindow: '1 minute'
});

// JWT
await fastify.register(require('@fastify/jwt'), {
 secret: process.env.JWT_SECRET
});

// Static files
await fastify.register(require('@fastify/static'), {
 root: path.join(__dirname, 'public'),
 prefix: '/public/'
});
```

The pdf skill can generate migration documentation as you progress, capturing decisions and code changes for your team.

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

## Replacing Express-Validator

A common migration challenge is replacing `express-validator` logic with Fastify schemas. Here's a concrete before/after:

```javascript
// Express with express-validator
const { body, validationResult } = require('express-validator');

app.post('/api/posts',
 body('title').notEmpty().isLength({ max: 200 }),
 body('content').notEmpty(),
 body('tags').isArray().optional(),
 (req, res) => {
 const errors = validationResult(req);
 if (!errors.isEmpty()) {
 return res.status(400).json({ errors: errors.array() });
 }
 const post = createPost(req.body);
 res.status(201).json(post);
 }
);

// Fastify with JSON Schema
const createPostSchema = {
 body: {
 type: 'object',
 required: ['title', 'content'],
 properties: {
 title: { type: 'string', minLength: 1, maxLength: 200 },
 content: { type: 'string', minLength: 1 },
 tags: { type: 'array', items: { type: 'string' } }
 },
 additionalProperties: false
 },
 response: {
 201: {
 type: 'object',
 properties: {
 id: { type: 'string' },
 title: { type: 'string' },
 content: { type: 'string' },
 createdAt: { type: 'string', format: 'date-time' }
 }
 }
 }
};

fastify.post('/api/posts', { schema: createPostSchema }, async (request, reply) => {
 const post = await createPost(request.body);
 reply.code(201);
 return post;
});
```

Fastify automatically returns a `400` with a descriptive error message if the request body doesn't match the schema. no validation middleware needed.

## Reusing Schemas with $ref

For larger applications with many routes sharing common types, use `$ref` to avoid duplication:

```javascript
fastify.addSchema({
 $id: 'UserResponse',
 type: 'object',
 properties: {
 id: { type: 'string' },
 name: { type: 'string' },
 email: { type: 'string', format: 'email' },
 createdAt: { type: 'string', format: 'date-time' }
 }
});

// Reference the shared schema in any route
fastify.get('/api/users/:id', {
 schema: {
 params: { type: 'object', properties: { id: { type: 'string' } } },
 response: { 200: { $ref: 'UserResponse#' } }
 }
}, async (request, reply) => {
 return await getUserById(request.params.id);
});

fastify.get('/api/users/me', {
 schema: {
 response: { 200: { $ref: 'UserResponse#' } }
 }
}, async (request, reply) => {
 return await getCurrentUser(request.user.id);
});
```

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

## Structured Error Handling with Custom Error Classes

Fastify's `setErrorHandler` integrates cleanly with custom error hierarchies:

```javascript
// Custom error classes
class NotFoundError extends Error {
 constructor(resource, id) {
 super(`${resource} with id ${id} not found`);
 this.name = 'NotFoundError';
 this.statusCode = 404;
 }
}

class ValidationError extends Error {
 constructor(message, fields) {
 super(message);
 this.name = 'ValidationError';
 this.statusCode = 400;
 this.fields = fields;
 }
}

class UnauthorizedError extends Error {
 constructor(message = 'Unauthorized') {
 super(message);
 this.name = 'UnauthorizedError';
 this.statusCode = 401;
 }
}

// Central error handler
fastify.setErrorHandler((error, request, reply) => {
 const statusCode = error.statusCode || 500;

 if (statusCode >= 500) {
 request.log.error({ err: error }, 'Internal server error');
 } else {
 request.log.warn({ err: error }, 'Client error');
 }

 const response = {
 error: error.name || 'Error',
 message: statusCode < 500 ? error.message : 'Internal server error',
 statusCode
 };

 if (error.fields) {
 response.fields = error.fields;
 }

 reply.code(statusCode).send(response);
});

// Route that throws a typed error
fastify.get('/api/users/:id', async (request, reply) => {
 const user = await getUserById(request.params.id);
 if (!user) {
 throw new NotFoundError('User', request.params.id);
 }
 return user;
});
```

## 404 Handler

Express uses `app.use()` at the end of the middleware chain as a catch-all. Fastify has a dedicated `setNotFoundHandler`:

```javascript
// Express
app.use((req, res) => {
 res.status(404).json({ error: 'Route not found' });
});

// Fastify
fastify.setNotFoundHandler((request, reply) => {
 reply.code(404).send({
 error: 'Not Found',
 message: `Route ${request.method} ${request.url} not found`,
 statusCode: 404
 });
});
```

## Testing the Migration

The tdd skill accelerates your migration testing by generating comprehensive test suites. Create parallel tests for both implementations during the transition:

```bash
Run both servers on different ports
Express on 3000, Fastify on 3001

Test Fastify routes
curl http://localhost:3001/api/users/123
```

## Writing Tests with fastify.inject

Fastify's built-in `inject` method lets you test routes without starting a real HTTP server. significantly faster than Express testing with supertest:

```javascript
// Install test runner
npm install --save-dev tap # or jest, vitest

// test/users.test.js
const tap = require('tap');
const buildApp = require('../app'); // factory function that returns fastify instance

tap.test('GET /api/users/:id', async (t) => {
 const app = buildApp();
 await app.ready();

 // Successful fetch
 const validRes = await app.inject({
 method: 'GET',
 url: '/api/users/1'
 });
 t.equal(validRes.statusCode, 200);
 t.match(JSON.parse(validRes.body), { id: '1' });

 // Not found
 const notFoundRes = await app.inject({
 method: 'GET',
 url: '/api/users/99999'
 });
 t.equal(notFoundRes.statusCode, 404);

 // Invalid param format (schema validation)
 const badParamRes = await app.inject({
 method: 'GET',
 url: '/api/users/not-a-number'
 });
 t.equal(badParamRes.statusCode, 400);

 await app.close();
 t.end();
});
```

The key is structuring your Fastify app as a factory function rather than a module-level singleton:

```javascript
// app.js. factory pattern for testability
const fastify = require('fastify');

function buildApp(opts = {}) {
 const app = fastify({ logger: opts.logger ?? false });

 app.register(require('./routes/users'));
 app.register(require('./routes/posts'));
 // ... other routes

 return app;
}

module.exports = buildApp;

// server.js. entry point
const buildApp = require('./app');

const app = buildApp({ logger: true });
app.listen({ port: process.env.PORT || 3000, host: '0.0.0.0' });
```

Compare response times, status codes, and payload formats between implementations. The canvas-design skill can help visualize performance metrics if you need to present findings to stakeholders.

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

## Migration Tracking Checklist Pattern

With the supermemory skill tracking your progress, maintain a migration checklist in code comments:

```javascript
// routes/index.js
// Migration status:
// [x] GET /health . migrated 2026-03-10
// [x] GET /api/users . migrated 2026-03-11
// [x] GET /api/users/:id . migrated 2026-03-11
// [x] POST /api/users . migrated 2026-03-12
// [ ] PUT /api/users/:id . pending
// [ ] DELETE /api/users/:id. pending
// [ ] GET /api/posts . pending (depends on pagination refactor)
// [ ] POST /api/upload . pending (multipart refactor needed)
```

This pattern pairs well with Claude Code sessions. paste the checklist at the start of each session and update it as you go.

## Routing Strategy During Transition

Use NGINX or a lightweight Node proxy to split traffic without touching application code:

```nginx
nginx.conf. route by path prefix during migration
upstream express_app {
 server localhost:3000;
}

upstream fastify_app {
 server localhost:3001;
}

server {
 listen 80;

 # Migrated routes go to Fastify
 location /api/users {
 proxy_pass http://fastify_app;
 }

 # Everything else stays on Express during transition
 location / {
 proxy_pass http://express_app;
 }
}
```

This strategy reduces risk and lets you validate performance improvements incrementally without deploying two separate services to production.

## Performance Verification

After migrating key routes, benchmark using tools like autocannon or wrk:

```bash
Install autocannon
npm i -g autocannon

Benchmark Fastify
autocannon -c 100 -d 10 http://localhost:3001/api/users/1
```

## Side-by-Side Benchmark Script

Run both servers and compare automatically:

```bash
#!/bin/bash
benchmark.sh. compare Express and Fastify on the same route

DURATION=15
CONNECTIONS=100
ROUTE="/api/users/1"

echo "=== Express (port 3000) ==="
autocannon -c $CONNECTIONS -d $DURATION --json http://localhost:3000$ROUTE | \
 jq '{requests: .requests.total, rps: .requests.average, latency_p99: .latency.p99}'

echo ""
echo "=== Fastify (port 3001) ==="
autocannon -c $CONNECTIONS -d $DURATION --json http://localhost:3001$ROUTE | \
 jq '{requests: .requests.total, rps: .requests.average, latency_p99: .latency.p99}'
```

Compare results against your Express baseline. Most teams see significant improvements in p99 latency after completing the migration.

## What to Measure

Focus on these metrics when validating the migration:

| Metric | Where to Look | Target |
|--------|--------------|--------|
| p50 latency | `autocannon` output | Consistent improvement vs Express |
| p99 latency | `autocannon` output | The number that matters for user experience |
| Requests/second | `autocannon` output | Should increase vs Express baseline |
| Memory usage | `process.memoryUsage()` or `/metrics` endpoint | Should be equal or lower |
| Error rate | Response codes during load test | Must be 0% at sustained load |
| Startup time | `time node server.js` | Fastify is typically faster to start |

## Conclusion

Migrating from Express to Fastify requires thoughtful refactoring but delivers substantial performance and developer experience improvements. Claude Code's ecosystem, including the tdd skill for test-driven migration, supermemory for tracking progress, pdf for documentation, and frontend-design for code patterns, makes the process more manageable. Start with non-critical routes, establish validation schemas early, and verify performance at each step.

The incremental approach is the key to a low-risk migration. Migrate one route group at a time, keep the Express server running alongside Fastify until every route is converted and verified, and use the proxy layer to split traffic without a big-bang cutover. By the time you decommission the Express instance, every route will have been individually validated in production traffic.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-express-to-fastify-migration-tutorial-2026)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Skills for Developers 2026](/best-claude-skills-for-developers-2026/). The tdd and supermemory skills power migration workflows
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). Trigger skills automatically during migration and refactoring tasks
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Manage token usage during long migration sessions
- [How to Use TypeORM Entities Relations Migration (2026)](/claude-code-typeorm-entities-relations-migration-workflow/)
- [Claude Code Struts to Spring Boot Migration Workflow](/claude-code-struts-to-spring-boot-migration-workflow/)
- [Claude Code Next.js App Router — Complete Developer Guide](/claude-code-nextjs-app-router-migration-guide/)
- [Claude Code MongoDB Aggregation Pipeline Workflow Guide](/claude-code-mongodb-aggregation-pipeline-workflow-guide/)
- [Claude Code for Kotlin Multiplatform — Guide](/claude-code-for-kotlin-multiplatform-workflow-guide/)
- [Claude Code for TanStack Form — Workflow Guide](/claude-code-for-tanstack-form-workflow-guide/)
- [How to Use TypeORM Query Builder Patterns with Claude Code](/claude-code-typeorm-query-builder-advanced-patterns-guide/)
- [Claude Code for Wormhole Bridge Workflow Guide](/claude-code-for-wormhole-bridge-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


