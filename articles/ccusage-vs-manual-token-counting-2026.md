---
title: "ccusage vs Manual Token Counting (2026)"
description: "ccusage parses Claude Code JSONL logs automatically. Manual counting uses tiktoken or the API response. Compare accuracy and effort for cost tracking."
permalink: /ccusage-vs-manual-token-counting-2026/
last_tested: "2026-04-22"
---

# ccusage vs Manual Token Counting (2026)

Tracking what Claude Code costs you requires counting tokens. You can do this manually by parsing API responses or log files, or you can let ccusage automate it. Here is why the manual approach rarely makes sense.

## Quick Verdict

**ccusage** automates everything — parsing, calculation, reporting — in one command. **Manual counting** gives you maximum control but at 10-50x the effort. Unless you have a very specific custom analysis need, use ccusage.

## Feature Comparison

| Feature | ccusage | Manual Token Counting |
|---|---|---|
| Setup | `npx ccusage` | Write parsing scripts |
| Data Source | ~/.claude/projects/ JSONL | Same logs or API responses |
| Token Breakdown | Input, output, cache read, cache write | Whatever you parse |
| Cost Calculation | Automatic (published rates) | You apply rates manually |
| Per-Session Detail | Yes | If your script handles it |
| Per-Project Grouping | Yes | If your script handles it |
| Historical Analysis | All available logs | As far as your scripts go |
| Export Formats | JSON, CSV | Whatever you build |
| Maintenance | Auto-updated via npx | You maintain your scripts |
| Time to First Result | 10 seconds | Hours to days |

## The Manual Approach

Manual token counting means writing scripts to parse Claude Code's JSONL log files. Each file contains message objects with token counts in the `usage` field. A basic approach:

```python
import json
import glob

total_input = 0
total_output = 0

for log_file in glob.glob("~/.claude/projects/**/*.jsonl", recursive=True):
    with open(log_file) as f:
        for line in f:
            msg = json.loads(line)
            if "usage" in msg:
                total_input += msg["usage"].get("input_tokens", 0)
                total_output += msg["usage"].get("output_tokens", 0)

# Apply rates
cost = (total_input / 1_000_000 * 3.00) + (total_output / 1_000_000 * 15.00)
print(f"Estimated cost: ${cost:.2f}")
```

This basic script takes 30 minutes to write and debug. But it does not handle cache tokens, does not group by project or session, does not handle rate changes, and does not format output nicely. A production-quality version takes a full day.

## The ccusage Approach

```bash
npx ccusage
```

Done. In 10 seconds, you see a formatted table with every session, every project, input/output/cache tokens, and cost estimates. No scripting, no debugging, no maintenance.

ccusage handles all the edge cases your manual script would need to handle:
- Cache read vs cache write token separation
- Rate changes across model versions
- Session boundaries within log files
- Project directory mapping
- Date range filtering

## When Manual Makes Sense

There are legitimate reasons to parse logs manually:

**Custom metrics** — If you need metrics that ccusage does not support (e.g., tokens per tool call, average message length, tool usage frequency), you need custom parsing.

**Integration with other systems** — If you want to feed token data into a custom dashboard, billing system, or monitoring platform, a custom pipeline gives you control over the data format and delivery.

**Learning** — Parsing the JSONL files yourself teaches you how Claude Code works internally. You see the message structure, tool call patterns, and token distribution. Educational, even if ccusage is more practical.

For most developers tracking [Claude Code costs](/karpathy-skills-vs-claude-code-best-practices-2026/), ccusage covers 95% of needs without any custom code.

## Accuracy Comparison

Both approaches use the same source data (JSONL logs), so raw token counts are identical. The difference is in cost calculation:

ccusage applies the correct rates for each model and token type. It stays updated as Anthropic adjusts pricing. Manual scripts use whatever rates you hardcoded — if you forget to update after a price change, your calculations drift.

## When To Use Each

**Choose ccusage when:**
- You want cost tracking with zero effort
- You need per-session and per-project breakdowns
- You want automatically updated rate calculations
- You need quick answers, not custom analysis

**Choose manual counting when:**
- You need custom metrics beyond cost
- You are building a data pipeline for token analytics
- You want to integrate cost data into another system
- You want to learn how Claude Code log files are structured

## Final Recommendation

Install ccusage and use it for all standard cost tracking. If you later need custom analysis that ccusage does not support, write targeted scripts for those specific metrics while keeping ccusage for the routine work. The time investment difference is enormous: 10 seconds vs a full day, with ccusage being more accurate and maintainable. See also the [hooks guide](/understanding-claude-code-hooks-system-complete-guide/) for patterns that can log additional cost-relevant data during sessions.
