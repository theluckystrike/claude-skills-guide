---
layout: default
title: "Add MySQL MCP to Claude Code (2026)"
description: "Set up MySQL MCP in Claude Code for direct database queries, schema exploration, and migration generation from your editor."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-add-mysql-mcp/
categories: [guides]
tags: [claude-code, claude-skills, mysql, mcp]
reviewed: true
score: 6
geo_optimized: true
---

Adding MySQL MCP to Claude Code connects it directly to your database for schema inspection, query execution, and migration generation. This guide walks through the setup using a MySQL-compatible MCP server so Claude Code can write accurate SQL against your actual tables.

## The Problem

Claude Code generates SQL that looks correct but fails on execution because it does not know your actual table structure. Column names are guessed, JOIN conditions reference nonexistent foreign keys, and data types are wrong. You spend more time fixing generated queries than writing them from scratch. Without direct schema access, Claude Code treats your database as a black box.

## Quick Solution

**Step 1: Install the MySQL MCP server**

```bash
npm install -g @anthropic-ai/mcp-server-mysql
```

**Step 2: Get your MySQL connection details**

You need: host, port, username, password, and database name. For local development:

```text
Host: 127.0.0.1
Port: 3306
User: root
Password: your-password
Database: myapp_dev
```

**Step 3: Configure MCP in your project**

Create `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "mysql": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-mysql"],
      "env": {
        "MYSQL_HOST": "127.0.0.1",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "your-password",
        "MYSQL_DATABASE": "myapp_dev"
      }
    }
  }
}
```

**Step 4: Restart Claude Code and test**

```bash
claude
```

Verify by asking:

```text
> Show me the schema for the users table
```

Claude Code will query `INFORMATION_SCHEMA` through MCP and return your actual column definitions, indexes, and constraints.

## How It Works

The MySQL MCP server establishes a persistent connection to your database and exposes tools for schema inspection and query execution. When Claude Code needs to generate a query, it calls the `describe_table` tool to fetch column names, types, and constraints. For complex queries involving JOINs, it calls `list_tables` and inspects foreign key relationships.

All queries execute on your local machine through the MCP server process. The MCP server acts as a thin bridge between Claude Code's stdio protocol and the MySQL wire protocol. Your credentials and query results never leave your machine -- they flow directly between the MCP process and your MySQL server.

CLAUDE.md rules complement MCP by encoding business logic that schema alone cannot convey -- like which columns are soft-delete flags, which tables contain PII, or which indexes should be used for specific query patterns.

## Common Issues

**"Access denied for user" error on startup**
Verify credentials by connecting directly:

```bash
mysql -h 127.0.0.1 -P 3306 -u root -p myapp_dev
```

If this works but MCP fails, check that the password in `mcp.json` does not contain unescaped special characters in the JSON string.

**MCP server cannot connect to Docker MySQL**
If MySQL runs in Docker, use `host.docker.internal` on Mac or the container's bridge IP on Linux. Alternatively, expose the port with `-p 3306:3306` and connect to `127.0.0.1`.

**Slow schema queries on large databases**
Databases with hundreds of tables cause slow `INFORMATION_SCHEMA` queries. Add a `MYSQL_DATABASE` environment variable to restrict the MCP server to a single database rather than scanning all schemas.

## Example CLAUDE.md Section

```markdown
# MySQL Project Configuration

## Database
- MySQL 8.0 via MCP (.claude/mcp.json)
- Development: myapp_dev (local Docker)
- Test: myapp_test (local Docker, wiped between runs)
- ORM: Prisma with mysql provider

## Schema Conventions
- Primary keys: `id` BIGINT AUTO_INCREMENT
- Timestamps: `created_at`, `updated_at` (DATETIME, NOT NULL)
- Soft deletes: `deleted_at` DATETIME NULL
- Foreign keys: `{table_singular}_id` naming convention
- Indexes: prefix with `idx_`

## Rules
- NEVER run DROP, TRUNCATE, or DELETE without WHERE clause
- Always generate Prisma migrations, not raw DDL
- Use transactions for multi-table updates
- Soft-delete by setting deleted_at, never hard delete
- All queries must account for deleted_at IS NULL

## Commands
- Migrate: `npx prisma migrate dev`
- Generate client: `npx prisma generate`
- Seed: `npx prisma db seed`
- Studio: `npx prisma studio`
```

## Best Practices

1. **Use a read-only MySQL user** -- Create a user with `SELECT` and `SHOW DATABASES` privileges only. This prevents Claude Code from accidentally running destructive queries during exploration.

2. **Connect to development, never production** -- Always point MCP at your local or staging database. Add a comment in your `mcp.json` noting which environment it targets.

3. **Combine MCP with your ORM** -- Tell Claude Code to read schemas via MCP but generate changes through your ORM (Prisma, TypeORM, Knex). This ensures migrations are tracked properly.

4. **Document soft-delete patterns** -- MySQL MCP cannot infer that `deleted_at IS NULL` should be appended to every query. State this rule explicitly in CLAUDE.md.

5. **Restrict to one database** -- Set the `MYSQL_DATABASE` environment variable to avoid exposing other databases on the same server to Claude Code.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-add-mysql-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)
- [Claude Code for Postgres Full Text Search Workflow](/claude-code-for-postgres-full-text-search-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
