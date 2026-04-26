---
layout: default
title: "Parallel Tool Calls Memory Exhaustion — Fix (2026)"
permalink: /claude-code-parallel-tool-calls-memory-exhaustion-fix-2026/
date: 2026-04-20
description: "Fix memory exhaustion from parallel tool calls in Claude Code. Limit concurrent operations and reduce batch sizes to prevent heap overflow crashes."
last_tested: "2026-04-22"
---

## The Error

```
Error: JavaScript heap out of memory during parallel tool execution
  at ToolExecutor.runParallel (tool-executor.js:156)
  6 concurrent tool calls exceeded available memory (RSS: 3.8GB)
```

This appears when Claude Code runs multiple tool calls simultaneously and their combined output exceeds available memory. Common with parallel file reads or multiple Bash commands.

## The Fix

```bash
claude "Process these files one at a time, not in parallel: src/a.ts, src/b.ts, src/c.ts"
```

1. Instruct Claude Code to process files sequentially rather than in parallel.
2. Break large batch operations into smaller groups of 2-3 files at most.
3. Use `/compact` between batches to free memory from previous tool results.

## Why This Happens

Claude Code can issue multiple tool calls in a single turn for efficiency. Each parallel call holds its result in memory until all calls complete. When 5-6 tool calls each return large file contents or verbose command output, the combined memory usage can exceed the Node.js heap limit. The garbage collector cannot reclaim memory fast enough because all results are referenced simultaneously.

## If That Doesn't Work

Increase the Node.js memory limit:

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
claude
```

Restrict Claude Code to sequential tool execution via CLAUDE.md:

```bash
echo "Always execute tool calls sequentially, never in parallel." > CLAUDE.md
```

Close other memory-intensive applications before running large batch operations:

```bash
# Check current memory usage
vm_stat | head -10
```

## Prevention

```markdown
# CLAUDE.md rule
When processing more than 3 files, work sequentially. Never read more than 3 files in a single turn. Run /compact after processing every 5 files.
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
