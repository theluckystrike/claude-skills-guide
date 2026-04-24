---
title: "How to set a hard token budget"
description: "Set hard token budgets per Claude Code session using --max-turns, API spend limits, and hooks-based enforcement to cap costs at $1-$5 per session."
permalink: /set-hard-token-budget-per-claude-code-session/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to set a hard token budget per Claude Code session

## The Problem

Claude Code has no built-in per-session token limit. A session can consume unlimited tokens until it hits the context window ceiling or the API key's monthly spending cap. Without a session budget, a debugging spiral or exploration binge can burn $5-$20 in a single sitting. Developers need a way to cap individual sessions at a predictable cost -- for example, $2 per session -- to maintain budget discipline.

## Quick Fix (2 Minutes)

The fastest way to set a session budget is `--max-turns`:

```bash
# Cap session to 15 turns (~15K-45K tokens, ~$0.23-$3.38 at Opus)
claude --max-turns 15 "Fix the payment validation bug in checkout.ts"

# For simple tasks, 5 turns is usually enough (~5K-15K tokens)
claude --max-turns 5 "Add the email field to the user registration form"

# For complex tasks, allow more room but still bounded
claude --max-turns 30 "Debug the intermittent timeout in the order processing pipeline"
```

**Budget approximation:** At 1,000-3,000 tokens per turn, `--max-turns N` creates a rough budget of N * 2,000 tokens (midpoint). Multiply by your model's blended rate for a dollar estimate.

## Why This Happens

Claude Code is designed for autonomous operation, which means it will keep working until the task is complete or the context window fills. This is powerful for productivity but dangerous for budgets. Three factors create the budget control gap:

1. **No built-in session spending limit** -- the `/cost` command shows spend but does not enforce limits.
2. **Token usage is unpredictable** -- the same task can cost 20K or 100K tokens depending on how the agent approaches it.
3. **Human attention gaps** -- developers start a task and look away, or accept tool calls without checking spend.

The financial risk: without a budget, a single bad session can consume a week's worth of API budget.

## The Full Fix

### Step 1: Diagnose

Understand current per-session spending patterns:

```bash
# Check recent session costs
ccusage --days 7 --format table

# Identify your per-session spending distribution:
# - Most sessions: 20K-60K tokens ($0.30-$4.50 Opus)
# - Occasional outliers: 100K-200K tokens ($1.50-$15.00 Opus)
# - Target: cap the outliers without constraining normal sessions
```

### Step 2: Fix

Three methods to enforce a session budget, from simplest to most robust:

**Method 1: --max-turns flag (simplest)**

```bash
# Add to your shell alias for daily use
alias cc='claude --max-turns 20'
alias cc-quick='claude --max-turns 5'
alias cc-deep='claude --max-turns 40'

# Now every session is automatically bounded:
cc "Implement the rate limiting middleware"
# Stops after 20 turns regardless of task completion
```

Token budget: 20 turns * 2,000 avg tokens = ~40K tokens = ~$0.60 (Sonnet) or ~$3.00 (Opus).

**Method 2: CLAUDE.md self-enforcement (medium)**

```yaml
# CLAUDE.md -- session budget enforcement
## Session Budget: $2.00
- Check /cost every 8 exchanges
- At $1.50 (75% of budget): report to user, suggest compaction
- At $2.00 (100% of budget): STOP all work and report final cost
- If task is incomplete at budget limit: summarize progress and remaining work
- Do not start new tasks after the first task is complete (keep sessions single-purpose)
```

**Method 3: Hooks-based hard enforcement (most robust)**

```json
{
  "hooks": {
    "PostToolExecution": [
      {
        "matcher": ".*",
        "command": "python3 ~/.claude/hooks/session-budget.py"
      }
    ]
  }
}
```

```python
#!/usr/bin/env python3
# ~/.claude/hooks/session-budget.py

import json
import sys
from pathlib import Path

SESSION_BUDGET_USD = 2.00
TURN_COUNT_FILE = Path.home() / ".claude" / "turn-count.txt"
MAX_TURNS = 25

def enforce_budget():
    """Track turns and enforce budget."""
    # Simple turn counter (robust, no API dependency)
    turns = 0
    if TURN_COUNT_FILE.exists():
        try:
            turns = int(TURN_COUNT_FILE.read_text().strip())
        except (ValueError, OSError):
            turns = 0

    turns += 1

    # Bounded write
    try:
        TURN_COUNT_FILE.write_text(str(min(turns, 99999)))
    except OSError:
        pass

    if turns >= MAX_TURNS:
        print(f"SESSION BUDGET: {turns} turns reached (limit: {MAX_TURNS}). "
              f"Estimated cost at limit: ~${turns * 0.10:.2f}. "
              f"Start a new session for additional work.", file=sys.stderr)
    elif turns >= int(MAX_TURNS * 0.75):
        print(f"BUDGET WARNING: {turns}/{MAX_TURNS} turns used.", file=sys.stderr)

if __name__ == "__main__":
    enforce_budget()
```

### Step 3: Prevent

Establish session budget tiers for different task types:

```yaml
# CLAUDE.md -- budget tiers
## Session Budget Tiers
| Task Type | Max Turns | Approx. Token Budget | Approx. Cost (Opus) |
|-----------|-----------|---------------------|---------------------|
| Quick edit | 5 | 10K | $0.15 |
| Bug fix | 15 | 30K-45K | $0.45-$0.68 |
| Feature | 25 | 50K-75K | $0.75-$1.13 |
| Complex debug | 35 | 70K-105K | $1.05-$1.58 |
| Architecture | 40 | 80K-120K | $1.20-$1.80 |

Select the appropriate tier before starting each session.
Use --max-turns to enforce the tier.
```

## Cost Recovery

```text
If a session has already exceeded the intended budget:

Step 1: Check actual spend
/cost

Step 2: If task is near completion (1-2 more turns): finish it
  Cost of 2 more turns at current context: ~4K-6K tokens = $0.06-$0.45

Step 3: If task is far from completion: stop and start fresh
  Continuing in an oversized context: expensive
  Starting fresh with context handoff: ~5K tokens to re-establish
  Savings: avoid 50K-100K tokens of inflated-context turns

Step 4: Record the overspend for pattern analysis
  Track: task type, estimated budget, actual spend, why it overran
  Use this data to refine budget tiers
```

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## Hard Session Budget
- Maximum session budget: $2.00
- Maximum turns: 25
- Check /cost every 8 exchanges
- At 75% of budget: compact and report remaining budget
- At 100% of budget: STOP and summarize progress
- One major task per session (start fresh for new tasks)
- Use --max-turns flag: `claude --max-turns 25`
```

## Related Guides

- [Claude Code Token Budget: How to Set Limits and Track Spend](/claude-code-token-budget-set-limits-track-spend/) -- comprehensive budget management
- [Claude Code Hooks for Token Budget Enforcement](/claude-code-hooks-token-budget-enforcement/) -- automated hooks-based enforcement
- [Claude Code Dashboard: Built-In Usage Monitoring](/claude-code-dashboard-built-in-usage-monitoring/) -- tracking spend with /cost and ccusage
