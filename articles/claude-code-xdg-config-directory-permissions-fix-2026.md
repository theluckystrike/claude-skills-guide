---
title: "XDG Config Directory Permissions Fix"
permalink: /claude-code-xdg-config-directory-permissions-fix-2026/
description: "Fix XDG config directory permission denied error in Claude Code. Reset ownership and permissions on ~/.config/claude-code to restore configuration access."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: EACCES: permission denied, mkdir '/home/user/.config/claude-code'
  Cannot create configuration directory
  XDG_CONFIG_HOME=/home/user/.config is owned by root (installed via sudo)
  Claude Code needs write access to store settings and conversation history
```

This appears when Claude Code cannot write to its configuration directory because the parent directory has incorrect ownership or permissions.

## The Fix

```bash
sudo chown -R $(whoami) ~/.config/claude-code
chmod -R 755 ~/.config/claude-code
```

1. Fix the ownership of the Claude Code config directory.
2. Set appropriate permissions (read/write for owner, read for others).
3. Restart Claude Code — it should now write configuration normally.

## Why This Happens

The `~/.config` directory (XDG_CONFIG_HOME) sometimes gets created with root ownership when software is installed with `sudo`. If `sudo npm install -g @anthropic-ai/claude-code` created the config directory, it is owned by root. Subsequent runs as your normal user cannot write to it. This is especially common on Linux systems where `npm install -g` requires `sudo`.

## If That Doesn't Work

Fix the entire `.config` directory if the problem is broader:

```bash
sudo chown -R $(whoami) ~/.config
```

Use a custom config directory:

```bash
export XDG_CONFIG_HOME="$HOME/.claude-config"
mkdir -p "$XDG_CONFIG_HOME/claude-code"
claude
```

If npm's global directory has permission issues, fix that too:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH="$HOME/.npm-global/bin:$PATH"
npm install -g @anthropic-ai/claude-code
```

## Prevention

```markdown
# CLAUDE.md rule
Never install Claude Code with sudo. Use npm prefix or nvm to avoid root-owned directories. If you see EACCES errors, fix ownership with chown before proceeding. Check directory permissions after any sudo operation.
```
