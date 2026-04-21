---
title: "Git Worktree Lock Conflict Fix"
permalink: /claude-code-worktree-lock-conflict-fix-2026/
description: "Fix git worktree lock conflict in Claude Code. Remove stale lock files and prune dead worktrees to resolve 'worktree already locked' errors."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
fatal: 'feature-auth' is a missing but locked worktree
  use 'git worktree unlock' to unlock it, or 'git worktree remove' to remove it
  lock reason: Claude Code session (PID 48291) — process no longer running
```

This appears when a previous Claude Code session created a git worktree and the session crashed without cleaning it up, leaving a stale lock.

## The Fix

```bash
git worktree unlock feature-auth
git worktree prune
```

1. Unlock the stale worktree.
2. Prune all dead worktrees whose directories no longer exist.
3. Verify the worktree list is clean: `git worktree list`.

## Why This Happens

Claude Code's worktree feature creates isolated git worktrees in `.claude/worktrees/` for parallel development. Each worktree gets locked to prevent concurrent access. When Claude Code exits abnormally (crash, SIGKILL, OOM), it cannot release the lock. Subsequent sessions that try to use the same worktree name find it locked by a non-existent process.

## If That Doesn't Work

Force remove the problematic worktree:

```bash
git worktree remove --force feature-auth
```

If the worktree directory was already deleted:

```bash
git worktree prune --verbose
```

Manually clean up stale worktree references:

```bash
rm -rf .git/worktrees/feature-auth
rm -rf .claude/worktrees/feature-auth
git worktree prune
```

## Prevention

```markdown
# CLAUDE.md rule
After a Claude Code crash, always run 'git worktree prune' to clean up stale worktrees. Use 'git worktree list' to verify no orphaned worktrees exist before starting a new session.
```
