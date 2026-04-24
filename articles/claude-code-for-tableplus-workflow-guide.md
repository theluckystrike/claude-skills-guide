---
layout: default
title: "Claude Code for TablePlus"
description: "Manage databases with TablePlus GUI and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-tableplus-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, tableplus, workflow]
---

## The Setup

You are managing databases with TablePlus, a native database GUI for macOS, Windows, and Linux that supports PostgreSQL, MySQL, SQLite, Redis, MongoDB, and more. TablePlus provides a fast, clean interface for browsing data, writing queries, and managing schemas. Claude Code generates SQL and manages databases, but it assumes command-line tools and outputs CLI-specific commands.

## What Claude Code Gets Wrong By Default

1. **Outputs psql or mysql CLI commands.** Claude writes `psql -c "SELECT..."` or `mysql -e "SELECT..."`. With TablePlus, you paste SQL into the query editor and run it — generate pure SQL statements, not CLI wrapper commands.

2. **Creates pgAdmin or phpMyAdmin workflows.** Claude references web-based admin panels. TablePlus is a native desktop app — it has its own connection manager, query editor, and data browser with keyboard shortcuts.

3. **Builds data export scripts.** Claude writes Python scripts to export CSV data. TablePlus exports data with Cmd+Shift+E from any result set — to CSV, JSON, SQL, or other formats natively.

4. **Suggests SSH tunnels via terminal.** Claude tells you to run `ssh -L 5432:localhost:5432`. TablePlus has built-in SSH tunnel support in the connection dialog — configure the SSH hop directly in the connection settings.

## The CLAUDE.md Configuration

```
# TablePlus Database Project

## Database GUI
- Tool: TablePlus (native database client)
- Databases: PostgreSQL, MySQL, SQLite, Redis, MongoDB
- Features: query editor, data browser, SSH tunnels
- Platform: macOS/Windows/Linux native app

## TablePlus Rules
- Generate pure SQL, not CLI wrapper commands
- Schema changes: SQL scripts for the query editor
- Migrations: provide SQL runnable in query editor
- Use EXPLAIN for query analysis (visual plan in TablePlus)
- Safe mode: TablePlus requires Cmd+S to commit changes
- Connections: managed in TablePlus, not .env files

## Conventions
- Pure SQL output for all database operations
- Include comments for complex queries
- Use transactions for multi-statement operations
- Test with EXPLAIN ANALYZE before optimizing
- Data browsing: use TablePlus GUI, not SELECT *
- Exports: TablePlus handles CSV/JSON export
- SSH tunnels: configured in TablePlus connection settings
```

## Workflow Example

You want to optimize a slow query and add missing indexes. Prompt Claude Code:

"Analyze this query that joins orders, customers, and products tables. Provide the EXPLAIN ANALYZE statement to test in TablePlus, identify missing indexes, and generate CREATE INDEX statements. Output pure SQL for the TablePlus query editor."

Claude Code should output the original query with `EXPLAIN ANALYZE` prepended, analyze the query plan to identify sequential scans and missing indexes, generate `CREATE INDEX` statements with descriptive names, and provide a comment explaining which part of the query each index optimizes.

## Common Pitfalls

1. **Forgetting TablePlus safe mode.** Claude tells you to run UPDATE or DELETE statements. TablePlus has safe mode enabled by default — changes in the data editor require Cmd+S to commit. In the query editor, queries execute immediately. Be aware of which mode you are using.

2. **Connection string confusion.** Claude puts connection details in `.env` for the application and tells you to also configure TablePlus. Keep these separate — your app uses `.env` for runtime connections, TablePlus stores connections in its own encrypted format.

3. **Large result sets freezing the GUI.** Claude runs `SELECT * FROM large_table` without LIMIT. TablePlus loads results into memory — always add `LIMIT 1000` when exploring large tables to prevent the GUI from becoming unresponsive.

## Related Guides

- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)
- [Claude Code for Drizzle ORM Workflow Guide](/claude-code-for-drizzle-orm-workflow-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
