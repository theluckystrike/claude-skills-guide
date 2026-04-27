---
sitemap: false
layout: default
title: "Fix: Claude Code 2m Bash Timeout (2026)"
description: "Claude Code kills bash commands after 2 minutes by default. Learn how to increase the timeout for long-running builds, tests, and deployments."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-timeout-2m-fix/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, timeout, bash, performance, configuration]
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix: Claude Code Timeout 2m Bash Command Limit

## The Error

A long-running bash command in Claude Code gets killed after approximately 2 minutes. This commonly hits during `npm install`, `docker build`, `cargo build`, test suites, database migrations, and deployment scripts.

## Quick Fix

Ask Claude to run the command in the background:

```text
Run `npm install` in the background so it doesn't time out
```

Claude Code will run the command as a background task and check results when it completes.

## What Causes This

Claude Code's Bash tool has a default timeout of 120,000 milliseconds (2 minutes) for command execution, controlled by the `BASH_DEFAULT_TIMEOUT_MS` environment variable. The maximum timeout the model can set is 600,000 milliseconds (10 minutes), controlled by `BASH_MAX_TIMEOUT_MS`.

The timeout exists to prevent hung commands from blocking the session indefinitely. However, many legitimate development commands regularly exceed 2 minutes:

| Command | Typical Duration |
|---------|-----------------|
| `npm install` (large project) | 2-5 minutes |
| `docker build` (multi-stage) | 3-15 minutes |
| `cargo build` (Rust, release) | 5-30 minutes |
| Full test suite | 2-60 minutes |
| Database migration | 1-10 minutes |

## Full Solution

### Option 1: Use Background Execution

Tell Claude to run long commands in the background:

```text
Run this command in the background: npm ci && npm run build && npm test
```

Claude Code will start the command as a background process, return immediately, and check the task's output when it completes.

### Option 2: Increase the Default Timeout

Set the `BASH_DEFAULT_TIMEOUT_MS` environment variable before launching Claude Code:

```bash
# Set default to 10 minutes (600000ms)
export BASH_DEFAULT_TIMEOUT_MS=600000
claude
```

Or add it to your shell profile for persistence:

```bash
echo 'export BASH_DEFAULT_TIMEOUT_MS=600000' >> ~/.bashrc
source ~/.bashrc
```

You can also increase the maximum timeout the model can request:

```bash
# Set max to 10 minutes (the default maximum)
export BASH_MAX_TIMEOUT_MS=600000
```

### Option 3: Break Commands Into Stages

Instead of one long command, break it into steps that each complete within the timeout window:

```text
Instead of: "Run npm ci && npm run build && npm test"

Do:
1. "Run npm ci"
2. (wait for completion)
3. "Run npm run build"
4. (wait for completion)
5. "Run npm test"
```

Each step runs independently with its own timeout window.

### Option 4: Pre-Run Long Commands Yourself

For commands you know will take a while, run them in a separate terminal:

```bash
# In a separate terminal (not Claude Code)
npm ci && echo "DONE: npm ci"

# Then tell Claude Code
# "npm ci is complete. The node_modules are installed. Continue with the build."
```

## Prevention

- **Identify long-running commands early** and instruct Claude to run them in the background
- **Set `BASH_DEFAULT_TIMEOUT_MS`** in your shell profile if you regularly work with slow builds
- **Use `npm ci` instead of `npm install`** -- it is significantly faster for CI workloads
- **Cache aggressively** -- Docker layer caching, npm cache, pip cache all reduce install times
- **Pre-install dependencies** before starting a Claude Code session

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-timeout-2m-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix: Claude Code Slow Response Times](/claude-code-slow-response-fix/)
- [Claude Code Dotenv Configuration Workflow](/claude-code-dotenv-configuration-workflow/)
- [Fix: Claude Code Slow Response and Performance](/claude-code-slow-fix/)
- [Before and After Switching to Claude Code Workflow](/before-and-after-switching-to-claude-code-workflow/)

## See Also

- [Claude Code Bash Command Timeout 120s — Fix (2026)](/claude-code-bash-command-timeout-120s-fix-2026/)


## Common Questions

### What causes fix: claude code 2m bash timeout issues?

Common causes include misconfigured settings, outdated dependencies, and environment conflicts. Check your project configuration and ensure all dependencies are up to date.

### How do I prevent this error from recurring?

Set up automated checks in your development workflow. Use Claude Code's built-in validation tools to catch configuration issues before they reach production.

### Does this fix work on all operating systems?

The core fix applies to macOS, Linux, and Windows. Some path-related adjustments may be needed depending on your OS. Check the platform-specific notes in the guide above.

## Related Resources

- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [Fix: Claude Code npm Install Fails](/claude-code-error-npm-install-fails-in-skill-workflow/)
- [Fix: Claude Code Gives Incorrect](/claude-code-gives-incorrect-imports-how-to-fix/)
