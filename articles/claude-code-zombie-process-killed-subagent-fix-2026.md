---
layout: default
title: "Zombie Process From Killed Subagent — Fix (2026)"
permalink: /claude-code-zombie-process-killed-subagent-fix-2026/
date: 2026-04-20
description: "Fix zombie processes left by killed Claude Code subagents. Find and kill orphaned node processes to reclaim system resources and prevent port conflicts."
last_tested: "2026-04-22"
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


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Claude Code Install Killed on Linux](/claude-code-install-killed-low-memory-linux-fix/)
- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
