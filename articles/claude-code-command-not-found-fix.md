---
title: "Fix 'Command Not Found: Claude' — zsh/bash/npm PATH Fix (2026)"
description: "Getting 'zsh: command not found: claude' or 'claude: command not found' after install? PATH setup, npm global bin fix, shell profile (zshrc/bashrc), and native installer fix for macOS, Linux, WSL. June 2026."
permalink: /claude-code-command-not-found-fix/
layout: default
date: 2026-04-22
last_modified_at: 2026-06-28
last_tested: "2026-06-28"
author: "Claude Code Guides"
categories: [troubleshooting]
tags: [claude-code, troubleshooting]
reviewed: true
---

# Fix 'Command Not Found: Claude' — zsh/bash/npm PATH Fix (2026)

## TL;DR — Quick Fix

Run this single command. It fixes the problem 90% of the time:

```
npm install -g @anthropic-ai/claude-code && source ~/.zshrc && claude --version
```

If that does not work, your shell cannot find the npm global bin directory. Keep reading for the full fix.

## The Error

```
zsh: command not found: claude
```

Or one of these variations:

```
bash: claude: command not found
command not found: claude
claude: not found
-bash: claude: No such file or directory
```

You installed Claude Code with `npm install -g @anthropic-ai/claude-code`, the install completed without errors, but when you type `claude` your shell says it cannot find it.

## Why This Happens

When npm installs a global package, it places the executable in npm's global bin directory. Your shell can only run commands that exist in directories listed in your `PATH` environment variable. If npm's global bin is not in `PATH`, your shell cannot find `claude`.

The three most common causes:

1. **npm global bin is not in PATH.** This is the default state on many Linux distributions and some macOS setups. npm installs the binary, but your shell profile never adds its location to PATH.
2. **nvm node version mismatch.** You installed Claude Code under Node 20, then switched to Node 22 with `nvm use 22`. Global packages are per-node-version in nvm. The binary only exists under the Node 20 prefix.
3. **Wrong shell profile.** You added the PATH export to `~/.bashrc` but your terminal runs zsh (reads `~/.zshrc`). Or you edited `~/.zprofile` but your terminal is a login shell that reads `~/.zshrc`.

## Fix 1 — Reinstall Claude Code Globally

The fastest fix. This reinstalls the package and re-links the binary:

```
# Uninstall any existing broken installation
npm uninstall -g @anthropic-ai/claude-code

# Reinstall fresh
npm install -g @anthropic-ai/claude-code

# Verify the binary exists
which claude
```

If `which claude` prints a path like `/usr/local/bin/claude` or `/Users/you/.nvm/versions/node/v22.x.x/bin/claude`, the install worked. If it still says “not found”, continue to Fix 2.

## Fix 2 — Add npm Global Bin to PATH

First, find where npm installs global binaries:

```
npm bin -g
```

This prints the directory. Common outputs:

```
# macOS (system Node)
/usr/local/bin

# macOS/Linux (nvm)
/Users/you/.nvm/versions/node/v22.15.0/bin

# Linux (apt-installed Node)
/usr/lib/node_modules/.bin

# Linux (snap-installed Node)
/snap/node/current/bin
```

Now add that directory to your PATH. Choose your shell:

**zsh (macOS default since Catalina):**

```
# Add npm global bin to PATH in your zsh profile
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.zshrc

# Reload the profile
source ~/.zshrc

# Verify
claude --version
```

**bash:**

```
# Add npm global bin to PATH in your bash profile
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.bashrc

# Reload the profile
source ~/.bashrc

# Verify
claude --version
```

**fish:**

```
# Add npm global bin to PATH in fish config
set -Ua fish_user_paths (npm bin -g)

# Verify
claude --version
```

If you are not sure which shell you use, run:

```
echo $SHELL
```

## Fix 3 — nvm Users: Node Version Mismatch

If you use nvm, global packages are installed per Node version. Switching Node versions makes previously installed globals disappear.

```
# Check which Node version is active
node --version

# List installed Node versions
nvm ls

# Check if claude exists in the current version's bin
ls $(nvm which current | xargs dirname)/claude 2>/dev/null && echo "Found" || echo "Not found"
```

If “Not found”, you have two options:

**Option A — Reinstall under the current Node version:**

```
npm install -g @anthropic-ai/claude-code
```

**Option B — Switch back to the Node version that has it:**

```
# List all Node versions and check each for claude
for dir in ~/.nvm/versions/node/*/bin; do
  [ -f "$dir/claude" ] && echo "Found claude in: $dir"
done

# Switch to that version
nvm use 22  # replace with the version number from above
```

**Option C — Set a default Node version so claude persists across terminal sessions:**

```
# Set your current version as the default
nvm alias default node

# Install claude on the default
npm install -g @anthropic-ai/claude-code
```

## Fix 4 — Homebrew Users (macOS)

If you installed Node.js via Homebrew, npm's global bin is under the Homebrew prefix, which may not be in your PATH (especially on Apple Silicon Macs):

```
# Check Homebrew prefix
brew --prefix

# Apple Silicon Macs: /opt/homebrew
# Intel Macs: /usr/local
```

**Apple Silicon (M1/M2/M3/M4) fix:**

```
# Add Homebrew's bin to PATH (if not already there)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Reinstall Claude Code
npm install -g @anthropic-ai/claude-code

# Verify
which claude
```

**Intel Mac fix:**

```
# Homebrew's /usr/local/bin is usually already in PATH
# Just reinstall:
npm install -g @anthropic-ai/claude-code

# If still not found, force the link:
npm link @anthropic-ai/claude-code
```

You can also install Claude Code directly via Homebrew if npm is giving you trouble:

```
# Alternative: install via npx without global install
npx @anthropic-ai/claude-code
```

## Fix 5 — Verify Installation

Run these commands to confirm everything is working:

```
# Check if claude is in PATH
which claude

# Check the version
claude --version

# Check that the binary is executable
ls -la $(which claude)

# Check your PATH includes npm's global bin
echo $PATH | tr ':' '\n' | grep -i node
```

Expected output:

```
$ which claude
/Users/you/.nvm/versions/node/v22.15.0/bin/claude

$ claude --version
Claude Code v1.x.x

$ ls -la $(which claude)
lrwxr-xr-x  1 you  staff  ... claude -> ../lib/node_modules/@anthropic-ai/claude-code/cli.js
```

If `which claude` returns a path but `claude --version` still fails, the symlink may be broken. Reinstall with `npm install -g @anthropic-ai/claude-code`.

## Error Variations by Shell and OS

Shell / OS
Error Message
Profile File

zsh (macOS)
`zsh: command not found: claude`
`~/.zshrc`

bash (Linux)
`bash: claude: command not found`
`~/.bashrc`

bash (macOS)
`-bash: claude: command not found`
`~/.bash_profile`

fish
`fish: Unknown command: claude`
`~/.config/fish/config.fish`

Windows (WSL)
`claude: command not found`
`~/.bashrc`

Windows (PowerShell)
`claude: The term 'claude' is not recognized`
`$PROFILE`

Windows (CMD)
`'claude' is not recognized as an internal or external command`
System Environment Variables

The fix is the same for all: make sure npm's global bin directory is in your shell's `PATH`.

## FAQ

### Why does “zsh: command not found: claude” appear after a successful npm install?

npm installed the binary, but your zsh shell does not know where it is. npm's global bin directory is not in your `PATH` environment variable. Run `npm bin -g` to find the directory, then add it to `~/.zshrc` with `export PATH="$(npm bin -g):$PATH"`. Reload with `source ~/.zshrc`.

### How do I fix “claude command not found” on macOS?

macOS uses zsh by default since Catalina. Run `npm install -g @anthropic-ai/claude-code` to install, then add the npm bin path to `~/.zshrc`. On Apple Silicon Macs (M1-M4), also make sure Homebrew's shell environment is loaded: `eval "$(/opt/homebrew/bin/brew shellenv)"` in your `~/.zshrc`.

### Does “command not found” mean Claude Code failed to install?

Not necessarily. The npm install may have succeeded (check with `npm list -g @anthropic-ai/claude-code`). The error means your shell cannot locate the `claude` binary because the install directory is not in your PATH. It is a path configuration issue, not an installation failure.

### Why does claude work in one terminal but not another?

Different terminals may load different shell profiles. If you added the PATH export to `~/.zshrc` but open a bash terminal, it reads `~/.bashrc` instead. Also, if you use nvm and different terminals default to different Node versions, the global packages differ between them. Run `echo $SHELL` and `node --version` in each terminal to compare.

### I switched Node versions with nvm and now claude is gone. How do I get it back?

nvm installs global packages per Node version. When you switch from Node 20 to Node 22, the packages installed under Node 20 are not available. Reinstall with `npm install -g @anthropic-ai/claude-code` on your current Node version. To prevent this in the future, set a default: `nvm alias default node` and always install globals on the default version.
