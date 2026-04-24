---
title: "Structured Error Returns (2026)"
description: "Reduce Claude Code token waste by 90% on error handling with structured error returns that replace verbose stack traces with agent-optimized output."
permalink: /structured-error-returns-format-affects-agent-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Structured Error Returns: How Error Format Affects Agent Token Usage

## The Pattern

Structured error returns replace verbose, human-oriented error output with concise, machine-parseable formats that reduce agent token consumption by 90-97% per error encounter.

## Why It Matters for Token Cost

When Claude Code runs a command that fails, the entire error output enters the context window. A typical Node.js stack trace is 500-2,000 tokens. A TypeScript compiler error dump can be 2,000-10,000 tokens. A test suite failure report can be 5,000-20,000 tokens.

These tokens are not just read once. They persist in the context window and are re-read on every subsequent turn. A 5,000-token error output in a 20-turn debugging session costs 100,000 input tokens ($0.30 on Sonnet 4.6, $1.50 on Opus 4.6) just to carry that error in context.

Structured error returns reduce the error output to 50-200 tokens, cutting the carry cost to 1,000-4,000 tokens over the same session. The savings compound with each error encountered in the session.

## The Anti-Pattern (What NOT to Do)

```bash
#!/bin/bash
# build.sh -- unstructured error output (expensive)
npm run build
# Raw output on failure:
#
# src/api/routes/users.ts(34,15): error TS2345: Argument of type 'string'
# is not assignable to parameter of type 'number'.
#   34 |   const user = await findUser(req.params.id);
#      |               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   The expected type comes from property 'id' which is declared here in
#   type 'FindUserParams'
#     12 |   id: number;
#        |   ~~~~~~~~~~
# src/api/routes/users.ts(47,3): error TS2322: Type 'string | undefined'
# is not assignable to type 'string'.
# ... (continues for 50+ lines)
#
# Token cost: 2,000-10,000 tokens per build failure
```

Claude reads the entire output, processes every error, and may attempt to fix all of them simultaneously, leading to large edits and potential retry loops.

## The Pattern in Action

### Step 1: Create a Structured Build Wrapper

```bash
#!/bin/bash
# build-structured.sh -- agent-optimized error output
set -uo pipefail

MAX_ERRORS=3
output=$(npm run build 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "STATUS: BUILD_SUCCESS"
    exit 0
fi

echo "STATUS: BUILD_FAILED"
echo "EXIT_CODE: $exit_code"

# Count total errors
error_count=$(echo "$output" | grep -c "error TS" || true)
echo "TOTAL_ERRORS: $error_count"

# Show first N errors in compact format
echo "FIRST_ERRORS:"
echo "$output" | grep "error TS" | head -n "$MAX_ERRORS" | while read -r line; do
    # Extract file:line and error message
    file=$(echo "$line" | grep -oP '[^/]+\.ts\(\d+' | head -1)
    code=$(echo "$line" | grep -oP 'TS\d+' | head -1)
    msg=$(echo "$line" | grep -oP '(?<=: ).*' | head -c 100)
    echo "  $file | $code | $msg"
done

if [ "$error_count" -gt "$MAX_ERRORS" ]; then
    echo "... $((error_count - MAX_ERRORS)) more (fix these $MAX_ERRORS first)"
fi
```

**Token cost: 100-200 tokens per build failure.** Reduction: 95-98%.

### Step 2: Create a Structured Test Wrapper

```bash
#!/bin/bash
# test-structured.sh -- agent-optimized test output
set -uo pipefail

MAX_FAILURES=3
output=$(npm test -- --json 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    passed=$(echo "$output" | grep -oP '"numPassedTests":\d+' | grep -oP '\d+')
    echo "STATUS: ALL_PASSED ($passed tests)"
    exit 0
fi

echo "STATUS: TESTS_FAILED"

# Parse JSON output for failures
echo "$output" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    failed = data.get('numFailedTests', 0)
    passed = data.get('numPassedTests', 0)
    print(f'PASSED: {passed}')
    print(f'FAILED: {failed}')
    count = 0
    for suite in data.get('testResults', []):
        for test in suite.get('testResults', []):
            if test['status'] == 'failed' and count < $MAX_FAILURES:
                name = test['fullName'][:80]
                msg = (test.get('failureMessages') or [''])[0][:150]
                print(f'  FAIL: {name}')
                print(f'    MSG: {msg}')
                count += 1
except Exception as e:
    print(f'PARSE_ERROR: {e}')
" 2>/dev/null

exit $exit_code
```

**Token cost: 150-300 tokens per test failure.** Versus raw Jest output: 2,000-15,000 tokens.

### Step 3: Register Wrappers in CLAUDE.md

```markdown
# CLAUDE.md

## Build & Test Commands
- Build: ./scripts/build-structured.sh (NOT npm run build directly)
- Test all: ./scripts/test-structured.sh (NOT npm test directly)
- Test one: npm test -- --testPathPattern="<file>" (OK for single tests)

## Error Handling
- Read structured output before attempting fixes
- Fix errors one at a time, starting with the first reported
- Maximum 3 fix attempts per error, then report to developer
```

## Before and After

| Metric | Unstructured Errors | Structured Errors | Savings |
|--------|-------------------|-------------------|---------|
| Tokens per build error | 2,000-10,000 | 100-200 | 95-98% |
| Tokens per test failure | 2,000-15,000 | 150-300 | 93-98% |
| Context carry cost (20 turns) | 40K-200K | 2K-6K | 95-97% |
| Fix attempts per error | 3-5 | 1.5-2.5 | 40-50% fewer |
| Monthly cost (5 errors/day, Sonnet) | $40-$100 | $2-$5 | $38-$95 saved |

## When to Use This Pattern

- **Always** for build commands that produce verbose output
- **Always** for test suites with more than 10 tests
- **Always** for linting tools that report multiple issues
- When working on projects where errors are a daily occurrence during development

## When NOT to Use This Pattern

- For one-off debugging sessions where the full stack trace is genuinely needed (run the raw command manually)
- For simple scripts with single-line error output
- When the structured wrapper would be more complex than the command itself

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md

## Error Output Rules
- Always use structured wrappers in scripts/ for build, test, and lint
- If a raw command produces more than 20 lines of error output, use head -20
- Parse errors one at a time: fix the FIRST error, then re-run
- Never attempt to fix all errors in a single edit
- After 3 failed fix attempts, stop and report

## Available Wrappers
- scripts/build-structured.sh -- build with truncated errors
- scripts/test-structured.sh -- test with parsed failures
- scripts/lint-structured.sh -- lint with top-3 issues
```

## Implementing Across Common Tools

### Structured Wrapper for ESLint

```bash
#!/bin/bash
# lint-structured.sh
set -uo pipefail

MAX_ISSUES=5
output=$(npx eslint src/ --format json 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "STATUS: LINT_PASSED"
    exit 0
fi

echo "STATUS: LINT_FAILED"
total=$(echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
total = sum(len(f.get('messages',[])) for f in data)
print(total)
" 2>/dev/null || echo "?")
echo "TOTAL_ISSUES: $total"
echo "FIRST_ISSUES:"
echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = 0
for f in data:
    for msg in f.get('messages', []):
        if count >= $MAX_ISSUES:
            break
        print(f\"  {f['filePath'].split('/')[-1]}:{msg['line']} [{msg['ruleId']}] {msg['message'][:80]}\")
        count += 1
" 2>/dev/null
exit $exit_code
```

Raw ESLint output for a project with 50 issues: 3,000-15,000 tokens. Structured output: 200-400 tokens. **Savings: 93-97%.**

### Structured Wrapper for TypeScript Compiler

```bash
#!/bin/bash
# tsc-structured.sh
set -uo pipefail

MAX_ERRORS=5
output=$(npx tsc --noEmit 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "STATUS: TYPE_CHECK_PASSED"
    exit 0
fi

error_count=$(echo "$output" | grep -c "error TS" || true)
echo "STATUS: TYPE_CHECK_FAILED"
echo "TOTAL_ERRORS: $error_count"
echo "FIRST_ERRORS:"
echo "$output" | grep "error TS" | head -n "$MAX_ERRORS" | while IFS= read -r line; do
    # Compact format: file:line TScode message
    echo "  $(echo "$line" | sed 's/(.*//' | sed 's#.*/##'):$(echo "$line" | grep -oP '\d+,' | head -1 | tr -d ',') $(echo "$line" | grep -oP 'TS\d+') $(echo "$line" | grep -oP '(?<=: ).*' | head -c 80)"
done

if [ "$error_count" -gt "$MAX_ERRORS" ]; then
    echo "  ... and $((error_count - MAX_ERRORS)) more (fix these first)"
fi
exit $exit_code
```

### Integrating Wrappers into the Workflow

Store all wrappers in `scripts/` and document in CLAUDE.md:

```markdown
# CLAUDE.md

## Build/Test Commands (USE THESE, not raw commands)
- Build: ./scripts/build-structured.sh
- Test: ./scripts/test-structured.sh
- Lint: ./scripts/lint-structured.sh
- Type check: ./scripts/tsc-structured.sh

## Raw commands (only when you need full output for debugging):
- npm run build
- npm test
- npx eslint src/
- npx tsc --noEmit
```

The structured wrappers become the default interface for Claude Code. Raw commands are available as fallback but should only be used when the structured output is insufficient for diagnosis. Over time, the structured wrappers accumulate coverage for all build, test, and lint tools in the project, creating a complete agent-friendly error interface.

## Measuring the Impact

Track error-related token consumption before and after implementing structured wrappers:

```bash
# Before: run 5 build/test cycles with errors, record /cost after each
# After: run 5 equivalent cycles with structured wrappers, record /cost

# Expected reduction:
# Build errors: 90-95% token reduction per error encounter
# Test failures: 85-95% token reduction per failure
# Lint issues: 93-97% token reduction per lint run
# Type errors: 90-95% token reduction per type check

# Monthly savings estimate (3 error encounters/day, Sonnet):
# Before: 3 x 5,000 avg tokens x 22 days = 330K tokens = $0.99/month
# After: 3 x 300 avg tokens x 22 days = 19.8K tokens = $0.06/month
# Direct savings: $0.93/month

# Indirect savings (fewer retries due to clearer errors):
# Estimated 2 fewer retry cycles/day x 15K tokens = 30K tokens/day
# Monthly: 660K tokens = $1.98/month
# Total savings: $2.91/month per developer
```

## Related Guides

- [The Retry Loop Tax](/retry-loop-tax-error-handling-token-cost/) -- how errors lead to expensive loops
- [Semantic Exit Codes](/semantic-exit-codes-help-claude-code-debug-faster/) -- complementary pattern for exit codes
- [Errors Atlas](/errors-atlas/) -- error reference for Claude Code
