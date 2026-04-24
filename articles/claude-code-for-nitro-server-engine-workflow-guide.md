---
layout: default
title: "Claude Code for Nitro Server Engine"
description: "Build universal servers with Nitro and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-nitro-server-engine-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, nitro, workflow]
---

## The Setup

You are building server-side applications with Nitro, the universal server engine that powers Nuxt 3 but works standalone. Nitro provides file-based routing, auto-imports, and deploys to any platform (Node.js, Cloudflare Workers, Vercel, Deno, Bun) with zero configuration changes. Claude Code can build Node.js servers, but it generates Express.js boilerplate instead of Nitro's convention-based approach.

## What Claude Code Gets Wrong By Default

1. **Creates Express app with manual routing.** Claude writes `app.get('/api/users', handler)` route registrations. Nitro uses file-based routing — `server/routes/api/users.get.ts` automatically creates a GET endpoint at `/api/users`.

2. **Manually imports dependencies.** Claude adds `import { readBody } from 'h3'` at the top of every file. Nitro auto-imports h3 utilities — `readBody`, `getQuery`, `setResponseStatus` are available without imports.

3. **Writes platform-specific deployment code.** Claude creates Dockerfile or Vercel configuration. Nitro has preset-based deployment — `NITRO_PRESET=cloudflare-workers npx nitropack build` targets any platform without config changes.

4. **Uses `node:fs` for storage.** Claude reads/writes files with the fs module. Nitro has a built-in storage layer (`useStorage()`) that abstracts over file system, Redis, KV stores, and more — switching storage backends requires no code changes.

## The CLAUDE.md Configuration

```
# Nitro Server Project

## Server
- Engine: Nitro (universal server engine)
- Routing: file-based in server/routes/
- Runtime: h3 HTTP framework
- Deploy: presets for any platform

## Nitro Rules
- Routes: server/routes/[path].[method].ts
- API: server/api/[path].ts (auto-prefixed /api)
- Middleware: server/middleware/[name].ts
- Plugins: server/plugins/[name].ts
- Storage: useStorage() for KV operations
- Auto-imports: h3 utilities available without import
- Tasks: server/tasks/[name].ts for background jobs

## Conventions
- Route file: export default defineEventHandler(async (event) => {})
- GET params: getQuery(event)
- POST body: readBody(event)
- Route params: getRouterParam(event, 'id')
- Storage: useStorage('db').getItem('key')
- Deployment: NITRO_PRESET=target npx nitropack build
- Config: nitro.config.ts for global settings
```

## Workflow Example

You want to build a REST API with Nitro that deploys to Cloudflare Workers. Prompt Claude Code:

"Create a Nitro REST API for a todo app with CRUD endpoints. Use file-based routing, Nitro's storage layer for persistence, and proper error handling. The API should deploy to Cloudflare Workers without any configuration changes."

Claude Code should create `server/api/todos/index.get.ts` for listing, `server/api/todos/index.post.ts` for creating, `server/api/todos/[id].get.ts` for reading, `server/api/todos/[id].put.ts` for updating, and `server/api/todos/[id].delete.ts` for deleting — all using `useStorage()` and `defineEventHandler()`.

## Common Pitfalls

1. **Using Node.js APIs in edge deployments.** Claude uses `fs`, `path`, or `child_process` in route handlers. These Node.js APIs are not available in Cloudflare Workers or Deno Deploy. Use Nitro's abstractions (`useStorage()`, `$fetch()`) which work across all presets.

2. **Missing error handling with createError.** Claude throws generic JavaScript errors. Nitro uses `createError({ statusCode: 404, message: 'Not found' })` for proper HTTP error responses — generic throws result in 500 errors without useful messages.

3. **Not using server tasks for background work.** Claude runs long operations inside route handlers. Nitro has `server/tasks/` for background jobs that can be triggered via API or scheduled — keep route handlers fast and offload heavy work to tasks.

## Related Guides

- [Claude Code for Hono Framework Workflow Guide](/claude-code-for-hono-framework-workflow-guide/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
