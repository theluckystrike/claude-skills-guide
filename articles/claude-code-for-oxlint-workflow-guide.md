---
layout: default
title: "Claude Code for Oxlint — Workflow Guide"
description: "Claude Code for Oxlint — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-oxlint-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, oxlint, workflow]
---

## The Setup

You are adding Oxlint to your project for near-instant JavaScript/TypeScript linting. Oxlint runs 50-100x faster than ESLint by using Rust and can catch common issues in milliseconds. Claude Code can configure and fix Oxlint issues, but it treats Oxlint as an ESLint replacement when it works best as a complement.

## What Claude Code Gets Wrong By Default

1. **Removes ESLint entirely.** Claude uninstalls ESLint when adding Oxlint. Oxlint does not support all ESLint rules — especially plugin rules for React, import ordering, and accessibility. Keep both, with Oxlint running first for fast feedback.

2. **Uses ESLint config format verbatim.** Claude copies `.eslintrc.json` rules into Oxlint config. While Oxlint understands some ESLint config, its native `.oxlintrc.json` format organizes rules by category (correctness, suspicious, style) rather than flat rule lists.

3. **Expects plugin support.** Claude tries to configure `eslint-plugin-react-hooks` rules in Oxlint. Oxlint has no plugin system — it implements common rules from popular plugins natively, but not all of them.

4. **Runs Oxlint after ESLint.** Claude puts Oxlint as a secondary linter. Since Oxlint runs 100x faster, it should run first in CI to provide instant feedback, with ESLint running afterward for the rules Oxlint does not cover.

## The CLAUDE.md Configuration

```
# Oxlint Fast Linter

## Linting Strategy
- Fast lint: Oxlint (runs first, milliseconds)
- Full lint: ESLint (runs second, covers plugin rules)
- Config: .oxlintrc.json for Oxlint rules

## Oxlint Rules
- npx oxlint . (runs on current directory)
- Categories: correctness (default), suspicious, pedantic, style
- Enable category: "categories": { "suspicious": "warn" }
- Individual rules: "rules": { "no-unused-vars": "error" }
- Ignore patterns: "ignorePatterns": ["dist", "node_modules"]
- Auto-fix: npx oxlint --fix .

## Conventions
- CI order: oxlint first, then eslint
- Pre-commit hook: oxlint only (fast enough for every commit)
- Full ESLint: run on CI and pre-push only
- Correctness + suspicious categories always enabled
- Style category: warn only (do not block commits)
- Track oxlint rule coverage — disable ESLint rules as oxlint adds them
```

## Workflow Example

You want to integrate Oxlint into your existing ESLint project. Prompt Claude Code:

"Add Oxlint to this project alongside ESLint. Configure it with correctness and suspicious categories, add it to the pre-commit hook for fast linting, and update the CI pipeline to run Oxlint before ESLint."

Claude Code should install `oxlint`, create `.oxlintrc.json` with the two categories enabled, add `npx oxlint .` to the pre-commit hook (using husky or lint-staged), and update the CI workflow to run Oxlint as an earlier step with ESLint following.

## Common Pitfalls

1. **Duplicate rule warnings.** Claude enables the same rules in both Oxlint and ESLint, causing duplicate warnings. Once a rule works in Oxlint, disable it in ESLint with a comment noting the migration: `// handled by oxlint`.

2. **Oxlint severity defaults differ from ESLint.** Claude expects `"no-unused-vars": "error"` to behave identically. Oxlint's default severity for some rules differs from ESLint's. Explicitly set severity in `.oxlintrc.json` to match your ESLint config.

3. **Missing TypeScript type-aware rules.** Claude expects Oxlint to run type-aware rules like `@typescript-eslint/no-floating-promises`. Oxlint does not perform type checking — it lints syntactically only. Type-aware rules must stay in ESLint with the TypeScript parser.

## Related Guides

- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
