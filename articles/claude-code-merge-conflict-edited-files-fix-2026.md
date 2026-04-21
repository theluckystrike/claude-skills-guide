---
title: "Merge Conflict in Claude-Edited Files Fix"
permalink: /claude-code-merge-conflict-edited-files-fix-2026/
description: "Fix merge conflicts in files edited by Claude Code. Use git mergetool or manual resolution to handle overlapping changes from AI and human edits."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
CONFLICT (content): Merge conflict in src/auth/login.ts
Auto-merging src/auth/login.ts
Claude Code edited lines 45-89 which overlap with changes on origin/main
Automatic merge failed; fix conflicts and then commit the result.
```

This appears when you pull or merge a branch and Claude Code's edits conflict with changes made by teammates on the same lines.

## The Fix

```bash
claude "Resolve the merge conflicts in src/auth/login.ts — keep both the new validation logic from main and the error handling you added"
```

1. Let Claude Code resolve its own merge conflicts. It can read the conflict markers and intelligently merge both sides.
2. After resolution, stage and commit: `git add src/auth/login.ts && git commit -m "Resolve merge conflict"`.
3. Run tests to verify the merged code works correctly.

## Why This Happens

Claude Code applies edits using exact string matching (the Edit tool). When these edits touch the same lines that a teammate modified, Git cannot automatically merge both changes. This is especially common when Claude Code refactors a function that someone else simultaneously edited, or when both Claude and a human fix the same bug independently.

## If That Doesn't Work

Use git's built-in merge tool for complex conflicts:

```bash
git mergetool --tool=vimdiff src/auth/login.ts
```

Accept one side entirely and manually apply the other:

```bash
git checkout --theirs src/auth/login.ts
claude "Now add back the error handling from our branch to src/auth/login.ts"
```

Abort the merge and try rebasing instead:

```bash
git merge --abort
git rebase origin/main
```

## Prevention

```markdown
# CLAUDE.md rule
Before making edits, always run 'git pull' to get the latest changes. Commit frequently in small batches to minimize conflict surface area. Never edit files that have uncommitted changes.
```
