---
title: "File Descriptor Leak in Watch Mode"
permalink: /claude-code-file-descriptor-leak-watch-mode-fix-2026/
description: "Fix file descriptor leak in Claude Code watch mode. Close stale watchers and increase ulimit to prevent EMFILE too many open files errors."
last_tested: "2026-04-22"
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

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Memory Management in Claude Code

Claude Code's memory consumption depends on three factors: conversation context size, file scanning scope, and concurrent tool operations.

**Conversation context.** Each turn in a Claude Code session accumulates context. After 20-30 turns with large file reads, context can reach 100K+ tokens, consuming significant memory. Use `/clear` to reset when context grows too large.

**File scanning.** When Claude Code searches for files or reads directory structures, it loads file metadata into memory. For repositories with 100,000+ files (common in monorepos), this can exceed available memory. Use `.claudeignore` to exclude `node_modules`, `.git`, and build output directories.

**Node.js heap limits.** By default, Node.js limits heap to approximately 1.5GB on 64-bit systems. For very large operations, increase this limit:

```bash
export NODE_OPTIONS="--max-old-space-size=4096"
claude
```

## Monitoring Memory Usage

Track Claude Code's memory consumption during a session:

```bash
# Check current memory usage
ps aux | grep -E "node.*claude" | awk '{print $6/1024 "MB", $11}'

# Monitor continuously (every 5 seconds)
while true; do ps aux | grep -E "node.*claude" | grep -v grep | awk '{print strftime("%H:%M:%S"), $6/1024 "MB"}'; sleep 5; done

# Check system memory availability
vm_stat | head -10  # macOS
free -h              # Linux
```

If memory usage exceeds 1GB, start a new session. Continuing with high memory usage risks OOM kills that lose unsaved work.
