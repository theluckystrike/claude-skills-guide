---
layout: default
title: "Git Credentials Expired Mid-Session — Fix (2026)"
permalink: /claude-code-git-credentials-expired-mid-session-fix-2026/
date: 2026-04-20
description: "Fix git credentials expired during Claude Code session. Refresh your GitHub token or SSH key passphrase to resume push and fetch operations."
last_tested: "2026-04-22"
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

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Git Operations in Claude Code: Safety Checklist

Claude Code can execute git commands, which makes safety guardrails important:

**Before any destructive operation:** Always check `git status` and `git stash list` to confirm there are no uncommitted changes that could be lost.

**Branch management:** Claude Code should create feature branches for non-trivial changes rather than committing directly to main. Use the pattern `git checkout -b claude/feature-name` to clearly identify AI-generated branches.

**Commit message conventions:** Configure your preferred commit format in CLAUDE.md. Claude Code follows the format you specify. Common formats: Conventional Commits (`feat: add user search`), Angular style, or simple descriptive messages.

## Common Git Mistakes Claude Code Makes

1. **Amending the wrong commit.** If a pre-commit hook fails, Claude Code sometimes uses `--amend` on the next attempt, which modifies the previous (successful) commit instead of creating a new one. Configure CLAUDE.md with: "Never use git commit --amend. Always create new commits."

2. **Force pushing to shared branches.** Claude Code may suggest `git push --force` to resolve push rejections. Add `Bash(git push --force*)` to your deny list in settings.json.

3. **Committing generated files.** Without guidance, Claude Code may commit `dist/`, `node_modules/`, or `.env` files. Ensure your `.gitignore` is complete and add a pre-commit hook that checks for these.
