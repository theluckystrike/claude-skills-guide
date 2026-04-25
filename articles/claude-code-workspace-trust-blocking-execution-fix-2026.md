---
layout: default
title: "Workspace Trust Blocking Execution Fix (2026)"
permalink: /claude-code-workspace-trust-blocking-execution-fix-2026/
date: 2026-04-20
description: "Fix VS Code workspace trust blocking Claude Code execution. Trust the workspace folder or configure restricted mode exceptions to enable full functionality."
last_tested: "2026-04-22"
---

## The Error

```
[Claude Code Extension] Workspace is not trusted
  Cannot execute commands in restricted mode
  VS Code Workspace Trust is blocking Claude Code tool execution
  Enable trust for this workspace to use Claude Code features
```

This appears when VS Code's Workspace Trust feature has the current folder in restricted mode, preventing Claude Code from executing any tools.

## The Fix

```
Cmd+Shift+P > Workspaces: Manage Workspace Trust
> Click "Trust" for the current workspace folder
```

1. Open the VS Code command palette.
2. Search for "Manage Workspace Trust".
3. Click "Trust" to grant the workspace full permissions.
4. Restart Claude Code in the terminal.

## Why This Happens

VS Code's Workspace Trust feature (introduced in VS Code 1.57) prevents extensions from executing code in untrusted workspaces. When you open a folder for the first time or from an untrusted source (like a downloaded repo), VS Code starts in restricted mode. In this mode, the Claude Code extension cannot execute Bash commands, write files, or run any tools that modify the filesystem. The extension detects restricted mode and refuses to operate.

## If That Doesn't Work

Disable Workspace Trust entirely (only if you trust all code you open):

```json
// VS Code settings.json
{
  "security.workspace.trust.enabled": false
}
```

Add specific folders to the trust list:

```json
// VS Code settings.json
{
  "security.workspace.trust.untrustedFiles": "open",
  "security.workspace.trust.banner": "never"
}
```

Run Claude Code from the system terminal instead of VS Code:

```bash
# Open Terminal.app or iTerm2 independently
cd /path/to/project
claude
```

## Prevention

```markdown
# CLAUDE.md rule
Trust this workspace in VS Code before using Claude Code. If prompted about workspace trust, select "Trust" — Claude Code cannot function in restricted mode. Or run Claude Code from a standalone terminal.
```

## See Also

- [macOS Gatekeeper Blocking Binary Fix](/claude-code-macos-gatekeeper-blocking-binary-fix-2026/)
- [Claude Code Workspace Trust Blocks Headless — Fix (2026)](/claude-code-workspace-trust-blocks-headless-mode-fix/)
- [Workspace Trust Required for Claude Code — Fix (2026)](/claude-code-workspace-trust-required-fix-2026/)


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

- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/)
- [Claude Code Parallel Task Execution](/claude-code-parallel-task-execution-workflow/)
- [Parallel AI Agent Execution Patterns](/parallel-ai-agent-execution-patterns-and-trade-offs/)
- [Karpathy Goal-Driven Execution](/karpathy-goal-driven-execution-principle-2026/)

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
