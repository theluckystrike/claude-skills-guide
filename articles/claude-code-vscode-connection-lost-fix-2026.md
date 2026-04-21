---
title: "Claude Code VS Code Connection Lost — Fix (2026)"
permalink: /claude-code-vscode-connection-lost-fix-2026/
description: "Restart the VS Code extension host to restore the dropped connection. Fixes the persistent reconnecting loop when Claude Code loses server contact."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Connection to Claude Code lost. Reconnecting...
```

## The Fix

```bash
# In VS Code, open Command Palette (Cmd+Shift+P / Ctrl+Shift+P) and run:
Developer: Restart Extension Host
```

## Why This Works

The VS Code extension host process crashes or enters a deadlock state when memory pressure spikes during long sessions. Restarting the extension host re-establishes the WebSocket connection between the extension and the Claude Code language server without reloading the entire window.

## If That Doesn't Work

```bash
# Kill orphaned Claude Code processes and reload the window
pkill -f "claude-code" && sleep 2
# Then in VS Code Command Palette:
# Developer: Reload Window
```

Check if your VS Code version is outdated. Claude Code requires VS Code 1.85 or later. Run `code --version` and update if below that threshold. On macOS, also verify that the system did not put the process to sleep via App Nap — disable it for VS Code in Activity Monitor if reconnection failures correlate with periods of inactivity.

## Prevention

Add to your CLAUDE.md:
```
When using Claude Code in VS Code, save work frequently. If sessions exceed 2 hours, manually restart the extension host before the connection degrades. Keep VS Code updated to latest stable release.
```
