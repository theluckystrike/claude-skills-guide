---
title: "Claude Code --allowedTools"
description: "The --allowedTools flag restricts Claude Code tool access per session, cutting MCP overhead by 40-60% and preventing unnecessary tool call tokens."
permalink: /claude-code-allowed-tools-flag-save-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code --allowedTools Flag: Restrict Tool Calls to Save Tokens

## The Problem

Every MCP tool registered with Claude Code adds 500-2,000 tokens of schema overhead to the context window. A project with 3 MCP servers exposing 15 tools loads 7,500-30,000 tokens of tool definitions at session start -- before the first prompt. The `--allowedTools` flag restricts which tools load, cutting this overhead by 40-60% on focused tasks. At Sonnet 4.6 rates ($3/$15 per MTok), trimming 15,000 tokens per session saves $0.045 per session, or $4.50 per month for a developer running 100 sessions.

## Quick Wins (Under 5 Minutes)

1. **List your tool overhead** -- run `claude mcp list` to see all registered servers and tool counts. Multiply tool count by ~1,000 for estimated token overhead.
2. **Create task-specific aliases** -- add shell aliases for common restricted sessions.
3. **Start with deny patterns** -- use `--allowedTools` with negation to block known-expensive tools you rarely use.

## Deep Optimization Strategies

### Strategy 1: Understand What Gets Loaded Without the Flag

By default, Claude Code loads tool definitions for every configured MCP server at session start. Understanding the baseline overhead clarifies what `--allowedTools` eliminates:

```bash
# Check current MCP overhead
claude mcp list
# Example output:
# postgres   - 4 tools (~4,000 tokens)
# github     - 8 tools (~8,000 tokens)
# filesystem - 6 tools (~3,000 tokens)
# Total: 18 tools = ~15,000 tokens loaded EVERY session
```

Those 15,000 tokens persist in context for the entire session. On a 20-turn session, they are re-sent as input on every turn: 15,000 x 20 = 300,000 tokens of cumulative overhead. At Sonnet 4.6 input rates ($3/MTok), that is $0.90 in pure overhead tokens for tools that may never be called.

The `--allowedTools` flag specifies an explicit allowlist. Only tools named in the flag load their definitions. Everything else is excluded from context entirely -- zero tokens, zero overhead.

### Strategy 2: Restrict Tools by Task Type

For code review sessions that only need file reading:

```bash
# Allow only built-in read/search tools -- no MCP, no bash
claude --allowedTools "Read,Glob,Grep" \
  -p "Review src/auth/login.ts for security issues"
```

This session loads zero MCP tool definitions, saving the full MCP overhead. Token budget for a read-only review session drops from ~30,000 (with all tools) to ~8,000 (built-in tools only).

For edit-focused sessions:

```bash
# Allow read + edit tools, block database and deployment MCP servers
claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash" \
  -p "Refactor the user service to use dependency injection"
```

**Savings: 7,500-22,000 tokens per restricted session**

For exploration and investigation sessions where no code changes are needed:

```bash
# Investigation mode: cannot edit, only observe
claude --allowedTools "Read,Glob,Grep" \
  -p "Trace the data flow from the webhook handler to the database.
  Show me which files are involved and what transformations happen."
```

This is particularly valuable for onboarding sessions where a new developer is learning the codebase. Read-only sessions cannot accidentally modify code, and the limited tool set keeps costs low.

**Savings: 7,500-22,000 tokens per restricted session**

### Strategy 3: Create Shell Aliases for Common Patterns

```bash
# ~/.zshrc or ~/.bashrc

# Read-only review mode
alias claude-review='claude --allowedTools "Read,Glob,Grep"'

# Edit mode (no MCP servers)
alias claude-edit='claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash"'

# Database work only
alias claude-db='claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash,mcp__postgres__query"'

# Full access (explicit, for when you need everything)
alias claude-full='claude'
```

Using `claude-review` for 30% of daily sessions (code reviews, explanations) eliminates tool overhead on those sessions entirely.

**Savings: 4,500-15,000 tokens per review session (30% of daily usage)**

Make the cost implication clear in alias names so team members naturally choose the cheaper option:

```bash
# Cost-labeled aliases (team convention)
alias claude-cheap='claude --allowedTools "Read,Glob,Grep" --max-turns 8'
alias claude-standard='claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash" --max-turns 20'
alias claude-full='claude --max-turns 30'
```

Using `claude-review` for 30% of daily sessions (code reviews, explanations) eliminates tool overhead on those sessions entirely.

**Savings: 4,500-15,000 tokens per review session (30% of daily usage)**

### Strategy 4: Combine with --max-turns for Budget Control

Pair `--allowedTools` with `--max-turns` for hard cost caps on automated tasks:

```bash
# CI pipeline: review PR with limited tools and bounded turns
claude --allowedTools "Read,Glob,Grep" \
  --max-turns 10 \
  -p "Review the changes in this PR for bugs and style issues. Files: $(git diff --name-only HEAD~1)"
```

This caps the session at approximately 10 turns with read-only tools. Maximum possible cost: ~30,000 tokens ($0.09 on Sonnet 4.6) versus an unbounded session that could consume 200,000+ tokens ($0.60+).

```bash
# Automated documentation generation with cost ceiling
claude --allowedTools "Read,Glob,Grep,Write" \
  --max-turns 15 \
  -p "Generate JSDoc comments for all exported functions in src/utils/"
```

**Savings: prevents runaway sessions that exceed 200K tokens**

### Strategy 5: Per-MCP-Tool Allowlisting

When a session needs one specific MCP tool but not the rest of the server's tools, allow only that specific tool:

```bash
# Only allow the postgres query tool, not describe/list/execute
claude --allowedTools "Read,Glob,Grep,Edit,Bash,mcp__postgres__query" \
  -p "Write a query to find users who signed up in the last 30 days but haven't made a purchase"
```

If the postgres MCP server exposes 4 tools at ~1,000 tokens each, loading only 1 saves ~3,000 tokens of tool definition overhead. This fine-grained control is especially valuable for servers with many tools where only one is needed for the current task.

```bash
# Only allow the GitHub issue creation tool, not the full 8-tool suite
claude --allowedTools "Read,Glob,Grep,Bash,mcp__github__create_issue" \
  -p "Create a GitHub issue for the authentication timeout bug described in BUGS.md"
```

**Savings: 1,000-6,000 tokens per session with selective MCP tool loading**

## Measuring Your Savings

```bash
# Compare costs between restricted and unrestricted sessions

# Unrestricted (all tools loaded):
claude -p "Explain what src/auth/login.ts does"
# Session cost: ~18,000 tokens ($0.054)

# Restricted (read-only):
claude --allowedTools "Read,Glob,Grep" -p "Explain what src/auth/login.ts does"
# Session cost: ~6,000 tokens ($0.018)

# Savings: 12,000 tokens (67% reduction), $0.036 per session
```

Check with `/cost` at the end of interactive sessions to measure the difference.

For systematic comparison, track restricted vs. unrestricted session costs over a week:

```bash
# scripts/compare-tool-configs.sh
# Run the same task type with different tool configurations
set -uo pipefail

TASK="Explain what src/auth/login.ts does and identify potential issues"

echo "=== Unrestricted ==="
claude -p "$TASK" --max-turns 5 2>&1 | grep -i "cost\|token" | tail -3

echo ""
echo "=== Restricted (read-only) ==="
claude --allowedTools "Read,Glob,Grep" -p "$TASK" --max-turns 5 2>&1 | grep -i "cost\|token" | tail -3
```

The restricted session should show 40-70% fewer tokens for the same task output quality.

## Cost Impact Summary

| Scenario | Unrestricted Cost | Restricted Cost | Monthly Savings |
|----------|------------------|----------------|-----------------|
| Code review session | 18,000 tokens | 6,000 tokens | $3.60 |
| Quick explanation | 12,000 tokens | 4,000 tokens | $2.40 |
| CI PR review | 80,000 tokens | 30,000 tokens | $15.00 |
| **Blended (100 sessions/month)** | | | **$7.20-$21.00** |

Assumes Sonnet 4.6 rates, 20 working days, 5 sessions/day. The `--allowedTools` flag is most effective when combined with `--max-turns` -- together they provide both scope restriction and duration restriction for comprehensive cost control.

## Related Guides

- [Claude Code Max Turns Flag: Prevent Runaway Sessions](/claude-code-max-turns-flag-prevent-runaway-sessions/) -- pair with --allowedTools for maximum cost control
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- understand which MCP tools contribute to overhead
- [Cost Optimization Hub](/cost-optimization/) -- complete guide to reducing Claude Code costs

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to --dangerously-skip-permissions and safer alternatives
