---
layout: default
title: "Claude Code Command Not Found After Install: Troubleshooting Guide"
description: "Fix the 'claude: command not found' error after installing Claude Code. Practical solutions for PATH issues, shell configuration, and installation problems."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-command-not-found-after-install-troubleshooting/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills]
---

# Claude Code Command Not Found After Install: Troubleshooting Guide

Installing Claude Code should give you immediate access to the `claude` CLI tool. Instead, you're staring at `zsh: command not found: claude`. This happens more often than you'd think, and the fix is usually straightforward.

This guide walks through the most common causes and their solutions, so you can get back to coding with Claude's AI assistance.

## Understanding the Problem

When you install Claude Code, the installer adds the Claude CLI to a specific directory on your system. Your shell needs to know where to find that executable. If the installation directory isn't in your PATH environment variable, your terminal simply cannot locate the `claude` command.

The error message might appear as:

```
zsh: command not found: claude
```

or

```
bash: claude: command not found
```

The root cause is almost always PATH-related, but there are a few other possibilities worth checking.

## Solution 1: Verify the Installation Location

First, confirm where Claude Code was actually installed. Run this command to search for the executable:

```bash
sudo find /usr -name "claude" -type f 2>/dev/null
sudo find /usr/local -name "claude" -type f 2>/dev/null
sudo find "$HOME" -name "claude" -type f 2>/dev/null
```

On macOS, the installer typically places the CLI in `/usr/local/bin/` or `~/.local/bin/`. On Linux systems, it might go to `/usr/bin/` or a user-local directory.

Once you locate the executable, note the full path. You'll need it for the next steps.

## Solution 2: Check Your PATH Configuration

Your shell searches for commands in directories listed in the PATH environment variable. Let's verify what's currently in your PATH:

```bash
echo $PATH
```

If the directory containing the Claude executable isn't listed, you need to add it. Open your shell configuration file:

**For Zsh (macOS default):**
```bash
nano ~/.zshrc
```

**For Bash:**
```bash
nano ~/.bashrc
```

Add this line to the end of the file, replacing `/usr/local/bin` with the actual path where Claude is installed:

```bash
export PATH="/usr/local/bin:$PATH"
```

Save the file and reload your shell configuration:

```bash
source ~/.zshrc   # for Zsh
source ~/.bashrc  # for Bash
```

Now try running `claude` again:

```bash
claude --version
```

## Solution 3: Fix Shell Initialization Issues

Sometimes the PATH is correct in login shells but not in interactive non-login shells. This commonly happens on macOS when using Terminal or iTerm2.

The installer typically adds a snippet to your shell config that handles this. Check if the following appears in your `~/.zshrc`:

```bash
# Claude Code installer
if [ -f "/usr/local/bin/claude" ]; then
    export CLAUDE_PATH="/usr/local/bin/claude"
fi
```

If the installer snippet is missing or corrupted, manually add it. Alternatively, some users find success by placing PATH exports at the very top of their shell config, before any conditional logic or framework initializations.

## Solution 4: Handle symlink Issues

The Claude installer may create a symbolic link rather than copying the binary directly. Verify the symlink exists and points to a valid target:

```bash
ls -la /usr/local/bin/claude
```

If you see something like `claude -> ../Cellar/claude/...`, verify the target exists. Broken symlinks are a common cause of this error. Recreate the symlink if needed:

```bash
sudo ln -sf /path/to/actual/claude /usr/local/bin/claude
```

## Solution 5: Reinstall Claude Code

If the above solutions don't work, the installation may be corrupted or incomplete. Reinstalling is often faster than debugging further.

Uninstall the current installation:

```bash
sudo rm -f /usr/local/bin/claude
sudo rm -rf ~/.claude
```

Then reinstall using the official installer:

```bash
curl -sSL https://raw.githubusercontent.com/anthropics/claude-cli/main/install.sh | sh
```

Or download the latest release from the official repository and follow the installation instructions specific to your operating system.

## Solution 6: Verify Permissions

Permission issues can prevent the shell from executing the Claude binary. Check the file permissions:

```bash
ls -la /usr/local/bin/claude
```

The file should have execute permissions (look for `x` in the permissions string). If it doesn't, fix it:

```bash
sudo chmod +x /usr/local/bin/claude
```

Also ensure your user has read access to the file and its parent directories.

## Using Claude Skills Once Working

Once you resolve the command not found error, you'll have access to Claude's full ecosystem. [Best Claude Code skills to install first](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) covers which skills are worth adding immediately. Skills extend Claude's capabilities for specialized tasks. The `frontend-design` skill helps generate UI components and layouts. The `pdf` skill enables document manipulation and extraction. The `tdd` skill assists with test-driven development workflows.

Other valuable skills include `supermemory` for managing project context across sessions, `docx` for Word document automation, and `xlsx` for spreadsheet operations. You can explore and install skills using the `claude skill` commands.

## Prevention Tips

To avoid this issue in the future, keep these tips in mind:

1. **Restart your terminal** after installing CLI tools to ensure shell initialization completes properly
2. **Use explicit paths** when debugging: `/usr/local/bin/claude --version` confirms the binary works even if PATH is broken
3. **Check shell framework configs** if you use Oh My Zsh or similar frameworks—they may override PATH settings

## Wrapping Up

The "claude: command not found" error almost always comes down to PATH configuration. By locating the executable, adding its directory to PATH, and verifying permissions, you can resolve this in under five minutes.

If you continue experiencing issues after trying these solutions, check the official Claude Code documentation or open an issue on the GitHub repository with details about your operating system and installation method.

## Related Reading

- [Claude Code Setup on Mac: Step-by-Step Guide](/claude-skills-guide/claude-code-setup-on-mac-step-by-step/) — Full installation walkthrough for macOS
- [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) — First skills to add once Claude is running
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/) — Full orientation for new users
- [Claude Skills Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/) — More installation and setup troubleshooting guides

Built by theluckystrike — More at [zovo.one](https://zovo.one)
