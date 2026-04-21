---
title: "Claude Code Git Hook Pre-commit Conflict — Fix (2026)"
description: "Fix Claude Code git hook pre-commit conflict blocking commits. Configure hooks to work with AI-generated code. Step-by-step solution."
permalink: /claude-code-git-hook-pre-commit-conflict-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
husky - pre-commit hook exited with code 1 (error)

hint: The '.husky/pre-commit' hook was ignored because it's not set as executable.
hint: You can disable this warning with `git config advice.ignoredHook false`.

# Or:
lint-staged: Running tasks for staged files...
  ✖ eslint --fix failed
  ✖ prettier --write failed
  ERROR: Pre-commit hook failed. Claude Code commit aborted.
```

## The Fix

1. **Make hooks executable and check what's running**

```bash
# List all hooks
ls -la .husky/ .git/hooks/

# Make hooks executable
chmod +x .husky/pre-commit
chmod +x .husky/_/husky.sh
```

2. **Run the pre-commit check manually to see exact errors**

```bash
# Run lint-staged directly to see what fails
npx lint-staged --debug

# Or run the hook manually
bash .husky/pre-commit
```

3. **Verify the fix:**

```bash
# Stage a test change and commit
echo "// test" >> test-temp.js
git add test-temp.js
git commit -m "test: verify pre-commit hook"
git reset HEAD~1
rm test-temp.js
# Expected: Commit succeeds without hook errors
```

## Why This Happens

Claude Code creates and stages files, then attempts to commit. Pre-commit hooks (typically lint-staged + husky) run formatters and linters on the staged files. Claude-generated code may not match your project's exact ESLint or Prettier configuration, causing the hook to fail. Additionally, husky hooks created on one OS may lose their executable bit when checked out on another, or after a fresh `git clone` where `husky install` wasn't run.

## If That Doesn't Work

- **Alternative 1:** Add auto-fix to your lint-staged config so it repairs issues instead of failing: `"*.ts": ["eslint --fix", "prettier --write"]`
- **Alternative 2:** Update your `CLAUDE.md` to tell Claude Code about your lint rules so it generates compliant code from the start
- **Check:** Run `git config core.hooksPath` to verify hooks are pointed at the right directory (should be `.husky` or `.git/hooks`)

## Prevention

Add to your `CLAUDE.md`:
```markdown
Before committing, run `npx lint-staged` to verify all staged files pass. Follow the ESLint and Prettier configs in this project exactly. After generating code, always run the project formatter before staging.
```

**Related articles:** [Claude Code Git Hook Blocked Commit](/claude-code-git-hook-blocked-commit-fix-2026/), [ESLint Prettier Conflict Fix](/claude-code-eslint-prettier-conflict-fix/), [Debugging Tips](/claude-code-verbose-mode-debugging-tips/)
