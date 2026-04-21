---
title: "Streaming Buffer Overflow Error Fix"
permalink: /claude-code-streaming-buffer-overflow-fix-2026/
description: "Fix streaming buffer overflow in Claude Code. Clear the output buffer and reduce response size to prevent terminal rendering crashes during long outputs."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Stream buffer overflow — accumulated 64MB of unprocessed chunks
  at StreamProcessor.push (stream.js:89)
  EPIPE: broken pipe — terminal cannot consume output fast enough
```

This appears when Claude Code streams a very large response faster than the terminal can render it, causing the internal buffer to overflow.

## The Fix

```bash
claude --output-format json "Your prompt" > output.json
```

1. Redirect large outputs to a file instead of rendering them in the terminal.
2. For interactive sessions, ask Claude Code to write results to files using the Write tool rather than printing them inline.
3. Restart the terminal if it becomes unresponsive after a buffer overflow.

## Why This Happens

Claude Code streams responses token-by-token to the terminal. When the response contains thousands of lines of code or large diff outputs, the terminal emulator falls behind on rendering. The internal Node.js stream buffer accumulates unread chunks. Once it exceeds the high-water mark (typically 64MB), the stream errors out with a buffer overflow or broken pipe error.

## If That Doesn't Work

Reduce the terminal's scroll buffer to free up rendering resources:

```bash
# In iTerm2: Preferences → Profiles → Terminal → Scrollback lines: 1000
# In Terminal.app: Preferences → Profiles → Window → Scrollback: limit to 1000
```

Use a simpler terminal renderer:

```bash
TERM=dumb claude "Generate the migration file"
```

Pipe output through a pager:

```bash
claude --print "List all routes" 2>&1 | less
```

## Prevention

```markdown
# CLAUDE.md rule
For outputs longer than 200 lines, always write to a file using the Write tool instead of printing to terminal. Never generate large diffs inline.
```
