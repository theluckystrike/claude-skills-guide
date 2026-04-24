---
title: "Workspace Trust Required for Claude"
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

## See Also

- [Claude Code Workspace Trust Blocks Headless — Fix (2026)](/claude-code-workspace-trust-blocks-headless-mode-fix/)
- [Node 18+ Required Version Error — Fix (2026)](/claude-code-node-version-18-required-fix-2026/)
- [Workspace Trust Blocking Execution Fix](/claude-code-workspace-trust-blocking-execution-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`
- `MODULE_NOT_FOUND: Cannot find module 'node:fs'`
- `Error reading configuration file`
- `JSON parse error in config`

## Frequently Asked Questions

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.

### How do I manage multiple Node.js versions?

Use nvm (Node Version Manager): `nvm install 20 && nvm use 20`. This lets you switch between Node.js versions per-project without affecting other applications. Add a `.nvmrc` file with `20` to your project root so nvm automatically selects the right version.

### Why does Claude Code fail with the node:fs prefix?

The `node:` prefix for built-in modules was introduced in Node.js 16. If you see errors about `node:fs` or `node:path`, you are running an older Node.js version that does not support this syntax. Upgrade to Node.js 18 or later.

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.
