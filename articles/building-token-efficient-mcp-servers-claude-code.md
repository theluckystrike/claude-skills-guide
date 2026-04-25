---
title: "Building Token-Efficient MCP Servers"
description: "Design MCP servers that minimize Claude Code token overhead with lean tool schemas, batch operations, and structured responses -- saving 40-60% per session."
permalink: /building-token-efficient-mcp-servers-claude-code/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Building Token-Efficient MCP Servers for Claude Code

## What It Does

MCP servers extend Claude Code with custom tools, but poorly designed servers waste thousands of tokens on verbose schemas, redundant tool definitions, and unstructured responses. A token-efficient MCP server minimizes definition overhead (~200 tokens per tool instead of ~2,000), returns structured responses that Claude can parse in one read, and batches related operations to reduce round-trips. These design choices save 40-60% on MCP-related token costs -- $4-$10 per month for a developer on Sonnet 4.6.

## Installation / Setup

Initialize a new MCP server project:

```bash
mkdir my-mcp-server && cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk
```

```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node src/index.js"
  }
}
```

## Configuration for Cost Optimization

### Principle 1: Lean Tool Schemas

Every property, description, and enum value in a tool schema costs tokens. Minimize aggressively:

```javascript
// BAD: Verbose schema (~1,500 tokens)
{
  name: "query_database",
  description: "Executes a SQL query against the connected PostgreSQL database. Supports SELECT, INSERT, UPDATE, and DELETE operations. Returns results as JSON array. Automatically parameterizes inputs to prevent SQL injection. Timeouts after 30 seconds.",
  inputSchema: {
    type: "object",
    properties: {
      query: {
        type: "string",
        description: "The SQL query to execute. Must be valid PostgreSQL syntax. Use $1, $2, etc. for parameterized values."
      },
      params: {
        type: "array",
        description: "Array of parameter values corresponding to $1, $2, etc. in the query. Each value will be properly escaped.",
        items: { type: "string" }
      },
      timeout_ms: {
        type: "number",
        description: "Query timeout in milliseconds. Defaults to 30000 (30 seconds). Maximum allowed: 60000.",
        default: 30000
      },
      read_only: {
        type: "boolean",
        description: "If true, only SELECT queries are allowed. Defaults to false.",
        default: false
      }
    },
    required: ["query"]
  }
}
```

```javascript
// GOOD: Lean schema (~200 tokens)
{
  name: "sql",
  description: "Run parameterized SQL. Returns JSON rows.",
  inputSchema: {
    type: "object",
    properties: {
      q: { type: "string" },
      p: { type: "array", items: { type: "string" } }
    },
    required: ["q"]
  }
}
```

The lean version saves ~1,300 tokens per tool definition. With 5 tools in a server, that is 6,500 tokens saved per session.

### Principle 2: Consolidate Related Tools

Instead of separate tools for each operation, use a single tool with an action parameter:

```javascript
// BAD: 4 separate tools (~4,000 tokens in definitions)
// list_tables, describe_table, query, execute

// GOOD: 1 tool with action parameter (~400 tokens)
{
  name: "db",
  description: "Database operations: list, describe, query, execute",
  inputSchema: {
    type: "object",
    properties: {
      action: { type: "string", enum: ["list", "describe", "query", "execute"] },
      target: { type: "string" },
      sql: { type: "string" }
    },
    required: ["action"]
  }
}
```

**Savings: ~3,600 tokens in tool definitions per session**

### Principle 3: Structured, Compact Responses

Design tool responses for machine consumption, not human reading:

```javascript
// BAD: Verbose response (~800 tokens)
{
  content: [{
    type: "text",
    text: `Query Results:\n\nThe query returned 3 rows from the users table.\n\nRow 1:\n  id: abc-123\n  email: user1@example.com\n  name: Alice\n  created_at: 2026-04-01T00:00:00Z\n\nRow 2:\n  id: def-456\n  email: user2@example.com\n  name: Bob\n  created_at: 2026-04-02T00:00:00Z\n\nRow 3:\n  id: ghi-789\n  email: user3@example.com\n  name: Charlie\n  created_at: 2026-04-03T00:00:00Z\n\nTotal rows: 3\nExecution time: 12ms`
  }]
}
```

```javascript
// GOOD: Compact JSON response (~300 tokens)
{
  content: [{
    type: "text",
    text: JSON.stringify({
      rows: [
        { id: "abc-123", email: "user1@example.com", name: "Alice" },
        { id: "def-456", email: "user2@example.com", name: "Bob" },
        { id: "ghi-789", email: "user3@example.com", name: "Charlie" }
      ],
      count: 3
    })
  }]
}
```

**Savings: ~500 tokens per tool response**

## Usage Examples

### Basic Usage: Minimal MCP Server Implementation

```javascript
// src/index.js -- token-efficient MCP server
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "project-tools", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// Single consolidated tool instead of multiple
server.setRequestHandler("tools/list", async () => ({
  tools: [{
    name: "project",
    description: "Project ops: status, deps, config",
    inputSchema: {
      type: "object",
      properties: {
        action: { type: "string", enum: ["status", "deps", "config"] },
        key: { type: "string" }
      },
      required: ["action"]
    }
  }]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { action, key } = request.params.arguments;
  let result;

  switch (action) {
    case "status":
      result = { node: process.version, cwd: process.cwd(), uptime: process.uptime() };
      break;
    case "deps":
      // Bounded: read only top-level dependencies
      const pkg = JSON.parse(await fs.promises.readFile("package.json", "utf-8"));
      result = { deps: Object.keys(pkg.dependencies || {}), count: Object.keys(pkg.dependencies || {}).length };
      break;
    case "config":
      result = { key, value: process.env[key] || "not set" };
      break;
    default:
      result = { error: `Unknown action: ${action}` };
  }

  return { content: [{ type: "text", text: JSON.stringify(result) }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Register in Claude Code:

```bash
claude mcp add project-tools node src/index.js
```

### Advanced: Batch Operations Tool

```javascript
// Support batch operations to reduce round-trips
{
  name: "batch",
  description: "Run multiple operations in one call",
  inputSchema: {
    type: "object",
    properties: {
      ops: {
        type: "array",
        items: {
          type: "object",
          properties: {
            action: { type: "string" },
            target: { type: "string" }
          }
        },
        maxItems: 10  // Bounded: NASA P10 Rule 2
      }
    },
    required: ["ops"]
  }
}
```

One batch call with 5 operations costs ~200 tokens (tool call) + ~500 tokens (response) = 700 tokens. Five separate calls cost 5 x (200 + 300) = 2,500 tokens.

**Savings: 1,800 tokens per batch (72% reduction)**

## Token Usage Measurements

| Design Choice | Verbose Server | Efficient Server | Savings |
|--------------|---------------|-----------------|---------|
| Tool definitions (5 tools) | ~7,500 tokens | ~1,500 tokens | 6,000 |
| Average response (per call) | ~800 tokens | ~300 tokens | 500 |
| 10 calls per session (responses) | ~8,000 tokens | ~3,000 tokens | 5,000 |
| **Total per session** | **~15,500 tokens** | **~4,500 tokens** | **11,000** |

Monthly savings (100 sessions, Sonnet 4.6): **$3.30-$6.60** per developer.

### Principle 4: Lazy Initialization

Only connect to external services when a tool is actually called, not at server startup:

```javascript
// BAD: Connect at startup (slow start, may fail before tools are needed)
import pg from "pg";
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
// Pool connects immediately, adding 500ms-2s startup time
// If no database tool is called this session, the connection was wasted

// GOOD: Lazy connection (fast start, connect only when needed)
let pool = null;

async function getPool() {
  if (!pool) {
    const pg = await import("pg");
    pool = new pg.default.Pool({
      connectionString: process.env.DATABASE_URL,
      max: 5,           // Bounded connections
      idleTimeoutMillis: 30000,  // Clean up after 30s idle
    });
  }
  return pool;
}

// Tool handler uses lazy pool
async function handleQuery(sql, params) {
  const db = await getPool();
  const result = await db.query(sql, params);
  return result.rows;
}
```

Lazy initialization does not directly save tokens, but it eliminates startup failures that cause connection retry loops (which do cost tokens when Claude Code retries the MCP connection).

### Principle 5: Response Size Limits

Always cap response size to prevent context flooding:

```javascript
// BAD: Return all rows from a large table
// If the table has 10,000 rows, the response injects 50,000+ tokens
const result = await pool.query("SELECT * FROM users");
return { content: [{ type: "text", text: JSON.stringify(result.rows) }] };

// GOOD: Cap response size
const MAX_ROWS = 50;
const MAX_RESPONSE_CHARS = 8000; // ~2,000 tokens

const result = await pool.query(`${sql} LIMIT ${MAX_ROWS}`);
let response = JSON.stringify(result.rows);

if (response.length > MAX_RESPONSE_CHARS) {
  response = JSON.stringify({
    rows: result.rows.slice(0, 10),
    total: result.rowCount,
    truncated: true,
    message: `Showing 10 of ${result.rowCount} rows. Add more specific WHERE clauses.`
  });
}

return { content: [{ type: "text", text: response }] };
```

A single uncapped response can inject 50,000 tokens into context -- more than the entire tool definition overhead of 10 servers combined. The response cap is the single most important token-efficiency measure for MCP servers that query databases.

**Savings from response capping: prevents 10,000-50,000 token incidents per uncapped query**

## Comparison with Alternatives

| Approach | Definition Overhead | Response Efficiency | Implementation Effort |
|----------|-------------------|-------------------|---------------------|
| Efficient MCP (this guide) | ~300/tool | Compact JSON | Medium (build server) |
| Standard MCP | ~1,500/tool | Varies | Medium |
| CLI commands (Bash) | 0 | Text (variable) | Low |
| Skills files | 0 | N/A (static) | Low |

### Testing Token Efficiency

Before deploying an MCP server, measure its token overhead:

```bash
#!/bin/bash
# scripts/test-mcp-efficiency.sh
# Compare token overhead of different server configurations
set -uo pipefail

echo "=== MCP Server Token Efficiency Test ==="

# Test 1: Session without MCP server
echo "Test 1: Baseline (no MCP)"
claude --allowedTools "Read,Glob,Grep,Bash" \
  --max-turns 3 \
  -p "Say hello and report token usage" 2>&1 | grep -i "token\|cost" | tail -3

# Test 2: Session with MCP server
echo "Test 2: With MCP server"
claude --max-turns 3 \
  -p "Say hello and report token usage" 2>&1 | grep -i "token\|cost" | tail -3

echo ""
echo "Difference = MCP tool definition overhead"
echo "Target: under 1,000 tokens per server"
```

If the overhead exceeds 1,000 tokens, review tool definitions for opportunities to consolidate or slim down. The ideal MCP server adds under 500 tokens of definition overhead -- roughly equivalent to a medium-sized skill file but with the advantage of runtime capabilities.

### Production Deployment Checklist

Before deploying an MCP server for team use:

```markdown
## MCP Server Deployment Checklist
- [ ] Total tool definitions under 1,000 tokens
- [ ] Each tool description under 20 words
- [ ] Response sizes capped (MAX_ROWS, MAX_RESPONSE_CHARS)
- [ ] Lazy initialization for external connections
- [ ] Timeout handling on all operations (max 5 seconds)
- [ ] Error responses include structured error codes
- [ ] Tested with `scripts/test-mcp-efficiency.sh`
- [ ] Documented in project CLAUDE.md
```

## Troubleshooting

**Claude ignores lean tool names**: Short names like `db` or `sql` work fine. Claude uses the tool list context, not human-readable names. If needed, add a one-line description.

**Batch tool responses are too large**: Add a `limit` parameter to batch operations and enforce it server-side. Cap response size at 4,000 tokens to prevent context flooding.

**Server startup slow**: MCP servers connect via stdio. Startup time does not cost tokens but delays the first tool call. Keep the server lightweight: avoid heavy imports at module level.

**Response compression not working**: If JSON responses are still large after implementing caps, consider returning summaries instead of raw data. A summary like `{ users_count: 14523, recent_signup: "2026-04-22" }` at ~50 tokens replaces a full query result at ~5,000 tokens. This compression technique applies broadly to any MCP tool that returns structured data.

## Related Guides

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- server installation and configuration
- [Reducing Claude Code MCP Round-Trips: Batch Operations Pattern](/reducing-claude-code-mcp-round-trips-batch-pattern/) -- batch pattern in depth
- [Claude Code MCP Server Token Usage: How to Measure and Reduce](/claude-code-mcp-server-token-usage-measure-reduce/) -- measurement techniques

- [claude mcp list command guide](/claude-mcp-list-command-guide/) — How to use the claude mcp list command to manage MCP servers

- [Claude Code MCP configuration guide](/claude-code-mcp-configuration-guide/) — Complete guide to configuring MCP servers in Claude Code
