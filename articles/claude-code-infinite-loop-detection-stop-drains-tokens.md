---
title: "Claude Code Infinite Loop Detection"
description: "Detect and stop Claude Code infinite loops that drain 50K-200K tokens by recognizing the three loop patterns and adding CLAUDE.md circuit breakers."
permalink: /claude-code-infinite-loop-detection-stop-drains-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code infinite loop detection -- stop before it drains tokens

## The Problem

Claude Code is executing the same or similar operations repeatedly without making progress. This is not a 2-3 retry situation -- it is a sustained loop consuming 50K-200K tokens over 10-30 iterations. At Opus 4.6 rates, a 20-iteration loop costs $3-$15. The agent may be cycling through the same file edits, repeatedly running failing tests, or alternating between two approaches without converging on a solution.

## Quick Fix (2 Minutes)

1. **Press Escape or type "stop"** to interrupt immediately.
2. **Check the damage:** run `/cost` to see how many tokens were consumed.
3. **Compact:** run `/compact` to purge the loop iterations from context.
4. **Restate with explicit bounds:** "Attempt to fix the test failure in auth.test.ts. Make exactly ONE change and run the test ONCE. If it fails, stop and report the error."

```bash
# Interrupt
# Press Escape

# Assess damage
/cost

# Clean up
/compact Keep: the original task and the current error. Discard: all loop iterations.

# Restart with bounds
# "Fix auth.test.ts. ONE attempt only. If it fails, report the error and stop."
```

## Why This Happens

Three distinct loop patterns cause this behavior:

**Pattern 1: Edit-Run-Fail Loop**
The agent edits code, runs a test, it fails, the agent makes a similar edit, runs the test again. The edits are too small or too similar to resolve the underlying issue. Each cycle costs 3,000-8,000 tokens.

**Pattern 2: Alternating Approach Loop**
The agent tries approach A, encounters an error, switches to approach B, encounters a different error, switches back to approach A. The context accumulates both failed approaches, but the agent alternates between them indefinitely. Each full cycle costs 10,000-20,000 tokens.

**Pattern 3: Build-Deploy Loop**
The agent deploys, reads an error, modifies configuration, deploys again. Deployment takes 10-30 seconds, and the agent often does not read the full error before retrying. Each cycle costs 5,000-15,000 tokens.

All three patterns share a root cause: the agent lacks a stopping condition. Without explicit iteration bounds, the agent will continue attempting until the context window fills.

## The Full Fix

### Step 1: Diagnose

Identify which loop pattern is occurring:

```bash
# Check the conversation for repeating patterns:
# - Same file being edited multiple times with small changes = Edit-Run-Fail
# - Two different approaches appearing alternately = Alternating Approach
# - Deployment commands repeating = Build-Deploy

# Check token burn rate
/cost
# If tokens are increasing by 5K-10K per exchange with no task progress: loop confirmed
```

### Step 2: Fix

```bash
# For Edit-Run-Fail loops:
/compact
# "The test failure in auth.test.ts is NOT caused by the null check.
#  Stop editing auth.ts. Instead, read the test file to check if
#  the test expectations are correct."

# For Alternating Approach loops:
/compact
# "Both approach A (adding middleware) and approach B (modifying the route)
#  have been tried and failed. Try approach C: check if the issue is in
#  the database schema, not the application code."

# For Build-Deploy loops:
/compact
# "The deployment has failed 4 times. Do NOT deploy again.
#  Instead: 1) Read the FULL error log, 2) Check the configuration locally,
#  3) Validate with a dry-run command if available."
```

### Step 3: Prevent

Add loop detection rules to CLAUDE.md with explicit circuit breakers.

```yaml
# CLAUDE.md -- infinite loop prevention
## Loop Detection Rules
- Track operations: if the same command has been run 3 times in a session, STOP
- Track files: if the same file has been edited 4 times in a session, STOP and reassess
- Track approaches: if 2 different approaches have both failed, try a THIRD approach, not a retry
- Maximum tool calls per task: 15 (hard limit)
- Maximum consecutive failures: 3 (then stop and report)

## Circuit Breaker Protocol
When a circuit breaker triggers:
1. Stop all operations
2. Summarize: what was attempted, what failed, what the errors were
3. Propose 2 NEW approaches (not variations of what was tried)
4. Wait for user direction before proceeding
```

## Cost Recovery

```text
Loop damage assessment:

Small loop (5 iterations): ~25K tokens = $0.38-$1.88
  Recovery: /compact saves 60-80% of polluted context
  Net recovery: 15K-20K tokens saved on remaining turns

Medium loop (10 iterations): ~60K tokens = $0.90-$4.50
  Recovery: /compact + fresh approach
  Net recovery: 36K-48K tokens saved

Large loop (20+ iterations): ~150K tokens = $2.25-$11.25
  Recovery: Start fresh session (context too polluted for compaction)
  Net recovery: 150K tokens not re-sent = $2.25-$11.25 saved on first turn alone
```

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## Infinite Loop Circuit Breakers
- Same command run 3 times: STOP, report, wait for guidance
- Same file edited 4 times: STOP, the approach is wrong
- 3 consecutive test failures: STOP, check if the test is correct
- 3 consecutive deploy failures: STOP, validate locally
- 15 tool calls on a single task: STOP, summarize progress
- 2 failed approaches: try a FUNDAMENTALLY different third approach
- NEVER make the same edit twice -- if an edit did not fix the issue, it will not fix it on retry
```

## Related Guides

- [Claude Code keeps retrying the same error](/claude-code-keeps-retrying-same-error-cost-fix/) -- specific fix for retry spirals
- [Edge Function Debugging: Prevent Retry Spirals](/edge-function-debugging-prevent-retry-token-spirals/) -- deploy-specific loop prevention
- [Claude Code Hooks for Token Budget Enforcement](/claude-code-hooks-token-budget-enforcement/) -- automated loop detection via hooks
