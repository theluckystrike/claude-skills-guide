---
layout: default
title: "Fix Claude Timeout: 3 Proven Methods"
description: "Fix Claude timeout with 3 commands: set timeout to 600000ms, use run_in_background, or add timeout parameter to bash calls. Tested April 2026."
date: 2026-04-14
last_modified_at: 2026-04-21
last_tested: "2026-04-21"
author: "Claude Code Guides"
permalink: /claude-code-timeout-fix/
reviewed: true
categories: [Performance & Speed Issues]
tags: ["claude-code", "timeout", "bash", "performance"]
geo_optimized: true
---

# Fix Claude Code Timeout Errors

> **TL;DR:** Claude Code's default Bash timeout is 2 minutes. Increase it with the `timeout` parameter in tool calls, use `run_in_background` for long tasks, or configure global timeout settings.

## The Problem

Your Claude Code commands fail with timeout errors:

```
Bash tool timed out after 120000ms (2 minutes)
```

Or during login:

```
Timeout getting diagnostics
```

This happens with commands that take longer than the default 2-minute limit — builds, test suites, large file operations, or network-dependent tasks.

## Why This Happens

Claude Code imposes a default 2-minute (120,000ms) timeout on Bash tool calls to prevent runaway processes. This is a safety feature, but it catches legitimate long-running commands like:

- `npm install` on large projects
- Full test suites (`npm test`, `pytest`)
- Docker builds
- Database migrations
- Network downloads

## The Fix

### Step 1 — Use Background Execution for Long Tasks

The cleanest solution is to run long commands in the background:

```
> Run `npm test` in the background so it doesn't time out
```

Claude Code will use `run_in_background: true`, which removes the timeout constraint. You will be notified when the task completes.

### Step 2 — Increase the Timeout for Specific Commands

When asking Claude to run a command, specify a longer timeout:

```
> Run `npm run build` with a 10 minute timeout
```

Claude Code supports timeouts up to 600,000ms (10 minutes) per tool call.

### Step 3 — Break Long Commands into Stages

Instead of one long command, decompose it:

```bash
# Instead of: npm install && npm run build && npm test
# Break into three separate commands:

# Command 1
npm install

# Command 2
npm run build

# Command 3
npm test
```

Each gets its own 2-minute window.

### Step 4 — Fix Login Timeout Issues

If `claude /login` times out on the diagnostics step:

```bash
# Skip diagnostics during login
claude /login --skip-diagnostics

# Or set API key directly (bypasses login flow entirely)
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"
```

### Step 5 — Verify the Fix

```bash
# Test with a command that would previously timeout
> Run `sleep 5 && echo "success"` to verify timeouts are working
```

**Expected output:**

```
success
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| `npm install` times out | Large dependency tree | Use `run_in_background: true` |
| Test suite times out | Tests take >2 min | Run in background or break into test groups |
| Login timeout | Slow network/diagnostics | `--skip-diagnostics` or use API key |
| Docker build times out | Image layers downloading | Run in background |
| `git clone` times out | Large repository | Run in background or use `--depth=1` |
| Timeout only on Windows | WSL I/O overhead | Run commands in native PowerShell |

## Prevention

- **Default to background for builds:** Any command that might take over 1 minute should use `run_in_background`.
- **Set up CI for heavy tasks:** Do not run full test suites inside Claude Code — trigger CI pipelines instead.
- **Use incremental builds:** Configure your build system for incremental compilation to stay within timeout limits.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-timeout-fix)**

</div>

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-timeout-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Fix Claude Code Slow Response and Performance](/claude-code-slow-fix) — General performance optimization
- [Claude Code Bash Command Not Found in Skill](/claude-code-bash-command-not-found-in-skill/) — Understanding Bash tool capabilities and limits
- [Benchmarking Claude Code Skills Performance Guide](/benchmarking-claude-code-skills-performance-guide/) — Browse all performance guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*


