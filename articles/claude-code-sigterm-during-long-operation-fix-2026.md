---
title: "SIGTERM During Long Operation Fix (2026)"
permalink: /claude-code-sigterm-during-long-operation-fix-2026/
description: "Fix SIGTERM killing Claude Code during long operations. Increase bash timeout, use background execution, and handle signal traps to prevent data loss."
last_tested: "2026-04-22"
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


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Related Guides

- [Claude Code Conversation Too Long](/claude-code-conversation-too-long-fresh-vs-compact/)
- [Claude API System Prompt Too Long Error](/claude-api-system-prompt-too-long-error-fix/)
- [Claude Code Notification Setup for Long](/claude-code-notification-setup-for-long-tasks/)
- [Fix Claude MD Too Long Context Window](/claude-md-too-long-context-window-optimization/)

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
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error. This fix also applies if you see variations of this error: - Connection or process errors with similar root causes in the same subsystem - Timeout variants where the operation starts but does not complete - Permission variants where access is denied to the same resource - Configuration variants where the same setting is missing or malformed If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message."
      }
    }
  ]
}
</script>
