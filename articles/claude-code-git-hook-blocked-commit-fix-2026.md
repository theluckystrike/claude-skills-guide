---
title: "Pre-commit Hook Failed in Claude Code — Fix (2026)"
permalink: /claude-code-git-hook-blocked-commit-fix-2026/
description: "Fix the linting error flagged by the pre-commit hook, then re-stage and commit. Resolves hook exit code 1 failures blocking Claude Code commits."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
pre-commit hook failed (exit code 1) — commit aborted by Claude Code
```

## The Fix

```bash
# Check what the hook flagged
git diff --cached | npx eslint --stdin --stdin-filename staged.ts
# Fix the issue, then re-stage and commit
git add -A && git commit -m "fix: resolve lint errors"
```

## Why This Works

Claude Code respects git hooks by design and never bypasses them with `--no-verify`. When a pre-commit hook (linting, formatting, type-checking) fails, the commit is aborted. The fix is to address the actual issue the hook caught, re-stage the corrected files, and commit again.

## If That Doesn't Work

```bash
# See exactly which hook failed and its output
GIT_TRACE=1 git commit -m "test" 2>&1 | head -50
# If the hook is broken (not your code), temporarily skip it
# ONLY if you understand the consequences:
git commit --no-verify -m "fix: bypass broken hook (hook issue tracked in #123)"
```

If the hook runs a tool that is not installed in your environment (like a Python linter in a Node project), install the missing dependency or remove that hook from `.pre-commit-config.yaml`.

## Prevention

Add to your CLAUDE.md:
```
Never use --no-verify to bypass hooks. When a pre-commit hook fails, fix the underlying issue. Run the hook manually before committing large changesets: pre-commit run --all-files.
```
