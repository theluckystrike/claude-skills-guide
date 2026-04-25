---
layout: default
title: "Project Scaffolding with Claude Code (2026)"
description: "Use Claude Code to scaffold new projects with proper structure, configuration, testing setup, and CI/CD from templates and slash commands."
permalink: /claude-code-project-scaffolding-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Project Scaffolding with Claude Code (2026)

Starting a new project means creating dozens of files: config, folder structure, boilerplate, CI pipelines, linting, testing setup. Claude Code can scaffold all of this in minutes -- if you give it the right template.

## Why Scaffold with Claude Code?

Traditional scaffolding tools (create-react-app, create-next-app) give you a generic starting point. Claude Code gives you YOUR starting point -- configured for your team's conventions, dependencies, and architecture from day one.

## The Scaffolding Prompt

Here is a comprehensive scaffolding prompt:

```
Create a new Next.js 14 project with:

Structure:
- src/app/ — App Router pages and routes
- src/components/ui/ — Shared UI components
- src/lib/ — Core utilities and config
- src/services/ — Business logic
- src/types/ — TypeScript type definitions
- src/schemas/ — Zod validation schemas

Configuration:
- TypeScript strict mode
- ESLint with our rules (no any, explicit returns, import order)
- Prettier with single quotes, no semicolons, 2 spaces
- Vitest for testing
- Tailwind CSS v4
- pnpm as package manager

Files to create:
- CLAUDE.md with our standard template
- .claudeignore
- .github/workflows/ci.yml (lint, typecheck, test, build)
- .env.example with placeholder values
- src/lib/env.ts with Zod env validation

DO NOT:
- Install any dependencies beyond what is listed
- Create example/demo pages
- Add unnecessary middleware
```

## Scaffolding Slash Command

Create `.claude/commands/scaffold.md`:

```markdown
Scaffold a new project module based on the arguments provided.

Arguments: $ARGUMENTS

For each module, create:
1. Route handler (src/app/api/[module]/route.ts)
   - GET (list with pagination)
   - POST (create with Zod validation)
2. Route handler (src/app/api/[module]/[id]/route.ts)
   - GET (single)
   - PUT (update with Zod validation)
   - DELETE
3. Service (src/services/[module].service.ts)
   - CRUD operations via Prisma
4. Types (src/types/[module].types.ts)
   - Entity type, Create input, Update input
5. Schema (src/schemas/[module].schema.ts)
   - Zod schemas for create and update
6. Tests (src/services/[module].service.test.ts)
   - Happy path for each CRUD operation

Follow the API Response Contract from CLAUDE.md.
Match patterns from existing modules in the codebase.
```

Usage: `/scaffold users` or `/scaffold orders`

## Template Repositories

The [claude-code-templates](https://github.com/davila7/claude-code-templates) (25K+ stars) provides scaffolding templates for various project types:

```bash
npx claude-code-templates@latest
```

Categories include:
- Web applications (React, Vue, Svelte, Angular)
- APIs (Express, Fastify, Hono)
- Full-stack (Next.js, Nuxt, SvelteKit)
- Libraries (npm packages, CLIs)
- Infrastructure (Docker, Terraform)

The [awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) (107K+ stars) provides 100+ runnable templates specifically for AI/LLM applications.

## CLAUDE.md for New Projects

Every scaffolded project should include a CLAUDE.md. Here is a starter:

```markdown
# [Project Name]

## Architecture
- Framework: [framework]
- Database: [database]
- Auth: [auth strategy]
- Testing: [test runner]

## Directory Structure
- src/app/ — Routes and pages
- src/components/ — Shared components
- src/lib/ — Core utilities
- src/services/ — Business logic
- src/types/ — Type definitions

## Conventions
- TypeScript strict mode, no 'any'
- Named exports only
- Zod schemas for all validation
- Service layer between routes and database

## Dependencies — DO NOT ADD
- Use existing libraries only
- Check package.json before suggesting new packages

## Getting Started
- pnpm install
- cp .env.example .env
- pnpm dev
```

## Multi-Module Scaffolding

For larger projects, scaffold in stages:

### Stage 1: Foundation
```
"Create the project foundation: package.json, tsconfig, eslint,
prettier, vitest config, and directory structure."
```

### Stage 2: Infrastructure
```
"Add Prisma with PostgreSQL, the database schema for users and
sessions, and the initial migration."
```

### Stage 3: Core Features
```
"Scaffold the auth module: login/register routes, session management,
middleware, types, schemas, and tests."
```

### Stage 4: CI/CD
```
"Add GitHub Actions CI workflow: lint, typecheck, test, build.
Add Dockerfile for production deployment."
```

The [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars) can generate this staged plan from a PRD:

```bash
task-master parse-prd project-requirements.md
```

## Scaffolding Best Practices

### 1. Always Include Tests
Scaffolded code without tests creates technical debt from day one. Include at least one test per module.

### 2. Match Team Conventions
If you already have projects, tell Claude Code to match their patterns:
```
"Follow the same structure as our existing project at
/path/to/reference-project. Read its CLAUDE.md and package.json first."
```

### 3. Validate After Scaffolding
Run the full CI check immediately:
```bash
pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

### 4. Git Init Early
Initialize git before Claude Code starts writing files:
```bash
git init && git add -A && git commit -m "Initial scaffold"
```

This gives you a clean baseline to diff against.

## FAQ

### Should I use create-next-app or Claude Code scaffolding?
Use create-next-app for the absolute basics, then use Claude Code to customize the generated project to your conventions. Or use Claude Code entirely if you have a well-defined template.

### Can Claude Code scaffold non-JavaScript projects?
Yes. Claude Code can scaffold Python, Go, Rust, and other projects. Provide the same level of detail in your prompt about directory structure, tooling, and conventions.

### How long does scaffolding take?
A basic project scaffold (structure + config + a few modules) takes 5-10 minutes with Claude Code. A full project with 5+ modules, tests, and CI takes 20-30 minutes.

### Should I commit scaffolded code without review?
Review the generated code before committing. Check that configs are correct, dependencies are intentional, and test patterns match your standards.

For more on structuring Claude Code workflows, see [The Claude Code Playbook](/playbook/). For slash command creation, read the [skills vs hooks vs commands guide](/claude-code-skills-vs-hooks-vs-commands-2026/). For team-standard scaffolding, see the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).

## See Also

- [Claude Code Project vs Global Settings: Token Impact](/claude-code-project-vs-global-settings-token-impact/)
