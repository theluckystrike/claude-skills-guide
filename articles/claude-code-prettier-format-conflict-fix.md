---
title: "Claude Code Prettier Format Conflict — Fix (2026)"
description: "Fix Claude Code Prettier format conflict with project config. Align Claude output with .prettierrc settings. Step-by-step solution."
permalink: /claude-code-prettier-format-conflict-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
[warn] src/components/Button.tsx
[warn] Code style issues found in the above file. Run Prettier to fix.

# Or after Claude Code edits a file:
error: You have unstaged changes. Please commit or stash them.
  (Prettier reformatted files that Claude Code just wrote)

# Or in pre-commit:
✖ prettier --check failed without output (SIGKILL)
  src/utils/helpers.ts — Formatting differs from Prettier config
```

## The Fix

1. **Tell Claude Code about your Prettier config in CLAUDE.md**

```bash
# Check your current Prettier settings
cat .prettierrc 2>/dev/null || cat .prettierrc.json 2>/dev/null || echo "No .prettierrc found"

# Add formatting rules to CLAUDE.md
cat >> CLAUDE.md << 'EOF'

## Code Formatting
- Use single quotes (singleQuote: true)
- Tab width: 2 spaces
- Semicolons: required
- Trailing commas: all
- Print width: 80
- Always match the format in .prettierrc
EOF
```

2. **Auto-format Claude Code output with a hook**

```bash
# Add to .claude/settings.json or use a post-edit hook:
# After Claude edits files, run Prettier automatically
npx prettier --write "src/**/*.{ts,tsx,js,jsx}" --config .prettierrc
```

3. **Verify the fix:**

```bash
npx prettier --check "src/**/*.{ts,tsx}" 2>&1 | tail -5
# Expected: All matched files use Prettier code style!
```

## Why This Happens

Claude Code generates code based on patterns in its training data, which may default to different formatting conventions than your project's Prettier configuration. For example, Claude might output double quotes when your `.prettierrc` specifies single quotes, or use 4-space indentation when your project uses 2. Since Prettier is opinionated and deterministic, any deviation from your config is flagged as an error during checks. The conflict appears in pre-commit hooks, CI pipelines, or manual `prettier --check` runs.

## If That Doesn't Work

- **Alternative 1:** Set up lint-staged to auto-format on commit: `"*.{ts,tsx}": ["prettier --write"]` in `package.json`
- **Alternative 2:** Use the VS Code Prettier extension with format-on-save to catch issues immediately
- **Check:** Run `npx prettier --find-config-path src/file.ts` to confirm Prettier is finding your config file

## Prevention

Add to your `CLAUDE.md`:
```markdown
Format all code according to this project's .prettierrc: single quotes, 2-space indent, semicolons, trailing commas. Run `npx prettier --write` on every file you create or modify. Never override .prettierrc settings.
```

**Related articles:** [ESLint Prettier Conflict Fix](/claude-code-eslint-prettier-conflict-fix/), [Git Hook Pre-commit Conflict](/claude-code-git-hook-pre-commit-conflict-fix/), [Verbose Mode Debugging](/claude-code-verbose-mode-debugging-tips/)
