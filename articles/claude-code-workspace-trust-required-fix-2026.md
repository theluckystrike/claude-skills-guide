---
title: "Workspace Trust Required for Claude Code — Fix (2026)"
permalink: /claude-code-workspace-trust-required-fix-2026/
description: "Grant workspace trust via the VS Code Manage Workspace Trust command palette option. Enables Claude Code operations in restricted workspace folders."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Workspace is not trusted. Claude Code requires workspace trust to operate.
```

## The Fix

```bash
# In VS Code Command Palette (Cmd+Shift+P / Ctrl+Shift+P):
# Run: Workspaces: Manage Workspace Trust
# Click "Trust" for the current folder

# Or add the folder to your trusted list in settings.json:
code ~/.config/Code/User/settings.json
```

```json
{
  "security.workspace.trust.enabled": true,
  "security.workspace.trust.untrustedFiles": "open"
}
```

## Why This Works

VS Code Workspace Trust restricts extensions from executing code in untrusted folders. Claude Code requires trust because it reads files, runs terminal commands, and modifies code. Without trust, VS Code blocks these operations at the API level. Granting trust enables the full extension capability set.

## If That Doesn't Work

```bash
# If the trust banner never appears, reset trust state
rm -rf ~/.config/Code/User/workspaceStorage/*/trust.json
# Reopen VS Code — the trust prompt will appear fresh

# For Remote SSH or Containers, trust must be granted on the remote side:
# Command Palette > Remote: Manage Workspace Trust
```

On managed machines with group policy, workspace trust settings may be locked by IT. Check if `security.workspace.trust.enabled` is enforced in the policy settings.

## Prevention

Add to your CLAUDE.md:
```
Always open project folders as trusted workspaces. If cloning new repositories, grant trust on first open to avoid extension initialization failures.
```
