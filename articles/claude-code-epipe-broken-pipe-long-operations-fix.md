---
title: "Claude Code EPIPE Broken Pipe Error (2026)"
description: "Fix Claude Code EPIPE broken pipe during long operations. Increase pipe buffer and handle SIGPIPE signals. Step-by-step solution."
permalink: /claude-code-epipe-broken-pipe-long-operations-fix/
last_tested: "2026-04-21"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Broken Link Finder Chrome Extension](/chrome-extension-broken-link-finder/)


## Step-by-Step Debugging Process

When you encounter pipe-related errors in Claude Code, follow this systematic debugging approach:

**Step 1: Identify the failing command.** Check the error output for the command that triggered the failure. The stack trace shows which process wrote to the closed pipe.

**Step 2: Check command output size.** Run the command alone (without piping) and check output size with `wc -l`. If the output exceeds 10,000 lines, it needs buffering or file redirection.

**Step 3: Replace pipes with file intermediaries.** Instead of `command1 | command2`, use `command1 > /tmp/intermediate.txt && command2 < /tmp/intermediate.txt`. This eliminates pipe buffer pressure entirely.

**Step 4: Set appropriate timeouts.** Long-running commands need matching timeout values. Check `CLAUDE_CODE_BASH_TIMEOUT` and ensure it exceeds the expected command duration by at least 50%.

**Step 5: Verify the fix under load.** Run the full workflow three times consecutively to confirm the error does not recur under typical conditions.


## Platform-Specific Pipe Buffer Sizes

Pipe buffer capacity varies by operating system, and understanding these limits helps prevent EPIPE errors before they occur:

| Platform | Default Pipe Buffer | Maximum Pipe Buffer | Check Command |
|----------|-------------------|-------------------|---------------|
| macOS | 16KB | 64KB | `sysctl kern.maxpipekva` |
| Linux | 64KB | 1MB (adjustable) | `cat /proc/sys/fs/pipe-max-size` |
| WSL2 | 64KB | 1MB | Same as Linux |

When a producer writes faster than the consumer reads, the pipe buffer fills up. Once full, the producer blocks until space is available. If the consumer exits while the producer is blocked or actively writing, the kernel delivers SIGPIPE to the producer process, which Node.js surfaces as the EPIPE error. For commands producing more than the buffer size in output, always prefer file-based intermediaries over direct pipes.

On macOS, the kernel limits total pipe buffer memory across all processes through the `kern.maxpipekva` sysctl parameter. On systems running many concurrent Claude Code sessions, this global limit can become a bottleneck even when individual pipes are within their per-pipe limits. Monitor with `sysctl kern.maxpipekva` and increase if needed through `/etc/sysctl.conf`.

## Common Scenarios That Trigger This Error

**Large repository searches.** Running `grep -r` or `find` across a repository with 50,000+ files produces output faster than the pipe consumer can process it. Use `--max-count` or `-maxdepth` to limit output volume.

**Build output during CI.** Build tools like webpack, tsc, and esbuild produce verbose output during compilation. If Claude Code's process supervisor terminates the build mid-output, the pipe breaks. Redirect build output to a log file.

**Streaming API responses.** When Claude Code processes long streaming responses and the connection is interrupted (timeout, network drop), the write side of the stream receives EPIPE. Implement proper stream error handlers with `.on('error', handler)`.

**Parallel tool execution.** Claude Code may run multiple bash commands simultaneously. If system pipe buffer capacity (typically 64KB on macOS, 65KB on Linux) is exhausted across all concurrent pipes, writes block and eventually fail.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
