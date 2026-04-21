---
title: "Zombie Process From Killed Subagent Fix"
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
