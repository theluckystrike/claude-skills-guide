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
