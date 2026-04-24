---
layout: default
title: "Claude Code for RisingWave Streaming"
description: "Build streaming pipelines with RisingWave and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-risingwave-streaming-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, risingwave, workflow]
---

## The Setup

You are building real-time streaming data pipelines with RisingWave, a Postgres-compatible streaming database. Unlike Kafka + Flink setups, RisingWave lets you write SQL to define streaming computations — materialized views that update continuously as new data arrives. Claude Code can build data pipelines, but it generates Kafka consumer code or Flink jobs instead of RisingWave's SQL-based approach. For a deeper dive, see [Claude Code for Turso Database — Workflow Guide](/claude-code-for-turso-edge-database-workflow-guide/).

## What Claude Code Gets Wrong By Default

1. **Creates Kafka consumers in Python/Java.** Claude writes consumer applications that poll topics and process records. RisingWave replaces consumer code with SQL — `CREATE MATERIALIZED VIEW` defines the transformation, and RisingWave continuously updates it.

2. **Deploys Apache Flink for stream processing.** Claude sets up Flink clusters with Java stream processing jobs. RisingWave provides the same capabilities through SQL — no JVM, no Flink cluster management, no Java code.

3. **Uses batch SQL queries on a schedule.** Claude creates cron jobs that run `SELECT` queries periodically. RisingWave's materialized views update incrementally in real-time — there is no polling or scheduling needed.

4. **Ignores Postgres compatibility.** Claude connects with custom streaming SDKs. RisingWave speaks the Postgres wire protocol — connect with `psql`, any Postgres driver, or standard BI tools. Learn more in [Claude Code for Standard Schema — Workflow Guide](/claude-code-for-standard-schema-workflow-guide/).

## The CLAUDE.md Configuration

```
# RisingWave Streaming Project

## Database
- Engine: RisingWave (streaming SQL database)
- Protocol: PostgreSQL compatible
- Processing: SQL materialized views (real-time)
- Sources: Kafka, Kinesis, Pulsar, S3, databases

## RisingWave Rules
- Sources: CREATE SOURCE for ingesting streams
- Sinks: CREATE SINK for outputting results
- MV: CREATE MATERIALIZED VIEW for transformations
- SQL: standard PostgreSQL with streaming extensions
- Connect: psql or any Postgres driver/ORM
- Time: event time processing with watermarks
- Windows: TUMBLE, HOP, SESSION window functions

## Conventions
- Define sources from Kafka/Kinesis topics
- Materialized views for real-time aggregations
- Use watermarks for event-time processing
- Window functions for time-based aggregations
- Sinks to Kafka, PostgreSQL, or other destinations
- Connect application via standard Postgres drivers
- Monitor with system tables and RisingWave dashboard
```

## Workflow Example

You want to build a real-time analytics dashboard for website events. Prompt Claude Code:

"Create RisingWave SQL to process website click events from Kafka. Create a source from the Kafka topic, materialized views for page views per minute, unique visitors per hour, and top pages by views. Output results to a PostgreSQL sink for the dashboard."

Claude Code should write `CREATE SOURCE` for the Kafka topic with JSON format, `CREATE MATERIALIZED VIEW pageviews_per_minute` using `TUMBLE` window, `CREATE MATERIALIZED VIEW unique_visitors_hourly` using `HOP` window with `COUNT(DISTINCT user_id)`, `CREATE MATERIALIZED VIEW top_pages` with `GROUP BY page`, and `CREATE SINK` to output to PostgreSQL.

## Common Pitfalls

1. **Missing watermark configuration.** Claude creates time-based windows without defining watermarks. RisingWave needs watermarks to handle late-arriving events — without them, results may be incorrect or windows never close. Add `WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND`.

2. **Treating materialized views as batch queries.** Claude queries materialized views expecting batch-style execution plans. RisingWave MVs update incrementally — complex joins and aggregations have different performance characteristics than batch databases. Monitor with `EXPLAIN CREATE MATERIALIZED VIEW`.

3. **Not managing source schemas.** Claude creates sources without explicit schemas. When the upstream schema changes (new Kafka fields), the source breaks. Define explicit schemas and handle schema evolution with `ALTER SOURCE`.

## Related Guides

- [Claude Code for ClickHouse Workflow Guide](/claude-code-for-clickhouse-workflow-guide/)
- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
