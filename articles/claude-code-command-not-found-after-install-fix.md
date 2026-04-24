---
layout: default
title: "Fix 'command not found"
description: "Resolve the 'command not found: claude' error after installing Claude Code on macOS, Linux, and Windows with PATH fixes."
date: 2026-04-15
permalink: /claude-code-command-not-found-after-install-fix/
categories: [troubleshooting, claude-code]
tags: [installation, PATH, command-not-found, setup]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Fix 'command not found: claude' After Install

## The Error

After running the Claude Code installer, you get one of these errors when trying to run `claude`:

```text
zsh: command not found: claude
```

```text
bash: claude: command not found
```

```text
'claude' is not recognized as an internal or external command
```

```text
claude : The term 'claude' is not recognized as the name of a cmdlet
```

## Quick Fix

The installer places the `claude` binary at `~/.local/bin/claude`. Add that directory to your PATH:

```bash
# macOS (zsh)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Linux (bash)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

On Windows PowerShell:

```powershell
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
[Environment]::SetEnvironmentVariable('PATH', "$currentPath;$env:USERPROFILE\.local\bin", 'User')
```

Restart your terminal, then verify:

```bash
claude --version
```

## What's Happening

The Claude Code installer downloads the binary to `~/.local/bin/claude` on macOS and Linux, or `%USERPROFILE%\.local\bin\claude.exe` on Windows. Your shell searches for programs in directories listed in the PATH environment variable. If `~/.local/bin` is not in your PATH, the shell cannot find the `claude` command even though the binary exists on disk.

This is the most common installation issue and affects all platforms equally. The installer adds a note about updating PATH, but if you close the terminal or miss the message, the next session will not find the binary.

## Step-by-Step Fix

### Step 1: Confirm the binary exists

Check that the installer actually placed the binary:

```bash
ls -la ~/.local/bin/claude
```

On Windows:

```powershell
Test-Path "$env:USERPROFILE\.local\bin\claude.exe"
```

If the file does not exist, the installation did not complete. Re-run the installer.

### Step 2: Check your current PATH

See if `~/.local/bin` is already in your PATH:

```bash
echo $PATH | tr ':' '\n' | grep local/bin
```

On Windows:

```powershell
$env:PATH -split ';' | Select-String 'local\\bin'
```

If there is no output, the directory is missing from PATH.

### Step 3: Add to PATH permanently

On macOS (default shell is zsh):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

On Linux (default shell is bash):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

On Windows PowerShell:

```powershell
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
[Environment]::SetEnvironmentVariable('PATH', "$currentPath;$env:USERPROFILE\.local\bin", 'User')
```

Restart your terminal after the Windows change.

### Step 4: Check for conflicting installations

If you previously installed Claude Code via npm, you may have multiple binaries:

```bash
which -a claude
```

Check for an npm global installation:

```bash
npm -g ls @anthropic-ai/claude-code 2>/dev/null
```

If you find duplicates, remove the extra installations. The native install at `~/.local/bin/claude` is recommended:

```bash
npm uninstall -g @anthropic-ai/claude-code
```

On macOS, remove a Homebrew install if present:

```bash
brew uninstall --cask claude-code
```

### Step 5: Verify the fix

```bash
claude --version
```

You should see the Claude Code version number.

## Prevention

After any fresh install, verify immediately:

```bash
claude --version
```

If you use a shell configuration manager like `oh-my-zsh` or `starship`, ensure your PATH modifications load before other plugins that might reset PATH. Place the `export PATH` line near the top of your shell configuration file.

For teams, add the PATH requirement to your onboarding documentation. Alternatively, use Homebrew on macOS or WinGet on Windows, which handle PATH automatically:

```bash
# macOS/Linux
brew install --cask claude-code

# Windows
winget install Anthropic.ClaudeCode
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-command-not-found-after-install-fix)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)
- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Claude Code Dev Containers Setup Guide](/claude-code-dev-containers-devcontainer-json-setup-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)

## See Also

- [Claude Code Notebook Kernel Not Found — Fix (2026)](/claude-code-notebook-kernel-not-found-fix-2026/)
- [PATH Not Updated After Install — Fix (2026)](/claude-code-path-not-updated-after-install-fix-2026/)
- [Claude Code Custom Slash Command Not Found — Fix (2026)](/claude-code-custom-slash-command-not-recognized-fix/)
- [claude: command not found After Install — Fix (2026)](/claude-code-binary-not-found-after-install-fix-2026/)
