---
layout: post
title: "Claude Code Verbose Mode: Debug Output Guide 2026"
description: "Enable verbose mode in Claude Code for detailed API logs, token counts, and request tracing. Essential for debugging and cost optimization."
permalink: /claude-code-verbose-mode-debug-output-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Enable verbose and debug output in Claude Code to inspect API requests, token usage, tool calls, and timing data. Essential for diagnosing unexpected behavior, optimizing costs, and understanding how Claude Code processes your prompts.

Expected time: 5 minutes
Prerequisites: Claude Code CLI installed (v1.0+)

## Setup

### 1. Enable Verbose Mode

```bash
# Run Claude Code with verbose flag
claude --verbose

# Or set environment variable for persistent verbose output
export CLAUDE_CODE_VERBOSE=1
claude
```

Verbose mode shows tool calls, file reads, and decision-making steps as they happen.

### 2. Enable Debug Mode for Full API Traces

```bash
# Full debug output including API request/response bodies
claude --debug

# Or via environment variable
export CLAUDE_CODE_DEBUG=1
claude
```

Debug mode adds raw API payloads, token counts per message, and latency measurements.

### 3. Log Output to a File

```bash
# Redirect verbose output to a file while keeping normal output in terminal
claude --verbose 2> claude-debug.log

# Or capture everything
claude --debug 2>&1 | tee claude-session.log
```

### 4. Configure Verbose in Settings

```json
// ~/.claude/settings.json
{
  "verbosity": "verbose",
  "showTokenUsage": true,
  "showToolCalls": true,
  "showTimings": true
}
```

Persistent settings avoid passing flags every time.

### 5. Verify

```bash
claude --verbose --print "Hello"
# Expected output includes:
# [debug] Model: claude-sonnet-4-20250514
# [debug] Input tokens: 42
# [debug] Output tokens: 12
# [debug] Latency: 1.2s
# [debug] Cost: $0.0003
# Hello!
```

## Usage Example

Debugging a prompt that produces unexpected behavior:

```bash
# Start with verbose to see what Claude Code is doing
claude --verbose

> Read src/config.ts and explain the database configuration
```

Verbose output reveals:

```
[tool_call] Read file: src/config.ts (245 lines, 4.2KB)
[context] Added to context: src/config.ts
[context] Total context: 1,234 tokens (of 200,000 limit)
[api_call] Sending request...
  Model: claude-sonnet-4-20250514
  System prompt: 847 tokens
  User message: 89 tokens
  Context files: 312 tokens
  Total input: 1,248 tokens
[api_response] Received in 2.3s
  Output tokens: 456
  Stop reason: end_turn
  Cost this turn: $0.0021
[session_total]
  Input tokens: 1,248
  Output tokens: 456
  Total cost: $0.0021
```

Diagnosing why Claude Code reads too many files:

```bash
claude --debug

> Fix the bug in the login handler

# Debug output shows:
[tool_call] Glob: src/**/*.ts (found 847 files)
[tool_call] Read file: src/auth/login.ts
[tool_call] Read file: src/auth/types.ts
[tool_call] Read file: src/middleware/auth.ts
[tool_call] Read file: src/db/users.ts
[tool_call] Read file: src/utils/crypto.ts
[tool_call] Read file: src/config/auth.ts
[context] WARNING: 6 files read, 12,400 tokens used for context
```

You can see Claude Code is reading 6 files. To reduce this (and costs), create a more targeted `.claudeignore` or more specific prompt:

```bash
> Fix the bug in src/auth/login.ts where the session token
> is not being refreshed on password change. Only modify login.ts.
```

Tracking costs across a session:

```bash
# Run with token tracking
claude --verbose --session "cost-audit"

# After multiple interactions, check cumulative usage
> /usage
# Output:
# Session: cost-audit
# Total input tokens: 45,230
# Total output tokens: 12,847
# Estimated cost: $0.087
# Files read: 23
# Tool calls: 31
# Duration: 14m 22s
```

Using verbose output for CI debugging:

```bash
#!/bin/bash
# ci-review.sh - Run code review with full logging
LOG="review-$(date +%s).log"

claude --verbose --print \
  "Review the changes in this PR for security issues. \
   Check src/api/ files only." \
  2> "$LOG"

# Parse the log for cost data
grep "Total cost" "$LOG"
grep "tool_call" "$LOG" | wc -l
```

## Common Issues

- **Verbose output clutters the terminal:** Use `2> /dev/null` to suppress debug output when you only want the result, or redirect to a file with `2> debug.log`.
- **Token counts don't match billing:** Verbose shows estimated tokens. Actual billing may differ slightly due to tokenizer differences between display and API.
- **Debug mode reveals API key in logs:** Debug output redacts API keys by default, but always review log files before sharing them publicly.

## Why This Matters

Verbose mode reveals exactly how many tokens each interaction costs. Teams using verbose output for a week typically identify 20-40% cost reduction opportunities by optimizing prompts and reducing unnecessary file reads.

## Related Guides

- [Claude Code for Cost Optimization Monitoring Guide](/claude-code-for-cost-optimization-monitoring-guide/)
- [Claude Code Common Beginner Mistakes to Avoid](/claude-code-common-beginner-mistakes-to-avoid/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
