---
layout: default
title: "Claude Code for Jujutsu VCS"
description: "Use Jujutsu version control with Claude Code for better diffs. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-jujutsu-vcs-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, jujutsu, workflow]
---

## The Setup

You are using Jujutsu (jj), the Git-compatible version control system that simplifies branching, rebasing, and conflict resolution. Jujutsu automatically creates commits for your working copy, uses change IDs instead of commit hashes, and makes rebasing trivial. Claude Code can work with Jujutsu, but it defaults to Git commands that behave differently or do not exist in jj.

## What Claude Code Gets Wrong By Default

1. **Uses `git add` and `git commit`.** Claude runs the Git staging workflow. Jujutsu has no staging area — every change is automatically part of the working copy commit. You describe changes with `jj describe` and create new changes with `jj new`.

2. **References commits by SHA hash.** Claude uses `git checkout abc123`. Jujutsu uses change IDs (short unique prefixes like `xyz`) and revset expressions. You write `jj checkout xyz` using the change ID, not the commit hash.

3. **Runs `git rebase -i` for history editing.** Claude suggests interactive rebase. Jujutsu makes rebasing automatic — when you edit an earlier change, all descendants are automatically rebased. Use `jj edit xyz` to go back to any change.

4. **Creates branches for every feature.** Claude runs `git checkout -b feature-x`. Jujutsu uses anonymous changes by default. Branches (bookmarks) are optional and only needed when pushing to Git remotes.

## The CLAUDE.md Configuration

```
# Jujutsu VCS Project

## Version Control
- VCS: Jujutsu (jj) — Git-compatible, no staging area
- Backend: Git (jj colocated repo, works with existing .git)
- Remote: GitHub via jj git push

## Jujutsu Rules
- No staging area — all changes are auto-tracked
- New change: jj new (starts a new change on top of current)
- Describe changes: jj describe -m "message"
- View log: jj log (shows change graph with IDs)
- Edit past change: jj edit <change-id> (auto-rebases descendants)
- Squash changes: jj squash (fold into parent)
- Split changes: jj split (interactive file/hunk splitting)
- Conflicts are first-class — work continues even with conflicts

## Conventions
- Use change IDs (short prefix), not commit SHAs
- Bookmarks (branches) only for push targets: jj bookmark create main
- Push to remote: jj git push --bookmark main
- Fetch from remote: jj git fetch
- Resolve conflicts inline, then jj resolve to mark resolved
- Never use git commands directly — use jj equivalents
```

## Workflow Example

You want to split a large Claude Code change into smaller logical commits. Prompt Claude Code:

"I have a single working copy change that modifies both the database schema and the API routes. Help me split this into two separate changes using Jujutsu — one for the schema and one for the API."

Claude Code should run `jj split` to interactively split the current change, selecting schema files for the first change and API files for the second. Then `jj describe` each change with an appropriate message. The second change is automatically rebased on top of the first.

## Common Pitfalls

1. **Running `git add .` out of habit.** Claude stages files with git commands in a colocated repo. This creates confusion because jj tracks all changes automatically. The git staging state and jj's working copy can get out of sync. Use only `jj` commands.

2. **Panicking about conflicts.** Claude treats jj conflicts as errors and tries to resolve immediately. Jujutsu treats conflicts as normal state — you can commit conflicted files and resolve later. This is by design, not an error.

3. **Bookmark (branch) management for pushes.** Claude expects `jj push` to just work. Jujutsu requires a bookmark pointing to the change you want to push. Create one with `jj bookmark create feature-x` on the target change, then `jj git push --bookmark feature-x`.

## Related Guides

- [Claude Code Conventional Commits Enforcement Workflow](/claude-code-conventional-commits-enforcement-workflow/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
- [AI-Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
