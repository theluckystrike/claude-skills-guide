---
title: "EACCES Permission Denied Config Dir — Fix (2026)"
permalink: /claude-code-config-dir-permission-denied-fix-2026/
description: "Fix ownership of the .config/claude-code directory with sudo chown command. Resolves EACCES permission denied errors on config.json read/write."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
EACCES: permission denied, open '/home/user/.config/claude-code/config.json'
```

## The Fix

```bash
# Fix ownership of the config directory
sudo chown -R $(whoami) ~/.config/claude-code/

# Verify correct permissions
ls -la ~/.config/claude-code/
```

## Why This Works

The config directory was likely created by a process running as root (e.g., `sudo claude` or a system-level installation script). When Claude Code later runs as your normal user, it cannot read or write files owned by root. Restoring ownership to your user account gives Claude Code the read/write access it needs for config, cache, and session data.

## If That Doesn't Work

```bash
# If the directory doesn't exist yet, create it with correct permissions
mkdir -p ~/.config/claude-code && chmod 700 ~/.config/claude-code

# If running in a container where you can't chown, set a custom config path
export CLAUDE_CONFIG_DIR="/tmp/claude-code-config"
mkdir -p "$CLAUDE_CONFIG_DIR"

# On macOS, the path is different:
sudo chown -R $(whoami) ~/Library/Application\ Support/claude-code/
```

In Docker containers, ensure your Dockerfile sets the correct user before installing Claude Code. Running `npm install -g` as root then switching users causes this exact permission mismatch.

## Prevention

Add to your CLAUDE.md:
```
Never run Claude Code with sudo. If the config directory has wrong ownership, fix with: sudo chown -R $(whoami) ~/.config/claude-code/ — Do not chmod 777 as that is a security risk.
```
