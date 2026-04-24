---
title: "Claude Code SSH Key Passphrase Blocking — Fix (2026)"
description: "Fix Claude Code SSH key passphrase prompt blocking automation. Configure ssh-agent or deploy key without passphrase. Step-by-step solution."
permalink: /claude-code-ssh-key-passphrase-prompt-blocking-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
