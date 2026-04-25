---
layout: default
title: "Claude Skills for Monorepo Projects (2026)"
description: "Configure Claude Code skills in monorepos with nested .claude/skills/ directories, package-scoped activation, and cross-package orchestration."
permalink: /claude-skills-for-monorepo-projects/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, monorepo, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

Your monorepo has 12 packages: `packages/api`, `packages/web`, `packages/mobile`, `packages/shared`, and 8 others. The API package needs a "REST endpoint generator" skill, the web package needs a "React component scaffold" skill, and the shared package needs a "schema validator" skill. Root-level skills like "deploy" and "PR review" apply to all packages. You need skills that activate only when working in their specific package, plus root skills that work everywhere.

## Technical Foundation

Claude Code supports automatic nested discovery. When you work with files in subdirectories, Claude discovers skills from nested `.claude/skills/` directories in those subdirectories. This means `packages/api/.claude/skills/` and `packages/web/.claude/skills/` are discovered independently when you touch files in those packages.

Root-level skills at `.claude/skills/` apply to the entire project. The `paths` field in each skill's frontmatter further restricts when a skill activates within its scope. Combined with CLAUDE.md files that also support subdirectory loading, you get a complete per-package customization system.

The `--add-dir` flag grants file access to additional directories. Skills in an added directory's `.claude/skills/` are loaded automatically as a special exception.

## The Working SKILL.md

Monorepo directory structure:

```
monorepo/
  .claude/
    skills/
      deploy/SKILL.md           # Root: applies to all packages
      pr-review/SKILL.md        # Root: applies to all packages
  packages/
    api/
      .claude/
        skills/
          rest-endpoint/SKILL.md  # Package-scoped: API only
          db-migration/SKILL.md   # Package-scoped: API only
    web/
      .claude/
        skills/
          component-scaffold/SKILL.md  # Package-scoped: Web only
          storybook-gen/SKILL.md       # Package-scoped: Web only
    shared/
      .claude/
        skills/
          schema-validator/SKILL.md    # Package-scoped: Shared only
```

Package-scoped skill at `packages/api/.claude/skills/rest-endpoint/SKILL.md`:

```yaml
---
name: rest-endpoint
description: >
  Generate REST API endpoints for the API package. Creates route handler,
  validation schema, service layer function, and integration test.
  Use when adding new API endpoints to packages/api.
paths:
  - "packages/api/src/**/*"
allowed-tools: Read Bash(node *)
---

# REST Endpoint Generator

## Inputs
- Resource name: $ARGUMENTS[0] (e.g., "users", "orders")
- HTTP method: $ARGUMENTS[1] (GET, POST, PUT, DELETE)

## Generated Files
1. `packages/api/src/routes/{resource}.ts` — Route handler
2. `packages/api/src/schemas/{resource}.ts` — Zod validation schema
3. `packages/api/src/services/{resource}.ts` — Business logic
4. `packages/api/tests/routes/{resource}.test.ts` — Integration test

## Conventions (packages/api specific)
- Route files export a Fastify plugin function
- Schemas use Zod with .openapi() annotation for Swagger docs
- Services accept validated input, return typed output
- Tests use supertest with test database fixture

## Cross-Package References
- Import shared types from `@monorepo/shared`
- Import shared validation from `@monorepo/shared/schemas`
- Never import directly from packages/web or packages/mobile
```

Root-level cross-package skill at `.claude/skills/deploy/SKILL.md`:

```yaml
---
name: deploy
description: >
  Deploy one or more packages from the monorepo. Handles dependency
  ordering, build verification, and deployment sequencing.
  Invoke with: /deploy [package-name|all]
disable-model-invocation: true
allowed-tools: Bash(pnpm *) Bash(npm *) Bash(node *)
---

# Monorepo Deploy Skill

## Package Dependency Order
Deploy in this sequence (dependencies first):
1. packages/shared (no dependencies)
2. packages/api (depends on shared)
3. packages/web (depends on shared)
4. packages/mobile (depends on shared)

## Pre-Deploy Checks
For each package being deployed:
1. Run `pnpm --filter {package} build` — must succeed
2. Run `pnpm --filter {package} test` — must pass
3. Check `packages/{name}/CHANGELOG.md` for unreleased entries
4. Verify no uncommitted changes in the package directory

## Deploy Commands
- shared: `pnpm --filter @monorepo/shared publish`
- api: `pnpm --filter @monorepo/api deploy:production`
- web: `pnpm --filter @monorepo/web deploy:vercel`
- mobile: `pnpm --filter @monorepo/mobile build:release`
```

## Common Problems and Fixes

**Package skill not discovered.** Nested `.claude/skills/` discovery requires Claude to be working with files in that subdirectory. If you start a session and immediately type `/rest-endpoint`, Claude may not have discovered it yet because no files in `packages/api/` have been touched. Open a file in the package first, or use the root-level deploy skill to reference it.

**Root skill conflicts with package skill.** If the root has a skill named `test` and `packages/api` also has a skill named `test`, the nested version activates when working in that package. This is usually the desired behavior, but it can be confusing. Use distinct names to avoid ambiguity.

**Cross-package imports not validated.** A skill in `packages/web` references types from `@monorepo/shared`, but the import path is wrong. Add a validation step: "Verify that all cross-package imports use the workspace alias (`@monorepo/shared`) and not relative paths (`../../shared/`)."

**Nested skills directory not detected on first session.** If you create a new `packages/newpkg/.claude/skills/` directory during a session, Claude Code may not detect it until session restart. The top-level `.claude/skills/` must exist at session start for live detection to work on new subdirectories.

## Production Gotchas

Monorepo skill directories multiply quickly. With 12 packages each having 2-3 skills, plus root skills, you can easily reach 30+ skills. Each skill's description (up to 1,536 chars) counts toward the context budget. Use `disable-model-invocation: true` on deployment and administrative skills, and `user-invocable: false` on reference-only skills to keep the description budget under control.

The `--add-dir` flag for accessing skills from external directories creates an exception: `.claude/skills/` within an added directory is loaded automatically. This is useful for monorepos where a shared skill package lives outside the main project directory.

## Checklist

- [ ] Root skills apply to all packages (deploy, PR review, CI)
- [ ] Package skills scoped with `paths` to their package directory
- [ ] Cross-package imports use workspace aliases, not relative paths
- [ ] Skill description budget managed (disable-model-invocation on admin skills)
- [ ] New `.claude/skills/` directories documented for session restart requirement

## Related Guides

- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- sharing resources across package skills
- [Claude Skill Registry Pattern for Teams](/claude-skill-registry-pattern-for-teams/) -- tracking all skills across the monorepo
- [Claude Skill Inheritance and Composition](/claude-skill-inheritance-composition/) -- extending root skills in packages

## Related Articles

- [Claude Code Skills Monorepo Management Workflow](/claude-code-skills-monorepo-management-workflow/)
- [Claude Skills vs Claude AI Projects — When to Use Code Skills vs Web-Based Project Instructions — 20](/claude-skills-vs-claude-ai-projects/)
