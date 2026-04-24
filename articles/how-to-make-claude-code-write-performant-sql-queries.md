---

layout: default
title: "How to Make Claude Code Write"
description: "Learn techniques to guide Claude when writing SQL queries that perform well. Optimize indexes, avoid N+1 queries, and use database-specific features."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, sql, database-optimization, performance, claude-skills]
permalink: /how-to-make-claude-code-write-performant-sql-queries/
reviewed: true
score: 7
geo_optimized: true
---

Getting Claude to generate efficient SQL requires understanding how to communicate performance requirements effectively. This guide shows you concrete patterns for prompting Claude to write queries that scale.

## The Foundation: Express Performance Intent

Claude responds to clear performance signals. When you need performant queries, state your requirements explicitly rather than hoping Claude guesses.

Instead of asking "Write a query to get user orders," try: "Write a query to get all orders for a user, using an indexed column, that completes in under 50ms on a table with 10 million rows."

This approach works because Claude's training included countless Stack Overflow threads where developers complained about slow queries. The model recognizes performance-oriented language and adjusts its output accordingly.

## Indexing Strategies That Claude Understands

Effective SQL performance starts with proper indexing. When working with Claude, explicitly mention which columns need indexing and why.

Consider this scenario: you need a query finding all orders placed after a certain date. If you tell Claude "This query runs on a table with 5 million rows and needs to filter by order_date," Claude will typically suggest an index on that column. However, you get better results by being specific:

```sql
-- Claude will often generate something like this with minimal guidance
SELECT * FROM orders WHERE order_date > '2026-01-01';

-- Better: specify the index requirement explicitly
-- The orders table has ~5M rows, ordered_date is indexed
SELECT id, customer_id, total, status 
FROM orders 
WHERE order_date >= '2026-01-01' 
AND status != 'cancelled';
```

The second version specifies columns explicitly, avoiding SELECT *, and includes a status filter that could use a composite index.

## Avoiding the N+1 Query Problem

The N+1 query pattern trips up many AI-generated queries. When retrieving related data, Claude might write separate queries for each related record instead of joining efficiently.

Here's how to prevent it:

## Bad prompt: "Get all users and their posts"

Good prompt: "Get all users and their posts using a single query with a JOIN, not separate queries"

```sql
-- What Claude might write with vague instructions
-- SELECT * FROM users; then loop: SELECT * FROM posts WHERE user_id = ?

-- What you want instead
SELECT u.id, u.email, u.created_at, p.id AS post_id, p.title, p.created_at AS post_created
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.active = true
ORDER BY u.created_at DESC;
```

The LEFT JOIN retrieves all related posts in one query. If you need aggregation, use GROUP BY with aggregate functions:

```sql
SELECT 
 u.id,
 u.username,
 COUNT(p.id) AS post_count,
 MAX(p.created_at) AS latest_post
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.active = true
GROUP BY u.id, u.username
HAVING COUNT(p.id) > 0
ORDER BY post_count DESC;
```

## Optimizing Aggregate Queries

Aggregation queries often become slow as data grows. Correlated subqueries are a frequent performance killer, they execute once per row in the outer query:

```sql
-- Slow: Correlated subquery runs once per user
SELECT
 user_id,
 (SELECT COUNT(*) FROM orders WHERE user_id = users.id) as order_count,
 (SELECT SUM(total) FROM orders WHERE user_id = users.id) as total_spent
FROM users;
```

Convert these to a single JOIN with GROUP BY for dramatic improvement:

```sql
-- Optimized: Single aggregation pass
SELECT
 u.id,
 u.name,
 COUNT(o.id) as order_count,
 COALESCE(SUM(o.total), 0) as total_spent
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name;
```

When prompting Claude, be specific: "Rewrite this correlated subquery as a JOIN with GROUP BY to eliminate per-row execution." Claude recognizes the pattern and generates the optimized version while preserving result correctness.

## Composite Index Strategy

Beyond rewriting queries, ask Claude to recommend indexes that support your actual query patterns. A well-designed composite index can cover the JOIN, WHERE, and ORDER BY in a single structure:

```sql
-- Composite index covering common order query patterns
CREATE INDEX idx_orders_user_status
ON orders(user_id, status, total DESC);
```

This index serves queries that filter by user and status while sorting by total, all without touching the underlying table rows.

## Using Claude Skills for SQL Tasks

Several Claude skills enhance SQL query writing and optimization. The tdd skill helps you write tests first, then implement queries that pass those tests. This approach catches performance regressions before deployment.

For generating documentation, the pdf skill can create formatted schema documentation. The docx skill works well for internal design documents explaining your database architecture.

When working with frontend-design projects that connect to databases, combining with supermemory helps maintain context about your existing schema across sessions.

## Query Patterns That Scale

Certain patterns consistently produce faster queries. Here are techniques to request from Claude:

Use covering indexes: "Write a query that can be satisfied entirely from the index without touching the table."

```sql
-- Index: (status, created_at) INCLUDE (user_id, total)
SELECT user_id, COUNT(*) AS order_count, SUM(total) AS revenue
FROM orders
WHERE status = 'completed'
AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY user_id;
```

Prefer WHERE over HAVING: "Filter data in WHERE clause, not HAVING, since HAVING filters after aggregation."

Batch operations instead of loops: "Insert 1000 records in a single INSERT statement, not 1000 individual inserts."

```sql
-- Single bulk insert
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 101, 2, 29.99),
(1, 102, 1, 14.99),
(2, 101, 1, 29.99);
```

Use EXISTS for presence checks: When you only need to know if related records exist, EXISTS outperforms COUNT:

```sql
-- Instead of: SELECT COUNT(*) FROM orders WHERE user_id = 1 HAVING COUNT(*) > 0
-- Use:
SELECT EXISTS(SELECT 1 FROM orders WHERE user_id = 1) AS has_orders;
```

## Database-Specific Optimizations

Different databases have unique performance features. Specify your database when prompting Claude:

For PostgreSQL: mention using EXPLAIN ANALYZE, array_agg, json_agg, or window functions.

For MySQL: specify using EXPLAIN, STRAIGHT_JOIN hints, or partitioned tables.

For SQLite: note the limitations around concurrency and recommend appropriate indexing strategies.

```sql
-- PostgreSQL example with window function
SELECT 
 department,
 employee_name,
 salary,
 AVG(salary) OVER (PARTITION BY department) AS dept_avg,
 salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_avg
FROM employees
ORDER BY department, salary DESC;
```

## Testing Query Performance

Always verify that generated queries perform as expected. Ask Claude to include EXPLAIN plans in comments, then run them against realistic data volumes.

When using the tdd skill, write performance assertions:

```sql
-- Performance test expectation
-- This query should return in < 100ms on production data volume
SELECT * FROM analytics_events 
WHERE event_type = 'purchase' 
AND created_at > NOW() - INTERVAL '7 days';
```

If tests fail, use Claude's supermemory to log the slow queries and their EXPLAIN outputs for future reference.

## Summary

Making Claude write performant SQL comes down to clear communication. State your performance requirements explicitly, specify indexing needs, avoid N+1 patterns through JOINs, and test with EXPLAIN. Use skills like tdd for regression testing and supermemory for tracking query performance over time.

With these patterns, you can confidently delegate SQL writing to Claude while maintaining the performance standards your applications require.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-make-claude-code-write-performant-sql-queries)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Profiler Integration Guide](/claude-code-profiler-integration-guide/). Profile SQL queries to identify bottlenecks
- [Claude Code Memory Leak Detection Workflow](/claude-code-memory-leak-detection-workflow/). Database connections can cause memory leaks
- [Claude Code Technical Debt Tracking Workflow](/claude-code-technical-debt-tracking-workflow/). Slow queries are a form of technical debt
- [Advanced Claude Skills Hub](/advanced-hub/). Advanced database and performance patterns

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code Write Path Outside Workspace — Fix (2026)](/claude-code-write-tool-path-outside-workspace-fix-2026/)
