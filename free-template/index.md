---
layout: default
title: "Free CLAUDE.md Template for Production Projects"
description: "Download a production-ready CLAUDE.md template for Next.js and TypeScript projects. Includes coding conventions, file structure, testing requirements, and git commit rules."
date: 2026-04-15
last_modified_at: 2026-04-15
categories: [guides]
tags: [claude-md, claude-code, template, nextjs, typescript, production, free]
author: "Claude Code Guides"
reviewed: true
permalink: /free-template/
---

# Free CLAUDE.md Template for Production Projects

A well-crafted CLAUDE.md file is the single most effective way to get consistent, high-quality output from Claude Code. It tells the AI exactly how your project works, what conventions to follow, and what mistakes to avoid. Without one, every session starts from scratch and you waste tokens re-explaining the same rules.

This page gives you a complete, production-grade CLAUDE.md template for a Next.js + TypeScript project. Copy it, adapt it to your stack, and drop it in your repo root. You will see the difference in your first session.

## What Is CLAUDE.md and Why Does It Matter

CLAUDE.md is a special markdown file that Claude Code reads automatically when it enters your project directory. It acts as persistent context -- project rules, conventions, file structure, and commands that the AI follows without you having to repeat them in every prompt.

Projects with a well-written CLAUDE.md consistently produce better results:

- Fewer hallucinated imports and file paths
- Consistent code style across sessions
- Correct use of your testing framework and git workflow
- Awareness of your project structure and naming conventions

For a deep dive on the format and mechanics, read the [CLAUDE.md best practices guide](/claude-code-claude-md-best-practices/).

## Template Preview

Here is a condensed look at what the full template covers:

```markdown
# Project: my-app

## Tech Stack
- Next.js 14 (App Router) + TypeScript 5.x
- Tailwind CSS + shadcn/ui
- PostgreSQL + Prisma ORM
- Vitest + Playwright

## Coding Conventions
- Functions MUST be under 60 lines
- All loops MUST have bounded iteration
- Every exported function MUST have at least 2 assertions
- No `any` types -- use `unknown` and narrow
...
```

The full template below includes every section you need.

## Full CLAUDE.md Template

Copy this entire block and save it as `CLAUDE.md` in your project root. Then customize the project name, tech stack, and file paths to match your codebase.

````markdown
# Project: my-app

> Production Next.js application with TypeScript. This file defines all
> conventions and rules that Claude Code must follow when working in this
> repository.

## Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript 5.x (strict mode enabled)
- **Styling**: Tailwind CSS 3.x + shadcn/ui components
- **Database**: PostgreSQL 16 via Prisma ORM 5.x
- **Auth**: NextAuth.js v5 (Auth.js)
- **Testing**: Vitest (unit/integration) + Playwright (e2e)
- **Package Manager**: pnpm
- **Node Version**: 20 LTS

## Coding Conventions

These rules are non-negotiable. Every piece of code generated must follow them.

### Function Size

- Every function MUST be under 60 lines of code.
- If a function exceeds 60 lines, decompose it into smaller helper functions.
- Prefer pure functions. Side effects belong at the boundary.

### Type Safety

- Never use `any`. Use `unknown` and narrow with type guards.
- Every function parameter and return value MUST have an explicit type.
- Use `satisfies` for compile-time checks on object literals.
- Prefer discriminated unions over optional properties for state modeling.

### Assertions and Validation

- Every exported function MUST include at least 2 runtime assertions.
- Use the project assert utility at `src/lib/assert.ts`.
- Validate all external input at API boundaries with Zod schemas.
- Never trust data from `params`, `searchParams`, or request bodies without validation.

### Loop Safety

- All loops MUST have a bounded iteration count.
- Use `for...of` over `for (let i = ...)` when iterating collections.
- Maximum loop depth: 2 levels. Extract inner loops into named functions.
- Prefer `.map()`, `.filter()`, `.reduce()` over manual loops when the intent is clearer.

### Error Handling

- Never silently swallow errors. Every `catch` must log or re-throw.
- Use custom error classes defined in `src/lib/errors.ts`.
- API routes must return structured error responses: `{ error: string, code: string }`.
- Database operations must be wrapped in try/catch with rollback logic.

### Naming

- Files: kebab-case (`user-profile.ts`, `auth-guard.tsx`)
- Components: PascalCase (`UserProfile.tsx` exports `UserProfile`)
- Functions/variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Types/interfaces: PascalCase with no `I` prefix

## File Structure

```
src/
  app/                    # Next.js App Router pages and layouts
    (auth)/               # Auth-required route group
    (public)/             # Public route group
    api/                  # API routes
    layout.tsx            # Root layout
    page.tsx              # Home page
  components/
    ui/                   # shadcn/ui primitives (do not edit directly)
    forms/                # Form components
    layout/               # Header, footer, sidebar, navigation
    shared/               # Reusable components used across features
  lib/
    assert.ts             # Runtime assertion utility
    errors.ts             # Custom error classes
    db.ts                 # Prisma client singleton
    auth.ts               # Auth configuration
    utils.ts              # General utilities (cn, formatDate, etc.)
  hooks/                  # Custom React hooks
  types/                  # Shared TypeScript type definitions
  schemas/                # Zod validation schemas
prisma/
  schema.prisma           # Database schema
  migrations/             # Migration history (do not edit manually)
tests/
  unit/                   # Vitest unit tests (mirror src/ structure)
  integration/            # Vitest integration tests
  e2e/                    # Playwright end-to-end tests
  fixtures/               # Shared test data
```

## Testing Requirements

### Unit Tests (Vitest)

- Every utility function in `src/lib/` MUST have a corresponding test file.
- Test file location mirrors source: `src/lib/utils.ts` -> `tests/unit/lib/utils.test.ts`.
- Minimum 3 test cases per function: happy path, edge case, error case.
- Use `describe` blocks to group related tests. Use `it` for individual cases.

### Integration Tests (Vitest)

- Every API route MUST have integration tests covering success and error responses.
- Use the test database defined in `.env.test`.
- Reset database state before each test suite with `beforeAll` + Prisma migrate reset.

### End-to-End Tests (Playwright)

- Cover critical user flows: sign up, sign in, core feature CRUD, sign out.
- Tests run against the dev server on port 3001.
- Use data-testid attributes for selectors. Never select by CSS class or text content.

### Running Tests

- All tests must pass before committing. No skipped tests in main branch.
- Run the full suite before any PR: `pnpm test && pnpm test:e2e`.

## Git Commit Conventions

- Format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`
- Scope: the feature area or module affected (e.g., `auth`, `api`, `db`, `ui`)
- Description: imperative mood, lowercase, no period at end
- Examples:
  - `feat(auth): add magic link sign-in flow`
  - `fix(api): handle null user in profile endpoint`
  - `refactor(db): extract query builders into separate module`
  - `test(auth): add integration tests for session refresh`

### Branch Naming

- `feat/short-description` for features
- `fix/short-description` for bug fixes
- `refactor/short-description` for refactoring
- Always branch from `main`. Always rebase before merging.

## Common Commands

```bash
# Development
pnpm dev                    # Start dev server on port 3000
pnpm build                  # Production build
pnpm start                  # Start production server

# Database
pnpm db:push                # Push schema changes (dev only)
pnpm db:migrate             # Create and apply migration
pnpm db:studio              # Open Prisma Studio
pnpm db:seed                # Seed development data

# Testing
pnpm test                   # Run Vitest (unit + integration)
pnpm test:unit              # Run unit tests only
pnpm test:integration       # Run integration tests only
pnpm test:e2e               # Run Playwright e2e tests
pnpm test:coverage          # Generate coverage report

# Code Quality
pnpm lint                   # ESLint check
pnpm lint:fix               # ESLint auto-fix
pnpm typecheck              # TypeScript compiler check (no emit)
pnpm format                 # Prettier format all files
```

## Environment Variables

- `.env.local` is used for development. Never commit it.
- Required variables are documented in `.env.example`.
- Access env vars through `src/lib/env.ts` which validates them with Zod at startup.
- Never access `process.env` directly in application code.

## Rules for Claude Code

1. Always read this file at the start of every session.
2. Run `pnpm typecheck` after making changes to catch type errors.
3. Run `pnpm test` after modifying any function that has tests.
4. Do not modify files in `src/components/ui/` -- these are managed by shadcn/ui.
5. Do not modify files in `prisma/migrations/` -- use `pnpm db:migrate` instead.
6. When creating new API routes, always add Zod validation and integration tests.
7. When creating new components, add them to the appropriate subdirectory and export from the barrel file.
8. Prefer editing existing files over creating new ones.
9. Ask before deleting any file.
````

## How to Use This Template

1. **Copy the template** above and save it as `CLAUDE.md` in your project root directory.
2. **Customize the project name** in the first heading.
3. **Update the tech stack** to match your actual dependencies and versions.
4. **Adjust the file structure** to reflect your real directory layout.
5. **Modify the commands** to match your package.json scripts.
6. **Add project-specific rules** -- any patterns, gotchas, or conventions unique to your codebase.

The template works immediately as-is for any Next.js + TypeScript project. For other stacks, keep the same section structure and swap the specifics.

## Customizing for Other Stacks

The section structure works for any project. Here is what to change per stack:

- **Python + Django**: Replace pnpm commands with pip/poetry, swap Vitest for pytest, update file structure for Django apps
- **Go**: Replace TypeScript conventions with Go idioms, swap testing framework, update error handling section for Go patterns
- **Ruby on Rails**: Update to Bundler commands, RSpec testing, Rails directory conventions
- **Rust**: Add cargo commands, adjust assertions section for Rust's type system and `Result` pattern

The core principles -- bounded functions, explicit types, mandatory tests, structured commits -- apply universally.

## Related Guides

- [CLAUDE.md Best Practices](/claude-code-claude-md-best-practices/) -- Advanced patterns for large and complex codebases
- [Claude Code Config File Location](/claude-code-config-file-location/) -- Where Claude Code stores settings and how to manage them
- [Permission Rules and settings.json Guide](/claude-code-permission-rules-settings-json-guide/) -- Control what Claude Code can and cannot do in your project

<div class="trust-strip">
$400K+ earned on Upwork · 100% Job Success · Top Rated Plus · 16 published extensions · 3,000+ users · Building with Claude Code since launch
</div>

## Want More Templates, Prompts, and Configs?

This free template is one of 16 production-ready CLAUDE.md templates included in the Zovo Lifetime package. The full collection covers:

- **16 CLAUDE.md templates** for different stacks: React, Vue, Python, Go, Rust, Ruby, mobile, monorepo, microservices, and more
- **80+ tested prompts** for code generation, refactoring, debugging, and code review
- **Orchestration configs** for multi-agent workflows with 5+ parallel Claude Code instances
- **Sprint playbooks** with step-by-step workflows for shipping features end-to-end

All of it is built by a developer who shipped 20+ Chrome extensions to 5,000+ users using these exact templates and workflows.

**[Get Zovo Lifetime for $99 -- yours forever](https://zovo.one/lifetime?utm_source=ccg&utm_medium=lead-magnet&utm_campaign=free-template)**
