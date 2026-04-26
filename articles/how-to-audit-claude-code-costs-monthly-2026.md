---
layout: default
title: "Audit Claude Code Costs Monthly (2026)"
description: "Set up a monthly Claude Code cost audit using ccusage. Automate reports, identify expensive sessions, and track spending trends over time."
permalink: /how-to-audit-claude-code-costs-monthly-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# How to Audit Claude Code Costs Monthly With ccusage (2026)

A monthly cost audit prevents surprise bills and identifies optimization opportunities. ccusage automates the data collection. Here is how to build a repeatable monthly audit process.

## Prerequisites

- Node.js 18+ installed
- At least one month of Claude Code usage (for meaningful data)
- Terminal access

## Step 1: Generate the Monthly Report

Run ccusage with date filters for the previous month:

```bash
npx ccusage --from 2026-03-01 --to 2026-03-31 --format json > ~/claude-costs/march-2026.json
```

For a human-readable summary:

```bash
npx ccusage --from 2026-03-01 --to 2026-03-31
```

Create the costs directory if it does not exist:

```bash
mkdir -p ~/claude-costs
```

## Step 2: Identify Expensive Sessions

Sort sessions by cost to find outliers:

```bash
npx ccusage --from 2026-03-01 --to 2026-03-31 --sort cost
```

For each expensive session, ask:
- What project was I working on?
- What task was I doing? (Check your git log for that date)
- Was the high cost justified, or was there waste?

Common causes of expensive sessions:
- Large file reads (Claude re-reading big files repeatedly)
- Debugging loops (multiple failed attempts)
- Over-broad prompts ("refactor the entire codebase")
- Context window bloat (huge CLAUDE.md + many MCP servers)

## Step 3: Calculate Key Metrics

From your monthly data, track these metrics:

**Total monthly cost**: Sum of all session costs. Compare month-over-month.

**Cost per project**: Group sessions by project. Identify which projects consume the most tokens.

**Average session cost**: Total cost divided by session count. Rising averages suggest inefficiency.

**Cost per productive session**: Exclude sessions where you abandoned the task or Claude's output was not used. This is your true cost of productivity.

Export to CSV for spreadsheet analysis:

```bash
npx ccusage --from 2026-03-01 --to 2026-03-31 --format csv > ~/claude-costs/march-2026.csv
```

## Step 4: Automate the Monthly Report

Create a script that generates the report on the first of each month:

Create `~/scripts/claude-monthly-audit.sh`:

```bash
#!/bin/bash
LAST_MONTH=$(date -v-1m +%Y-%m)
FIRST_DAY="${LAST_MONTH}-01"
LAST_DAY=$(date -v-1d +%Y-%m-%d)

mkdir -p ~/claude-costs

npx ccusage --from "$FIRST_DAY" --to "$LAST_DAY" --format json > ~/claude-costs/"${LAST_MONTH}.json"
npx ccusage --from "$FIRST_DAY" --to "$LAST_DAY" > ~/claude-costs/"${LAST_MONTH}.txt"

echo "Claude Code cost report for ${LAST_MONTH} saved to ~/claude-costs/"
```

```bash
chmod +x ~/scripts/claude-monthly-audit.sh
```

Schedule with cron (run on the 1st of each month at 10 AM):

```bash
echo "0 10 1 * * ~/scripts/claude-monthly-audit.sh" | crontab -
```

## Step 5: Act on Findings

Based on your audit, implement optimizations:

**If input tokens are high**: Trim your CLAUDE.md, reduce the number of MCP servers loaded, or break large files into smaller modules.

**If output tokens are high**: Write more specific prompts. Instead of "implement the feature," specify exactly what you want.

**If certain projects cost disproportionately**: Evaluate whether those projects need Claude Code or if the tasks could be done faster manually.

**If costs are increasing month-over-month**: Identify what changed — new projects, more complex tasks, or workflow inefficiency.

## Building a Cost Optimization Habit

Monthly auditing works best as part of a broader cost optimization cycle:

**Week 1**: Generate the monthly report and identify the top 3 most expensive sessions.

**Week 2**: Investigate those sessions. What were you working on? Were the high costs justified (complex feature) or wasteful (debugging loop, over-broad prompts)?

**Week 3**: Implement one optimization based on your findings. Common ones:
- Trim your CLAUDE.md if input tokens are high
- Write more specific prompts if output tokens are high
- Remove unused MCP servers if context is bloated
- Use `/compact` more frequently in long sessions

**Week 4**: Compare this week's costs with the same week last month to verify the optimization helped.

## Setting Cost Budgets

Use monthly data to set project budgets:

```bash
# Calculate average weekly cost for a project
npx ccusage --project my-app --from 2026-03-01 --to 2026-03-31 --format json | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Total: \${sum(s[\"cost\"] for s in d):.2f}, Weekly avg: \${sum(s[\"cost\"] for s in d)/4:.2f}')"
```

If your average weekly cost is $15, budget $20/week to account for occasional complex sessions. If a week exceeds $30, investigate before the month-end surprises you.

## Multi-Project Cost Allocation

If you work on multiple projects, monthly auditing helps allocate costs:

```bash
# Cost per project for the month
npx ccusage --from 2026-03-01 --to 2026-03-31 --format csv > /tmp/costs.csv
# Group by project in a spreadsheet or with a script
```

This data is valuable for:
- Client billing (if you pass AI costs through)
- Team budget allocation
- Identifying which projects benefit most from Claude Code
- Justifying Claude Code costs to management

## Troubleshooting

**No data for recent sessions**: ccusage reads log files after sessions end. Ensure you have closed recent sessions before generating the report. Sessions still in progress may not have complete log files.

**Cost seems inaccurate**: ccusage uses published API rates. If you are on Claude Max, the numbers represent API-equivalent costs, not your actual subscription cost. They are still useful for relative comparison between sessions and projects.

**Cron job does not run**: Check cron logs. On macOS, you may need to use launchd instead. Verify the script path is absolute and the user has the correct PATH set (cron runs with a minimal environment).

**Reports show zero cost**: Verify that Claude Code JSONL logs exist in `~/.claude/projects/`. If the directory is empty, Claude Code may be configured to store logs elsewhere.

## Next Steps

- Learn [daily cost tracking](/how-to-track-claude-code-costs-ccusage-2026/) for real-time awareness
- Compare ccusage with [the Claude Max dashboard](/ccusage-vs-claude-max-dashboard-cost-tracking-2026/)
- Explore [cost-saving tools](/best-claude-code-cost-saving-tools-2026/) for the full optimization toolkit
- Read [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for workflow efficiency

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
