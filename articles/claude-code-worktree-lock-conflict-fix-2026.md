---
title: "Git Worktree Lock Conflict Fix — Fix (2026)"
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

## See Also

- [Certificate Pinning Conflict Error — Fix (2026)](/claude-code-certificate-pinning-conflict-fix-2026/)
- [Claude Code Rust-Analyzer Conflict — Fix (2026)](/claude-code-rust-analyzer-conflict-fix-2026/)
- [Stash Pop Conflict After Claude Edits Fix](/claude-code-stash-pop-conflict-after-edits-fix-2026/)
- [Homebrew vs System Python Conflict Fix](/claude-code-homebrew-vs-system-python-conflict-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`
- `Killed (signal 9) — OOM killer`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What triggers OOM in Claude Code?

Reading very large files (over 10MB), processing repositories with more than 100,000 files, or accumulating a long conversation history without starting a fresh session. Each of these increases memory consumption beyond the default Node.js heap limit.
