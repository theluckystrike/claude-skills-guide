---
title: "Zombie Process From Killed Subagent Fix — Fix (2026)"
permalink: /claude-code-zombie-process-killed-subagent-fix-2026/
description: "Fix zombie processes left by killed Claude Code subagents. Find and kill orphaned node processes to reclaim system resources and prevent port conflicts."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: EADDRINUSE: address already in use :::3000
  Orphaned process from previous Claude Code session still holding port
  PID 48291 (node) — zombie subagent, PPID 1 (init/launchd)
```

This appears when a previous Claude Code session crashed or was force-killed, leaving child processes (dev servers, watchers, builds) running in the background as orphans.

## The Fix

```bash
pkill -f "claude.*subagent"
```

1. Kill orphaned Claude Code subagent processes.
2. Check for any node processes that were spawned by Claude Code and are still running.
3. Verify the port is free before restarting.

## Why This Happens

When Claude Code spawns a subagent or runs a background command (like a dev server), the child process runs as a separate OS process. If Claude Code is killed with SIGKILL (Ctrl+C twice, or OOM killer), it cannot clean up its children. These orphaned processes get reparented to PID 1 (init on Linux, launchd on macOS) and continue running indefinitely, holding onto ports, file locks, and memory.

## If That Doesn't Work

Find and kill all orphaned node processes from Claude Code:

```bash
ps aux | grep -E "node.*claude" | grep -v grep
kill -9 <PID>
```

Find what process is holding a specific port:

```bash
lsof -i :3000
kill -9 $(lsof -ti :3000)
```

Clean up all node processes if you are sure nothing else needs them:

```bash
killall node
```

## Prevention

```markdown
# CLAUDE.md rule
Always stop dev servers before ending a session. Use /clear before closing Claude Code to trigger cleanup. After a crash, run 'ps aux | grep node' to check for orphans.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`
- `MODULE_NOT_FOUND: Cannot find module 'node:fs'`
- `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`
- `JavaScript heap out of memory`

## Frequently Asked Questions

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.

### How do I manage multiple Node.js versions?

Use nvm (Node Version Manager): `nvm install 20 && nvm use 20`. This lets you switch between Node.js versions per-project without affecting other applications. Add a `.nvmrc` file with `20` to your project root so nvm automatically selects the right version.

### Why does Claude Code fail with the node:fs prefix?

The `node:` prefix for built-in modules was introduced in Node.js 16. If you see errors about `node:fs` or `node:path`, you are running an older Node.js version that does not support this syntax. Upgrade to Node.js 18 or later.

### How much memory does Claude Code use?

Claude Code typically uses 200-500MB of RAM. Large file operations, parallel tool calls, and long conversation histories can push usage above 1GB. Monitor with `ps aux | grep claude` to see current memory usage.
