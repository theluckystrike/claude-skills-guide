---
layout: default
title: "Fix Claude Code Not Understanding (2026)"
description: "Fix Claude Code not understanding your codebase by configuring CLAUDE.md with architecture maps, key file paths, and project conventions."
permalink: /claude-code-doesnt-understand-codebase-fix-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Fix Claude Code Not Understanding Your Codebase (2026)

You ask Claude Code to modify your authentication flow, and it creates a brand-new auth module instead of editing the one that already exists. Or it suggests Express patterns when your project uses Fastify. This happens because Claude Code starts each session with zero knowledge of your specific architecture.

## The Problem

Claude Code enters every session without knowing:
- Which frameworks and libraries your project actually uses
- Where key files live in your directory structure
- What naming conventions your team follows
- How modules connect to each other

Without this context, Claude Code guesses. And guesses are wrong often enough to waste significant time.

## Root Cause

Claude Code reads files on demand but does not automatically scan your entire repository at session start. It relies on what you tell it and what it discovers through tool calls. For large codebases (500+ files), the model cannot hold the full picture in its context window.

The result: Claude Code treats your project like a greenfield app and suggests patterns that conflict with your actual architecture.

## The Fix

Create a `CLAUDE.md` file in your project root that acts as a persistent architecture map. The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo (72K+ stars) provides a proven template built on four principles: Don't Assume, Don't Hide Confusion, Surface Tradeoffs, and Goal-Driven Execution.

Pair this with the [claude-code-templates](https://github.com/davila7/claude-code-templates) collection, which provides 600+ pre-built agent configurations including codebase-aware templates.

### Step 1: Map Your Architecture

Create `CLAUDE.md` in your project root:

```markdown
# Project: MyApp

## Architecture
- Framework: Next.js 14 (App Router, NOT Pages Router)
- Database: PostgreSQL via Prisma ORM (schema at prisma/schema.prisma)
- Auth: NextAuth.js v5 (config at src/lib/auth.ts)
- State: Zustand stores in src/stores/

## Key Directories
- src/app/ — Route handlers and pages
- src/components/ — Shared React components
- src/lib/ — Utility functions and configs
- src/services/ — Business logic layer
- prisma/ — Database schema and migrations

## Conventions
- All API routes return { data, error } shape
- Components use .tsx extension, utilities use .ts
- Database queries go through src/services/, never called directly from routes
```

### Step 2: Add Dependency Context

```markdown
## Dependencies (DO NOT add alternatives)
- HTTP client: ky (NOT axios, NOT fetch wrapper)
- Validation: zod (NOT joi, NOT yup)
- Testing: vitest + @testing-library/react
- CSS: Tailwind CSS v4 (NOT styled-components)
```

### Step 3: Add File Relationship Map

```markdown
## How Modules Connect
- Routes (src/app/) → Services (src/services/) → Prisma Client
- Components import from @/components (path alias)
- All env vars defined in src/lib/env.ts with zod validation
```

## CLAUDE.md Code to Add

Combine the above sections into a single file. Use the Karpathy principle of "Don't Assume" by being explicit about what NOT to do:

```markdown
## Anti-Patterns (DO NOT)
- Do NOT create new utility files if one exists in src/lib/
- Do NOT use default exports (we use named exports everywhere)
- Do NOT add middleware — we handle cross-cutting concerns in src/lib/middleware.ts
- Do NOT suggest MongoDB — this is a PostgreSQL project
```

## Verification

After creating your `CLAUDE.md`, test it:

1. Start a new Claude Code session
2. Ask: "Where is the auth configuration in this project?"
3. Claude Code should reference `src/lib/auth.ts` without searching
4. Ask: "Add a new API endpoint for user preferences"
5. Claude Code should place it in `src/app/api/` and use the service layer pattern

If Claude Code still guesses wrong, your `CLAUDE.md` needs more specificity in the areas where it failed.

## Prevention

Keep your `CLAUDE.md` updated as your project evolves. The [claude-code-docs](https://github.com/ericbuess/claude-code-docs) repo includes an auto-update hook that can remind you when project structure changes.

Add a quarterly review to your sprint cycle:
- Check that listed directories still exist
- Verify framework versions are current
- Update convention rules that have changed

For a deeper look at CLAUDE.md patterns, see our [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). For the full ecosystem of tools that improve Claude Code's project awareness, check the [Claude Code best practices overview](/karpathy-skills-vs-claude-code-best-practices-2026/). You can also browse available [skills and plugins](/claude-skills-directory-where-to-find-skills/) that add persistent project memory.

## See Also

- [Make Claude Code Explain Its Changes (2026)](/claude-code-doesnt-explain-changes-fix-2026/)
- [Make Claude Code Write Documentation (2026)](/claude-code-doesnt-write-docs-fix-2026/)
- [Make Claude Code Handle Edge Cases (2026)](/claude-code-doesnt-handle-edge-cases-fix-2026/)
- [Make Claude Code Read Existing Code First (2026)](/claude-code-doesnt-read-existing-code-fix-2026/)
- [Make Claude Code Match Team Conventions (2026)](/claude-code-doesnt-match-team-conventions-fix-2026/)
- [Fix Claude Code Misunderstanding Requirements (2026)](/claude-code-misunderstands-requirements-fix-2026/)
