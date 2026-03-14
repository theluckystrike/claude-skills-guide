---
layout: default
title: "How to Make Claude Code Write Performant SQL Queries"
description: "A practical guide to getting Claude Code to generate efficient, optimized SQL queries. Learn prompt engineering techniques and skill combinations."
date: 2026-03-14
categories: [guides]
tags: [claude-code, sql, performance, database, claude-skills, tdd, code-review]
author: theluckystrike
reviewed: true
score: 8
permalink: /how-to-make-claude-code-write-performant-sql-queries/
---

# How to Make Claude Code Write Performant SQL Queries

Getting Claude Code to generate efficient SQL queries requires understanding how LLMs approach database operations and applying specific techniques to guide output toward performance-conscious solutions. If you want **how to make claude code write performant sql queries** effectively, this guide covers practical methods to improve query performance when working with Claude Code.

## Understanding the Performance Problem

Claude Code often generates functional SQL that works correctly but may not perform optimally. The model tends toward straightforward solutions that prioritize readability over efficiency. Common issues include missing indexes, N+1 query patterns, unnecessary full table scans, and suboptimal JOIN structures.

When generating database code, Claude follows patterns it has seen in training data, which may not align with your specific database schema, data volume, or performance requirements. The solution involves combining specific prompting techniques with the right skill stack.

## Start with the Right Skill Configuration

Claude Code skills extend the model's capabilities in targeted areas. For SQL performance, several skills work together effectively.

The **tdd** skill helps create performance tests that validate query execution time. By specifying performance requirements in test cases, you establish benchmarks that guide query design:

```
/tdd create performance tests for this user query, verify response time under 100ms with 10000 records
```

The **code-review** skill analyzes generated SQL for common performance anti-patterns. Running it after query generation adds a review layer:

```
/code-review analyze this SQL query for performance issues, missing indexes, and N+1 patterns
```

For projects using ORMs, the **orm** skill can generate query patterns optimized for your specific framework, whether you use SQLAlchemy, Prisma, or another ORM.

## Prompt Engineering for SQL Performance

Your prompts determine the quality of generated SQL. Include performance requirements explicitly in your requests.

### Specify Performance Constraints

Instead of generic requests, embed performance requirements directly:

```
Generate a query to fetch user orders with:
- Total order value aggregated per user
- Filter for orders from the last 30 days
- Use indexed columns for filtering (user_id, created_at)
- Avoid subqueries in WHERE clauses
- Target execution time under 50ms
```

### Request EXPLAIN Analysis

Ask Claude to include query execution plans in its output:

```
Write a query to calculate user engagement metrics and explain which indexes would improve performance
```

Claude will often include analysis of the query plan and suggest index strategies.

### Define Schema Context

Provide schema information in your prompts:

```
Given this schema:
users (id, email, created_at, status)
orders (id, user_id, total, created_at)
order_items (id, order_id, product_id, quantity, price)

Write a query that:
- Joins efficiently using indexed foreign keys
- Uses WHERE clauses on indexed columns
- Avoids SELECT * and only fetches needed columns
```

## Optimizing Common Query Patterns

### Avoid N+1 Queries

Claude often generates queries that work but trigger multiple database calls. Specify batch loading:

```
Generate an API endpoint that fetches users with their order counts.
Use a single query with JOIN, not separate queries per user.
```

### Optimize JOIN Order and Type

Guide Claude toward efficient JOIN strategies:

```
Write a query joining users, orders, and products.
- Lead with the smallest table in FROM clause
- Use INNER JOIN when possible
- Put filtering conditions on the right table in LEFT JOINs
- Use EXISTS instead of IN for correlated subqueries
```

### Request Proper Index Usage

Make index awareness explicit:

```
Write a query to find active users who placed orders in Q1 2024.
Use indexed columns: users.status, orders.user_id, orders.created_at.
Explain which indexes would optimize this query.
```

## Using Code Review for Performance Validation

The **code-review** skill serves as a final checkpoint. Configure it to flag performance issues:

```
Review this SQL for:
- Missing WHERE clause on large tables
- SELECT * usage that pulls unnecessary data
- Implicit conversions that prevent index usage
- Missing LIMIT on large result sets
- Subqueries that could be JOINs
```

Claude Code with the code-review skill will analyze generated SQL and suggest specific improvements.

## Performance Testing with TDD

The **tdd** skill extends to performance validation. Create tests that enforce query performance:

```
Write integration tests that:
- Verify query executes under 200ms
- Test with production-scale data volumes
- Validate index usage via EXPLAIN
- Measure query plan efficiency
```

These tests become regression guards that ensure future changes don't degrade performance.

## Handling Large Result Sets

For queries returning many rows, specify pagination and streaming:

```
Write a paginated query for the orders table:
- Use cursor-based pagination (ORDER BY id LIMIT N)
- Avoid OFFSET for large tables
- Include total count query separately
- Suggest proper indexing for pagination
```

## Database-Specific Optimizations

Different databases have unique performance characteristics. Specify your database in prompts:

For PostgreSQL:
```
Write a query using PostgreSQL-specific optimizations:
- Use DISTINCT ON
- Leverage window functions
- Include USING for join conditions
- Use COALESCE appropriately
```

For MySQL:
```
Write a query optimized for MySQL:
- Use STRAIGHT_JOIN when appropriate
- Consider FORCE INDEX hints
- Optimize for InnoDB patterns
```

## Best Practices Summary

1. **Include schema context** in every SQL generation prompt
2. **Specify performance requirements** explicitly (execution time, result set size)
3. **Request EXPLAIN plans** and index recommendations
4. **Use code-review skill** as a performance gate
5. **Create performance tests** with the tdd skill
6. **Specify your database** for dialect-specific optimizations
7. **Guide JOIN strategies** explicitly rather than accepting defaults

## Advanced: Combining Skills for Full Lifecycle

For comprehensive SQL performance management, combine multiple skills:

1. Use **tdd** to create performance test specifications
2. Generate SQL with explicit performance constraints
3. Run **code-review** to catch anti-patterns
4. Use **db-design** skill (if available) to plan proper indexes
5. Deploy with monitoring to validate real-world performance

This workflow ensures generated SQL meets performance requirements from creation through deployment.

---


## Related Reading

- [How to Write Effective Prompts for Claude Code](/claude-skills-guide/how-to-write-effective-prompts-for-claude-code/)
- [Best Way to Scope Tasks for Claude Code Success](/claude-skills-guide/best-way-to-scope-tasks-for-claude-code-success/)
- [Claude Code Output Quality: How to Improve Results](/claude-skills-guide/claude-code-output-quality-how-to-improve-results/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
