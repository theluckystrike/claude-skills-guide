---
layout: default
title: "Claude Code MCP tools loading slowly (2026)"
description: "Slow MCP tool loading adds 500-2,000 tokens of overhead per server to every Claude Code session. Diagnose latency and reduce token impact with these fixes."
permalink: /claude-code-mcp-tools-loading-slowly-token-cost/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code MCP tools loading slowly -- token cost impact

## The Problem

MCP servers that take 5-30 seconds to initialize still load their full tool definitions into the Claude Code context window, costing 500-2,000 tokens per tool regardless of startup speed. Slow servers compound the problem: if initialization times out or errors occur, Claude Code may retry the connection, multiplying the overhead. A session with 3 slow MCP servers can waste 3,000-12,000 tokens in tool definitions for tools that may not function reliably, costing $0.01-$0.07 per session on Sonnet 4.6 ($3/$15 per MTok).

## Quick Fix (2 Minutes)

1. **Remove unused MCP servers**: `claude mcp remove <server-name>` for any server not used in the past week. See the [claude mcp list command guide](/claude-mcp-list-command-guide/) for details.
2. **Check server health**: review your [Claude Code MCP configuration](/claude-code-mcp-configuration-guide/) for misconfigured servers.
3. **Use `--allowedTools` to bypass slow servers**:
   ```bash
   claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash" -p "your prompt"
   ```
   This loads zero MCP tools, eliminating all MCP overhead for sessions that do not need them.

## Why This Happens

MCP servers connect to Claude Code via stdio (standard input/output). The connection lifecycle:

1. **Spawn process**: Claude Code starts the server process (e.g., `npx -y @modelcontextprotocol/server-postgres ...`)
2. **Initialize**: Server sends capabilities and tool list via JSON-RPC
3. **Load tool definitions**: Claude Code adds tool schemas to the context window

Slow loading occurs at steps 1-2:
- **`npx` cold start**: First-time `npx` invocations download and install the package. This can take 5-30 seconds.
- **Heavy dependencies**: Servers importing large libraries (Prisma, database drivers, API clients) at startup.
- **Network dependencies**: Servers that connect to external services (databases, APIs) during initialization.
- **Multiple servers**: Each server starts sequentially, compounding delays.

The token cost problem is at step 3: regardless of how long initialization takes, the tool definitions occupy context window space for the entire session. A server with 8 tools adds ~8,000 tokens of overhead even if the tools are never called.

## The Full Fix

### Step 1: Diagnose

Identify which servers are slow and how many tools they expose:

```bash
# List configured servers and tool counts
claude mcp list

# Time each server's startup (approximate)
time npx -y @modelcontextprotocol/server-postgres "postgresql://localhost/test" < /dev/null 2>&1 | head -5
# If this takes >5 seconds, the server has a slow startup

# Check for npx cache misses
ls ~/.npm/_npx/ 2>/dev/null | wc -l
# If empty or missing, npx will download on every invocation
```

### Step 2: Fix

**Fix 1: Pre-install MCP servers** to eliminate `npx` download latency:

```bash
# Instead of: npx -y @modelcontextprotocol/server-postgres
# Install globally:
npm install -g @modelcontextprotocol/server-postgres

# Update .claude/settings.json to use the global install:
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "args": ["postgresql://localhost/mydb"]
    }
  }
}
```

**Fix 2: Replace heavy MCP servers with CLI commands** for infrequent operations:

```bash
# Instead of a GitHub MCP server (8 tools, ~8,000 tokens overhead):
# Use gh CLI directly:
gh issue list --state open --limit 10
gh pr create --title "Fix: auth timeout" --body "..."

# Savings: ~8,000 tokens per session + eliminated startup latency
```

**Fix 3: Use lightweight server implementations**:

```javascript
// Minimal MCP server that starts in <100ms
// Instead of a full framework, use raw stdio JSON-RPC
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "fast-db", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// Single lean tool instead of 8 verbose ones
server.setRequestHandler("tools/list", async () => ({
  tools: [{
    name: "sql",
    description: "Run SQL query",
    inputSchema: {
      type: "object",
      properties: { q: { type: "string" } },
      required: ["q"]
    }
  }]
}));

// Lazy database connection (only connect when tool is called)
let pool = null;
server.setRequestHandler("tools/call", async (req) => {
  if (!pool) {
    const pg = await import("pg");
    pool = new pg.default.Pool({ connectionString: process.env.DATABASE_URL });
  }
  const result = await pool.query(req.params.arguments.q);
  return { content: [{ type: "text", text: JSON.stringify(result.rows) }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

This server: starts in <100ms (lazy DB connection), exposes 1 tool (~200 tokens overhead), versus a standard postgres server with 4-8 tools (~2,000-8,000 tokens overhead).

### Step 3: Prevent

Add startup performance monitoring:

```bash
#!/bin/bash
# scripts/check-mcp-performance.sh
set -uo pipefail

echo "=== MCP Server Startup Times ==="

SERVERS=("mcp-server-postgres" "mcp-server-github" "mcp-server-filesystem")
MAX_STARTUP_MS=3000

for server in "${SERVERS[@]}"; do
  if command -v "$server" > /dev/null 2>&1; then
    START=$(date +%s%N)
    timeout 10 "$server" --version > /dev/null 2>&1 || true
    END=$(date +%s%N)
    DURATION_MS=$(( (END - START) / 1000000 ))

    if [ "$DURATION_MS" -gt "$MAX_STARTUP_MS" ]; then
      echo "SLOW: $server (${DURATION_MS}ms) -- consider replacing with CLI"
    else
      echo "OK: $server (${DURATION_MS}ms)"
    fi
  else
    echo "MISSING: $server (not installed globally)"
  fi
done
```

### Measuring Before and After

Track the impact of MCP optimizations on session startup and token usage:

```bash
#!/bin/bash
# scripts/measure-mcp-impact.sh
# Compare session costs with and without MCP servers
set -uo pipefail

echo "=== MCP Impact Measurement ==="

# Session without MCP (baseline)
echo "Test 1: No MCP (baseline)"
time claude --allowedTools "Read,Glob,Grep,Edit,Bash" \
  --max-turns 3 \
  -p "List the files in src/ and report the count" 2>&1 | tail -3

echo ""

# Session with MCP (current config)
echo "Test 2: With MCP (current config)"
time claude --max-turns 3 \
  -p "List the files in src/ and report the count" 2>&1 | tail -3

echo ""
echo "Compare the token counts above to quantify MCP overhead."
echo "Difference = MCP tool definition overhead."
```

Run this comparison monthly to verify that MCP overhead stays within the token budget. If the difference grows (from adding new servers or tools), it is time to audit and prune.

## Cost Recovery

Slow MCP servers do not cause direct financial damage beyond normal tool definition overhead. Recovery focuses on preventing ongoing waste:

- Remove servers not actively used: saves 500-8,000 tokens per server per session
- Pre-install to eliminate download latency: saves 5-30 seconds per server (not tokens, but productivity)
- Replace multi-tool servers with single-tool lean implementations: saves 1,000-6,000 tokens per server

### The True Cost of MCP Server Collection Bloat

Many developers accumulate MCP servers over time: adding one for a database, another for GitHub, another for a cloud provider, another for a documentation tool. Each adds 500-2,000 tokens of overhead. After 6 months, the accumulated overhead can reach 10,000-20,000 tokens per session -- pure waste from tools that are rarely used.

Quarterly MCP audits prevent this bloat:

```bash
# Quarterly MCP audit checklist
# 1. List all configured servers: claude mcp list
# 2. Review usage logs: which tools were called in the past 30 days?
# 3. Remove servers with zero calls in 30 days
# 4. Replace low-usage servers with CLI alternatives
# 5. Optimize remaining servers (slim definitions, fewer tools)
```

The audit takes 15 minutes and typically removes 2-3 unused servers, saving 2,000-6,000 tokens per session. Over a quarter, that is 200K-600K tokens saved ($0.60-$1.80 at Sonnet 4.6 rates).

## Prevention Rules for CLAUDE.md

```markdown
## MCP Server Rules
- Maximum 2 MCP servers configured at any time
- Each server must expose 3 or fewer tools
- Servers must start in under 3 seconds
- Use `--allowedTools` to skip MCP loading on sessions that do not need external tools
- Review MCP configuration monthly: remove unused servers
```



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code MCP Server Token Usage: How to Measure and Reduce](/claude-code-mcp-server-token-usage-measure-reduce/) -- measure and reduce overhead
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- proper MCP configuration
- [Errors Atlas](/errors-atlas/) -- troubleshoot MCP connection errors


