---
title: "Parallel Tool Calls Memory Exhaustion Fix"
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
