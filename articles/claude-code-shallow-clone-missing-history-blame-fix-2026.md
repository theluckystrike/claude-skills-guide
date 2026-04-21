---
title: "Shallow Clone Missing History for Blame Fix"
permalink: /claude-code-shallow-clone-missing-history-blame-fix-2026/
description: "Fix shallow clone missing history for git blame in Claude Code. Unshallow the repo or fetch additional depth to access full commit history."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
fatal: git blame --porcelain: no such path 'src/api/handler.ts' in HEAD
warning: unable to access beyond shallow boundary
  This repository is a shallow clone (depth=1). History is incomplete.
  git log and git blame show only the grafted commit.
```

This appears when Claude Code tries to use `git blame`, `git log`, or `git bisect` on a shallow clone that lacks full commit history.

## The Fix

```bash
git fetch --unshallow
```

1. Convert the shallow clone into a full clone by fetching all missing history.
2. Verify full history is available: `git log --oneline | wc -l` should show all commits.
3. Claude Code can now use blame, log, and bisect normally.

## Why This Happens

CI/CD systems and quick setups often clone repositories with `--depth=1` to save time and bandwidth. This creates a "shallow" clone containing only the latest commit. Claude Code's git operations that require history (blame for understanding code authorship, log for reviewing changes, bisect for finding bugs) fail because the required commits do not exist locally.

## If That Doesn't Work

If unshallow takes too long on a massive repo, fetch only partial history:

```bash
git fetch --depth=100
```

Fetch history for a specific file:

```bash
git fetch origin main --deepen=50
git blame src/api/handler.ts
```

If the remote does not support unshallow (rare):

```bash
git clone --no-single-branch <repo-url> full-clone
cd full-clone
```

## Prevention

```markdown
# CLAUDE.md rule
This project requires full git history. Clone with 'git clone' (no --depth flag). In CI/CD, use 'fetch-depth: 0' in GitHub Actions checkout. Never use shallow clones for development.
```
