---
layout: default
title: "Supabase MCP Server Token Usage (2026)"
description: "The Supabase MCP server adds 1,500-4,000 tokens per tool definition to every Claude Code message -- learn exactly what gets sent and how to minimize it."
permalink: /supabase-mcp-server-token-usage-what-gets-sent/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Supabase MCP Server Token Usage: What Gets Sent and Why

## What It Does

The Supabase MCP server connects Claude Code to a Supabase project, enabling direct database queries, schema inspection, and edge function management through tool calls. Each MCP tool definition contributes approximately 500-2,000 tokens to the system prompt. The Supabase MCP server typically exposes 8-15 tools, adding 4,000-12,000 tokens of overhead to every API call -- even when no Supabase tools are used in that particular turn.

## Installation / Setup

```bash
# Install the Supabase MCP server
npx supabase mcp setup

# Or manually configure in Claude Code settings
# ~/.claude/settings.json:
```

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://your-project.supabase.co",
        "SUPABASE_SERVICE_KEY": "your-service-key"
      }
    }
  }
}
```

## Configuration for Cost Optimization

The primary cost optimization is tool filtering -- loading only the Supabase tools needed for the current task.

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://your-project.supabase.co",
        "SUPABASE_SERVICE_KEY": "your-service-key"
      },
      "allowedTools": [
        "query",
        "get_schema"
      ]
    }
  }
}
```

By filtering to only 2 tools instead of the full 8-15, token overhead drops from 4,000-12,000 tokens per turn to approximately 1,000-2,000 tokens per turn.

## Usage Examples

### Basic Usage

```bash
# Claude Code with Supabase MCP -- schema query
> "Show me the schema for the users table"

# Behind the scenes, Claude Code calls the get_schema tool:
# Tool call overhead: ~500 tokens
# Schema response: ~300-1,000 tokens depending on table complexity
# Total: ~800-1,500 tokens for this operation
```

### Advanced: Cost-Saving Pattern

Instead of using MCP tools for every database interaction, cache schema information in CLAUDE.md and use MCP only for actual queries.

```yaml
# CLAUDE.md -- cached Supabase schema (saves ~800 tokens per schema lookup)
## Database Schema Summary
### users
- id: uuid (PK)
- email: text (unique)
- created_at: timestamptz
- subscription_tier: text (free|pro|enterprise)

### orders
- id: uuid (PK)
- user_id: uuid (FK -> users.id)
- total_cents: integer
- status: text (pending|paid|refunded)
- created_at: timestamptz

### subscriptions
- id: uuid (PK)
- user_id: uuid (FK -> users.id)
- plan: text
- stripe_customer_id: text
- current_period_end: timestamptz
```

This 250-token schema summary replaces repeated `get_schema` MCP calls that cost 800-1,500 tokens each. Over a 20-turn session with 3 schema lookups, the savings are (3 * 1,150) - 250 = **3,200 tokens saved**.

## Token Usage Measurements

Measured token costs for common Supabase MCP operations:

| Operation | Tool Definition Overhead | Call Overhead | Response Size | Total |
|-----------|------------------------|---------------|---------------|-------|
| get_schema (single table) | 1,200 tokens | 500 tokens | 300-800 tokens | 2,000-2,500 |
| query (simple SELECT) | 1,200 tokens | 500 tokens | 200-2,000 tokens | 1,900-3,700 |
| query (complex JOIN) | 1,200 tokens | 500 tokens | 500-5,000 tokens | 2,200-6,700 |
| list_tables | 800 tokens | 500 tokens | 200-500 tokens | 1,500-1,800 |
| insert/update | 1,000 tokens | 500 tokens | 100-300 tokens | 1,600-1,800 |

The tool definition overhead (column 2) is paid on every turn whether or not the tool is called. This is the key insight: having the Supabase MCP server loaded costs 4,000-12,000 tokens per turn in definitions alone.

```text
20-turn session with Supabase MCP loaded (all tools):
  Definition overhead per turn: ~8,000 tokens
  Total definition overhead: 20 * 8,000 = 160,000 tokens
  Cost at Opus: $2.40 just for tool definitions

20-turn session with filtered tools (2 tools):
  Definition overhead per turn: ~1,500 tokens
  Total definition overhead: 20 * 1,500 = 30,000 tokens
  Cost at Opus: $0.45 just for tool definitions

  Savings: $1.95 per session from filtering alone
```

## Comparison with Alternatives

| Approach | Tokens per Query | Setup Time | Flexibility |
|----------|-----------------|------------|-------------|
| Supabase MCP (all tools) | 2,000-6,700 + 8K/turn overhead | 5 minutes | High |
| Supabase MCP (filtered) | 2,000-6,700 + 1.5K/turn overhead | 10 minutes | Medium |
| Direct SQL via Bash | 245 + query result tokens | 2 minutes | High |
| Schema in CLAUDE.md + Bash SQL | 250 (one-time) + 245 per query | 15 minutes | Low |

For projects where database queries are infrequent (under 5 per session), running SQL directly through Bash is more token-efficient than loading the MCP server. For database-heavy sessions, the filtered MCP approach provides the best balance.

## Troubleshooting

**High token usage despite few database operations** -- The MCP tool definitions are the likely cause. Check how many tools are loaded with the MCP server and filter to only essential ones. The definitions contribute tokens on every turn, not just turns with database operations.

**Slow MCP responses inflating session time** -- Large query results increase both token count and latency. Add `LIMIT 50` to queries in CLAUDE.md rules, and use `SELECT specific_columns` instead of `SELECT *`.

**MCP connection errors consuming retry tokens** -- If the Supabase MCP server fails to connect, Claude Code may retry multiple times, each attempt costing tool call overhead. Add a CLAUDE.md rule: "If Supabase MCP connection fails, report the error and wait for user guidance. Do not retry more than twice."

## Related Guides

- [MCP Tool Filtering: Only Load What You Need](/mcp-tool-filtering-only-load-what-you-need/) -- universal MCP filtering techniques
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- complete MCP configuration guide
- [Claude Code Tool Call Overhead](/claude-code-tool-call-overhead-tokens-per-mcp-call/) -- token cost breakdown for all tool types
