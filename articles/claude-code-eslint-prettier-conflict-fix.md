---
sitemap: false
layout: default
title: "Fix ESLint and Prettier Conflicts (2026)"
description: "Resolve ESLint and Prettier Conflicts in Claude Code issues with tested solutions, step-by-step debugging, and production-ready code examples verified..."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-eslint-prettier-conflict-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [eslint, prettier, formatting, linting, configuration]
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix ESLint and Prettier Conflicts in Claude Code Projects

## The Problem

Claude Code writes code that passes Prettier formatting but fails ESLint, or vice versa. You see conflicting errors like:

```
error Replace `·····` with `····` prettier/prettier
error Expected indentation of 4 spaces but found 2 indent
```

Or Claude Code fixes one linting error and introduces another because ESLint's formatting rules conflict with Prettier's output. This creates an endless loop of fixes.

## Quick Fix

Install `eslint-config-prettier` to disable all ESLint rules that conflict with Prettier:

```bash
npm install --save-dev eslint-config-prettier
```

Add it as the last item in your ESLint extends array:

```json
{
 "extends": [
 "eslint:recommended",
 "plugin:@typescript-eslint/recommended",
 "prettier"
 ]
}
```

This disables every ESLint rule that Prettier handles, eliminating all conflicts.

## What's Happening

ESLint and Prettier both have opinions about code formatting. ESLint has rules like `indent`, `semi`, `quotes`, and `max-len` that control formatting. Prettier also controls these same aspects but with its own logic. When both tools run, they can produce contradictory requirements.

For example, ESLint's `indent` rule might require 4 spaces while Prettier is configured for 2 spaces. Claude Code writes code with 2-space indentation (following Prettier), and ESLint immediately flags it as an error.

The solution is to let Prettier handle all formatting and let ESLint handle only code quality rules (unused variables, type errors, potential bugs).

## Step-by-Step Fix

### Step 1: Audit current configuration

Ask Claude Code to check for conflicts:

```
Check my ESLint and Prettier configurations for conflicting rules.
List every ESLint rule that overlaps with Prettier's formatting.
```

Claude Code will read your `.eslintrc.*`, `eslint.config.*`, and `.prettierrc.*` files and identify overlapping rules like:

- `indent` / `@typescript-eslint/indent`
- `semi` / `@typescript-eslint/semi`
- `quotes` / `@typescript-eslint/quotes`
- `comma-dangle`
- `arrow-parens`
- `max-len` / `printWidth`
- `object-curly-spacing`
- `array-bracket-spacing`

### Step 2: Install the compatibility package

```bash
npm install --save-dev eslint-config-prettier
```

For ESLint 9+ with flat config:

```bash
npm install --save-dev eslint-config-prettier
```

### Step 3: Update ESLint configuration

**For flat config (eslint.config.js) - ESLint 9+:**

```javascript
import eslintConfigPrettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';

export default [
 ...tseslint.configs.recommended,
 eslintConfigPrettier, // Must be last
 {
 rules: {
 // Your custom code quality rules (not formatting)
 'no-console': 'warn',
 '@typescript-eslint/no-unused-vars': 'error',
 '@typescript-eslint/explicit-function-return-type': 'warn',
 },
 },
];
```

**For legacy config (.eslintrc.json):**

```json
{
 "extends": [
 "eslint:recommended",
 "plugin:@typescript-eslint/recommended",
 "plugin:react/recommended",
 "plugin:react-hooks/recommended",
 "prettier"
 ],
 "rules": {
 "no-console": "warn",
 "@typescript-eslint/no-unused-vars": "error"
 }
}
```

The `"prettier"` entry must be last in the extends array because it overrides all previous formatting rules.

### Step 4: Configure Prettier

Create or update `.prettierrc`:

```json
{
 "semi": true,
 "singleQuote": true,
 "tabWidth": 2,
 "trailingComma": "all",
 "printWidth": 100,
 "arrowParens": "always",
 "endOfLine": "lf"
}
```

### Step 5: Remove conflicting ESLint rules

After adding `eslint-config-prettier`, manually remove any formatting rules you had in your ESLint config:

```
Review my ESLint config and remove any formatting rules that
Prettier now handles. Keep only code quality rules.
```

Rules to remove (Claude Code will identify the full list):

```javascript
// Remove all of these from your ESLint rules:
// indent, semi, quotes, comma-dangle, arrow-parens,
// object-curly-spacing, array-bracket-spacing, max-len,
// no-mixed-spaces-and-tabs, no-trailing-spaces,
// space-before-function-paren, keyword-spacing,
// @typescript-eslint/indent, @typescript-eslint/semi,
// @typescript-eslint/quotes, @typescript-eslint/comma-dangle,
// @typescript-eslint/member-delimiter-style
```

### Step 6: Set up format-on-save in your editor

Configure VS Code to run Prettier on save and ESLint for diagnostics:

```json
{
 "editor.defaultFormatter": "esbenp.prettier-vscode",
 "editor.formatOnSave": true,
 "editor.codeActionsOnSave": {
 "source.fixAll.eslint": "explicit"
 },
 "eslint.validate": ["javascript", "typescript", "typescriptreact"]
}
```

### Step 7: Add a pre-commit hook

Ensure consistency across your team with lint-staged:

```bash
npm install --save-dev husky lint-staged
npx husky init
```

Configure `lint-staged` in `package.json`:

```json
{
 "lint-staged": {
 "*.{ts,tsx,js,jsx}": [
 "prettier --write",
 "eslint --fix --max-warnings 0"
 ],
 "*.{json,md,css}": [
 "prettier --write"
 ]
 }
}
```

### Step 8: Update CLAUDE.md

Tell Claude Code about your formatting setup:

```markdown
## Code Formatting
- Prettier handles all formatting (run `npx prettier --write` on changed files)
- ESLint handles code quality only (no formatting rules)
- Run `npm run lint` before committing
- Zero warnings policy: fix all ESLint warnings, do not suppress with eslint-disable
```

## Verify the Fix

Run both tools and confirm no conflicts:

```bash
# Format with Prettier
npx prettier --write "src/**/*.{ts,tsx}"

# Lint with ESLint (should report zero formatting issues)
npx eslint "src/**/*.{ts,tsx}"

# Check for any remaining conflicts
npx eslint-config-prettier "src/**/*.{ts,tsx}"
```

The `eslint-config-prettier` CLI tool checks your config for rules that conflict with Prettier and reports them.

## Prevention

Keep formatting and linting concerns separate. Prettier owns formatting (whitespace, semicolons, quotes, line length). ESLint owns code quality (unused variables, unreachable code, type safety). Never add formatting rules to ESLint when Prettier is in the project.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-eslint-prettier-conflict-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code CLAUDE.md Best Practices](/claude-code-claude-md-best-practices/)
- [Claude Code Workflow Optimization Tips 2026](/claude-code-workflow-optimization-tips-2026/)

## See Also

- [Claude Code ESLint Plugin Crashes on Custom Rule — Fix (2026)](/claude-code-eslint-plugin-crashes-custom-rule-fix/)
- [Claude Code Prettier Format Conflict — Fix (2026)](/claude-code-prettier-format-conflict-fix/)
- [Claude Code vs ESLint + Prettier: Code Quality Tools](/claude-code-vs-eslint-prettier-comparison/)
