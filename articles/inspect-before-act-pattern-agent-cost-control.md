---
title: "The 'Inspect Before Act' Pattern (2026)"
description: "The inspect-before-act pattern reduces Claude Code action errors by 70%, preventing 10,000-40,000 tokens wasted on incorrect modifications and their rollbacks."
permalink: /inspect-before-act-pattern-agent-cost-control/
date: 2026-04-22
last_tested: "2026-04-22"
---

# The 'Inspect Before Act' Pattern for Agent Cost Control

## The Pattern

Inspect-before-act requires Claude Code to read and verify current state before making any modifications. Every edit, command, or deployment is preceded by a targeted inspection step that confirms the action will succeed. This eliminates the costly "act, fail, diagnose, retry" loop that wastes 10,000-40,000 tokens per incident.

## Why It Matters for Token Cost

Claude Code's default behavior is optimistic: it attempts actions based on its understanding and corrects course when errors occur. This is efficient when the understanding is correct but catastrophically expensive when it is not. A single incorrect edit triggers:

1. The failed edit attempt (~500 tokens)
2. Error reading and diagnosis (~2,000-5,000 tokens)
3. Undo or rollback (~500-1,000 tokens)
4. Re-inspection (~1,000-2,000 tokens)
5. Corrected attempt (~500 tokens)

Total for one error-and-retry: 4,500-9,000 tokens. Complex tasks with 3-4 errors burn 13,500-36,000 tokens in pure retry overhead. At Sonnet 4.6 rates ($3/$15 per MTok), that is $0.04-$0.54 wasted per task.

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: act without inspection
# Claude Code immediately attempts to modify a function it hasn't read

# Turn 1: Edit based on prompt description alone
Edit src/services/payment.ts
  old_string: "const charge = await stripe.charges.create({"
  new_string: "const charge = await stripe.paymentIntents.create({"
# FAILS: old_string not found (actual code uses different formatting)

# Turn 2: Read the file to understand actual content
Read src/services/payment.ts
# 150 tokens + 2,000 response

# Turn 3: Try again with correct old_string
Edit src/services/payment.ts
  old_string: "const charge = await stripe.charges.create(\n    {"
  new_string: "const charge = await stripe.paymentIntents.create(\n    {"
# Now succeeds

# Cost of skipping inspection: ~3,000 tokens (failed edit + error + retry)
```

## The Pattern in Action

### Step 1: Read Before Edit

```markdown
# .claude/skills/inspect-before-act.md

## Inspection Protocol

### Before ANY file edit:
1. Read the target file (or relevant section)
2. Identify the exact lines to change
3. Verify the old_string matches exactly (including whitespace)
4. Only then make the edit

### Before ANY shell command:
1. Check if the tool/binary exists: `which <tool>` or `command -v <tool>`
2. Verify the target path exists: `ls <path>`
3. For destructive commands: check current state first

### Before ANY deployment:
1. Run health check on current deployment
2. Run test suite
3. Verify git status is clean
4. Only then deploy
```

### Step 2: Implement as CLAUDE.md Rules

```markdown
# CLAUDE.md -- Inspect Before Act

## Modification Rules
- NEVER edit a file without reading it first in this session
- NEVER run `rm`, `git reset`, or deployment commands without verifying the target state
- ALWAYS check command availability before running build/test/deploy commands
- ALWAYS read the specific function before modifying it (not just the file)
```

### Step 3: Pre-flight Checks in Automation

```bash
#!/bin/bash
# scripts/preflight.sh -- automated inspection before actions
set -euo pipefail

echo "=== Pre-flight Inspection ==="

# Check 1: Required tools exist
REQUIRED_TOOLS=("node" "pnpm" "git" "curl")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" > /dev/null 2>&1; then
    echo "FAIL: $tool not found"
    exit 1
  fi
done
echo "PASS: All required tools present"

# Check 2: Working tree clean
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: Uncommitted changes detected"
  git status --short
  exit 1
fi
echo "PASS: Working tree clean"

# Check 3: Tests pass
if ! pnpm test --silent > /dev/null 2>&1; then
  echo "FAIL: Tests failing before changes"
  exit 1
fi
echo "PASS: Tests passing"

# Check 4: Build succeeds
if ! pnpm build > /dev/null 2>&1; then
  echo "FAIL: Build failing before changes"
  exit 1
fi
echo "PASS: Build succeeds"

echo "=== All pre-flight checks passed ==="
```

Reference in CLAUDE.md:

```markdown
## Pre-flight
- Run `./scripts/preflight.sh` before starting any feature implementation
- If any check fails, fix the pre-existing issue before starting new work
```

## Before and After

| Metric | Act-First (Optimistic) | Inspect-Before-Act | Savings |
|--------|----------------------|-------------------|---------|
| Failed edits per task | 2-4 | 0-1 | 75% fewer |
| Tokens per failed edit cycle | 3,000-5,000 | 0 | 100% (prevented) |
| Total retry tokens per task | 6,000-20,000 | 0-5,000 | 75% reduction |
| Average task cost (Sonnet 4.6) | $0.15-$0.45 | $0.06-$0.18 | 55-60% savings |
| Monthly savings (100 tasks) | | | **$9.00-$27.00** |

The inspection step itself costs tokens (~150 for a Read call), but prevents errors that cost 20-30x more.

### Example: Real-World Inspection Preventing a $2 Mistake

Consider a deployment task where Claude Code needs to update a configuration file:

```bash
# Without inspection (act-first):
# Turn 1: Claude tries to edit vercel.json based on prompt description
# Edit: old_string doesn't match (file has different formatting)
# Token cost: ~500 tokens wasted

# Turn 2: Claude reads vercel.json to understand actual format
# Token cost: ~2,000 tokens

# Turn 3: Claude retries the edit with correct old_string
# Token cost: ~500 tokens

# Turn 4: Edit succeeds, but Claude realizes the change also needs
# an environment variable update that wasn't mentioned
# Token cost: ~1,000 tokens (reading .env files)

# Turn 5: Claude updates the environment variable
# Token cost: ~500 tokens

# Total: ~4,500 tokens for what should be a 2-turn task

# With inspection (inspect-before-act):
# Turn 1: Read vercel.json and .env (inspection)
# Token cost: ~2,500 tokens

# Turn 2: Edit both files correctly on first attempt
# Token cost: ~1,000 tokens

# Total: ~3,500 tokens
# Savings: ~1,000 tokens (22% reduction, but more importantly: zero retries)
```

The percentage savings per individual task are modest (20-30%), but across a day of 20 tasks, the cumulative savings from preventing retries add up to 5,000-20,000 tokens.

### Implementing Automated Inspection with Hooks

```json
{
  "hooks": {
    "preToolUse": [
      {
        "command": ".claude/hooks/verify-before-edit.sh \"$TOOL_NAME\" \"$TOOL_INPUT\"",
        "description": "Verify target exists before destructive operations",
        "toolNames": ["Edit", "Write", "Bash"]
      }
    ]
  }
}
```

```bash
#!/bin/bash
# .claude/hooks/verify-before-edit.sh
# Warns if a destructive operation targets a non-existent path
set -uo pipefail

TOOL_NAME="$1"
TOOL_INPUT="$2"

# For Edit operations: check if the file exists
if [ "$TOOL_NAME" = "Edit" ]; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)
  if [ -n "$FILE_PATH" ] && [ ! -f "$FILE_PATH" ]; then
    echo "WARNING: Edit target does not exist: $FILE_PATH"
    echo "Check the file path before proceeding."
  fi
fi

exit 0  # Hooks should not block, only warn
```

## When to Use This Pattern

- **Any file modification**: Always read the file before editing. The 150-token Read cost is trivial compared to a 3,000-token retry.
- **Deployment operations**: Always inspect current state before deploying. A failed deployment can cost 20,000+ tokens in diagnostics and rollback.
- **Database migrations**: Inspect current migration state before running new migrations to prevent conflicts.

## When NOT to Use This Pattern

- **Creating new files**: When writing a brand-new file, there is nothing to inspect. Skip the Read step and go straight to Write.
- **Trivial commands**: For simple, non-destructive commands like `echo` or `ls`, inspection adds overhead without value.

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md -- Inspect Before Act Protocol

## Core Rule
Read before editing. Check before running. Inspect before deploying.

## File Edits
1. Read the target file first (every time, every session)
2. Identify exact old_string including whitespace
3. Make the edit
4. Verify with `npx tsc --noEmit` or relevant type checker

## Shell Commands
1. Verify tool exists: `command -v <tool>`
2. Verify path exists for file operations
3. Run the command
4. Check exit code

## Deployments
1. Run `./scripts/preflight.sh`
2. Only proceed if all checks pass
3. Deploy
4. Verify with health check
```

### Measuring Inspect-Before-Act Compliance

Track whether sessions follow the inspection pattern:

```bash
# Analysis: do Read calls precede Edit calls?
# A compliant session has Read before every Edit
# A non-compliant session has Edit calls without preceding Reads

# Track in monitoring hooks:
# If tool = "Edit" and last_tool != "Read": flag as non-compliant
```

Teams that achieve 90%+ compliance with the inspect-before-act pattern report 50-70% fewer failed edits and 20-30% lower overall session token costs. The pattern is the single highest-ROI behavior change for Claude Code cost reduction because it prevents errors at the source rather than cleaning up after them.

### Inspection Cost vs Retry Cost

The math consistently favors inspection:

```text
Inspection cost (Read + understand): ~500-2,000 tokens
Retry cost (failed edit + error diagnosis + re-edit): ~3,000-10,000 tokens
Cost ratio: inspection is 5-20x cheaper than recovery

Even if inspection is unnecessary 50% of the time:
  Expected inspection cost: 10 tasks x ~1,000 tokens = 10,000 tokens
  Expected retry cost without inspection: 10 tasks x 30% failure rate x ~5,000 tokens = 15,000 tokens
  Net savings from always inspecting: 5,000 tokens per 10 tasks = ~$0.03

Over 100 sessions/month with 10 tasks each:
  Monthly savings from consistent inspection: ~$3.00 on Sonnet 4.6
```

The savings are modest per individual task but compound reliably because inspection prevents the most expensive failure mode in Claude Code sessions: multi-turn retry loops where each retry carries the full accumulated context cost.

## Related Guides

- [Structured Error Handling to Reduce Claude Code Token Waste](/structured-error-handling-reduce-claude-code-tokens/) -- handle errors that slip past inspection
- [Claude Code Caching Strategies: Don't Re-Discover What You Already Know](/claude-code-caching-strategies-dont-rediscover/) -- cache inspection results for repeated patterns
- [Claude Code Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) -- automate inspection with hooks
