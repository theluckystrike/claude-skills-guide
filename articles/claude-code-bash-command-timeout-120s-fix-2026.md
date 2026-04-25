---
layout: default
title: "Claude Code Bash Command Timeout 120s — Fix (2026)"
permalink: /claude-code-bash-command-timeout-120s-fix-2026/
date: 2026-04-20
description: "Set an explicit timeout parameter to fix the 120-second command timeout. Use background execution mode for long-running builds and test suites."
last_tested: "2026-04-21"
---

## The Error

```
Command timed out after 120000ms
```

## The Fix

```bash
# When invoking long-running commands, set a longer timeout (up to 600000ms)
# In your prompt, instruct Claude to use the timeout parameter:

# Example: for a build that takes 3 minutes
# Tell Claude: "Run the build with a 300000ms timeout"

# Or use background execution for commands that don't need immediate output:
# Tell Claude: "Run this in the background"
```

## Why This Works

Claude Code's Bash tool defaults to a 120-second (120000ms) timeout. Commands like `npm install` on large projects, full test suites, or Docker builds regularly exceed this. The timeout parameter accepts values up to 600000ms (10 minutes), and background execution removes the limit entirely by running asynchronously.

## If That Doesn't Work

```bash
# Break the command into smaller chunks
npm install --prefer-offline  # faster, uses cache
npx jest --testPathPattern="src/module"  # subset of tests

# Or split a large build:
tsc --noEmit --project tsconfig.json 2>&1 | head -50
```

Splitting work into bounded operations keeps each call under the timeout ceiling.

## Prevention

Add to your CLAUDE.md:
```
For commands expected to exceed 60 seconds (builds, full test suites, large installs), always specify timeout: 300000 or use background execution. Never rely on the default 120s timeout for CI-scale operations.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Timeout Configuration Reference

Claude Code has several timeout settings that interact with each other:

| Setting | Default | Controls | How to Change |
|---------|---------|----------|---------------|
| Bash timeout | 120s | Maximum time for a single bash command | `CLAUDE_CODE_BASH_TIMEOUT=600` |
| API timeout | 300s | Maximum time waiting for API response | Network-level setting |
| Session timeout | None | Auto-close after inactivity | Not currently configurable |
| MCP server init | 30s | Time allowed for MCP server startup | Set in settings.json |

## Diagnosing Slow Operations

When Claude Code appears to hang, determine which component is slow:

**Step 1: Check CPU and memory.** Run `top -l 1 | grep -E "node|claude"` (macOS) or `top -bn1 | grep -E "node|claude"` (Linux). High CPU suggests active computation. High memory (over 1GB) suggests the conversation context is too large.

**Step 2: Check network connectivity.** Run `curl -s -o /dev/null -w "%{time_total}" https://api.anthropic.com/v1/messages`. Response times over 2 seconds indicate network issues between you and the API.

**Step 3: Check disk I/O.** Run `iostat 1 3` to see if disk is a bottleneck. Claude Code performs significant file reads when scanning large projects. An SSD reduces file scanning from minutes to seconds.

**Step 4: Reduce context size.** If the session has been running for many turns, accumulated context can slow API responses. Use `/clear` to reset the conversation and start fresh with a smaller context window.
