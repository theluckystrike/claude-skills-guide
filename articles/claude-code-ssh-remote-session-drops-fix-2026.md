---
layout: default
title: "SSH Remote Session Drops Fix (2026)"
permalink: /claude-code-ssh-remote-session-drops-fix-2026/
date: 2026-04-20
description: "Fix SSH session dropping while running Claude Code remotely. Configure SSH keepalive and use tmux to persist sessions across network interruptions."
last_tested: "2026-04-22"
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

## See Also

- [Claude Code SSH Key Passphrase Blocking — Fix (2026)](/claude-code-ssh-key-passphrase-prompt-blocking-fix/)
- [tmux Session Not Detected Error Fix](/claude-code-tmux-session-not-detected-fix-2026/)


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Connect Claude Code to Remote MCP](/claude-code-mcp-remote-http-server-setup/)
- [Claude Code Turborepo Remote Caching](/claude-code-turborepo-remote-caching-setup-workflow-guide/)
- [Claude Code for Prometheus Remote Write](/claude-code-for-prometheus-remote-write-workflow/)
- [Break Reminder Remote Work Chrome](/chrome-extension-break-reminder-remote-work/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
