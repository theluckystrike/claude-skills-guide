---
layout: default
title: "Claude Code Dashboard (2026)"
description: "Use Claude Code's built-in /cost command and dashboard to monitor token usage, track session spend, and identify wasteful patterns in real time."
permalink: /claude-code-dashboard-built-in-usage-monitoring/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Dashboard: Built-In Usage Monitoring Explained

## What It Does

Claude Code includes built-in usage monitoring through the `/cost` command that displays real-time token consumption, cost estimates, and cache efficiency metrics for the current session. This is the first line of defense against runaway token spend, giving immediate feedback that prevents a $2 session from becoming a $20 session.

## Installation / Setup

No installation required. The `/cost` command is built into Claude Code and available in every session.

```bash
# Verify /cost is available (it always is)
# Simply type in any Claude Code session:
/cost

# For historical tracking across sessions, install ccusage:
npm install -g ccusage
```

## Configuration for Cost Optimization

The built-in dashboard does not have configuration options, but its effectiveness depends on how frequently it is checked. Encode monitoring cadence in CLAUDE.md:

```yaml
# CLAUDE.md -- monitoring discipline
## Cost Monitoring
- Run /cost every 10 exchanges
- If session cost exceeds $2, evaluate whether to compact or start fresh
- If cache read ratio is below 50%, investigate why prompt caching is not being used
- Log anomalous sessions (>$5) for pattern review
```

## Usage Examples

### Basic Usage

```bash
# Check current session costs
/cost

# Typical output:
# Session Cost Summary
# ──────────────────────
# Input tokens:    45,230 ($0.68 at Opus)
# Output tokens:   12,100 ($0.91 at Opus)
# Cache read:      28,000 tokens (saved $0.42)
# Cache write:      8,500 tokens
# Total cost:      $1.59
# Turns:           12
```

The output breaks down input tokens (conversation context re-sent each turn), output tokens (agent responses), and cache metrics. Cache reads indicate tokens served from Anthropic's prompt cache at reduced cost.

### Advanced: Cost-Per-Task Tracking

Use `/cost` at task boundaries to measure the cost of individual tasks within a session.

```bash
# Before starting a task, note the current cost
/cost
# Total: $0.45

# Complete the task...
# "Add rate limiting to the /api/upload endpoint"

# After the task, check again
/cost
# Total: $1.23

# Task cost: $1.23 - $0.45 = $0.78
# Record this for your task-cost database
```

For team-level tracking over time:

```bash
# View 7-day usage history
ccusage --days 7

# View with model breakdown
ccusage --days 30 --format table

# Export to JSON for dashboards
ccusage --days 30 --format json > usage-$(date +%Y%m%d).json
```

## Token Usage Measurements

The `/cost` command itself costs zero additional tokens -- it reads from local session state. The ccusage tool reads from local log files and makes no API calls.

| Monitoring Action | Token Cost | Dollar Cost |
|------------------|------------|-------------|
| /cost command | 0 tokens | $0.00 |
| ccusage report | 0 tokens (local read) | $0.00 |
| Manual /cost every 10 turns | 0 tokens | $0.00 |

## Comparison with Alternatives

| Feature | Built-in /cost | ccusage | Anthropic Console | Custom Dashboard |
|---------|---------------|---------|-------------------|-----------------|
| Real-time session data | Yes | No (historical) | Delayed (~1 hr) | Depends |
| Per-session breakdown | Yes | Yes | Aggregate only | Depends |
| Cost per model | Yes | Yes | Yes | Yes |
| Team aggregation | No | No | Yes | Yes |
| Alerting | No | No | Yes | Yes |
| Setup required | None | npm install | Account access | Engineering time |

For individual developers, `/cost` plus ccusage covers all monitoring needs. Teams needing aggregation and alerts should supplement with the Anthropic Console.

## Troubleshooting

**`/cost` shows unexpectedly high token counts** -- Check for large file reads or verbose tool outputs earlier in the session. Run `/compact` to reduce context, then verify the cost stabilizes on subsequent turns.

**ccusage shows no data** -- Ensure Claude Code is writing usage logs. Check `~/.claude/usage/` for log files. If empty, verify the Claude Code version supports usage logging.

**Cache read ratio is 0%** -- Prompt caching activates when the same context prefix is sent across multiple turns in a session. Very short sessions (1-2 turns) may not benefit from caching. This is normal behavior, not a configuration issue.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Token Budget: How to Set Limits and Track Spend](/claude-code-token-budget-set-limits-track-spend/) -- budget enforcement using monitoring data
- [Claude Code Cost Alerts: Set Up Notifications](/claude-code-cost-alerts-notifications-budget/) -- automated alerts when spend exceeds thresholds


## Common Questions

### How do I get started with claude code dashboard?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code for Appsmith Dashboard](/claude-code-for-appsmith-dashboard-workflow-guide/)
- [Claude Code Grafana Dashboard](/claude-code-grafana-dashboard-configuration-workflow-tips/)
- [Claude Code Kpi Dashboard](/claude-code-kpi-dashboard-implementation-guide/)
