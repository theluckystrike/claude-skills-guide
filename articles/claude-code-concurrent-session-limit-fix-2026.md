---
title: "Claude Code Concurrent Sessions 5/5 — Fix (2026)"
permalink: /claude-code-concurrent-session-limit-fix-2026/
description: "Close idle sessions with claude sessions list and close commands. Frees connection slots immediately when hitting the 5-session concurrency limit."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Maximum concurrent sessions reached (5/5). Close an existing session.
```

## The Fix

```bash
# List all active sessions
claude sessions list

# Close sessions you no longer need (by session ID)
claude sessions close <session-id>

# Or close all idle sessions at once
claude sessions close --idle
```

## Why This Works

Each Claude Code session maintains an active connection and consumes API concurrency quota. The 5-session limit exists to prevent runaway costs and API abuse. Closing idle sessions (tabs you forgot about, terminals that finished their task) frees slots immediately without waiting for automatic timeout.

## If That Doesn't Work

```bash
# Force-kill orphaned Claude Code processes
ps aux | grep "claude-code" | grep -v grep
kill -9 <orphaned-pid>

# If sessions are stuck in a "closing" state, clear the session store
rm -rf ~/.config/claude-code/sessions/*.lock
# Then restart Claude Code
```

Orphaned processes occur when VS Code crashes or terminals are force-closed without graceful shutdown. These phantom sessions count against your limit until the server-side timeout (usually 5 minutes) expires.

## Prevention

Add to your CLAUDE.md:
```
Close Claude Code sessions explicitly when done. Never leave idle sessions open across multiple terminals. Use a single session for sequential tasks rather than spawning parallel sessions for small operations.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.
