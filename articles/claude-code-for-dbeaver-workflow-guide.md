---
layout: default
title: "Claude Code for DBeaver"
description: "Manage databases with DBeaver and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-dbeaver-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, dbeaver, workflow]
---

## The Setup

You are using DBeaver as your universal database tool — a free, open-source GUI that supports every major database (PostgreSQL, MySQL, MongoDB, SQLite, Oracle, and dozens more). DBeaver provides an ER diagram viewer, data editor, SQL editor with autocomplete, and database comparison tools. Claude Code generates SQL and database commands, but it assumes command-line database clients.

## What Claude Code Gets Wrong By Default

1. **Writes CLI-specific database commands.** Claude generates `psql`, `mysql`, or `mongosh` commands for database operations. With DBeaver, you run queries in the SQL editor — generate pure SQL, not CLI wrapper commands.

2. **Creates scripts for data export.** Claude writes Python scripts to export data to CSV. DBeaver has built-in data export to CSV, JSON, XML, SQL inserts, and more — right-click any result set to export.

3. **Ignores ER diagram generation.** Claude describes table relationships in text. DBeaver auto-generates ER diagrams from your schema — tell Claude to create proper foreign keys so DBeaver visualizes relationships correctly.

4. **Manages connections in code.** Claude puts connection strings in config files for scripts. DBeaver manages connections separately — generate SQL queries that work in DBeaver's SQL editor, not connection-embedded scripts.

## The CLAUDE.md Configuration

```
# DBeaver Database Project

## Database
- GUI: DBeaver (universal database manager)
- Supported: PostgreSQL, MySQL, SQLite, MongoDB, and more
- Editor: SQL editor with autocomplete
- Visualization: ER diagrams, data editor

## DBeaver Rules
- Generate standard SQL, not CLI commands
- Use proper foreign keys for ER diagram visualization
- Schema changes via SQL scripts runnable in DBeaver
- Use EXPLAIN for query optimization (DBeaver shows visual plan)
- Transactions: BEGIN/COMMIT for safe schema changes
- Comments in SQL for clarity in saved scripts

## Conventions
- Pure SQL output — no psql/mysql/mongosh wrappers
- CREATE TABLE with explicit foreign keys and constraints
- Indexes: CREATE INDEX with clear naming conventions
- Use DBeaver's data editor for manual data fixes
- ER diagrams: ensure proper FK relationships
- Use schemas for logical grouping in PostgreSQL
```

## Workflow Example

You want to redesign a database schema for better performance. Prompt Claude Code:

"Analyze this schema and generate SQL to normalize the orders table. Split address data into a separate addresses table, add proper foreign keys, and create indexes for commonly queried columns. Output pure SQL that I can run in DBeaver's SQL editor."

Claude Code should generate `CREATE TABLE addresses` with proper columns, `ALTER TABLE orders` to add a foreign key reference, `CREATE INDEX` statements for query-critical columns, and data migration `INSERT INTO ... SELECT` statements — all as standard SQL without CLI wrappers.

## Common Pitfalls

1. **Database-specific syntax without noting it.** Claude generates PostgreSQL-specific syntax like `SERIAL` or `RETURNING` when you might be using MySQL. Specify your database engine in the CLAUDE.md so queries are compatible with your DBeaver connection.

2. **Large data modifications without safety.** Claude generates `UPDATE` or `DELETE` statements affecting millions of rows. In DBeaver, always wrap large modifications in a transaction and verify the row count before committing.

3. **Missing schema qualification.** Claude writes `SELECT * FROM users` without schema prefix. In DBeaver with multiple schemas, use `SELECT * FROM public.users` to avoid ambiguity when switching between database connections.

## Related Guides

- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)
- [Claude Code for Drizzle ORM Workflow Guide](/claude-code-for-drizzle-orm-workflow-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
