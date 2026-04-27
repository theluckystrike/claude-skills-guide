---
sitemap: false
layout: default
title: "Claude Code for Kysely — Workflow Guide (2026)"
description: "Claude Code for Kysely — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-kysely-query-builder-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, kysely, workflow]
---

## The Setup

You are using Kysely, the type-safe SQL query builder for TypeScript that generates SQL without the abstraction overhead of a full ORM. Kysely gives you full SQL power with TypeScript autocompletion and compile-time type checking. Claude Code can write Kysely queries and migrations, but it defaults to Knex.js syntax or full ORM patterns.

## What Claude Code Gets Wrong By Default

1. **Writes Knex.js query syntax.** Claude uses `knex('users').where('id', 1)` string-based column references. Kysely uses `db.selectFrom('users').where('id', '=', 1)` with explicit operator arguments and typed column names.

2. **Uses an ORM-style relation API.** Claude writes `User.findOne({ include: ['posts'] })` eager loading. Kysely is a query builder, not an ORM — joins are explicit SQL joins: `db.selectFrom('users').innerJoin('posts', 'posts.userId', 'users.id')`. Learn more in [Claude Code for fd (Find Alternative) — Guide](/claude-code-for-fd-find-alternative-workflow-guide/).

3. **Skips the Database type interface.** Claude queries without defining the TypeScript Database interface. Kysely's type safety comes from a `Database` interface that maps table names to column types — without it, you lose all autocompletion.

4. **Uses string interpolation in queries.** Claude concatenates values into SQL strings. Kysely uses parameterized queries by default — pass values as method arguments, never interpolate them into query strings.

## The CLAUDE.md Configuration

```
# Kysely Query Builder Project

## Architecture
- Query Builder: Kysely (NOT Knex, NOT Prisma)
- Database: PostgreSQL with pg driver
- Types: Database interface in types/database.ts
- Migrations: Kysely migrator with TypeScript migrations

## Kysely Rules
- Define Database interface mapping tables to column types
- Queries: db.selectFrom('table').select(['col1', 'col2'])
- Where clauses need operator: .where('col', '=', value)
- Joins are explicit: .innerJoin('table', 'a.id', 'b.aId')
- Insert: db.insertInto('table').values({ ... }).returning('id')
- Update: db.updateTable('table').set({ ... }).where(...)
- Never use string interpolation — all values are parameterized
- Use $castTo<Type>() for complex query result types

## Conventions
- Database type in src/types/database.ts
- Query functions in src/db/queries/ directory
- Migrations in src/db/migrations/ with timestamp prefix
- Use Kysely CLI: kysely migrate:latest
- Transactions: db.transaction().execute(async (trx) => { ... })
- Complex queries: use the expression builder (eb) for subqueries
```

## Workflow Example

You want to create a complex query with joins and aggregation. Prompt Claude Code:

"Write a Kysely query that gets all users with their post count and most recent post date. Filter to users who have at least 5 posts. Order by post count descending."

Claude Code should produce a query using `db.selectFrom('users')` with a left join to a subquery that aggregates posts by userId, using `eb.fn.count()` for the count, `eb.fn.max()` for latest date, and a `having` clause for the minimum post count, all with proper TypeScript types inferred from the Database interface.

## Common Pitfalls

1. **Forgetting the `execute()` or `executeTakeFirst()` call.** Claude builds queries but forgets to execute them. Kysely queries are lazy — they return a query builder until you call `.execute()` (array) or `.executeTakeFirst()` (single row or undefined).

2. **Type narrowing after `executeTakeFirst`.** Claude uses the result without null checking. `executeTakeFirst()` returns `T | undefined`. Always check for undefined before accessing properties, or use `executeTakeFirstOrThrow()` if the row must exist.

3. **Migration file naming.** Claude creates migration files with descriptive names like `add-users-table.ts`. Kysely's migrator processes files in alphabetical order, so prefix with timestamps (`20260418_add_users_table.ts`) to ensure correct ordering.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code Drizzle ORM TypeScript Database Workflow](/claude-code-drizzle-orm-typescript-database-workflow/)

## Related Articles

- [Claude Code for LitServe Lightning Workflow Guide](/claude-code-for-litserve-lightning-workflow-guide/)
- [Claude Code for Reentrancy Guard Workflow](/claude-code-for-reentrancy-guard-workflow/)
- [Claude Code For Mitre Attck — Complete Developer Guide](/claude-code-for-mitre-attck-workflow-guide/)
- [Claude Code with Astro Content Collections Workflow](/claude-code-with-astro-content-collections-workflow/)
- [How to Use Web3Modal Wallet Integration (2026)](/claude-code-for-web3modal-wallet-workflow/)
- [Claude Code for Synthetic Monitoring Workflow Guide](/claude-code-for-synthetic-monitoring-workflow-guide/)
- [Claude Code Prompt Management Workflow Guide](/claude-code-prompt-management-workflow-guide/)
- [Claude Code for FreeRTOS Workflow Tutorial Guide](/claude-code-for-freertos-workflow-tutorial-guide/)


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
