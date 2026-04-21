---
layout: post
title: "Claude Code CLAUDE.md Best Practices for Teams 2026"
description: "Write effective CLAUDE.md files for team projects. Conventions, style guides, tool permissions, and shared context patterns that scale."
permalink: /claude-code-claude-md-best-practices-teams-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Create and maintain CLAUDE.md files that work for entire engineering teams, not just individual developers. This covers file structure, convention enforcement, tool permissions, and scaling patterns for monorepos and multi-team organizations.

Expected time: 30-45 minutes for initial setup
Prerequisites: Claude Code installed, a shared repository, team agreement on coding conventions

## Setup

### 1. Create the Root CLAUDE.md

```bash
touch CLAUDE.md
```

The root CLAUDE.md applies to every Claude Code session in the repository.

### 2. Establish the File Structure

```
your-project/
├── CLAUDE.md                    # Root: project-wide rules
├── packages/
│   ├── frontend/
│   │   └── CLAUDE.md            # Frontend-specific conventions
│   └── backend/
│       └── CLAUDE.md            # Backend-specific conventions
└── .claude/
    └── settings.json            # Tool permissions and restrictions
```

Claude Code loads CLAUDE.md files from the working directory upward to the project root. More specific files override general ones.

### 3. Verify Claude Reads Your CLAUDE.md

```bash
claude --print "What project conventions are you following?"
# Expected output:
# Should reference rules from your CLAUDE.md
```

## Usage Example

Here is a production CLAUDE.md for a full-stack TypeScript project with 8 developers:

```markdown
# CLAUDE.md — Acme Platform

## Project Overview
E-commerce platform. Next.js 14 frontend, Express.js API, PostgreSQL with Prisma ORM.
Monorepo managed by Turborepo. CI/CD via GitHub Actions.

## Absolute Rules (never violate)
- NEVER modify files in /migrations/ without explicit user request
- NEVER commit .env files or log secrets
- NEVER use `any` type in TypeScript — use `unknown` and narrow
- NEVER delete tests — mark as .skip with a TODO comment explaining why
- ALL database changes require a Prisma migration file

## Code Style
- TypeScript strict mode (tsconfig strict: true)
- Functions: max 50 lines, single responsibility
- Naming: camelCase for variables/functions, PascalCase for types/components
- Imports: absolute paths using @/ alias, grouped (external, internal, relative)
- Error handling: custom AppError class, never throw raw strings
- Comments: only for "why", never for "what" — code should be self-documenting

## File Conventions
- Components: src/components/[Feature]/[Component].tsx + [Component].test.tsx
- API routes: src/api/v1/[resource]/[resource].router.ts
- Types: co-located with module, shared types in src/types/
- Tests: co-located with source file, suffix .test.ts or .test.tsx

## Git Conventions
- Branch names: feat/, fix/, chore/ prefix
- Commit messages: conventional commits (feat:, fix:, docs:, refactor:)
- PR size: max 400 lines changed — split larger changes

## Testing Requirements
- New features: minimum 1 unit test and 1 integration test
- Bug fixes: add a regression test that fails without the fix
- Test framework: Vitest for unit, Playwright for E2E
- Coverage: maintain 80% line coverage — never decrease

## API Design
- REST endpoints follow: GET /resource, POST /resource, PATCH /resource/:id
- Response envelope: { data, meta, errors }
- Pagination: cursor-based, never offset-based
- Validation: zod schemas for all request bodies

## Database
- Prisma schema is source of truth
- Column names: snake_case
- Every table needs: id (UUID), created_at, updated_at
- Soft deletes: deleted_at column, never hard delete user data

## What NOT to do (common Claude mistakes in this codebase)
- Do not add console.log — use the logger service at src/lib/logger.ts
- Do not create new utility files — check src/lib/ first for existing helpers
- Do not refactor unrelated code when fixing a bug
- Do not add dependencies without checking package.json first
```

For the frontend sub-package:

```markdown
# packages/frontend/CLAUDE.md

## Frontend-Specific Rules
Extends root CLAUDE.md with frontend conventions.

## Component Patterns
- Use server components by default (Next.js App Router)
- Add "use client" only when state or browser APIs are needed
- Props: destructure in function signature, define interface above component
- Styling: Tailwind CSS only, no inline styles, no CSS modules
- Images: always use next/image with width, height, and alt text

## State Management
- Server state: TanStack Query with query keys in src/lib/query-keys.ts
- Client state: Zustand stores in src/stores/
- Form state: React Hook Form + zod resolver
- URL state: nuqs for search params

## Performance
- Lazy load below-fold components with dynamic()
- Memoize expensive computations with useMemo
- Never fetch data in layout.tsx — use page.tsx or parallel routes
```

Set tool permissions in `.claude/settings.json`:

```json
{
  "permissions": {
    "allowedTools": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(npx prisma*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)"
    ],
    "disallowedTools": [
      "Bash(rm -rf*)",
      "Bash(git push*)",
      "Bash(git reset --hard*)",
      "Bash(npx prisma migrate deploy*)"
    ]
  }
}
```

## Common Issues

- **CLAUDE.md too long, Claude forgets rules:** Keep it under 300 lines. Move detailed patterns into sub-package CLAUDE.md files. Use the [CLAUDE.md length optimization guide](/claude-md-length-optimization/) for trimming strategies.
- **New team members override with personal settings:** Personal `~/.claude/` settings take precedence over project settings. Document this in onboarding and have developers remove conflicting personal CLAUDE.md entries.
- **Conflicting rules between root and sub-package:** Sub-package rules win for files in that directory. If rules genuinely conflict, the more specific file takes precedence. See the [conflicting instructions resolution guide](/claude-md-conflicting-instructions-resolution-guide/).

## Why This Matters

A shared CLAUDE.md eliminates the "works on my machine" problem for AI-assisted development. Every developer gets the same Claude behavior, producing consistent code across the entire team.

## Related Guides

- [CLAUDE.md Length Optimization: 300 Lines](/claude-md-length-optimization/)
- [CLAUDE.md Conflicting Instructions Resolution Guide](/claude-md-conflicting-instructions-resolution-guide/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
