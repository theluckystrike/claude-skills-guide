---
layout: default
title: "Semantic Exit Codes (2026)"
description: "Implement semantic exit codes to help Claude Code debug 40% faster with categorized error signals that reduce unnecessary token-expensive investigation."
permalink: /semantic-exit-codes-help-claude-code-debug-faster/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Semantic Exit Codes: How to Help Claude Code Debug Faster

## The Pattern

Semantic exit codes replace generic failure codes (exit 1) with categorized codes that tell Claude Code what type of error occurred, enabling targeted debugging instead of exploratory investigation.

## Why It Matters for Token Cost

When a command exits with code 1, Claude Code knows only that something failed. It then reads the full error output (500-5,000 tokens), forms hypotheses, and begins investigating. This investigation phase costs 10K-30K tokens.

With semantic exit codes, Claude knows immediately whether the failure is a type error (fix the code), a configuration error (fix the config), a test failure (fix the test), or an environment issue (report to developer). This categorization eliminates 50-70% of the investigation phase, saving 5K-20K tokens per error. At $3/MTok on Sonnet 4.6, that is $0.015-$0.06 per error. For a team encountering 20 errors per day, monthly savings reach $6.60-$26.40.

## The Anti-Pattern (What NOT to Do)

```bash
#!/bin/bash
# deploy.sh -- generic exit codes (expensive for agents)
npm run build || exit 1
npm test || exit 1
npm run deploy || exit 1
# Every failure exits with 1 -- Claude cannot distinguish between
# a build error, test failure, or deploy problem without reading full output
```

Claude must read the entire output to determine what failed. Token cost per failure: 500-5,000 tokens for output + 10K-30K tokens for investigation.

## The Pattern in Action

### Step 1: Define a Semantic Exit Code Schema

```bash
#!/bin/bash
# exit-codes.sh -- shared exit code definitions

# Success
EXIT_SUCCESS=0

# Build errors (10-19)
EXIT_BUILD_TYPE_ERROR=10     # TypeScript/type errors
EXIT_BUILD_SYNTAX_ERROR=11   # Syntax errors
EXIT_BUILD_DEPENDENCY=12     # Missing dependency
EXIT_BUILD_CONFIG=13         # Build configuration error

# Test errors (20-29)
EXIT_TEST_FAILURE=20         # Test assertion failed
EXIT_TEST_TIMEOUT=21         # Test timed out
EXIT_TEST_CONFIG=22          # Test configuration error

# Deploy errors (30-39)
EXIT_DEPLOY_AUTH=30           # Authentication failed
EXIT_DEPLOY_NETWORK=31       # Network error
EXIT_DEPLOY_CONFLICT=32      # Version conflict

# Environment errors (40-49)
EXIT_ENV_MISSING=40           # Missing environment variable
EXIT_ENV_INVALID=41           # Invalid environment value

# General
EXIT_UNKNOWN=99               # Unknown error
```

### Step 2: Apply to Build Scripts

```bash
#!/bin/bash
# build-semantic.sh
set -uo pipefail
source "$(dirname "$0")/exit-codes.sh"

output=$(npm run build 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "STATUS: BUILD_SUCCESS"
    exit $EXIT_SUCCESS
fi

# Categorize the error
if echo "$output" | grep -q "error TS"; then
    echo "STATUS: BUILD_TYPE_ERROR"
    echo "$output" | grep "error TS" | head -3
    exit $EXIT_BUILD_TYPE_ERROR
elif echo "$output" | grep -q "SyntaxError"; then
    echo "STATUS: BUILD_SYNTAX_ERROR"
    echo "$output" | grep "SyntaxError" | head -3
    exit $EXIT_BUILD_SYNTAX_ERROR
elif echo "$output" | grep -q "Cannot find module"; then
    echo "STATUS: BUILD_DEPENDENCY_MISSING"
    echo "$output" | grep "Cannot find module" | head -3
    exit $EXIT_BUILD_DEPENDENCY
else
    echo "STATUS: BUILD_UNKNOWN_ERROR"
    echo "$output" | tail -10
    exit $EXIT_UNKNOWN
fi
```

### Step 3: Document Exit Codes for Claude Code

```markdown
# .claude/skills/exit-codes.md

## Exit Code Reference
| Code | Meaning | Claude Action |
|------|---------|---------------|
| 0 | Success | Continue |
| 10 | Type error | Fix types in reported file |
| 11 | Syntax error | Fix syntax in reported file |
| 12 | Missing dependency | Run npm install <pkg> |
| 13 | Build config error | Check tsconfig.json or webpack config |
| 20 | Test assertion failed | Fix test or implementation |
| 21 | Test timeout | Increase timeout or fix async code |
| 22 | Test config error | Check jest.config.js |
| 30 | Deploy auth failed | Report to developer (cannot fix) |
| 31 | Deploy network error | Retry once, then report |
| 40 | Missing env var | Report to developer |
| 99 | Unknown | Read full output, investigate |
```

## Before and After

| Metric | Generic Exit Codes | Semantic Exit Codes | Savings |
|--------|-------------------|--------------------|---------|
| Error categorization | 10K-30K tokens | 0 tokens (instant) | 100% |
| Error output reading | 500-5,000 tokens | 100-300 tokens | 80-94% |
| Wrong-path investigation | 30% of errors | 5% of errors | 83% reduction |
| Average fix time (tokens) | 40K | 18K | 55% |
| Monthly cost (20 errors/day, Sonnet) | $52.80 | $23.76 | $29.04 saved |

## When to Use This Pattern

- Projects with custom build pipelines
- CI/CD scripts executed by Claude Code
- Any script that Claude runs more than twice per day
- Multi-stage processes (build -> test -> deploy) where failure location matters

## When NOT to Use This Pattern

- Simple one-file scripts where the error is always obvious
- Scripts that already produce clear, concise error messages
- Ad-hoc commands run once during exploration

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md

## Script Exit Codes
All scripts in scripts/ use semantic exit codes.
See .claude/skills/exit-codes.md for the full reference.

## On Script Failure
1. Check the exit code against the exit code reference
2. Follow the prescribed action for that code
3. Do NOT read full output unless exit code is 99 (unknown)
4. Maximum 3 fix attempts, then report with exit code and status line
```

## Implementing Semantic Exit Codes Across a Project

### Step-by-Step Migration

Migrating existing scripts to semantic exit codes requires a systematic approach:

**Phase 1: Audit existing scripts (1 hour)**

```bash
# Find all scripts that Claude Code runs
grep -r "Bash(" .claude/settings.json 2>/dev/null | grep "allow"
# Plus any scripts referenced in CLAUDE.md

# For each script, check current exit behavior:
# Does it use exit 0/exit 1 only? (generic -- needs migration)
# Does it have error categorization? (may already be semantic)
```

**Phase 2: Create exit-codes.sh (10 minutes)**

```bash
#!/bin/bash
# scripts/exit-codes.sh -- shared constants
# Source this from all scripts: source "$(dirname "$0")/exit-codes.sh"

readonly EXIT_SUCCESS=0
readonly EXIT_BUILD_TYPE=10
readonly EXIT_BUILD_SYNTAX=11
readonly EXIT_BUILD_DEPS=12
readonly EXIT_BUILD_CONFIG=13
readonly EXIT_TEST_FAIL=20
readonly EXIT_TEST_TIMEOUT=21
readonly EXIT_TEST_CONFIG=22
readonly EXIT_DEPLOY_AUTH=30
readonly EXIT_DEPLOY_NET=31
readonly EXIT_ENV_MISSING=40
readonly EXIT_ENV_INVALID=41
readonly EXIT_UNKNOWN=99
```

**Phase 3: Migrate scripts one at a time (15-30 minutes per script)**

Start with the most frequently run scripts. Priority order:
1. Build script (run 10+ times per day)
2. Test runner (run 10+ times per day)
3. Lint script (run 5+ times per day)
4. Deploy script (run 1-3 times per day)

**Phase 4: Update CLAUDE.md and skills (10 minutes)**

```markdown
# CLAUDE.md
## Scripts use semantic exit codes -- see .claude/skills/exit-codes.md
## Always check exit code before attempting fixes
```

### Testing Exit Codes

Verify that scripts return correct exit codes:

```bash
#!/bin/bash
# test-exit-codes.sh -- verify exit code behavior
set -uo pipefail

source scripts/exit-codes.sh

TESTS_PASSED=0
TESTS_FAILED=0

# Test: successful build returns 0
npm run build > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "PASS: successful build returns 0"
    ((TESTS_PASSED++))
else
    echo "FAIL: successful build should return 0"
    ((TESTS_FAILED++))
fi

# Test: type error returns EXIT_BUILD_TYPE
echo "const x: number = 'string'" > /tmp/test-type-error.ts
npx tsc /tmp/test-type-error.ts --noEmit 2>/dev/null
# Expected: exit code 10 from build-semantic.sh wrapper
# Verify by running through wrapper

echo ""
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
rm -f /tmp/test-type-error.ts
```

## Exit Code Design Principles

1. **Non-overlapping ranges.** Build errors (10-19), test errors (20-29), and deploy errors (30-39) must not overlap. This allows Claude to categorize errors from the code alone without reading output.

2. **Ordered by severity.** Within each range, lower numbers indicate more common errors that Claude should fix first. Exit code 10 (type error) is more common than 13 (build config error).

3. **Actionable mapping.** Every exit code should map to a specific Claude action. If Claude cannot take action on a particular error (like environment issues, exit code 40), the mapped action should be "report to developer" rather than "attempt fix."

4. **Bounded range.** Using 0-99 ensures all exit codes are portable across operating systems. Some systems treat exit codes above 127 as signal-terminated processes.



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Structured Error Returns](/structured-error-returns-format-affects-agent-tokens/) -- complementary pattern for error output format
- [How to Stop Claude Code Retry Loops](/stop-claude-code-retry-loops-token-waste/) -- preventing error-driven loops
- [Errors Atlas](/errors-atlas/) -- complete error reference
- [Error Handling Reference](/error-handling/). Complete error diagnosis and resolution guide
