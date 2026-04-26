---
layout: default
title: "Claude Code for ClickHouse (2026)"
description: "Claude Code for ClickHouse — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-clickhouse-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, clickhouse, workflow]
---

## The Setup

You are using ClickHouse for real-time analytics, handling billions of rows with sub-second query performance. ClickHouse uses column-oriented storage and its own SQL dialect with specialized functions. Claude Code can write ClickHouse queries and schema definitions, but it generates PostgreSQL syntax that fails on ClickHouse's different SQL dialect and storage engine model.

## What Claude Code Gets Wrong By Default

1. **Writes PostgreSQL-compatible SQL.** Claude uses `SERIAL PRIMARY KEY`, `VARCHAR`, and `UPDATE` statements. ClickHouse uses `UInt64`, `String`, and strongly discourages row-level updates — it is append-only by design.

2. **Creates normalized schemas with foreign keys.** Claude designs relational schemas with joins. ClickHouse performs best with denormalized, wide tables. Joins work but are expensive — pre-join data at insert time.

3. **Uses `UPDATE` and `DELETE` for data changes.** Claude writes row-level modifications. ClickHouse uses `ALTER TABLE ... UPDATE` (async mutations) which are heavy operations, not for transactional workloads.

4. **Ignores engine and partition configuration.** Claude creates tables without specifying the engine. ClickHouse requires an explicit engine (`MergeTree`, `ReplacingMergeTree`, etc.) and partition/order keys for query performance.

## The CLAUDE.md Configuration

```
# ClickHouse Analytics Project

## Database
- Engine: ClickHouse (column-oriented, real-time analytics)
- Client: @clickhouse/client for Node.js
- SQL dialect: ClickHouse SQL (NOT standard PostgreSQL)

## ClickHouse Rules
- Tables need ENGINE = MergeTree() with ORDER BY clause
- Partition by date: PARTITION BY toYYYYMM(created_at)
- Data types: UInt32, Int64, String, DateTime, Float64
- No AUTO_INCREMENT — use generateUUIDv4() or supply IDs
- Denormalize data — avoid joins on large tables
- INSERT is fast; UPDATE/DELETE are async mutations (avoid)
- Use Materialized Views for pre-aggregation
- Use Array and Nested types for multi-value columns

## Conventions
- Schema in migrations/ directory (SQL files)
- Analytics queries in queries/ directory
- Materialized Views for dashboards and reports
- Batch inserts: insert in batches of 10K+ rows
- Never single-row inserts in loops
- Use JSONEachRow format for bulk imports
- TTL for automatic data expiration
```

## Workflow Example

You want to create an event analytics table and a dashboard query. Prompt Claude Code:

"Create a ClickHouse events table for product analytics with event name, user ID, properties (as JSON), timestamp, and country. Partition by month, order by timestamp. Write a query that shows top 10 events by count in the last 7 days grouped by country."

Claude Code should create the table with `ENGINE = MergeTree() PARTITION BY toYYYYMM(timestamp) ORDER BY (timestamp, user_id)`, use ClickHouse types (`String`, `DateTime`, `Map(String, String)` for properties), and write the analytics query using ClickHouse functions like `toStartOfDay()`, `countIf()`, and proper `WHERE timestamp > now() - INTERVAL 7 DAY`.

## Common Pitfalls

1. **Single-row inserts destroying performance.** Claude inserts events one at a time in a loop. ClickHouse optimizes for batch inserts of thousands of rows. Buffer events in memory or a queue and flush in batches.

2. **ORDER BY column selection.** Claude uses `ORDER BY id` like PostgreSQL. ClickHouse's ORDER BY determines the primary index for query performance. Choose columns that match your most common WHERE clauses (usually timestamp + a high-cardinality column).

3. **Expecting transactional consistency.** Claude writes code expecting read-after-write consistency. ClickHouse uses eventual consistency for Materialized Views and async mutations. Recent inserts may not appear in MV queries immediately.

## Related Guides

- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Best Way to Feed Claude Code a Large SQL Schema](/best-way-to-feed-claude-code-a-large-sql-schema/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)


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
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
