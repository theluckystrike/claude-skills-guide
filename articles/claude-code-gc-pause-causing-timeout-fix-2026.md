---
title: "Garbage Collection Pause Causing Timeout Fix"
permalink: /claude-code-gc-pause-causing-timeout-fix-2026/
description: "Fix garbage collection pauses causing timeouts in Claude Code. Tune Node.js GC flags and reduce memory pressure to prevent long stop-the-world pauses."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Operation timed out — no response received for 30000ms
  GC pause detected: 12,847ms (mark-sweep)
  Heap used: 3.2GB / 4.0GB — major GC triggered during API response processing
```

This appears when Node.js triggers a major garbage collection cycle that freezes the Claude Code process for several seconds, causing pending network requests or streaming operations to time out.

## The Fix

```bash
export NODE_OPTIONS="--max-old-space-size=8192 --gc-interval=200"
claude
```

1. Increase the heap size to reduce GC frequency.
2. Set a higher GC interval to defer collection until idle periods.
3. Restart Claude Code with these environment variables set.

## Why This Happens

Claude Code's Node.js process accumulates large JavaScript objects from conversation history, tool results, and API response buffers. When the V8 heap approaches its limit, a "stop-the-world" major GC (mark-sweep) runs to reclaim memory. During this pause, all JavaScript execution halts, including network I/O handling. If the pause exceeds the timeout threshold for pending API calls or streaming connections, those operations fail with timeout errors.

## If That Doesn't Work

Use incremental GC to reduce pause duration:

```bash
export NODE_OPTIONS="--max-old-space-size=8192 --incremental-marking"
claude
```

Run `/compact` proactively to reduce the volume of objects in memory:

```bash
/compact
```

Monitor GC activity with trace flags to diagnose the issue:

```bash
export NODE_OPTIONS="--trace-gc --max-old-space-size=8192"
claude 2>gc-trace.log
```

## Prevention

```markdown
# CLAUDE.md rule
Run /compact after every 30 messages. Avoid reading large files into context. Set NODE_OPTIONS="--max-old-space-size=8192" in your shell profile for Claude Code sessions.
```
