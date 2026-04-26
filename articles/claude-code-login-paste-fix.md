---
layout: default
title: "Fix Claude Code Login (2026)"
description: "Resolve the Claude Code CLI login issue where pasting the auth code from the browser fails. Linux, WSL, and paste bracketing fixes."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-login-paste-fix/
reviewed: true
categories: [Authentication & Login Issues]
tags: ["claude-code", "login", "paste", "authentication", "linux"]
geo_optimized: true
---

# Fix Claude Code Login — Cannot Paste Auth Code

> **TL;DR:** Claude Code's login prompt sometimes does not accept pasted text due to terminal paste bracketing. Disable paste bracketing, type the code manually, or use the `ANTHROPIC_API_KEY` environment variable instead.

## The Problem

When running `claude /login`, you complete the browser authorization flow and receive a code to paste back into the CLI. But when you try to paste it:

```
Paste code here if prompted >
```

Nothing happens. The pasted text does not appear, and pressing Enter gives an empty input error. This is a known regression affecting v2.1.105+ on Linux, WSL, and some macOS terminal configurations.

## Why This Happens

Modern terminals use "paste bracketing" — they wrap pasted text in escape sequences (`\e[200~....\e[201~`) to distinguish it from typed input. Claude Code's TUI input handler does not always process these escape sequences correctly, causing the pasted text to be silently discarded.

This is tracked as a known bug in the Claude Code repository (issues #47648, #47670, #47656).

## The Fix

### Step 1 — Try Disabling Paste Bracketing

Before running `claude /login`, disable paste bracketing in your terminal:

```bash
# Disable paste bracketing for the current session
printf '\e[?2004l'

# Then run login
claude /login
```

### Step 2 — Use Manual Typing (Short Codes)

If the auth code is short enough (usually 6-8 characters), type it manually character by character rather than pasting.

### Step 3 — Use API Key Authentication Instead

The most reliable workaround is to bypass the browser OAuth flow entirely:

```bash
# Get your API key from https://console.anthropic.com/
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# Add to your shell profile for persistence
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"' >> ~/.zshrc
source ~/.zshrc

# Verify Claude Code can authenticate
claude --version
```

### Step 4 — WSL-Specific Fix

If you are using WSL (Windows Subsystem for Linux), there is an additional issue where the WSL terminal does not pass clipboard contents correctly:

```bash
# Option 1: Use powershell.exe to get clipboard
CODE=$(powershell.exe -command "Get-Clipboard" | tr -d '\r')
echo "$CODE" | claude /login

# Option 2: Use xclip if X11 is configured
sudo apt install xclip
xclip -o -selection clipboard | claude /login
```

### Step 5 — Verify It Works

```bash
# Check authentication status
claude auth status
```

**Expected output:**

```
Authenticated as: your-email@example.com
Subscription: Pro/Max
API: Anthropic
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Paste works in other apps, not Claude | Paste bracketing in TUI | `printf '\e[?2004l'` before login |
| WSL2 paste broken | WSL clipboard isolation | Use `powershell.exe Get-Clipboard` pipe |
| Dev Container paste broken | Container terminal limitations | Use `ANTHROPIC_API_KEY` env var |
| SSH session paste broken | Remote terminal escape handling | Use API key auth or `tmux` paste |
| Works on v2.1.104, broken on v2.1.105 | Regression in TUI input | Downgrade or use API key auth |

## Prevention

- **Use API key auth for automated environments:** Set `ANTHROPIC_API_KEY` in CI/CD, containers, and remote sessions.
- **Pin working versions:** If paste regressions recur, pin to a known working version with `npm install -g @anthropic-ai/claude-code@2.1.104`.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-login-paste-fix)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Issues

- [Fix Claude API Error 401 — Unauthorized](/claude-api-error-401-fix/) — Auth token expired or invalid
- [Claude Code Config File Location](/claude-code-config-file-location/) — Where settings and credentials are stored
- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/) — Browse all auth guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Login Auth Redirect Loop Error — Fix (2026)](/claude-code-login-auth-redirect-loop-fix-2026/)


## Common Questions

### What causes fix claude code login issues?

Common causes include misconfigured settings, outdated dependencies, and environment conflicts. Check your project configuration and ensure all dependencies are up to date.

### How do I prevent this error from recurring?

Set up automated checks in your development workflow. Use Claude Code's built-in validation tools to catch configuration issues before they reach production.

### Does this fix work on all operating systems?

The core fix applies to macOS, Linux, and Windows. Some path-related adjustments may be needed depending on your OS. Check the platform-specific notes in the guide above.

## Related Resources

- [Fix Claude Code OAuth Login Paste Not](/claude-code-oauth-login-paste-not-working/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [Fix Claude Code API Error 400 Bad](/claude-code-api-error-400/)
