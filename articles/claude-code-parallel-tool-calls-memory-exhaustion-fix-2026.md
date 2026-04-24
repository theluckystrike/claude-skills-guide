---
title: "Parallel Tool Calls Memory Exhaustion — Fix (2026)"
permalink: /claude-code-parallel-tool-calls-memory-exhaustion-fix-2026/
description: "Fix memory exhaustion from parallel tool calls in Claude Code. Limit concurrent operations and reduce batch sizes to prevent heap overflow crashes."
last_tested: "2026-04-22"
render_with_liquid: false
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
