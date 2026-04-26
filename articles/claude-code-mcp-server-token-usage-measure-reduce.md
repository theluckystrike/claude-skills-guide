---
layout: default
title: "Claude Code MCP Server Token Usage (2026)"
description: "MCP servers add 500-2,000 tokens per tool definition to every Claude Code session. Measure your overhead and apply these techniques to cut it by 50-70%."
permalink: /claude-code-mcp-server-token-usage-measure-reduce/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code MCP Server Token Usage: How to Measure and Reduce

## What It Does

MCP (Model Context Protocol) servers extend Claude Code with custom tools, but each tool definition persists in the context window for the entire session. A typical MCP server with 5-10 tools adds 2,500-20,000 tokens of overhead to every session, regardless of whether those tools are used. Measuring this overhead reveals which servers are worth their cost and which should be replaced with lighter alternatives. Reduction techniques cut MCP overhead by 50-70%, saving $3-$12 per month on Sonnet 4.6.

## Installation / Setup

Start by inventorying current MCP servers:

```bash
# List all configured MCP servers
claude mcp list

# Example output:
# postgres    - 4 tools
# github      - 8 tools
# filesystem  - 6 tools
# Total: 18 tools
```

## Configuration for Cost Optimization

### Step 1: Measure Tool Definition Overhead

Each MCP tool definition costs tokens based on its complexity. Measure with this estimation method:

```bash
#!/bin/bash
# scripts/measure-mcp-overhead.sh
# Estimates token overhead from MCP tool definitions
set -uo pipefail

echo "=== MCP Tool Definition Token Estimates ==="
echo ""

# Common tool definition sizes (tokens per tool)
# Simple tool (1-2 params, short description): ~500 tokens
# Medium tool (3-5 params, detailed description): ~1,000 tokens
# Complex tool (6+ params, enums, nested schemas): ~2,000 tokens

# Based on your claude mcp list output, estimate:
SERVERS=(
  "postgres:4:medium"      # 4 tools, medium complexity
  "github:8:complex"       # 8 tools, complex definitions
  "filesystem:6:simple"    # 6 tools, simple definitions
)

TOTAL_OVERHEAD=0
for server_info in "${SERVERS[@]}"; do
  IFS=':' read -r name count complexity <<< "$server_info"

  case $complexity in
    simple)  PER_TOOL=500 ;;
    medium)  PER_TOOL=1000 ;;
    complex) PER_TOOL=2000 ;;
    *)       PER_TOOL=1000 ;;
  esac

  OVERHEAD=$((count * PER_TOOL))
  TOTAL_OVERHEAD=$((TOTAL_OVERHEAD + OVERHEAD))
  MONTHLY_COST=$(echo "scale=2; $OVERHEAD * 100 * 3 / 1000000" | bc)

  echo "$name: $count tools x ~$PER_TOOL tokens = ~$OVERHEAD tokens (\$${MONTHLY_COST}/mo at 100 sessions)"
done

TOTAL_MONTHLY=$(echo "scale=2; $TOTAL_OVERHEAD * 100 * 3 / 1000000" | bc)
echo ""
echo "Total MCP overhead: ~$TOTAL_OVERHEAD tokens/session"
echo "Monthly cost (100 sessions, Sonnet 4.6 input only): \$${TOTAL_MONTHLY}"
```

### Step 2: Identify Low-Usage Tools

Track which MCP tools actually get called using a monitoring hook:

```bash
#!/bin/bash
# .claude/hooks/track-mcp-usage.sh
set -uo pipefail

TOOL_NAME="${1:-unknown}"
LOG_FILE="${HOME}/.claude/mcp-usage-log.jsonl"

# Only log MCP tool calls (they have mcp__ prefix)
if echo "$TOOL_NAME" | grep -q "^mcp__"; then
  printf '{"ts":"%s","tool":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$TOOL_NAME" \
    >> "$LOG_FILE"
fi
```

After a week of usage, analyze:

```bash
# Find most and least used MCP tools
sort "$HOME/.claude/mcp-usage-log.jsonl" | \
  grep -o '"tool":"[^"]*"' | \
  sort | uniq -c | sort -rn | head -20
```

Tools with zero or single-digit calls per week are candidates for removal.

### Step 3: Reduce Tool Count per Server

Configure MCP servers to expose only essential tools. Many servers support tool filtering:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  }
}
```

If the server exposes 8 tools but only `create_issue` and `list_issues` are used, consider replacing the full server with targeted Bash commands:

```bash
# Instead of MCP github server (8 tools, ~16,000 tokens overhead):
# Use gh CLI directly (0 tool definition overhead)
gh issue create --title "Bug: login timeout" --body "Details..."
gh issue list --state open --limit 10
```

**Savings: ~16,000 tokens per session by removing the GitHub MCP server**

## Usage Examples

### Basic Usage

After measuring and identifying low-usage tools, remove unnecessary servers:

```bash
# Remove MCP servers that are cheaper as CLI commands
claude mcp remove github
claude mcp remove filesystem
```

Verify the reduction:

```bash
claude mcp list
# Now showing only: postgres - 4 tools
# Overhead reduced from ~22,000 to ~4,000 tokens
```

### Advanced: Session-Specific MCP Loading

Use `--allowedTools` to control which MCP tools load per session:

```bash
# Database-focused session: only load postgres MCP
claude --allowedTools "Read,Glob,Grep,Edit,Bash,mcp__postgres__query,mcp__postgres__list_tables" \
  -p "Write a query to find users with expired subscriptions"

# This loads only 2 of 4 postgres tools: ~2,000 tokens instead of ~4,000
```

```bash
# No MCP session (pure CLI):
claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash" \
  -p "Refactor the user service to use dependency injection"

# Zero MCP overhead: saves the full ~4,000 tokens
```

## Token Usage Measurements

| Configuration | Tool Definitions | Per-Session Overhead | Monthly Cost (100 sessions) |
|--------------|-----------------|---------------------|---------------------------|
| 3 MCP servers (18 tools) | 18 | ~18,000 tokens | $5.40 |
| 1 MCP server (4 tools) | 4 | ~4,000 tokens | $1.20 |
| Filtered (2 tools only) | 2 | ~2,000 tokens | $0.60 |
| No MCP (CLI only) | 0 | 0 tokens | $0.00 |

**Reduction from 3 servers to filtered 1 server: $4.80/month savings per developer.**

### Step 4: Implement Token Budget Monitoring for MCP

Create a periodic check that compares MCP overhead against total session cost:

```bash
#!/bin/bash
# scripts/mcp-token-budget.sh
# Compare MCP overhead against session budgets
set -uo pipefail

echo "=== MCP Token Budget Analysis ==="

# Estimated MCP overhead per session
MCP_OVERHEAD=4000  # Adjust based on your actual configuration

# Average session tokens (from ccusage data)
AVG_SESSION_TOKENS=60000

OVERHEAD_PERCENT=$((MCP_OVERHEAD * 100 / AVG_SESSION_TOKENS))

echo "MCP overhead per session: ~$MCP_OVERHEAD tokens"
echo "Average session size: ~$AVG_SESSION_TOKENS tokens"
echo "MCP overhead ratio: ${OVERHEAD_PERCENT}%"
echo ""

if [ "$OVERHEAD_PERCENT" -gt 20 ]; then
  echo "WARNING: MCP overhead exceeds 20% of average session."
  echo "Consider removing low-usage MCP tools or switching to CLI alternatives."
elif [ "$OVERHEAD_PERCENT" -gt 10 ]; then
  echo "NOTE: MCP overhead is ${OVERHEAD_PERCENT}% of sessions. Acceptable but review quarterly."
else
  echo "OK: MCP overhead is well-controlled at ${OVERHEAD_PERCENT}%."
fi
```

A healthy MCP configuration contributes less than 10% of total session token cost. If it exceeds 20%, the overhead is eating into productive token budget and needs reduction.

## Comparison with Alternatives

| Tool Access Method | Definition Overhead | Per-Call Cost | Best For |
|-------------------|-------------------|---------------|----------|
| MCP server | 500-2,000/tool | ~200 tokens | 10+ calls/session, complex ops |
| Bash CLI | 0 | ~245 tokens | Simple commands, infrequent use |
| Skills (static) | 0 | 200-500 tokens (file read) | Knowledge, conventions, procedures |
| Built-in tools | 0 (pre-loaded) | 150-245 tokens | File ops, search, edit |

### Step 5: Right-Size Your MCP Configuration

Based on measurement data, create an optimal MCP configuration:

```json
{
  "mcpServers": {
    "db": {
      "command": "node",
      "args": [".claude/mcp/lean-db-server.js"],
      "env": { "DATABASE_URL": "postgresql://localhost/myapp" }
    }
  }
}
```

Where the lean server exposes only the tools that clear the 9-call-per-week threshold:

```javascript
// .claude/mcp/lean-db-server.js
// Only 2 tools instead of the default 4-8
// Total definition overhead: ~400 tokens instead of ~4,000
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "sql",
      description: "Run SQL query, returns JSON rows",
      inputSchema: {
        type: "object",
        properties: { q: { type: "string" } },
        required: ["q"]
      }
    },
    {
      name: "tables",
      description: "List all tables with row counts",
      inputSchema: { type: "object", properties: {} }
    }
  ]
}));
```

Two tools at ~200 tokens each = 400 tokens. Compare to a standard PostgreSQL MCP server with 6 tools at ~1,000 tokens each = 6,000 tokens. The lean server saves 5,600 tokens per session.

**Monthly savings from right-sizing: 5,600 tokens x 100 sessions x $0.006/1K = $3.36**

### Step 6: Automate MCP Overhead Reporting

Create a weekly report that tracks MCP token overhead trends:

```bash
#!/bin/bash
# scripts/mcp-weekly-report.sh
# Generates a weekly MCP overhead report
set -uo pipefail

MCP_LOG="${HOME}/.claude/mcp-usage-log.jsonl"
REPORT_FILE="${HOME}/Desktop/mcp-report-$(date +%Y-%m-%d).txt"

echo "=== MCP Weekly Report ($(date +%Y-%m-%d)) ===" > "$REPORT_FILE"

if [ ! -f "$MCP_LOG" ]; then
  echo "No MCP usage log found." >> "$REPORT_FILE"
  exit 0
fi

# Last 7 days of MCP calls
WEEK_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d)

echo "" >> "$REPORT_FILE"
echo "Tool call frequency (last 7 days):" >> "$REPORT_FILE"
grep "$WEEK_AGO\|$(date +%Y-%m-%d)" "$MCP_LOG" | \
  grep -o '"tool":"[^"]*"' | sort | uniq -c | sort -rn >> "$REPORT_FILE"

TOTAL_CALLS=$(grep "$WEEK_AGO\|$(date +%Y-%m-%d)" "$MCP_LOG" | wc -l | tr -d ' ')
EST_OVERHEAD=$((TOTAL_CALLS * 500))
EST_COST=$(echo "scale=2; $EST_OVERHEAD * 3 / 1000000" | bc)

echo "" >> "$REPORT_FILE"
echo "Total MCP calls this week: $TOTAL_CALLS" >> "$REPORT_FILE"
echo "Estimated overhead: ~$EST_OVERHEAD tokens" >> "$REPORT_FILE"
echo "Estimated cost: \$$EST_COST (Sonnet 4.6 input only)" >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
cat "$REPORT_FILE"
```

The weekly report surfaces trends: if MCP overhead is growing (more tools being added or called more frequently), it signals time for an optimization pass. If overhead is stable or declining, the current configuration is well-tuned.

## Troubleshooting

**Cannot determine which tools an MCP server exposes**: Start Claude Code with the server configured and ask "What MCP tools are available?" Claude will list all loaded tools with their names and descriptions.

**Removing an MCP server breaks workflows**: Before removing, verify all functionality can be replicated with CLI commands or built-in tools. Create a migration plan: document each MCP tool call and its CLI equivalent.

**Tool filtering not supported by server**: Fork the server and remove unwanted tool handlers, or wrap it with a proxy that filters the tool list response.

**MCP server startup is slow**: Some servers take 2-5 seconds to initialize, adding latency to every session. If the server is only used in 20% of sessions, consider loading it on-demand through a wrapper script rather than configuring it globally. The startup latency wastes both time and tokens (the model waits for tool definitions before proceeding).

**Token costs increased after adding a new MCP server**: Compare `ccusage` data from before and after the server was added. Calculate the per-session overhead increase. If the new server adds 5,000+ tokens per session but is called fewer than 5 times per week, the overhead is not justified. Remove the server and use CLI commands or skills as alternatives.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- MCP configuration reference
- [Building Token-Efficient MCP Servers for Claude Code](/building-token-efficient-mcp-servers-claude-code/) -- design servers with minimal overhead
- [CLI vs MCP for Agent Operations: Token Cost Comparison](/cli-vs-mcp-agent-operations-token-cost/) -- when to choose CLI over MCP

## See Also

- [MCP Server stdio Timeout 30000ms — Fix (2026)](/claude-code-mcp-server-stdio-timeout-fix-2026/)
- [Claude Code Skills vs MCP Servers: Which Uses Fewer Tokens?](/claude-code-skills-vs-mcp-servers-token-usage/)
- [Claude Code MCP tools loading slowly — token cost impact](/claude-code-mcp-tools-loading-slowly-token-cost/)
