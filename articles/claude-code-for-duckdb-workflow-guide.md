---
layout: default
title: "Claude Code for DuckDB — Workflow Guide"
description: "Claude Code for DuckDB — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-duckdb-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, duckdb, workflow]
---

## The Setup

You are using DuckDB for analytical queries — an in-process OLAP database that runs SQL directly on Parquet files, CSVs, and JSON without loading data into a separate database. DuckDB is ideal for data analysis, ETL pipelines, and local analytics. Claude Code can write DuckDB queries, but it defaults to PostgreSQL syntax and ignores DuckDB's unique ability to query files directly.

## What Claude Code Gets Wrong By Default

1. **Sets up a PostgreSQL connection.** Claude creates a database server connection. DuckDB is in-process — `new duckdb.Database(':memory:')` or `new duckdb.Database('analytics.db')` runs embedded, no server needed.

2. **Loads data with INSERT statements.** Claude writes row-by-row INSERT logic. DuckDB reads files directly: `SELECT * FROM 'data.parquet'` or `SELECT * FROM read_csv('data.csv')` — no import step needed.

3. **Uses Node.js for data transformation.** Claude reads files into JavaScript and transforms with array methods. DuckDB handles transformations in SQL: window functions, pivots, and complex aggregations run directly on files.

4. **Ignores DuckDB extensions.** Claude writes custom code for HTTP data access or spatial queries. DuckDB has extensions: `INSTALL httpfs; SELECT * FROM 'https://example.com/data.parquet'` reads remote files directly.

## The CLAUDE.md Configuration

```
# DuckDB Analytics Project

## Database
- Engine: DuckDB (in-process OLAP)
- Client: duckdb or @duckdb/node-api
- Storage: in-memory or local .duckdb file
- File queries: Parquet, CSV, JSON queried directly

## DuckDB Rules
- No server — runs in-process: new duckdb.Database()
- Query files: SELECT * FROM 'file.parquet'
- CSV: SELECT * FROM read_csv('data.csv', auto_detect=true)
- JSON: SELECT * FROM read_json('data.json')
- Remote: INSTALL httpfs; SELECT * FROM 'https://url/file.parquet'
- Export: COPY (SELECT ...) TO 'output.parquet' (FORMAT PARQUET)
- Extensions: INSTALL extension; LOAD extension

## Conventions
- Analytics queries in queries/ directory
- DuckDB instance in lib/duckdb.ts
- Use in-memory for ephemeral analysis, file for persistence
- Parquet for large datasets (columnar, compressed)
- Window functions for time-series and ranking queries
- GROUP BY ALL for convenient aggregation
- Use EXPLAIN ANALYZE to optimize query performance
```

## Workflow Example

You want to analyze CSV log data with DuckDB. Prompt Claude Code:

"Write a DuckDB query that reads server access logs from a CSV file, calculates requests per hour, identifies the top 10 endpoints by traffic, and exports the results as a Parquet file for archival."

Claude Code should query the CSV directly with `read_csv()`, use `date_trunc('hour', timestamp)` for hourly aggregation, `ROW_NUMBER() OVER (ORDER BY count(*) DESC)` for ranking, and `COPY (...) TO 'report.parquet' (FORMAT PARQUET)` for the export — all in pure SQL.

## Common Pitfalls

1. **Memory exhaustion on large files.** Claude reads entire datasets into memory. DuckDB streams data from files, but some operations (large JOINs, unbound GROUP BY) need memory. Use `SET memory_limit='4GB'` and consider partitioning for very large datasets.

2. **Type inference surprises with CSVs.** Claude assumes column types from CSV headers. DuckDB auto-detects types but can guess wrong on ambiguous columns (dates as strings, IDs as integers). Use explicit `read_csv('file.csv', columns={'id': 'VARCHAR', 'date': 'DATE'})`.

3. **Concurrent write conflicts.** Claude opens the same DuckDB file from multiple processes. DuckDB supports concurrent reads but only one writer. Use `access_mode='read_only'` for reader processes and a single writer process.

## Related Guides

- [Best Way to Feed Claude Code a Large SQL Schema](/best-way-to-feed-claude-code-a-large-sql-schema/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code For Chainlink Vrf — Complete Developer Guide](/claude-code-for-chainlink-vrf-workflow-guide/)
- [Claude Code for Criterion Benchmarking Workflow Guide](/claude-code-for-criterion-benchmarking-workflow-guide/)
- [Claude Code LaunchDarkly Targeting Rules Setup Workflow](/claude-code-launchdarkly-targeting-rules-setup-workflow/)
- [Claude Code GitBook Documentation Workflow](/claude-code-gitbook-documentation-workflow/)
- [Claude Code Structured Logging Best Practices Workflow](/claude-code-structured-logging-best-practices-workflow/)
- [Claude Code Terragrunt Modules — Complete Developer Guide](/claude-code-terragrunt-modules-workflow/)
- [Claude Code for Arrow Flight Workflow Tutorial](/claude-code-for-arrow-flight-workflow-tutorial/)
- [Claude Code Jupyter Notebook Analysis Workflow Guide](/claude-code-jupyter-notebook-analysis-workflow-guide/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
