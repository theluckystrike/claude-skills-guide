---
title: "Output Channel Buffer Full Truncated — Fix (2026)"
permalink: /claude-code-output-channel-buffer-full-fix-2026/
description: "Increase outputChannel.maxBuffer to 5MB in VS Code settings.json. Stops older message truncation in the Claude Code output channel during sessions."
last_tested: "2026-04-21"
---

## The Error

```
Output channel buffer full. Older messages truncated.
```

## The Fix

```json
// Add to VS Code settings.json (Cmd+Shift+P > Preferences: Open Settings JSON)
{
  "claude-code.outputChannel.maxBuffer": 5242880
}
```

## Why This Works

The VS Code output channel has a default buffer limit to prevent memory exhaustion. When Claude Code produces verbose output (large diffs, extensive tool results, long conversations), the buffer fills and older messages are discarded. Increasing the buffer to 5MB (5242880 bytes) retains significantly more history while staying within reasonable memory bounds.

## If That Doesn't Work

```bash
# Clear the output channel to free the buffer
# Command Palette > Output: Clear Output Channel

# If the extension is producing excessive output, reduce verbosity
claude config set log_level "warn"

# For persistent logging that survives buffer limits, enable file logging
claude config set log_file "~/.config/claude-code/claude.log"
```

If memory usage grows unacceptably after increasing the buffer, consider enabling file-based logging and keeping the buffer at its default. You can review the log file separately without impacting VS Code performance.

## Prevention

Add to your CLAUDE.md:
```
Output buffer is set to 5MB. For operations that generate large output (multi-file diffs, recursive searches), prefer writing results to a file rather than streaming to the output channel.
```

## See Also

- [Claude Code ENOSPC Disk Full Error — Fix (2026)](/claude-code-enospc-disk-full-fix/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`
- `JavaScript heap out of memory`
- `Error: spawn ENOMEM`
- `Error reading configuration file`
- `JSON parse error in config`

## Frequently Asked Questions

### How much memory does Claude Code use?

Claude Code typically uses 200-500MB of RAM. Large file operations, parallel tool calls, and long conversation histories can push usage above 1GB. Monitor with `ps aux | grep claude` to see current memory usage.

### How do I increase Node.js memory limit?

Set `NODE_OPTIONS='--max-old-space-size=4096'` to allow Node.js up to 4GB of heap memory. The default is approximately 1.5GB on 64-bit systems. This is useful when Claude Code processes very large files or generates extensive output.

### Why does memory spike during file search?

The Grep and Glob tools build in-memory indexes for fast searching. In repositories with more than 100,000 files, the index alone can consume significant memory. Add large directories (node_modules, build output) to `.gitignore` to exclude them from indexing.

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.


## Related Guides

- [Fix Skill Exceeded Maximum Output](/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Fix: Structured Output + Thinking +](/anthropic-sdk-structured-output-thinking-tool-use-bug/)
- [Claude Code Skill Output Streaming](/claude-code-skill-output-streaming-optimization/)
- [Unicode Encoding Errors in Code Output — Fix (2026)](/claude-code-unicode-encoding-errors-code-output-fix-2026/)

## Step-by-Step Debugging Process

When you encounter pipe-related errors in Claude Code, follow this systematic debugging approach:

**Step 1: Identify the failing command.** Check the error output for the command that triggered the failure. The stack trace shows which process wrote to the closed pipe.

**Step 2: Check command output size.** Run the command alone (without piping) and check output size with `wc -l`. If the output exceeds 10,000 lines, it needs buffering or file redirection.

**Step 3: Replace pipes with file intermediaries.** Instead of `command1 | command2`, use `command1 > /tmp/intermediate.txt && command2 < /tmp/intermediate.txt`. This eliminates pipe buffer pressure entirely.

**Step 4: Set appropriate timeouts.** Long-running commands need matching timeout values. Check `CLAUDE_CODE_BASH_TIMEOUT` and ensure it exceeds the expected command duration by at least 50%.

**Step 5: Verify the fix under load.** Run the full workflow three times consecutively to confirm the error does not recur under typical conditions.


## Common Scenarios That Trigger This Error

**Large repository searches.** Running `grep -r` or `find` across a repository with 50,000+ files produces output faster than the pipe consumer can process it. Use `--max-count` or `-maxdepth` to limit output volume.

**Build output during CI.** Build tools like webpack, tsc, and esbuild produce verbose output during compilation. If Claude Code's process supervisor terminates the build mid-output, the pipe breaks. Redirect build output to a log file.

**Streaming API responses.** When Claude Code processes long streaming responses and the connection is interrupted (timeout, network drop), the write side of the stream receives EPIPE. Implement proper stream error handlers with `.on('error', handler)`.

**Parallel tool execution.** Claude Code may run multiple bash commands simultaneously. If system pipe buffer capacity (typically 64KB on macOS, 65KB on Linux) is exhausted across all concurrent pipes, writes block and eventually fail.
