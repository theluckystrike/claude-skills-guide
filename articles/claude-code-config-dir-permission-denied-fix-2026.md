---
title: "EACCES Permission Denied Config Dir"
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

## See Also

- [npm Global Install Permission Denied — Fix (2026)](/claude-code-npm-global-install-permission-denied-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `EACCES: permission denied, open '/path/to/file'`
- `Error: EPERM: operation not permitted`
- `sudo: a terminal is required to read the password`
- `EACCES: permission denied, mkdir '/usr/local/lib/node_modules'`
- `npm ERR! Error: EACCES: permission denied, rename`

## Frequently Asked Questions

### Should I run Claude Code with sudo?

No. Running Claude Code with sudo is strongly discouraged because it changes the ownership of cached files and configuration to root, which causes permission failures in subsequent non-sudo sessions. Instead, fix the underlying permission issue on the specific file or directory.

### How do I check file ownership?

Run `ls -la /path/to/file` to see the owner and group. If the file is owned by root but you run Claude Code as a regular user, run `sudo chown $(whoami) /path/to/file` to reclaim ownership.

### Does this affect CI/CD environments?

Yes. Docker containers and CI runners often execute as root, which creates files that a non-root user cannot modify later. Set `USER node` in your Dockerfile or use `--user $(id -u):$(id -g)` with `docker run` to match the host user.

### Why does npm need special permissions?

When Node.js is installed via system package managers, the global `node_modules` directory is owned by root. Running `npm install -g` as a regular user fails because the user lacks write access. Use `nvm` or configure npm to use a user-owned prefix directory to avoid this.
