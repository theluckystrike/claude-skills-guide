---
title: "Claude Code Monorepo: Best Setup Guide"
description: "Configure Claude Code for monorepos with per-package CLAUDE.md files, scoped tool permissions, and workspace-aware dependency management rules."
permalink: /claude-code-monorepo-best-setup-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Monorepo: Best Setup Guide (2026)

Monorepos amplify every Claude Code problem — wrong package dependencies, cross-package import mistakes, files in wrong directories. Here's the setup that tames it.

## The Problem

In a monorepo, Claude Code:
- Installs dependencies at the root instead of in the specific package
- Uses relative imports between packages instead of workspace imports
- Creates files in the wrong package directory
- Doesn't know which tsconfig/eslint config applies to which package
- Modifies shared packages without understanding downstream impact

## Root Cause

Claude Code sees one project root. It doesn't inherently understand workspace boundaries, package scoping, or the dependency direction between packages.

## The Fix

### 1. Root CLAUDE.md for Global Rules

```markdown
# Monorepo: my-project

## Structure
- packages/api — Express API (TypeScript)
- packages/web — Next.js frontend (TypeScript)
- packages/shared — shared types and utilities
- packages/cli — CLI tool (TypeScript)

## Monorepo Rules
- Dependencies: ALWAYS use `pnpm add <pkg> --filter <workspace>`, NEVER `pnpm add` at root
- Imports between packages: use workspace names `@myorg/shared`, NEVER relative paths `../../shared`
- Each package has its own tsconfig.json, eslint config, and test setup
- Before modifying @myorg/shared, list all packages that import from it

## Package Boundaries
- packages/api depends on @myorg/shared
- packages/web depends on @myorg/shared
- packages/cli depends on @myorg/shared
- @myorg/shared depends on nothing — no imports from other packages
```

### 2. Per-Package CLAUDE.md Files

Create `packages/api/CLAUDE.md`:

```markdown
# API Package
- Framework: Express with tRPC
- ORM: Drizzle
- Tests: Vitest
- All routes in src/routes/
- All services in src/services/
```

### 3. Workspace-Aware Commands

Add to [commands](/understanding-claude-code-hooks-system-complete-guide/):

```markdown
# .claude/commands/add-dep.md
When adding a dependency to this monorepo:
1. Identify which package needs it
2. Run: pnpm add <package> --filter @myorg/<workspace>
3. Never install at the root unless it's a dev tool used by all packages
```

## CLAUDE.md Rule to Add

```markdown
## Cross-Package Changes
Before modifying @myorg/shared:
1. List all packages that import the changed code
2. Check if the change breaks any consumer
3. Update consumers if needed
4. Run tests in ALL affected packages, not just @myorg/shared
```

## Verification

```
Add a date formatting utility to the shared package
```

**Bad:** creates `packages/shared/src/utils/date.ts`, adds `date-fns` to root `package.json`
**Good:** creates the utility in `packages/shared/src/utils/`, runs `pnpm add date-fns --filter @myorg/shared`, verifies no downstream breaks

Related: [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [Karpathy Don't Assume Examples](/karpathy-dont-assume-examples-real-projects-2026/)

## See Also

- [Claude Code Monorepo Workspace Resolution Failure — Fix (2026)](/claude-code-monorepo-workspace-resolution-failure-fix/)
- [Monorepo Workspace Package Resolution — Fix (2026)](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
- [Make Claude Code Write Tests First (TDD) (2026)](/claude-code-write-tests-first-tdd-setup-2026/)
- [Claude Code Tab Completion Setup Guide 2026](/claude-code-tab-completion-setup-2026/)
- [How to Set Up Claude Code in Ghostty Terminal 2026](/claude-code-ghostty-terminal-setup-2026/)
