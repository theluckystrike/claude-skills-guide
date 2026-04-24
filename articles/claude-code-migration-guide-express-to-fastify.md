---
layout: default
title: "Migrate Express to Fastify with Claude"
description: "Step-by-step guide to migrate an Express.js application to Fastify using Claude Code. Route conversion, middleware, plugins, and validation."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-migration-guide-express-to-fastify/
reviewed: true
categories: [guides, claude-code]
tags: [express, fastify, migration, node-js, api]
geo_optimized: true
---

# Migrate Express to Fastify with Claude Code

## The Problem

Your Express.js application has grown, and you need better performance, built-in schema validation, and a more structured plugin system. Fastify offers 2-3x better throughput than Express, native TypeScript support, and a schema-first approach. But migrating an existing application is daunting: you need to convert routes, middleware, error handlers, and all the Express-specific patterns.

## Quick Start

Ask Claude Code to analyze your Express app and plan the migration:

```
Read my Express application starting from src/app.ts. Map all routes,
middleware, and plugins. Create a migration plan to convert this to Fastify.
List every file that needs changes and the order to migrate them.
```

## What's Happening

Express and Fastify have different architectures but serve the same purpose. The core differences:

| Express | Fastify |
|---------|---------|
| `app.use(middleware)` | `app.register(plugin)` |
| `req.body` (needs body-parser) | `req.body` (built-in) |
| No validation | JSON Schema validation built-in |
| `next()` for middleware chain | Hooks system (onRequest, preHandler, etc.) |
| `res.json()` | `reply.send()` |
| Callback-based error handling | Async/await native |

Claude Code can systematically convert each pattern because the mapping between Express and Fastify is well-defined.

## Step-by-Step Guide

### Step 1: Install Fastify dependencies

```bash
npm install fastify @fastify/cors @fastify/helmet @fastify/rate-limit @fastify/jwt @fastify/swagger
npm install --save-dev @types/node
```

### Step 2: Convert the app entry point

**Express (before):**

```typescript
// src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { json } from 'express';
import { userRoutes } from './routes/users';
import { projectRoutes } from './routes/projects';
import { errorHandler } from './middleware/errorHandler';

const app = express();

app.use(helmet());
app.use(cors({ origin: 'https://myapp.com' }));
app.use(json({ limit: '10mb' }));

app.use('/api/users', userRoutes);
app.use('/api/projects', projectRoutes);

app.use(errorHandler);

app.listen(3000, () => {
 console.log('Server running on port 3000');
});
```

**Fastify (after):**

```typescript
// src/app.ts
import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { userRoutes } from './routes/users';
import { projectRoutes } from './routes/projects';
import { errorHandler } from './plugins/errorHandler';

const app = Fastify({
 logger: true,
 bodyLimit: 10 * 1024 * 1024, // 10MB
});

// Register plugins
app.register(helmet);
app.register(cors, { origin: 'https://myapp.com' });

// Register routes
app.register(userRoutes, { prefix: '/api/users' });
app.register(projectRoutes, { prefix: '/api/projects' });

// Error handler
app.setErrorHandler(errorHandler);

app.listen({ port: 3000, host: '0.0.0.0' }, (err) => {
 if (err) {
 app.log.error(err);
 process.exit(1);
 }
});

export { app };
```

### Step 3: Convert route handlers

Ask Claude Code to convert routes one file at a time:

```
Convert src/routes/users.ts from Express to Fastify.
Use Fastify's schema validation for request/response.
Convert Express middleware to Fastify hooks.
```

**Express route (before):**

```typescript
// src/routes/users.ts
import { Router, Request, Response, NextFunction } from 'express';
import { body, validationResult } from 'express-validator';
import { authMiddleware } from '../middleware/auth';
import { UserService } from '../services/UserService';

const router = Router();

router.get('/', authMiddleware, async (req: Request, res: Response, next: NextFunction) => {
 try {
 const page = parseInt(req.query.page as string) || 1;
 const limit = parseInt(req.query.limit as string) || 20;
 const users = await UserService.list(page, limit);
 res.json(users);
 } catch (error) {
 next(error);
 }
});

router.post('/',
 authMiddleware,
 body('email').isEmail(),
 body('name').isLength({ min: 1, max: 100 }),
 async (req: Request, res: Response, next: NextFunction) => {
 const errors = validationResult(req);
 if (!errors.isEmpty()) {
 return res.status(400).json({ errors: errors.array() });
 }
 try {
 const user = await UserService.create(req.body);
 res.status(201).json(user);
 } catch (error) {
 next(error);
 }
 }
);

export { router as userRoutes };
```

**Fastify route (after):**

```typescript
// src/routes/users.ts
import { FastifyPluginAsync } from 'fastify';
import { UserService } from '../services/UserService';

const userRoutes: FastifyPluginAsync = async (app) => {
 // Auth hook for all routes in this plugin
 app.addHook('onRequest', async (request, reply) => {
 await request.jwtVerify();
 });

 app.get('/', {
 schema: {
 querystring: {
 type: 'object',
 properties: {
 page: { type: 'integer', minimum: 1, default: 1 },
 limit: { type: 'integer', minimum: 1, maximum: 100, default: 20 },
 },
 },
 response: {
 200: {
 type: 'object',
 properties: {
 data: {
 type: 'array',
 items: {
 type: 'object',
 properties: {
 id: { type: 'string' },
 email: { type: 'string', format: 'email' },
 name: { type: 'string' },
 },
 },
 },
 pagination: {
 type: 'object',
 properties: {
 page: { type: 'integer' },
 limit: { type: 'integer' },
 total: { type: 'integer' },
 },
 },
 },
 },
 },
 },
 handler: async (request, reply) => {
 const { page, limit } = request.query as { page: number; limit: number };
 const users = await UserService.list(page, limit);
 return users;
 },
 });

 app.post('/', {
 schema: {
 body: {
 type: 'object',
 required: ['email', 'name'],
 properties: {
 email: { type: 'string', format: 'email' },
 name: { type: 'string', minLength: 1, maxLength: 100 },
 },
 },
 response: {
 201: {
 type: 'object',
 properties: {
 id: { type: 'string' },
 email: { type: 'string' },
 name: { type: 'string' },
 },
 },
 },
 },
 handler: async (request, reply) => {
 const user = await UserService.create(request.body as { email: string; name: string });
 reply.code(201);
 return user;
 },
 });
};

export { userRoutes };
```

### Step 4: Convert middleware to plugins

Express middleware becomes Fastify plugins with hooks:

**Express auth middleware:**

```typescript
// Express
export function authMiddleware(req, res, next) {
 const token = req.headers.authorization?.split(' ')[1];
 if (!token) return res.status(401).json({ error: 'Unauthorized' });
 try {
 req.user = jwt.verify(token, SECRET);
 next();
 } catch {
 res.status(401).json({ error: 'Invalid token' });
 }
}
```

**Fastify auth plugin:**

```typescript
// Fastify
import fp from 'fastify-plugin';
import jwt from '@fastify/jwt';

export default fp(async (app) => {
 app.register(jwt, { secret: process.env.JWT_SECRET! });

 app.decorate('authenticate', async (request, reply) => {
 try {
 await request.jwtVerify();
 } catch (err) {
 reply.code(401).send({ error: 'Unauthorized' });
 }
 });
});
```

### Step 5: Convert error handling

**Express error handler:**

```typescript
export function errorHandler(err, req, res, next) {
 console.error(err);
 res.status(err.status || 500).json({
 error: err.message || 'Internal server error',
 });
}
```

**Fastify error handler:**

```typescript
import { FastifyError, FastifyReply, FastifyRequest } from 'fastify';

export function errorHandler(
 error: FastifyError,
 request: FastifyRequest,
 reply: FastifyReply
) {
 request.log.error(error);

 const statusCode = error.statusCode ?? 500;
 reply.code(statusCode).send({
 error: statusCode >= 500 ? 'Internal server error' : error.message,
 code: error.code,
 });
}
```

### Step 6: Update tests

Ask Claude Code to update your test suite:

```
Convert my Express supertest tests to work with Fastify.
Use Fastify's built-in inject method instead of supertest.
```

```typescript
// Fastify test using inject (no supertest needed)
import { app } from '../src/app';

describe('GET /api/users', () => {
 it('returns paginated users', async () => {
 const response = await app.inject({
 method: 'GET',
 url: '/api/users?page=1&limit=10',
 headers: {
 authorization: `Bearer ${testToken}`,
 },
 });

 expect(response.statusCode).toBe(200);
 const body = JSON.parse(response.body);
 expect(body.data).toBeDefined();
 expect(body.pagination).toBeDefined();
 });
});
```

### Step 7: Run both in parallel during transition

For a gradual migration, run both servers:

```typescript
// During migration: run Express on 3000, Fastify on 3001
// Use nginx or a load balancer to route migrated endpoints to Fastify
```

Ask Claude Code to track migration progress:

```
List all Express routes and mark which ones have been migrated to Fastify.
Show me the remaining routes that still need conversion.
```

## Prevention

After migration, add Fastify conventions to your CLAUDE.md:

```markdown
## API Framework
- Fastify (not Express)
- All routes must have JSON Schema validation
- Use plugins for cross-cutting concerns, not middleware
- Use Fastify's built-in logger (do not use console.log)
- Register routes as async plugins with FastifyPluginAsync
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-migration-guide-express-to-fastify)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude Code API Endpoint Testing Guide](/claude-code-api-endpoint-testing-guide/)
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/)
- [Before and After Switching to Claude Code Workflow](/before-and-after-switching-to-claude-code-workflow/)


