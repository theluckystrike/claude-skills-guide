---
title: "Track Claude Code Costs With ccusage (2026)"
description: "Run npx ccusage to see per-session Claude Code costs from local logs. Step-by-step setup, filtering, and export for cost tracking and optimization."
permalink: /how-to-track-claude-code-costs-ccusage-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Track Claude Code Costs With ccusage (2026)

ccusage parses your local Claude Code session logs and calculates per-session costs. No API keys needed. No account setup. One command and you see where your tokens go.

## Prerequisites

- Node.js 18+ installed
- Claude Code installed with at least one previous session (so log files exist)
- Terminal access

## Step 1: Run ccusage

No installation needed — npx handles it:

```bash
npx ccusage
```

First run downloads the package (a few seconds), then parses your `~/.claude/projects/` directory. Output is a table showing:

| Date | Project | Input Tokens | Output Tokens | Cache Read | Cache Write | Est. Cost |
|---|---|---|---|---|---|---|
| 2026-04-22 | my-app | 125,400 | 34,200 | 89,100 | 12,300 | $0.89 |
| 2026-04-21 | my-app | 342,100 | 98,400 | 201,000 | 45,200 | $2.41 |

## Step 2: Filter by Date Range

See costs for a specific period:

```bash
npx ccusage --from 2026-04-01 --to 2026-04-22
```

This is useful for monthly audits or comparing week-over-week spending.

## Step 3: Filter by Project

If you work on multiple projects, isolate costs:

```bash
npx ccusage --project my-app
```

## Step 4: Export Data

Export to JSON for further analysis:

```bash
npx ccusage --format json > claude-costs-april.json
```

Export to CSV for spreadsheets:

```bash
npx ccusage --format csv > claude-costs-april.csv
```

## Step 5: Analyze and Optimize

Look for patterns in the output:

**High input tokens**: Claude is reading large files repeatedly. Consider breaking large files into smaller modules, or adding summaries to your CLAUDE.md so Claude does not need to re-read full files.

**High output tokens**: Claude is generating more code than needed. Be more specific in your prompts — "add a login endpoint" produces less output than "add authentication."

**High cache read tokens**: Not necessarily bad — cache reads are cheaper than fresh input tokens. But if cache reads are extremely high, your context might be too large.

**Cost spikes on specific sessions**: Identify what you did in expensive sessions. Common causes: large refactors, debugging loops where Claude tried multiple approaches, or sessions where you repeatedly asked Claude to re-read the codebase.

## Verification

Confirm ccusage is reading your logs correctly:

```bash
# Check that log files exist
ls ~/.claude/projects/

# Run with verbose output
npx ccusage --verbose
```

If ccusage reports zero sessions, verify that `~/.claude/projects/` contains JSONL files from your Claude Code sessions.

## Setting Up Weekly Cost Reviews

The most effective cost optimization is a weekly review habit. Here is a 5-minute routine:

**Every Monday morning**:

```bash
# See last week's costs
npx ccusage --from $(date -v-7d +%Y-%m-%d) --to $(date +%Y-%m-%d)
```

Review the output for:
1. Any session over $5 — investigate what happened
2. Projects with disproportionate costs — consider if those projects need optimization
3. Trends — are costs increasing or decreasing week over week?

**Monthly export for records**:

```bash
npx ccusage --from $(date -v-1m +%Y-%m-01) --to $(date +%Y-%m-01) --format csv > ~/claude-costs/$(date -v-1m +%Y-%m).csv
```

## Understanding Token Types

ccusage breaks down tokens into four categories. Understanding each helps you optimize:

**Input tokens**: Text you send to Claude, including your CLAUDE.md, conversation history, and the content of files Claude reads. High input tokens usually mean large files being read repeatedly.

**Output tokens**: Text Claude generates — code, explanations, and commands. These cost 5x more than input tokens, so reducing output has the highest cost impact. Write specific prompts to get focused output.

**Cache read tokens**: Content that was recently sent and is served from cache. These are cheaper than fresh input tokens. High cache reads mean Claude is efficiently reusing context.

**Cache write tokens**: Content being written to the cache for future reads. These are normal and expected. You do not need to optimize for cache writes.

## Troubleshooting

**"No sessions found"**: Claude Code may store logs in a different location on your system. Check `~/.claude/` for the actual path structure. On some systems, the projects directory may be nested differently.

**Cost seems too high/low**: ccusage uses published API rates. If you are on Claude Max (subscription), the estimated cost represents what you would pay at API rates, not your actual subscription cost. Use it for relative comparisons, not absolute billing.

**Old sessions missing**: ccusage only reads files that exist. If you deleted old log files, those sessions will not appear. To preserve history, back up `~/.claude/projects/` periodically.

**npx takes too long**: Pin the version for faster subsequent runs:

```bash
npm install -g ccusage
ccusage
```

**Date format errors**: Use ISO format (YYYY-MM-DD) for date filters. Other formats may not parse correctly.

## Next Steps

- Set up [monthly cost auditing](/how-to-audit-claude-code-costs-monthly-2026/) with ccusage
- Compare ccusage with [the Claude Max dashboard](/ccusage-vs-claude-max-dashboard-cost-tracking-2026/)
- Use [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) to log additional cost-relevant data
- Review [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for token optimization
