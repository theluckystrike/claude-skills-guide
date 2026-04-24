---
layout: default
title: "Claude Code Monorepo Setup (2026)"
description: "Configure Claude Code for monorepos using Turborepo, Nx, or pnpm workspaces. CLAUDE.md structure, context management, and multi-package workflows."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-monorepo-setup-guide/
reviewed: true
categories: [guides, claude-code]
tags: [monorepo, turborepo, nx, pnpm, workspaces]
geo_optimized: true
last_tested: "2026-04-22"
---
# How to Set Up Claude Code for Monorepo Projects

## The Problem

Your monorepo has dozens of packages. Claude Code does not know which package you are working in, reads files from the wrong package, and wastes context on irrelevant code. Build commands, test commands, and lint configurations differ per package, and Claude Code uses the wrong ones.

## Quick Fix

Create a root-level `CLAUDE.md` with the monorepo structure, then package-level CLAUDE.md files with specific instructions:

```markdown
<!-- /CLAUDE.md (root) -->
# Monorepo: MyApp

## Structure
- packages/api - Express API server (Node.js, TypeScript)
- packages/web - Next.js frontend (React, TypeScript)
- packages/shared - Shared types and utilities
- packages/db - Prisma schema and database client

## Package Manager
pnpm (use pnpm, not npm or yarn)

## Common Commands
- Install all: `pnpm install`
- Build all: `pnpm run build`
- Test all: `pnpm run test`
- Lint all: `pnpm run lint`

## Working in a Package
Always specify the package: `pnpm --filter @myapp/api run test`
```

```markdown
<!-- /packages/api/CLAUDE.md -->
# @myapp/api

## Commands
- Dev: `pnpm run dev` (starts on port 3001)
- Test: `pnpm run test`
- Build: `pnpm run build`
- Lint: `pnpm run lint`

## Key Directories
- src/routes/ - API route handlers
- src/middleware/ - Express middleware
- src/services/ - Business logic
- src/__tests__/ - Test files (co-located with source)

## Dependencies
- Uses @myapp/shared for types
- Uses @myapp/db for database access
```

## What's Happening

Monorepos contain multiple packages in a single repository. Each package has its own `package.json`, build configuration, and test setup. Claude Code reads files from the current working directory and its CLAUDE.md, but without explicit guidance it cannot distinguish between packages or know their relationships.

The solution is a layered CLAUDE.md approach: a root file for repository-wide context and per-package files for specific instructions. Claude Code reads the root CLAUDE.md first, then the package-level one based on which files you are discussing.

## Step-by-Step Setup

### Step 1: Choose your monorepo tool

Ask Claude Code to set up the monorepo structure:

**Turborepo (recommended for most projects):**

```bash
pnpm dlx create-turbo@latest my-monorepo
```

**Nx (for enterprise-scale projects):**

```bash
pnpm dlx create-nx-workspace@latest my-monorepo
```

**pnpm Workspaces (lightweight, no build orchestration):**

```yaml
# pnpm-workspace.yaml
packages:
 - 'packages/*'
 - 'apps/*'
```

### Step 2: Configure root CLAUDE.md

The root CLAUDE.md is your monorepo's instruction manual for Claude Code:

```markdown
# Project: SaaS Platform

## Monorepo Structure
This is a Turborepo monorepo with pnpm workspaces.

### Apps
- apps/web - Next.js customer dashboard
- apps/admin - Next.js admin panel
- apps/api - Fastify API server

### Packages
- packages/ui - Shared React component library
- packages/db - Prisma client and schema
- packages/config-eslint - Shared ESLint config
- packages/config-typescript - Shared tsconfig
- packages/types - Shared TypeScript types

## Package Manager
pnpm 9.x — never use npm or yarn

## Dependency Rules
- Apps can depend on packages, never on other apps
- packages/ui can depend on packages/types only
- packages/db can depend on packages/types only
- Circular dependencies are forbidden

## Build Order
turbo handles this automatically via turbo.json. Manual order:
packages/types → packages/db → packages/ui → apps/*

## Environment Variables
- apps/web: .env.local (NEXT_PUBLIC_* for client-side)
- apps/api: .env (DATABASE_URL, JWT_SECRET, REDIS_URL)
- Root .env is not used

## Testing
- Unit tests: `pnpm run test` in each package
- Integration tests: `pnpm --filter @myapp/api run test:integration`
- E2E tests: `pnpm --filter @myapp/web run test:e2e`
```

### Step 3: Configure per-package CLAUDE.md files

Each package gets instructions specific to its tech stack:

```markdown
<!-- packages/ui/CLAUDE.md -->
# @myapp/ui - Component Library

## Tech Stack
React 19, TypeScript, Tailwind CSS, Storybook

## Commands
- Dev (Storybook): `pnpm run storybook`
- Test: `pnpm run test`
- Build: `pnpm run build`

## Component Pattern
Every component must have:
1. ComponentName.tsx - Implementation
2. ComponentName.test.tsx - Tests
3. ComponentName.stories.tsx - Storybook story
4. index.ts - Re-export

## Exports
All components are exported from packages/ui/src/index.ts.
After creating a new component, add it to the index.

## Styling
Use Tailwind CSS utility classes. No CSS modules, no styled-components.
```

### Step 4: Configure turbo.json for Claude Code

Turborepo's pipeline configuration tells Claude Code how tasks relate:

```json
{
 "$schema": "https://turbo.build/schema.json",
 "tasks": {
 "build": {
 "dependsOn": ["^build"],
 "outputs": ["dist/**", ".next/**"]
 },
 "test": {
 "dependsOn": ["build"]
 },
 "lint": {},
 "dev": {
 "cache": false,
 "persistent": true
 }
 }
}
```

### Step 5: Set up shared TypeScript configuration

Create a base tsconfig that all packages extend:

```json
// packages/config-typescript/base.json
{
 "compilerOptions": {
 "strict": true,
 "target": "ES2022",
 "module": "ESNext",
 "moduleResolution": "bundler",
 "declaration": true,
 "declarationMap": true,
 "sourceMap": true,
 "esModuleInterop": true,
 "skipLibCheck": true,
 "forceConsistentCasingInFileNames": true,
 "resolveJsonModule": true,
 "isolatedModules": true
 }
}
```

Each package extends it:

```json
// packages/api/tsconfig.json
{
 "extends": "@myapp/config-typescript/base.json",
 "compilerOptions": {
 "outDir": "dist",
 "rootDir": "src"
 },
 "include": ["src/**/*"]
}
```

### Step 6: Handle cross-package dependencies

Tell Claude Code how packages reference each other:

```json
// packages/api/package.json
{
 "name": "@myapp/api",
 "dependencies": {
 "@myapp/db": "workspace:*",
 "@myapp/types": "workspace:*"
 }
}
```

When Claude Code modifies shared types, remind it to check dependents:

```
After changing types in packages/types, run:
pnpm --filter "@myapp/*" run build
to verify no downstream packages break.
```

### Step 7: Scope Claude Code sessions to one package

For focused work, start Claude Code in the package directory:

```bash
cd packages/api
claude
```

Or tell Claude Code to focus:

```
I'm working in packages/api only. Do not read or modify files
in other packages unless I specifically ask.
```

## Context Management Tips

Large monorepos can overwhelm Claude Code's context window. Use these strategies:

1. **Work in one package at a time**: Focus on `packages/api` for a session, then `packages/web`
2. **Use subagents for cross-package exploration**: Delegate search tasks to keep your main context clean
3. **Keep shared types small**: Large type files imported everywhere bloat context
4. **Use barrel exports**: Each package's `index.ts` shows what is available without reading internal files

## Prevention

Structure your monorepo for Claude Code success from the start. Clear package boundaries, explicit dependency rules, and per-package CLAUDE.md files ensure Claude Code always knows where it is and what tools to use.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-monorepo-setup-guide)**

</div>

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-monorepo-setup-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

- [Claude Code CLAUDE.md Best Practices](/claude-code-claude-md-best-practices/)
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/)
- [Claude Code Subagents Guide](/claude-code-subagents-guide/)

## See Also

- [Claude Code Monorepo: Best Setup Guide (2026)](/claude-code-monorepo-best-setup-2026/)
- [Claude Code Monorepo Workspace Resolution Failure — Fix (2026)](/claude-code-monorepo-workspace-resolution-failure-fix/)
- [Monorepo Workspace Package Resolution — Fix (2026)](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
