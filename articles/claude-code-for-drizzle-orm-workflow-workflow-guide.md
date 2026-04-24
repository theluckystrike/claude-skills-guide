---
layout: default
title: "Claude Code for Drizzle ORM (2026)"
description: "Claude Code for Drizzle ORM — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-drizzle-orm-workflow-workflow-guide/
canonical_url: /claude-code-for-drizzle-orm-workflow-guide/
sitemap: false
categories: [workflow, niche-tools]
tags: [claude-code, drizzle-orm, workflow]
---

## The Setup

You are using Drizzle ORM for type-safe database access in a TypeScript project. Drizzle's schema-as-code approach generates SQL migrations from TypeScript table definitions. Claude Code can write schemas, queries, and migrations, but it frequently mixes up Drizzle's API with Prisma's syntax or generates raw SQL when Drizzle's query builder would be more appropriate.

## What Claude Code Gets Wrong By Default

1. **Writes Prisma schema syntax.** Claude generates `model User { id Int @id }` in a `.prisma` file. Drizzle defines schemas in TypeScript: `export const users = pgTable('users', { id: serial('id').primaryKey() })`.

2. **Uses Prisma client methods.** Claude writes `prisma.user.findMany()` calls. Drizzle uses `db.select().from(users).where(eq(users.id, 1))` with explicit query builder methods and imported operator functions.

3. **Forgets to import operators.** Claude writes `.where(users.age > 18)` using JavaScript comparison. Drizzle requires imported operators: `.where(gt(users.age, 18))` with `gt`, `eq`, `and`, `or` from `drizzle-orm`.

4. **Runs `prisma migrate` commands.** Claude uses Prisma CLI for migrations. Drizzle uses `drizzle-kit generate` to create SQL migration files and `drizzle-kit migrate` to apply them.

## The CLAUDE.md Configuration

```
# Drizzle ORM TypeScript Project

## Architecture
- ORM: Drizzle (drizzle-orm + drizzle-kit)
- Database: PostgreSQL (pg driver)
- Schema: drizzle/schema.ts (TypeScript table definitions)
- Migrations: drizzle/migrations/ directory (SQL files)
- Config: drizzle.config.ts at project root

## Drizzle Rules
- Define tables in drizzle/schema.ts using pgTable()
- Import operators: eq, gt, lt, and, or, like from drizzle-orm
- Generate migrations: npx drizzle-kit generate
- Apply migrations: npx drizzle-kit migrate
- Use db.select().from(table) pattern, not Prisma-style methods
- Relations defined with relations() function, not schema decorators
- Use $inferSelect and $inferInsert for TypeScript type inference
- Connection: drizzle(pool) wrapping a pg Pool instance

## Conventions
- Schema file: drizzle/schema.ts (all tables in one file or split by domain)
- Queries in lib/db/queries/ directory
- Use prepared statements for frequently run queries
- Timestamps: .defaultNow() for createdAt, .$onUpdate() for updatedAt
- Always include .notNull() on required columns
- Never write raw SQL when Drizzle query builder supports the operation
```

## Workflow Example

You want to add a comments feature with a relation to users and posts. Prompt Claude Code:

"Create a comments table in the Drizzle schema with body text, userId, postId, and createdAt fields. Add the foreign key relations, generate the migration, and write a query function that gets all comments for a post with the commenter's name."

Claude Code should add the `comments` pgTable with `references(() => users.id)` on userId, define relations using Drizzle's `relations()` function, run `drizzle-kit generate`, and write a query using `db.query.comments.findMany({ where: eq(comments.postId, id), with: { user: true } })`.

## Common Pitfalls

1. **Schema push vs migration generate confusion.** Claude uses `drizzle-kit push` for production. Push modifies the database directly without creating migration files. Use `drizzle-kit generate` + `drizzle-kit migrate` in production for auditable, reversible changes.

2. **Circular relation definitions.** Claude defines relations inline in the table definition. Drizzle requires relations to be defined separately using the `relations()` function to avoid circular import issues between table files.

3. **Missing the `$inferSelect` type export.** Claude creates manual TypeScript interfaces matching the schema. Drizzle provides automatic type inference with `type User = typeof users.$inferSelect` — manual interfaces drift out of sync with schema changes.

## Related Guides

- [Using Claude Code with Drizzle ORM Schema Management](/using-claude-code-with-drizzle-orm-schema-management/)
- [Claude Code Drizzle ORM TypeScript Database Workflow](/claude-code-drizzle-orm-typescript-database-workflow/)
- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)

## Related Articles

- [Claude Code Laravel Eloquent Orm — Complete Developer Guide](/claude-code-laravel-eloquent-orm-guide/)
- [Claude Code for Drizzle ORM — Workflow Guide](/claude-code-for-drizzle-orm-workflow-guide/)
