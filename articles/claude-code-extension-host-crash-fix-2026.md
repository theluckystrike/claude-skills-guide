---
layout: default
title: "VS Code Extension Host Crash Fix (2026)"
permalink: /claude-code-extension-host-crash-fix-2026/
date: 2026-04-20
description: "Fix VS Code extension host crash caused by Claude Code. Disable conflicting extensions and increase memory limit to stabilize the extension host process."
last_tested: "2026-04-22"
---

## The Error

```
[Extension Host] terminated unexpectedly with code 137 (SIGKILL)
  Extension host was killed due to memory pressure
  Claude Code extension and 23 other extensions consumed 2.1GB
  Restarting extension host... Claude Code extension may need reconfiguration
```

This appears when VS Code's extension host process crashes due to excessive memory usage, often caused by the Claude Code extension combined with other memory-heavy extensions.

## The Fix

```bash
# In VS Code, disable non-essential extensions for the workspace:
# Cmd+Shift+P > Extensions: Show Installed Extensions
# Disable extensions you don't need for this project
```

1. Open the Extensions sidebar in VS Code.
2. Disable memory-heavy extensions you do not need (GitLens, Remote SSH, Docker, etc.).
3. Restart VS Code to apply the changes.

## Why This Happens

VS Code runs all extensions in a shared "extension host" Node.js process. When multiple extensions consume significant memory — Claude Code for context indexing, GitLens for git history, TypeScript language server for type checking — the combined usage can exceed the extension host's memory limit. The OS kills the process with SIGKILL (code 137), and VS Code restarts it. Extensions like Claude Code lose their state during the crash.

## If That Doesn't Work

Increase the extension host memory limit:

```json
// VS Code settings.json (user-level)
{
  "extensions.experimental.affinity": {
    "anthropic.claude-code": 2
  }
}
```

Run Claude Code in a separate process via the terminal:

```bash
# Use CLI directly instead of the VS Code extension
claude
```

Check which extensions use the most memory:

```
Help > Open Process Explorer
# Look at "Extension Host" children
```

Disable extensions per-workspace to avoid blanket disabling:

```json
// .vscode/settings.json
{
  "extensions.ignoreRecommendations": true
}
```

## Prevention

```markdown
# CLAUDE.md rule
Keep VS Code extension count under 20 for best performance. Use per-workspace extension profiles to load only what you need. If the extension host crashes, check Process Explorer for memory usage and disable the heaviest extensions.
```

## See Also

- [Apple Silicon Rosetta Crash Error — Fix (2026)](/claude-code-apple-silicon-rosetta-crash-fix-2026/)


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

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Crash Course with GitHub](/claude-code-crash-course-github/)
- [Conversation History OOM Crash — Fix (2026)](/claude-code-conversation-history-oom-fix-2026/)
- [Fix Claude Code Bun Crash (2026)](/claude-code-bun-crash/)
- [Virtual Background Chrome Extension](/virtual-background-chrome-extension/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
