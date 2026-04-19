---
layout: default
title: "Claude Code for Sentry Errors — Workflow Guide"
description: "Integrate Sentry error tracking with Claude Code setup. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-sentry-error-tracking-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, sentry, workflow]
---

## The Setup

You are integrating Sentry for error tracking, performance monitoring, and session replay in your application. Sentry captures errors with full stack traces, breadcrumbs, and context. Claude Code can set up Sentry instrumentation, but it uses outdated SDK patterns and misses framework-specific integration points.

## What Claude Code Gets Wrong By Default

1. **Uses the deprecated `@sentry/browser` directly.** Claude imports from the generic package. Modern Sentry uses framework-specific SDKs: `@sentry/nextjs`, `@sentry/react`, `@sentry/node` — each with framework-aware auto-instrumentation.

2. **Initializes Sentry with only the DSN.** Claude writes `Sentry.init({ dsn: '...' })` without configuring traces, replays, or environment. Missing `tracesSampleRate`, `replaysSessionSampleRate`, and `environment` means you get errors but no performance data or session context.

3. **Wraps everything in manual try/catch.** Claude adds try/catch blocks sending errors with `Sentry.captureException()`. Modern Sentry SDKs automatically capture unhandled errors and promise rejections — manual capture is only for handled errors.

4. **Ignores source maps.** Claude deploys without uploading source maps. Sentry errors show minified code without source maps, making debugging impossible. The build must upload maps to Sentry.

## The CLAUDE.md Configuration

```
# Sentry Error Tracking Project

## Monitoring
- Errors: Sentry (@sentry/nextjs for Next.js)
- Performance: Sentry tracing (tracesSampleRate)
- Replay: Session replay for debugging user issues
- Source maps: Uploaded on build via Sentry webpack/vite plugin

## Sentry Rules
- Use framework-specific SDK, not @sentry/browser
- Init in sentry.client.config.ts and sentry.server.config.ts (Next.js)
- Set environment: 'production', 'staging', 'development'
- tracesSampleRate: 0.1 in prod (10% of transactions)
- replaysSessionSampleRate: 0.1 (10% of sessions)
- Source maps uploaded by @sentry/nextjs plugin automatically
- Custom context: Sentry.setUser({ id, email }) after auth
- Never send PII in breadcrumbs or extra context

## Conventions
- Sentry config files at project root (framework convention)
- Error boundaries: Sentry.ErrorBoundary wrapper for React
- Custom errors: Sentry.captureException(error, { tags: { ... } })
- Breadcrumbs: automatic from navigation, fetch, console
- Performance: auto-instrument API routes and page loads
- Alerts configured in Sentry dashboard, not code
- DSN in environment variable: NEXT_PUBLIC_SENTRY_DSN
```

## Workflow Example

You want to set up Sentry for a Next.js app with error boundaries and performance monitoring. Prompt Claude Code:

"Integrate Sentry into this Next.js project. Set up client and server configs, add error boundaries for React components, configure performance tracing at 10% sample rate, enable session replay, and ensure source maps are uploaded on build."

Claude Code should install `@sentry/nextjs`, run the Sentry wizard or create `sentry.client.config.ts` and `sentry.server.config.ts` with proper init, wrap the root layout with `Sentry.ErrorBoundary`, configure `next.config.js` with the Sentry plugin for source map uploads, and set sample rates for traces and replays.

## Common Pitfalls

1. **Source maps in production bundles.** Claude configures source map uploads but also ships `.map` files to production. Set `productionBrowserSourceMaps: false` in `next.config.js` — upload maps to Sentry but do not serve them publicly, as they expose your source code.

2. **Over-sampling in production.** Claude sets `tracesSampleRate: 1.0` (100%) in production. This generates massive volume and costs. Use `0.1` (10%) for production and `1.0` only in development.

3. **Missing user context.** Claude sets up Sentry but never calls `Sentry.setUser()` after authentication. Without user context, you cannot tell which users are affected by errors, making it harder to prioritize fixes and communicate with affected customers.

## Related Guides

- [Claude Code for Amplitude Analytics Workflow](/claude-code-for-amplitude-analytics-workflow/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [AI Tools for Incident Debugging and Postmortems](/ai-tools-for-incident-debugging-and-postmortems/)

## Related Articles

- [Fix Next.js Hydration Errors Using Claude Code](/claude-code-next-js-hydration-error-fix/)
- [Fix Claude Code Remix Error Boundaries Nested — Quick Guide](/claude-code-remix-error-boundaries-nested-routes-guide/)
- [Fix Claude Opus Prefill Not Supported Error — Quick Guide](/claude-opus-prefill-not-supported-error-fix/)
- [Fix Claude Code Esm Module Not Found Import — Quick Guide](/claude-code-esm-module-not-found-import-error-fix/)
- [Claude Code for Remix Error Boundary Workflow Guide](/claude-code-for-remix-error-boundary-workflow-guide/)
- [Fix Skill Name Already in Use: Resolve Claude Code Naming Conflicts — 2026](/fix-skill-name-already-in-use-error/)
- [Fix Claude Code Spawn Unknown Error When Running Skill Scripts — 2026](/fix-claude-code-spawn-unknown-error-skills/)
