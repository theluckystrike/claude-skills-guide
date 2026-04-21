---
title: "File Descriptor Leak in Watch Mode Fix"
permalink: /claude-code-file-descriptor-leak-watch-mode-fix-2026/
description: "Fix file descriptor leak in Claude Code watch mode. Close stale watchers and increase ulimit to prevent EMFILE too many open files errors."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: EMFILE: too many open files, watch '/src/components'
  at FSWatcher.start (fs.js:1382:19)
  Current open file descriptors: 10240 (limit: 10240)
  Claude Code file watcher leaked 8,400+ descriptors
```

This appears when Claude Code's file watching system accumulates open file descriptors without releasing them, eventually hitting the OS limit.

## The Fix

```bash
ulimit -n 65536
claude
```

1. Increase the file descriptor limit for the current shell session.
2. Restart Claude Code after increasing the limit.
3. For permanent fix on macOS, create a launchd plist to set higher limits system-wide.

## Why This Happens

Claude Code watches your project directory for file changes to detect when you or other tools modify files. Each watched directory and file consumes one file descriptor. In large monorepos with thousands of files and `node_modules`, the watcher can exhaust the default 10,240 descriptor limit. The leak occurs when Claude Code opens new watchers for navigated directories but does not release watchers for directories it no longer needs.

## If That Doesn't Work

Add `node_modules` and large directories to the ignore list:

```bash
echo "node_modules" >> .claudeignore
echo "dist" >> .claudeignore
echo ".git" >> .claudeignore
```

Check current file descriptor usage:

```bash
lsof -p $(pgrep -f "claude") | wc -l
```

Set the limit permanently on macOS:

```bash
sudo launchctl limit maxfiles 65536 200000
```

On Linux, edit `/etc/security/limits.conf`:

```bash
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
```

## Prevention

```markdown
# CLAUDE.md rule
Always maintain a .claudeignore file that excludes node_modules, dist, .git, and other large generated directories. Set ulimit -n 65536 in your shell profile.
```
