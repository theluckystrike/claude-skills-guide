---
sitemap: false
layout: default
title: "Claude Code for Convex — Workflow Guide (2026)"
description: "Claude Code for Convex — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-convex-backend-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, convex, workflow]
---

## The Setup

You are building a reactive backend with Convex where mutations, queries, and actions automatically sync to connected clients. Claude Code can scaffold Convex functions, manage schema definitions, and wire up real-time subscriptions, but it needs explicit guidance about Convex's unique server function model and its distinction from traditional REST APIs.

## What Claude Code Gets Wrong By Default

1. **Generates REST endpoints instead of Convex functions.** Claude defaults to Express-style route handlers when you ask for backend logic. Convex uses exported function declarations with `mutation()`, `query()`, and `action()` wrappers — not HTTP handlers.

2. **Uses raw database calls instead of the Convex query builder.** Claude tries to write SQL or Prisma-style queries. Convex uses `ctx.db.query("tableName").filter(...)` with its own chainable API that does not support raw SQL.

3. **Misses the `v` validator import.** Convex requires argument validation using its built-in `v` module from `convex/values`. Claude often skips validation entirely or imports Zod, which does not work in Convex server functions.

4. **Puts server logic in the wrong directory.** Convex functions must live in the `convex/` directory. Claude frequently creates files in `src/api/` or `server/` which Convex ignores completely.

## The CLAUDE.md Configuration

```
# Convex Backend Project

## Architecture
- Backend: Convex (convex/ directory contains all server functions)
- Frontend: React with convex/react hooks
- Schema: convex/schema.ts defines all tables
- Functions: convex/*.ts files export query(), mutation(), action()

## Convex Rules
- All server functions must be in convex/ directory
- Import validators from "convex/values" using { v }
- Use ctx.db for database operations, never raw SQL
- Queries are reactive — no manual refetch needed
- Mutations must be deterministic (no Date.now(), use ctx.scheduler)
- Actions can call external APIs but cannot write to DB directly
- Use internal functions with internalMutation for action DB writes

## Conventions
- One file per domain (convex/users.ts, convex/messages.ts)
- Export handler name matches the function purpose (getUser, createMessage)
- Always validate arguments with args: { field: v.string() }
- Never import Node.js modules in query/mutation files
- Use convex/http.ts for any HTTP endpoint needs
```

## Workflow Example

You want to add a new "projects" table with CRUD operations. Prompt Claude Code:

"Create a projects table in the Convex schema with name, description, and ownerId fields. Then create query and mutation functions for listing projects by owner and creating new projects."

Claude Code should produce `convex/schema.ts` updates with the table definition using `defineTable()`, plus a `convex/projects.ts` file exporting `list` as a `query()` and `create` as a `mutation()`, both with proper `v` validators on their arguments.

## Common Pitfalls

1. **Scheduling in mutations.** Claude tries to use `setTimeout` inside mutations. Convex mutations cannot use timers — use `ctx.scheduler.runAfter()` to schedule delayed work.

2. **Importing between function types.** Claude imports queries inside mutations for reuse. Convex does not allow calling queries from mutations directly. Use `ctx.db` calls in both, or extract shared logic into plain helper functions.

3. **File upload handling.** Claude generates multipart form parsing code. Convex uses `storage.generateUploadUrl()` on the client side and `storage.getUrl()` for retrieval — there is no server-side file parsing.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code for Criterion Benchmarking Workflow Guide](/claude-code-for-criterion-benchmarking-workflow-guide/)
- [Claude Code LaunchDarkly Targeting Rules Setup Workflow](/claude-code-launchdarkly-targeting-rules-setup-workflow/)
- [Claude Code GitBook Documentation Workflow](/claude-code-gitbook-documentation-workflow/)
- [Claude Code Structured Logging Best Practices Workflow](/claude-code-structured-logging-best-practices-workflow/)
- [Claude Code Terragrunt Modules — Complete Developer Guide](/claude-code-terragrunt-modules-workflow/)
- [Claude Code for Arrow Flight Workflow Tutorial](/claude-code-for-arrow-flight-workflow-tutorial/)
- [Claude Code Jupyter Notebook Analysis Workflow Guide](/claude-code-jupyter-notebook-analysis-workflow-guide/)
- [Claude Code for Hygen Code Generation Workflow](/claude-code-for-hygen-code-generation-workflow/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
