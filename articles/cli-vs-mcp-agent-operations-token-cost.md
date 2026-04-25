---
layout: default
title: "CLI vs MCP for Agent Operations (2026)"
description: "Claude Code comparison: cLI Bash calls cost 245 tokens overhead versus 500-2,000 tokens for MCP tool definitions. Compare token costs to choose the..."
permalink: /cli-vs-mcp-agent-operations-token-cost/
date: 2026-04-22
last_tested: "2026-04-22"
---

# CLI vs MCP for Agent Operations: Token Cost Comparison

## What This Means for Claude Code Users

Claude Code performs operations through two primary channels: Bash tool calls (CLI commands) and MCP server tool calls. Each has different token overhead structures. Choosing the wrong channel for a given operation can cost 2-8x more tokens than necessary. For API users on Sonnet 4.6 ($3/$15 per MTok), understanding this cost difference determines whether a 100-operation session costs $0.30 or $1.20.

## The Concept

Every tool invocation in Claude Code carries overhead beyond the actual command or query. This overhead includes the tool call framing (function name, parameters, response structure) and, for MCP tools, the schema definitions that persist in context throughout the session.

The critical distinction: Bash tool overhead is per-call only, while MCP tool overhead is per-call *plus* per-session (schema loading). This means MCP tools carry a fixed tax that amortizes across many calls, while Bash commands have a lower but constant per-call cost.

The decision framework depends on two variables: how many times the tool is called per session, and how complex the operation is.

## How It Works in Practice

### Example 1: Database Queries -- CLI vs MCP

**CLI approach** (Bash tool call):

```bash
# Token cost: ~245 tokens (bash overhead) + ~100 tokens (command) + response
psql -h localhost -d myapp -t -c "SELECT id, email, status FROM users WHERE created_at > '2026-04-01' LIMIT 10"
```

Per-call cost: ~345 tokens + response content. No session-wide overhead.

**MCP approach** (PostgreSQL MCP server):

```json
{
  "tool": "mcp__postgres__query",
  "input": {
    "sql": "SELECT id, email, status FROM users WHERE created_at > '2026-04-01' LIMIT 10"
  }
}
```

Per-call cost: ~200 tokens (tool call framing) + response content.
Session overhead: ~1,200 tokens (tool schema definition loaded at session start).

Break-even analysis:
- CLI: 345 tokens per call, 0 session overhead
- MCP: 200 tokens per call, 1,200 session overhead

Break-even point: 1,200 / (345 - 200) = 8.3 calls. If running fewer than 9 database queries per session, CLI is cheaper. If running 9 or more, MCP amortizes its overhead.

### Example 2: File Operations -- Built-in vs MCP

Claude Code's built-in Read tool costs ~150 tokens overhead per call. A hypothetical MCP file-reader would add tool definition overhead:

```bash
# Built-in Read tool
# Cost: ~150 tokens + file content
# No session overhead (built-in tools are always loaded)

# Bash alternative for targeted extraction
# Cost: ~245 tokens + output
grep -n "function handleAuth" src/auth/*.ts
```

```yaml
# MCP file tool (hypothetical)
# Cost: ~200 tokens per call + ~800 tokens session overhead
# Only justified if it provides functionality beyond built-in tools
# Example: structured AST parsing, cross-file refactoring
```

For standard file operations, built-in tools win decisively. MCP file tools only justify their overhead when providing capabilities impossible through CLI or built-in tools (AST manipulation, semantic search).

**Savings: 50-800 tokens per operation by using built-in tools for standard file work**

### Example 3: Git Operations -- CLI Advantage

Git operations are a clear CLI win because they are single-shot commands with self-contained output:

```bash
# CLI: ~245 tokens overhead + response
git log --oneline -10

# CLI: ~245 tokens overhead + response
git diff --stat HEAD~1

# CLI: ~245 tokens overhead + response
git blame -L 40,60 src/auth/login.ts
```

An MCP Git server would add ~2,000 tokens of tool definitions (diff, blame, log, status, commit, push, pull, etc.) for tools that Bash handles with lower per-call overhead.

**Savings: 2,000 tokens session overhead by using CLI instead of Git MCP server**

## Token Cost Impact

| Operation Type | CLI Cost (per call) | MCP Cost (per call) | MCP Session Overhead | Winner |
|---------------|--------------------|--------------------|---------------------|--------|
| Database query | ~345 tokens | ~200 tokens | ~1,200 tokens | CLI (<9 calls), MCP (9+) |
| File read | ~245 tokens (Bash) / ~150 (Read) | ~200 tokens | ~800 tokens | Built-in Read |
| Git operations | ~245 tokens | ~200 tokens | ~2,000 tokens | CLI (always) |
| API calls (curl) | ~300 tokens | ~250 tokens | ~1,500 tokens | CLI (<30 calls) |
| Complex search | ~245 tokens (Grep) | ~300 tokens | ~1,000 tokens | Built-in Grep |

Decision rule: **Use CLI/built-in tools by default. Use MCP only when (a) the tool provides capabilities CLI cannot match, or (b) the session will make 10+ calls to that specific tool.**

For a typical session with 30 tool calls:
- All-CLI approach: ~30 x 345 = 10,350 tokens in overhead
- Mixed (3 MCP servers loaded, 10 MCP calls): 20 x 345 + 10 x 200 + 3,500 = 12,400 tokens in overhead
- Optimized (CLI default, 1 MCP for high-frequency use): 25 x 345 + 5 x 200 + 1,200 = 10,825 tokens

**Monthly savings from CLI-first strategy: $2.40-$8.40 (Sonnet 4.6, 100 sessions/month)**

### The Hidden Cost: MCP Session Accumulation

Beyond per-call overhead, MCP tools have a second-order cost that CLI commands avoid. MCP tool definitions persist in the context window for the entire session. If a session starts with 3 MCP servers (15 tools total), those tool definitions cost ~15,000 tokens on every subsequent turn as they are re-sent as input.

CLI commands through the Bash tool carry no persistent context overhead. Each `git log --oneline -5` call costs its 245-token overhead and the response content, but nothing persists in the tool definition space.

For a 20-turn session:
- MCP overhead (15 tools): 15,000 tokens x 20 turns = 300,000 tokens of accumulated overhead ($0.90 on Sonnet 4.6 input)
- CLI overhead: 0 persistent tokens, only per-call costs

This makes the MCP break-even calculation more aggressive. MCP tools need to save substantial per-call tokens to justify their persistent overhead, especially in long sessions.

```bash
# Strategy: use CLI for short sessions, MCP for long database-heavy sessions
# Short session (5 turns): CLI always wins
claude --max-turns 5 --allowedTools "Read,Glob,Grep,Bash" \
  -p "Check the database connection and list the tables"

# Long database session (20+ turns): MCP amortizes overhead
claude --allowedTools "Read,Glob,Grep,Edit,Bash,mcp__postgres__query" \
  -p "Investigate the slow query reports and optimize the worst performers"
```

## Implementation Checklist

- [ ] Audit MCP servers: list all registered servers and their tool counts with `claude mcp list`
- [ ] Remove MCP servers for operations achievable through CLI (git, simple file ops, curl)
- [ ] Keep MCP servers only for: database operations (10+ queries/session), external APIs with auth, complex structured operations
- [ ] Add CLI command reference to CLAUDE.md to guide Claude toward efficient CLI patterns
- [ ] Use `--allowedTools` to prevent MCP loading on CLI-sufficient sessions
- [ ] Track per-session tool call counts to validate the break-even analysis for retained MCP servers
- [ ] Review monthly: remove MCP servers with fewer than 9 average calls per session

## The CCG Framework Connection

The CLI-vs-MCP decision is an application of the "select" lever in context engineering. By selecting the tool channel with lower overhead for each operation type, context stays lean. This decision compounds across sessions: a team of 5 developers making 500 combined sessions per month, each saving 2,000 tokens per session by choosing CLI over unnecessary MCP, saves 1,000,000 tokens per month ($3 on Sonnet 4.6 input alone, higher when accounting for output tokens and context compounding).

### Practical Decision Matrix

Use this matrix when deciding whether to configure an MCP server or use CLI for a new integration:

| Question | CLI Wins | MCP Wins |
|----------|---------|----------|
| How many calls per session? | < 9 calls | 9+ calls |
| Does it need structured params? | No (simple args) | Yes (typed schemas) |
| Does the tool need state? | No (stateless) | Yes (connection pool) |
| Is there a good CLI tool? | Yes (gh, psql, curl) | No or poor CLI |
| Session length typical? | < 10 turns | 10+ turns (amortize) |

When in doubt, start with CLI. If a specific operation reaches 9+ calls per session consistently, migrate it to MCP. This "CLI first, MCP when proven" approach minimizes overhead while leaving room for optimization.

### Migration Guide: MCP to CLI

For teams that over-invested in MCP servers, a structured migration path:

```bash
# Step 1: Identify MCP tools with CLI equivalents
# Common replacements:
#   mcp__github__create_issue  -> gh issue create
#   mcp__github__list_issues   -> gh issue list
#   mcp__fs__read_file         -> cat (built-in Read tool)
#   mcp__fs__write_file        -> (built-in Edit/Write tool)
#   mcp__docker__list          -> docker ps
#   mcp__docker__logs          -> docker logs <container>

# Step 2: Add CLI commands to CLAUDE.md
cat >> CLAUDE.md << 'EOF'
## CLI Commands (use instead of MCP)
- GitHub issues: `gh issue create`, `gh issue list --state open`
- Docker: `docker ps`, `docker logs <name>`
- File ops: use built-in Read/Edit tools (0 overhead)
EOF

# Step 3: Remove unnecessary MCP servers
claude mcp remove github
claude mcp remove filesystem
claude mcp remove docker

# Step 4: Verify savings with ccusage after 1 week
```

Each removed MCP server saves its full tool definition overhead on every session. Removing a 6-tool server at ~1,000 tokens per tool eliminates 6,000 tokens of per-session overhead. Over 100 monthly sessions: 600,000 tokens saved = $1.80/month on Sonnet 4.6 input alone.

## Further Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- when MCP is the right choice
- [Claude Code Skills Guide](/skills/) -- an even cheaper alternative to both CLI and MCP for static knowledge
- [Reducing Claude Code MCP Round-Trips: Batch Operations Pattern](/reducing-claude-code-mcp-round-trips-batch-pattern/) -- optimize MCP when it is needed
- [InsForge vs Supabase: Claude Code Token Cost (2026)](/insforge-vs-supabase-claude-code-token-cost-2026/)
- [Claude Code MCP tools loading slowly — token cost impact](/claude-code-mcp-tools-loading-slowly-token-cost/)
