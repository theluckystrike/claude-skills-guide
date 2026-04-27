---
sitemap: false
layout: default
title: "Senior Engineer CLAUDE.md Template (2026)"
description: "A battle-tested CLAUDE.md template used by senior engineers to enforce code quality, architecture patterns, and review standards in Claude Code."
permalink: /senior-engineer-claude-md-template/
date: 2026-04-20
categories: [claude-md, patterns]
tags: [claude-md, senior-engineer, template, best-practices, claude-code]
last_updated: 2026-04-19
---

## Why Senior Engineers Need a Different CLAUDE.md

Junior developers use CLAUDE.md to list build commands. Senior engineers use it to encode architectural judgment -- the kind of decisions that prevent entire categories of bugs rather than fixing individual ones. The difference between a generic CLAUDE.md and a senior engineer's version is the difference between "run npm test" and "never add a dependency without checking its bundle size impact against our 150KB budget."

This template reflects patterns used across production codebases where Claude Code handles real pull requests, not toy projects.

## The Template Structure

A senior engineer's CLAUDE.md covers five domains: project identity, architectural constraints, code quality gates, review standards, and forbidden patterns. Keep the file under 200 lines total. Anything longer reduces Claude's adherence to your instructions.

```markdown
# Project: [name]

## Identity
- Language: TypeScript 5.4, strict mode
- Runtime: Node 22 LTS
- Framework: Express 5 + Prisma 6
- Deploy target: AWS ECS Fargate

## Build & Test
- Install: pnpm install
- Test: pnpm test (must pass before any commit suggestion)
- Lint: pnpm lint --fix
- Type check: pnpm tsc --noEmit

## Architecture Constraints
- All database access goes through src/repositories/. Never import Prisma client directly in route handlers.
- API responses use src/responses/envelope.ts. Never return raw objects from controllers.
- Error handling uses src/errors/AppError.ts hierarchy. Never throw plain Error().
- Environment variables read from src/config/env.ts only. Never use process.env directly.
- Maximum function length: 40 lines. Extract helpers if exceeded.

## Code Quality Gates
- Every public function has a JSDoc comment with @param and @returns
- No any type. Use unknown + type guards when type is uncertain.
- Prefer readonly arrays and objects. Mutate only inside clearly named mutation functions.
- Imports sorted: node builtins, external packages, internal modules, relative imports.

## Forbidden Patterns
- Do NOT use console.log for production logging. Use the logger from src/lib/logger.ts.
- Do NOT add new npm packages without checking: bundle size, last publish date, weekly downloads.
- Do NOT write SQL strings. Use Prisma query builder exclusively.
- Do NOT use default exports. Named exports only.

## Review Standards
- Every PR description explains WHY, not just WHAT changed.
- Test coverage for new functions: at minimum one happy path and one error path.
- No TODO comments without a linked issue number.
```

## Why Each Section Exists

The **Identity** block prevents Claude from guessing your stack. Without it, Claude might suggest Express 4 patterns in an Express 5 project or use CommonJS syntax in an ESM codebase.

**Architecture Constraints** encode decisions that took months to establish. "All database access through repositories" prevents the scattered Prisma imports that make schema migrations painful. Listing these in CLAUDE.md means Claude enforces them on every interaction without you watching.

**Forbidden Patterns** work better than positive instructions. "Use the logger" is vague. "Do NOT use console.log" is concrete and verifiable. Claude handles negation well when the instruction is specific.

## Extending with .claude/rules/

Move file-type-specific rules out of the main CLAUDE.md into `.claude/rules/` with path patterns. This keeps your root file under the 200-line limit while adding granular control:

```markdown
# File: .claude/rules/api-routes.md
---
paths:
  - "src/routes/**/*.ts"

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

## API Route Rules
- Every route handler returns through the response envelope
- Validate request body with zod schemas from src/schemas/
- Log request duration using the middleware timer
- Return appropriate HTTP status codes: 201 for creation, 204 for deletion
```

These path-specific rules load only when Claude reads files matching the glob pattern, keeping context lean for unrelated work.

## Common Mistakes Senior Engineers Make

**Overloading the file.** Writing 400 lines of exhaustive rules defeats the purpose. Claude's adherence drops past 200 lines. Prioritize the 20 rules that prevent 80% of your bugs.

**Being too abstract.** "Write clean code" tells Claude nothing. "Functions under 40 lines, no nested ternaries, early returns over else blocks" tells it everything.

**Forgetting CLAUDE.local.md.** Your personal preferences -- debug flags, test database URLs, preferred diff format -- go in CLAUDE.local.md, not the shared CLAUDE.md. Add CLAUDE.local.md to .gitignore so team members maintain their own.

## Verification

Run `/memory` in Claude Code to verify your CLAUDE.md is loaded. You should see the file listed under project instructions. If your rules are not being followed, check for contradictions across multiple CLAUDE.md files in parent directories -- Claude concatenates all of them, and conflicting instructions produce unpredictable results.

For teams adopting this template, see the [complete CLAUDE.md guide](/claude-md-file-complete-guide-what-it-does/) for loading mechanics and the [team collaboration patterns](/claude-md-team-collaboration-best-practices/) for managing shared versus personal instructions. If you are enforcing architecture patterns specifically, the [architecture enforcement guide](/claude-md-for-enforcing-architecture-patterns/) covers advanced techniques.
