---
layout: default
title: "Neovim Plugin Socket Error — Fix (2026)"
permalink: /claude-code-neovim-plugin-socket-error-fix-2026/
date: 2026-04-20
description: "Fix Neovim Claude Code plugin socket connection error. Set the correct socket path and restart the RPC server to restore editor communication."
last_tested: "2026-04-22"
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

## See Also

- [Claude Code + Neovim Terminal Integration 2026](/claude-code-neovim-terminal-integration-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`
- `EPIPE: broken pipe`
- `Error reading configuration file`
- `JSON parse error in config`

## Frequently Asked Questions

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.

### How do I diagnose intermittent connection failures?

Enable verbose logging with `claude --verbose` or set `CLAUDE_LOG_LEVEL=debug`. Check the timestamps of failed requests against your network monitoring tools to correlate with proxy restarts, DNS changes, or ISP issues.

### Does Claude Code automatically retry failed connections?

Yes. Claude Code retries transient failures (HTTP 429, 502, 503) with exponential backoff. Connection resets (ECONNRESET) and refused connections (ECONNREFUSED) are also retried up to 3 times. Persistent failures after retries indicate a systemic network issue.

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Editor Integration with Claude Code

Claude Code works alongside your editor rather than replacing it. Understanding how they interact prevents conflicts:

**File watching conflicts.** Both your editor and Claude Code may watch the same files for changes. When Claude Code edits a file, the editor detects the change and may trigger auto-save, auto-format, or auto-lint. These secondary changes can conflict with Claude Code's next operation. Disable auto-format-on-save for files Claude Code is actively editing, or configure your editor to ignore external changes during Claude Code sessions.

**Extension conflicts.** Some editor extensions (Copilot, Tabnine, IntelliCode) run language servers that consume significant CPU and memory. Running these alongside Claude Code can cause slowdowns. If Claude Code is slow, try disabling AI-powered extensions temporarily.

**Terminal integration.** Claude Code runs in a terminal. In VS Code, use the integrated terminal for best compatibility. In Neovim, use a terminal buffer or tmux split. In JetBrains IDEs, use the built-in terminal tab.

## Configuration for Smooth Co-existence

Add these settings to prevent editor interference with Claude Code operations:

**VS Code (`settings.json`):**
```json
{
  "files.autoSave": "onFocusChange",
  "editor.formatOnSave": false,
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/.git/**": true
  }
}
```

These settings prevent VS Code from reformatting files immediately after Claude Code writes them, avoiding a common source of git conflicts.
