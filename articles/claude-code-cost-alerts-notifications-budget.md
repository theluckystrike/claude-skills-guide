---
sitemap: false
layout: default
title: "Claude Code Cost Alerts (2026)"
description: "Configure Claude Code cost alerts through Anthropic Console thresholds, CLAUDE.md budget rules, and hooks-based monitoring to prevent billing surprises."
permalink: /claude-code-cost-alerts-notifications-budget/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Cost Alerts: Set Up Notifications When Spend Exceeds Budget

## What It Does

Cost alerts notify developers when Claude Code spending approaches or exceeds a predefined budget. Without alerts, a single runaway session can burn through $10-$50 in tokens before anyone notices. Alerts provide a safety net, catching budget overruns at the $5 or $10 mark instead of the $50 mark.

## Installation / Setup

Three layers of cost alerting are available, from simplest to most sophisticated:

```bash
# Layer 1: Anthropic Console alerts (no code required)
# Navigate to: console.anthropic.com -> Settings -> Limits
# Set monthly spend limit and notification thresholds

# Layer 2: CLAUDE.md self-monitoring (add to project)
# See Configuration section below

# Layer 3: Hooks-based monitoring (requires settings.json)
# See Advanced section below
```

## Configuration for Cost Optimization

### Layer 1: Anthropic Console Spend Limits

The Anthropic Console provides organization-wide spend limits and email notifications.

```text
Console Settings -> Limits:

  Monthly spend limit: $200 (hard cap -- API calls blocked beyond this)
  Alert at 50%:  $100 -- email notification "Review usage"
  Alert at 75%:  $150 -- email notification "Approaching limit"
  Alert at 90%:  $180 -- email notification "Near limit"
```

The hard spend limit is the most important setting. It prevents catastrophic bills from automated pipelines or forgotten sessions. Set it at 1.5x the expected monthly budget to allow for spikes without blocking work.

### Layer 2: CLAUDE.md Budget Rules

Encode session-level budget awareness directly in the agent's instructions.

```yaml
# CLAUDE.md -- cost alert rules
## Budget Alerts
- Run /cost every 10 exchanges
- If session cost exceeds $1.50: report to user and suggest compaction
- If session cost exceeds $3.00: stop work and ask for confirmation before continuing
- If a single task uses more than 15 tool calls without resolution: stop and reassess
- Maximum 3 retries on any failing approach before escalating to user
```

## Usage Examples

### Basic Usage

```bash
# Check current session spending
/cost

# Example output when approaching budget:
# Session Cost Summary
# ──────────────────────
# Total cost: $2.87
# Budget alert: approaching $3.00 session limit
# Recommendation: /compact or start new session
```

### Advanced: Hooks-Based Cost Monitoring

Claude Code hooks can execute scripts after every tool call, enabling automated budget tracking.

```json
{
  "hooks": {
    "PostToolExecution": [
      {
        "matcher": ".*",
        "command": "python3 ~/.claude/scripts/cost-monitor.py"
      }
    ]
  }
}
```

```python
#!/usr/bin/env python3
# ~/.claude/scripts/cost-monitor.py
# Reads session cost and alerts if threshold exceeded

import json
import sys
import os
from pathlib import Path

ALERT_THRESHOLD = 3.00  # dollars
LOG_FILE = Path.home() / ".claude" / "cost-alerts.log"
MAX_LOG_LINES = 1000

def check_cost():
    """Check if session cost exceeds threshold."""
    cost_file = Path.home() / ".claude" / "current-session-cost.json"
    if not cost_file.exists():
        return

    try:
        data = json.loads(cost_file.read_text())
        total_cost = data.get("total_cost_usd", 0)

        if total_cost > ALERT_THRESHOLD:
            alert_msg = f"ALERT: Session cost ${total_cost:.2f} exceeds ${ALERT_THRESHOLD:.2f} threshold"
            # Append to log (bounded)
            lines = []
            if LOG_FILE.exists():
                lines = LOG_FILE.read_text().splitlines()
            lines.append(alert_msg)
            if len(lines) > MAX_LOG_LINES:
                lines = lines[-MAX_LOG_LINES:]
            LOG_FILE.write_text("\n".join(lines) + "\n")
            print(alert_msg, file=sys.stderr)
    except (json.JSONDecodeError, KeyError, OSError):
        pass  # Fail silently -- monitoring should not break the session

if __name__ == "__main__":
    check_cost()
```

## Token Usage Measurements

| Alert Method | Token Overhead | Dollar Overhead |
|-------------|---------------|-----------------|
| Anthropic Console | 0 tokens (server-side) | $0.00 |
| CLAUDE.md /cost rule | 0 tokens per check | $0.00 |
| Hooks script | ~50 tokens (stderr output) | <$0.01 |

All three methods are essentially free in terms of token cost. The hooks method adds minimal stderr output that enters the context, but at ~50 tokens per alert, the monitoring cost is negligible compared to the overspend it prevents.

## Comparison with Alternatives

| Feature | Console Alerts | CLAUDE.md Rules | Hooks Script |
|---------|---------------|----------------|--------------|
| Granularity | Monthly | Per-session | Per-tool-call |
| Setup effort | 2 minutes | 1 minute | 15 minutes |
| Automated | Yes (email) | No (agent self-reports) | Yes (log/stderr) |
| Customizable | Limited | Fully | Fully |
| Works offline | No | Yes | Yes |

The recommended approach is all three layers: Console for monthly protection, CLAUDE.md for session awareness, and hooks for real-time automated monitoring.

## Troubleshooting

**Console alerts not arriving** -- Check the email address in Console settings. Verify the spend limit is set (alerts require a limit to be configured). Allow up to 1 hour for usage data to sync.

**CLAUDE.md rules being ignored** -- If the agent stops checking /cost, the session may have exceeded the context window and the CLAUDE.md rules were dropped during compaction. Re-add the budget rule after compaction or include it in the compaction focus directive.

**Hooks script not executing** -- Verify the script has execute permissions (`chmod +x`). Check that the hooks configuration in settings.json uses the correct path and matcher pattern.



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Dashboard: Built-In Usage Monitoring](/claude-code-dashboard-built-in-usage-monitoring/) -- understanding the /cost command output
- [Claude Code Hooks for Token Budget Enforcement](/claude-code-hooks-token-budget-enforcement/) -- automated enforcement beyond alerting
- [Claude Code Token Budget: How to Set Limits](/claude-code-token-budget-set-limits-track-spend/) -- complete budget management framework
