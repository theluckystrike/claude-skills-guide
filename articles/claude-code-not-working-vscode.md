---
layout: default
title: "Fix Claude Code Not Working in VS Code"
description: "Resolve Claude Code extension issues in VS Code — blank panels, missing output, connection errors, and WSL integration problems."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-code-not-working-vscode/
reviewed: true
categories: [Desktop & IDE Integration]
tags: ["claude-code", "vscode", "ide", "troubleshooting"]
---

# Fix Claude Code Not Working in VS Code

> **TL;DR:** Verify the CLI is installed and on PATH, check the extension version, restart VS Code, and inspect the output channel for errors.

## The Problem

Claude Code is installed but not working in VS Code. Symptoms include:

- The Claude Code panel is blank or shows "connecting..."
- Commands typed in the panel produce no response
- The extension icon appears but clicking it does nothing
- Error: "Claude Code CLI not found"

## Why This Happens

The VS Code extension is a thin wrapper around the Claude Code CLI. It fails when:

- The CLI is not installed or not on VS Code's PATH
- VS Code is using a different shell profile than your terminal
- The extension version is incompatible with the installed CLI version
- WSL remote sessions have different PATH/environment than the host
- Another extension is conflicting

## The Fix

### Step 1 — Verify the CLI Is Installed and on PATH

Open VS Code's integrated terminal (Ctrl+`) and run:

```bash
which claude
claude --version
```

If `which claude` returns nothing, the CLI is not on VS Code's PATH. Fix it:

```bash
# Find where claude is installed
npm list -g @anthropic-ai/claude-code

# Common location
ls ~/.npm-global/bin/claude 2>/dev/null || ls /usr/local/bin/claude 2>/dev/null

# Add to VS Code's PATH - edit your shell profile
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
```

Then restart VS Code completely (not just reload window).

### Step 2 — Check the Extension Output Channel

1. Open VS Code Command Palette (Cmd+Shift+P / Ctrl+Shift+P)
2. Type "Output: Focus on Output View"
3. In the output panel dropdown, select "Claude Code"
4. Look for error messages

Common errors:
- "ENOENT: claude not found" — CLI not on PATH (see Step 1)
- "Authentication required" — Run `claude /login` in the integrated terminal
- "Connection refused" — Extension cannot communicate with CLI process

### Step 3 — Restart the Extension

1. Open Command Palette (Cmd+Shift+P / Ctrl+Shift+P)
2. Type "Developer: Restart Extension Host"
3. Wait for extensions to reload

If that does not work, fully quit and reopen VS Code.

### Step 4 — WSL-Specific Fix

If you are using VS Code Remote — WSL:

```bash
# Inside WSL terminal in VS Code
# Install Claude Code in WSL, not just on Windows
npm install -g @anthropic-ai/claude-code

# Authenticate inside WSL
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"
# Or run: claude /login

# Verify
claude --version
```

The extension in WSL mode uses the WSL environment, not the Windows host.

### Step 5 — Verify It Works

After fixes, test in VS Code:

1. Open the Claude Code panel
2. Type a simple query: "What is 2+2?"
3. Verify you get a response

**Expected behavior:** Claude responds within a few seconds with the answer.

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Works in terminal, not in VS Code | Different PATH | Add npm bin dir to VS Code terminal profile |
| Works on first open, fails later | Extension crash | Restart Extension Host |
| WSL: extension hangs | CLI not installed in WSL | Install CLI inside WSL |
| Input corrupts (Cyrillic chars) | Encoding bug (Windows) | Update extension, use CLI directly |
| Panel shows 1M context limit | Large project indexing | Exclude `node_modules` from workspace |
| Cursor IDE: not working | Different extension API | Claude Code may need Cursor-specific build |

## Prevention

- **Keep CLI and extension in sync:** Update both together with `npm update -g @anthropic-ai/claude-code` and VS Code extension auto-update.
- **Use `ANTHROPIC_API_KEY` in WSL:** Browser-based OAuth is unreliable in WSL; environment variable auth is more stable.

## Related Issues

- [Install Claude Code — All Platforms Guide](/claude-code-install-guide) — Fresh installation instructions
- [Fix Claude Code Login — Cannot Paste Auth Code](/claude-code-login-paste-fix) — Authentication issues
- [Claude Code Docker Desktop Workflow Tips](/claude-code-docker-desktop-workflow-tips/) — Browse all IDE guides

---

*If you debug browser extensions alongside VS Code work, [Zovo's developer tools](https://zovo.one) streamline the inspect-reload-test cycle for Chrome extensions.*

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
