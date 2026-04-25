---
layout: default
title: "Garbage Collection Pause Causing — Fix (2026)"
permalink: /claude-code-gc-pause-causing-timeout-fix-2026/
date: 2026-04-20
description: "Fix garbage collection pauses causing timeouts in Claude Code. Tune Node.js GC flags and reduce memory pressure to prevent long stop-the-world pauses."
last_tested: "2026-04-22"
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

## See Also

- [DNS Resolution Timeout Error — Fix (2026)](/claude-code-dns-resolution-timeout-fix-2026/)
- [Claude Code Bash Command Timeout 120s — Fix (2026)](/claude-code-bash-command-timeout-120s-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.


## Related Guides

- [Claude Code Postman Collection](/claude-code-postman-collection-automation/)
- [Claude Code for Postman Collection](/claude-code-for-postman-collection-generation-workflow/)
- [Claude Code Guides: Complete Collection](/playbook/)
- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)