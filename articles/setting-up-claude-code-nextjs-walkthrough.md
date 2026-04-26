---
layout: default
title: "Setting Up Claude Code for Next.js: Complete Walkthrough (2026)"
description: "Next.js-specific Claude Code setup: CLAUDE.md with App Router rules, .claudeignore for .next/build, permissions for npm/npx, testing, and deployment pipeline."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /setting-up-claude-code-nextjs-walkthrough/
reviewed: true
categories: [getting-started]
tags: [claude, claude-code, nextjs, setup, walkthrough]
---

# Setting Up Claude Code for Next.js: Complete Walkthrough

Next.js projects have specific needs that a generic Claude Code setup misses. The App Router has file-based conventions. The `.next/` directory generates thousands of files that pollute context. Server components and client components follow different rules. This walkthrough configures Claude Code to understand all of it. Use the [Project Starter](/starter/) for a one-command setup, or follow these steps for full control.

## CLAUDE.md for Next.js App Router

This CLAUDE.md covers the patterns Claude Code needs to know for effective Next.js development:

```markdown
# CLAUDE.md

## Project
Next.js 15 App Router, TypeScript strict, Tailwind CSS v4, Supabase

## Package Manager
pnpm (always use pnpm, never npm or yarn)

## Commands
- `pnpm dev` -- dev server at localhost:3000
- `pnpm build` -- production build (must pass before deploy)
- `pnpm test` -- Vitest unit tests
- `pnpm test:e2e` -- Playwright end-to-end tests
- `pnpm lint` -- next lint + ESLint
- `pnpm typecheck` -- tsc --noEmit

## App Router Conventions
- page.tsx -- route page component
- layout.tsx -- shared layout (wraps children)
- loading.tsx -- streaming loading UI
- error.tsx -- error boundary ("use client" required)
- not-found.tsx -- 404 page
- route.ts -- API route handler (GET, POST, etc.)
- template.tsx -- re-rendered on navigation

## Component Rules
- Server components by default. No "use client" unless needed.
- "use client" required for: useState, useEffect, onClick, onChange,
  useRouter, useSearchParams, usePathname
- Server actions: "use server" in function or file-level directive
- Metadata: export const metadata or generateMetadata() in page/layout

## File Structure
- src/app/ -- pages, layouts, API routes
- src/components/ -- shared components (ui/ for primitives)
- src/lib/ -- utilities, helpers, constants
- src/db/ -- database client, queries
- src/types/ -- shared TypeScript types
- src/hooks/ -- custom React hooks ("use client" files)

## Coding Standards
- All functions < 60 lines. Extract helpers for complex logic.
- Explicit return types on exported functions.
- Zod for all form/API input validation.
- next/image for all images with width + height.
- next/link for all internal navigation.
- No default exports except page.tsx, layout.tsx, route.ts.

## Testing
- Vitest + React Testing Library for unit tests
- Test files: Component.test.tsx next to Component.tsx
- Playwright for E2E: tests/e2e/*.spec.ts
- Mock server actions with vi.mock()
```

## .claudeignore for Next.js

Next.js generates a large `.next/` directory during builds. Without ignoring it, Claude Code wastes thousands of tokens reading compiled output:

```bash
# .claudeignore
node_modules/
.next/
out/
dist/
coverage/
.vercel/
.turbo/

# Lock files
pnpm-lock.yaml
package-lock.json
yarn.lock

# Generated files
next-env.d.ts
*.tsbuildinfo

# Assets that waste context
public/images/
public/fonts/
public/og/

# Test artifacts
playwright-report/
test-results/
.playwright/
```

This configuration prevents Claude Code from reading build artifacts, dependencies, and binary assets. Expected token savings: 30-50% per session compared to no `.claudeignore`.

## Permissions for Next.js Development

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(pnpm test *)",
      "Bash(pnpm test)",
      "Bash(pnpm lint)",
      "Bash(pnpm typecheck)",
      "Bash(pnpm build)",
      "Bash(pnpm dev)",
      "Bash(npx next lint *)",
      "Bash(npx prisma generate)",
      "Bash(npx prisma db push)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(wc -l *)",
      "Bash(ls *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(pnpm deploy *)",
      "Bash(vercel --prod *)",
      "Bash(sudo *)"
    ]
  }
}
```

Key decisions in this config:
- **Build allowed:** Claude Code can run `pnpm build` to verify changes compile
- **Deploy denied:** Production deployment requires human approval
- **Prisma allowed:** Schema changes and client regeneration are safe
- **Force push denied:** Protecting git history from accidental rewrites

## Testing Setup

Configure Claude Code to write and run tests effectively:

```typescript
// vitest.config.ts -- Claude Code reads this to understand test setup
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.test.*', 'src/types/**']
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

```typescript
// tests/setup.ts
import '@testing-library/jest-dom/vitest'
```

With this setup, Claude Code knows to:
- Place test files next to source files with `.test.tsx` suffix
- Use `@testing-library/react` for component tests
- Use the `@/` path alias in imports
- Run `pnpm test` to execute the suite

## Next.js-Specific Prompting Patterns

Get better results by using Next.js terminology in your prompts:

```bash
# Server component (default -- no special instruction needed)
"Create a product listing page at /products that fetches
 from Supabase and displays a grid of ProductCards"

# Client component (specify when interactivity needed)
"Create a client component SearchBar with useState for the
 query and debounced onChange that updates URL search params"

# Server action
"Create a server action in src/app/actions/cart.ts that
 adds an item to the cart in Supabase and revalidates /cart"

# API route
"Create a POST API route at /api/webhooks/stripe that
 verifies the Stripe signature and processes checkout events"

# Metadata
"Add generateMetadata to the product page that sets the
 title and description from the product data"
```

## Deployment Pipeline Integration

Add deployment awareness to your CLAUDE.md:

```markdown
## Deployment
- Preview: automatic on PR via Vercel
- Production: `vercel --prod` (manual only, never auto-deploy)
- Pre-deploy checklist: pnpm build + pnpm test + pnpm typecheck
- Environment vars: Vercel dashboard only, never in code
```

## Try It Yourself

The [Project Starter](/starter/) detects Next.js projects automatically and generates all configuration files -- CLAUDE.md, .claudeignore, and settings.json -- customized for your specific Next.js version, package manager, and testing framework. Run it once and you are ready to develop.

## Frequently Asked Questions

<details>
<summary>Should CLAUDE.md mention the Next.js version?</summary>
Yes. Next.js 15 App Router and Next.js 13 Pages Router have fundamentally different patterns. Specifying the version ensures Claude Code uses the correct file conventions, routing patterns, and API syntax. If you are on Pages Router, replace the App Router conventions with Pages Router equivalents. Use the <a href="/starter/">Project Starter</a> to auto-detect your version.
</details>

<details>
<summary>How do I handle environment variables in CLAUDE.md?</summary>
Never put actual values in CLAUDE.md. Instead, list the variable names and their purpose: "NEXT_PUBLIC_SUPABASE_URL -- Supabase project URL (set in .env.local)". Claude Code uses this to understand what services are available without seeing credentials. See <a href="/configuration/">Configuration</a> for secure env var handling.
</details>

<details>
<summary>Does Claude Code understand Next.js middleware?</summary>
Yes. Add a note in CLAUDE.md about your middleware pattern: "Middleware in src/middleware.ts handles auth redirects and locale detection." Claude Code reads the middleware file and understands the matcher config, request/response modification, and NextResponse API. See <a href="/commands/">Commands</a> for how to scope Claude Code to specific files.
</details>

<details>
<summary>How do I prevent Claude Code from creating Pages Router files in an App Router project?</summary>
The CLAUDE.md rule "App Router file conventions: page.tsx, layout.tsx..." is usually sufficient. If Claude Code still creates pages/ files, add an explicit deny: "Never create files in a pages/ directory. This project uses App Router exclusively." The <a href="/permissions/">Permissions</a> configurator can add file-level restrictions.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should CLAUDE.md mention the Next.js version?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Next.js 15 App Router and Next.js 13 Pages Router have fundamentally different patterns. Specifying the version ensures Claude Code uses the correct conventions."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle environment variables in Claude Code CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Never put actual values in CLAUDE.md. List variable names and their purpose so Claude Code understands what services are available without seeing credentials."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude Code understand Next.js middleware?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Add a note in CLAUDE.md about your middleware pattern. Claude Code reads the middleware file and understands the matcher config and NextResponse API."
      }
    },
    {
      "@type": "Question",
      "name": "How do I prevent Claude Code from creating Pages Router files in an App Router project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The CLAUDE.md App Router conventions are usually sufficient. If needed, add an explicit rule: 'Never create files in a pages/ directory. This project uses App Router exclusively.'"
      }
    }
  ]
}
</script>

## Related Guides

- [Project Starter](/starter/) -- Auto-generate Next.js-specific Claude Code configuration
- [CLAUDE.md Generator](/generator/) -- Create framework-aware instruction files
- [Permissions Configurator](/permissions/) -- Set up Next.js-safe permissions
- [Commands Reference](/commands/) -- Claude Code commands for development workflows
- [Configuration Guide](/configuration/) -- Full .claudeignore and settings.json reference
