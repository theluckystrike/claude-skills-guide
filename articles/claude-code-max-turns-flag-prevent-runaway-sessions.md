---
title: "Claude Code --max-turns Flag: Prevent Runaway Sessions"
description: "The --max-turns flag caps Claude Code session length, preventing runaway sessions that consume 200K+ tokens and cost over $0.60 per incident on Sonnet 4.6."
permalink: /claude-code-max-turns-flag-prevent-runaway-sessions/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code --max-turns Flag: Prevent Runaway Sessions

## What It Does

The `--max-turns` flag sets a hard limit on the number of conversational turns Claude Code can execute in a single session. Without this limit, a session can run indefinitely -- consuming 200K-500K tokens on complex or poorly-scoped tasks. At Sonnet 4.6 rates ($3/$15 per MTok), an unbounded session can cost $0.60-$1.50 or more. The `--max-turns` flag prevents this by stopping execution at a predictable point, typically saving $0.30-$1.00 per runaway incident.

## Installation / Setup

The flag is built into Claude Code. No installation required:

```bash
# Basic syntax
claude --max-turns <number> -p "your prompt"

# Example: cap at 10 turns
claude --max-turns 10 -p "Fix the failing test in src/auth/login.test.ts"
```

## Configuration for Cost Optimization

### Recommended Turn Limits by Task Type

```bash
# Quick fix or explanation: 5-8 turns
claude --max-turns 8 -p "Explain what src/utils/cache.ts does"

# Bug fix: 10-15 turns
claude --max-turns 15 -p "Fix the timeout error in the payment service"

# Feature implementation: 20-25 turns
claude --max-turns 25 -p "Add email verification to the signup flow"

# Code review: 8-12 turns
claude --max-turns 10 -p "Review src/api/routes/users.ts for security issues"

# CI/automation: 10-15 turns
claude --max-turns 12 -p "Run tests and fix any failures in src/services/"
```

### Shell Aliases for Common Patterns

```bash
# ~/.zshrc or ~/.bashrc

# Quick tasks (explanations, small fixes)
alias cq='claude --max-turns 8'

# Standard tasks (bug fixes, reviews)
alias cs='claude --max-turns 15'

# Large tasks (features, refactors)
alias cl='claude --max-turns 25'

# CI mode (automated, strict budget)
alias cci='claude --max-turns 12 --allowedTools "Read,Glob,Grep,Edit,Bash"'
```

### Cost Ceiling Calculation

Each turn in Claude Code averages 3,000-10,000 tokens (input + output), depending on context size and task complexity. Setting `--max-turns` creates a predictable cost ceiling:

```text
Cost ceiling = max_turns x avg_tokens_per_turn x rate

Example (Sonnet 4.6, moderate session):
  --max-turns 15
  Avg tokens/turn: 8,000 (4,000 input + 4,000 output)
  Input cost: 15 x 4,000 x $3/MTok = $0.18
  Output cost: 15 x 4,000 x $15/MTok = $0.90
  Cost ceiling: $1.08

  Without --max-turns (session runs to 40 turns):
  Input cost: 40 x 6,000 x $3/MTok = $0.72
  Output cost: 40 x 4,000 x $15/MTok = $2.40
  Potential cost: $3.12
```

## Usage Examples

### Basic Usage

```bash
# Prevent a simple question from spiraling
claude --max-turns 5 -p "What does the handleWebhook function in src/api/webhooks.ts do?"
# Guaranteed to complete in 5 turns or less
# Max cost: ~$0.20 on Sonnet 4.6
```

### Advanced: CI Pipeline Integration

```bash
#!/bin/bash
# .github/scripts/claude-pr-review.sh
# Automated PR review with hard cost cap
set -euo pipefail

CHANGED_FILES=$(git diff --name-only HEAD~1 | head -20)
MAX_TURNS=10

claude --max-turns "$MAX_TURNS" \
  --allowedTools "Read,Glob,Grep" \
  -p "Review these changed files for bugs, security issues, and style problems:
$CHANGED_FILES

Output a summary with: file, line, severity (high/medium/low), description.
If no issues found, say 'No issues found.'"

# Worst case: 10 turns x ~5,000 tokens = 50,000 tokens = $0.15
# vs. unbounded: could read entire codebase at 200K+ tokens = $0.60+
```

## Token Usage Measurements

| Task | Turns (Unbounded) | Turns (Capped) | Token Savings | Cost Savings |
|------|-------------------|----------------|---------------|-------------|
| Explain function | 3-5 | 5 (cap not hit) | 0 | $0.00 |
| Bug fix (clear) | 8-12 | 15 (cap not hit) | 0 | $0.00 |
| Bug fix (unclear) | 20-40 | 15 (cap hit) | 50K-200K | $0.30-$1.00 |
| Feature (scoped) | 15-25 | 25 (cap not hit) | 0 | $0.00 |
| Feature (vague prompt) | 30-60 | 25 (cap hit) | 80K-350K | $0.50-$1.50 |

The flag provides value primarily as insurance: it costs nothing on well-scoped tasks but prevents expensive runaway sessions on poorly-scoped ones. A developer encountering 2-3 runaway sessions per week saves $3-$9 weekly ($12-$36/month).

### Advanced: Dynamic Turn Limits Based on Task Complexity

For teams that want automated cost control without manual alias selection:

```bash
#!/bin/bash
# scripts/claude-smart.sh
# Automatically sets --max-turns based on prompt complexity heuristics
set -uo pipefail

PROMPT="$*"
WORD_COUNT=$(echo "$PROMPT" | wc -w | tr -d ' ')
FILE_COUNT=$(echo "$PROMPT" | grep -oP 'src/[^\s]+' | wc -l | tr -d ' ')

# Simple heuristic: more files or longer prompts get more turns
if [ "$WORD_COUNT" -lt 20 ] && [ "$FILE_COUNT" -le 1 ]; then
  MAX_TURNS=8    # Simple task
elif [ "$WORD_COUNT" -lt 50 ] && [ "$FILE_COUNT" -le 3 ]; then
  MAX_TURNS=15   # Moderate task
else
  MAX_TURNS=25   # Complex task
fi

echo "Auto-selected --max-turns $MAX_TURNS (${WORD_COUNT} words, ${FILE_COUNT} file refs)"
claude --max-turns "$MAX_TURNS" -p "$PROMPT"
```

```bash
chmod +x scripts/claude-smart.sh

# Usage:
./scripts/claude-smart.sh "Fix the typo in src/config.ts"
# Auto-selected --max-turns 8

./scripts/claude-smart.sh "Refactor the payment service in src/services/payment.ts and update tests in src/services/payment.test.ts and the route handler in src/routes/billing.ts"
# Auto-selected --max-turns 25
```

### What Happens When --max-turns Is Reached

When Claude Code hits the turn limit, it stops execution and returns whatever work was completed. This means:

- Edits already made are preserved (files are modified on disk)
- Commands already run have their effects (git commits, file creations)
- Incomplete tasks are left in a partial state

Best practice: choose turn limits that are slightly generous rather than too tight. An 8-turn limit on a 6-turn task costs nothing extra (unused turns are free), but a 4-turn limit on a 6-turn task leaves work incomplete, requiring a second session (additional cost for context rebuilding).

## Comparison with Alternatives

| Cost Control Method | Prevents Runaways | Granularity | Setup Effort |
|--------------------|--------------------|-------------|-------------|
| --max-turns (this guide) | Yes (hard cap) | Per-session | Zero |
| --allowedTools | Reduces overhead | Per-tool | Low |
| /compact (manual) | Reduces context | On-demand | None |
| Scoped prompts | Reduces exploration | Per-prompt | None |
| API spend limits | Yes (Anthropic dashboard) | Per-billing period | Low |

Best practice: combine `--max-turns` with `--allowedTools` for defense-in-depth cost control.

## Troubleshooting

**Task not complete when turns expire**: Increase the turn limit or break the task into smaller pieces. If a bug fix consistently needs 20+ turns, the prompt likely needs better scoping with specific file paths and error descriptions.

**Cap too aggressive for interactive sessions**: `--max-turns` is most useful for automated/headless sessions. In interactive mode, manual session control is often sufficient since the developer can stop the session.

**Finding the right turn limit**: Start generous and tighten over time. Track actual turns used per task type with `ccusage`, then set limits at the 90th percentile. If 90% of bug fixes complete in 12 turns, set the limit at 15 (with buffer). This data-driven approach avoids both waste (too many turns) and frustration (too few turns).

**Turns consumed by retries**: If Claude Code spends 5 turns retrying a failing command, the turn budget is wasted on diagnostic loops. Fix this by adding error handling rules to CLAUDE.md: "If a command fails twice, stop and report the error instead of retrying." This single CLAUDE.md rule can save 3-5 turns per session that would otherwise be wasted on futile retry loops.

## Related Guides

- [Claude Code --allowedTools Flag: Restrict Tool Calls to Save Tokens](/claude-code-allowed-tools-flag-save-tokens/) -- complementary cost control
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- mid-session context reduction
- [Cost Optimization Hub](/cost-optimization/) -- all cost control techniques

- [Claude Flow tool guide](/claude-flow-tool-guide/) — How to use Claude Flow for multi-agent orchestration
