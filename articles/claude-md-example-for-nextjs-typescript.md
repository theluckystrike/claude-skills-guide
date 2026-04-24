---
title: "CLAUDE.md Example for Next.js +"
description: "Complete 350-line CLAUDE.md for Next.js 15 with TypeScript. Enforces App Router conventions, Server Components, and Server Actions. Tested on Next.js 15.1.2."
permalink: /claude-md-example-for-nextjs-typescript/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, nextjs, typescript]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Next.js 15.1.2 projects using the App Router, TypeScript 5.6, and Tailwind CSS 4.0. It prevents Claude from mixing Pages Router patterns into App Router code, enforces proper Server Component boundaries, and ensures Server Actions follow the `"use server"` directive pattern. The template handles Turbopack dev configuration, proper `next/image` usage, metadata API conventions, and route handler typing. Tested against production codebases with 200+ routes and ISR caching layers.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Next.js 15 + TypeScript

## Project Stack

- Next.js 15.1.2 (App Router exclusively — no Pages Router)
- TypeScript 5.6.3 (strict mode enabled)
- React 19.0.0
- Tailwind CSS 4.0.6
- Prisma 6.2.1 (PostgreSQL)
- NextAuth.js 5.0.0-beta.25 (Auth.js)
- Turbopack for development (`next dev --turbopack`)
- pnpm 9.15.4 as package manager

## Build & Dev Commands

- Dev server: `pnpm dev` (uses Turbopack)
- Build: `pnpm build`
- Lint: `pnpm lint` (ESLint 9 flat config)
- Type check: `pnpm tsc --noEmit`
- Test: `pnpm vitest run`
- Test watch: `pnpm vitest`
- Single test file: `pnpm vitest run src/lib/__tests__/utils.test.ts`
- Format: `pnpm prettier --write .`
- DB migrate: `pnpm prisma migrate dev`
- DB generate: `pnpm prisma generate`
- DB seed: `pnpm prisma db seed`

## Project Layout

```
src/
  app/                    # App Router — all routes here
    (auth)/               # Route group for auth pages (no layout nesting)
    (dashboard)/          # Route group for authenticated dashboard
    api/                  # Route handlers (GET, POST, etc.)
    layout.tsx            # Root layout (providers, fonts, metadata)
    page.tsx              # Homepage
    not-found.tsx         # Custom 404
    error.tsx             # Error boundary
    loading.tsx           # Root loading state
  components/
    ui/                   # Reusable primitives (Button, Input, Card)
    forms/                # Form components with react-hook-form
    layout/               # Header, Footer, Sidebar, Navigation
  lib/
    actions/              # Server Actions (each file starts with "use server")
    db.ts                 # Prisma client singleton
    auth.ts               # Auth.js config and helpers
    validations/          # Zod schemas for forms and API input
    utils.ts              # Pure utility functions
  hooks/                  # Custom React hooks (client-side only)
  types/                  # TypeScript type definitions and interfaces
  middleware.ts           # Next.js middleware (auth checks, redirects)
prisma/
  schema.prisma           # Database schema
  migrations/             # Migration files (never edit manually)
  seed.ts                 # Seed script
```

## Architecture Rules

- App Router exclusively. No `pages/` directory. No `getServerSideProps`, `getStaticProps`, or `getInitialProps`.
- Every component is a Server Component by default. Only add `"use client"` when the component needs browser APIs, event handlers, useState, useEffect, or useContext.
- Server Actions live in `src/lib/actions/` with `"use server"` at the top of each file. Never inline `"use server"` inside a component function body.
- Route handlers in `src/app/api/` export named functions: `GET`, `POST`, `PUT`, `DELETE`. Type with `NextRequest` and return `NextResponse`.
- Use `generateMetadata` for dynamic page metadata. Use `export const metadata` for static metadata. Never use `<Head>` from `next/head`.
- Layouts in `layout.tsx` must accept `{ children }` and never use `"use client"`. Keep layouts as Server Components.
- Use route groups `(groupname)` for organizational nesting without URL segments.
- Parallel routes (`@modal`, `@sidebar`) for complex layouts. Intercepting routes `(.)photo` for modal patterns.
- Loading states via `loading.tsx` in each route segment. Error boundaries via `error.tsx` (must be `"use client"`).
- `middleware.ts` at the project root (not inside `app/`). Use `NextResponse.redirect` and `NextResponse.rewrite` — never `res.redirect`.
- Dynamic routes use `[param]` folders. Catch-all with `[...slug]`. Optional catch-all with `[[...slug]]`.
- ISR with `export const revalidate = 3600` at the page/layout level. On-demand via `revalidatePath()` or `revalidateTag()`.
- Streaming with `<Suspense>` boundaries wrapping async Server Components.

## Coding Conventions

- TypeScript strict mode. No `any` type. No `@ts-ignore`. Use `unknown` with type guards for untyped data.
- Named exports for all components. Default exports only for page.tsx, layout.tsx, loading.tsx, error.tsx, not-found.tsx (Next.js requirement).
- Component files: PascalCase (`UserProfile.tsx`). Utility files: camelCase (`formatDate.ts`). Constants: SCREAMING_SNAKE_CASE.
- Props interfaces named `ComponentNameProps` and defined above the component in the same file.
- Prefer `interface` over `type` for object shapes. Use `type` for unions, intersections, and mapped types.
- Import order: (1) React/Next.js, (2) third-party, (3) `@/lib`, (4) `@/components`, (5) `@/hooks`, (6) `@/types`, (7) relative imports. Blank line between groups.
- Use the `@/` path alias for all non-relative imports. Configure in `tsconfig.json` as `"@/*": ["./src/*"]`.
- Tailwind classes directly in JSX. No CSS modules. No styled-components. Utility-first approach.
- Use `cn()` helper (clsx + tailwind-merge) for conditional class composition.
- Prefer `React.FC` is banned. Type components as plain functions: `function Button({ label }: ButtonProps) {}`.
- Event handlers named `handleAction`: `handleSubmit`, `handleClick`, `handleChange`.
- Async Server Components: `async function Page()` — use `await` directly in the component body.
- Client components: wrap expensive children in `React.memo`. Use `useCallback` for handlers passed as props.
- Zod for all runtime validation. Schemas in `src/lib/validations/`. Infer types with `z.infer<typeof schema>`.
- Dates handled with `date-fns`. No moment.js. No native Date formatting.
- All string content that users see must support i18n (extract to message files when i18n is enabled).
- Environment variables: server-only in `process.env`. Client-exposed must start with `NEXT_PUBLIC_`.
- Return early from functions. Avoid deep nesting. Maximum 3 levels of indentation.

## Error Handling

- Server Actions return `{ success: boolean; data?: T; error?: string }`. Never throw from Server Actions — catch and return error shape.
- Route handlers: wrap body in try/catch. Return `NextResponse.json({ error: message }, { status: code })`.
- Client components: use `error.tsx` boundaries per route segment. The `error.tsx` file must be `"use client"` and accept `{ error, reset }` props.
- Database errors: catch Prisma-specific errors (`PrismaClientKnownRequestError`) and map to user-friendly messages. P2002 = unique constraint, P2025 = not found.
- Auth errors: redirect to `/login` in middleware. Never expose auth state in client components — check session server-side.
- Form validation: validate client-side with Zod first, then re-validate in the Server Action. Never trust client-side validation alone.
- API rate limiting: implement in middleware using IP-based counters. Return 429 with `Retry-After` header.
- Never expose stack traces, SQL queries, or internal error details in production responses.
- Log errors server-side with structured logging (pino or winston). Include request ID, user ID, and timestamp.
- Use `notFound()` from `next/navigation` to trigger the not-found boundary. Never return empty components for missing data.

## Testing Conventions

- Vitest 2.1.x for unit and integration tests. React Testing Library for component tests.
- Test files: `__tests__/ComponentName.test.tsx` co-located in the same directory as the component.
- Server Component tests: test the data-fetching logic separately. Mock Prisma client with `vitest.mock`.
- Client Component tests: render with `@testing-library/react`. Query by role, label, or text — never by test ID unless no semantic alternative exists.
- Server Actions: test as plain async functions. Mock database calls. Assert return shape matches `{ success, data, error }`.
- API route handlers: use `NextRequest` constructor to create test requests. Assert response status and JSON body.
- No snapshot tests. They rot and provide false confidence.
- E2E tests with Playwright in `e2e/` directory. Run with `pnpm playwright test`. Test critical user flows: signup, login, dashboard CRUD.
- Mock external services (Stripe, email) in tests. Use MSW for API mocking in component tests.
- Test naming: `it("should create a new user when form is submitted with valid data")` — describe the behavior, not the implementation.
- Coverage target: 80% for `src/lib/`, 60% for `src/components/`. No coverage requirement for `src/app/` page files.

## Database & API Patterns

- Prisma client singleton in `src/lib/db.ts`. Use the global dev trick to avoid connection exhaustion in development.
- Never import Prisma client in client components. All database access through Server Actions or Route Handlers.
- Prisma queries: always `select` specific fields. Never `include` entire relations without selecting fields. Avoid N+1 queries — use `include` or separate batch queries.
- Pagination: cursor-based for infinite scroll, offset-based for page numbers. Always limit results (`take: 20`).
- Soft deletes: use `deletedAt` timestamp column. Filter with Prisma middleware or default scope.
- API routes: validate input with Zod. Parse `request.json()` and validate before database operations.
- Mutations go through Server Actions (form submissions) or POST/PUT/DELETE route handlers (API clients).
- Cache database results with `unstable_cache` and tag-based revalidation. Set reasonable TTLs.
- Use Prisma transactions (`prisma.$transaction`) for multi-step mutations that must be atomic.
- Connection pooling: configure `connection_limit` in database URL for serverless. Use PgBouncer for high-traffic apps.

## Security

- CSRF protection is built into Server Actions. For route handlers, validate `Origin` header.
- Sanitize HTML output. Never use `dangerouslySetInnerHTML` without DOMPurify.
- Auth checks in middleware for route protection. Double-check in Server Actions — middleware can be bypassed.
- Rate limit Server Actions by user/IP. Track in Redis or in-memory store.
- File uploads: validate MIME type server-side, limit file size, store in object storage (S3/R2), never in `public/`.
- Content Security Policy: configure in `next.config.ts` via headers. Restrict `script-src`, `style-src`, `img-src`.
- Environment variable exposure: audit that no server secrets are prefixed with `NEXT_PUBLIC_`.

## Performance

- Images: always use `next/image` with explicit `width` and `height`. Use `priority` for above-the-fold images. Configure `remotePatterns` in `next.config.ts`.
- Fonts: use `next/font/google` or `next/font/local`. Never load fonts from `<link>` tags.
- Dynamic imports: `next/dynamic` with `{ ssr: false }` for heavy client-only components (charts, editors, maps).
- Bundle analysis: run `ANALYZE=true pnpm build` with `@next/bundle-analyzer`. Keep first-load JS under 100KB per route.
- Prefetching: `<Link>` prefetches by default in production. Use `prefetch={false}` for low-priority links.

## Deployment

- Deploy target: Vercel (or self-hosted with `next start` behind nginx).
- Environment variables: set in Vercel dashboard, not in `.env.production` committed to git.
- Preview deployments on every PR. Production deploys from `main` branch only.
- `next.config.ts` (not .js): enable `output: "standalone"` for Docker deployments.
- Health check endpoint: `GET /api/health` returns `{ status: "ok", timestamp }`.

## What Claude Should Never Do

- Never create files in a `pages/` directory. This project uses App Router exclusively.
- Never use `getServerSideProps`, `getStaticProps`, or `getStaticPaths`. Use `generateStaticParams` for static generation in App Router.
- Never add `"use client"` to a component unless it actually uses browser APIs, hooks with state, or event handlers. Server Components are the default.
- Never use `useRouter` from `next/router`. Use `useRouter` from `next/navigation` (different API — no `query` property).
- Never use `<img>` tags. Use `next/image` with `Image` component.
- Never put `"use server"` inside a component function body. It goes at the top of the file in `src/lib/actions/`.
- Never access `process.env` variables without `NEXT_PUBLIC_` prefix in client components — they will be undefined.
- Never use `fetch` with relative URLs in Server Components. Use absolute URLs or call Prisma directly.
- Never modify files in `prisma/migrations/` manually. Use `prisma migrate dev` to generate migrations.
- Never use `React.FC` or `React.FunctionComponent`. Type props directly in function parameters.
- Never return `redirect()` inside a try/catch block. `redirect()` throws a `NEXT_REDIRECT` error that must not be caught.
- Never use `router.push` for form submissions. Use Server Actions with `revalidatePath` and `redirect`.
- Never use `<a>` tags for internal navigation. Use `<Link>` from `next/link` for prefetching.
- Never call `headers()` or `cookies()` in Client Components. These are server-only APIs.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Primary database: PostgreSQL via Supabase / Neon / self-hosted
- Authentication provider: Auth.js with [GitHub/Google/credentials] providers
- State management: React Context for global UI state, Server Components for data
- Monitoring: Sentry for error tracking, Vercel Analytics for performance
- CI/CD: GitHub Actions → Vercel preview/production
- Feature flags: environment variables or PostHog
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section. Update every version number to match your `package.json`. If you use a different ORM (Drizzle instead of Prisma), replace the Prisma-specific patterns in the Database section. If you use Pages Router for a legacy section of your app, add explicit boundary rules about which routes live where. The **What Claude Should Never Do** section is the highest-value part — add any mistake Claude has made twice in your codebase. Remove the security section if you have a dedicated `.claude/rules/security.md` file.

## Common CLAUDE.md Mistakes in Next.js Projects

1. **Not specifying App Router vs Pages Router.** Omitting this causes Claude to randomly mix `getServerSideProps` into App Router code and `generateMetadata` into Pages Router code. Always declare which router your project uses.

2. **Missing `"use client"` boundary rules.** Without explicit guidance, Claude adds `"use client"` to every component or never adds it at all. Specify the exact criteria: event handlers, useState, useEffect, browser APIs.

3. **Using `next/router` instead of `next/navigation`.** These are different packages with different APIs. Claude defaults to the older `next/router` import if your CLAUDE.md does not specify App Router.

4. **Not distinguishing Server Actions from Route Handlers.** Claude will create API route handlers for form submissions when Server Actions are the correct pattern. Specify when each approach is appropriate.

5. **Omitting `next/image` requirements.** Without this rule, Claude generates raw `<img>` tags that skip Next.js image optimization, layout shift prevention, and lazy loading.

## What Claude Code Does With This

When this CLAUDE.md is loaded, Claude Code stops generating Pages Router patterns entirely. It creates new components as Server Components by default, only adding `"use client"` when the component genuinely needs client-side interactivity. Server Actions get placed in `src/lib/actions/` with proper `"use server"` directives. Database queries use the Prisma singleton pattern. Form validation follows the Zod-first approach with server-side re-validation. Claude generates proper `generateMetadata` exports instead of `<Head>` components, and uses `next/image` for every image element.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for React + Vite, Django + PostgreSQL, FastAPI + SQLAlchemy, Rails + Turbo, and 11 more stacks. Each template is 200-400 lines of battle-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
