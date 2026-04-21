---
title: "Claude Code EPIPE Broken Pipe Error — Fix (2026)"
description: "Fix Claude Code EPIPE broken pipe during long operations. Increase pipe buffer and handle SIGPIPE signals. Step-by-step solution."
permalink: /claude-code-epipe-broken-pipe-long-operations-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error: write EPIPE
    at WriteWrap.onWriteComplete [as oncomplete] (node:internal/stream_base_commons:94:16) {
  errno: -32,
  code: 'EPIPE',
  syscall: 'write'
}

# Or:
Error [ERR_STREAM_WRITE_AFTER_END]: write after end
    at new NodeError (node:internal/errors:406:5)
    at _write (node:internal/streams/writable:334:11)
```

## The Fix

1. **Increase the bash command timeout for long operations**

```bash
# In your CLAUDE.md, set a longer timeout:
# bash_timeout: 600

# Or set the environment variable before starting Claude Code:
export CLAUDE_CODE_BASH_TIMEOUT=600
claude
```

2. **For piped commands, ensure the receiving process stays alive**

```bash
# WRONG — pipe breaks if head exits before find finishes
find . -name "*.ts" | head -100

# CORRECT — use process substitution or limit at source
find . -name "*.ts" -maxdepth 3 | head -100

# Or capture output first, then slice
find . -name "*.ts" > /tmp/results.txt && head -100 /tmp/results.txt
```

3. **Verify the fix:**

```bash
# Test a long-running pipe
node -e "for(let i=0;i<10000;i++) process.stdout.write('line '+i+'\n')" | tail -1
# Expected: line 9999 (no EPIPE error)
```

## Why This Happens

EPIPE occurs when a process writes to a pipe whose reading end has been closed. In Claude Code, this typically happens when a long-running command (like `find`, `grep`, or a build process) is piped to another command that exits early (like `head`), or when Claude Code's internal process supervisor terminates a command that exceeds its timeout while output is still being written. The Node.js stream API throws this as an unhandled write error.

## If That Doesn't Work

- **Alternative 1:** Redirect output to a file instead of piping: `long_command > output.txt 2>&1`
- **Alternative 2:** Add `2>/dev/null` to suppress EPIPE noise when using intentional early-termination patterns
- **Check:** Run `ulimit -a` to check pipe buffer sizes and `sysctl kern.maxpipekva` (macOS) for system pipe limits

## Prevention

Add to your `CLAUDE.md`:
```markdown
For commands that produce large output, redirect to a file instead of piping to head/tail. Set bash_timeout to 600 for build and test commands. Avoid piping unbounded output through multiple stages.
```

**Related articles:** [Claude Code Timeout Fix](/claude-code-timeout-fix/), [Claude Code Not Responding Fix](/claude-code-not-responding-terminal-hangs-fix/), [Verbose Mode Debugging](/claude-code-verbose-mode-debugging-tips/)
