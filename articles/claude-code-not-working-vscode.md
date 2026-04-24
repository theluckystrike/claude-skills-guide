---
layout: default
title: "Fix Claude Code Not Working VSCode"
description: "Resolve Claude Code extension issues in VS Code — blank panels, missing output, connection errors, and WSL integration problems. Updated for 2026."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-not-working-vscode/
reviewed: true
categories: [Desktop & IDE Integration]
tags: ["claude-code", "vscode", "ide", "troubleshooting"]
geo_optimized: true
last_tested: "2026-04-22"
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

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-not-working-vscode)**

</div>

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-not-working-vscode)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Install Claude Code — All Platforms Guide](/claude-code-install-guide) — Fresh installation instructions
- [Fix Claude Code Login — Cannot Paste Auth Code](/claude-code-login-paste-fix) — Authentication issues
- [Claude Code Docker Desktop Workflow Tips](/claude-code-docker-desktop-workflow-tips/) — Browse all IDE guides

---

*If you debug browser extensions alongside VS Code work, [Zovo's developer tools](https://zovo.one) streamline the inspect-reload-test cycle for Chrome extensions.*

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



## Related Articles

- [Why Is Claude Code Producing Code That — Developer Guide](/why-is-claude-code-producing-code-that-does-not-run/)
- [Fix Claude Code Uncaught Typeerror Is Not A — Quick Guide](/claude-code-uncaught-typeerror-is-not-a-function/)
- [Claude Code Not Recognizing TypeScript — Developer Guide](/claude-code-not-recognizing-typescript-path-aliases-tsconfig/)
- [Why Is Claude Code Changing Files I Did — Developer Guide](/why-is-claude-code-changing-files-i-did-not-mention/)
- [Fix Claude Md Not Being Read By Claude Code — Quick Guide](/claude-md-not-being-read-by-claude-code-fix/)
- [Fix Claude Code Not Generating Tests — Quick Guide (2026)](/claude-code-not-generating-tests-correctly-fix-guide/)
- [Fix Claude Code Crashing in VS Code](/claude-code-crashing-vscode/)
- [Fix Claude Code Not Working in VS Code](/claude-code-not-working-in-vscode/)
