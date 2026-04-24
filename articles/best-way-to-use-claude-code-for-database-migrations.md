---
layout: default
title: "Use Claude Code for Database Migrations (2026)"
description: "Generate safe database migrations with Claude Code. Covers schema diffing, rollback scripts, data backfilling, and zero-downtime migration patterns."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, database, migrations, sql, workflow]
author: theluckystrike
reviewed: true
score: 9
permalink: /best-way-to-use-claude-code-for-database-migrations/
geo_optimized: true
last_tested: "2026-04-21"
---
# Best Way to Use Claude Code for Database Migrations

Database migrations are critical operations that can make or break your application. A poorly written migration can cause downtime, data loss, or corrupt relationships. The best way to use Claude Code for database migrations combines AI assistance with solid engineering practices to generate reliable, reversible, and well-documented schema changes.

This guide walks through practical strategies for integrating Claude Code into your migration workflow, whether you use raw SQL, ORMs like Prisma or Django, or custom migration frameworks.

## Setting Up Claude Code for Migration Work

Before diving into migration generation, ensure Claude Code understands your project structure. Create a project-specific context file that describes your database system, existing schema, and migration conventions. This context serves as the foundation for accurate migration generation.

```bash
Tell Claude Code about your database setup
CLAUDE.md or PROJECT.md should include:

Database: PostgreSQL 15
ORM: Prisma 5.x
Migration tool: Prisma Migrate
Schema location: ./prisma/schema.prisma
Migration history: ./prisma/migrations/
```

When Claude Code has access to this context, it can generate migrations that respect your existing patterns, naming conventions, and business rules.

## Generating Your First Migration

The most straightforward approach is to describe your schema change in natural language and let Claude Code generate the migration. Here's how to get the best results:

1. Provide clear intent: Instead of "add user fields," specify "add a users table with id, email, created_at, and password_hash columns"
2. Include constraints: Specify which fields are required, unique, or indexed
3. Mention existing tables: Reference related tables for foreign key relationships

```sql
-- Example prompt to Claude Code:
-- "Generate a migration to create an orders table with:
-- - id (uuid, primary key)
-- - user_id (foreign key to users.id)
-- - total_amount (decimal, not null)
-- - status (enum: pending, completed, cancelled)
-- - created_at and updated_at timestamps
-- Include an index on user_id and a unique constraint on (user_id, created_at) for recent orders"
```

Claude Code will generate a migration similar to:

```sql
CREATE TABLE "orders" (
 "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 "user_id" UUID NOT NULL REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
 "total_amount" DECIMAL(10,2) NOT NULL,
 "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
 "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
 "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX "idx_orders_user_id" ON "orders"("user_id");
CREATE UNIQUE INDEX "idx_orders_user_recent" ON "orders"("user_id", "created_at");

ALTER TABLE "orders" ADD CONSTRAINT "orders_status_check" 
CHECK ("status" IN ('pending', 'completed', 'cancelled'));
```

## Validating and Reviewing Migrations

The best way to use Claude Code goes beyond generation, it includes validation. Before applying any migration, use Claude Code to review it for common issues:

- Data loss warnings: Check if ALTER TABLE operations might truncate or lose data
- Index recommendations: Verify foreign key columns have appropriate indexes
- Lock time estimates: Identify operations that might require table locks on large datasets
- Rollback verification: Ensure DOWN migrations properly reverse the changes

```bash
Ask Claude Code to review your migration:
"Review this migration for potential issues on a table with 10M rows"
```

Claude Code can also explain what each statement does in plain language, helping team members understand the migration without reading raw SQL.

## Integrating with Claude Skills

Several Claude skills enhance the migration workflow when used together with Claude Code:

- tdd: Write tests that verify data integrity after migrations, ensuring columns accept expected values and relationships function correctly
- pdf: Generate database documentation from your schema, useful for onboarding new team members
- supermemory: Maintain a searchable knowledge base of past migrations, including the reasoning behind schema decisions
- frontend-design: When building new features, align your UI forms with database constraints that Claude Code has generated

For teams using Prisma, the workflow becomes even tighter. Describe your schema changes, let Claude Code generate the Prisma schema updates, then use `npx prisma migrate dev` to create the actual migration files.

If you find yourself running the same type of migrations repeatedly, adding audit columns, splitting contact fields, standardising index naming, consider encoding those patterns as a reusable Claude skill rather than re-prompting each time. See [Claude Skills for Creating Database Migration Scripts](/claude-skills-for-creating-database-migration-scripts/) for how to build a dedicated `db-migration` skill that captures your project's conventions and generates production-ready scripts automatically.

## Handling Complex Scenarios

Real-world migrations often involve data transformation, not just schema changes. Here's how to handle these scenarios:

## Data Migration with Cleanup

```sql
-- Migrating user emails to lowercase and removing duplicates
UPDATE users SET email = LOWER(email) WHERE email != LOWER(email);

-- After update, remove duplicates keeping the oldest record
DELETE FROM users 
WHERE id NOT IN (
 SELECT MIN(id) 
 FROM users 
 GROUP BY LOWER(email)
);
```

## Adding Columns with Defaults

For large tables, adding columns with DEFAULT values can cause table locks. Claude Code recommends safer approaches:

```sql
-- Step 1: Add column without default (instant)
ALTER TABLE orders ADD COLUMN tracking_number VARCHAR(50);

-- Step 2: Backfill existing rows in batches
UPDATE orders SET tracking_number = 'PENDING' 
WHERE tracking_number IS NULL 
AND created_at > NOW() - INTERVAL '30 days'
LIMIT 1000;

-- Step 3: Add default for new rows
ALTER TABLE orders ALTER COLUMN tracking_number SET DEFAULT 'PENDING';
```

## Zero-Downtime Migration Patterns

For production systems that cannot tolerate downtime, the expand-contract pattern provides the safest approach:

1. Expand: Add new columns or tables alongside existing ones without removing anything
2. Migrate: Backfill data from old columns to new ones using batch operations
3. Contract: Remove old columns only after all application code references the new structure

```sql
-- Step 1: Expand. add new column alongside old one
ALTER TABLE users ADD COLUMN email_verified_at TIMESTAMP NULL;
CREATE INDEX idx_users_email_verified ON users(email_verified_at);

-- Step 2: Migrate. backfill data in batches
UPDATE users SET email_verified_at = created_at
WHERE email_verified = true AND email_verified_at IS NULL
LIMIT 1000;

-- Step 3: Contract. remove old column (only after code migration)
ALTER TABLE users DROP COLUMN email_verified;
```

Key principles for zero-downtime migrations: maintain backward compatibility between old and new schemas, deploy changes in small reversible steps, and use feature flags to toggle new behavior without redeployment.

## Zero-Downtime Migration Patterns

For production databases serving live traffic, zero-downtime migrations follow the expand-contract pattern:

1. Expand: Add the new column alongside the old one (additive, no locks on reads)
2. Migrate: Backfill data from the old column to the new column in batches
3. Contract: Remove the old column after all application code uses the new one

```sql
-- Step 1: Add new column (safe, additive)
ALTER TABLE users ADD COLUMN email_verified_at TIMESTAMP NULL;
CREATE INDEX idx_users_email_verified ON users(email_verified_at);

-- Step 2: Backfill in batches (run during low traffic)
UPDATE users SET email_verified_at = created_at WHERE email_verified = true AND email_verified_at IS NULL LIMIT 1000;

-- Step 3: Remove old column (after application code is updated)
ALTER TABLE users DROP COLUMN email_verified;
```

Key principles: never change a column in place, deploy changes in small reversible steps, and use feature flags to toggle new features on/off without redeployment. Your application must work with both old and new schemas simultaneously during the migration window.

## Production Best Practices

When using Claude Code for production migrations, follow these proven practices:

1. Generate, review, then apply: Never run generated migrations without review
2. Test on staging first: Apply migrations to a staging database that mirrors production
3. Use the tdd skill: Write migration tests that verify data integrity
4. Document changes: Use the pdf skill to export schema documentation after major changes
5. Keep migrations atomic: Each migration should represent a single logical change

## Conclusion

The best way to use Claude Code for database migrations is an interactive loop: you describe the change in plain language, Claude Code generates the SQL, you review it, and you apply it only when satisfied. Claude Code excels at producing correct SQL syntax, suggesting appropriate indexes, flagging lock-time risks, and explaining what each statement does before it runs.

This interactive approach is distinct from the skills-based approach, where you pre-author a `db-migration` skill that encodes your project's conventions and generates migrations on demand without needing to prompt from scratch each time. Both approaches complement each other: start interactively with Claude Code to understand your migration patterns, then crystallise those patterns into a reusable skill for day-to-day use.

By pairing Claude Code with skills like tdd for testing, pdf for documentation, and supermemory for knowledge management, you build a migration workflow that scales with your project. Start with small, low-risk migrations to build confidence, then expand to more complex schema changes as you trust the workflow.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=best-way-to-use-claude-code-for-database-migrations)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Skills for Creating Database Migration Scripts](/claude-skills-for-creating-database-migration-scripts/). Once you know your patterns from interactive use, encode them as a reusable `db-migration` skill
- [Using Claude Code with Prisma ORM Database Migrations](/using-claude-code-with-prisma-orm-database-migrations/). See also
- [Should I Use Claude Code for Production Database Migrations](/should-i-use-claude-code-for-production-database-migrations/). See also
- [Claude Code Tutorials Hub](/tutorials-hub/). See also
- [How To Use Claude Code To Write — Complete Developer Guide](/how-to-use-claude-code-to-write-database-queries-from-scratch/)
- [Claude Code SQLAlchemy Alembic Migrations Deep Dive Guide](/claude-code-sqlalchemy-alembic-migrations-deep-dive-guide/)
- [Claude Code Output Format — How to Customize (2026)](/best-way-to-customize-claude-code-output-format-style/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


