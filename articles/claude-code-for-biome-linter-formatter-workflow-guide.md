---
sitemap: false
layout: default
title: "Claude Code for Biome — Workflow Guide (2026)"
description: "Claude Code for Biome — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-biome-linter-formatter-workflow-guide/
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

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
