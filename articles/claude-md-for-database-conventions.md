---
title: "CLAUDE.md for Database Conventions — Schema, Queries, and Migration Rules (2026)"
description: "How to write CLAUDE.md rules for database naming, query patterns, migration safety, and ORM usage that Claude Code follows consistently."
permalink: /claude-md-database-conventions/
render_with_liquid: false
categories: [claude-md, patterns]
tags: [claude-md, database, conventions, migrations, orm, claude-code]
last_updated: 2026-04-19
---

## Why Database Rules Need to Be Explicit

Claude Code generates database code that works -- but "works" is a low bar for database operations. Without explicit conventions, Claude might create a column named `userId` in one migration and `user_id` in the next. It might generate a query that does a full table scan when an indexed lookup exists. It might create a migration that locks a table for minutes in production.

CLAUDE.md prevents these problems by encoding your database conventions as rules Claude checks against every piece of database code it writes.

## Schema Naming Conventions

```markdown
## Database Schema Rules

### Naming
- Tables: plural snake_case (user_profiles, order_items)
- Columns: singular snake_case (created_at, user_id, email_address)
- Foreign keys: referenced_table_singular_id (user_id, order_id)
- Indexes: idx_table_column (idx_users_email, idx_orders_created_at)
- Unique constraints: uniq_table_column (uniq_users_email)
- Junction tables: alphabetical (category_products, not product_categories)

### Column Standards
- Primary keys: id as UUID v7 (time-sortable), never auto-increment integers
- Timestamps: created_at and updated_at on every table, stored as timestamptz
- Soft deletes: deleted_at column (nullable timestamptz), never hard delete user-facing data
- Money: stored as integer cents, never floating point
- Status fields: use a check constraint with allowed values, not a boolean
```

## Query Pattern Rules

```markdown
## Query Patterns

### ORM Usage (Prisma)
- All database access through src/repositories/ — NEVER import PrismaClient in services or routes
- Use Prisma's select to fetch only needed columns — no select-star equivalents
- Use Prisma transactions for multi-table writes: prisma.$transaction([...])
- Pagination: cursor-based using id, never offset-based for user-facing lists

### Performance
- Every WHERE clause must use an indexed column — check schema before writing queries
- No N+1 queries — use Prisma include or explicit joins
- Queries returning lists MUST have a LIMIT (default 100, max 1000)
- Count queries on large tables: use estimated counts from pg_stat_user_tables
```

## Migration Safety Rules

Migrations are the most dangerous database operations. Encode safety rules explicitly:

```markdown
## Migration Rules

### Safety Requirements
- NEVER drop a column in the same deploy that stops using it. Two-phase: stop reading first, drop in next release.
- NEVER rename a column. Add new column, backfill, switch reads, drop old column.
- New NOT NULL columns MUST have a DEFAULT value
- Index creation: use CREATE INDEX CONCURRENTLY (does not lock table)
- Large table migrations: always include estimated row count and expected lock duration in the migration comment

### Migration File Standards
- One logical change per migration file
- File name: YYYYMMDDHHMMSS_descriptive_name.sql
- Include a comment block at the top explaining what and why
- Reversible: every UP migration has a corresponding DOWN
```

## File-Specific Database Rules

Use `.claude/rules/` to scope database rules to relevant files:

```markdown
# .claude/rules/database.md
---
paths:
  - "src/repositories/**/*.ts"
  - "prisma/**"
  - "migrations/**"
---

## Repository Implementation Rules
- Every repository method handles its own error mapping
- Prisma errors → AppError subtypes (P2002 → ConflictError, P2025 → NotFoundError)
- Repository methods return domain objects, never raw Prisma types
- Include query timing logs for operations expected to exceed 100ms
```

This loads only when Claude works on database-related files. Route handlers and service files do not see these rules, keeping their context focused.

## Seed and Test Data Rules

```markdown
## Test Data
- Seed data in prisma/seed.ts — deterministic, idempotent
- Test factories in tests/factories/ using @faker-js/faker
- Factory functions return plain objects matching domain types
- Tests use isolated transactions that roll back after each test
- NEVER use production data patterns in seeds (no real emails, names, or addresses)
```

## Putting It Together

A complete database section in your CLAUDE.md might look like this, staying well within the 200-line total budget by using imports:

```markdown
## Database
- ORM: Prisma 6 with PostgreSQL 16
- Schema: prisma/schema.prisma is the source of truth
- Access: only through src/repositories/
- @docs/database-naming-conventions.md
- @docs/migration-safety-rules.md
```

The two `@` imports pull in detailed rules from separate files, keeping the root CLAUDE.md concise while giving Claude full context when it needs it.

## Connection Pool and Performance Rules

```markdown
## Database Performance
- Connection pool: 20 connections default, configured in src/config/database.ts
- Query timeout: 30 seconds for read queries, 60 seconds for write queries
- Slow query logging: queries exceeding 500ms logged at WARN level
- Connection retry: exponential backoff with max 3 retries
- Read replicas: use for analytics and reporting queries
- Write operations: always against primary database
```

These rules prevent Claude from generating database code that opens unbounded connections, runs without timeouts, or fails to use your read replica setup. Without them, Claude defaults to single-connection patterns that work in development but fail in production.

## Schema Validation in CI

Add a CLAUDE.md rule that Claude includes schema validation when generating migrations:

```markdown
## Post-Migration Validation
- Every migration includes a verification step that checks the schema matches Prisma expectations
- Run prisma db pull after migration to verify schema sync
- Migration PR must include the prisma diff output
- Seed data must work against the new schema (run prisma db seed in CI)
```

This ensures Claude generates complete migration workflows, not just the SQL change.

For error handling patterns that complement database conventions, see the [error handling guide](/claude-md-error-handling-patterns/). For the overall approach to encoding project rules, see the [CLAUDE.md best practices](/claude-code-claude-md-best-practices/). For architecture rules that govern how database code fits into your layers, see the [architecture decisions guide](/claude-md-for-architecture-decisions/).
