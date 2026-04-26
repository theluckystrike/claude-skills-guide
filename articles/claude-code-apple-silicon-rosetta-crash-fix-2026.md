---
layout: default
title: "Apple Silicon Rosetta Crash Error — Fix (2026)"
permalink: /claude-code-apple-silicon-rosetta-crash-fix-2026/
date: 2026-04-20
description: "Fix Claude Code crashing on Apple Silicon Mac. Install arm64-native Node.js instead of x86 version running through Rosetta."
last_tested: "2026-04-22"
---

## The Error

```
[1]    12345 killed     claude
$ file $(which node)
/usr/local/bin/node: Mach-O 64-bit executable x86_64
```

Claude Code crashes or is killed immediately on Apple Silicon Macs when running an x86_64 (Intel) Node.js binary through Rosetta 2 translation. This causes excessive memory usage and eventual OOM kills.

## The Fix

1. Check if your Node is native ARM64:

```bash
file $(which node)
# Should say: Mach-O 64-bit executable arm64
```

2. Install native ARM64 Node via nvm:

```bash
arch -arm64 zsh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zshrc
nvm install 22
```

3. Verify the architecture:

```bash
file $(which node)
# Must show: arm64
node -e "console.log(process.arch)"
# Must show: arm64
```

4. Reinstall Claude Code:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

When Node.js is installed via an Intel-only installer or from an x86 terminal session (Terminal opened via Rosetta), you get the x86_64 binary. Rosetta 2 translates it at runtime, adding 30-50% memory overhead. Claude Code's Node process can exceed available memory during large operations and get killed by the OOM killer. Native ARM64 Node uses half the memory.

## If That Doesn't Work

- Ensure your terminal itself is not running under Rosetta:

```bash
# Check terminal architecture
uname -m
# Should say: arm64, not x86_64
```

- If iTerm2 or Terminal shows x86_64, uncheck "Open using Rosetta" in the app's Get Info panel.

- Remove all Intel Node installations:

```bash
sudo rm -rf /usr/local/lib/node_modules
brew uninstall node  # If installed via x86 Homebrew
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Apple Silicon
- Always verify: uname -m returns arm64 before installing tools.
- Use nvm with native ARM64 shell. Never install Node from x86 terminal.
- If crashes occur, check: file $(which node) — must show arm64.
```

## See Also

- [VS Code Extension Host Crash Fix](/claude-code-extension-host-crash-fix-2026/)


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

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Crash Course with GitHub](/claude-code-crash-course-github/)
- [Conversation History OOM Crash — Fix (2026)](/claude-code-conversation-history-oom-fix-2026/)
- [Fix Claude Code Bun Crash (2026)](/claude-code-bun-crash/)

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
