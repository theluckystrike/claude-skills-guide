---
layout: default
title: "Codespaces WebSocket Disconnect Fix (2026)"
permalink: /claude-code-codespaces-websocket-disconnect-fix-2026/
date: 2026-04-20
description: "Fix WebSocket disconnect in GitHub Codespaces with Claude Code. Adjust idle timeout settings and use port forwarding to maintain stable connections."
last_tested: "2026-04-22"
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

## See Also

- [WebSocket Upgrade Rejected Error — Fix (2026)](/claude-code-websocket-upgrade-rejected-fix-2026/)


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

- [Claude Code GitHub Codespaces](/claude-code-github-codespaces-cloud-development-workflow/)
- [Claude Code for GitHub Codespaces](/claude-code-for-codespaces-dev-environments-workflow-guide/)
- [Use Claude Code with GitHub Codespaces](/claude-code-github-codespaces-setup-2026/)
- [Build WebSocket Apps with Claude Code](/claude-code-skills-websocket-real-time-app-development/)

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
