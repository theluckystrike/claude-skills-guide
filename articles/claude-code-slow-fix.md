---
layout: default
title: "Fix Claude Code Slow Response and Performance"
description: "Speed up Claude Code when responses are slow or typing lags. Covers context management, model selection, and optimization."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-code-slow-fix/
reviewed: true
categories: [Performance & Speed Issues]
tags: ["claude-code", "performance", "slow", "speed", "optimization"]
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

If you see 50+ tools, that could be consuming 10-15% of your context window. Solutions:

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

## Related Issues

- [Claude Code Memory Leak Fix](/claude-code-memory-leak-fix) — When memory usage grows unbounded
- [Claude Code Context Window Management](/claude-code-context-window) — Understanding context limits
- [Hub: Performance & Speed Issues](/claude-code-performance-hub) — Browse all performance guides

---

*If you are running many browser tabs alongside Claude Code, [Tab Suspender Pro](https://chromewebstore.google.com/detail/tab-suspender-pro/) can free memory from inactive tabs so your dev tools stay responsive.*

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
