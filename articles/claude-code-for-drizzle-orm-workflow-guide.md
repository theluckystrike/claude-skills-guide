---
layout: default
title: "Claude Code for Drizzle ORM (2026)"
description: "Claude Code for Drizzle ORM — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-drizzle-orm-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, drizzle-orm, workflow]
---

## The Setup

You are using Drizzle ORM as a lightweight, type-safe SQL query builder for TypeScript. Unlike heavier ORMs, Drizzle stays close to SQL while providing full TypeScript inference. Claude Code can generate Drizzle schemas and queries, but it consistently defaults to Prisma syntax or writes raw SQL strings.

## What Claude Code Gets Wrong By Default

1. **Uses Prisma's `schema.prisma` file format.** Claude writes `model User { id Int @id @default(autoincrement()) }`. Drizzle defines schemas in TypeScript: `export const users = pgTable('users', { id: serial('id').primaryKey() })`.

2. **Calls Prisma client methods.** Claude writes `prisma.user.findMany({ where: { age: { gte: 18 } } })`. Drizzle uses SQL-like builder syntax: `db.select().from(users).where(gte(users.age, 18))`.

3. **Generates raw SQL strings.** For complex queries, Claude falls back to `db.execute(sql\`SELECT...\`)`. Drizzle's query builder handles joins, subqueries, and CTEs — raw SQL should be a last resort.

4. **Imports the wrong operators.** Claude uses JavaScript operators in where clauses like `users.age > 18`. Drizzle requires imported comparison functions: `gt(users.age, 18)`, `eq()`, `like()`, `and()`, `or()`.

## The CLAUDE.md Configuration

```
# Drizzle ORM Project

## Database
- ORM: Drizzle ORM (drizzle-orm)
- Driver: PostgreSQL (pg) or libSQL
- Schema: src/db/schema.ts
- Migrations: drizzle-kit generate + drizzle-kit migrate

## Drizzle Rules
- Schema in TypeScript using pgTable(), sqliteTable()
- Operators: eq, gt, lt, gte, lte, like, and, or from drizzle-orm
- Select: db.select().from(table).where(...)
- Insert: db.insert(table).values({...}).returning()
- Update: db.updateTable(table).set({...}).where(...)
- Delete: db.delete(table).where(...)
- Relations: defined with relations() function separately
- Types: typeof table.$inferSelect, typeof table.$inferInsert

## Conventions
- Schema: src/db/schema.ts or src/db/schema/ directory
- Migrations: drizzle/ directory
- DB instance: src/db/index.ts exports configured drizzle()
- Config: drizzle.config.ts for drizzle-kit
- Use query API for simple reads: db.query.users.findMany()
- Use select API for complex queries: db.select().from()
```

## Workflow Example

You want to query users with their related posts and comment counts. Prompt Claude Code:

"Write a Drizzle ORM query that fetches users along with their total post count and most recent post title. Only include users with at least one post, ordered by post count descending."

Claude Code should use `db.select()` with a left join or subquery, `count(posts.id)` for the aggregate, `max(posts.createdAt)` for the most recent post, grouped by user ID with a `having` clause for minimum post count, all using Drizzle's operator imports.

## Common Pitfalls

1. **Confusing the query API with the select API.** Claude uses `db.query.users.findMany()` (relational) for complex aggregations. The query API is for simple relational reads. Use `db.select().from()` for joins, aggregates, and subqueries.

2. **Schema push vs generate confusion.** Claude uses `drizzle-kit push` in production. Push applies schema changes directly without creating migration files. Use `drizzle-kit generate` to create tracked migration files for production deployments.

3. **Type inference for joins.** Claude manually types the result of join queries. Drizzle infers join result types automatically, but only when you specify selected columns. Use `.select({ user: users, postCount: count(posts.id) })` for properly typed results.

## Related Guides

- [Using Claude Code with Drizzle ORM Schema Management](/using-claude-code-with-drizzle-orm-schema-management/)
- [Claude Code Drizzle ORM TypeScript Database Workflow](/claude-code-drizzle-orm-typescript-database-workflow/)
- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)

## Related Articles

- [Claude Code Laravel Eloquent Orm — Complete Developer Guide](/claude-code-laravel-eloquent-orm-guide/)
- [Claude Code For Database Orm — Complete Developer Guide](/claude-code-for-database-orm-code-generation-workflow/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\")."
      }
    }
  ]
}
</script>
