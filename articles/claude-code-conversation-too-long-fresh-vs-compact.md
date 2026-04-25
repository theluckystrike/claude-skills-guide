---
layout: default
title: "Claude Code Conversation Too Long (2026)"
description: "Decide whether to /compact or start a fresh Claude Code session when conversations grow too long -- compact saves 60-80% but fresh sessions reset at zero cost."
permalink: /claude-code-conversation-too-long-fresh-vs-compact/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code conversation too long -- when to start fresh vs /compact

## The Problem

The Claude Code session has grown large -- 100K, 150K, or even 200K tokens. Every new message re-sends the entire context, costing $1.50-$3.00+ per turn at Opus 4.6 rates ($15/MTok input). Two options exist: `/compact` to compress the conversation by 60-80%, or start a fresh session at zero tokens. Choosing wrong wastes money: compacting when a fresh start is better preserves stale context, while starting fresh when compacting is better loses valuable task context.

## Quick Fix (2 Minutes)

Decision flowchart:

1. **Is the current task nearly done (1-3 more turns)?** --> Stay, finish, then start fresh for the next task.
2. **Is the current task ongoing and complex (5+ more turns needed)?** --> `/compact` with a focus directive.
3. **Is the session full of completed tasks with one new task starting?** --> Start fresh.
4. **Are there failed attempts polluting the context?** --> `/compact` to remove them.

```bash
# Check current state
/cost
# If over 100K tokens and task is done: start fresh
# If over 80K tokens and task is in progress: compact

# Compact with focus
/compact Keep: current task (refactoring payment module), files identified, test results. Discard: completed tasks, exploration, failed approaches.

# Or start fresh (exit and relaunch)
# Exit current session: Ctrl+C or type "exit"
# Start new: claude "Continue refactoring the payment module. Key files: src/payments/service.ts, src/payments/routes.ts. Last state: service refactored, routes pending."
```

## Why This Happens

Conversations grow long because:

1. **Multi-task sessions** -- completing 3-4 tasks in one session. Each task adds 20K-50K tokens of context that is irrelevant to subsequent tasks.
2. **Exploration phases** -- searching the codebase, reading multiple files, running discovery commands. These add 10K-30K tokens of one-time-use context.
3. **Verbose tool outputs** -- test results, build logs, and API responses that accumulate. A single test run can add 500-3,000 tokens.
4. **Failed attempts** -- debugging iterations that did not resolve the issue add tokens with no ongoing value.

The cost of an oversized context is not just the current turn -- it compounds. A 150K-token session with 10 remaining turns costs 1.5M tokens in input. After compaction to 50K, those 10 turns cost 500K tokens. **Savings: 1M tokens = $15 at Opus rates.**

## The Full Fix

### Step 1: Diagnose

```bash
# Check context size
/cost
# Note: input tokens, output tokens, total cost

# Decision matrix:
# Context > 100K + task complete     --> Start fresh
# Context > 80K + task in progress   --> Compact
# Context > 150K + any state         --> Compact immediately (nearing window limit)
# Context < 60K + any state          --> Continue (no action needed)
```

### Step 2: Fix

**Option A: Compact (preserve task state)**

```bash
# Best for: ongoing complex task, valuable context still needed
/compact Keep: {current task description}, {key file paths}, {recent test results}, {decisions made}. Discard: {completed unrelated tasks}, {exploration output}, {failed approaches}, {file contents already edited}.

# Verify
/cost
# Target: 30-50% of pre-compact size
```

**Option B: Start fresh (zero-cost reset)**

```bash
# Best for: completed task, switching to unrelated work, severely polluted context
# Exit current session
# Start new session with a focused context handoff:

claude "Task: implement rate limiting for /api/upload.
Context: Express.js app, TypeScript, src/middleware/ for middleware,
src/routes/upload.ts for the route. Use express-rate-limit package.
Tests in tests/middleware/."
```

The fresh start costs 200-500 tokens for the initial prompt instead of carrying 50K+ tokens of compacted context.

### Step 3: Prevent

```yaml
# CLAUDE.md -- conversation length management
## Session Management
- Check /cost every 10 exchanges
- If context exceeds 80K tokens and current task is complete: start a fresh session
- If context exceeds 80K tokens and current task is in progress: /compact with focus directive
- One major task per session (do not chain unrelated tasks)
- After completing a task: either start fresh or compact before the next task
```

## Cost Recovery

```text
Recovery calculation:

Pre-compact: 120K tokens, 10 turns remaining
  Remaining input cost: 120K * 10 / 1,000,000 * $15 = $18.00 (Opus)

After compact to 40K: 10 turns remaining
  Remaining input cost: 40K * 10 / 1,000,000 * $15 = $6.00 (Opus)
  Savings: $12.00

After fresh start at 5K: 10 turns remaining
  Remaining input cost: 5K * 10 / 1,000,000 * $15 = $0.75 (Opus)
  Savings: $17.25 (but risk losing context worth 2-3 tool calls = $0.50-$1.50)

Net: Fresh start saves $5.25 more than compact, but requires re-establishing context.
```

The break-even: if re-establishing context costs less than $5.25 in tokens (about 3 tool calls), a fresh start is cheaper. If the context is too complex to re-establish in 3 tool calls, compacting is safer.

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## Session Length Control
- One primary task per session
- Check /cost every 10 exchanges
- At 80K tokens: compact (if task ongoing) or start fresh (if task complete)
- At 120K tokens: compact immediately regardless of task state
- After every /compact: verify context dropped below 50K with /cost
- When starting a fresh session: include a 3-sentence context handoff in the first prompt
- Maximum session length: 30 exchanges (start fresh after 30, even if context is small)
```

## Related Guides

- [The Compaction Strategy: When to /compact and When Not To](/compaction-strategy-when-compact-when-not/) -- detailed compaction timing guide
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- full /compact reference
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- preventing oversized contexts in the first place

## See Also

- [CLAUDE.md Too Long? How to Split and Optimize for Context Window (2026)](/claude-md-too-long-fix/)
- [Conversation History OOM Crash Fix](/claude-code-conversation-history-oom-fix-2026/)
