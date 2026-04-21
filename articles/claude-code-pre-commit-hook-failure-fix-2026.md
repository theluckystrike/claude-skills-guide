---
title: "Pre-Commit Hook Failure on Claude Changes Fix"
permalink: /claude-code-pre-commit-hook-failure-fix-2026/
description: "Fix pre-commit hook failures on Claude Code changes. Run linters manually, fix violations, then re-commit to pass ESLint, Prettier, or type checks."
last_tested: "2026-04-22"
render_with_liquid: false
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
