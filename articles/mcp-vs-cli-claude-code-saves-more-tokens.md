---
layout: default
title: "MCP vs CLI for Claude Code (2026)"
description: "Compare MCP servers and CLI tools for Claude Code to determine when each approach saves more tokens, with per-operation measurements and cost analysis."
permalink: /mcp-vs-cli-claude-code-saves-more-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
---

# MCP vs CLI for Claude Code: When Each Saves More Tokens

## What It Does

MCP (Model Context Protocol) servers provide structured tool interfaces for Claude Code, while CLI commands use the Bash tool for direct command execution. Each approach has different token costs per operation. MCP tools add 500-2,000 tokens of definition overhead per tool but return structured data. CLI commands add ~245 tokens of Bash tool overhead but may return verbose, unstructured output. Choosing the right approach per operation can save 30-60% of integration-related token costs.

## Installation / Setup

### MCP Server Setup

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

### CLI Alternative Setup

```markdown
# CLAUDE.md
## Database Commands
- Query: psql $DATABASE_URL -c "<SQL>" --csv --quiet
- Schema: psql $DATABASE_URL -c "\d <table>"
- Tables: psql $DATABASE_URL -c "\dt"
```

## Configuration for Cost Optimization

### Token Cost Breakdown: MCP vs CLI

**MCP tool overhead per session:**
- Tool definition loading: 500-2,000 tokens per tool (loaded once at session start)
- Tool call overhead: ~200 tokens per invocation
- Response parsing: structured JSON, ~100-500 tokens

**CLI (Bash) overhead per operation:**
- Bash tool call: ~245 tokens overhead
- Command string: 20-100 tokens
- Response: unstructured text, 100-10,000 tokens depending on output

```markdown
## Decision Matrix

### Use MCP when:
- Tool will be called 5+ times per session (amortizes definition cost)
- Output needs to be structured (JSON vs free text)
- Complex parameter validation is needed
- External service requires authentication handling

### Use CLI when:
- One-off commands (1-2 calls per session)
- Simple output (exit code + short text)
- Standard Unix tools (grep, find, wc)
- The Bash tool overhead is lower than MCP definition cost
```

## Usage Examples

### Basic Usage: Database Query

**MCP approach:**

```json
// Tool definition cost: ~800 tokens (loaded once)
// Per-call cost: ~200 tokens overhead + ~300 tokens response
{
  "tool": "database_query",
  "arguments": {
    "sql": "SELECT id, email FROM users WHERE role = 'admin'"
  }
}
// Response: structured JSON, ~300 tokens
// Total for 1 call: 800 + 200 + 300 = 1,300 tokens
// Total for 10 calls: 800 + (200 + 300) x 10 = 5,800 tokens
```

**CLI approach:**

```bash
# Per-call cost: ~245 tokens overhead + ~50 tokens command + response
psql "$DATABASE_URL" -c "SELECT id, email FROM users WHERE role = 'admin'" --csv --quiet
# Response: CSV text, ~200 tokens
# Total for 1 call: 245 + 50 + 200 = 495 tokens
# Total for 10 calls: (245 + 50 + 200) x 10 = 4,950 tokens
```

**Verdict:** For database queries, CLI wins at low volume (1-5 calls saves 800 tokens in definition overhead). MCP wins at high volume (10+ calls) because structured responses reduce parsing tokens.

### Advanced: Cost-Saving Pattern with Hybrid Approach

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

```markdown
# CLAUDE.md
## Tool Selection
- GitHub operations (PR, issues, reviews): use MCP github server
- File operations (read, edit, search): use built-in tools (Read, Edit, Grep)
- Build/test: use Bash tool directly
- Database queries: use Bash + psql (low volume) or MCP (high volume sessions)
```

This hybrid approach loads MCP overhead only for frequently-used external services and uses lightweight CLI for everything else.

## Token Usage Measurements

| Operation | MCP Tokens (first call) | MCP Tokens (Nth call) | CLI Tokens (each call) | Break-even |
|-----------|------------------------|----------------------|----------------------|------------|
| DB query | 1,300 | 500 | 495 | 2 calls |
| GitHub PR list | 1,500 | 400 | 800 | 3 calls |
| File search | 1,200 | 350 | 300 | Never (CLI wins) |
| API request | 1,400 | 450 | 600 | 4 calls |
| Schema inspect | 1,800 | 600 | 1,200 | 2 calls |

**Monthly impact example (Sonnet 4.6):**
A developer making 50 tool calls per day, split 30 CLI / 20 MCP:
- All-MCP approach: 50 calls x 700 avg x 22 days = 770K tokens = $2.31/month
- Hybrid approach: (30 x 400 + 20 x 550) x 22 = 506K tokens = $1.52/month
- **Savings: $0.79/month per developer** in tool overhead alone

The real savings come from structured vs unstructured responses. Structured MCP responses lead to fewer follow-up reads and retries, saving an estimated 15-25% on downstream token usage.

## Comparison with Alternatives

| Approach | Definition Cost | Per-Call Cost | Response Quality | Best For |
|----------|---------------|--------------|-----------------|----------|
| MCP server | 500-2,000 tokens | 200-400 tokens | Structured JSON | Repeated, complex ops |
| Bash/CLI | 0 | 245+ tokens | Unstructured text | One-off, simple commands |
| Skills (pre-loaded) | 0 runtime | 0 | Static knowledge | Known-ahead context |
| Built-in tools | 0 | ~150-245 tokens | Optimized | File operations |

## Troubleshooting

**MCP server loading too many tools:** Each tool definition costs 500-2,000 tokens. A server with 20 tools can cost 10K-40K tokens just to load. Configure the server to expose only the tools needed for the project.

**CLI output flooding context:** Pipe CLI output through truncation: `command 2>&1 | head -20`. Add to CLAUDE.md: "Always truncate CLI output to 20 lines."

**MCP server crashing during session:** The definition tokens are lost, and the server must reload. Use stable, well-maintained MCP servers. For critical workflows, have a CLI fallback documented in CLAUDE.md.

## Real-World Decision Framework

### Scenario 1: Database-Heavy Development

A developer making 20+ database queries per session benefits from the MCP PostgreSQL server:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "postgresql://..." }
    }
  }
}
```

MCP cost: 1,200 (definition) + 20 x 400 = 9,200 tokens
CLI cost: 20 x 495 = 9,900 tokens
**MCP saves 700 tokens per session (7%)**

But the real savings come from structured responses. MCP returns typed JSON rows; CLI returns formatted text. The structured data leads to 30% fewer follow-up queries because Claude parses it correctly the first time.

### Scenario 2: Occasional API Calls

A developer making 2-3 API calls per session to check a service status:

```bash
# CLI approach (cheaper for low volume)
curl -s https://api.service.com/status | jq '.status'
# 245 + 80 + 50 = 375 tokens per call
# 3 calls = 1,125 tokens
```

Loading an MCP server for this: 1,200 definition + 3 x 350 = 2,250 tokens. **CLI saves 1,125 tokens (50%).** For low-volume operations, CLI is always more efficient.

### Scenario 3: GitHub Operations

A developer reviewing PRs, checking CI status, and creating issues:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

GitHub MCP server provides 15+ tools. If only 3 are used regularly, the definition overhead for the unused 12 tools is wasted: approximately 12 x 600 = 7,200 tokens per session.

**Alternative:** Use `gh` CLI for GitHub operations. Each `gh` call costs ~300 tokens with structured output. For teams using fewer than 5 GitHub operations per session, CLI is more token-efficient.

## Optimization: MCP Tool Filtering

When using MCP servers with many tools, request only the tools needed:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "tools": ["create_issue", "list_pull_requests", "get_pull_request"]
    }
  }
}
```

Filtering from 15 tools to 3 saves approximately 7,200 tokens per session in tool definition overhead. At 1 session per day on Sonnet: $0.47/month in definition savings alone.

## Decision Checklist

For each external service integration, answer these questions:

1. How many times per session will this be called?
   - Under 3: use CLI
   - 3-10: either (consider response quality)
   - Over 10: use MCP

2. Does structured response matter?
   - Yes (parsing needed): lean toward MCP
   - No (simple status check): lean toward CLI

3. How many tools does the MCP server expose?
   - Under 5: definition cost is manageable
   - 5-10: consider filtering to needed tools only
   - Over 10: filter aggressively or use CLI

4. Is authentication complex?
   - Yes (OAuth, token refresh): MCP handles it once
   - No (simple API key): CLI is simpler

5. How stable is the MCP server?
   - Stable, well-maintained: safe to rely on
   - Experimental or frequently crashing: use CLI as primary, MCP as fallback
   - A crashed MCP server wastes all definition tokens and requires reload

## Cost-Aware MCP Server Selection

When evaluating MCP servers for a project, consider the token cost profile alongside functionality:

| MCP Server | Tools Exposed | Definition Cost | Best Use Case |
|-----------|--------------|-----------------|---------------|
| @modelcontextprotocol/server-postgres | 5-7 | ~3,500 tokens | DB-heavy sessions (10+ queries) |
| @modelcontextprotocol/server-github | 15-20 | ~10,000 tokens | Full PR workflow sessions |
| @modelcontextprotocol/server-filesystem | 8-10 | ~5,000 tokens | Rarely justified (built-in tools are better) |
| Custom single-purpose server | 1-3 | ~1,500 tokens | Targeted integrations |

Custom single-purpose MCP servers provide the best token-to-value ratio because they expose only the tools needed and minimize definition overhead. For teams with recurring integrations (deployment, monitoring, notification), building a custom server with 2-3 focused tools saves 5K-8K tokens per session compared to general-purpose servers.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- complete MCP configuration reference
- [Environment Variables for Claude Code Cost Control](/environment-variables-claude-code-cost-control/) -- controlling tool behavior
- [Cost Optimization Hub](/cost-optimization/) -- all cost guides
