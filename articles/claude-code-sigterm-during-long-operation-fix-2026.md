---
title: "SIGTERM During Long Operation Fix"
permalink: /claude-code-sigterm-during-long-operation-fix-2026/
description: "Fix SIGTERM killing Claude Code during long operations. Increase bash timeout, use background execution, and handle signal traps to prevent data loss."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Process terminated by SIGTERM during operation
  Command 'npm run build' was killed after 120000ms (2 minute timeout)
  Partial output saved. File writes may be incomplete.
```

This appears when a Bash command executed by Claude Code exceeds the default 2-minute timeout, triggering a SIGTERM that kills the process and may leave files in a partially written state.

## The Fix

```bash
claude "Run npm run build with a 10-minute timeout"
```

1. Ask Claude Code to use a longer timeout for the Bash tool call. Claude Code supports timeout parameters up to 600,000ms (10 minutes).
2. For builds that take longer than 10 minutes, run them outside of Claude Code and share the output.
3. Check for incomplete file writes after a SIGTERM and restore from git if needed.

## Why This Happens

Claude Code's Bash tool has a default 120-second (2-minute) timeout to prevent runaway commands. Long-running operations like full project builds, large test suites, or database migrations regularly exceed this limit. When the timeout fires, Node.js sends SIGTERM to the child process. If the process does not exit within a few seconds, SIGKILL follows, which cannot be caught or handled.

## If That Doesn't Work

Run the command in the background:

```bash
claude "Run this in the background: npm run build > build.log 2>&1 &"
```

Split the build into smaller steps:

```bash
claude "First compile TypeScript with tsc, then run webpack separately"
```

Check for and fix partially written files:

```bash
git diff --stat
git checkout -- path/to/corrupted-file.ts
```

## Prevention

```markdown
# CLAUDE.md rule
For build commands that may take over 2 minutes, always specify a timeout of 300000ms (5 min) or run them in the background. Never run full test suites without a timeout override.
```

## See Also

- [Claude Code EPIPE Broken Pipe Error — Fix (2026)](/claude-code-epipe-broken-pipe-long-operations-fix/)
- [Disk Space Full During Operation Fix](/claude-code-disk-space-full-during-operation-fix-2026/)
