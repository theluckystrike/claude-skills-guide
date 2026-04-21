---
title: "Neovim Plugin Socket Error Fix"
permalink: /claude-code-neovim-plugin-socket-error-fix-2026/
description: "Fix Neovim Claude Code plugin socket connection error. Set the correct socket path and restart the RPC server to restore editor communication."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
E5108: Error executing lua: ...claude-code.nvim/lua/claude/init.lua:42:
  Connection refused: /tmp/claude-code-nvim.sock
  Failed to connect to Claude Code RPC socket
  Is Claude Code running in a terminal within this Neovim instance?
```

This appears in Neovim when the Claude Code plugin cannot connect to the Claude Code CLI's RPC socket for editor integration.

## The Fix

```bash
# Start Claude Code in a Neovim terminal buffer:
# :terminal claude

# Or set the socket path explicitly in init.lua:
# require('claude-code').setup({ socket_path = '/tmp/claude-code-nvim.sock' })
```

1. Ensure Claude Code is running in a Neovim `:terminal` buffer, not an external terminal.
2. Check the socket file exists: `ls /tmp/claude-code-nvim.sock`.
3. Restart Neovim and relaunch Claude Code in the terminal buffer.

## Why This Happens

The Neovim Claude Code plugin communicates with the CLI through a Unix domain socket. The socket is created when Claude Code detects it is running inside Neovim (by checking `$NVIM` environment variable). If Claude Code was started in an external terminal, the `$NVIM` variable is not set, so no socket is created. The plugin then fails to connect to a non-existent socket.

## If That Doesn't Work

Check if the `$NVIM` environment variable is set in your terminal buffer:

```vim
:terminal echo $NVIM
```

Remove stale socket files:

```bash
rm -f /tmp/claude-code-nvim.sock
```

Manually set the Neovim socket path:

```bash
export NVIM_LISTEN_ADDRESS=/tmp/nvim.sock
nvim --listen /tmp/nvim.sock
```

Update the plugin to the latest version:

```vim
:Lazy update claude-code.nvim
```

## Prevention

```markdown
# CLAUDE.md rule
When using Neovim integration, always start Claude Code from within Neovim's :terminal buffer. Never run Claude Code in an external terminal and expect Neovim plugin features to work. Add socket_path to your plugin config for reliability.
```
