---
title: "Claude Amending Wrong Commit Fix"
permalink: /claude-code-amending-wrong-commit-fix-2026/
description: "Fix Claude Code amending the wrong commit with git commit --amend. Use git reflog to recover the original commit and create a new one instead."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
warning: Claude Code ran 'git commit --amend' after a pre-commit hook failure
  The --amend modified the PREVIOUS commit (abc1234) instead of creating a new one
  Previous commit message: "Add user authentication"
  Now contains: unrelated linting fixes mixed with auth changes
```

This appears when Claude Code uses `--amend` thinking it is completing a failed commit, but instead modifies the previous unrelated commit.

## The Fix

```bash
git reflog
git reset --soft HEAD@{1}
git commit -m "Original commit message restored"
git add .
git commit -m "New changes in separate commit"
```

1. Use `git reflog` to find the commit SHA before the erroneous amend.
2. Reset to that commit while keeping all changes staged.
3. Re-create the original commit and then create a separate commit for the new changes.

## Why This Happens

When a pre-commit hook fails, the `git commit` command exits with a non-zero code and no commit is created. Claude Code may then retry with `--amend`, thinking it needs to complete the failed commit. But `--amend` modifies the last successful commit — which is an entirely different, previously completed commit. This silently corrupts that commit by adding unrelated changes to it.

## If That Doesn't Work

If the amend was pushed to remote:

```bash
git reflog
git reset --hard HEAD@{1}
git push --force-with-lease
```

If multiple amends were chained:

```bash
git reflog
# Find the last clean state
git reset --soft <clean-sha>
git stash
git commit -m "Restored original commit"
git stash pop
git commit -m "New changes"
```

Create a revert commit if force push is not possible:

```bash
git revert HEAD
git commit -m "Revert erroneous amend"
```

## Prevention

```markdown
# CLAUDE.md rule
NEVER use 'git commit --amend'. Always create new commits. After a pre-commit hook failure, fix the issue and run 'git commit' (not --amend). The failed commit never existed — there is nothing to amend.
```
