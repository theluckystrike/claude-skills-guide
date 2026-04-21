---
title: "Conversation History OOM Crash Fix"
permalink: /claude-code-conversation-history-oom-fix-2026/
description: "Fix conversation history out-of-memory crash in Claude Code. Clear cached sessions and limit history retention to prevent Node.js heap exhaustion."
last_tested: "2026-04-22"
render_with_liquid: false
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
