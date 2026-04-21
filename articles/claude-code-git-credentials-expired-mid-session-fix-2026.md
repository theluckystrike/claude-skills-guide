---
title: "Git Credentials Expired Mid-Session Fix"
permalink: /claude-code-git-credentials-expired-mid-session-fix-2026/
description: "Fix git credentials expired during Claude Code session. Refresh your GitHub token or SSH key passphrase to resume push and fetch operations."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
remote: Invalid username or password.
fatal: Authentication failed for 'https://github.com/user/repo.git'
  Git credential token expired during Claude Code session.
  Push/fetch operations will fail until credentials are refreshed.
```

This appears when your GitHub personal access token (PAT) or OAuth token expires while Claude Code is running, causing all remote git operations to fail.

## The Fix

```bash
gh auth refresh
```

1. Refresh your GitHub CLI authentication, which also updates the git credential helper.
2. Verify the new token works: `gh auth status`.
3. Resume your Claude Code session — push and fetch will work again.

## Why This Happens

GitHub tokens (PATs, OAuth tokens, fine-grained tokens) have expiration dates. If a token expires during a long Claude Code session, all `git push`, `git fetch`, and `git pull` commands fail. Claude Code does not detect the authentication failure as a token expiry — it sees it as a generic push rejection and may retry repeatedly. This is especially common with fine-grained PATs that have short (7-day) expiration windows.

## If That Doesn't Work

Re-authenticate with the GitHub CLI:

```bash
gh auth login
```

Update a stored personal access token:

```bash
git credential reject <<EOF
protocol=https
host=github.com
EOF
gh auth login --with-token < ~/.github-token
```

Switch to SSH authentication to avoid token expiry:

```bash
git remote set-url origin git@github.com:user/repo.git
ssh-add ~/.ssh/id_ed25519
```

## Prevention

```markdown
# CLAUDE.md rule
Use SSH keys instead of HTTPS tokens for git authentication — SSH keys do not expire. If using PATs, set expiration to 90 days minimum. Run 'gh auth status' at the start of each session to verify credentials.
```
