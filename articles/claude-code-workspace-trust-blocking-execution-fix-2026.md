---
title: "Workspace Trust Blocking Execution Fix"
permalink: /claude-code-workspace-trust-blocking-execution-fix-2026/
description: "Fix VS Code workspace trust blocking Claude Code execution. Trust the workspace folder or configure restricted mode exceptions to enable full functionality."
last_tested: "2026-04-22"
render_with_liquid: false
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
