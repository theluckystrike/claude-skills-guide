---
title: "Claude Code keeps retrying the same"
description: "Stop Claude Code from retrying the same error in a loop that wastes 20K-50K tokens per spiral by adding retry limits and error classification to CLAUDE.md."
permalink: /claude-code-keeps-retrying-same-error-cost-fix/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code keeps retrying the same error -- cost fix

## The Problem

Claude Code is stuck retrying the same failing operation -- modifying code slightly and re-running it, each time getting the same or a similar error. Each retry costs 3,000-8,000 tokens (code modification + command execution + error reading). A 5-retry spiral burns 15,000-40,000 tokens in 2-3 minutes. At Opus 4.6 rates ($15/$75 per MTok), that is $0.23-$3.00 wasted on an approach that is not working.

## Quick Fix (2 Minutes)

1. **Type "stop" or press Escape** to interrupt the current retry loop.
2. **Run `/compact`** to clear the accumulated failed attempts from context.
3. **Restate the task with explicit constraints:** "The previous approach of modifying X did not work after 3 attempts. Try a different approach: [describe alternative]."

```bash
# Step 1: Interrupt
# Press Escape or type "stop"

# Step 2: Compact away the failed attempts
/compact Keep: the original error and task description. Discard: all failed fix attempts.

# Step 3: Redirect
# "The type error in auth.ts was not fixed by adding null checks.
#  Instead, check if the JWT library version is compatible with Node 22.
#  Read package.json for the jsonwebtoken version."
```

## Why This Happens

Retry spirals occur because Claude Code's context accumulates evidence that a particular approach is "close to working." Each slightly different error message reinforces the agent's commitment to the current strategy. Three factors compound:

1. **Anchoring bias** -- the accumulated context of 3-4 attempts makes the agent believe it is on the right track, even when the fundamental approach is wrong.
2. **Context pollution** -- each failed attempt adds 3,000-8,000 tokens of noise to the context, making it harder for the agent to reason clearly about alternatives.
3. **Missing root cause** -- the agent is treating symptoms (the error message) rather than diagnosing the root cause (wrong library version, missing configuration, etc.).

The token cost compounds because each retry re-sends the entire conversation context, which now includes all previous failed attempts. By retry 5, the context may contain 25,000+ tokens of failed attempt history, costing $0.38+ per turn at Opus rates just to re-read the failures.

## The Full Fix

### Step 1: Diagnose

Confirm that the agent is in a retry loop by checking the pattern:

```bash
# Check the /cost output
/cost
# If token count has jumped 20K+ in the last few exchanges with no progress: retry spiral confirmed

# Look for the pattern in the conversation:
# - Same command being run repeatedly
# - Same error or slight variations of the same error
# - Small code changes between attempts (e.g., adding null checks, changing variable names)
```

### Step 2: Fix

Break the loop and redirect the agent to a fundamentally different approach.

```bash
# Compact to remove the failed attempts
/compact Keep: original task, error description. Discard: all fix attempts.

# Redirect with explicit constraints
# Instead of: "Fix the TypeError in auth.ts"
# Say: "The TypeError in auth.ts is NOT a null reference issue (already tried 3 times).
#       Investigate: 1) JWT library version compatibility, 2) Node.js crypto API changes,
#       3) TypeScript strict mode type narrowing. Read package.json first."
```

### Step 3: Prevent

Add retry limits to CLAUDE.md that trigger before spirals begin.

```yaml
# CLAUDE.md -- retry spiral prevention
## Error Handling Rules
- Maximum 3 attempts on any single error
- After attempt 1: re-read the FULL error message and identify the root cause
- After attempt 2: if the same error recurs, the approach is wrong -- try a different strategy
- After attempt 3: STOP. Report: what was tried, what failed, and 2 alternative approaches
- Never retry: permission errors (403/401), missing file errors, configuration errors
- For build/test errors: read the error output completely before making changes
```

## Cost Recovery

After a retry spiral, minimize the damage:

```bash
# 1. Compact to remove the wasted context
/compact

# 2. Verify compaction saved tokens
/cost

# 3. If the task is still needed, restart with a focused prompt
# This fresh approach typically costs 5K-15K tokens vs the 40K+ already wasted

# 4. Consider switching to a cheaper model for the diagnostic phase
# Use Haiku ($0.80/$4 per MTok) to investigate, then Sonnet to implement
```

The compaction alone saves significant money on remaining turns. If the context was 120K tokens and compaction reduces it to 40K tokens, each subsequent turn saves $1.20 in input at Opus rates.

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## Retry Spiral Prevention
- MAX 3 RETRIES on any failing operation
- After each failure: read the COMPLETE error message before retrying
- After 2 failures with the same error: CHANGE APPROACH (do not modify the same code)
- After 3 failures: STOP and report:
  1. What was attempted (3 sentences max)
  2. The exact error each time
  3. Two alternative approaches to try
- Never retry: auth errors, missing file errors, permission errors, syntax errors in config files
- If a test fails 3 times: check if the test itself is wrong, not just the implementation
```

## Related Guides

- [Claude Code infinite loop detection](/claude-code-infinite-loop-detection-stop-drains-tokens/) -- detecting and stopping broader loop patterns
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- comprehensive CLAUDE.md cost prevention rules
- [Edge Function Debugging: Prevent Retry Spirals](/edge-function-debugging-prevent-retry-token-spirals/) -- retry prevention for deployment scenarios
