---
title: "Output Channel Buffer Full Truncated — Fix (2026)"
permalink: /claude-code-output-channel-buffer-full-fix-2026/
description: "Increase outputChannel.maxBuffer to 5MB in VS Code settings.json. Stops older message truncation in the Claude Code output channel during sessions."
last_tested: "2026-04-21"
render_with_liquid: false
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
