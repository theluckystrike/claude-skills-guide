---
layout: default
title: "Fix Prisma Migration Failures"
description: "Resolve Prisma migration errors using Claude Code. Fix drift detection, failed migrations, data loss warnings, and production rollback scenarios."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-prisma-migration-failed-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [prisma, migration, database, postgresql, debugging]
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix Prisma Migration Failures with Claude Code

## The Problem

You run `npx prisma migrate dev` and it fails with an error:

```
Error: P3006
Migration `20260415_add_user_roles` failed to apply cleanly to the shadow database.
Error:
 Step 1 Added the required column `role` to the `User` table without a default value.
 There are 247 rows in this table, it is not possible to execute this step.
```

Or you see drift detection failures:

```
Error: P3005
The database schema is not empty. Read more about how to baseline an existing
production database: https://pris.ly/d/migrate-baseline
```

Prisma migrations touch your actual data. Getting them wrong can cause data loss or production downtime.

## Quick Fix

For the "required column without default" error, add a default value:

```prisma
model User {
 id String @id @default(cuid())
 email String @unique
 role String @default("user") // Add default for existing rows
}
```

Then regenerate the migration:

```bash
npx prisma migrate dev --name add_user_roles
```

## What's Happening

Prisma Migrate uses a shadow database to verify migrations. It creates a temporary database, applies all migrations from scratch, compares the result with your schema, and generates new SQL. When this process fails, it means the migration SQL cannot be applied cleanly.

Common failure scenarios:

1. **Adding a required column**: Existing rows have no value for the new column
2. **Schema drift**: The database has been modified outside of Prisma migrations
3. **Failed migration stuck in history**: A previous migration partially applied
4. **Data type changes**: Converting a column type with incompatible data
5. **Unique constraint violations**: Adding a unique constraint to a column with duplicates

## Step-by-Step Fix

### Step 1: Diagnose the specific error

Ask Claude Code to analyze the migration:

```
Run npx prisma migrate dev and show me the full error.
Then read the failed migration SQL file and explain what went wrong.
```

Claude Code will check `prisma/migrations/` for the latest migration folder and read the `migration.sql` file inside it.

### Step 2: Fix "required column without default" errors

This is the most common migration failure. You have three options:

**Option A: Add a default value in the schema:**

```prisma
model User {
 id String @id @default(cuid())
 email String @unique
 role String @default("user")
 createdAt DateTime @default(now())
}
```

**Option B: Make the column optional first, backfill, then make required:**

```
Create a three-step migration:
1. Add the 'role' column as optional (String?)
2. Write a data migration to set role='user' for all existing rows
3. Make the column required (String)
```

Claude Code will generate the migration files:

```sql
-- Step 1: migration_add_role_optional.sql
ALTER TABLE "User" ADD COLUMN "role" TEXT;

-- Step 2: migration_backfill_roles.sql
UPDATE "User" SET "role" = 'user' WHERE "role" IS NULL;

-- Step 3: migration_make_role_required.sql
ALTER TABLE "User" ALTER COLUMN "role" SET NOT NULL;
ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'user';
```

**Option C: Use a custom migration:**

```bash
# Create an empty migration
npx prisma migrate dev --create-only --name add_user_roles

# Edit the generated SQL file
```

Then ask Claude Code to write the correct SQL:

```sql
-- prisma/migrations/20260415_add_user_roles/migration.sql
ALTER TABLE "User" ADD COLUMN "role" TEXT NOT NULL DEFAULT 'user';
```

### Step 3: Fix schema drift

When your database has been modified outside of Prisma:

```bash
# See the current drift
npx prisma migrate diff \
 --from-migrations ./prisma/migrations \
 --to-schema-datamodel ./prisma/schema.prisma \
 --script
```

If the database matches your desired schema but has no migration history:

```bash
# Baseline the existing database
npx prisma migrate resolve --applied "20260415_init"
```

Ask Claude Code to handle this:

```
My production database was modified manually. Compare the actual database
schema with my Prisma schema and create a migration that reconciles them.
Do not drop any columns that exist in the database.
```

### Step 4: Fix a stuck failed migration

If a migration partially applied and is now stuck:

```bash
# Check migration status
npx prisma migrate status

# Mark it as rolled back
npx prisma migrate resolve --rolled-back "20260415_add_user_roles"

# Or mark it as applied (if it actually succeeded)
npx prisma migrate resolve --applied "20260415_add_user_roles"
```

Then fix the migration SQL and re-run:

```bash
npx prisma migrate dev
```

### Step 5: Fix unique constraint violations

When adding a unique constraint to a column with duplicate values:

```
I need to add a unique constraint on User.email but there are duplicates.
Write a migration that:
1. Identifies duplicate emails
2. Appends a number suffix to duplicates (e.g., user+1@example.com)
3. Adds the unique constraint
```

Claude Code generates:

```sql
-- Deduplicate emails
WITH duplicates AS (
 SELECT id, email,
 ROW_NUMBER() OVER (PARTITION BY email ORDER BY "createdAt") as rn
 FROM "User"
)
UPDATE "User" u
SET email = u.email || '+dup' || d.rn::text
FROM duplicates d
WHERE u.id = d.id AND d.rn > 1;

-- Now add the constraint
ALTER TABLE "User" ADD CONSTRAINT "User_email_key" UNIQUE ("email");
```

### Step 6: Fix data type conversion errors

Changing column types can fail if existing data is incompatible:

```
Change the 'age' column from String to Int. Handle rows where the string
cannot be parsed as an integer by setting them to NULL.
```

```sql
-- Add new column
ALTER TABLE "User" ADD COLUMN "age_new" INTEGER;

-- Migrate data (safe conversion)
UPDATE "User"
SET "age_new" = CASE
 WHEN "age" ~ '^\d+$' THEN "age"::INTEGER
 ELSE NULL
END;

-- Drop old, rename new
ALTER TABLE "User" DROP COLUMN "age";
ALTER TABLE "User" RENAME COLUMN "age_new" TO "age";
```

## Prevention

Always test migrations against a copy of production data before deploying:

```bash
# Dump production schema (not data)
pg_dump --schema-only production_db > schema.sql

# Restore to a test database
psql test_db < schema.sql

# Run migrations against the test database
DATABASE_URL="postgresql://localhost/test_db" npx prisma migrate deploy
```

Add migration safety rules to your CLAUDE.md:

```markdown
## Prisma Migration Rules
- Never add a required column without a default value
- Always use --create-only for complex migrations and review the SQL
- Test migrations against a production schema copy before deploying
- Use multi-step migrations for data transformations
- Never use prisma migrate dev in production (use prisma migrate deploy)
```

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-prisma-migration-failed-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

- [Claude Code Database Seeding Automation](/claude-code-database-seeding-automation/)
- [Claude Code Database Test Fixtures Guide](/claude-code-database-test-fixtures-guide/)
- [Claude Code Testcontainers Integration Testing](/claude-code-testcontainers-integration-testing/)

## See Also

- [Request Body Validation Failed — Fix (2026)](/claude-code-request-body-validation-failed-fix-2026/)
- [Prisma Generate Failure After Schema Change — Fix (2026)](/claude-code-prisma-generate-failure-fix-2026/)
