---
layout: default
title: "Claude Code SSH Key Passphrase Blocking (2026)"
description: "Fix Claude Code SSH key passphrase prompt blocking automation. Configure ssh-agent or deploy key without passphrase. Step-by-step solution."
permalink: /claude-code-ssh-key-passphrase-prompt-blocking-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Enter passphrase for /Users/you/.ssh/id_ed25519: _
# Terminal hangs here — Claude Code cannot type the passphrase

# Or in CI:
fatal: Could not read from remote repository.
Permission denied (publickey).

# Or:
Error: ssh_askpass: exec(/usr/bin/ssh-askpass): No such file or directory
Host key verification failed.
```

## The Fix

1. **Add your SSH key to the agent so it doesn't prompt again**

```bash
# Start ssh-agent if not running
eval "$(ssh-agent -s)"

# Add key (enter passphrase once, then it's cached)
ssh-add ~/.ssh/id_ed25519

# Verify it's loaded
ssh-add -l
```

2. **On macOS, persist across reboots with Keychain**

```bash
# Add to Keychain (macOS only)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Configure SSH to use Keychain automatically
cat >> ~/.ssh/config << 'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
```

3. **Verify the fix:**

```bash
ssh -T git@github.com
# Expected: Hi username! You've been authenticated, but GitHub does not provide shell access.
```

## Why This Happens

When Claude Code runs `git push`, `git pull`, or `git clone` over SSH, the Git process spawns an SSH connection. If your SSH key has a passphrase and the key isn't loaded in `ssh-agent`, SSH opens an interactive prompt for the passphrase. Claude Code's terminal session cannot respond to this prompt, causing the operation to hang indefinitely or fail with a permission error. In CI environments, there is no TTY at all, so SSH fails immediately.

## If That Doesn't Work

- **Alternative 1:** Use HTTPS with a personal access token instead: `git remote set-url origin https://TOKEN@github.com/user/repo.git`
- **Alternative 2:** Generate a passphrase-free deploy key for CI: `ssh-keygen -t ed25519 -f deploy_key -N ""`
- **Check:** Run `SSH_AUTH_SOCK= ssh -T git@github.com` to test without the agent — if this fails but `ssh -T git@github.com` works, the agent is the fix

## Prevention

Add to your `CLAUDE.md`:
```markdown
Ensure ssh-agent is running and keys are loaded before starting Claude Code sessions. On macOS, use Keychain integration. In CI, use deploy keys or HTTPS tokens — never passphrase-protected keys without an agent.
```

**Related articles:** [Claude Code Command Not Found Fix](/claude-code-command-not-found-after-install-fix/), [Claude Code Not Responding Fix](/claude-code-not-responding-terminal-hangs-fix/), [GitHub Actions Setup](/claude-code-github-actions-setup-guide/)


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
- [SSH Remote Session Drops Fix](/claude-code-ssh-remote-session-drops-fix-2026/)
- [macOS Gatekeeper Blocking Binary Fix](/claude-code-macos-gatekeeper-blocking-binary-fix-2026/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Workspace Trust Blocking Execution Fix](/claude-code-workspace-trust-blocking-execution-fix-2026/)
- [Referrer Blocking Chrome Extension](/chrome-referrer-blocking-extension/)
- [Chrome Enterprise Split Tunnel Browsing](/chrome-enterprise-split-tunnel-browsing/)
- [Connect Claude Code to Remote MCP](/claude-code-mcp-remote-http-server-setup/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
