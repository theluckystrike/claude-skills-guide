---
title: "Claude Code VS Code Extension Fails to Activate — Fix (2026)"
description: "Fix Claude Code VS Code extension fails to activate. Clear extension cache and reinstall from marketplace. Step-by-step solution."
permalink: /claude-code-vscode-extension-fails-to-activate-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
