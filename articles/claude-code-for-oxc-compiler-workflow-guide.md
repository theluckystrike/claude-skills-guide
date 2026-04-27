---
sitemap: false
layout: default
title: "Claude Code for Oxc Compiler (2026)"
description: "Claude Code for Oxc Compiler — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-oxc-compiler-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, oxc, workflow]
---

## The Setup

You are using Oxc (Oxidation Compiler), the Rust-based JavaScript/TypeScript toolchain that provides a parser, linter, resolver, transformer, and minifier — all significantly faster than their JavaScript equivalents. Claude Code can configure Oxc tools, but it defaults to the established JavaScript toolchain (Babel, ESLint, Terser) instead of Oxc equivalents.

## What Claude Code Gets Wrong By Default

1. **Configures Babel for transforms.** Claude sets up `.babelrc` with presets and plugins. Oxc's transformer handles TypeScript stripping, JSX transforms, and proposal transforms natively — no Babel needed.

2. **Uses ESLint for linting.** Claude creates `.eslintrc` with rule configurations. Oxc provides `oxlint` which runs the same rules 50-100x faster. Not all ESLint rules are implemented, but common ones are.

3. **Installs Terser for minification.** Claude adds Terser to the build pipeline. Oxc's minifier produces comparable output at much higher speed — use it as a drop-in replacement.

4. **Uses `@babel/parser` for AST work.** Claude parses code with Babel's parser for codemod or analysis tasks. Oxc's parser is significantly faster and produces a compatible AST through NAPI bindings.

## The CLAUDE.md Configuration

```
# Oxc JavaScript Toolchain Project

## Toolchain
- Parser: Oxc parser (fastest JS/TS parser)
- Linter: oxlint (replaces ESLint for supported rules)
- Transformer: Oxc transformer (replaces Babel)
- Minifier: Oxc minifier (replaces Terser)
- Resolver: Oxc resolver (replaces enhanced-resolve)

## Oxc Rules
- Lint: npx oxlint (auto-detects config)
- Config: .oxlintrc.json at project root
- Categories: correctness, suspicious, pedantic, style, nursery
- Default: correctness + suspicious rules enabled
- No plugin system — rules are built-in
- Integrates with existing .eslintrc for rule config migration

## Conventions
- Use oxlint alongside ESLint during migration (oxlint runs first, fast)
- Minification in build script: oxc minify input.js -o output.js
- Parser NAPI for custom AST tools: @oxc-parser/binding
- Enable pedantic category for stricter checks
- CI pipeline: oxlint before eslint (catches easy issues faster)
- Deny nursery rules individually as they stabilize
```

## Workflow Example

You want to replace ESLint with oxlint for faster CI feedback. Prompt Claude Code:

"Add oxlint to the CI pipeline. Run it before the existing ESLint step for fast feedback. Configure it with correctness and suspicious categories enabled, and add specific pedantic rules for no-accumulating-spread and no-barrel-file."

Claude Code should add `oxlint` to the project, create `.oxlintrc.json` with the enabled categories and specific pedantic rules, update the CI workflow to run `npx oxlint` as a separate step before the ESLint step, and note which ESLint rules can eventually be disabled as oxlint covers them.

## Common Pitfalls

1. **Expecting full ESLint rule parity.** Claude disables ESLint entirely after adding oxlint. Oxc does not implement all ESLint rules — especially plugin rules (React hooks, import order). Keep ESLint for plugin-based rules and use oxlint for the core rules it supports.

2. **Config format confusion.** Claude copies `.eslintrc` format into `.oxlintrc.json`. While oxlint can read some ESLint config, the native format has differences in how categories and rule severity are specified. Use oxlint's own config format.

3. **NAPI binding version mismatches.** Claude installs the Oxc parser binding without matching the platform. Oxc uses native bindings that are platform-specific (`@oxc-parser/binding-darwin-arm64`, etc.). The meta-package `@oxc-parser/binding` handles this, but direct platform installs cause cross-platform failures.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)


## Common Questions

### How do I get started with claude code for oxc compiler?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
