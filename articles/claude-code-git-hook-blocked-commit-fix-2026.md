---
title: "Pre-commit Hook Failed in Claude Code"
permalink: /claude-code-git-hook-blocked-commit-fix-2026/
description: "Fix the linting error flagged by the pre-commit hook, then re-stage and commit. Resolves hook exit code 1 failures blocking Claude Code commits."
last_tested: "2026-04-21"
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

## See Also

- [Claude Code Hook Script Not Executable — Fix (2026)](/claude-code-hook-script-not-executable-fix-2026/)
- [Fix Claude Code Poor Commit Messages (2026)](/claude-code-poor-commit-messages-fix-2026/)
- [Claude Amending Wrong Commit Fix](/claude-code-amending-wrong-commit-fix-2026/)
- [Claude Code Git Hook Pre-commit Conflict — Fix (2026)](/claude-code-git-hook-pre-commit-conflict-fix/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `Hook execution failed with exit code 1`
- `pre-commit hook rejected the commit`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What are Claude Code hooks?

Claude Code hooks are user-defined scripts that run at specific lifecycle points: before/after file edits, before/after bash commands, and before/after commits. They are configured in `.claude/hooks/` or via the Claude Code settings file.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
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
