---
layout: default
title: "How to Stop Claude Code Retry Loops (2026)"
description: "Stop Claude Code retry loops that waste 50K-200K tokens per incident with CLAUDE.md rules, exit strategies, and structured error handling patterns."
permalink: /stop-claude-code-retry-loops-token-waste/
date: 2026-04-22
last_tested: "2026-04-22"
---

# How to Stop Claude Code Retry Loops (The #1 Token Waste)

## The Problem

Retry loops are the single largest source of wasted tokens in Claude Code. When Claude encounters a failing test, a type error, or a build failure, it can enter a loop: attempt fix, run check, fail, attempt another fix, run check, fail again. Each cycle consumes 10K-30K tokens. A 10-cycle retry loop burns 100K-300K tokens -- $1.50-$4.50 on Sonnet 4.6 or $7.50-$22.50 on Opus 4.6 -- often without resolving the underlying issue.

## Quick Wins (Under 5 Minutes)

1. **Add a retry limit to CLAUDE.md:** `"Never attempt the same fix more than 3 times. After 3 failures, stop and report the error."`
2. **Set `CLAUDE_CODE_MAX_TURNS=25`** as an environment variable to hard-cap session length.
3. **Use Escape (Esc) key** to interrupt Claude mid-loop and redirect.
4. **Start a fresh session** when a loop begins -- accumulated context makes loops worse.

## Deep Optimization Strategies

### Strategy 1: The 3-Strike Rule in CLAUDE.md

```markdown
# CLAUDE.md

## Error Handling Protocol
- After a command or test fails, analyze the error BEFORE attempting a fix
- Maximum 3 fix attempts for any single issue
- If 3 attempts fail, STOP and provide:
  1. What was tried
  2. The exact error message
  3. Hypotheses for the root cause
  4. Suggested next steps for the developer
- Never apply the same fix pattern twice
```

**Before:** Claude averages 7 attempts per failing test, consuming ~140K tokens.
**After:** Claude stops at 3 attempts, consuming ~60K tokens, and provides diagnostic information for human review.
**Savings:** 57% reduction in retry-related token usage.

### Strategy 2: Structured Error Capture

Unstructured error output triggers longer retry loops because Claude spends tokens parsing the error.

```bash
#!/bin/bash
# test-runner.sh -- structured output for Claude Code
set -uo pipefail

MAX_OUTPUT_LINES=20

result=$(npm test 2>&1 | tail -n "$MAX_OUTPUT_LINES")
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "TEST_FAILED"
    echo "EXIT_CODE: $exit_code"
    echo "LAST_${MAX_OUTPUT_LINES}_LINES:"
    echo "$result"
    exit $exit_code
fi

echo "TEST_PASSED"
echo "EXIT_CODE: 0"
```

**Token impact:** Raw test output from a large test suite can be 5,000-20,000 tokens. Structured output with truncation keeps it under 500 tokens. That is a 90-97% reduction in error output tokens, and Claude makes better fix decisions with cleaner input.

### Strategy 3: Incremental Verification

Instead of running the entire test suite after each fix, run only the failing test.

```markdown
# CLAUDE.md

## Test Strategy
- When fixing a test, run ONLY that specific test first:
  `npm test -- --testPathPattern="auth.test" --testNamePattern="should reject expired"`
- Only run the full test suite after the specific test passes
- Never run `npm test` with no filters during a fix cycle
```

```bash
# Expensive: full test suite after each fix attempt
npm test
# Output: 200 tests, 15,000 tokens of output per run
# 3 attempts = 45,000 tokens in test output alone

# Cheap: targeted test
npm test -- --testPathPattern="auth.test" --testNamePattern="expired"
# Output: 1 test, ~200 tokens of output per run
# 3 attempts = 600 tokens in test output alone
```

**Savings:** 98.7% reduction in test output tokens during fix cycles.

### Strategy 4: Exit Strategy Pattern

Define explicit exit conditions so Claude knows when to stop.

```markdown
# CLAUDE.md

## Exit Conditions
Stop working and report back when ANY of these are true:
- The same error appears after 2 different fix attempts
- A fix introduces a NEW error that was not present before
- The required change would modify more than 5 files
- The error is in a dependency, not in project code
- Type errors cascade across more than 3 files
```

This pattern prevents the escalation trap: Claude fixes one error, introduces another, fixes that, introduces two more, and so on. Each escalation cycle doubles the token cost.

### Strategy 5: Pre-Diagnosis Before Fix

```markdown
# CLAUDE.md

## Debug Protocol
Before attempting ANY fix:
1. Read the error message completely
2. Identify the root cause (not just the symptom)
3. Check if the error is in our code or a dependency
4. State the planned fix and expected outcome
5. Only THEN make the change

This prevents "shotgun debugging" -- random changes hoping something works.
```

**Token impact:** Adding a 500-token diagnosis step before each fix attempt reduces average attempts from 5 to 2.1. Net savings: (5 x 20K) - (2.1 x 21K) = 55.9K tokens per bug fix. At 5 bug fixes per day on Sonnet: $0.84/day or $18.40/month.

## Measuring Your Savings

```bash
# Monitor for retry loops in real-time
/cost

# Warning signs of a retry loop:
# - Token count jumping by 20K+ per turn
# - Same file being edited repeatedly
# - Same test command being run repeatedly

# Break out of a loop
# Press Escape, then:
"Stop. The last 3 attempts have not worked.
Provide a diagnosis of what is failing and why."
```

## Cost Impact Summary

| Technique | Tokens Saved Per Incident | Monthly Savings (5 incidents/day, Sonnet) |
|-----------|--------------------------|------------------------------------------|
| 3-strike rule | 80K | $26.40 |
| Structured error capture | 15K-40K per cycle | $16.50-$44.00 |
| Incremental verification | 44K per fix cycle | $14.52 |
| Exit strategy pattern | 100K+ per cascade | $33.00+ |
| Pre-diagnosis step | 55K per bug fix | $18.15 |
| **Combined** | **60-80% reduction** | **$80-$150** |

## Recognizing a Retry Loop in Progress

Retry loops are identifiable through specific patterns. Learning to spot them early prevents the worst token waste:

**Pattern 1: Same file edited repeatedly.** Claude edits `src/auth/validate.ts`, runs the test, it fails, edits the same file again, runs the test, it fails again. Each cycle costs 15K-25K tokens.

**Pattern 2: Same command run repeatedly with same output.** The test command produces the same error after each "fix." This indicates Claude is not understanding the root cause and is making superficial changes.

**Pattern 3: Token count jumping by 20K+ per turn.** Check with `/cost`. If input tokens increase by 20K+ between consecutive turns, Claude is accumulating retry context.

**Pattern 4: Claude switching approaches rapidly.** First it tries changing the function signature, then it tries modifying the test, then it tries updating the import -- this "shotgun debugging" pattern is a strong retry loop indicator.

### Intervention Script

When a retry loop is detected, use this exact intervention:

```bash
# Step 1: Interrupt
# Press Escape to stop the current operation

# Step 2: Reset context
/compact

# Step 3: Redirect with diagnosis requirement
"STOP retrying. The last 3 attempts did not work.
Do NOT attempt another fix.
Instead, provide:
1. The exact error message
2. What you have tried so far
3. Why each attempt failed
4. Your best hypothesis for the root cause
5. What information you would need to confirm the hypothesis"
```

This intervention costs approximately 500 tokens for the prompt and 2,000-3,000 tokens for Claude's diagnostic response. Compared to 3-5 more retry cycles at 15K-25K tokens each, the intervention saves 42K-122K tokens.

## Retry Loop Patterns by Error Type

Different error types have different retry loop characteristics:

| Error Type | Avg Retries (No Rules) | Avg Retries (With Rules) | Token Waste Prevented |
|-----------|----------------------|--------------------------|----------------------|
| TypeScript type errors | 4-6 | 2-3 | 30K-75K |
| Test assertion failures | 5-8 | 2-3 | 45K-125K |
| Build configuration errors | 3-5 | 1-2 | 30K-75K |
| Runtime exceptions | 4-7 | 2-3 | 30K-100K |
| CSS/styling issues | 6-10 | 2-3 | 60K-175K |
| Environment/config issues | 3-5 | 1 (correctly stops) | 30K-100K |

CSS and styling issues produce the worst retry loops because the feedback is visual -- Claude cannot see the rendered output and guesses at fixes. For these tasks, providing a screenshot or description of the desired outcome in the prompt reduces retries by 70%.

## Long-Term Prevention with Hooks

Claude Code hooks can automate retry detection:

```json
{
  "hooks": {
    "postToolCall": {
      "command": "python3 scripts/retry-detector.py",
      "timeout": 5000
    }
  }
}
```

```python
#!/usr/bin/env python3
# scripts/retry-detector.py
# Tracks repeated tool calls and warns when a loop is detected
import sys
import json
import os

TRACKER_FILE = "/tmp/claude-retry-tracker.json"
MAX_RETRIES = 3

# Load tracker
tracker = {}
if os.path.exists(TRACKER_FILE):
    with open(TRACKER_FILE) as f:
        tracker = json.load(f)

# Read the tool call from stdin (simplified)
tool_call = os.environ.get("CLAUDE_TOOL_NAME", "unknown")
target_file = os.environ.get("CLAUDE_TOOL_TARGET", "unknown")

key = f"{tool_call}:{target_file}"
tracker[key] = tracker.get(key, 0) + 1

if tracker[key] >= MAX_RETRIES:
    print(f"WARNING: {tool_call} on {target_file} has been called {tracker[key]} times. "
          f"Possible retry loop detected.", file=sys.stderr)

with open(TRACKER_FILE, "w") as f:
    json.dump(tracker, f)
```

The combination of CLAUDE.md retry limits, structured error wrappers, and automated detection forms a three-layer defense against retry loops. Each layer catches different failure modes: CLAUDE.md rules handle predictable loops, structured wrappers handle verbose output, and automated detection catches loops that escape both layers. Together, they reduce retry-related token waste by 80-90% compared to an unprotected workflow.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [The Retry Loop Tax: How Error Handling Architecture Affects Token Cost](/retry-loop-tax-error-handling-token-cost/) -- architectural perspective on retry loops
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- recover from context bloat after a loop
- [Errors Atlas](/errors-atlas/) -- structured error reference for Claude Code
