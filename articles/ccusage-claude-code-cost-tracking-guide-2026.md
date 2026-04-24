---
title: "ccusage: Claude Code Cost Tracking"
description: "Track Claude Code session costs with ccusage — parse JSONL logs for daily, monthly, and per-session spend breakdowns via CLI."
permalink: /ccusage-claude-code-cost-tracking-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# ccusage: Claude Code Cost Tracking Guide (2026)

ccusage by ryoppippi (13K+ stars) is the go-to CLI for answering "how much did that Claude Code session cost?" It parses the JSONL log files in `~/.claude/projects/` and breaks down token usage into dollar amounts — by session, by day, or by month.

## What It Is

A lightweight Node.js CLI that reads Claude Code's local log files and calculates cost. Claude Code writes detailed JSONL logs for every session, including input tokens, output tokens, cache reads, and cache writes. ccusage parses these logs and applies current API pricing to produce cost reports.

Three modes:

- **Daily** (`npx ccusage`) — cost per day for the current billing period
- **Monthly** (`npx ccusage monthly`) — month-over-month cost comparison
- **Session** (`npx ccusage session`) — cost for each individual session with project names

## Why It Matters

Claude Code doesn't surface cost information in the UI. You see token counts in the status bar, but converting that to dollars requires knowing the per-model pricing, accounting for cache hits, and summing across sessions. ccusage automates all of this.

Without cost visibility, teams discover overspend at invoice time. With ccusage, you catch runaway sessions the day they happen. One team reported finding a stuck agent loop that consumed $47 in a single session — ccusage flagged it the same day.

## Installation

### Via npx (No Install)

```bash
npx ccusage
```

### Global Install

```bash
npm install -g ccusage
ccusage
```

### Verify It Works

```bash
npx ccusage session --limit 5
```

This should list your last 5 Claude Code sessions with token counts and costs. If it shows nothing, check that `~/.claude/projects/` contains JSONL files.

## Key Features

1. **Daily Cost View** — see what you spent today, yesterday, and across the current billing period. Spot cost spikes immediately.

2. **Monthly Aggregation** — compare spending month over month. Track whether your team's Claude Code usage is growing, stable, or shrinking.

3. **Per-Session Breakdown** — identify which sessions cost the most. Correlate with project names to find which codebases are expensive to work with.

4. **Cache-Aware Pricing** — correctly accounts for cache reads (cheaper) vs. fresh input tokens. Most naive calculators overestimate costs by ignoring the cache.

5. **Project Name Resolution** — maps session IDs to project directory names, so you see "my-api" instead of a UUID.

6. **No API Keys Required** — reads local log files only. No network calls, no authentication, no data leaves your machine.

7. **Export to JSON** — pipe output to JSON for custom dashboards or budget alerts.

8. **Model-Aware** — applies correct pricing for whichever model the session used (Opus, Sonnet, Haiku). Multi-model sessions are priced correctly per-segment.

## Real Usage Example

### Daily View

```bash
$ npx ccusage

Claude Code Usage — April 2026

Date        │ Input Tokens │ Output Tokens │ Cache Reads │ Cost
────────────┼──────────────┼───────────────┼─────────────┼────────
2026-04-22  │    245,831   │     89,442    │   312,558   │  $4.12
2026-04-21  │    512,099   │    201,337    │   445,221   │  $8.74
2026-04-20  │    189,445   │     67,882    │   234,119   │  $3.01
2026-04-19  │    834,221   │    312,445    │   667,883   │ $14.22
────────────┼──────────────┼───────────────┼─────────────┼────────
Total       │  1,781,596   │    671,106    │ 1,659,781   │ $30.09
```

### Session View

```bash
$ npx ccusage session --limit 3

Session                          │ Project      │ Duration │ Cost
─────────────────────────────────┼──────────────┼──────────┼───────
2026-04-22T14:32:00 (active)     │ my-api       │   23m    │ $2.18
2026-04-22T09:15:00              │ frontend     │   45m    │ $1.94
2026-04-21T16:44:00              │ my-api       │  1h 12m  │ $5.33
```

### Export for Budgeting

```bash
npx ccusage --json > ~/reports/claude-costs-april.json
```

### Set Up a Budget Alert (with a simple wrapper)

```bash
#!/bin/bash
# daily-cost-check.sh
DAILY_COST=$(npx ccusage --json | jq '.days[-1].cost')
THRESHOLD=20.00

if (( $(echo "$DAILY_COST > $THRESHOLD" | bc -l) )); then
  echo "Claude Code daily spend alert: \$$DAILY_COST" | \
    mail -s "Cost Alert" team@example.com
fi
```

## When To Use

- **Teams with Claude Code budgets** — monitor spend against monthly allocations
- **Individual developers** — track personal usage to avoid surprise bills
- **Cost optimization** — identify expensive sessions and analyze what made them costly
- **Manager reporting** — generate monthly cost reports per project
- **Comparing workflows** — measure whether a new CLAUDE.md configuration reduces token usage

## When NOT To Use

- **Enterprise plans with usage dashboards** — if Anthropic's admin console gives you the same data, ccusage is redundant
- **API-only usage** — ccusage reads Claude Code's local logs, not direct API call logs
- **Shared machines** — the tool reads all sessions for the current user; multi-user machines may show mixed data

## FAQ

### Where are the log files?

`~/.claude/projects/` contains one directory per project, each with JSONL log files. ccusage reads all of them.

### How accurate are the cost estimates?

Within 5% of actual billing. The main variance comes from pricing updates — if Anthropic changes token prices, ccusage needs an update to reflect the new rates. Check for updates regularly.

### Does it work with Claude Max / Pro subscriptions?

It shows token usage and calculates what the cost would be at API rates. For subscription plans, this represents the "equivalent API cost" of your usage, which is useful for understanding whether a subscription or API billing is more cost-effective.

### Can I track costs per team member?

Not directly — ccusage reads the local user's logs. For team tracking, each developer runs ccusage and exports JSON to a shared dashboard.

### How far back does the history go?

As far back as your log files exist. Claude Code retains logs indefinitely by default. Most installations have months of history available.

## Our Take

**9/10.** Essential tool for anyone paying for Claude Code usage. The per-session breakdown alone has saved teams hundreds of dollars by identifying wasteful patterns (stuck loops, over-broad context loading, unnecessary re-reads). The only missing feature is built-in alerting — you need to script that yourself. Pair with [Karpathy's Don't Assume principle](/karpathy-dont-assume-principle-claude-code-2026/) to reduce token waste from unnecessary clarification cycles.

## Related Resources

- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — patterns that reduce token usage
- [The Claude Code Playbook](/playbook/) — workflows optimized for cost efficiency
- [Best Claude Skills for Developers](/best-claude-skills-for-developers-2026/) — tools that complement cost tracking
- [Claude API pricing](/claude-api-pricing-complete-guide/) — every plan and model priced
- [Claude extra usage cost](/claude-extra-usage-cost-guide/) — understand what overages cost
