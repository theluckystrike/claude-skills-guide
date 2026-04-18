---
layout: default
title: "Claude Code for Biome — Workflow Guide"
description: "Replace ESLint and Prettier with Biome using Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-biome-linter-formatter-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, biome, workflow]
---

## The Setup

You are replacing ESLint and Prettier with Biome, the fast all-in-one linter and formatter written in Rust. Claude Code can configure Biome rules, fix linting errors, and format code, but it keeps generating ESLint and Prettier configurations alongside Biome or uses ESLint rule names that do not exist in Biome.

## What Claude Code Gets Wrong By Default

1. **Creates `.eslintrc` and `.prettierrc` files.** Claude generates ESLint and Prettier configs when you ask for linting setup. With Biome, everything goes in a single `biome.json` file — no other config files needed.

2. **Uses ESLint rule names in Biome config.** Claude writes `"no-unused-vars": "error"` in `biome.json`. Biome uses its own rule naming: `"noUnusedVariables"` under `"linter": { "rules": { "correctness": { ... } } }`.

3. **Runs `npx eslint --fix` for auto-fixes.** Claude defaults to ESLint CLI commands. Biome uses `npx @biomejs/biome check --fix` for combined linting and formatting, or `biome format --write` for formatting only.

4. **Installs multiple dev dependencies.** Claude adds `eslint`, `prettier`, `eslint-config-*`, and dozens of plugins. Biome is a single dependency: `@biomejs/biome`. No plugins, no config inheritance chains.

## The CLAUDE.md Configuration

```
# Biome Linter/Formatter Project

## Tooling
- Linter + Formatter: Biome (@biomejs/biome)
- Config: biome.json at project root
- NO ESLint, NO Prettier — Biome replaces both

## Biome Rules
- Format: npx @biomejs/biome format --write .
- Lint: npx @biomejs/biome lint .
- Both: npx @biomejs/biome check --fix .
- Config uses camelCase rule names, not ESLint kebab-case
- Rules organized by category: correctness, suspicious, style, complexity
- Use "recommended": true for sensible defaults
- Override per-file with biome.json "overrides" array

## Conventions
- Run biome check before commits (pre-commit hook)
- Indent: tabs (Biome default, do not change to spaces)
- Line width: 100 characters
- Quote style: double quotes
- Semicolons: always
- Never add ESLint or Prettier — Biome handles everything
- Ignore generated files in biome.json "files.ignore"
```

## Workflow Example

You want to migrate from ESLint + Prettier to Biome. Prompt Claude Code:

"Migrate this project from ESLint and Prettier to Biome. Remove the old config files and dependencies, create a biome.json with equivalent rules, and update the package.json scripts."

Claude Code should delete `.eslintrc.*`, `.prettierrc`, remove ESLint/Prettier packages from `package.json`, install `@biomejs/biome`, create `biome.json` with `"recommended": true`, and update scripts to use `biome check --fix` instead of `eslint --fix && prettier --write`.

## Common Pitfalls

1. **Import sorting conflicts.** Claude configures Biome's import sorting but keeps the `eslint-plugin-import` sort order. Biome sorts imports differently by default. Remove any other import sorting tools and let Biome handle it exclusively.

2. **VS Code extension conflicts.** Claude does not update VS Code settings. If you have the ESLint and Prettier extensions active alongside the Biome extension, you get duplicate formatting and conflicting fixes. Disable the ESLint and Prettier extensions for the workspace.

3. **Biome does not support all ESLint rules.** Claude migrates every ESLint rule one-to-one. Some ESLint ecosystem rules (like React-specific or TypeScript-ESLint rules) may not have Biome equivalents yet. Check Biome's rule list before assuming a migration is complete.

## Related Guides

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
