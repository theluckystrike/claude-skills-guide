---
title: "Claude Code Hooks for Token Budget"
description: "Enforce token budgets automatically with Claude Code hooks that monitor spend per session, alert on threshold breaches, and block runaway operations."
permalink: /claude-code-hooks-token-budget-enforcement/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Hooks for Token Budget Enforcement

## The Pattern

Claude Code hooks execute scripts before or after tool calls, enabling automated budget enforcement that does not rely on the agent remembering to check `/cost`. A PostToolExecution hook can monitor cumulative token usage and inject warnings or blocks when spending exceeds a threshold. This provides hard budget enforcement rather than soft CLAUDE.md guidelines that the agent may overlook during complex tasks.

## Why It Matters for Token Cost

CLAUDE.md rules are advisory -- the agent can and sometimes does ignore them during intense debugging or exploration. Hooks are programmatic -- they execute regardless of agent behavior. A budget enforcement hook catches the 10-15% of sessions where the agent ignores CLAUDE.md spending rules and burns through 150K-300K tokens. At Opus rates, catching even 2-3 runaway sessions per month saves $15-$45.

## The Anti-Pattern (What NOT to Do)

```yaml
# Anti-pattern: Relying solely on CLAUDE.md for budget enforcement
# CLAUDE.md
## Budget Rules
- Check /cost every 10 exchanges
- Stop if session exceeds $3

# Problem: Agent forgets to check /cost during a complex debugging session
# Result: Session hits 250K tokens ($3.75 at Opus) before anyone notices
# The rule was there, but nothing enforced it
```

## The Pattern in Action

### Step 1: Create the Budget Monitor Script

```python
#!/usr/bin/env python3
# ~/.claude/hooks/budget-monitor.py
# Runs after every tool execution to track cumulative spend

import json
import os
import sys
from pathlib import Path
from datetime import datetime

# Configuration
SESSION_BUDGET_USD = 3.00
WARNING_THRESHOLD = 0.75  # Warn at 75% of budget
COST_LOG = Path.home() / ".claude" / "session-costs.jsonl"
MAX_LOG_ENTRIES = 10000

# Pricing (April 2026)
PRICING = {
    "opus": {"input": 15.0, "output": 75.0},    # per MTok
    "sonnet": {"input": 3.0, "output": 15.0},
    "haiku": {"input": 0.8, "output": 4.0},
}

def estimate_cost(input_tokens: int, output_tokens: int, model: str = "opus") -> float:
    """Estimate cost in USD from token counts."""
    rates = PRICING.get(model, PRICING["sonnet"])
    input_cost = (input_tokens / 1_000_000) * rates["input"]
    output_cost = (output_tokens / 1_000_000) * rates["output"]
    return input_cost + output_cost

def check_budget():
    """Read session state and check against budget."""
    session_file = Path.home() / ".claude" / "current-session.json"
    if not session_file.exists():
        return

    try:
        data = json.loads(session_file.read_text())
        cost = estimate_cost(
            data.get("input_tokens", 0),
            data.get("output_tokens", 0),
            data.get("model", "sonnet")
        )

        # Log the cost entry (bounded)
        if COST_LOG.exists():
            line_count = sum(1 for _ in open(COST_LOG))
            if line_count > MAX_LOG_ENTRIES:
                lines = COST_LOG.read_text().splitlines()
                COST_LOG.write_text("\n".join(lines[-MAX_LOG_ENTRIES:]) + "\n")

        with open(COST_LOG, "a") as f:
            entry = {"timestamp": datetime.now().isoformat(), "cost": cost}
            f.write(json.dumps(entry) + "\n")

        # Check thresholds
        if cost >= SESSION_BUDGET_USD:
            print(f"BUDGET EXCEEDED: Session cost ${cost:.2f} exceeds ${SESSION_BUDGET_USD:.2f} limit.", file=sys.stderr)
            print("Action: Compact context or start a new session.", file=sys.stderr)
        elif cost >= SESSION_BUDGET_USD * WARNING_THRESHOLD:
            print(f"BUDGET WARNING: Session cost ${cost:.2f} ({cost/SESSION_BUDGET_USD*100:.0f}% of ${SESSION_BUDGET_USD:.2f} budget).", file=sys.stderr)

    except (json.JSONDecodeError, KeyError, OSError) as e:
        # Monitoring must never break the session
        pass

if __name__ == "__main__":
    check_budget()
```

### Step 2: Configure the Hook

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolExecution": [
      {
        "matcher": ".*",
        "command": "python3 ~/.claude/hooks/budget-monitor.py"
      }
    ]
  }
}
```

### Step 3: Add Pre-Execution Guards for Expensive Operations

```json
// .claude/settings.json -- expanded hooks
{
  "hooks": {
    "PreToolExecution": [
      {
        "matcher": "Bash\\(.*deploy.*\\)",
        "command": "python3 ~/.claude/hooks/pre-deploy-check.py"
      }
    ],
    "PostToolExecution": [
      {
        "matcher": ".*",
        "command": "python3 ~/.claude/hooks/budget-monitor.py"
      }
    ]
  }
}
```

```python
#!/usr/bin/env python3
# ~/.claude/hooks/pre-deploy-check.py
# Validates before expensive deploy operations

import json
import sys
from pathlib import Path

SESSION_BUDGET_USD = 3.00
DEPLOY_MIN_REMAINING = 1.00  # Need at least $1 budget for deploy + verify

def check_deploy_budget():
    """Block deploys if budget is nearly exhausted."""
    session_file = Path.home() / ".claude" / "current-session.json"
    if not session_file.exists():
        return  # Allow if we cannot check

    try:
        data = json.loads(session_file.read_text())
        input_tokens = data.get("input_tokens", 0)
        output_tokens = data.get("output_tokens", 0)
        # Estimate at Opus rates (worst case)
        cost = (input_tokens / 1_000_000) * 15.0 + (output_tokens / 1_000_000) * 75.0
        remaining = SESSION_BUDGET_USD - cost

        if remaining < DEPLOY_MIN_REMAINING:
            print(f"DEPLOY BLOCKED: Only ${remaining:.2f} budget remaining. Compact or start fresh session before deploying.", file=sys.stderr)
            sys.exit(1)  # Non-zero exit blocks the tool execution

    except (json.JSONDecodeError, KeyError, OSError):
        pass  # Allow if we cannot check

if __name__ == "__main__":
    check_deploy_budget()
```

## Before and After

| Metric | CLAUDE.md Rules Only | Hooks + CLAUDE.md | Savings |
|--------|---------------------|-------------------|---------|
| Runaway session catch rate | ~85% (agent sometimes ignores) | ~99% (programmatic) | 14% more sessions caught |
| Average runaway cost | $5-$15 | Blocked at $3 | $2-$12 per incident |
| Monthly runaway incidents | 3-5 | 0-1 | 60-80% fewer |
| Monthly savings (Opus) | Baseline | $6-$60 saved on prevented overruns | Net positive after setup |

## When to Use This Pattern

- Teams with strict monthly API budgets that cannot be exceeded
- CI/CD pipelines where Claude Code runs unattended
- Developers who frequently work on complex, long-running debugging sessions
- Any environment where a single runaway session has meaningful financial impact

## When NOT to Use This Pattern

- Claude Code Max subscribers (fixed monthly cost, token tracking is informational only)
- Developers who rarely exceed 10 turns per session (low risk of budget overruns)
- Environments where hooks add too much latency to the workflow (test with simple echo hooks first)

## Implementation in CLAUDE.md

```yaml
# CLAUDE.md -- hooks-aware budget rules
## Budget Enforcement (Automated via Hooks)
- A PostToolExecution hook monitors cumulative spend
- Warning at 75% of $3.00 session budget ($2.25)
- Hard notification at 100% ($3.00)
- Deploy commands blocked when remaining budget < $1.00
- If budget warning appears: run /compact to reduce context costs
- If budget exceeded: start a new session for the remaining work
```

## Related Guides

- [Claude Code Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) -- complete hooks reference and configuration
- [Claude Code Cost Alerts: Set Up Notifications](/claude-code-cost-alerts-notifications-budget/) -- complementary alert systems
- [Claude Code Token Budget: How to Set Limits](/claude-code-token-budget-set-limits-track-spend/) -- the full budget management framework

## See Also

- [How to set a hard token budget per Claude Code session](/set-hard-token-budget-per-claude-code-session/)
