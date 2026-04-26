---
layout: default
title: "The Perfect CLAUDE.md: A Senior Engineer's Config (2026)"
description: "A complete 120-line CLAUDE.md with architecture rules, forbidden patterns, testing requirements, and performance constraints from a senior engineer."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /perfect-claude-md-senior-engineer-config/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, claude-md, senior-engineer, configuration, best-practices]
---

# The Perfect CLAUDE.md: A Senior Engineer's Config

Most CLAUDE.md files are too generic. They list the tech stack and a few commands, then wonder why Claude still produces junior-level code. A senior engineer's CLAUDE.md is opinionated -- it encodes architectural boundaries, forbidden patterns, performance constraints, and the kind of code quality rules that take years to learn. Here's a complete, annotated 120-line config built from patterns that consistently produce senior-quality output. Generate the base structure with the [CLAUDE.md Generator](/generator/) and layer these sections on top.

## The Complete Config

```markdown
# Project: Pulse Analytics Dashboard
# Senior Engineer Config — Last updated 2026-04-26

## Stack
- TypeScript 5.7 (strict, noUncheckedIndexedAccess)
- React 19 + Next.js 15 (App Router, RSC by default)
- Drizzle ORM + PostgreSQL 16
- TanStack Query v5 for server state
- Tailwind CSS 4 + shadcn/ui
- Vitest + Testing Library
- pnpm 9

## Commands
- Dev: `pnpm dev` (port 3000)
- Build: `pnpm build` (must pass with zero warnings)
- Test: `pnpm test` (Vitest, verbose)
- Test single: `pnpm test -- path/to/file.test.ts`
- Lint: `pnpm lint --fix`
- Type check: `pnpm tsc --noEmit`
- DB migrate: `pnpm drizzle-kit push`
- DB studio: `pnpm drizzle-kit studio`

## Architecture (STRICT — do not violate)
/app                → Next.js App Router pages + layouts
/app/api            → Route handlers (thin — validation + response only)
/src/components     → React components (no business logic)
/src/components/ui  → shadcn/ui primitives (never modify directly)
/src/hooks          → Custom hooks (data fetching, state machines)
/src/services       → Business logic (pure functions, no React imports)
/src/repositories   → Database queries (Drizzle only, no raw SQL)
/src/lib            → Utilities, constants, type definitions
/src/schemas        → Zod validation schemas

Data flow: Route Handler → Service → Repository → Database
           Component → Hook → TanStack Query → Service → Repository

## Forbidden Patterns (NEVER do these)
- ❌ `any` type — use `unknown` and narrow, or define proper types
- ❌ Default exports — always use named exports
- ❌ Barrel files (index.ts re-exports) — import from source directly
- ❌ CSS modules or styled-components — Tailwind only
- ❌ `useEffect` for data fetching — use TanStack Query
- ❌ Direct database calls outside /repositories
- ❌ Business logic in components or route handlers
- ❌ Mutable state where immutable works (spread, not mutate)
- ❌ console.log in production code — use structured logger
- ❌ String concatenation for SQL — parameterized queries only
- ❌ setTimeout/setInterval without cleanup
- ❌ Nested ternaries deeper than 1 level

## Required Patterns (ALWAYS do these)
- ✅ Zod validation on all API inputs (request body, params, query)
- ✅ Error boundaries around every page-level component
- ✅ Loading and error states for every async operation
- ✅ JSDoc on all exported functions with @param and @returns
- ✅ Descriptive variable names (userSubscriptions, not us or data)
- ✅ Early returns over nested if/else
- ✅ `as const` for literal objects and arrays
- ✅ Discriminated unions over optional fields
- ✅ `satisfies` over `as` for type assertions

## Naming Conventions
- Files: kebab-case (user-profile.ts)
- Components: PascalCase (UserProfile.tsx)
- Functions: camelCase, verb-first (getUserById, formatCurrency)
- Types: PascalCase, noun (UserProfile, DashboardMetrics)
- Constants: UPPER_SNAKE_CASE (MAX_RETRY_COUNT)
- Database tables: snake_case plural (user_profiles)
- Database columns: snake_case (created_at)
- CSS classes: Tailwind utilities only (no custom class names)

## Testing Requirements
- Every service function: unit test (happy + error path)
- Every API route: integration test with real test DB
- Every component with logic: Testing Library test
- Bug fixes: write failing test FIRST, then fix
- Test file location: co-located ({name}.test.ts)
- Mocks: only external services (never mock internal modules)
- Assertions: specific values, not just truthiness
- No tests for: type definitions, constant files, re-exports

## Performance Constraints
- No component file over 200 lines (split into sub-components)
- No function over 40 lines (extract helpers)
- No more than 3 levels of component nesting
- Images: next/image with explicit width/height
- Lists over 50 items: use virtualization (TanStack Virtual)
- API responses: paginate at 50 items default, 200 max
- Database queries: always LIMIT, never SELECT * on large tables
- Bundle: no client-side package over 50KB gzipped without approval

## Git
- Commit: type(scope): description (present tense, imperative)
- Branch: type/TICKET-short-desc
- PR: squash merge to main, delete branch after
- Never: force push main, commit .env, skip pre-commit hooks

## When Uncertain
- Ask before making architectural changes
- Prefer boring technology over cutting-edge
- Copy patterns from existing code in the same directory
- If a function is getting complex, it probably needs to be split
```

## Why Each Section Matters

**Forbidden Patterns** saves the most time. Without it, Claude reaches for `any` types, default exports, and `useEffect` for data fetching -- patterns that work but create maintenance debt. Listing them explicitly eliminates the most common code review rejections.

**Architecture with data flow** is the section most CLAUDE.md files miss. Listing directories is not enough. The data flow line tells Claude that a route handler calls a service which calls a repository -- never the reverse, never skipping layers. This single line prevents 80% of architectural violations.

**Performance Constraints** encode the standards that distinguish senior from junior code. A 500-line component file technically works, but it's unmaintainable. These constraints force Claude to produce code that stays maintainable as the project grows.

**Required Patterns** complement the forbidden list. Banning `any` without specifying what to use instead leaves Claude guessing. "Use `unknown` and narrow" tells Claude exactly what you want.

## Customizing for Your Project

This config is opinionated toward a Next.js + TypeScript stack. Adapt it:

1. Replace the **Stack** section with your actual dependencies
2. Keep the **Architecture** section but map it to your directory structure
3. Review **Forbidden Patterns** -- some rules are TypeScript-specific
4. Adjust **Performance Constraints** to your project's scale
5. Add domain-specific rules (e.g., HIPAA compliance, i18n requirements)

The structure -- stack, commands, architecture, forbidden, required, naming, testing, performance, git -- transfers to any language or framework.

## Try It Yourself

Use the [CLAUDE.md Generator](/generator/) to scaffold your project's base config, then paste in the sections from this article that apply. The generator handles stack detection and command mapping; these sections add the senior-level quality constraints that turn Claude from a code generator into a code craftsman. Review the output, customize the forbidden and required patterns for your team's standards, and commit it to your project root.

<details>
<summary>Is 120 lines too long for a CLAUDE.md?</summary>
No. 120 lines uses roughly 700-900 tokens of context. The alternative -- repeating these rules in prompts across dozens of sessions -- costs 10-50x more tokens. The break-even point is about 3 sessions; after that, a detailed CLAUDE.md saves tokens on every interaction.
</details>

<details>
<summary>Should junior developers use this same config?</summary>
Yes, with one addition: add a "When Uncertain" section that tells Claude to explain its decisions in comments. Juniors benefit from seeing why Claude chose a particular pattern, which this config's strict rules make consistent and learnable.
</details>

<details>
<summary>How do I handle rules that have exceptions?</summary>
Add the exception explicitly. For example: "No default exports -- EXCEPTION: Next.js page components and layout components require default exports." Claude follows explicit exceptions without asking for clarification.
</details>

<details>
<summary>What if my team disagrees on some of these rules?</summary>
That is the point. A CLAUDE.md forces your team to make explicit decisions about standards. The disagreements are valuable -- resolve them once in the CLAUDE.md and never argue about them in code reviews again.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Is 120 lines too long for a CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. 120 lines uses roughly 700-900 tokens of context. The alternative -- repeating these rules in prompts across dozens of sessions -- costs 10-50x more tokens. The break-even point is about 3 sessions; after that, a detailed CLAUDE.md saves tokens on every interaction."
      }
    },
    {
      "@type": "Question",
      "name": "Should junior developers use the same CLAUDE.md config?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, with one addition: add a When Uncertain section that tells Claude to explain its decisions in comments. Juniors benefit from seeing why Claude chose a particular pattern, which the strict rules make consistent and learnable."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle rules that have exceptions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add the exception explicitly. For example: No default exports -- EXCEPTION: Next.js page components and layout components require default exports. Claude follows explicit exceptions without asking for clarification."
      }
    },
    {
      "@type": "Question",
      "name": "What if my team disagrees on some of these CLAUDE.md rules?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "That is the point. A CLAUDE.md forces your team to make explicit decisions about standards. The disagreements are valuable -- resolve them once in the CLAUDE.md and never argue about them in code reviews again."
      }
    }
  ]
}
</script>

## Related Guides

- [CLAUDE.md Generator](/generator/) -- Scaffold your CLAUDE.md with automatic stack detection
- [Claude Code Best Practices](/best-practices/) -- More production patterns for Claude Code
- [Claude Code Commands Reference](/commands/) -- Every Claude Code command explained
- [Claude Code Permissions Guide](/permissions/) -- Control Claude's access and capabilities
- [Advanced Claude Code Usage](/advanced-usage/) -- Power-user workflows and techniques
