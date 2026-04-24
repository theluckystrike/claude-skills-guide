---
layout: default
title: "Claude Code for Rolldown"
description: "Use the Rust-powered Rolldown bundler with Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-rolldown-bundler-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, rolldown, workflow]
---

## The Setup

You are using Rolldown, the Rust-based JavaScript bundler designed as a faster drop-in replacement for Rollup (and eventually Vite's underlying bundler). Rolldown aims for Rollup API compatibility while delivering significantly faster build times. Claude Code can configure Rolldown, but it confuses it with Rollup, Vite, or Webpack configurations.

## What Claude Code Gets Wrong By Default

1. **Creates `rollup.config.js` with Rollup plugins.** Claude writes a Rollup config file with Rollup plugin imports. Rolldown has its own config format and plugin compatibility layer — not all Rollup plugins work directly.

2. **Uses Webpack configuration patterns.** Claude generates `module.exports = { entry, output, module: { rules } }`. Rolldown follows the Rollup config pattern, not Webpack's loader-based approach.

3. **Installs Rollup as a peer dependency.** Claude adds `rollup` to the project alongside Rolldown. They are separate bundlers — Rolldown does not need Rollup installed and including both causes conflicts.

4. **Ignores Rolldown-specific optimizations.** Claude configures the bundler like standard Rollup without leveraging Rolldown's parallel processing and Rust-native tree-shaking which are enabled by default.

## The CLAUDE.md Configuration

```
# Rolldown Bundler Project

## Build Tool
- Bundler: Rolldown (Rust-based, Rollup-compatible API)
- Config: rolldown.config.js or rolldown.config.ts
- CLI: npx rolldown (or rolldown in scripts)

## Rolldown Rules
- Config uses Rollup-compatible format but in rolldown.config.ts
- Plugins: many Rollup plugins compatible, test before assuming
- Tree-shaking: enabled by default, Rust-native
- Output formats: esm, cjs, iife supported
- Import from 'rolldown' for programmatic API
- Define builds in rolldown.config.ts with defineConfig()

## Conventions
- Config file: rolldown.config.ts at project root
- Build command: npx rolldown -c
- Output: dist/ directory
- Source maps: enabled for development builds
- External deps: mark in external array (node_modules)
- Use rolldown.config.ts, NOT rollup.config.js
```

## Workflow Example

You want to configure Rolldown for a TypeScript library that outputs both ESM and CJS. Prompt Claude Code:

"Set up Rolldown to build a TypeScript library with dual ESM and CJS output. Include source maps, externalize all dependencies, and configure the package.json exports field."

Claude Code should create `rolldown.config.ts` with two output configurations (ESM and CJS formats), `external` array from package.json dependencies, source map generation enabled, and update `package.json` with `"exports"` field pointing to the correct output files for each format.

## Common Pitfalls

1. **Rollup plugin compatibility assumptions.** Claude adds complex Rollup plugins expecting them to work. Rolldown supports many Rollup plugins but not all — especially those using Rollup's internal AST APIs. Test each plugin individually.

2. **Config file naming.** Claude creates `rollup.config.mjs` by habit. Rolldown looks for `rolldown.config.ts` or `rolldown.config.js` — using the Rollup filename means Rolldown ignores the config and uses defaults.

3. **TypeScript transform expectations.** Claude adds `@rollup/plugin-typescript` for TypeScript support. Rolldown has built-in TypeScript transformation — no plugin needed. Adding the Rollup plugin causes double-processing and errors.

## Related Guides

- [Claude Code for Rspack Bundler Workflow Guide](/claude-code-for-rspack-bundler-workflow-guide/)
- [Claude Code for Farm Bundler Workflow Guide](/claude-code-for-farm-bundler-workflow-guide/)
- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)

## Related Articles

- [Claude Code Sre On Call Incident — Complete Developer Guide](/claude-code-sre-on-call-incident-response-workflow-guide/)
- [Claude Code For Cloudwatch Rum — Complete Developer Guide](/claude-code-for-cloudwatch-rum-workflow/)
- [Claude Code for Aave Flash Loan Workflow](/claude-code-for-aave-flash-loan-workflow/)
- [Claude Code for Find References Workflow Tutorial](/claude-code-for-find-references-workflow-tutorial/)
- [How Claude Code Changed My — Complete Developer Guide](/how-claude-code-changed-my-development-workflow/)
- [Claude Code for README Generation Workflow Tutorial](/claude-code-for-readme-generation-workflow-tutorial/)
- [Claude Code for Echidna Fuzzing Workflow](/claude-code-for-echidna-fuzzing-workflow/)
- [Claude Code for Metacontroller Workflow Guide](/claude-code-for-metacontroller-workflow-guide/)
