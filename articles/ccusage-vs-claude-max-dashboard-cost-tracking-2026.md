---
title: "ccusage vs Claude Max Dashboard (2026)"
description: "ccusage tracks Claude Code costs from local JSONL logs. The Claude Max dashboard tracks usage online. Compare granularity, accuracy, and use cases."
permalink: /ccusage-vs-claude-max-dashboard-cost-tracking-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# ccusage vs Claude Max Dashboard for Cost Tracking (2026)

Knowing what Claude Code costs you is not optional once you move past the free tier. Two tools serve this need: ccusage, an open-source CLI that parses your local session logs, and the Claude Max subscription dashboard built into the Anthropic console. They measure different things in different ways.

## Quick Verdict

**ccusage** gives you granular, per-session, per-project cost breakdowns from local data. **Claude Max dashboard** gives you aggregate subscription usage and billing information. Use ccusage for optimization. Use the dashboard for accounting.

## Feature Comparison

| Feature | ccusage | Claude Max Dashboard |
|---|---|---|
| GitHub Stars | ~13K | N/A (Anthropic product) |
| Data Source | Local JSONL files | Server-side usage logs |
| Granularity | Per-session, per-project | Aggregate monthly |
| Install | `npx ccusage` | Built into console |
| Token Breakdown | Input/output/cache tokens | Total tokens used |
| Cost Calculation | Based on published rates | Subscription-based |
| Historical Data | As far back as your logs go | Current billing period |
| Export | JSON, CSV | Limited |
| Offline Access | Yes (local files) | No |
| Real-time | Parses after session ends | Near real-time |

## How ccusage Works

ccusage reads the JSONL log files that Claude Code writes to `~/.claude/projects/`. Every Claude Code session generates a log file containing every message, tool use, and token count. ccusage parses these files, calculates costs using the published Anthropic pricing, and presents the results.

Run it with no arguments to see a summary:

```bash
npx ccusage
```

This outputs a table showing each session's date, project, input tokens, output tokens, cache reads, cache writes, and estimated cost. You can filter by date range, project, or session ID.

The per-session granularity is the key advantage. You can identify which sessions burned through tokens and why. A session that used 500K input tokens probably had large file reads. A session with high output tokens probably generated a lot of code. This data helps you optimize your [Claude Code workflow](/karpathy-skills-vs-claude-code-best-practices-2026/).

## How Claude Max Dashboard Works

The Claude Max dashboard shows your subscription usage in the Anthropic console. For Max subscribers, it tracks how much of your monthly allocation you have consumed. For API users, it shows spend against your billing limits.

The dashboard is straightforward: a progress bar showing usage, a billing summary, and basic historical data. It tells you "you have used 60% of your monthly allocation" but does not tell you which projects or sessions consumed that 60%.

## Accuracy Differences

ccusage calculates costs from raw token counts using published pricing. This is accurate for API-billed usage but approximate for Max subscribers. If you are on Claude Max, the "cost" ccusage reports is what you would pay at API rates, not your actual subscription cost. Still useful for relative comparisons between sessions.

The dashboard shows your actual billing data but lacks the granularity to attribute costs to specific activities. You know what you spent but not where you spent it.

## Data Retention

ccusage works as long as you have the JSONL files. Claude Code stores these locally and does not automatically delete them. If you have been using Claude Code for months, you have months of cost data available.

The dashboard typically shows the current and recent billing periods. Historical data beyond a few months may not be accessible.

## Optimization Workflows

The real value of ccusage is optimization. When you notice a session cost more than expected, you can dig into the token breakdown. Common findings:

- Sessions with large `cache_read` tokens: Claude re-read large files repeatedly. Consider breaking files into smaller modules.
- Sessions with high `input` tokens: Your CLAUDE.md or context files are large. Trim them.
- Sessions with excessive `output` tokens: Claude generated code you did not need. Be more specific in your prompts.

The dashboard cannot support this kind of analysis. It is a billing tool, not an optimization tool.

For more strategies on reducing Claude Code costs, see the guide on [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) which can automate cost-saving patterns.

## When To Use Each

**Choose ccusage when:**
- You want to know exactly which sessions and projects cost the most
- You need to optimize token usage patterns
- You want offline access to historical cost data
- You need to export cost data for reporting

**Choose Claude Max Dashboard when:**
- You need to check your billing status
- You want to see remaining allocation for the month
- You need official billing records
- You are managing team seats and organization spending

**Use both when:**
- Use the dashboard for billing and accounting
- Use ccusage for optimization and per-project attribution

## Final Recommendation

Install ccusage today. It takes 10 seconds (`npx ccusage`), requires no configuration, and immediately shows you data you cannot get anywhere else. Use it weekly to review your spending patterns. Keep using the Claude Max dashboard for billing management. The two tools answer different questions — ccusage tells you *where* your tokens go, the dashboard tells you *what you owe*. Both answers matter.
