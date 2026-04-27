---
sitemap: false
layout: default
title: "Claude Code for PowerSync (2026)"
description: "Claude Code for PowerSync — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-powersync-offline-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, powersync, workflow]
---

## The Setup

You are building an offline-first application using PowerSync to sync a local SQLite database with your backend Postgres. PowerSync handles bidirectional sync with conflict resolution so your app works without network connectivity. Claude Code can generate sync rules, local queries, and upload handlers, but it consistently misunderstands the local-first data flow.

## What Claude Code Gets Wrong By Default

1. **Fetches data from the server on every render.** Claude writes `fetch('/api/items')` calls in components. With PowerSync, data lives in a local SQLite database. You query it locally using `db.getAll()` or `db.watch()` — network requests are handled by the sync engine automatically.

2. **Skips the sync rules configuration.** PowerSync requires a `sync-rules.yaml` file that defines which tables and rows sync to each client. Claude ignores this entirely and assumes all data is available locally.

3. **Uses Prisma or Drizzle for local queries.** Claude tries to use server-side ORMs for local database access. PowerSync uses its own query API or raw SQL against the local SQLite instance.

4. **Handles conflicts manually with timestamps.** Claude builds last-write-wins logic with `updatedAt` comparisons. PowerSync has built-in conflict resolution through its CRUD upload queue — you define the upload handler, not the merge strategy.

## The CLAUDE.md Configuration

```
# PowerSync Offline-First App

## Architecture
- Sync: PowerSync (@powersync/web or @powersync/react-native)
- Backend DB: Supabase Postgres
- Local DB: SQLite (managed by PowerSync)
- Sync rules: sync-rules.yaml defines client-side data scope

## PowerSync Rules
- Never fetch data from server in components — query local DB
- Use db.watch('SELECT ...') for reactive queries
- Use db.execute() for local writes (INSERT/UPDATE/DELETE)
- Upload handler in upload.ts pushes local changes to backend
- Sync rules define which rows each user gets (row-level security)
- Schema defined in schema.ts using PowerSync column() definitions
- Local writes are optimistic — they appear instantly, sync later

## Conventions
- Local schema in lib/powersync/schema.ts
- Upload connector in lib/powersync/upload.ts
- Sync rules in sync-rules.yaml at project root
- Queries use raw SQL strings, not ORM methods
- Always handle the offline case — no loading spinners for local data
```

## Workflow Example

You want to add a tasks feature that works offline. Prompt Claude Code:

"Create a tasks table in the PowerSync local schema with title, completed, and assigneeId fields. Add the sync rule, write the upload handler for Supabase, and create a React hook that watches tasks for the current user."

Claude Code should produce the PowerSync schema definition in `schema.ts`, a sync rule in `sync-rules.yaml` filtering by `assigneeId`, an upload handler that calls Supabase's REST API to push changes, and a `useTasks()` hook using `db.watch()` with a SQL query.

## Common Pitfalls

1. **Not queuing writes during offline.** Claude tries to POST changes immediately and shows errors offline. PowerSync automatically queues local writes and syncs when reconnected — just write to the local DB and trust the upload handler.

2. **Watching queries without cleanup.** Claude subscribes with `db.watch()` but never unsubscribes. The watch returns an abort controller or cleanup function that must be called when the component unmounts to prevent memory leaks.

3. **Sync rule parameter mismatches.** Claude defines sync rules referencing `user_id` but the token contains `sub` as the user identifier. The parameter names in sync rules must match exactly what PowerSync receives from your authentication JWT.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)
- [Claude Code for Yjs CRDT Workflow Guide](/claude-code-for-yjs-crdt-workflow-guide/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)


## Common Questions

### How do I get started with claude code for powersync?

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
