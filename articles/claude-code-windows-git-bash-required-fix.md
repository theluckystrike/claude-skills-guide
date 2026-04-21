---
layout: default
title: "Fix Claude Code Windows Requires Git Bash (2026)"
description: "Resolve the 'Claude Code on Windows requires git-bash' error by installing Git for Windows or setting the Git Bash path in settings. Updated for 2026."
date: 2026-04-15
permalink: /claude-code-windows-git-bash-required-fix/
categories: [troubleshooting, claude-code]
tags: [windows, git-bash, installation, setup]
last_modified_at: 2026-04-17
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix Claude Code Windows Requires Git Bash

## The Error

When running Claude Code on Windows, you see:

```text
Claude Code on Windows requires git-bash
```

## Quick Fix

Install Git for Windows from [git-scm.com/downloads/win](https://git-scm.com/downloads/win). During installation, select "Add to PATH." Restart your terminal.

If Git is already installed, set the path in your settings:

```json
{
 "env": {
 "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
 }
}
```

## What's Happening

Claude Code on native Windows requires Git for Windows, which includes Git Bash. Claude Code uses Git Bash as its shell environment for executing commands because it provides a Unix-like shell experience with standard utilities (`grep`, `find`, `sed`, etc.) that Claude's tools expect.

Without Git Bash available in the system PATH, Claude Code cannot execute shell commands and displays this error at startup.

## Step-by-Step Fix

### Step 1: Check if Git is installed

Open PowerShell and run:

```powershell
where.exe git
```

If this returns a path, Git is installed but Claude Code may not be finding Git Bash.

### Step 2: Install Git for Windows

If Git is not installed, download it from [git-scm.com/downloads/win](https://git-scm.com/downloads/win).

During installation:
1. Select "Add to PATH" when prompted
2. Keep the default installation directory (`C:\Program Files\Git`)
3. Complete the installation

Restart your terminal after installing.

### Step 3: Set Git Bash path manually

If Git is installed but Claude Code still cannot find it, explicitly set the path. Find where Git Bash is located:

```powershell
where.exe git
```

This might return something like `C:\Program Files\Git\cmd\git.exe`. The bash executable is at `C:\Program Files\Git\bin\bash.exe`.

Add this to your settings at `%USERPROFILE%\.claude\settings.json`:

```json
{
 "env": {
 "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
 }
}
```

If your Git is installed somewhere else, adjust the path accordingly.

### Step 4: Verify the fix

Open a new terminal and run:

```powershell
claude --version
```

Claude Code should start without the Git Bash error.

### Step 5: Fix 32-bit PowerShell confusion

If you also see "Claude Code does not support 32-bit Windows," verify you are using the correct PowerShell:

```powershell
[Environment]::Is64BitOperatingSystem
```

If this returns `True`, you are on a 64-bit system but opened the 32-bit PowerShell (labeled "Windows PowerShell (x86)" in the Start menu). Close it and open "Windows PowerShell" without the x86 suffix.

### Step 6: Handle Claude Desktop conflict

If running `claude` opens Claude Desktop instead of Claude Code CLI, an older version of Claude Desktop registered a `Claude.exe` in the WindowsApps directory that takes PATH priority.

Update Claude Desktop to the latest version, which resolves this conflict.

## Prevention

When setting up Claude Code on Windows for a team, include Git for Windows in your standard development environment. Add the `CLAUDE_CODE_GIT_BASH_PATH` setting to your managed settings if Git is installed in a non-standard location.

For Windows users who prefer to avoid Git Bash, consider using WSL (Windows Subsystem for Linux) where Claude Code runs in a full Linux environment without this requirement.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-windows-git-bash-required-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code Dev Containers Setup Guide](/claude-code-dev-containers-devcontainer-json-setup-guide/)
- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)


