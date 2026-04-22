---
title: "The Compaction Strategy: When to /compact and When Not To"
description: "Master Claude Code /compact timing to reduce context by 60-80% without losing critical information -- includes decision rules and compaction cadence formulas."
permalink: /compaction-strategy-when-compact-when-not/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# The Compaction Strategy: When to /compact and When Not To

## The Pattern

The `/compact` command summarizes the conversation history, reducing context by 60-80%. Strategic compaction at the right moments prevents context bloat while preserving critical information. The wrong compaction timing either wastes tokens (compacting too late) or loses task context (compacting mid-task). The pattern: compact between tasks, not during them.

## Why It Matters for Token Cost

Every turn in Claude Code re-sends the entire conversation context as input tokens. A session at 150K tokens costs $2.25/turn in input alone at Opus rates ($15/MTok). After compaction to 40K tokens, each turn costs $0.60 -- a 73% reduction. Over the remaining 10 turns of a session, compaction saves $16.50 in input costs.

The timing decision matters because compaction is irreversible within a session. Information lost during compaction cannot be recovered without re-reading files or re-running commands, which costs tokens.

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern 1: Never compacting
# Session grows from 20K to 200K tokens over 25 turns
# Total input cost: sum of 20K, 28K, 36K, ..., 200K = ~2.75M tokens
# Cost at Opus: $41.25

# Anti-pattern 2: Compacting mid-task
# Agent is debugging a complex issue, has read 5 files and identified a pattern
/compact
# Post-compaction: agent loses file contents and must re-read them
# Re-read cost: 5 files * 2,000 tokens = 10,000 tokens (wasted, already read once)

# Anti-pattern 3: Compacting too frequently
# After every 3 exchanges, even when context is only 30K
/compact
# Overhead: compaction itself costs tokens (summarization output)
# Loss: recent context is still relevant and gets unnecessarily compressed
```

## The Pattern in Action

### Step 1: Establish Compaction Triggers

Define clear rules for when to compact, based on context size and task boundaries.

```yaml
# CLAUDE.md -- compaction strategy
## Compaction Rules
- Compact BETWEEN tasks (never in the middle of an active investigation)
- Compact when context exceeds 80K tokens (check with /cost)
- Compact after completing a feature, bug fix, or review (natural task boundary)
- Before starting a new, unrelated task in the same session
- After receiving large tool outputs that are no longer needed

## Do NOT Compact When:
- Actively debugging (file contents in context are needed)
- Awaiting test results that will inform the next step
- In the middle of a multi-file refactoring
- Context is under 40K tokens (compaction overhead exceeds savings)
```

### Step 2: Use Focus Directives

The `/compact` command accepts an optional focus directive that tells the summarizer what to preserve and what to discard.

```bash
# Basic compaction (the summarizer decides what to keep)
/compact

# Focus-directed compaction (better results, less information loss)
/compact Keep: current task (adding rate limiting to upload endpoint), files already identified (src/middleware/rate-limit.ts, src/routes/upload.ts), test results from last run. Discard: initial project exploration, package.json contents, dead-end approaches.

# Task-boundary compaction (preserve outcomes, discard process)
/compact Keep: completed tasks and their outcomes, current file structure understanding, active bug description. Discard: file contents already edited, command outputs already processed, exploration paths that were abandoned.
```

Focus-directed compaction produces approximately 15-20% better context preservation compared to undirected compaction, based on fewer re-read operations needed post-compaction.

### Step 3: Measure and Adjust

```bash
# Before compaction: measure context size
/cost
# Input tokens: 120,000

# After compaction: verify reduction
/cost
# Input tokens: 35,000 (71% reduction)

# If reduction is under 50%, the session had mostly essential context
# Consider starting a fresh session instead of compacting

# Track compaction effectiveness over time:
# Record: pre-compact size, post-compact size, re-reads needed after compaction
```

## Before and After

| Metric | No Compaction | Compaction at 80K | Over-Compaction (every 3 turns) |
|--------|--------------|-------------------|---------------------------------|
| Average context size | 100K-200K | 40K-80K | 20K-40K |
| Input cost per turn (Opus) | $1.50-$3.00 | $0.60-$1.20 | $0.30-$0.60 |
| Information loss | None | Minimal (with focus directives) | Moderate (recent context lost) |
| Re-read overhead | None | 0-2,000 tokens | 5,000-10,000 tokens |
| 20-turn session total | $30-$60 input | $12-$24 input | $6-$12 input + $3-$6 re-reads |
| **Net session cost** | **$30-$60** | **$12-$24** | **$9-$18** |

The optimal strategy (compaction at 80K) saves 50-60% compared to no compaction while avoiding the re-read penalties of over-compaction.

## When to Use This Pattern

- Sessions longer than 10 turns where context exceeds 80K tokens
- After completing a task and before starting the next task in the same session
- Before complex operations that will generate large tool outputs (make room in the context window)
- When switching topics or modules within a session

## When NOT to Use This Pattern

- Sessions under 10 turns or under 60K tokens (the compaction overhead exceeds savings)
- When every piece of context is currently relevant to the active task
- When the session is nearly complete (1-2 turns remaining, compaction overhead is not recovered)

## Implementation in CLAUDE.md

```yaml
# CLAUDE.md -- compaction protocol
## Compaction Protocol
1. Check /cost every 10 exchanges
2. If context > 80K tokens AND a task just completed: run /compact with focus directive
3. Focus directive template: "Keep: {current task}, {key file paths}, {recent test results}. Discard: {exploration}, {processed outputs}, {abandoned approaches}."
4. After compaction, verify with /cost that context dropped below 50K
5. If post-compaction context is still above 60K, consider starting a fresh session
6. Never compact during active debugging or mid-refactoring
```

## Related Guides

- [Claude Code Compact Command Guide](/claude-code-compact-command-guide/) -- detailed /compact mechanics and options
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- broader context management strategies
- [Context Engineering for Claude Code](/context-engineering-claude-code-complete-guide-2026/) -- compaction as part of the context engineering framework
