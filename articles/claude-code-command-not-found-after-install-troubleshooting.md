---
layout: default
title: "Fix Claude Command Not Found After"
description: "Fix zsh/bash 'claude: command not found' after install. Step-by-step PATH fix with copy-paste commands. Works in 2 minutes."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-command-not-found-after-install-troubleshooting/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills]
geo_optimized: true
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

## Why PATH Errors Happen

To understand the fix, it helps to understand what PATH actually does. When you type a command in your terminal, your shell doesn't search your entire filesystem. It only looks in directories listed in the `PATH` environment variable, checked left to right. If the directory containing `claude` is not in that list, the shell gives up immediately and reports "command not found."

This is a deliberate security feature: unrestricted command lookup would allow malicious binaries in unexpected directories to shadow system commands. The downside is that newly installed tools sometimes end up in directories that aren't already in PATH, especially when the installation uses a user-local directory rather than a system-wide one.

On macOS, the typical culprit is `~/.local/bin` or `~/.npm-global/bin`. directories that are common targets for user-mode installs but are not included in the default system PATH. On Linux, similar issues arise with `/opt` subdirectories or snap/flatpak wrappers.

## Quick Diagnostic Checklist

Before diving into detailed solutions, run through this fast checklist:

| Check | Command | Expected Result |
|---|---|---|
| Binary exists | `which claude` | Prints a path |
| Binary is executable | `ls -la $(which claude)` | Shows `-rwxr-xr-x` |
| PATH contains install dir | `echo $PATH` | Directory is listed |
| Shell config loaded | `source ~/.zshrc` | No errors |
| Node / npm version OK | `node --version` | v18+ recommended |

If `which claude` returns nothing, the binary either was not installed or is in a directory not in PATH. If it returns a path but running `claude` still fails, the issue is permissions or a broken symlink.

## Solution 1: Verify the Installation Location

First, confirm where Claude Code was actually installed. Run this command to search for the executable:

```bash
sudo find /usr -name "claude" -type f 2>/dev/null
sudo find /usr/local -name "claude" -type f 2>/dev/null
sudo find "$HOME" -name "claude" -type f 2>/dev/null
```

On macOS, the installer typically places the CLI in `/usr/local/bin/` or `~/.local/bin/`. On Linux systems, it might go to `/usr/bin/` or a user-local directory.

If you installed Claude Code via npm (the most common method), check the npm global bin directory:

```bash
npm config get prefix
```

The output will be something like `/usr/local` or `/Users/yourname/.npm-global`. The `claude` binary lives in the `bin` subdirectory of that path. So if npm prefix is `/Users/yourname/.npm-global`, look for the binary at `/Users/yourname/.npm-global/bin/claude`.

Once you locate the executable, note the full path. You'll need it for the next steps.

## Solution 2: Check Your PATH Configuration

Your shell searches for commands in directories listed in the PATH environment variable. Let's verify what's currently in your PATH:

```bash
echo $PATH
```

A typical healthy PATH on macOS looks something like this:

```
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/yourname/.local/bin
```

If the directory containing the Claude executable isn't listed, you need to add it. Open your shell configuration file:

For Zsh (macOS default since Catalina):
```bash
nano ~/.zshrc
```

For Bash:
```bash
nano ~/.bashrc
```

For Fish shell:
```bash
nano ~/.config/fish/config.fish
```

Add this line to the end of the file, replacing `/usr/local/bin` with the actual path where Claude is installed:

```bash
export PATH="/usr/local/bin:$PATH"
```

For Fish shell, the syntax is different:

```fish
fish_add_path /usr/local/bin
```

Save the file and reload your shell configuration:

```bash
source ~/.zshrc # for Zsh
source ~/.bashrc # for Bash
```

Now try running `claude` again:

```bash
claude --version
```

## Common PATH Additions by Install Method

| Install Method | Typical Binary Location | PATH Line to Add |
|---|---|---|
| npm global (system) | `/usr/local/bin` | `export PATH="/usr/local/bin:$PATH"` |
| npm global (user) | `~/.npm-global/bin` | `export PATH="$HOME/.npm-global/bin:$PATH"` |
| Homebrew | `/opt/homebrew/bin` | `export PATH="/opt/homebrew/bin:$PATH"` |
| Manual download | `~/.local/bin` | `export PATH="$HOME/.local/bin:$PATH"` |
| nvm-managed node | `~/.nvm/versions/node/vX.X.X/bin` | Set via nvm (see below) |

## Solution 3: Fix Shell Initialization Issues

Sometimes the PATH is correct in login shells but not in interactive non-login shells. This commonly happens on macOS when using Terminal or iTerm2.

The distinction matters because macOS Terminal opens login shells by default, but tmux panes and many IDE integrated terminals open non-login interactive shells. Login shells read `~/.zprofile` (Zsh) or `~/.bash_profile` (Bash), while non-login interactive shells only read `~/.zshrc` or `~/.bashrc`.

The installer typically adds a snippet to your shell config that handles this. Check if the following appears in your `~/.zshrc`:

```bash
Claude Code installer
if [ -f "/usr/local/bin/claude" ]; then
 export CLAUDE_PATH="/usr/local/bin/claude"
fi
```

If the installer snippet is missing or corrupted, manually add it. Alternatively, some users find success by placing PATH exports at the very top of their shell config, before any conditional logic or framework initializations.

## Diagnosing Login vs. Non-Login Shell Problems

You can confirm which type of shell you are running with:

```bash
echo $0
```

A `-zsh` prefix (with the dash) indicates a login shell. Plain `zsh` means non-login. If the binary works in a fresh terminal window (login shell) but not in your IDE's terminal (non-login shell), move your PATH export from `~/.zprofile` to `~/.zshrc`.

A reliable fix that covers both shell types is to source your `.zshrc` from `.zprofile`:

```bash
~/.zprofile
if [ -f "$HOME/.zshrc" ]; then
 source "$HOME/.zshrc"
fi
```

nvm / asdf Version Manager Conflicts

If you manage Node.js with nvm or asdf, the PATH they inject may not include the global npm bin directory correctly. After installing via npm, verify the correct node and npm are active:

```bash
nvm use --lts # or your required version
npm install -g @anthropic-ai/claude-code
claude --version
```

With asdf:

```bash
asdf global nodejs latest
npm install -g @anthropic-ai/claude-code
claude --version
```

These version managers insert their shim directories early in PATH, which can shadow the system npm and cause installs to land in unexpected places.

## Solution 4: Handle Symlink Issues

The Claude installer may create a symbolic link rather than copying the binary directly. Verify the symlink exists and points to a valid target:

```bash
ls -la /usr/local/bin/claude
```

If you see something like `claude -> ../Cellar/claude/...`, verify the target exists. Broken symlinks are a common cause of this error. Recreate the symlink if needed:

```bash
sudo ln -sf /path/to/actual/claude /usr/local/bin/claude
```

To check whether a symlink target is valid, use `readlink`:

```bash
readlink -f /usr/local/bin/claude
```

If this returns an empty string or a path that does not exist, the symlink is broken. Find the actual binary first (Solution 1), then recreate the symlink pointing to it.

Example of a broken vs. working symlink:

```bash
Broken symlink (target missing)
lrwxr-xr-x 1 root wheel 38 Mar 12 09:14 /usr/local/bin/claude -> /usr/local/lib/node_modules/@anthropic-ai/claude-code/bin/claude

Check target
ls /usr/local/lib/node_modules/@anthropic-ai/claude-code/bin/claude
ls: No such file or directory <-- broken

Fix: reinstall the package
sudo npm install -g @anthropic-ai/claude-code
```

## Solution 5: Reinstall Claude Code

If the above solutions don't work, the installation is corrupted or incomplete. Reinstalling is often faster than debugging further.

Uninstall the current installation:

```bash
sudo rm -f /usr/local/bin/claude
sudo rm -rf ~/.claude
```

If installed via npm:

```bash
npm uninstall -g @anthropic-ai/claude-code
```

Then reinstall:

```bash
npm install -g @anthropic-ai/claude-code
```

Or use the official installer script:

```bash
curl -sSL https://raw.githubusercontent.com/anthropics/claude-cli/main/install.sh | sh
```

After reinstalling, immediately check where the binary landed before assuming it will be in PATH:

```bash
npm bin -g
Outputs: /usr/local/bin (or wherever npm puts global binaries)

ls $(npm bin -g)/claude
Should show the file
```

If `npm bin -g` outputs a path not in your current PATH, add it using the instructions in Solution 2.

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

A full permissions audit looks like this:

```bash
Check the binary
ls -la /usr/local/bin/claude
Expected: -rwxr-xr-x 1 root wheel ...

Check the parent directory
ls -la /usr/local/bin/
Expected: drwxr-xr-x ... root wheel ...

Check that you can read it
test -r /usr/local/bin/claude && echo "readable" || echo "not readable"

Check that you can execute it
test -x /usr/local/bin/claude && echo "executable" || echo "not executable"
```

If the file is owned by root and lacks execute bits, the npm install may have run into a permissions issue mid-install. Rerunning with `sudo npm install -g` (only when necessary) can resolve this, though it is better practice to configure npm to install globally without needing sudo by setting a user-owned prefix.

## Fixing npm Global Installs Without sudo

To stop needing `sudo` for global npm installs, configure npm to use a user-owned directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Now reinstall Claude Code without sudo:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

This approach avoids permission problems entirely and is the recommended setup for developer machines.

## Solution 7: macOS Gatekeeper and Security Blocks

On macOS, Gatekeeper can silently block unsigned binaries from running. If the binary exists, has correct permissions, and is in PATH, but still produces an error, check for a security block:

```bash
xattr -l /usr/local/bin/claude
```

If you see `com.apple.quarantine` in the output, macOS has quarantined the binary. Remove the quarantine flag:

```bash
xattr -d com.apple.quarantine /usr/local/bin/claude
```

Alternatively, open System Settings > Privacy and Security and look for a blocked application notice near the bottom of the page.

You can also run the binary directly once and approve it through the resulting dialog:

```bash
open /usr/local/bin/claude
```

## Debugging Summary: Decision Tree

Work through this decision tree when the error persists:

```
claude: command not found
 |
 v
Does `which claude` return a path?
 YES --> Go to permissions check (Solution 6)
 NO --> Does the binary file exist anywhere?
 |
 v
 `find ~ /usr -name claude -type f`
 |
 v
 File found?
 YES --> Add its directory to PATH (Solution 2)
 NO --> Reinstall (Solution 5)
```

## Using Claude Skills Once Working

Once you resolve the command not found error, you'll have access to Claude's full ecosystem. [Best Claude Code skills to install first](/best-claude-code-skills-to-install-first-2026/) covers which skills are worth adding immediately. Skills extend Claude's capabilities for specialized tasks. The `frontend-design` skill helps generate UI components and layouts. The `pdf` skill enables document manipulation and extraction. The `tdd` skill assists with test-driven development workflows.

Other valuable skills include `supermemory` for managing project context across sessions, `docx` for Word document automation, and `xlsx` for spreadsheet operations. Skills are `.md` files stored in `~/.claude/skills/`. place the skill file there to activate it.

## Prevention Tips

To avoid this issue in the future, keep these tips in mind:

1. Restart your terminal after installing CLI tools to ensure shell initialization completes properly
2. Use explicit paths when debugging: `/usr/local/bin/claude --version` confirms the binary works even if PATH is broken
3. Check shell framework configs if you use Oh My Zsh or similar frameworks. they may override PATH settings
4. Prefer user-local npm prefix to avoid sudo-related permission problems on future installs
5. Pin your node version with nvm or asdf so global installs always land in a consistent, expected directory
6. Keep a shell config backup so you can restore known-good PATH configuration if something breaks during an OS upgrade

## Wrapping Up

The "claude: command not found" error almost always comes down to PATH configuration. By locating the executable, adding its directory to PATH, and verifying permissions, you can resolve this in under five minutes.

The most common scenario on a fresh macOS machine: npm installed Claude Code into `~/.npm-global/bin`, that directory is not in PATH, and adding one `export PATH` line to `~/.zshrc` is the entire fix. The less common scenarios. broken symlinks, Gatekeeper blocks, nvm version conflicts. take a little more investigation but are equally solvable with the steps above.

If you continue experiencing issues after trying these solutions, check the official Claude Code documentation or open an issue on the GitHub repository with details about your operating system and installation method.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-command-not-found-after-install-troubleshooting)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Setup on Mac: Step-by-Step Guide](/claude-code-setup-on-mac-step-by-step/). Full installation walkthrough for macOS
- [Best Claude Code Skills to Install First in 2026](/best-claude-code-skills-to-install-first-2026/). First skills to add once Claude is running
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/). Full orientation for new users
- [Claude Skills Troubleshooting Hub](/troubleshooting-hub/). More installation and setup troubleshooting guides

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [PATH Not Updated After Install — Fix (2026)](/claude-code-path-not-updated-after-install-fix-2026/)
- [claude: command not found After Install — Fix (2026)](/claude-code-binary-not-found-after-install-fix-2026/)
