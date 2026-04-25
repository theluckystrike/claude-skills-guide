---
title: "Streaming Buffer Overflow Error — Fix"
permalink: /claude-code-streaming-buffer-overflow-fix-2026/
description: "Fix streaming buffer overflow in Claude Code. Clear the output buffer and reduce response size to prevent terminal rendering crashes during long outputs."
last_tested: "2026-04-22"
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

## See Also

- [Streaming SSE Event Parse Error — Fix (2026)](/claude-code-streaming-sse-event-parse-error-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`
- `Warning: response may be incomplete due to token limit`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.

### How do I reduce token consumption in long sessions?

Start new conversations for unrelated tasks. Each message in a conversation includes the full history, so long conversations consume exponentially more tokens. A 50-message conversation may use 10x the tokens of five 10-message conversations.

### Can I see my token usage?

Run `claude usage` to see your current billing period's token consumption broken down by model. The Anthropic console at console.anthropic.com provides detailed usage graphs and per-day breakdowns.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

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
