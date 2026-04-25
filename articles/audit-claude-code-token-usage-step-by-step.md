---
title: "How to Audit Your Claude Code Token"
description: "Audit Claude Code token usage with step-by-step instructions using /cost, ccusage, and session logs to identify waste and cut spending by 30-50%."
permalink: /audit-claude-code-token-usage-step-by-step/
date: 2026-04-22
last_tested: "2026-04-22"
---

# How to Audit Your Claude Code Token Usage (Step-by-Step)

## The Problem

Most Claude Code users have no idea where their tokens go. A developer spending $200/month on API usage might assume it is spread evenly across tasks, when in reality 60-70% of the cost comes from 10-15% of sessions -- typically retry loops, large file reads, and runaway subagents. Without auditing, optimization is guesswork. With auditing, targeted fixes can cut monthly spending by 30-50% ($60-$100 on a $200/month budget).

## Quick Wins (Under 5 Minutes)

1. **Run `/cost` right now** in any active session to see current token usage.
2. **Install ccusage:** `npm install -g ccusage` for historical usage analysis.
3. **Check your Anthropic dashboard** at console.anthropic.com for billing trends.
4. **Set `CLAUDE_CODE_MAX_TURNS=25`** to prevent the worst-case sessions while auditing.

## Deep Optimization Strategies

### Strategy 1: Real-Time Session Monitoring with /cost

The `/cost` command shows current session token usage and estimated cost.

```bash
# Run at any point during a session
/cost

# Example output:
# ┌─────────────────────────────┐
# │ Session Cost Summary        │
# │ Input tokens:  127,443      │
# │ Output tokens:  34,891      │
# │ Model: claude-sonnet-4-6    │
# │ Input cost:  $0.38          │
# │ Output cost: $0.52          │
# │ Total: $0.90                │
# └─────────────────────────────┘
```

**Audit protocol:** Run `/cost` at three points in every session:
1. After initial context load (baseline)
2. After completing the main task (working cost)
3. Before ending the session (total cost)

This reveals the cost distribution: if 70% of tokens are consumed before the main task, context loading is the bottleneck. If 70% are consumed during the task, tool usage optimization matters more.

### Strategy 2: Historical Analysis with ccusage

```bash
# Install ccusage
npm install -g ccusage

# View last 7 days of usage
ccusage --period week

# View usage by model
ccusage --period month --model all

# View usage by project directory
ccusage --period month --by-project

# Example output:
# Period: 2026-04-15 to 2026-04-22
# Total input tokens:  12,847,332
# Total output tokens:  3,291,445
# Estimated cost (Sonnet): $38.54 input + $49.37 output = $87.91
#
# Top 5 sessions by cost:
# 1. /project/api - Apr 18 - 2.1M tokens - $14.23
# 2. /project/api - Apr 17 - 1.8M tokens - $12.19
# 3. /project/web - Apr 19 - 987K tokens - $6.68
# 4. /project/api - Apr 20 - 834K tokens - $5.65
# 5. /project/web - Apr 16 - 721K tokens - $4.88
```

**Key insight:** The top 5 sessions account for $43.63 of the $87.91 total (49.6%). Optimizing or preventing these high-cost sessions has more impact than optimizing the remaining 50+ sessions.

### Strategy 3: The Token Audit Spreadsheet Method

Create a systematic audit over 5 business days.

```markdown
# Token Audit Template

| Date | Session | Task Description | Input Tokens | Output Tokens | Cost | Model | Notes |
|------|---------|-----------------|-------------|---------------|------|-------|-------|
| 4/22 | 1 | Fix auth bug | 45K | 12K | $0.31 | Sonnet | Clean session |
| 4/22 | 2 | Add rate limiting | 187K | 51K | $1.33 | Sonnet | Retry loop on test |
| 4/22 | 3 | Update README | 23K | 8K | $0.19 | Sonnet | Simple task |
| 4/22 | 4 | Debug deploy | 312K | 87K | $2.24 | Sonnet | Read too many files |
```

After 5 days, categorize sessions into:
- **Clean sessions** (under 100K tokens): working well, no changes needed
- **Moderate sessions** (100K-300K tokens): review for optimization opportunities

For more on this topic, see [Claude Code for Hoppscotch](/claude-code-for-hoppscotch-workflow-guide/).

For more on this topic, see [Claude Code for Automotive ECU AUTOSAR](/claude-code-automotive-ecu-autosar-2026/).


For more on this topic, see [Claude Code for PocketBase](/claude-code-for-pocketbase-workflow-guide/).


- **Expensive sessions** (300K+ tokens): investigate root cause

### Strategy 4: Identifying the Top Token Consumers

The most common cost centers, in order:

```bash
# 1. Context accumulation (40% of waste)
# Symptom: /cost shows 200K+ input tokens by mid-session
# Fix: /compact more frequently

# 2. Retry loops (25% of waste)
# Symptom: Same file edited 3+ times, same test run 3+ times
# Fix: 3-strike rule in CLAUDE.md

# 3. Large file reads (20% of waste)
# Symptom: Reading files with 500+ lines
# Fix: .claudeignore, grep-first strategy

# 4. Subagent overhead (10% of waste)
# Symptom: Multiple subagents spawned for simple tasks
# Fix: Subagent caps in CLAUDE.md

# 5. Model mismatch (5% of waste)
# Symptom: Opus used for simple tasks
# Fix: Default to Sonnet, Opus only for complex work
```

### Strategy 5: Setting Up Ongoing Monitoring

```bash
# Add to .zshrc or .bashrc for persistent monitoring
export CLAUDE_CODE_MAX_TURNS=25

# Create a daily audit alias
alias claude-audit='ccusage --period day --model all'

# Create a weekly summary alias
alias claude-weekly='ccusage --period week --by-project'
```

```markdown
# CLAUDE.md -- add monitoring awareness

## Cost Awareness
- Report token count after completing each major task
- If a single task exceeds 100K input tokens, pause and report why
- Run /compact when context exceeds 100K tokens
```

## Measuring Your Savings

After implementing audit findings, track week-over-week:

```bash
# Week 1 (baseline)
ccusage --period week
# Total: $87.91

# Week 2 (after applying fixes)
ccusage --period week
# Total: $52.74 (40% reduction)

# Week 3 (optimizations bedding in)
ccusage --period week
# Total: $45.23 (48.5% reduction from baseline)
```

## Cost Impact Summary

| Audit Finding | Typical Waste | Savings After Fix |
|---------------|-------------|-------------------|
| Context accumulation | 40% of tokens | 50-70% with /compact |
| Retry loops | 25% of tokens | 60% with 3-strike rule |
| Large file reads | 20% of tokens | 80% with .claudeignore |
| Subagent overhead | 10% of tokens | 50% with caps |
| Model mismatch | 5% of tokens | 80% with model routing |
| **Combined** | **$200/month baseline** | **$100-$140/month after** |

The audit itself takes about 2 hours to set up and 15 minutes per day for a week. The ROI is typically $60-$100/month in perpetual savings -- a payback period under 1 week.

## Building an Audit Culture

The audit is most effective when it becomes a team habit rather than a one-time event. Implement these practices:

### Daily Check (30 seconds)

Run `/cost` at the end of each session and note whether it was within the expected budget for the task type. No logging required -- just awareness.

### Weekly Summary (5 minutes)

```bash
# Run the weekly summary
ccusage --period week

# Compare to last week
# Is total trending up, down, or flat?
# Any single session above $5? (investigate these)
```

### Monthly Deep Audit (30 minutes)

```bash
# Full monthly breakdown
ccusage --period month --by-project --model all

# Key questions:
# 1. Which project consumed the most tokens? Why?
# 2. What percentage of usage was Opus vs Sonnet?
# 3. Were there any sessions over 1M tokens? What happened?
# 4. Is the per-task average trending up or down?
```

### Quarterly Optimization Review (2 hours)

Review all cost control mechanisms:
- CLAUDE.md: still accurate? Under 400 tokens?
- .claudeignore: covers new directories?
- Skills: up to date with current codebase?
- Environment variables: appropriate limits?
- Team adherence: any developers consistently over budget?

## Interpreting Audit Data

### Healthy Metrics

| Metric | Healthy Range | Action if Outside |
|--------|-------------|-------------------|
| Per-task tokens (bug fix) | 20K-40K | Check for retry loops |
| Per-task tokens (feature) | 60K-120K | Check for scope creep |
| Sonnet/Opus ratio | 80%/20% or higher Sonnet | Review model routing |
| Sessions over 500K | Less than 5% | Add turn limits |
| Week-over-week trend | Flat or declining | If rising, audit immediately |

### Red Flags

- **Sudden 2x cost increase:** Usually indicates a new team member without training, a project structure change that invalidated CLAUDE.md, or a new dependency that generates verbose errors.

- **Consistently high Opus usage:** Developers may have changed their default model or are not aware of the cost difference. Remind: Opus is 5x more expensive than Sonnet.

- **Single-day spikes:** Almost always a retry loop or runaway session. Find the specific session, understand what went wrong, and add a CLAUDE.md rule to prevent recurrence.

## Audit Tools Comparison

| Tool | Cost | Features | Best For |
|------|------|----------|----------|
| /cost (built-in) | Free, 0 tokens | Real-time session data | During-session monitoring |
| ccusage | Free (npm) | Historical, per-project, per-model | Weekly/monthly analysis |
| Anthropic Dashboard | Free (web) | Billing data, API key breakdown | Budget tracking, invoicing |
| Custom hooks | Free (setup time) | Real-time alerts, custom logic | Team-specific automation |

Use all four in combination: /cost for real-time awareness, ccusage for historical analysis, the Anthropic Dashboard for billing, and custom hooks for automated alerts. Starting with just `/cost` and upgrading to the full stack as spending grows ensures the audit effort matches the scale of the spend.

## Related Guides

- [Claude Code Cost Optimization: 15 Techniques That Actually Work](/claude-code-cost-optimization-15-techniques/) -- apply findings from audit
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- the top fix for context accumulation
- [Cost Optimization Hub](/cost-optimization/) -- all cost guides

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

- [Claude Code router guide](/claude-code-router-guide/) — How Claude Code's model router selects between Haiku, Sonnet, and Opus

## See Also

- [Monitoring Claude Code Token Usage with Custom Hooks](/monitoring-claude-code-token-usage-custom-hooks/)
