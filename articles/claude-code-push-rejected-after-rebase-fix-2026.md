---
title: "Push Rejected After Claude Rebase Fix"
permalink: /claude-code-push-rejected-after-rebase-fix-2026/
description: "Fix push rejected after Claude Code rebase. Use git push --force-with-lease to safely update remote after rebase without overwriting teammate commits."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
error: failed to push some refs to 'origin/feature-branch'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Claude Code performed a rebase which rewrote history.
```

This appears after Claude Code runs a `git rebase` and you try to push the rebased branch to the remote. The remote rejects the push because the rebase rewrote commit history.

## The Fix

```bash
git push --force-with-lease
```

1. Use `--force-with-lease` instead of `--force`. This safely overwrites the remote only if no one else has pushed new commits since your last fetch.
2. If `--force-with-lease` fails, someone else pushed to the branch. Fetch and reconcile first.
3. Never force push to `main` or `master`.

## Why This Happens

Git rebase rewrites commit SHAs by replaying your commits on top of a new base. The rewritten commits have different hashes than the ones on the remote, so Git sees them as divergent history and rejects a normal push. Claude Code sometimes performs rebase operations when asked to "update the branch" or "sync with main," which triggers this situation.

## If That Doesn't Work

If `--force-with-lease` fails because the remote has new commits:

```bash
git fetch origin
git rebase origin/feature-branch
git push --force-with-lease
```

If the branch is shared with teammates, use merge instead of rebase:

```bash
git rebase --abort
git merge origin/main
git push
```

Check what Claude Code actually did:

```bash
git reflog | head -20
```

## Prevention

```markdown
# CLAUDE.md rule
Never run git rebase on shared branches. Use git merge to incorporate upstream changes. Only rebase on personal feature branches that no one else is working on. Never use --force, always use --force-with-lease.
```
