---
layout: default
title: "Claude Code for Val Town (2026)"
description: "Claude Code for Val Town — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-val-town-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, val-town, workflow]
---

## The Setup

You are building serverless functions, scheduled jobs, and HTTP endpoints using Val Town — a platform where each function (called a "val") is independently deployable and shareable. Claude Code can write vals for APIs, cron jobs, and email handlers, but it treats Val Town like a traditional Node.js project instead of respecting its unique module system and runtime constraints.

## What Claude Code Gets Wrong By Default

1. **Creates project structure with package.json.** Claude scaffolds a full Node.js project with dependencies. Val Town vals are single files that import from URLs or the `@std` library. There is no `node_modules` or build step.

2. **Uses CommonJS require statements.** Claude writes `const express = require('express')`. Val Town runs pure ESM with Deno-style URL imports. Use `import` syntax with `npm:` specifiers or `https://` URLs.

3. **Writes Express/Fastify route handlers.** Claude generates full server frameworks for HTTP endpoints. Val Town HTTP vals export a default function that receives a `Request` and returns a `Response` — the Web API standard, no framework needed.

4. **Ignores Val Town's built-in blob and SQLite storage.** Claude reaches for external databases. Val Town provides `@std/blob` for key-value storage and `@std/sqlite` for SQL queries built into the platform at no extra cost.

## The CLAUDE.md Configuration

```
# Val Town Project

## Runtime
- Platform: Val Town (Deno-based serverless)
- Modules: ESM only, import via npm: specifier or URL
- Storage: @std/blob (key-value), @std/sqlite (SQL)
- HTTP: Export default function(req: Request): Response

## Val Town Rules
- Each val is a single file — no multi-file projects
- HTTP vals: export default async function(req: Request)
- Cron vals: export default async function(interval: Interval)
- Email vals: export default async function(email: Email)
- Import npm packages with "npm:package-name" prefix
- Use Deno.env.get("KEY") for environment variables
- Store persistent data with @std/blob or @std/sqlite
- No file system access — use blob storage instead

## Conventions
- Val names are camelCase: myApiEndpoint, dailyReport
- Keep vals under 200 lines — split logic into helper vals
- Use console.email() for notifications from cron vals
- Reference other vals with @username/valName imports
- Never hardcode secrets — use Val Town environment variables
```

## Workflow Example

You want to create a webhook endpoint that stores GitHub star events. Prompt Claude Code:

"Create a Val Town HTTP val that receives GitHub webhook POST requests for star events, stores the stargazer username and timestamp in SQLite, and returns the total star count as JSON."

Claude Code should produce a single val file that exports a default async function, parses the webhook payload, uses `@std/sqlite` to insert the event and query the count, and returns a `new Response(JSON.stringify({...}))` with the total.

## Common Pitfalls

1. **Using `fetch` for val-to-val communication.** Claude calls other vals via HTTP fetch. For vals you own, import them directly with `import { helper } from "@username/helperVal"` — it is faster and does not count as an HTTP request.

2. **SQLite schema drift.** Claude creates tables in the val body, running CREATE TABLE on every invocation. Use `CREATE TABLE IF NOT EXISTS` or check for table existence first, since vals can be invoked thousands of times.

3. **Blob storage size limits.** Claude stores large datasets in `@std/blob`. Each blob value has a size limit and there are total storage limits per account. For larger data, use an external database and store only the connection config in environment variables.

## Related Guides

**Find commands →** Search all commands in our [Command Reference](/commands/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)


## Common Questions

### How do I get started with claude code for val town?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
