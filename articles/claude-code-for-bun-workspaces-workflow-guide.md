---
sitemap: false
layout: default
title: "Claude Code for Bun Workspaces (2026)"
description: "Claude Code for Bun Workspaces — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-bun-workspaces-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, bun, workflow]
---

## The Setup

You are managing a monorepo using Bun's built-in workspace support. Unlike npm or pnpm workspaces that need separate tools for linking and building, Bun handles workspaces natively with zero-config linking and fast installs. Claude Code can scaffold workspace packages and manage cross-dependencies, but it defaults to npm/yarn workspace patterns that conflict with Bun's approach.

## What Claude Code Gets Wrong By Default

1. **Adds lerna, turbo, or nx for workspace management.** Claude installs monorepo tools on top of Bun. Bun workspaces handle dependency linking natively — `bun install` at the root links all packages automatically.

2. **Uses `npm link` or `yarn link` for local packages.** Claude runs manual linking commands. Bun resolves workspace packages through the `"workspaces"` field in root `package.json` without any link step.

3. **Creates `.npmrc` or `.yarnrc` files.** Claude generates package manager config files for the wrong runtime. Bun reads `bunfig.toml` for configuration, not npm or yarn config files.

4. **Writes CommonJS in workspace packages.** Claude defaults to `module.exports`. Bun workspaces work best with ESM — use `"type": "module"` in each package's `package.json` and `export` syntax in source files.

## The CLAUDE.md Configuration

```
# Bun Monorepo with Workspaces

## Architecture
- Runtime: Bun
- Monorepo: Bun native workspaces
- Structure: packages/* and apps/* directories
- Config: bunfig.toml for Bun settings, NOT .npmrc

## Workspace Rules
- Root package.json has "workspaces": ["packages/*", "apps/*"]
- Run bun install at root only — links all packages automatically
- Reference workspace packages by name: "my-lib": "workspace:*"
- No lerna, no turbo, no nx — Bun handles it natively
- Scripts run from root: bun run --filter my-app dev
- Each package has its own package.json with "type": "module"

## Conventions
- Shared packages in packages/ directory
- Applications in apps/ directory
- Package names prefixed: @myorg/package-name
- Each package exports via package.json "exports" field
- TypeScript: each package has own tsconfig extending root
- Test with bun test (built-in test runner, no Jest needed)
- Never use require() — ESM imports only
```

## Workflow Example

You want to create a shared UI component package used by two apps. Prompt Claude Code:

"Create a new workspace package called @myorg/ui in packages/ui with a Button component. Add it as a dependency to apps/web and apps/docs. Make sure TypeScript types are exported correctly."

Claude Code should create `packages/ui/package.json` with proper `"exports"` and `"types"` fields, write the Button component with TypeScript, add `"@myorg/ui": "workspace:*"` to both apps' `package.json` files, and run `bun install` at the root to link everything.

## Common Pitfalls

1. **Forgetting `workspace:*` protocol.** Claude adds dependencies with version numbers like `"@myorg/ui": "^1.0.0"`. Bun workspaces require the `workspace:*` protocol to resolve local packages instead of looking them up in the npm registry.

2. **Running `bun install` in individual packages.** Claude runs install in each package directory separately. With Bun workspaces, always run `bun install` from the monorepo root — it handles all packages at once and creates the correct symlinks.

3. **TypeScript path mapping conflicts.** Claude adds `paths` in `tsconfig.json` to resolve workspace packages. Bun's workspace linking makes packages available by name already. Adding redundant path mappings causes resolution conflicts when both Bun and TypeScript try to resolve the same import.



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Using Claude Code with Bun Runtime JavaScript Projects](/using-claude-code-with-bun-runtime-javascript-projects/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [What Is the Best Way to Organize Claude Skills in a Monorepo](/what-is-the-best-way-to-organize-claude-skills-in-a-monorepo/)

## Related Articles

- [Claude Code for Microbenchmark Workflow Tutorial Guide](/claude-code-for-microbenchmark-workflow-tutorial-guide/)
- [How to Use For Braintree Payment — Complete Developer (2026)](/claude-code-for-braintree-payment-workflow-guide/)
- [Claude Code for Confluence Workflow Tutorial Guide](/claude-code-for-confluence-workflow-tutorial-guide/)
- [Claude Code for Transaction Tracing Workflow Tutorial](/claude-code-for-transaction-tracing-workflow-tutorial/)
- [Claude Code for Auto Assign Reviewer Workflow Tutorial](/claude-code-for-auto-assign-reviewer-workflow-tutorial/)
- [Claude Code for Nomad Container Scheduling Workflow](/claude-code-for-nomad-container-scheduling-workflow/)
- [Claude Code For Step Ca Pki — Complete Developer Guide](/claude-code-for-step-ca-pki-workflow-guide/)
- [How to Use Ripgrep: Search Workflow (2026)](/claude-code-with-ripgrep-and-grep-workflow-tips/)
- [Claude Code for Bun Runtime — Workflow Guide](/claude-code-for-bun-runtime-workflow-guide/)


## Common Questions

### How do I get started with claude code for bun workspaces?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Fix Claude Code Bun Crash](/claude-code-bun-crash/)
- [Fix Claude Code Bun Errors](/claude-code-bun-error/)
- [Claude Code Bun Install Setup Guide](/claude-code-bun-install/)
