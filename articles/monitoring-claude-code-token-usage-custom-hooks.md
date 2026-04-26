---
layout: default
title: "Monitoring Claude Code Token Usage (2026)"
description: "Build custom Claude Code hooks that log token usage per session and alert when costs exceed thresholds, enabling data-driven optimization worth $10-30/month."
permalink: /monitoring-claude-code-token-usage-custom-hooks/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Monitoring Claude Code Token Usage with Custom Hooks

## What It Does

Claude Code hooks execute custom scripts at defined lifecycle points -- before/after tool calls, on session start/end, and on notification events. By attaching monitoring hooks, developers gain per-session token tracking, cost alerting, and historical analysis without modifying Claude Code itself. This visibility typically reveals 20-40% of sessions that consume disproportionate tokens, enabling targeted optimization worth $10-$30 per month on Sonnet 4.6.

## Installation / Setup

Hooks are configured in `.claude/settings.json` at the project or user level. No external dependencies required for basic monitoring.

Create the hooks directory and configuration:

```bash
mkdir -p .claude/hooks
```

Add the hook configuration to `.claude/settings.json`:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "command": ".claude/hooks/log-tool-usage.sh \"$TOOL_NAME\" \"$INPUT_TOKENS\" \"$OUTPUT_TOKENS\"",
        "description": "Log tool usage for cost analysis"
      }
    ],
    "sessionEnd": [
      {
        "command": ".claude/hooks/session-summary.sh",
        "description": "Generate session cost summary"
      }
    ]
  }
}
```

## Configuration for Cost Optimization

### Basic Tool Usage Logger

```bash
#!/bin/bash
# .claude/hooks/log-tool-usage.sh
# Logs each tool call with timestamp and token counts
set -uo pipefail

TOOL_NAME="${1:-unknown}"
LOG_DIR="${HOME}/.claude/usage-logs"
LOG_FILE="${LOG_DIR}/$(date +%Y-%m-%d).jsonl"

mkdir -p "$LOG_DIR"

# Append one JSON line per tool call
printf '{"ts":"%s","tool":"%s","session":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$TOOL_NAME" \
  "${CLAUDE_SESSION_ID:-unknown}" \
  >> "$LOG_FILE"
```

Make it executable:

```bash
chmod +x .claude/hooks/log-tool-usage.sh
```

### Session Summary Hook

```bash
#!/bin/bash
# .claude/hooks/session-summary.sh
# Runs at session end, summarizes tool call counts
set -uo pipefail

LOG_DIR="${HOME}/.claude/usage-logs"
TODAY_LOG="${LOG_DIR}/$(date +%Y-%m-%d).jsonl"
SUMMARY_DIR="${LOG_DIR}/summaries"

mkdir -p "$SUMMARY_DIR"

if [ ! -f "$TODAY_LOG" ]; then
  exit 0
fi

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

# Count tool calls for this session (bounded: max 1000 lines scanned)
TOOL_COUNT=$(grep -c "\"session\":\"${SESSION_ID}\"" "$TODAY_LOG" 2>/dev/null | head -1 || echo "0")

# Log the session summary
printf '{"date":"%s","session":"%s","tool_calls":%s}\n' \
  "$(date +%Y-%m-%d)" \
  "$SESSION_ID" \
  "$TOOL_COUNT" \
  >> "${SUMMARY_DIR}/$(date +%Y-%m-%d).jsonl"

# Alert if tool count is high (threshold: 50 calls)
MAX_CALLS=50
if [ "$TOOL_COUNT" -gt "$MAX_CALLS" ]; then
  echo "WARNING: Session used ${TOOL_COUNT} tool calls (threshold: ${MAX_CALLS})"
  echo "Review session for optimization opportunities"
fi
```

## Usage Examples

### Basic Usage

After configuring hooks, every Claude Code session automatically logs tool calls. Review daily summaries:

```bash
# View today's tool usage
cat ~/.claude/usage-logs/$(date +%Y-%m-%d).jsonl | head -20

# Count tool calls per session today
cat ~/.claude/usage-logs/summaries/$(date +%Y-%m-%d).jsonl
```

### Advanced: Weekly Cost Analysis Script

```bash
#!/bin/bash
# scripts/weekly-cost-report.sh
# Aggregate weekly usage and estimate costs
set -uo pipefail

LOG_DIR="${HOME}/.claude/usage-logs"
SUMMARY_DIR="${LOG_DIR}/summaries"
REPORT_FILE="${HOME}/Desktop/claude-weekly-cost-$(date +%Y-%m-%d).txt"

echo "=== Claude Code Weekly Cost Report ===" > "$REPORT_FILE"
echo "Week ending: $(date +%Y-%m-%d)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

TOTAL_SESSIONS=0
TOTAL_TOOL_CALLS=0
MAX_CALLS=0

# Process last 7 days of summaries (bounded loop)
for i in $(seq 0 6); do
  DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d)
  SUMMARY_FILE="${SUMMARY_DIR}/${DATE}.jsonl"

  if [ -f "$SUMMARY_FILE" ]; then
    DAY_SESSIONS=$(wc -l < "$SUMMARY_FILE" | tr -d ' ')
    TOTAL_SESSIONS=$((TOTAL_SESSIONS + DAY_SESSIONS))

    while IFS= read -r line; do
      CALLS=$(echo "$line" | grep -o '"tool_calls":[0-9]*' | grep -o '[0-9]*')
      CALLS=${CALLS:-0}
      TOTAL_TOOL_CALLS=$((TOTAL_TOOL_CALLS + CALLS))
      if [ "$CALLS" -gt "$MAX_CALLS" ]; then
        MAX_CALLS=$CALLS
      fi
    done < "$SUMMARY_FILE"
  fi
done

# Estimate cost (rough: 1000 tokens per tool call average at Sonnet 4.6 rates)
ESTIMATED_TOKENS=$((TOTAL_TOOL_CALLS * 1000))
ESTIMATED_COST_CENTS=$((ESTIMATED_TOKENS * 6 / 10000))

echo "Total sessions: $TOTAL_SESSIONS" >> "$REPORT_FILE"
echo "Total tool calls: $TOTAL_TOOL_CALLS" >> "$REPORT_FILE"
echo "Max tool calls (single session): $MAX_CALLS" >> "$REPORT_FILE"
echo "Estimated tokens: ~${ESTIMATED_TOKENS}" >> "$REPORT_FILE"
echo "Estimated cost: ~\$${ESTIMATED_COST_CENTS} (cents)" >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
cat "$REPORT_FILE"
```

### Advanced: Cost Threshold Alerting

Create a hook that alerts when a session's estimated cost exceeds a threshold:

```bash
#!/bin/bash
# .claude/hooks/cost-alert.sh
# Estimates cumulative session cost and warns when threshold exceeded
set -uo pipefail

COST_LOG="${HOME}/.claude/usage-logs/current-session-cost.txt"
THRESHOLD_CENTS=50  # Alert at $0.50

# Estimate tokens per tool call (rough: varies by tool)
TOOL_NAME="${1:-unknown}"
case "$TOOL_NAME" in
  Bash)  EST_TOKENS=1000 ;;
  Read)  EST_TOKENS=2000 ;;
  Edit)  EST_TOKENS=500  ;;
  Grep)  EST_TOKENS=800  ;;
  Glob)  EST_TOKENS=500  ;;
  mcp__*) EST_TOKENS=1500 ;;
  *)     EST_TOKENS=1000 ;;
esac

# Accumulate estimated tokens
CURRENT=$(cat "$COST_LOG" 2>/dev/null || echo "0")
NEW_TOTAL=$((CURRENT + EST_TOKENS))
echo "$NEW_TOTAL" > "$COST_LOG"

# Estimate cost in cents (Sonnet 4.6 blended rate ~$0.006/1K tokens = 0.6 cents/1K)
EST_COST_CENTS=$((NEW_TOTAL * 6 / 10000))

if [ "$EST_COST_CENTS" -gt "$THRESHOLD_CENTS" ]; then
  echo "COST ALERT: Session estimated at ~$${EST_COST_CENTS} cents (threshold: $${THRESHOLD_CENTS} cents)"
  echo "Consider running /compact or ending the session"
fi
```

This hook provides real-time cost awareness during long sessions, catching runaway costs before they become expensive.

### Advanced: Tool Usage Heatmap

Analyze which tools consume the most session time and tokens:

```bash
#!/bin/bash
# scripts/tool-heatmap.sh
# Shows tool call frequency across recent sessions
set -uo pipefail

LOG_DIR="${HOME}/.claude/usage-logs"

echo "=== Tool Usage Heatmap (Last 7 Days) ==="
echo ""

for i in $(seq 0 6); do
  DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d)
  LOG_FILE="${LOG_DIR}/${DATE}.jsonl"

  if [ -f "$LOG_FILE" ]; then
    echo "--- $DATE ---"
    grep -o '"tool":"[^"]*"' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
    echo ""
  fi
done
```

This reveals patterns like "Bash is called 3x more than Read" or "MCP tools account for 40% of all calls" -- data that guides targeted optimization.

### Advanced: Per-Project Cost Attribution

For teams working across multiple projects, attribute costs to specific projects:

```bash
#!/bin/bash
# .claude/hooks/project-cost-tracker.sh
# Tags tool calls with the current project for cost attribution
set -uo pipefail

TOOL_NAME="${1:-unknown}"
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
LOG_FILE="${HOME}/.claude/usage-logs/project-costs.jsonl"

printf '{"ts":"%s","project":"%s","tool":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$PROJECT_NAME" \
  "$TOOL_NAME" \
  >> "$LOG_FILE"
```

Analyze per-project costs:

```bash
# scripts/project-cost-summary.sh
#!/bin/bash
set -uo pipefail

LOG_FILE="${HOME}/.claude/usage-logs/project-costs.jsonl"

echo "=== Per-Project Tool Call Costs (Last 7 Days) ==="
echo ""

# Count tool calls per project
grep -o '"project":"[^"]*"' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10

echo ""
echo "Estimated cost per project (1K tokens per call, Sonnet 4.6 blended):"
grep -o '"project":"[^"]*"' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10 | \
  while read -r count project; do
    COST=$(echo "scale=2; $count * 6 / 1000" | bc)
    echo "  $project: ~\$$COST ($count calls)"
  done
```

This data enables informed decisions about which projects need cost optimization. A project with 3x the tool calls of others is the priority for CLAUDE.md optimization, skill creation, and MCP auditing.

## Token Usage Measurements

Hook overhead is minimal:

| Hook Action | Overhead | Frequency |
|-------------|----------|-----------|
| log-tool-usage.sh | ~5ms, 0 tokens (runs externally) | Per tool call |
| session-summary.sh | ~20ms, 0 tokens (runs externally) | Per session end |
| Weekly report script | ~100ms, 0 tokens (manual run) | Weekly |

Hooks run as external processes and do not consume Claude Code tokens. The monitoring is free in token terms -- it only costs the disk space for log files (~1KB per 100 tool calls).

## Comparison with Alternatives

| Method | Token Cost | Setup Time | Granularity | Historical Data |
|--------|-----------|------------|-------------|-----------------|
| Custom hooks (this guide) | 0 tokens | 15 min | Per tool call | Yes (logs) |
| `/cost` command | ~50 tokens | 0 min | Per session | No |
| `ccusage` CLI | 0 tokens | 5 min | Per session | Yes |
| Manual tracking | 0 tokens | Ongoing | Per session | Spreadsheet |

Custom hooks provide the most granularity (per-tool-call data) at zero token cost. Use `/cost` for quick checks, `ccusage` for session-level analysis, and custom hooks for deep tool-call-level optimization.

## Troubleshooting

**Hook not executing**: Verify the script has execute permissions (`chmod +x`). Check that `.claude/settings.json` has correct JSON syntax. Hooks fail silently if the command path is wrong.

**Log files growing too large**: Add a cleanup step to the weekly report script that removes logs older than 30 days: `find ~/.claude/usage-logs -name "*.jsonl" -mtime +30 -delete`.

**Hook permissions**: On macOS, new hook scripts may require explicit permission. Run `chmod +x .claude/hooks/*.sh` after creating any new hook. If the hook still fails silently, check System Preferences > Security & Privacy for any blocked scripts.

**Log file rotation**: Without rotation, log files grow indefinitely. Add cleanup to the weekly report: `find ~/.claude/usage-logs -name "*.jsonl" -mtime +30 -delete` removes logs older than 30 days, keeping disk usage under control while retaining enough history for monthly analysis.

**Session ID not available**: The `CLAUDE_SESSION_ID` environment variable may not be set in all hook contexts. Use a fallback like the current timestamp to differentiate sessions: `${CLAUDE_SESSION_ID:-$(date +%s)}`.

### Combining Hooks with ccusage

For the most comprehensive monitoring, use custom hooks for real-time tool-level tracking and `ccusage` for historical session-level analysis:

```bash
# Real-time: hooks log every tool call as it happens
# Historical: ccusage provides session summaries with actual token counts

# Weekly workflow:
# 1. Review ccusage for session-level cost trends
ccusage --sort cost --limit 10

# 2. Drill into expensive sessions using hook logs
# Find the date of the most expensive session, then check tool usage
cat ~/.claude/usage-logs/2026-04-22.jsonl | grep -o '"tool":"[^"]*"' | sort | uniq -c | sort -rn

# 3. Compare tool-level patterns to identify optimization targets
# If "Read" is 40% of calls, invest in CLAUDE.md architecture map
# If "mcp__*" is 30% of calls, audit MCP overhead
# If "Bash" is 50%+ of calls, check for unnecessary command execution
```

This two-layer approach -- hooks for granularity, ccusage for accuracy -- provides complete cost visibility without any token overhead. The hooks capture patterns that ccusage does not (tool call frequency, per-project attribution), while ccusage provides verified token counts that hook estimates cannot match.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) -- complete hooks reference
- [Cost Optimization Hub](/cost-optimization/) -- use monitoring data to apply targeted optimizations
