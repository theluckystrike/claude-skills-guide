---

layout: default
title: "Claude Code with PlanetScale Database (2026)"
description: "Learn how to integrate Claude Code with PlanetScale for smooth database development. This guide covers connection setup, schema management, branching."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-with-planetscale-database-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

PlanetScale is a MySQL-compatible serverless database platform that offers powerful features like branching, schema changes, and horizontal scaling. When combined with Claude Code, you get an intelligent pair programming experience for database development. This guide walks you through setting up and optimizing your workflow. from initial connection through schema design, query optimization, and production deployments.

Why Combine Claude Code with PlanetScale?

PlanetScale's unique architecture provides database branching similar to git. but for your schema. This makes it perfect for development workflows where you need to experiment safely. Claude Code can help you:

- Write and review migration scripts before they touch production
- Generate schema definitions from plain English descriptions
- Debug query performance by analyzing execution plans
- Build application code that interacts with your database
- Review migrations for PlanetScale-specific constraints before you encounter errors at deploy time

The combination creates a powerful workflow where Claude handles the code generation while PlanetScale handles the database infrastructure. What makes this pairing particularly effective is that PlanetScale's constraints (no foreign key enforcement, no `RENAME TABLE`, no certain `ALTER TABLE` operations) are exactly the kind of platform-specific knowledge Claude Code can apply automatically when you ask it to generate migrations.

## Understanding PlanetScale's Architecture

Before diving into workflows, it helps to understand what makes PlanetScale different from a traditional MySQL deployment. This affects how Claude Code should generate code for you.

PlanetScale is built on Vitess, the sharding system that powers YouTube's database infrastructure. This gives it:

- Horizontal sharding: Tables can be distributed across many physical MySQL instances
- Schema branching: Each branch is an isolated copy of the schema (not data). you can freely alter it without affecting other branches
- Non-blocking schema changes: DDL changes run online via `gh-ost` under the hood, so large table alterations do not lock production
- No foreign key constraints: Vitess does not enforce FK constraints across shards. You can declare them, but they are not enforced. Claude Code will generate code without FK declarations when targeting PlanetScale unless you explicitly request them.

Understanding these constraints shapes how you prompt Claude. Instead of "add a foreign key from orders to users," say "add an index on orders.user_id to support joins to users without a foreign key constraint." Claude Code knows PlanetScale's FK behavior and will flag it, but being precise in your prompts produces better results.

## Setting Up Your PlanetScale Connection

## Prerequisites

Ensure you have the following installed:

- PlanetScale CLI (`brew install planetscale/tap/pscale`)
- MySQL client (for direct queries)
- Node.js or Python for application development

## Configuring Environment Variables

Create a `.env` file in your project root:

```bash
.env file (add to .gitignore)
DATABASE_URL="mysql://username:password@aws.connect.psdb.cloud/database-name?sslaccept=strict"
```

Never commit credentials to version control. Use a `.gitignore` pattern:

```bash
.gitignore
.env
.env.local
*.local
```

## Connecting via PlanetScale CLI Proxy

For local development, the CLI proxy is the recommended approach. It handles authentication through your PlanetScale account and avoids storing a long-lived password:

```bash
Authenticate once
pscale auth login

Connect to a branch. this opens a local proxy on port 3309
pscale connect my-app main --port 3309
```

With the proxy running, your local DATABASE_URL becomes:

```bash
DATABASE_URL="mysql://127.0.0.1:3309/my-app"
```

This is particularly useful when using Claude Code's Bash tool to run migrations or seed scripts. the proxy provides a live connection without exposing credentials in command history.

## Database Branching Workflow

PlanetScale's standout feature is database branching. Each branch operates as an isolated development environment. perfect for trying new features without affecting production.

## Creating a Development Branch

Use the PlanetScale CLI to create a branch for your current task:

```bash
pscale branch create my-app feature-user-auth
pscale connect my-app feature-user-auth --port 3310
```

This creates an isolated environment where you can safely experiment. When working with Claude Code, describe your intended schema changes and let it generate the appropriate migrations. The branch gives you a safe sandbox. if the migration is wrong, you delete the branch and start over rather than rolling back production.

A typical branching workflow looks like this:

```
main (production schema)
 feature-user-auth (your changes)
 Apply schema changes
 Test with application
 Open deploy request to main
```

## Claude-Assisted Schema Design

When designing a new feature schema, describe your requirements to Claude:

> "I need a users table with email, password_hash, created_at, and updated_at fields. The email should be unique. This is for PlanetScale, so avoid foreign key constraints."

Claude generates the appropriate SQL:

```sql
CREATE TABLE users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 email VARCHAR(255) NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_users_email (email)
);
```

For ORM-based projects, Claude can also generate Prisma or Drizzle schemas:

```typescript
// Prisma schema. datasource must use mysql provider for PlanetScale
model User {
 id Int @id @default(autoincrement()) @db.UnsignedInt
 email String @unique @db.VarChar(255)
 passwordHash String @db.VarChar(255)
 createdAt DateTime @default(now())
 updatedAt DateTime @updatedAt

 @@map("users")
}
```

Note the `@db.UnsignedInt` and explicit `@db.VarChar` annotations. Claude adds these when targeting PlanetScale to match the SQL types precisely rather than relying on Prisma's defaults.

## Migration Management Strategies

Effective migration management is crucial for team collaboration. PlanetScale's deploy requests serve as the review mechanism, but the quality of that review depends on well-written migrations.

## Writing Safe Migrations

PlanetScale blocks certain operations because they are unsafe on a distributed system. Claude Code knows these constraints and will avoid them:

| Unsupported operation | PlanetScale alternative |
|---|---|
| `RENAME TABLE` | Create new table, migrate data, drop old table |
| `ALTER TABLE ... ADD FOREIGN KEY` | Use application-level integrity or indexed columns |
| Multiple `ALTER TABLE` operations on the same table in one statement | Separate statements or use a single `ALTER TABLE` with multiple clauses |
| `CREATE TABLE ... SELECT` | `CREATE TABLE` then `INSERT INTO ... SELECT` separately |

When you ask Claude to write a migration that would normally use `RENAME TABLE`, it should automatically generate a multi-step approach. If it does not, explicitly tell it: "This targets PlanetScale. do not use RENAME TABLE."

Always generate rollback-capable migrations by including commented reverse operations:

```sql
-- Migration: add_user_preferences
-- Forward
ALTER TABLE users ADD COLUMN preferences JSON;

-- Backward (for rollback)
-- ALTER TABLE users DROP COLUMN preferences;
```

## Expanding vs Contracting Schema Changes

For zero-downtime schema changes, use the expand-and-contract pattern. Claude Code can walk you through it when you describe what you want to achieve:

## Step 1. Expand: Add the new column without removing the old one

```sql
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);
```

Step 2. Migrate: Update application code to write to both columns. Deploy application code.

```sql
UPDATE users SET display_name = full_name WHERE display_name IS NULL;
```

## Step 3. Contract: Remove the old column once all code references the new one

```sql
ALTER TABLE users DROP COLUMN full_name;
```

This three-step process avoids any moment where the application reads a column that does not exist. Ask Claude Code "how do I rename the `full_name` column to `display_name` with zero downtime on PlanetScale?" and it will walk through exactly this pattern.

## Reviewing Migration Impact

Before applying migrations to production, ask Claude to analyze potential impacts:

> "Review this migration and identify any blocking operations for PlanetScale."

Claude will check for unsupported operations like:
- `RENAME TABLE` (not supported on PlanetScale)
- `ALTER TABLE` with certain column changes requiring table rebuilds
- Foreign key constraints (PlanetScale handles these differently)
- Statements that might cause full-table locks even with Vitess's online DDL

## Connecting Your Application

## Using the MySQL Protocol

PlanetScale exposes a MySQL-compatible interface. Connect using standard libraries:

```typescript
// Using mysql2 in Node.js
import mysql from 'mysql2/promise';

const connection = await mysql.createConnection({
 uri: process.env.DATABASE_URL,
 ssl: {
 rejectUnauthorized: true
 }
});

const [rows] = await connection.execute(
 'SELECT * FROM users WHERE email = ?',
 [userEmail]
);
```

Always use parameterized queries as shown above. Claude Code will generate parameterized queries by default. if you see it generating string interpolation for SQL, stop and ask it to rewrite using placeholders.

## Handling Connection Pooling

For serverless environments like Vercel or AWS Lambda, each function invocation may create a new database connection. Without pooling limits, this can exhaust PlanetScale's connection limit. Configure pooling appropriately:

```typescript
import { createPool } from 'mysql2/promise';

const pool = createPool({
 uri: process.env.DATABASE_URL,
 ssl: { rejectUnauthorized: true },
 waitForConnections: true,
 connectionLimit: 10,
 queueLimit: 0,
 enableKeepAlive: true,
 keepAliveInitialDelay: 10000,
});

// Reuse the pool across requests in long-lived processes
export async function query<T>(sql: string, params: unknown[]): Promise<T[]> {
 const [rows] = await pool.execute(sql, params);
 return rows as T[];
}
```

For Next.js or similar frameworks where the module is re-evaluated on cold starts, use a global singleton pattern:

```typescript
// lib/db.ts
import { Pool, createPool } from 'mysql2/promise';

declare global {
 var dbPool: Pool | undefined;
}

export const db: Pool = global.dbPool ?? createPool({
 uri: process.env.DATABASE_URL,
 ssl: { rejectUnauthorized: true },
 connectionLimit: 5,
});

if (process.env.NODE_ENV !== 'production') {
 global.dbPool = db;
}
```

This pattern prevents connection pool exhaustion during Next.js hot reloads in development. Claude Code can generate this boilerplate from a simple prompt: "Create a PlanetScale connection pool singleton safe for Next.js development reloads."

## Query Optimization with Claude

Claude can help optimize slow queries. Share your query and execution plan:

> "This query takes 3 seconds on a table with 2M rows. Here's the EXPLAIN output: [paste EXPLAIN]"

Claude will examine the query structure and EXPLAIN output and suggest improvements. A common pattern is missing composite indexes. For example:

```sql
-- Slow: full table scan
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';

-- Claude suggests: add a composite index covering both columns
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Then the query hits the index
-- EXPLAIN shows: type=ref, key=idx_orders_user_status, rows=12
```

For complex reporting queries, Claude can suggest query restructuring. replacing correlated subqueries with JOINs, using covering indexes to avoid row lookups, or breaking a single large query into smaller queries that are faster to cache at the application layer.

When sharing EXPLAIN output with Claude, use `EXPLAIN FORMAT=JSON` for the most detailed information:

```sql
EXPLAIN FORMAT=JSON
SELECT u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.created_at > '2026-01-01'
GROUP BY u.id;
```

Paste the JSON output into Claude Code and ask "identify the performance bottleneck and suggest index changes."

## Deployment Workflow

When you're ready to deploy schema changes to production:

1. Open a deploy request from your feature branch to `main` via the PlanetScale dashboard or CLI:

```bash
pscale deploy-request create my-app feature-user-auth
```

2. Review the diff. PlanetScale shows you exactly what DDL statements will run

3. Check for blocking operations. PlanetScale will warn you if any statements require table locks or are unsupported

4. Merge the deploy request during a low-traffic window for large table changes

5. Monitor application logs for the 15 minutes following deployment

Claude can generate a pre-deployment checklist script:

```bash
#!/bin/bash
pre-deploy-check.sh

echo "=== Pre-deployment Checklist ==="
echo ""

DB_NAME=${1:-"my-app"}
BRANCH=${2:-"main"}

echo "Checking branch status..."
pscale branch show "$DB_NAME" "$BRANCH"

echo ""
echo "Manual checks required:"
echo " [ ] Migration reviewed for RENAME TABLE or unsupported operations"
echo " [ ] Rollback plan documented"
echo " [ ] Application code deployed and compatible with new schema"
echo " [ ] Monitoring alerts configured"
echo " [ ] Low-traffic window confirmed"

echo ""
read -p "All checks passed? Continue with deploy request? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
 pscale deploy-request create "$DB_NAME" "$BRANCH"
 echo "Deploy request created. Review in PlanetScale dashboard before merging."
fi
```

## Best Practices Summary

- Use branches for all schema changes. Never modify production schema directly; always go through a branch and deploy request
- Store credentials in environment variables. Never commit to version control; use the CLI proxy for local development
- Review migrations before deploying. PlanetScale's deploy requests provide a diff review; use Claude to check for unsupported operations before opening the request
- Let Claude generate boilerplate code. Connection pool setup, query helpers, and migration templates are all good candidates for generation
- Test queries in development branches. Run EXPLAIN on your feature branch before deploying, since index behavior is consistent across branches
- Use the expand-and-contract pattern for column renames and type changes to avoid zero-downtime migrations
- Pin your PlanetScale CLI version in your team's setup documentation to avoid behavior changes during upgrades

Combining Claude Code with PlanetScale gives you intelligent assistance throughout the database development lifecycle. From initial schema design to deployment and optimization, Claude accelerates your workflow while PlanetScale provides the infrastructure confidence of non-blocking schema changes, automatic branching, and horizontal scale when your data grows beyond what a single MySQL instance can handle.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-with-planetscale-database-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Drizzle ORM TypeScript Database Workflow](/claude-code-drizzle-orm-typescript-database-workflow/)
- [Claude Code with Firebase Realtime Database Workflow](/claude-code-with-firebase-realtime-database-workflow/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


