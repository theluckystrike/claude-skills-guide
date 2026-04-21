---
title: "SSH Remote Session Drops Fix"
permalink: /claude-code-ssh-remote-session-drops-fix-2026/
description: "Fix SSH session dropping while running Claude Code remotely. Configure SSH keepalive and use tmux to persist sessions across network interruptions."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
client_loop: send disconnect: Broken pipe
Connection to remote-server closed.
  Claude Code session lost — SSH connection dropped after 60s inactivity
  Unsaved work in remote Claude Code session may be lost
```

This appears when the SSH connection drops during a Claude Code session on a remote machine, typically due to network timeouts or NAT table expiry.

## The Fix

```bash
# Add to ~/.ssh/config:
Host *
  ServerAliveInterval 30
  ServerAliveCountMax 5
  TCPKeepAlive yes
```

1. Configure SSH keepalive to send heartbeat packets every 30 seconds.
2. Reconnect to the remote server and check if Claude Code is still running.
3. Use tmux or screen for all remote Claude Code sessions going forward.

## Why This Happens

SSH connections are stateful TCP connections. When Claude Code waits for a long API response or you pause typing, the connection goes idle. Firewalls, NAT gateways, and load balancers drop idle TCP connections after their timeout (often 60 seconds). Without keepalive packets, the SSH server does not know the client disconnected, and the client does not know the server is unreachable until the next write attempt.

## If That Doesn't Work

Always run Claude Code inside tmux on the remote server:

```bash
ssh remote-server
tmux new -s claude-session
claude
# If disconnected, reconnect with:
ssh remote-server
tmux attach -t claude-session
```

Use mosh instead of SSH for unreliable connections:

```bash
brew install mosh  # on client
# On remote: apt install mosh
mosh remote-server
claude
```

Configure the server-side keepalive as well:

```bash
# On remote server, add to /etc/ssh/sshd_config:
# ClientAliveInterval 30
# ClientAliveCountMax 5
sudo systemctl restart sshd
```

## Prevention

```markdown
# CLAUDE.md rule
Always run Claude Code inside tmux on remote servers. Configure SSH keepalive in ~/.ssh/config. Use 'tmux new -s claude' before starting Claude Code remotely. Never run long sessions over bare SSH.
```
