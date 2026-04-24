---
title: "Merge Conflict in Claude-Edited Files — Fix (2026)"
permalink: /claude-code-merge-conflict-edited-files-fix-2026/
description: "Fix merge conflicts in files edited by Claude Code. Use git mergetool or manual resolution to handle overlapping changes from AI and human edits."
last_tested: "2026-04-22"
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

## See Also

- [Claude Edit Tool File Modified Externally — Fix (2026)](/claude-code-edit-tool-conflict-merge-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `error: cannot rebase: you have unstaged changes`
- `CONFLICT (content): Merge conflict in file.ts`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### Why does Claude Code's rebase fail?

Claude Code cannot perform interactive rebases (`git rebase -i`) because it requires an interactive editor. Non-interactive rebases fail when there are unstaged changes or merge conflicts. Commit or stash changes before rebasing.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated Fix — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
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
