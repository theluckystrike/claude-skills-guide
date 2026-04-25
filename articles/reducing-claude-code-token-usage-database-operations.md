---
layout: default
title: "Reducing Claude Code token usage (2026)"
description: "Reduce Claude Code token usage for database operations by 60-80% with schema skills, query templates, and structured migration patterns saving $30-80/month."
permalink: /reducing-claude-code-token-usage-database-operations/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Reducing Claude Code token usage for database operations

## The Problem

Database operations are among the most token-expensive tasks in Claude Code. Writing a single migration requires reading the schema file (2,000-5,000 tokens), understanding existing migrations (5,000-15,000 tokens), checking related models (3,000-8,000 tokens), and verifying constraints (2,000-5,000 tokens). A typical database task consumes 15K-35K tokens before any code is written. Multiply by 5-10 database tasks per day and the monthly cost reaches $30-$80 on Sonnet 4.6 just for database context loading.

## Quick Fix (2 Minutes)

Create a database schema skill:

```markdown
# .claude/skills/database.md

## Schema (Prisma, PostgreSQL)
### users: id(uuid PK), email(unique), password_hash, role(admin|user), created_at, deleted_at
### posts: id(uuid PK), user_id(FK->users), title(varchar 500), body(text), status(draft|pub|archived), created_at, deleted_at
### comments: id(uuid PK), post_id(FK->posts), user_id(FK->users), body(text), created_at
### tags: id(uuid PK), name(unique), slug(unique)
### post_tags: post_id(FK), tag_id(FK), PK(post_id, tag_id)

## Commands
- Migrate: npx prisma migrate dev --name <desc>
- Generate: npx prisma generate
- Reset: npx prisma migrate reset (DESTRUCTIVE)
- Seed: npx prisma db seed
```

This skill costs ~250 tokens to load and replaces 10K-25K tokens of schema file reading.

## Why This Happens

Database operations require three categories of context that Claude Code must discover:

1. **Schema knowledge:** What tables exist, their columns, relationships, and constraints. Without pre-loading, Claude reads the full Prisma schema or runs `\dt` and `\d table` commands.

2. **Migration patterns:** How migrations are structured in the project. Claude reads 2-5 existing migrations to understand the pattern.

3. **Query patterns:** How the project writes database queries. Claude reads repository files to understand conventions.

Each category costs 5K-15K tokens to discover. With skills, each costs 100-300 tokens.

## The Full Fix

### Step 1: Diagnose

```bash
# Measure token cost of a simple database task
claude "Add an 'updated_at' column to the posts table"

/cost
# If input > 20K tokens, database context is being over-fetched
# Target: under 8K tokens for this task
```

### Step 2: Fix

**Schema skill (eliminates schema reads):**

```markdown
# .claude/skills/database.md (~250 tokens)
[Schema as shown in Quick Fix above]
```

**Migration pattern skill (eliminates migration file reads):**

```markdown
# .claude/skills/migration-patterns.md (~200 tokens)

## Migration Conventions
- File: supabase/migrations/ or prisma/migrations/
- Naming: descriptive, lowercase, underscores
- Never edit existing migrations
- Always create new migration for changes
- Include DOWN migration for reversibility

## Common Templates
### Add column
ALTER TABLE "table" ADD COLUMN "col" TYPE DEFAULT value;

### Add index
CREATE INDEX idx_table_col ON "table" ("col");

### Add FK
ALTER TABLE "child" ADD CONSTRAINT fk_name
  FOREIGN KEY ("col") REFERENCES "parent" ("id");
```

**Query pattern skill (eliminates repository reads):**

```markdown
# .claude/skills/query-patterns.md (~200 tokens)

## Prisma Query Conventions
- Always use select/include to limit returned fields
- Use transactions for multi-table operations
- Soft deletes: where: { deleted_at: null }
- Pagination: skip/take pattern
- Error handling: catch PrismaClientKnownRequestError

## Example Patterns
### Find with pagination
prisma.post.findMany({
  where: { status: 'published', deleted_at: null },
  select: { id: true, title: true, created_at: true },
  skip: (page - 1) * limit,
  take: limit,
  orderBy: { created_at: 'desc' }
})
```

### Step 3: Prevent

```markdown
# CLAUDE.md

## Database Rules
- Schema reference: .claude/skills/database.md (read this, NOT prisma/schema.prisma)
- Migration patterns: .claude/skills/migration-patterns.md
- Query patterns: .claude/skills/query-patterns.md
- Always generate Prisma types after schema changes: npx prisma generate
- Never read migration files unless debugging a migration error
- Update database.md after any schema change
```

## Cost Recovery

If a database session is already bloated:

```bash
/compact

# Then use the skill directly
"Using the schema in .claude/skills/database.md, add an 'updated_at' column
to the posts table. Create a new Prisma migration."
```

## Prevention Rules for CLAUDE.md

```markdown
## Database Cost Rules
- For schema info: read .claude/skills/database.md (NOT the full schema file)
- For migration patterns: read .claude/skills/migration-patterns.md
- For query patterns: read .claude/skills/query-patterns.md
- Only read the actual schema file when the skill is insufficient
- Never read more than 2 existing migration files
- After any schema change, update .claude/skills/database.md
- Test migrations locally: npx prisma migrate dev (auto-generates)
```

Expected savings for 5-10 database tasks per day on Sonnet 4.6:
- Without skills: 5-10 tasks x 25K avg tokens x 22 days = 2.75-5.5M tokens = **$8.25-$16.50/month input**
- With skills: 5-10 tasks x 5K avg tokens x 22 days = 550K-1.1M tokens = **$1.65-$3.30/month input**
- **Savings: $6.60-$13.20/month** in input tokens alone. Including output savings: **$15-$35/month.**

For teams with heavy database work (Supabase projects with 40+ tables): savings scale to **$60-$150/month** per developer.

## Database Operation Cost Benchmarks

Use these benchmarks to evaluate whether database tasks are consuming appropriate tokens:

| Operation | Expected Tokens (With Skills) | Red Flag Threshold |
|-----------|------------------------------|-------------------|
| Add column | 5K-8K | Over 15K |
| New table with relations | 8K-15K | Over 30K |
| Write migration | 5K-10K | Over 20K |
| Debug query performance | 10K-20K | Over 40K |
| Write repository function | 5K-10K | Over 20K |
| RLS policy creation | 5K-12K | Over 25K |
| Seed data script | 8K-15K | Over 30K |

If a database task exceeds its red flag threshold, investigate:
- Is the schema skill outdated? (Most common cause)
- Is Claude reading migration files? (Should not need to with skills)
- Is Claude exploring the repository layer? (Should have query patterns skill)
- Is there an RLS debugging loop? (Needs RLS policy map skill)

## ORM-Specific Optimization

### Prisma

```markdown
# .claude/skills/prisma-patterns.md

## Prisma Conventions
- Schema: prisma/schema.prisma (source of truth)
- Client: import { PrismaClient } from '@prisma/client'
- Transactions: prisma.$transaction([...]) for multi-table ops
- Soft delete: where: { deleted_at: null } on all queries
- Pagination: { skip: (page-1)*limit, take: limit }
- Select: always specify select/include to limit returned fields

## After Schema Changes
1. npx prisma generate (regenerate client)
2. npx prisma migrate dev --name <description>
3. Update .claude/skills/database.md with new schema
```

### TypeORM

```markdown
# .claude/skills/typeorm-patterns.md

## TypeORM Conventions
- Entities: src/entities/ (one per table, decorated classes)
- Repositories: use getRepository() or custom repositories
- Migrations: npx typeorm migration:generate -n <name>
- Relations: use @ManyToOne, @OneToMany with eager:false
- QueryBuilder: preferred over raw SQL for complex queries
```

### Drizzle

```markdown
# .claude/skills/drizzle-patterns.md

## Drizzle Conventions
- Schema: src/db/schema.ts (TypeScript, source of truth)
- Migrations: npx drizzle-kit generate:pg
- Queries: use db.select().from(table).where(...)
- Relations: defined in schema file with relations()
- Push: npx drizzle-kit push:pg (dev only, dangerous in prod)
```

## The Database Exploration Trap

The most common database token waste pattern: Claude reads the schema, then reads repository files to see how queries are written, then reads service files to see how repositories are called, then reads route files to see how services are called. This exploration chain consumes 20K-50K tokens for a single database task.

Break the chain with a comprehensive database skill that includes both schema AND query patterns:

```markdown
# .claude/skills/database-complete.md (~400 tokens)

## Schema
### users: id(uuid), email(unique), password_hash, role, created_at, deleted_at
### posts: id(uuid), user_id(FK), title, body, status, created_at, deleted_at

## Query Patterns
- Find one: prisma.user.findUnique({ where: { id }, select: { id: true, email: true } })
- Find many: prisma.post.findMany({ where: { status: 'published', deleted_at: null }, skip, take })
- Create: prisma.user.create({ data: { email, password_hash, role: 'user' } })
- Update: prisma.user.update({ where: { id }, data: { ...changes } })
- Soft delete: prisma.user.update({ where: { id }, data: { deleted_at: new Date() } })
- Transaction: prisma.$transaction([op1, op2])

## Repositories: src/repositories/ (one per table, follows patterns above)
## Services: src/services/ (one per domain, calls repositories)
```

This single skill (~400 tokens) replaces reading 4-8 files (20K-40K tokens). For a developer doing 5 database tasks per day: **savings of 100K-200K tokens daily, or $6.60-$13.20/month on Sonnet.**

## Related Guides

- [RLS Policy Debugging with Claude Code](/rls-policy-debugging-claude-code-structured-approach/) -- Supabase-specific database patterns
- [Claude Code Skills Guide](/skills/) -- creating database-specific skills
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization guides

## See Also

- [Monitoring Claude Code Token Usage with Custom Hooks](/monitoring-claude-code-token-usage-custom-hooks/)
