---
title: "VS Code Extension Connection Timeout"
permalink: /claude-code-vscode-extension-connection-timeout-fix-2026/
description: "Fix VS Code extension connection timeout for Claude Code. Restart the extension host and check WebSocket port to restore the editor integration."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
[Claude Code Extension] Connection timeout after 10000ms
  Failed to establish WebSocket connection to ws://127.0.0.1:19836
  Extension status: Disconnected — Claude Code CLI not detected
```

This appears in VS Code's output panel when the Claude Code extension cannot connect to the Claude Code CLI process running in the integrated terminal.

## The Fix

```bash
# In VS Code, press Ctrl+Shift+P / Cmd+Shift+P:
# > Developer: Restart Extension Host
```

1. Restart the VS Code extension host from the command palette.
2. If that does not work, close and reopen the integrated terminal where Claude Code is running.
3. Verify Claude Code is running: check for the process with `ps aux | grep claude`.

## Why This Happens

The VS Code Claude Code extension communicates with the CLI via a local WebSocket connection. The connection can time out if Claude Code was started before the extension loaded, if the WebSocket port is blocked by a firewall, or if VS Code's extension host crashed and restarted without re-establishing the connection. Network-level firewalls or VPN software can also block localhost WebSocket connections.

## If That Doesn't Work

Kill and restart Claude Code in the terminal:

```bash
# Close existing session with Ctrl+C, then:
claude
```

Check if the WebSocket port is in use:

```bash
lsof -i :19836
```

Reinstall the VS Code extension:

```bash
code --uninstall-extension anthropic.claude-code
code --install-extension anthropic.claude-code
```

## Prevention

```markdown
# CLAUDE.md rule
If the VS Code extension shows "Disconnected", restart the extension host first. If that fails, restart Claude Code in the terminal. Keep the Claude Code extension updated to the latest version.
```

## See Also

- [Connection Reset by Peer Error — Fix (2026)](/claude-code-connection-reset-by-peer-fix-2026/)
- [Garbage Collection Pause Causing Timeout Fix](/claude-code-gc-pause-causing-timeout-fix-2026/)
- [DNS Resolution Timeout Error — Fix (2026)](/claude-code-dns-resolution-timeout-fix-2026/)
- [Claude Code vs VS Code IntelliSense: Completion Compared](/claude-code-vs-vscode-intellisense-comparison/)
- [Claude Code VS Code Extension Fails to Activate — Fix (2026)](/claude-code-vscode-extension-fails-to-activate-fix/)
