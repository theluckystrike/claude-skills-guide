---
layout: default
title: "Claude Code for Vinxi Server (2026)"
description: "Claude Code for Vinxi Server — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-vinxi-server-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, vinxi, workflow]
---

## The Setup

You are building full-stack JavaScript applications with Vinxi, the server SDK that powers SolidStart and TanStack Start. Vinxi provides a composable server architecture with routers, middleware, and server functions that compile differently based on the target (SSR, API, static). Claude Code can create full-stack apps, but it generates Next.js or Express patterns instead of Vinxi's router-based architecture.

## What Claude Code Gets Wrong By Default

1. **Creates Next.js app directory structure.** Claude writes `app/api/route.ts` and `app/page.tsx` files. Vinxi uses a router-based architecture defined in `app.config.js` — each router handles a different concern (client, server, API).

2. **Uses Express middleware patterns.** Claude adds `app.use(cors())` middleware chains. Vinxi uses h3 event handlers and Nitro-compatible middleware — the middleware API and lifecycle differ from Express.

3. **Ignores server functions.** Claude creates separate API routes for data fetching. Vinxi supports server functions (`"use server"`) that are extracted at build time and turned into API endpoints automatically.

4. **Bundles everything in one build.** Claude creates a single build output. Vinxi separates builds by router — client code, server code, and API code are built independently with different targets and optimizations.

## The CLAUDE.md Configuration

```
# Vinxi Server Project

## Framework
- SDK: Vinxi (full-stack JavaScript server SDK)
- Base: Nitro + Vite composition
- Routers: client, server, API as separate concerns
- Used by: SolidStart, TanStack Start

## Vinxi Rules
- Config: app.config.js defines routers
- Client router: Vite-based SPA/SSR
- Server router: Nitro-based API handlers
- Server functions: "use server" directive
- Middleware: h3-compatible event handlers
- Build: separate outputs per router
- Dev: vinxi dev for unified dev server

## Conventions
- app.config.js for router definitions
- createRouter() for each concern
- Server functions in same file as components
- API routes in server router directory
- Use "use server" for RPC-style server calls
- Middleware via router-level plugins
- vinxi build for production, vinxi dev for development
```

## Workflow Example

You want to create a full-stack app with Vinxi using server functions. Prompt Claude Code:

"Set up a Vinxi app with a client router for React, a server router for API endpoints, and server functions for data fetching. Create a simple todo app where the list component uses a server function to fetch todos and an API route for creating todos."

Claude Code should create `app.config.js` with client and server routers, a React component that calls a `"use server"` function to fetch todos, an API route handler in the server router for POST `/api/todos`, and configure the proper Vite and Nitro settings for each router.

## Common Pitfalls

1. **Server functions leaking to client bundle.** Claude defines server functions without the `"use server"` directive. Without the directive, server code gets bundled into the client — exposing database queries and secrets. Always mark server-only code with `"use server"`.

2. **Router misconfiguration.** Claude puts files in the wrong router's directory. Vinxi routers are isolated — client code in the server router will not be Vite-processed, and server code in the client router gets bundled for the browser.

3. **Missing handler return values.** Claude writes server handlers without returning responses. Vinxi uses h3 event handlers — always return a value or call `sendNoContent(event)`, otherwise the request hangs.

## Related Guides

- [Claude Code for TanStack Router Workflow Guide](/claude-code-for-tanstack-router-workflow-guide/)
- [Claude Code for Hono Framework Workflow Guide](/claude-code-for-hono-framework-workflow-guide/)
- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)

## Related Articles

- [How to Use vLLM Inference Server (2026)](/claude-code-for-vllm-inference-server-workflow/)
- [Claude Code For Lsp Server — Complete Developer Guide](/claude-code-for-lsp-server-implementation-workflow/)
