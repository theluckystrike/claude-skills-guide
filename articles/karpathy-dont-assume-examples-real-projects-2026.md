---
layout: default
title: "Karpathy Don't Assume (2026)"
description: "See Karpathy's Don't Assume principle in real codebases — API projects, React apps, CLI tools, and monorepos with exact CLAUDE.md rules."
permalink: /karpathy-dont-assume-examples-real-projects-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Karpathy Don't Assume: Real Project Examples (2026)

Abstract principles only stick when you see them in context. Here are four real-world applications of the Don't Assume principle across different project types, with the exact CLAUDE.md rules used and the behavior change they produced.

## The Principle

Don't Assume: when the codebase or explicit instructions don't dictate the answer, ask instead of guessing. See the [full principle guide](/karpathy-dont-assume-principle-claude-code-2026/) for background.

## Why It Matters

Every project type has different assumption traps. An API project's dangerous assumptions (database choice, auth strategy) differ from a React app's (state management, routing pattern). The CLAUDE.md rules need to be project-specific to be effective.

## Example 1: Express API with PostgreSQL

### Project Context
REST API, Express.js, PostgreSQL with Drizzle ORM, deployed on Railway.

### Dangerous Assumptions Claude Code Made (Before)
- Added Prisma instead of Drizzle for a new model
- Created REST endpoints when the team was migrating to tRPC
- Used `pg` driver directly instead of going through Drizzle
- Added bcrypt for a new hashing need when the project uses argon2

### CLAUDE.md Rules

```markdown
## Don't Assume — API Project Rules
- ORM: Drizzle ONLY. Do not suggest or use Prisma, TypeORM, Knex, or raw pg.
- API style: tRPC for new endpoints. Existing REST endpoints stay as-is.
- Auth: argon2 for hashing, jose for JWT. No bcrypt, no jsonwebtoken.
- Migrations: drizzle-kit generate → drizzle-kit push. Never hand-write SQL migrations.
- When a new feature could use an existing service or a new one, ask which approach is preferred.
```

### Behavior After
Claude Code now asks before touching ORM-related code and follows the Drizzle pattern without prompting. New endpoint requests get a confirmation: "I'll create this as a tRPC procedure. Confirm?"

## Example 2: Next.js SaaS Application

### Project Context
Next.js App Router, Tailwind CSS, Supabase auth, Stripe billing.

### Dangerous Assumptions Claude Code Made (Before)
- Used Pages Router patterns in an App Router project
- Added `use client` to every component (should be Server Components by default)
- Created API routes when server actions would work
- Used `fetch` in `useEffect` instead of Server Component data fetching

### CLAUDE.md Rules

```markdown
## Don't Assume — Next.js Rules
- ALWAYS use App Router patterns. Never use Pages Router (getServerSideProps, etc.)
- Components are Server Components by default. Add 'use client' ONLY when the component needs useState, useEffect, event handlers, or browser APIs.
- Data fetching goes in Server Components using async/await. No useEffect for data fetching.
- Server Actions for mutations, not API routes (unless the endpoint needs to be called from outside Next.js).
- Styling: Tailwind utility classes only. No CSS modules, no styled-components, no inline styles.
- When a new page needs auth, ask whether it should use middleware auth or component-level auth.
```

### Behavior After
Claude Code defaults to Server Components and only adds `use client` when it detects state or effect usage. Data fetching happens at the component level in async functions instead of useEffect calls.

## Example 3: Python CLI Tool

### Project Context
Python 3.12, Click for CLI, Rich for output formatting, Poetry for dependencies.

### Dangerous Assumptions Claude Code Made (Before)
- Used argparse instead of Click
- Added print() calls instead of Rich console output
- Created pip requirements.txt instead of updating pyproject.toml
- Used os.path instead of pathlib

### CLAUDE.md Rules

```markdown
## Don't Assume — Python CLI Rules
- CLI framework: Click. Not argparse, not typer, not fire.
- Output: Rich console (console.print, Table, Panel). Never raw print().
- Paths: pathlib.Path everywhere. No os.path.
- Dependencies: Poetry (pyproject.toml). No requirements.txt, no setup.py.
- Python version: 3.12+. Use match/case, | union types, tomllib.
- When adding a new command group, ask about naming convention and help text style.
```

### Behavior After
New commands follow Click patterns automatically. Output uses Rich tables and panels. Paths use pathlib consistently. No more os.path leaking in.

## Example 4: Monorepo with Multiple Packages

### Project Context
Turborepo monorepo with 4 packages: api, web, shared, cli. pnpm workspaces.

### Dangerous Assumptions Claude Code Made (Before)
- Added dependencies to root package.json instead of the specific package
- Imported from relative paths between packages instead of using workspace imports
- Created files in the wrong package directory
- Used different TypeScript configs per package without checking existing tsconfig

### CLAUDE.md Rules

```markdown
## Don't Assume — Monorepo Rules
- Dependencies go in the SPECIFIC package, not root. Use: pnpm add <pkg> --filter <workspace>
- Cross-package imports use workspace names: import { x } from '@myorg/shared'
- NEVER use relative paths between packages (../../shared/...)
- Each package has its own tsconfig.json extending the root. Don't modify root tsconfig.
- When a change touches multiple packages, list which packages are affected and confirm scope.
- When adding shared code, ask: does this belong in @myorg/shared or is it package-specific?
```

### Behavior After
Claude Code correctly scopes dependencies to packages and uses workspace imports. Before cross-package changes, it lists affected packages and asks for confirmation.

## Common Mistakes

1. **Rules too generic** — "Don't assume the tech stack" doesn't help when the project has 5 different patterns. Be specific about each technology choice.

2. **Not updating rules as the project evolves** — rules written on day 1 become stale. Review and update monthly.

3. **Copying rules between projects** — the Express API rules don't apply to the Next.js app. Each project needs its own assumption boundaries.

4. **Forgetting about the exceptions** — in all four examples above, established patterns DON'T need confirmation. If every component in your React app uses Tailwind, Claude Code shouldn't ask "should I use Tailwind?" for each new component.

## Related Principles

- [Implement Don't Assume in CLAUDE.md](/karpathy-dont-assume-implementation-claude-md-2026/) — the template for these rules
- [Debug When Claude Code Assumes Wrong](/karpathy-dont-assume-debugging-failures-2026/) — fixing assumption failures
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — broader patterns
- [Karpathy Skills Complete Guide](/karpathy-claude-code-skills-complete-guide-2026/) — all four principles
