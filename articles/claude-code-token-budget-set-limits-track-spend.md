---
title: "Claude Code Token Budget: How to Set Limits and Track Spend"
description: "Set token budgets and track Claude Code spending with built-in /cost, ccusage, and API console alerts to prevent runaway costs on every session."
permalink: /claude-code-token-budget-set-limits-track-spend/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Token Budget: How to Set Limits and Track Spend

## The Problem

Without explicit budgets, Claude Code sessions have no upper spending bound. A single debugging session that spirals into retry loops can consume 200K+ tokens -- costing $3-$18 at Opus 4.6 rates ($15/MTok input, $75/MTok output). Teams running five engineers without budgets regularly report $1,000-$4,000 in unexpected monthly API charges. Token budgets transform an unpredictable expense into a controlled line item.

## Quick Wins (Under 5 Minutes)

1. **Run `/cost` after every 5 exchanges** -- gives immediate visibility into current session spend.
2. **Set Anthropic Console spend alerts** -- configure email notifications at $50, $100, and $200 thresholds.
3. **Add a CLAUDE.md budget rule** -- a single line reminding the agent to report cost every 10 turns.
4. **Use `--max-turns` flag** -- caps the number of agentic turns per invocation, directly limiting token burn.

## Deep Optimization Strategies

### Strategy 1: Session-Level Budget with --max-turns

The `--max-turns` flag is the most direct budget control available. It hard-caps the number of agentic turns Claude Code will execute before stopping and returning control.

```bash
# Cap a session to 20 turns (typical: 15K-40K tokens)
claude --max-turns 20 "Refactor the payment service to use event sourcing"

# For simple tasks, 5 turns is usually sufficient (5K-15K tokens)
claude --max-turns 5 "Add input validation to the /users endpoint"

# For complex tasks, allow more room but still set a ceiling
claude --max-turns 50 "Debug the intermittent test failure in integration/auth.test.ts"
```

At 1,000-3,000 tokens per turn, `--max-turns 20` creates an effective budget ceiling of approximately 60K tokens ($0.90 at Opus rates). Without this flag, the same task could run 40+ turns and consume 120K tokens ($1.80).

### Strategy 2: CLAUDE.md Budget Enforcement Rules

Encode budget awareness directly into the agent's instructions so it self-monitors.

```yaml
# CLAUDE.md -- budget enforcement section
## Token Budget Rules
- Report current /cost every 10 exchanges
- If a task exceeds 15 tool calls without resolution, stop and summarize findings
- Maximum 3 retry attempts on any failing command before asking for guidance
- Never read more than 5 files in a single exploration phase
- For bug fixes: if not resolved in 8 turns, compact and reassess approach
```

These rules prevent the two most expensive failure modes: retry spirals (where Claude Code repeatedly attempts the same failing approach, wasting 20K-50K tokens) and exploration spirals (where it reads dozens of files trying to understand a codebase, consuming 30K-80K tokens).

### Strategy 3: API Console Budget Alerts

The Anthropic Console provides spend tracking and alerting. Configure tiered alerts to catch budget overruns early.

```text
Anthropic Console -> Settings -> Usage Alerts

Alert 1: $50/month  -- "On track" notification
Alert 2: $100/month -- "Review usage" warning
Alert 3: $200/month -- "Budget exceeded" critical alert
Alert 4: $500/month -- Hard spending limit (blocks API calls)
```

Set the hard limit at your true maximum. For a solo developer, this might be $200/month. For a team of five, consider $1,000/month. The hard limit prevents catastrophic billing surprises from runaway scripts or automated pipelines.

### Strategy 4: Historical Tracking with ccusage

The `ccusage` tool reads Claude Code's local usage logs and provides historical spending data across sessions.

```bash
# Install ccusage
npm install -g ccusage

# View last 7 days of usage
ccusage --days 7

# Output includes:
# - Total input/output tokens per day
# - Cost breakdown by model
# - Session count and average tokens per session

# Export for team reporting
ccusage --days 30 --format json > monthly-usage.json
```

Track three key metrics weekly:
- **Average tokens per session** -- target: under 80K after optimization
- **Cost per resolved task** -- target: under $1 for standard coding tasks
- **Retry ratio** -- tool calls that repeat the same operation (target: under 10%)

### Strategy 5: Per-Task Budget Estimation

Before starting a task, estimate its token budget based on complexity class.

```yaml
# Task complexity budget guide
# Keep in CLAUDE.md or a team wiki

## Budget by Task Type
| Task | Estimated Tokens | Max Turns | Approx. Cost (Opus) |
|------|-----------------|-----------|---------------------|
| Simple file edit | 5K-15K | 5 | $0.08-$0.23 |
| Bug fix (known location) | 15K-40K | 15 | $0.23-$0.60 |
| Bug fix (unknown location) | 40K-100K | 30 | $0.60-$1.50 |
| Feature implementation | 50K-120K | 25 | $0.75-$1.80 |
| PR review | 30K-80K | 10 | $0.45-$1.20 |
| Architecture exploration | 80K-200K | 40 | $1.20-$3.00 |
```

If a bug fix estimated at 40K tokens reaches 80K tokens (2x the estimate), that is a signal to stop, compact, and try a different approach -- or ask a human for direction.

## Measuring Your Savings

```bash
# Track budget adherence over a week
# Record each session: task type, estimated budget, actual spend

# Monday example:
# Task: Fix auth bug, Budget: 40K, Actual: 32K -- UNDER BUDGET
# Task: Add endpoint, Budget: 50K, Actual: 67K -- OVER BUDGET (review why)

# Weekly adherence rate target: 80%+ of sessions under budget
ccusage --days 7 --format table
```

## Cost Impact Summary

| Budget Technique | Token Savings | Monthly Savings (Solo, Opus) |
|-----------------|--------------|------------------------------|
| --max-turns caps | 20-40% reduction in overruns | $15-$60 |
| CLAUDE.md budget rules | 30-50% fewer retry/explore spirals | $20-$75 |
| Console spend alerts | Prevents runaway billing | $50-$500 (catastrophe prevention) |
| Per-task estimation | 15-25% tighter adherence | $10-$40 |
| **Combined** | **40-60% cost reduction** | **$95-$675** |

## Related Guides

- [How to Reduce Claude Code Token Usage by 3x](/reduce-claude-code-token-usage-3x-guide-2026/) -- comprehensive token reduction strategies
- [Claude Code Cost Alerts: Set Up Notifications When Spend Exceeds Budget](/claude-code-cost-alerts-notifications-budget/) -- detailed alerting configuration
- [Claude Code Hooks for Token Budget Enforcement](/claude-code-hooks-token-budget-enforcement/) -- automated enforcement with hooks
