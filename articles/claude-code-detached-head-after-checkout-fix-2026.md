---
title: "Detached HEAD After Claude Checkout Fix"
permalink: /claude-code-detached-head-after-checkout-fix-2026/
description: "Fix detached HEAD state after Claude Code checkout. Create a branch from the detached commit or switch back to your working branch to save your work."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.
HEAD is now at a3f7b2c... Claude Code checked out specific commit
```

This appears when Claude Code runs `git checkout <commit-hash>` instead of checking out a branch, leaving you in detached HEAD state where new commits are not attached to any branch.

## The Fix

```bash
git checkout -b recovery-branch
```

1. Create a new branch from the current detached HEAD to preserve any work.
2. If you have no uncommitted changes, simply switch back to your working branch: `git checkout main`.
3. Cherry-pick any commits made in detached state if needed.

## Why This Happens

When Claude Code is asked to "look at a previous version" or "check the code before the bug," it may run `git checkout <SHA>` on a specific commit instead of checking out a branch. This puts Git into detached HEAD mode. Any commits made in this state are orphaned — they exist but are not reachable from any branch and will eventually be garbage collected.

## If That Doesn't Work

If you made commits in detached HEAD and already switched away:

```bash
git reflog | head -20
git checkout <lost-commit-sha>
git checkout -b recovered-work
```

If Claude Code's checkout broke your working tree:

```bash
git checkout main
git stash pop  # if you had stashed changes
```

Reset to the branch tip if the checkout was accidental:

```bash
git checkout main
git reset --hard origin/main
```

## Prevention

```markdown
# CLAUDE.md rule
Never use 'git checkout <commit-hash>'. To inspect old code, use 'git show <hash>:path/to/file' or 'git diff <hash> HEAD -- path/to/file'. Always stay on a named branch.
```
