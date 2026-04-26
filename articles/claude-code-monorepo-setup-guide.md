---
layout: default
title: "Claude Code Monorepo Setup: The Right Way (2026)"
description: "Set up Claude Code for monorepos: root vs package CLAUDE.md, workspace-aware permissions, scoped MCP config, and context window strategies for large codebases."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-monorepo-setup-guide/
reviewed: true
categories: [getting-started]
tags: [claude, claude-code, monorepo, setup, configuration]
---

# Claude Code Monorepo Setup: The Right Way

Monorepos break Claude Code's default assumptions. A single project root might contain 50 packages, 500,000 lines of code, and six different programming languages. Without configuration, Claude Code reads irrelevant packages, burns through the context window, and applies wrong conventions to the wrong code. This guide covers the architecture decisions that make Claude Code effective in monorepos. Use the [Project Starter](/starter/) to generate monorepo-aware configuration files.

## The Monorepo Problem

A typical monorepo looks like this:

```
my-monorepo/
├── CLAUDE.md                    # Root config
├── .claude/settings.json        # Root permissions
├── packages/
│   ├── web/                     # Next.js frontend
│   │   ├── CLAUDE.md            # Package-specific rules
│   │   ├── src/
│   │   └── package.json
│   ├── api/                     # Express backend
│   │   ├── CLAUDE.md
│   │   ├── src/
│   │   └── package.json
│   ├── shared/                  # Shared types/utils
│   │   ├── src/
│   │   └── package.json
│   └── mobile/                  # React Native app
│       ├── CLAUDE.md
│       ├── src/
│       └── package.json
├── infra/                       # Terraform
│   └── CLAUDE.md
├── turbo.json
└── pnpm-workspace.yaml
```

Without configuration, when you ask Claude Code to "add a button component," it might:
1. Read files from all 5 packages (25,000+ tokens wasted)
2. Apply React Native patterns to the web frontend
3. Create the component in the wrong package
4. Run the wrong test command

## Root CLAUDE.md: Shared Conventions

The root CLAUDE.md defines rules that apply across all packages:

```markdown
# CLAUDE.md (root)

## Monorepo Structure
This is a pnpm workspace monorepo managed by Turborepo.
- packages/web -- Next.js 15 frontend
- packages/api -- Express/TypeScript backend
- packages/shared -- shared types and utilities
- packages/mobile -- React Native (Expo) app
- infra/ -- Terraform infrastructure

## Package Manager
pnpm (always pnpm, never npm or yarn)

## Workspace Commands
- `pnpm dev` -- start all packages in dev mode
- `pnpm build` -- build all packages (topological order)
- `pnpm test` -- test all packages
- `pnpm lint` -- lint all packages
- `pnpm -F web dev` -- start only the web package
- `pnpm -F api test` -- test only the api package

## Shared Rules (apply to ALL packages)
- TypeScript strict mode in every package
- All functions < 60 lines
- Exports through barrel files (index.ts)
- Shared types go in packages/shared, not duplicated
- Import shared code: `import { type User } from '@repo/shared'`

## IMPORTANT
- When working on a specific package, read its CLAUDE.md first.
- Do not modify packages outside the one you're working on
  unless the change is a shared type or dependency update.
- Always scope commands with -F flag: `pnpm -F <package> <cmd>`
```

## Package-Level CLAUDE.md: Specific Conventions

Each package with distinct conventions gets its own CLAUDE.md:

```markdown
# packages/web/CLAUDE.md

## Package: @repo/web
Next.js 15 App Router, Tailwind CSS v4

## Commands (scoped)
- `pnpm -F web dev` -- dev server at :3000
- `pnpm -F web test` -- Vitest tests
- `pnpm -F web build` -- production build
- `pnpm -F web lint` -- ESLint

## Rules
- Server components by default
- "use client" only for interactivity
- Tailwind only, no CSS modules
- Components in src/components/, pages in src/app/
- Import shared types: `import { type User } from '@repo/shared'`
```

```markdown
# packages/api/CLAUDE.md

## Package: @repo/api
Express 5, TypeScript, Prisma, PostgreSQL

## Commands (scoped)
- `pnpm -F api dev` -- dev server at :4000
- `pnpm -F api test` -- Jest tests
- `pnpm -F api build` -- tsc compilation
- `pnpm -F api prisma:generate` -- regenerate Prisma client

## Rules
- Controller -> Service -> Repository pattern
- All routes in src/routes/, controllers in src/controllers/
- Prisma for all DB access, no raw SQL
- Zod validation middleware on all POST/PUT endpoints
- Error handling via central error middleware
```

## Workspace-Aware Permissions

The root settings.json needs to handle commands for all packages:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(pnpm -F * test)",
      "Bash(pnpm -F * lint)",
      "Bash(pnpm -F * build)",
      "Bash(pnpm -F * dev)",
      "Bash(pnpm -F * typecheck)",
      "Bash(pnpm test)",
      "Bash(pnpm lint)",
      "Bash(pnpm build)",
      "Bash(npx turbo run *)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(wc -l *)",
      "Bash(ls *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(pnpm -F * deploy *)",
      "Bash(terraform apply *)",
      "Bash(sudo *)"
    ]
  }
}
```

The `pnpm -F *` pattern allows scoped commands for any package. Deployment and infrastructure changes are blocked.

## .claudeignore for Monorepos

A monorepo `.claudeignore` must exclude build artifacts from every package:

```bash
# .claudeignore (root)

# All package build outputs
**/node_modules/
**/dist/
**/build/
**/.next/
**/.turbo/
**/coverage/

# Lock files
pnpm-lock.yaml

# Generated code
**/prisma/generated/
**/*.tsbuildinfo

# Infrastructure state (sensitive)
infra/.terraform/
infra/*.tfstate
infra/*.tfstate.backup

# Mobile build artifacts
packages/mobile/ios/Pods/
packages/mobile/android/.gradle/
packages/mobile/android/app/build/

# Large assets
**/public/images/
**/public/fonts/
**/assets/videos/
```

## Context Window Strategies for Large Codebases

Monorepos challenge the 200K context window. These strategies keep sessions efficient:

### 1. Scope Prompts to a Single Package

```bash
# Bad: Claude reads across all packages
"Add authentication to the app"

# Good: Scoped to one package
"In packages/api/src/controllers/, add a login controller
 that validates credentials with the UserService and returns
 a JWT. Use the shared User type from @repo/shared."
```

### 2. Use the -F Flag in All Commands

```bash
# Bad: Runs all tests (reads all packages)
pnpm test

# Good: Runs only the relevant package
pnpm -F api test
```

### 3. Session Per Package

Start separate Claude Code sessions for work in different packages. Each session loads only the relevant package's context:

```bash
# Session 1: Frontend work
cd packages/web && claude
"Add a dashboard page with user stats"

# Session 2: Backend work (fresh context)
cd packages/api && claude
"Add a GET /api/stats endpoint for dashboard data"
```

### 4. Cross-Package Changes

When a change spans packages, be explicit:

```bash
# Explicit cross-package prompt
"Add a UserProfile type to packages/shared/src/types/user.ts
 with name, email, and avatarUrl fields.
 Then update packages/api/src/controllers/user.ts to return
 UserProfile from the GET /users/:id endpoint.
 Then update packages/web/src/components/UserCard.tsx to use
 the UserProfile type for its props."
```

## Scoped MCP Configuration

Different packages may need different MCP servers:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/myapp_dev"
      }
    }
  }
}
```

Only include MCP servers that are relevant to the packages you work on most. Each server adds tool definitions that consume context tokens. The [Token Estimator](/token-estimator/) can show the per-server token overhead.

## Try It Yourself

The [Project Starter](/starter/) has a monorepo mode. It scans your workspace structure, detects the package manager (pnpm/npm/yarn workspaces), identifies frameworks per package, and generates a root CLAUDE.md plus package-level CLAUDE.md files. It also creates the right `.claudeignore` and `settings.json` for your specific setup.

## Frequently Asked Questions

<details>
<summary>Which CLAUDE.md does Claude Code read in a monorepo?</summary>
Claude Code reads the CLAUDE.md closest to the current working directory, plus all parent CLAUDE.md files up to the repository root. If you run Claude Code from packages/web/, it reads packages/web/CLAUDE.md and then the root CLAUDE.md. Rules from the more specific file take precedence.
</details>

<details>
<summary>How do I prevent Claude Code from modifying other packages?</summary>
Add a rule to your root CLAUDE.md: "Do not modify packages outside the one specified in the task unless the change is a shared type or dependency." Claude Code respects this in most cases. For strict enforcement, start your session from within the specific package directory. See <a href="/permissions/">Permissions</a> for file-path restrictions.
</details>

<details>
<summary>Can Claude Code handle Nx and Turborepo build caching?</summary>
Yes. Claude Code interacts with Nx and Turborepo through their CLI commands. Add the relevant commands to your CLAUDE.md: "pnpm turbo run build --filter=web" or "npx nx run web:build". Claude Code does not need to understand the caching internals -- it just runs the commands. See <a href="/configuration/">Configuration</a> for build tool integration.
</details>

<details>
<summary>How large can a monorepo be before Claude Code struggles?</summary>
Claude Code works well with monorepos up to 500,000 lines of code if properly configured with .claudeignore and scoped prompts. Beyond that, context window limits become a bottleneck for cross-package changes. The key is never letting Claude Code read the entire codebase at once -- scope every session to 1-2 packages. The <a href="/token-estimator/">Token Estimator</a> can model your specific monorepo size.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Which CLAUDE.md does Claude Code read in a monorepo?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code reads the CLAUDE.md closest to the current working directory, plus all parent CLAUDE.md files up to the repository root. More specific files take precedence."
      }
    },
    {
      "@type": "Question",
      "name": "How do I prevent Claude Code from modifying other packages in a monorepo?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add a rule to your root CLAUDE.md and start sessions from within the specific package directory for strict enforcement."
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude Code handle Nx and Turborepo build caching?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code interacts through CLI commands. Add the relevant commands to CLAUDE.md. It does not need to understand caching internals."
      }
    },
    {
      "@type": "Question",
      "name": "How large can a monorepo be before Claude Code struggles?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works well up to 500,000 lines with proper .claudeignore and scoped prompts. Scope every session to 1-2 packages to avoid context window limits."
      }
    }
  ]
}
</script>



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

- [Project Starter](/starter/) -- Auto-generate monorepo-aware configuration
- [CLAUDE.md Generator](/generator/) -- Create per-package CLAUDE.md files
- [Configuration Guide](/configuration/) -- .claudeignore patterns for monorepos
- [Token Estimator](/token-estimator/) -- Model context usage for large codebases
- [Permissions Configurator](/permissions/) -- Workspace-scoped permission settings
