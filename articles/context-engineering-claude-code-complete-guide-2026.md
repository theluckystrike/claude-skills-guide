---
layout: default
title: "Context Engineering for Claude Code (2026)"
description: "Master context engineering for Claude Code to cut token costs by 60-80% with structured CLAUDE.md files, precision reads, and compaction strategies."
permalink: /context-engineering-claude-code-complete-guide-2026/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Context Engineering for Claude Code: Complete Guide (2026)

## The Problem

Context engineering is the discipline of controlling exactly what information an AI agent sees, when it sees it, and how much of it enters the context window. In Claude Code, poor context engineering is the single largest source of token waste. A session with unmanaged context easily consumes 200K tokens, while the same task with proper context engineering completes in 60K-80K tokens -- a 60-70% reduction that saves $6-$15 per session at Opus 4.6 rates ($15/$75 per MTok input/output).

## Quick Wins (Under 5 Minutes)

1. **Audit CLAUDE.md size** -- if it exceeds 500 tokens, split into a lean root file and `.claude/` subdirectory files that load on demand.
2. **Run `/compact` before starting any new task within an existing session** -- clears 60-80% of stale context.
3. **Specify file paths and line numbers in prompts** -- eliminates search-and-read discovery cycles that cost 1,000-3,000 tokens each.
4. **Remove unused MCP tool definitions** -- each definition adds 500-2,000 tokens to every API call.
5. **Use `--model sonnet` for discovery phases** -- pay $3/MTok instead of $15/MTok while Claude Code explores the codebase.

## Deep Optimization Strategies

### Strategy 1: The Context Budget Framework

Treat every session like a budget. At Opus 4.6 rates, 200K tokens costs $3.00 input + $15.00 output (assuming a 1:1 ratio). Set a context budget before starting work.

```yaml
# CLAUDE.md -- context budget rules
## Context Discipline
- Maximum file read: 200 lines without offset targeting
- Maximum tool calls per task: 8
- Compact after every 10 exchanges or 80K tokens (whichever comes first)
- For files > 500 lines: read structure first (lines 1-30), then target specific sections
- NEVER glob + read more than 5 files in a single exploration
```

This rule set prevents the most common context blowup: Claude Code reading 10+ files to understand a codebase it could navigate with a targeted 3-file read.

### Strategy 2: Layered Context Architecture

Structure project information in layers that load progressively, rather than dumping everything into a single CLAUDE.md.

```text
Project Root/
  CLAUDE.md              # Layer 0: 200-400 tokens. Project identity, key commands, constraints.
  .claude/
    architecture.md      # Layer 1: 500-800 tokens. System design, module boundaries.
    api-conventions.md   # Layer 2: 300-500 tokens. API patterns, naming rules.
    testing-rules.md     # Layer 2: 200-400 tokens. Test commands, coverage requirements.
  src/
    payments/
      CLAUDE.md          # Layer 3: 200-300 tokens. Payment module specifics.
    auth/
      CLAUDE.md          # Layer 3: 200-300 tokens. Auth module specifics.
```

```yaml
# Root CLAUDE.md (Layer 0) -- ~300 tokens
## PaymentService
- TypeScript, Node 20, pnpm
- PostgreSQL + Prisma ORM
- Run tests: `pnpm test`
- Run lint: `pnpm lint`
- Deploy: `pnpm deploy:staging`

## Rules
- Never modify src/generated/ files
- All new endpoints need OpenAPI spec update in docs/api.yaml
- Prefer Prisma transactions for multi-table writes
```

Layer 0 loads on every session (~300 tokens). Layers 1-3 load only when Claude Code navigates to relevant directories. Total savings versus a monolithic 2,000-token CLAUDE.md: 500-1,700 tokens per session on tasks that do not touch all modules.

### Strategy 3: Prompt Specificity as Context Control

The precision of a prompt directly controls how many tokens Claude Code will spend discovering context. Three levels of prompt specificity with their corresponding token costs:

```text
# Level 1: Vague (costs 8K-20K discovery tokens)
"Fix the authentication bug"

# Level 2: Targeted (costs 2K-5K discovery tokens)
"Fix the JWT expiration check in src/auth/middleware.ts -- the token.exp comparison uses seconds but Date.now() returns milliseconds"

# Level 3: Surgical (costs 500-1K discovery tokens)
"In src/auth/middleware.ts line 47, change `token.exp > Date.now()` to `token.exp > Math.floor(Date.now() / 1000)` -- JWT exp is in Unix seconds"
```

A Level 3 prompt saves 7,500-19,000 tokens compared to Level 1. At Opus rates, that is $0.11-$1.43 saved per prompt.

### Strategy 4: Tool Call Minimization

Every tool call in Claude Code carries overhead. Bash calls cost approximately 245 tokens each. Read calls cost approximately 150 tokens plus file content. A session making 30 tool calls spends at least 4,500-7,350 tokens on overhead alone.

```yaml
# CLAUDE.md -- tool efficiency rules
## Tool Call Discipline
- Before running Bash, check if the Read tool can answer the question
- Combine related grep operations: search for multiple patterns in one call
- Use Glob for file discovery instead of running `find` via Bash
- When reading test output, use `--reporter=verbose 2>&1 | head -50` to cap output size
- Never run a build command just to check syntax -- use the linter instead
```

Reducing a session from 30 tool calls to 15 saves approximately 3,675 tokens in overhead. More importantly, fewer tool calls means fewer round-trips, each of which re-sends the entire conversation context.

### Strategy 5: Compaction as Context Engineering

The `/compact` command is not just a memory management tool -- it is a context engineering instrument. Strategic compaction preserves the right information while discarding noise.

```bash
# Before compaction: check what context exists
/cost
# Output: ~120K tokens in context

# Compact with a focus directive
/compact Keep: current task (refactoring auth module), file paths already identified, test results from last run. Discard: initial exploration, dead-end approaches, superseded file reads.

# After compaction: verify reduction
/cost
# Output: ~35K tokens in context (71% reduction)
```

Adding focus directives to `/compact` produces better compaction results than bare `/compact` because the summarizer knows what to prioritize. This preserves task-relevant context while aggressively pruning discovery artifacts.

## Measuring Your Savings

```bash
# Per-session measurement
/cost
# Shows: input tokens, output tokens, cache reads/writes, total cost

# Historical measurement
ccusage --days 7 --format table

# Compare before/after implementing context engineering
# Week 1 baseline: record daily token totals
# Week 2 optimized: record daily token totals after applying strategies
# Calculate: (Week1 - Week2) / Week1 * 100 = % reduction
```

A well-executed context engineering practice should show a 50-70% reduction in weekly token usage within the first week of implementation.

## Cost Impact Summary

| Context Engineering Technique | Token Savings per Session | Monthly Savings (Opus, daily use) |
|-------------------------------|--------------------------|----------------------------------|
| Layered CLAUDE.md | 500-1,700 tokens/session | $1.50-$5 |
| Prompt specificity (L1 to L3) | 7,500-19,000 tokens/prompt | $25-$75 |
| Tool call minimization | 3,675+ tokens/session | $5-$15 |
| Strategic compaction | 50K-85K tokens/session | $30-$90 |
| MCP tool pruning | 2,500-10,000 tokens/turn | $15-$50 |
| **Combined** | **60-80% reduction** | **$76-$235** |

## Related Guides

- [What Is Context Engineering? (Karpathy's Definition Applied to Claude Code)](/what-is-context-engineering-karpathy-claude-code/) -- the conceptual foundation behind these techniques
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- detailed compaction mechanics
- [CLAUDE.md as Cost Control: Rules That Prevent Token Waste](/claude-md-cost-control-rules-prevent-token-waste/) -- CLAUDE.md patterns for cost reduction
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- staying within context limits under pressure

## See Also

- [How Context Engineering Reduces Claude Code Costs: The Mechanism](/context-engineering-reduces-claude-code-costs-mechanism/)
