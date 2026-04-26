---
layout: default
title: "Conversation History OOM Crash — Fix (2026)"
permalink: /claude-code-conversation-history-oom-fix-2026/
date: 2026-04-20
description: "Fix conversation history out-of-memory crash in Claude Code. Clear cached sessions and limit history retention to prevent Node.js heap exhaustion."
last_tested: "2026-04-22"
---

## The Error

```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
 1: 0x100a3c1a8 node::Abort() [/usr/local/bin/node]
 Claude Code process exited with code 134 (SIGABRT)
```

This crash occurs when Claude Code's Node.js process runs out of heap memory while loading or processing conversation history from previous sessions.

## The Fix

```bash
rm -rf ~/.claude/conversations/*.json
```

1. Close all Claude Code sessions.
2. Delete stale conversation history files from the cache directory.
3. Restart Claude Code. It will start with a fresh conversation store.

## Why This Happens

Claude Code persists conversation history to disk and loads it into memory on startup. Over weeks of use, the accumulated JSON files can grow to hundreds of megabytes. When Node.js tries to parse these large JSON blobs, it exhausts the default 4GB heap limit, triggering an OOM abort signal.

## If That Doesn't Work

Increase the Node.js heap limit before launching Claude Code:

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
claude
```

Selectively remove only the largest conversation files:

```bash
find ~/.claude/conversations/ -size +50M -delete
```

If the issue persists, reinstall Claude Code to reset all cached state:

```bash
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

## Prevention

```markdown
# CLAUDE.md rule
Use /clear between major tasks to prevent unbounded conversation growth. Start new sessions for unrelated work instead of continuing long-running conversations.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error

- [Claude upload limit guide](/claude-upload-limit-guide/) — Understanding Claude file upload limits and workarounds
- [Source Map Generation Out of Memory — Fix (2026)](/claude-code-source-map-generation-oom-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

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
