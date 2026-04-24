---
title: "Reducing Claude Code MCP Round-Trips (2026)"
description: "Batch MCP operations reduce Claude Code round-trips by 60-80%, cutting tool call overhead from 2,450 tokens to 490 tokens for 10-operation sequences."
permalink: /reducing-claude-code-mcp-round-trips-batch-pattern/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Reducing Claude Code MCP Round-Trips: Batch Operations Pattern

## The Pattern

The batch operations pattern consolidates multiple MCP tool calls into a single call that accepts an array of operations and returns all results at once. Instead of 10 separate MCP round-trips (each with ~200 tokens overhead), one batch call achieves the same work with a single ~200 token overhead plus the operation descriptions.

## Why It Matters for Token Cost

Every MCP tool call in Claude Code carries overhead: tool call framing (~200 tokens), the model's reasoning about the call (~100-300 tokens), and the response framing (~100 tokens). For a sequence of 10 related operations:

- **10 individual calls**: 10 x (~200 + ~200 + ~100) = ~5,000 tokens in pure overhead
- **1 batch call**: 1 x (~200 + ~400 + ~100) = ~700 tokens in overhead

The batch approach saves ~4,300 tokens in overhead alone. Add context accumulation (each individual call adds to the conversation history, which is re-sent on every subsequent turn), and the savings multiply. In a 20-turn session, 10 early MCP calls add ~5,000 tokens that compound across 15 remaining turns = 75,000 extra input tokens ($0.225 on Sonnet 4.6).

## The Anti-Pattern (What NOT to Do)

```javascript
// Anti-pattern: Sequential MCP calls for related operations
// Claude Code makes 5 separate tool calls:

// Call 1: Get user
mcp__db__query({ sql: "SELECT * FROM users WHERE id = $1", params: ["user-123"] })
// Call 2: Get orders
mcp__db__query({ sql: "SELECT * FROM orders WHERE user_id = $1", params: ["user-123"] })
// Call 3: Get subscriptions
mcp__db__query({ sql: "SELECT * FROM subscriptions WHERE user_id = $1", params: ["user-123"] })
// Call 4: Get payment methods
mcp__db__query({ sql: "SELECT * FROM payment_methods WHERE user_id = $1", params: ["user-123"] })
// Call 5: Get activity log
mcp__db__query({ sql: "SELECT * FROM activity_log WHERE user_id = $1 ORDER BY ts DESC LIMIT 10", params: ["user-123"] })

// Total overhead: 5 x ~500 = ~2,500 tokens
// Plus each response stays in context for all subsequent turns
```

## The Pattern in Action

### Step 1: Design the Batch Tool

```javascript
// MCP server: batch query tool
{
  name: "batch_query",
  description: "Run multiple SQL queries in one call. Returns array of results.",
  inputSchema: {
    type: "object",
    properties: {
      queries: {
        type: "array",
        items: {
          type: "object",
          properties: {
            label: { type: "string" },
            sql: { type: "string" },
            params: { type: "array", items: { type: "string" } }
          },
          required: ["label", "sql"]
        },
        maxItems: 20  // Bounded: prevent unbounded batch sizes
      }
    },
    required: ["queries"]
  }
}
```

### Step 2: Implement the Batch Handler

```javascript
// MCP server handler
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "batch_query") {
    const { queries } = request.params.arguments;
    const MAX_QUERIES = 20; // Bounded: NASA P10 Rule 2
    const QUERY_TIMEOUT_MS = 5000;

    const limitedQueries = queries.slice(0, MAX_QUERIES);
    const results = {};

    for (const query of limitedQueries) {
      try {
        const result = await Promise.race([
          pool.query(query.sql, query.params || []),
          new Promise((_, reject) =>
            setTimeout(() => reject(new Error("Query timeout")), QUERY_TIMEOUT_MS)
          )
        ]);
        results[query.label] = { rows: result.rows, count: result.rowCount };
      } catch (error) {
        results[query.label] = { error: error.message };
      }
    }

    return {
      content: [{ type: "text", text: JSON.stringify(results) }]
    };
  }
});
```

### Step 3: Claude Code Uses One Call Instead of Five

```javascript
// Single batch call replaces 5 individual calls
mcp__db__batch_query({
  queries: [
    { label: "user", sql: "SELECT * FROM users WHERE id = $1", params: ["user-123"] },
    { label: "orders", sql: "SELECT * FROM orders WHERE user_id = $1", params: ["user-123"] },
    { label: "subs", sql: "SELECT * FROM subscriptions WHERE user_id = $1", params: ["user-123"] },
    { label: "payments", sql: "SELECT * FROM payment_methods WHERE user_id = $1", params: ["user-123"] },
    { label: "activity", sql: "SELECT * FROM activity_log WHERE user_id = $1 ORDER BY ts DESC LIMIT 10", params: ["user-123"] }
  ]
})

// Total overhead: 1 x ~500 = ~500 tokens (vs 2,500 for individual calls)
```

## Before and After

| Metric | Individual Calls (5) | Batch Call (1) | Improvement |
|--------|---------------------|---------------|-------------|
| Tool call overhead | ~2,500 tokens | ~500 tokens | 80% reduction |
| Conversational turns used | 5 | 1 | 80% fewer |
| Context accumulation (20-turn session) | ~37,500 tokens | ~7,500 tokens | 80% reduction |
| Response handling | 5 separate results in context | 1 consolidated result | Cleaner context |
| Total cost impact (Sonnet 4.6) | ~$0.12 | ~$0.02 | $0.10 saved |

For a developer making 3 batch-eligible sequences per day, 20 days/month: **$6.00/month savings**.

### Batch Beyond Database Queries

The pattern applies to any MCP operation that can be parallelized:

```javascript
// Batch file operations
{
  name: "batch_read",
  description: "Read multiple files in one call",
  inputSchema: {
    type: "object",
    properties: {
      paths: {
        type: "array",
        items: { type: "string" },
        maxItems: 20
      }
    },
    required: ["paths"]
  }
}

// Handler returns all file contents in one response
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "batch_read") {
    const results = {};
    const paths = request.params.arguments.paths.slice(0, 20);
    for (const p of paths) {
      try {
        results[p] = await fs.promises.readFile(p, "utf-8");
      } catch (error) {
        results[p] = { error: error.message };
      }
    }
    return { content: [{ type: "text", text: JSON.stringify(results) }] };
  }
});
```

```javascript
// Batch API health checks
{
  name: "batch_health",
  description: "Check health of multiple endpoints",
  inputSchema: {
    type: "object",
    properties: {
      urls: {
        type: "array",
        items: { type: "string" },
        maxItems: 10
      }
    },
    required: ["urls"]
  }
}
```

Each batch variant eliminates N-1 round-trips, where N is the number of operations. For 5 file reads: 4 saved round-trips x ~500 tokens = 2,000 tokens saved. For 8 health checks: 7 saved round-trips x ~500 tokens = 3,500 tokens saved.

## When to Use This Pattern

- **Multi-table data fetching**: Gathering data from 3+ related tables for a single feature or report.
- **Bulk status checks**: Verifying multiple services, endpoints, or resources in one operation.
- **Migration verification**: Checking 5-10 tables after a database migration to confirm data integrity.

### Error Handling in Batch Operations

Batch operations require careful error handling to prevent one failed operation from invalidating the entire batch:

```javascript
// Each operation in the batch has its own error handling
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "batch_query") {
    const { queries } = request.params.arguments;
    const MAX_QUERIES = 20;
    const QUERY_TIMEOUT_MS = 5000;

    const results = {};

    for (const query of queries.slice(0, MAX_QUERIES)) {
      try {
        const result = await Promise.race([
          pool.query(query.sql, query.params || []),
          new Promise((_, reject) =>
            setTimeout(() => reject(new Error("Timeout")), QUERY_TIMEOUT_MS)
          )
        ]);
        results[query.label] = {
          status: "ok",
          rows: result.rows.slice(0, 50),  // Cap row count
          count: result.rowCount
        };
      } catch (error) {
        // Individual query failure does not stop the batch
        results[query.label] = {
          status: "error",
          message: error.message
        };
      }
    }

    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          results,
          succeeded: Object.values(results).filter(r => r.status === "ok").length,
          failed: Object.values(results).filter(r => r.status === "error").length
        })
      }]
    };
  }
});
```

Claude Code reads the batch response and knows immediately which queries succeeded and which failed, without needing to diagnose individual failures through additional tool calls. The structured error response saves 500-1,500 tokens per failed query that would otherwise require diagnostic calls.

### Batch Response Compression

Large batch responses can themselves become expensive context. Compress batch results by returning only essential fields:

```javascript
// Instead of returning full row data:
// { user: { id, email, name, avatar, bio, created_at, updated_at, ... } }

// Return compact summaries:
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "batch_summary") {
    const { entity_type, ids } = request.params.arguments;
    const MAX_IDS = 50;
    const limitedIds = ids.slice(0, MAX_IDS);

    const rows = await pool.query(
      `SELECT id, email, name FROM users WHERE id = ANY($1)`,
      [limitedIds]
    );

    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          count: rows.rowCount,
          items: rows.rows  // Only 3 fields instead of 12
        })
      }]
    };
  }
});
```

A full user record might be 200-300 tokens. A compact summary is 30-50 tokens. For a batch of 20 users, the difference is 3,000-5,000 tokens in response size. Combined with the round-trip savings, batch + compression reduces total token cost by 85-90% compared to individual full-record queries.

## When NOT to Use This Pattern

- **Sequential dependencies**: When query B depends on the result of query A. These cannot batch because the second query needs the first query's output.
- **Single operations**: Batching a single operation adds complexity with no benefit.
- **Very large result sets**: If each query returns 100+ rows, batching all responses into one JSON object creates an enormous context payload. Cap result sizes with LIMIT clauses.

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md -- Batch Operations Rule

## Database Queries
- When querying 3+ tables for the same entity, use `batch_query` MCP tool
- Provide a descriptive `label` for each query in the batch
- Maximum 20 queries per batch (enforce bounded operations)
- If a query depends on another query's result, use sequential calls for the dependent pair
```

## Related Guides

- [State Inspection Pattern: Give Agents Full Backend State in One Call](/state-inspection-pattern-agents-full-state-one-call/) -- the inspection variant of batch operations
- [Building Token-Efficient MCP Servers for Claude Code](/building-token-efficient-mcp-servers-claude-code/) -- design servers with batch support
- [CLI vs MCP for Agent Operations: Token Cost Comparison](/cli-vs-mcp-agent-operations-token-cost/) -- when CLI is cheaper than MCP
