---
title: "Claude Code VS Code Extension Fails (2026)"
description: "Fix Claude Code VS Code extension fails to activate. Clear extension cache and reinstall from marketplace. Step-by-step solution."
permalink: /claude-code-vscode-extension-fails-to-activate-fix/
last_tested: "2026-04-21"
---

## The Error

```
Extension 'anthropic.claude-code' failed to activate.
Reason: Cannot find module '@anthropic-ai/claude-code'
  at Module._resolveFilename (node:internal/modules/cjs/loader:1048:15)

# Or in the VS Code Output panel (Claude Code channel):
[Error] Extension host terminated unexpectedly.
  Error: ENOENT: no such file or directory, open '/Users/you/.vscode/extensions/anthropic.claude-code-1.0.0/dist/extension.js'
```

## The Fix

1. **Clear the extension cache and reinstall**

```bash
# Close VS Code first, then:
rm -rf ~/.vscode/extensions/anthropic.claude-code-*

# Clear VS Code extension cache
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs/anthropic.*
```

2. **Reinstall from command line**

```bash
code --install-extension anthropic.claude-code --force

# Or if using VS Code Insiders:
code-insiders --install-extension anthropic.claude-code --force
```

3. **Verify the fix:**

```bash
code --list-extensions | grep claude
# Expected: anthropic.claude-code

# Then open VS Code and check:
# View > Output > select "Claude Code" from dropdown
# Expected: "Claude Code extension activated successfully"
```

## Why This Happens

The VS Code extension activation failure occurs when the extension's JavaScript bundle is corrupted or missing. This happens during interrupted updates (VS Code updating the extension while the editor is closing), disk space issues during extraction, or when VS Code's extension host process crashes during installation. The extension depends on specific Node.js modules that must be present in the extension directory — if any are missing, activation fails on import.

## If That Doesn't Work

- **Alternative 1:** Download the VSIX directly from the marketplace and install manually: `code --install-extension ./claude-code-1.0.0.vsix`
- **Alternative 2:** Use Claude Code CLI directly in the integrated terminal — `claude` works without the extension
- **Check:** Open VS Code Developer Tools (`Cmd+Shift+I`) and check the Console tab for the exact activation error message

## Prevention

Add to your `CLAUDE.md`:
```markdown
Keep VS Code updated to the latest stable release. Disable auto-update for extensions if you experience frequent activation failures — update manually instead. Monitor the Output panel for Claude Code after each VS Code restart.
```

**Related articles:** [Claude Code Crashing VS Code](/claude-code-crashing-vscode/), [VS Code Connection Lost Fix](/claude-code-vscode-connection-lost-fix-2026/), [Claude Code Not Working in VS Code](/claude-code-not-working-in-vscode/)

## See Also

- [VS Code Extension Connection Timeout Fix](/claude-code-vscode-extension-connection-timeout-fix-2026/)
- [VS Code Extension Consuming Excessive CPU Fix](/claude-code-vscode-extension-excessive-cpu-fix-2026/)


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

- [Next.js Build Fails With Generated Code](/claude-code-nextjs-build-generated-code-fix-2026/)
- [Claude Code Error: npm Install Fails in Skill Workflow](/claude-code-error-npm-install-fails-in-skill-workflow/)
- [Fix: Claude Code Auth Fails on Headless](/claude-code-headless-linux-auth/)
- [Update Fails Behind Corporate Proxy](/claude-code-update-fails-behind-proxy-fix-2026/)

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
