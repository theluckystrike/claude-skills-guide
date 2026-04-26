---
layout: default
title: "CLAUDE.md for Teams: Standards That Actually Work (2026)"
description: "Set up team-wide CLAUDE.md standards with per-team overrides, shared coding conventions, and review rules that keep 10+ developers consistent."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-md-for-teams-standards-guide/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, claude-md, teams, standards, collaboration]
---

# CLAUDE.md for Teams: Standards That Actually Work

A solo developer's CLAUDE.md is simple -- one file, one set of preferences. Teams are different. Ten developers with ten CLAUDE.md files produce ten different coding styles, and Claude faithfully follows each one. The fix is a hierarchical CLAUDE.md structure: shared standards at the root, team-specific overrides in subdirectories, and personal preferences in `.claude/`. Generate your team's base config with the [CLAUDE.md Generator](/generator/), then build the hierarchy from there.

## The Three-Layer Hierarchy

Claude Code reads CLAUDE.md files from three locations and merges them:

```
company-monorepo/
├── CLAUDE.md                    # Layer 1: Org-wide standards
├── .claude/
│   └── CLAUDE.md                # Layer 3: Personal (gitignored)
├── apps/
│   ├── frontend/
│   │   └── CLAUDE.md            # Layer 2: Team/package override
│   └── api/
│       └── CLAUDE.md            # Layer 2: Team/package override
└── packages/
    └── shared/
        └── CLAUDE.md            # Layer 2: Team/package override
```

**Layer 1 (root)** loads on every session. It contains non-negotiable standards -- things every developer and every Claude session must follow regardless of which part of the codebase they're working in.

**Layer 2 (directory)** adds context when working in that directory. The frontend team's CLAUDE.md adds React-specific rules; the API team's adds database and endpoint conventions.

**Layer 3 (personal)** lives in `.claude/CLAUDE.md`, is gitignored, and holds individual preferences like editor shortcuts, personal debugging workflows, or experimental features.

## Layer 1: The Org-Wide CLAUDE.md

This file is committed to the repo root and reviewed like any other code. Every team member sees it, every Claude session loads it:

```markdown
# Organization: Acme Corp

## Tech Stack
- Language: TypeScript (strict mode, no any)
- Runtime: Node.js 22 LTS
- Package manager: pnpm (never npm or yarn)
- Monorepo: Turborepo with pnpm workspaces

## Universal Rules
- All functions must have JSDoc comments with @param and @returns
- No console.log in committed code (use structured logger)
- Maximum file length: 300 lines
- Maximum function length: 50 lines
- All exported functions need unit tests
- Use absolute imports via @/ alias

## Git Conventions
- Commit format: type(scope): description
  - Types: feat, fix, refactor, test, docs, chore
  - Scope: package name (e.g., feat(api): add user endpoint)
- Branch format: type/TICKET-123-short-description
- Never force push to main or develop

## Security
- Never commit secrets, API keys, or credentials
- Use environment variables for all configuration
- Validate all external input at system boundaries
- SQL queries must use parameterized queries (never string concat)

## Code Review Requirements
- All changes need at least one approval
- Tests must pass before merge
- No TODO comments without a linked ticket number
```

This root CLAUDE.md runs about 40 lines and covers what 90% of team arguments are about: naming, formatting, git conventions, and security basics. When Claude follows these rules, every PR looks like it came from the same team.

## Layer 2: Team-Specific Overrides

Each team or package adds its own CLAUDE.md that extends (never contradicts) the root:

**Frontend team** (`apps/frontend/CLAUDE.md`):

```markdown
# Frontend Application
Tech: React 19, Next.js 15, TanStack Query, Tailwind CSS

## Component Rules
- One component per file
- Props interface named {ComponentName}Props
- Use server components by default, add "use client" only when needed
- Tailwind classes only -- no CSS modules or styled-components
- All interactive components need aria-label or aria-labelledby

## State Management
- Server state: TanStack Query (never useState for API data)
- Client state: Zustand (for UI state that spans components)
- URL state: nuqs (for filters, pagination, search)

## Testing
- Component tests: Testing Library + Vitest
- Run: `pnpm --filter frontend test`
- Test user behavior, not implementation details
```

**API team** (`apps/api/CLAUDE.md`):

```markdown
# API Server
Tech: Hono, Drizzle ORM, PostgreSQL, Redis

## Endpoint Rules
- Route handlers do validation + response only
- Business logic goes in /services (never in route files)
- Database queries go in /repositories
- Every endpoint returns typed response: { data: T } or { error: string }

## Database
- Migrations via drizzle-kit (never manual SQL)
- All queries use Drizzle query builder (no raw SQL)
- Add indexes for any column used in WHERE clauses
- Foreign keys are mandatory for all relationships

## Testing
- Integration tests hit a real test database
- Run: `pnpm --filter api test`
- Seed data in beforeAll, clean in afterAll
```

## Personal Preferences (Layer 3)

The `.claude/CLAUDE.md` file is gitignored and holds individual preferences:

```markdown
# Personal Preferences (Mike)
- When suggesting changes, show the full file diff
- Use verbose variable names (I prefer readability over brevity)
- Always run tests after making changes
- Explain architectural decisions in comments when the reasoning
  is not obvious from the code
- I prefer early returns over nested if/else
```

These preferences never override team standards. They add context about how a specific developer works best with Claude.

## Handling Conflicts

When two layers disagree, Claude Code uses the most specific one. If the root says "maximum function length: 50 lines" and a package CLAUDE.md says "maximum function length: 30 lines", the package rule wins when working in that package. Design your hierarchy to avoid conflicts:

1. Root CLAUDE.md sets **minimums** (e.g., "at least" not "exactly")
2. Package CLAUDE.md **tightens** standards (stricter is fine, looser is not)
3. Personal CLAUDE.md adds **preferences** (style, not substance)

## Onboarding New Team Members

A well-structured CLAUDE.md hierarchy replaces half of your onboarding docs. New developers clone the repo, start Claude Code, and immediately get sessions that follow team conventions. No reading a 50-page style guide. No learning by trial and PR rejection.

Add an onboarding section to your root CLAUDE.md:

```markdown
## New Developer Setup
1. Clone repo and run `pnpm install`
2. Copy .env.example to .env and fill in values
3. Run `pnpm db:migrate` to set up local database
4. Run `pnpm dev` to start all services
5. Run `pnpm test` to verify everything works
```

## Try It Yourself

Start with the [CLAUDE.md Generator](/generator/) to create your root org-wide CLAUDE.md. It handles the structure -- project overview, commands, architecture mapping -- and you fill in the team-specific rules. Then create package-level CLAUDE.md files for each team. Within two weeks, your PRs will look like they came from one well-coordinated team instead of ten individuals using the same AI.

<details>
<summary>How do I enforce that everyone uses the root CLAUDE.md?</summary>
Commit it to the repo root and add it to your CODEOWNERS file so changes require team lead approval. Since Claude Code reads it automatically, there is no way to skip it during a session -- it loads before the first message.
</details>

<details>
<summary>What if team members want to override organization rules?</summary>
Personal CLAUDE.md files in .claude/ can add preferences but should not contradict org rules. If a rule does not work for a specific team, update the package-level CLAUDE.md with a documented exception and get it approved in code review.
</details>

<details>
<summary>How many lines should a team CLAUDE.md be?</summary>
Root: 30-50 lines. Package-level: 20-40 lines. Personal: 5-15 lines. The total loaded context stays under 200 lines, keeping token overhead below 1,200 tokens per session.
</details>

<details>
<summary>Should we version control all CLAUDE.md files?</summary>
Version control root and package-level CLAUDE.md files. Gitignore personal .claude/CLAUDE.md files. This ensures team standards are reviewed and approved while allowing individual preferences to stay private.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How do I enforce that everyone uses the root CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Commit it to the repo root and add it to your CODEOWNERS file so changes require team lead approval. Since Claude Code reads it automatically, there is no way to skip it during a session -- it loads before the first message."
      }
    },
    {
      "@type": "Question",
      "name": "What if team members want to override organization rules?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Personal CLAUDE.md files in .claude/ can add preferences but should not contradict org rules. If a rule does not work for a specific team, update the package-level CLAUDE.md with a documented exception and get it approved in code review."
      }
    },
    {
      "@type": "Question",
      "name": "How many lines should a team CLAUDE.md be?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Root: 30-50 lines. Package-level: 20-40 lines. Personal: 5-15 lines. The total loaded context stays under 200 lines, keeping token overhead below 1,200 tokens per session."
      }
    },
    {
      "@type": "Question",
      "name": "Should we version control all CLAUDE.md files?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Version control root and package-level CLAUDE.md files. Gitignore personal .claude/CLAUDE.md files. This ensures team standards are reviewed and approved while allowing individual preferences to stay private."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

- [CLAUDE.md Generator](/generator/) -- Build your team's base CLAUDE.md configuration
- [Claude Code Permissions Guide](/permissions/) -- Control what Claude can and cannot do
- [Claude Code Best Practices](/best-practices/) -- Production patterns for teams
- [Claude Code Configuration Guide](/configuration/) -- All config options explained
- [Claude Code Starter Guide](/starter/) -- Get new team members started fast
