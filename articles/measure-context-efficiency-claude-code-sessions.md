---
title: "How to Measure Context Efficiency (2026)"
description: "Measure context efficiency in Claude Code sessions using token-per-task ratios, waste metrics, and /cost data to identify and eliminate hidden token drains."
permalink: /measure-context-efficiency-claude-code-sessions/
date: 2026-04-22
last_tested: "2026-04-22"
---

# How to Measure Context Efficiency in Claude Code Sessions

## What This Means for Claude Code Users

Context efficiency is the ratio of useful tokens (those that directly contribute to task completion) to total tokens consumed. Most Claude Code sessions operate at 20-40% context efficiency, meaning 60-80% of tokens are spent on exploration, redundant reads, and accumulated stale context. Measuring context efficiency reveals exactly where tokens are wasted and which optimizations will have the largest impact. Improving from 30% to 60% efficiency halves the cost of every session -- a $200/month spend drops to $100/month.

## The Concept

Context efficiency borrows from the concept of signal-to-noise ratio. In a Claude Code session:

- **Signal tokens:** file reads that lead to successful edits, commands that verify changes, direct task execution
- **Noise tokens:** exploratory reads of irrelevant files, retry loop tokens, stale context from earlier tasks, tool overhead on unnecessary operations

The efficiency formula is:

```
Context Efficiency = Signal Tokens / Total Tokens x 100
```

A session that consumes 100K tokens but only needs 30K to complete the task has 30% efficiency. The remaining 70K tokens are the cost of poor context engineering.

Measuring efficiency requires tracking tokens at the task level, not just the session level. A session might show 80K total tokens, but without knowing that the task should have taken 25K, the waste is invisible.

## How It Works in Practice

### Example 1: Per-Task Token Benchmarking

Establish token budgets for common task types:

```markdown
# .claude/skills/token-benchmarks.md

## Expected Token Budgets (Sonnet 4.6)
| Task Type | Target Input | Target Output | Total Budget |
|-----------|-------------|---------------|-------------|
| Simple bug fix (1 file) | 15K-25K | 5K-10K | 20K-35K |
| Feature addition (2-3 files) | 40K-80K | 15K-30K | 55K-110K |
| Refactoring (5+ files) | 80K-150K | 30K-60K | 110K-210K |
| Test writing (1 test file) | 20K-40K | 10K-20K | 30K-60K |
| Config change | 10K-15K | 3K-5K | 13K-20K |
| Documentation update | 15K-25K | 8K-15K | 23K-40K |

## Red Flags
- Any task exceeding 2x its budget -> investigate
- Any task exceeding 3x its budget -> likely retry loop
```

Use these benchmarks with `/cost`:

```bash
# Start a simple bug fix
"Fix the null check in src/auth/validate.ts line 34"

# Check midway
/cost
# Input: 18,432 / Output: 4,221
# On track for 20K-35K budget

# Check at completion
/cost
# Input: 27,891 / Output: 9,443
# Total: 37,334 -- slightly over budget, acceptable

# Compare against a poor session:
/cost
# Input: 142,887 / Output: 31,222
# Total: 174,109 -- 5x budget, investigate why
```

### Example 2: The Efficiency Audit Protocol

Run this protocol for 5 consecutive working days to establish baseline efficiency:

```bash
# Step 1: Before each task, note the /cost baseline
/cost
# Record: baseline_input = 12,000 (from session startup)

# Step 2: Complete the task

# Step 3: After each task, record the delta
/cost
# Record: current_input = 47,000
# Task cost: 47,000 - 12,000 = 35,000 input tokens

# Step 4: Estimate the minimum viable token count
# (How many tokens SHOULD this have taken?)
# Simple bug fix = ~20K minimum viable
# Efficiency: 20,000 / 35,000 = 57%

# Step 5: Log it
echo "2026-04-22,bug-fix,35000,20000,57%" >> ~/claude-efficiency.csv
```

After 5 days, analyze the CSV:

```bash
# Average efficiency across all tasks
awk -F',' '{sum+=$5; count++} END {printf "Average efficiency: %.0f%%\n", sum/count}' \
    ~/claude-efficiency.csv

# Worst offenders
sort -t',' -k5 -n ~/claude-efficiency.csv | head -5
```

## Token Cost Impact

Improving context efficiency from a typical 30% to an achievable 60% yields direct cost savings:

| Metric | Before (30% efficient) | After (60% efficient) |
|--------|----------------------|----------------------|
| Average session tokens | 150K | 75K |
| Sessions per day | 5 | 5 |
| Daily input tokens | 750K | 375K |
| Monthly input tokens | 16.5M | 8.25M |
| Monthly input cost (Sonnet) | $49.50 | $24.75 |
| Monthly input cost (Opus) | $247.50 | $123.75 |
| **Monthly savings (Sonnet)** | | **$24.75** |
| **Monthly savings (Opus)** | | **$123.75** |

The measurement process itself costs negligible tokens -- `/cost` is a local command that does not consume API tokens. The audit protocol adds approximately 30 seconds per task.

## Implementation Checklist

- [ ] Create token benchmarks for the 5 most common task types in the project
- [ ] Store benchmarks in `.claude/skills/token-benchmarks.md`
- [ ] Run `/cost` before and after each task for 5 days
- [ ] Log results in a CSV with columns: date, task-type, actual-tokens, target-tokens, efficiency
- [ ] Calculate average efficiency after the audit period
- [ ] Identify the bottom 20% of sessions by efficiency
- [ ] Apply targeted fixes (usually: /compact, .claudeignore, retry limits)
- [ ] Re-measure after 1 week to verify improvement

## The CCG Framework Connection

Context efficiency measurement is the feedback loop that validates all other cost optimizations. Without measurement, optimizations are applied blindly. The [Cost Optimization Hub](/cost-optimization/) provides the techniques; this article provides the methodology to verify they are working and to prioritize which technique to apply next.

## Advanced: Efficiency by Task Phase

Context efficiency varies dramatically across task phases. Understanding this breakdown reveals where the largest optimization opportunities lie.

### Phase 1: Orientation (typically 20-40% of tokens, 5% of value)

Claude reads files to understand the project and task context. Most orientation tokens are noise -- files read but not directly relevant to the task.

**Target efficiency:** 60-80% (hard to achieve higher because some exploration is necessary)
**Optimization:** CLAUDE.md project map, skills pre-loading

### Phase 2: Implementation (typically 30-50% of tokens, 80% of value)

Claude makes changes, writes code, and edits files. This is where the useful work happens.

**Target efficiency:** 90%+ (nearly all tokens contribute to output)
**Optimization:** Specific prompts, scoped file access

### Phase 3: Verification (typically 15-25% of tokens, 10% of value)

Claude runs tests, builds, and checks the changes.

**Target efficiency:** 50-70% (test output often includes irrelevant passing tests)
**Optimization:** Targeted test commands, structured test output

### Phase 4: Retry/Correction (typically 10-30% of tokens, 5% of value)

Claude fixes issues found during verification. This is the highest-waste phase.

**Target efficiency:** 20-40% (most retry tokens are redundant context)
**Optimization:** 3-strike rule, structured errors, /compact after retries

### Phase Efficiency Dashboard

Track these metrics per session to identify which phase needs optimization:

```bash
# After each session, estimate phase breakdown:

# Orientation: tokens consumed before first Edit tool call
# Implementation: tokens consumed during Edit/Write operations
# Verification: tokens consumed during Bash (test/build) operations
# Retry: tokens consumed after a failed verification

# Quick formula:
# If orientation > 40% of total -> improve CLAUDE.md/skills
# If verification > 25% of total -> add structured test wrappers
# If retry > 20% of total -> add retry limits and error formatting
```

## Benchmarking Against Team Averages

For teams, context efficiency benchmarking enables peer learning. The most efficient developers on the team can share their patterns.

```markdown
# Weekly efficiency comparison (anonymized)

| Developer | Avg Tokens/Task | Avg Efficiency | Top Technique |
|-----------|----------------|----------------|---------------|
| Dev A | 32K | 72% | Skills + scoped prompts |
| Dev B | 48K | 55% | Good /compact usage |
| Dev C | 85K | 31% | Needs CLAUDE.md rules |
| Dev D | 41K | 64% | Model routing effective |

Team average: 51.5K tokens/task, 55.5% efficiency
Target: 40K tokens/task, 65% efficiency
```

Dev A's patterns should be documented and shared with Dev C. This peer learning approach is more effective than top-down mandates because it provides concrete, proven techniques.

## The Efficiency-Quality Tradeoff

A common concern: "If we optimize for fewer tokens, will quality suffer?" The data shows the opposite. Higher-efficiency sessions produce better outcomes because:

1. **Focused context = better decisions.** Claude makes better choices when the context is relevant, not bloated with irrelevant file reads.

2. **Fewer retries = cleaner code.** The 3-strike rule forces diagnostic thinking, which produces more correct fixes than random attempts.

3. **Smaller sessions = cleaner commits.** Session segmentation (one task per session) produces atomic commits instead of tangled multi-change sessions.

The efficiency-quality relationship is positive, not zero-sum. The techniques that save tokens also improve output quality.

This is the strongest argument for context efficiency measurement: it is not purely a cost exercise. Higher efficiency means better outputs, faster sessions, and more reliable results. Every team that measures context efficiency reports improvements on all three dimensions simultaneously.

## When to Stop Measuring

Context efficiency measurement has diminishing returns once a team consistently operates above 60% efficiency. At that point, the measurement overhead (30 seconds per task, weekly analysis) exceeds the marginal savings available. Shift from active measurement to passive monitoring: check weekly averages rather than per-task tracking, and only investigate when efficiency drops below 50% for three consecutive days. This transition from active optimization to maintenance mode prevents the measurement process itself from becoming overhead that slows down development.

## Further Reading

- [How to Audit Your Claude Code Token Usage (Step-by-Step)](/audit-claude-code-token-usage-step-by-step/) -- the full audit methodology
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- the top tool for improving efficiency mid-session
- [Cost Optimization Hub](/cost-optimization/) -- technique index
