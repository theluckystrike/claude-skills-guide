---
title: "CLAUDE.md Example for React + Vite + TypeScript — Production Template (2026)"
description: "Complete 300-line CLAUDE.md for React 19 with Vite 6. Covers HMR patterns, barrel exports, lazy loading, and Tanstack Query conventions. Tested on Vite 6.1.0."
permalink: /claude-md-example-for-react-vite-typescript/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, react, vite, typescript]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for React 19.0 single-page applications built with Vite 6.1.0 and TypeScript 5.6. It enforces proper Vite configuration patterns, prevents barrel export anti-patterns that break tree-shaking, and guides Claude through React 19 features like `use()`, `useActionState`, and Server Functions. The template covers Tanstack Query for data fetching, React Router 7 for routing, and Zustand for state management. Tested on production SPAs with 150+ components and complex form workflows.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — React 19 + Vite 6 + TypeScript

## Project Stack

- React 19.0.0
- Vite 6.1.0 (with SWC plugin for fast refresh)
- TypeScript 5.6.3 (strict mode)
- React Router 7.1.1 (data router with loaders/actions)
- Tanstack Query 5.62.0 (server state management)
- Zustand 5.0.3 (client state management)
- Tailwind CSS 4.0.6
- React Hook Form 7.54.2 + Zod 3.24.1
- Vitest 2.1.8 + React Testing Library 16.1.0
- pnpm 9.15.4

## Build & Dev Commands

- Dev server: `pnpm dev` (Vite HMR on port 5173)
- Build: `pnpm build` (outputs to `dist/`)
- Preview: `pnpm preview` (serve production build locally)
- Lint: `pnpm lint` (ESLint 9 flat config + typescript-eslint)
- Type check: `pnpm tsc --noEmit`
- Test: `pnpm test` (Vitest)
- Test UI: `pnpm test:ui` (Vitest UI in browser)
- Test coverage: `pnpm test:coverage`
- Format: `pnpm prettier --write .`
- Storybook: `pnpm storybook` (port 6006)

## Project Layout

```
src/
  app/
    App.tsx               # Root component with providers
    router.tsx            # React Router configuration
    providers.tsx         # QueryClient, Zustand, theme providers
  features/
    auth/                 # Feature module: login, signup, session
      components/         # Feature-specific components
      hooks/              # Feature-specific hooks
      api.ts              # API calls for this feature
      store.ts            # Zustand slice for this feature
      types.ts            # Types for this feature
    dashboard/
    settings/
  components/
    ui/                   # Design system primitives (Button, Input, Modal)
    layout/               # Shell, Sidebar, Header, Footer
    feedback/             # Toast, Alert, Skeleton, ErrorFallback
  hooks/                  # Shared custom hooks
  lib/
    api-client.ts         # Axios/fetch wrapper with interceptors
    query-keys.ts         # Tanstack Query key factory
    validations.ts        # Shared Zod schemas
    utils.ts              # Pure utility functions
    constants.ts          # App-wide constants
  types/
    api.ts                # API response/request types
    common.ts             # Shared type definitions
  assets/                 # Static assets (SVGs, images)
  styles/
    globals.css           # Tailwind directives and CSS custom properties
public/                   # Served as-is (favicon, robots.txt)
```

## Architecture Rules

- Feature-based folder structure. Each feature in `src/features/` is self-contained with its own components, hooks, API calls, store slice, and types.
- Shared components in `src/components/`. Only components used by 2+ features belong here.
- No barrel exports (`index.ts` re-exporting everything). Import directly from the source file. Barrel exports break Vite tree-shaking and slow down HMR.
- Data fetching exclusively through Tanstack Query. No `useEffect` + `useState` for API calls. No fetching in component mount.
- Server state (API data) in Tanstack Query cache. Client state (UI state, form state) in Zustand or local component state.
- React Router data router pattern: use `loader` functions for route-level data fetching, `action` functions for mutations.
- Lazy load route components with `React.lazy()` and `<Suspense>`. Every route-level component should be code-split.
- Environment variables: prefix with `VITE_` for client access. Access via `import.meta.env.VITE_API_URL`.
- No direct DOM manipulation. No `document.querySelector`. No `window.addEventListener` outside custom hooks with cleanup.
- API base URL from environment variable. Never hardcode API endpoints.
- Feature modules must not import from other feature modules directly. Shared logic goes in `src/lib/` or `src/hooks/`.

## Coding Conventions

- TypeScript strict mode. No `any`. No `@ts-ignore`. Use `unknown` and narrow with type guards.
- Named exports for all components and functions. No default exports.
- Component files: PascalCase (`UserProfile.tsx`). Hook files: camelCase starting with `use` (`useAuth.ts`). Utility files: camelCase (`formatCurrency.ts`).
- Props interfaces: `ComponentNameProps`, defined above the component in the same file.
- Prefer `interface` for object shapes, `type` for unions/intersections/utility types.
- Function components only. No class components. No `React.FC`. Type props in function parameters directly.
- Hooks rules: every custom hook starts with `use`. Hooks only called at the top level. No hooks inside callbacks or conditions.
- Import order: (1) react, (2) third-party, (3) `@/features`, (4) `@/components`, (5) `@/hooks`, (6) `@/lib`, (7) `@/types`, (8) relative. Blank line between groups.
- Path alias: `@/` maps to `src/`. Configured in both `vite.config.ts` and `tsconfig.json`.
- Event handlers: `handleAction` naming (`handleSubmit`, `handleClose`, `handleSelect`).
- Tailwind utility classes in JSX. Use `cn()` (clsx + tailwind-merge) for conditional classes.
- Prefer early returns over nested conditionals. Max 3 levels of nesting.
- Memoization: use `React.memo` for components receiving complex props from parent. Use `useMemo` for expensive computations. Use `useCallback` for callbacks passed to memoized children. Do not memoize everything — only when profiling shows a need.
- Template literals for string interpolation. No string concatenation.
- Destructure props in function signature. Destructure hook returns immediately.
- Arrow functions for inline callbacks. Named function declarations for components and hooks.
- No inline styles. No CSS-in-JS. Tailwind only.
- Comments: explain WHY, not WHAT. Use `// TODO(username):` for todos. Use `// HACK:` for intentional workarounds.

## Error Handling

- Global error boundary at app root using `react-error-boundary`. Renders `ErrorFallback` component with retry button.
- Route-level error elements: every route in `router.tsx` must have an `errorElement` prop.
- Tanstack Query error handling: use `onError` callback in mutations. Display errors with toast notifications.
- API client interceptors: handle 401 (redirect to login, clear session), 403 (show permission error), 429 (show rate limit message), 500+ (show generic error).
- Form validation errors: Zod schemas parsed in `onSubmit`. Field-level errors displayed inline below each input. Form-level errors displayed above the submit button.
- Never swallow errors silently. Every `catch` block must either display an error to the user or log to an error reporting service.
- Async operations in event handlers: always wrap in try/catch. Loading state while pending.
- Network errors: detect with `navigator.onLine` and show offline banner. Tanstack Query handles retry automatically.
- Type-narrow errors: `if (error instanceof AxiosError)` before accessing `.response`. Unknown errors get generic message.

## Testing Conventions

- Vitest + React Testing Library + jsdom environment.
- Test files: `ComponentName.test.tsx` co-located with the component.
- Component tests: render, interact, assert. Use `screen.getByRole`, `screen.getByLabelText`, `screen.getByText`. Avoid `getByTestId` unless no semantic option exists.
- Hook tests: use `renderHook` from `@testing-library/react`. Wrap in `QueryClientProvider` for hooks that use Tanstack Query.
- API mocking: MSW (Mock Service Worker) for intercepting network requests. Handlers defined per test suite.
- User interaction: `await userEvent.click()`, `await userEvent.type()`. Prefer `userEvent` over `fireEvent`.
- Async assertions: `await waitFor(() => expect(...))` or `await screen.findByText(...)`.
- No snapshot tests. Test behavior and output, not markup structure.
- Integration tests for complex features: render the full feature component with mocked API, simulate complete user workflows.
- Storybook stories for visual components. Stories are documentation, not tests.
- Coverage target: 80% for `src/lib/` and `src/hooks/`, 70% for `src/features/`, 50% for `src/components/ui/`.

## API & Data Fetching Patterns

- Tanstack Query keys: use factory pattern in `src/lib/query-keys.ts`. Example: `queryKeys.users.list(filters)`, `queryKeys.users.detail(id)`.
- Queries: `useQuery({ queryKey, queryFn, staleTime, gcTime })`. Set `staleTime` based on data freshness needs.
- Mutations: `useMutation({ mutationFn, onSuccess, onError })`. Invalidate related queries in `onSuccess`.
- Optimistic updates: use `onMutate` to update cache immediately, `onError` to roll back, `onSettled` to refetch.
- Infinite scroll: `useInfiniteQuery` with `getNextPageParam`. Trigger with Intersection Observer.
- Prefetching: `queryClient.prefetchQuery` on hover for fast navigation.
- API client: Axios instance with baseURL, timeout (10s), and auth token interceptor.
- Request types: `ApiResponse<T> = { data: T; meta?: PaginationMeta }`. Error type: `ApiError = { message: string; code: string; details?: Record<string, string[]> }`.
- File uploads: `FormData` with progress tracking via Axios `onUploadProgress`.
- WebSocket data: sync with Tanstack Query cache using `queryClient.setQueryData` on message receipt.

## Vite Configuration

- `vite.config.ts`: use `@vitejs/plugin-react-swc` for fast JSX transform and refresh.
- Path aliases: `resolve: { alias: { '@': path.resolve(__dirname, './src') } }`.
- Proxy API requests in dev: `server: { proxy: { '/api': { target: 'http://localhost:3001' } } }`.
- Environment-specific configs: `.env.development`, `.env.production`, `.env.test`. Never commit `.env.local`.
- Build optimization: `build.rollupOptions.output.manualChunks` for splitting vendor chunks (react, router, query).
- Chunk size warning limit: 500 KB. Investigate if any chunk exceeds this.
- Enable gzip/brotli compression via `vite-plugin-compression` for production.
- CSS: `postcss.config.js` with Tailwind and autoprefixer plugins. No separate CSS pre-processors.
- Dev server port: default 5173. Configure in `server.port` if needed.

## Security

- No secrets in `VITE_` environment variables — they are baked into the production bundle and visible in source.
- XSS: React escapes by default. Never use `dangerouslySetInnerHTML` without DOMPurify sanitization.
- Auth tokens: store in httpOnly cookies (preferred) or memory (Zustand store). Never in localStorage.
- CORS: API must whitelist frontend origin. Use Vite proxy in development to avoid CORS issues.
- CSP: configure Content-Security-Policy headers on the hosting platform (Vercel headers, nginx, CloudFront).
- Dependencies: run `pnpm audit` regularly. Update vulnerable packages immediately.

## Deployment

- Build: `pnpm build` outputs static files to `dist/`. Deploy as static site.
- Hosting: Vercel, Netlify, AWS S3 + CloudFront, or nginx. Configure SPA fallback to `index.html` for client-side routing.
- Environment: set `VITE_*` variables in hosting platform dashboard or CI/CD. Not in committed files.
- Preview: `pnpm preview` serves production build locally on port 4173 for testing.
- CI: run `pnpm lint && pnpm tsc --noEmit && pnpm test` before deploy. Fail on warnings.
- Cache: set `Cache-Control: max-age=31536000, immutable` on hashed assets. `no-cache` on `index.html`.
- Source maps: enable in staging, disable in production (`build.sourcemap: false`).

## What Claude Should Never Do

- Never create barrel `index.ts` files that re-export from other modules. Import directly from source files.
- Never use `useEffect` + `useState` for data fetching. Use Tanstack Query `useQuery`.
- Never access `process.env` in client code. Use `import.meta.env.VITE_*` — Vite does not use Node.js process.
- Never use `window.location.href` for navigation. Use React Router `useNavigate()` or `<Link>`.
- Never put API keys or secrets in `VITE_` environment variables. They are embedded in the client bundle.
- Never use `React.FC` or `React.FunctionComponent`. Type props directly in function parameters.
- Never mutate Tanstack Query cache directly with `queryClient.setQueryData` outside of optimistic update patterns.
- Never import from `react-router-dom` version 5 patterns (`withRouter`, `<Switch>`, `<Route exact>`). Use v7 data router API.
- Never create CSS modules or styled-components. This project uses Tailwind exclusively.
- Never add `key={Math.random()}` or `key={index}` to lists with mutable data. Generate stable IDs.
- Never use `document.getElementById` or direct DOM access. Use refs with `useRef`.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- API backend: [REST API at /api or separate service URL]
- Auth: [JWT tokens / session cookies / OAuth provider]
- Deployment: [Vercel / Netlify / AWS S3 + CloudFront]
- Monitoring: [Sentry / Datadog / LogRocket]
- Design system: [Custom / Radix UI / shadcn/ui]
```
{% endraw %}

## How to Adapt This For Your Project

Begin with the **Project Stack** section and match every version to your `package.json`. If you use Redux Toolkit instead of Zustand, swap the state management sections. If your project uses a REST API with custom hooks instead of Tanstack Query, replace the data fetching patterns entirely. The feature-based folder structure may need adjustment if your project uses a flat component structure — update the Project Layout section to match. Keep the **What Claude Should Never Do** section and add project-specific footguns as you discover them.

## Common CLAUDE.md Mistakes in React + Vite Projects

1. **Not banning barrel exports.** Without this rule, Claude creates `index.ts` files in every directory, which kills Vite HMR performance and breaks tree-shaking. Vite processes the full dependency graph on each change through barrel files.

2. **Confusing `process.env` with `import.meta.env`.** Claude defaults to Node.js patterns. Without explicit instruction, it writes `process.env.REACT_APP_*` (Create React App pattern) instead of `import.meta.env.VITE_*`.

3. **Using `useEffect` for data fetching.** Claude generates `useEffect` + `useState` + loading/error state boilerplate instead of a single `useQuery` call. Specify your data fetching library explicitly.

4. **Mixing React Router versions.** Claude trained on v5 and v6 syntax equally. Without specifying v7 data router patterns, you get a mix of `<Switch>`, `<Route exact>`, and modern `createBrowserRouter` syntax.

5. **Omitting HMR-safe state patterns.** Vite HMR preserves component state. Without guidance, Claude creates patterns where state resets on every save — like declaring state outside components or using module-level variables.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates components using the feature-based folder structure automatically. Data fetching uses Tanstack Query with proper key factories instead of raw `useEffect` calls. New routes get lazy-loaded with `React.lazy` and `<Suspense>`. State management follows the Zustand slice pattern for server-derived state and local state stays in components. Claude avoids creating barrel exports, uses `import.meta.env` for environment variables, and follows the React Router v7 data router API for all navigation and data loading patterns.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Next.js + TypeScript, Django + PostgreSQL, Rails + Turbo + Stimulus, Rust + Axum, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
