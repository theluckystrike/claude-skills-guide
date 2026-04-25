---
title: "Pre-Commit Hook Failure on Claude — Fix"
permalink: /claude-code-pre-commit-hook-failure-fix-2026/
description: "Fix pre-commit hook failures on Claude Code changes. Run linters manually, fix violations, then re-commit to pass ESLint, Prettier, or type checks."
last_tested: "2026-04-22"
---

## The Error

```
husky - pre-commit hook exited with code 1
lint-staged: ✖ eslint --fix found 3 errors in src/api/routes.ts
  error  Unexpected any type  @typescript-eslint/no-explicit-any (line 23)
  error  Missing return type  @typescript-eslint/explicit-function-return-type (line 45)
Claude Code commit aborted due to pre-commit hook failure.
```

This appears when Claude Code's generated code fails linting, formatting, or type-checking rules enforced by pre-commit hooks.

## The Fix

```bash
npx lint-staged --allow-empty
```

1. Run the linter manually to see all errors: `npx eslint src/api/routes.ts`.
2. Ask Claude Code to fix the specific violations: `claude "Fix the eslint errors: remove 'any' types and add return types in src/api/routes.ts"`.
3. Stage the fixed files and commit again.

## Why This Happens

Claude Code generates code based on the model's training data, which may not match your project's specific linting configuration. Strict TypeScript rules (`no-explicit-any`, `explicit-function-return-type`), import ordering rules, or Prettier formatting differences cause the pre-commit hook to reject the commit. The commit does not go through, but Claude Code may think it succeeded.

## If That Doesn't Work

Run the full pre-commit check manually and fix all issues:

```bash
npx eslint --fix src/api/routes.ts
npx prettier --write src/api/routes.ts
git add src/api/routes.ts
git commit -m "Fixed changes"
```

Tell Claude Code about your specific lint rules:

```bash
claude "Our project uses strict TypeScript. No 'any' types. All functions need explicit return types. Fix and commit."
```

Temporarily skip hooks for emergency commits (use sparingly):

```bash
git commit --no-verify -m "Emergency fix — lint cleanup follows"
```

## Prevention

```markdown
# CLAUDE.md rule
All generated code must pass our ESLint config. Use explicit types, never 'any'. Run 'npx eslint --fix' before every commit. Check .eslintrc for project rules before writing code.
```

## See Also

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
