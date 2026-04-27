---
sitemap: false
layout: default
title: "Fix Claude Code Slow Response (2026)"
description: "Speed up Claude Code when responses are slow or typing lags. Covers context management, model selection, and optimization. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-slow-fix/
reviewed: true
categories: [Performance & Speed Issues]
tags: ["claude-code", "performance", "slow", "speed", "optimization"]
geo_optimized: true
---

# Fix Claude Code Slow Response and Performance

> **TL;DR:** Claude Code slows down as context grows. Compact your conversation, reduce MCP tool count, choose the right model, and check your network connection.

## The Problem

Claude Code becomes noticeably slow during a session:

- Responses take 30+ seconds to start streaming
- Typing in the TUI lags or freezes
- The status bar shows high context usage (e.g., "85% context used")
- Memory usage climbs over time

Users report this worsening with longer sessions, larger codebases, and multiple MCP servers configured.

## Why This Happens

Several factors compound to make Claude Code slow:

- **Context window saturation:** As your conversation grows, each API call sends more tokens, increasing latency and cost
- **MCP tool overhead:** Each configured MCP server adds tool definitions to the context, consuming 1-15% of your context window before you even start
- **Model choice:** Opus models are slower than Sonnet; Sonnet is slower than Haiku
- **Network latency:** Slow or unstable connections increase time-to-first-token
- **Large file reads:** Reading large files into context inflates token count

## The Fix

### Step 1 — Compact Your Conversation

When context usage is high, use the `/compact` command to summarize the conversation:

```
> /compact
```

This replaces the full conversation history with a summary, freeing up context for new work. You can also configure auto-compaction:

```json
// ~/.claude/settings.json
{
 "autoCompactThreshold": 80
}
```

This automatically compacts when context exceeds 80%.

### Step 2 — Reduce MCP Tool Count

Each MCP tool definition consumes context tokens. If you have many servers configured:

```bash
# Check how many tools are loaded
claude mcp list
```

If you see 50+ tools, that is consuming 10-15% of your context window. Solutions:

- Remove MCP servers you do not need for the current project
- Use project-level `.claude/settings.json` with only project-relevant servers
- Use the `toolFilter` option to limit which tools are exposed

### Step 3 — Choose the Right Model

```bash
# Use Sonnet for most coding tasks (faster, still very capable)
claude --model claude-sonnet-4-5-20250514

# Use Haiku for simple tasks (fastest)
claude --model claude-haiku-3-5-20241022

# Reserve Opus for complex architectural decisions
claude --model claude-opus-4-5-20250414
```

Sonnet typically responds 2-3x faster than Opus for equivalent context sizes.

### Step 4 — Check Network Performance

```bash
# Test latency to Anthropic API
curl -o /dev/null -s -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
 https://api.anthropic.com/v1/messages \
 -H "x-api-key: $ANTHROPIC_API_KEY" \
 -H "anthropic-version: 2023-06-01" \
 -H "content-type: application/json" \
 -d '{"model":"claude-haiku-3-5-20241022","max_tokens":16,"messages":[{"role":"user","content":"hi"}]}'
```

If DNS or connect times are high (>500ms), check your network configuration.

### Step 5 — Start Fresh Sessions for New Tasks

Rather than reusing a long session for multiple tasks:

```bash
# Start a new session for each major task
claude

# Or explicitly create a new session
claude --new-session
```

**Verify improvement:**

After compacting and adjusting, context usage should drop significantly:

```
Context: 15% (was 85%)
Response time: ~3s (was ~30s)
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Slow only in VS Code | IDE extension overhead | Use CLI directly in terminal |
| Slow on Windows specifically | WSL I/O overhead | Run Claude in native Windows or use faster WSL2 disk |
| Slow startup (10+ seconds) | Many MCP servers initializing | Reduce MCP server count |
| Slow after idle period | Session state reload | Start a new session |
| Typing lag in TUI | Terminal rendering | Try a different terminal emulator |

## Prevention

- **Start new sessions often:** Do not let conversations grow beyond 50% context.
- **Use `/compact` proactively:** Compact before context reaches 70%, not after it hits 95%.
- **Profile MCP overhead:** Remove MCP servers that add tools you rarely use.

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

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-slow-fix)**

</div>

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-code-slow-fix)**

$99 once. Pays for itself in saved tokens within a week.

</div>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Issues

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Claude Code Error Out of Memory Large Codebase Fix](/claude-code-error-out-of-memory-large-codebase-fix/) — When memory usage grows unbounded
- [Claude Code Context Window Full in Large Codebase Fix](/claude-code-context-window-full-in-large-codebase-fix/) — Understanding context limits
- [Benchmarking Claude Code Skills Performance Guide](/benchmarking-claude-code-skills-performance-guide/) — Browse all performance guides

---

*If you are running many browser tabs alongside Claude Code, [Tab Suspender Pro](https://chromewebstore.google.com/detail/tab-suspender-pro/) can free memory from inactive tabs so your dev tools stay responsive.*


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



## Related Articles

- [Why Is Chrome So Slow in 2026? Quick Fixes](/why-is-chrome-so-slow-2026/)
- [Fix Chrome Slow Macbook — Quick Guide (2026)](/chrome-slow-macbook-fix/)
- [Fix Chrome Print Slow — Quick Guide](/chrome-print-slow-fix/)
- [Chrome Slow After Update: Causes and Solutions](/chrome-slow-after-update/)
- [Chrome Translate Slow: Fix Performance Issues](/chrome-translate-slow/)
- [Chrome Downloads Slow: Fixing Download Performance](/chrome-downloads-slow/)
- [Chrome Web Store Slow: Causes and Solutions for Developers](/chrome-web-store-slow/)
- [Chrome Slow Startup: Diagnose and Fix Performance Issues](/chrome-slow-startup/)
