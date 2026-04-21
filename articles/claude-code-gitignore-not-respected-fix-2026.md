---
title: ".gitignore Not Respected by Claude Fix"
permalink: /claude-code-gitignore-not-respected-fix-2026/
description: "Fix Claude Code ignoring .gitignore rules. Remove cached tracked files and update .claudeignore to prevent committing build artifacts and secrets."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
warning: Claude Code staged 'dist/bundle.js' which is listed in .gitignore
warning: Claude Code staged '.env' which is listed in .gitignore
Changes to be committed:
  new file: dist/bundle.js
  new file: .env
```

This appears when Claude Code stages or commits files that should be excluded by `.gitignore`, potentially exposing secrets or adding build artifacts to the repository.

## The Fix

```bash
git rm --cached dist/bundle.js .env
git commit -m "Remove files that should be gitignored"
```

1. Remove the accidentally tracked files from Git's index (keeps them on disk).
2. Verify `.gitignore` has the correct patterns.
3. Check that the files were not previously tracked before the `.gitignore` rule was added.

## Why This Happens

Git's `.gitignore` only prevents untracked files from being staged. If a file was tracked before being added to `.gitignore`, Git continues to track it. Claude Code's `git add` commands follow Git's standard behavior, so it stages previously tracked files regardless of `.gitignore` rules. Additionally, Claude Code's Write tool creates files on disk without consulting `.gitignore`, and a subsequent `git add .` picks them up.

## If That Doesn't Work

Check if the file was previously tracked:

```bash
git log --oneline --follow -- dist/bundle.js
```

Verify `.gitignore` patterns are correct:

```bash
git check-ignore -v dist/bundle.js
```

Remove all ignored files from the index:

```bash
git rm -r --cached .
git add .
git commit -m "Reset index to respect .gitignore"
```

## Prevention

```markdown
# CLAUDE.md rule
Never run 'git add .' or 'git add -A'. Always add specific files by name. Before staging, verify files are not in .gitignore. Never stage .env, dist/, node_modules/, or build artifacts.
```
