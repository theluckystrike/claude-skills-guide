---
title: "Codespaces WebSocket Disconnect Fix"
permalink: /claude-code-codespaces-websocket-disconnect-fix-2026/
description: "Fix WebSocket disconnect in GitHub Codespaces with Claude Code. Adjust idle timeout settings and use port forwarding to maintain stable connections."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
WebSocket connection to 'wss://xxx.github.dev/claude-ws' failed:
  WebSocket is closed before the connection is established
  Error: Codespace idle timeout (30 minutes) disconnected the session
  Claude Code state lost — reconnection failed
```

This appears when GitHub Codespaces disconnects due to idle timeout or WebSocket instability, killing the Claude Code session.

## The Fix

```bash
# In GitHub Settings > Codespaces > Default idle timeout:
# Set to 240 minutes (maximum)

# Or via CLI:
gh codespace edit --idle-timeout 240m
```

1. Increase the Codespace idle timeout to the maximum 4 hours.
2. Reconnect to the Codespace and restart Claude Code.
3. Use tmux inside the Codespace to persist sessions across reconnections.

## Why This Happens

GitHub Codespaces runs in a cloud VM that shuts down after a configurable idle period (default 30 minutes). When Claude Code waits for a long API response or you step away, the Codespace considers the session idle and suspends the VM. The WebSocket connection drops, Claude Code loses state, and all running processes terminate. Even active API calls are not considered "activity" by the Codespace timeout detector.

## If That Doesn't Work

Run Claude Code inside tmux to survive reconnections:

```bash
# In Codespace terminal:
tmux new -s claude
claude
# After reconnection:
tmux attach -t claude
```

Keep the Codespace alive with periodic activity:

```bash
# In a separate terminal tab:
while true; do sleep 300; echo "keepalive"; done
```

Use the GitHub CLI to prevent auto-stop:

```bash
gh codespace edit --idle-timeout 0  # Disable auto-stop (paid feature)
```

## Prevention

```markdown
# CLAUDE.md rule
In Codespaces, always run Claude Code inside tmux. Set idle timeout to maximum (240 minutes) in GitHub settings. Keep a second terminal tab open with periodic activity to prevent auto-stop.
```
