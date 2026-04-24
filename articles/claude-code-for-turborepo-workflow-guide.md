---
layout: default
title: "Claude Code for Turborepo"
description: "Claude Code for Turborepo — Workflow Guide tutorial with real-world examples, working configurations, best practices, and deployment steps verified for..."
date: 2026-04-18
permalink: /claude-code-for-turborepo-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, turborepo, workflow]
last_tested: "2026-04-22"
---

## The Setup

You are managing a monorepo with Turborepo, Vercel's build system that caches task outputs and runs tasks in parallel based on your dependency graph. Claude Code can configure Turborepo pipelines and manage workspace packages, but it generates sequential build scripts or Lerna configurations instead.

## What Claude Code Gets Wrong By Default

1. **Runs build commands sequentially.** Claude writes `cd packages/a && npm run build && cd ../b && npm run build`. Turborepo runs tasks in parallel respecting dependency order: `turbo run build` handles everything automatically.

2. **Creates Lerna or Nx configuration.** Claude generates `lerna.json` or `nx.json` for monorepo management. Turborepo uses `turbo.json` with a different pipeline configuration format.

3. **Ignores remote caching.** Claude runs every build from scratch. Turborepo can share build caches across your team with remote caching on Vercel — if a teammate already built that exact code, you skip the build entirely.

4. **Misconfigures task dependencies.** Claude adds `dependsOn` entries that create circular dependencies or miss topological ordering. Turborepo needs correct `dependsOn: ["^build"]` (caret means workspace dependencies first) for the build graph.

## The CLAUDE.md Configuration

```
# Turborepo Monorepo

## Build System
- Tool: Turborepo (turbo)
- Config: turbo.json at monorepo root
- Cache: local + Vercel remote cache
- Workspaces: pnpm workspaces (packages/* and apps/*)

## Turborepo Rules
- Define tasks in turbo.json pipeline
- ^build means "run build in dependencies first"
- Cache outputs: turbo.json outputs array per task
- Run tasks: turbo run build (parallel, cached)
- Filter: turbo run build --filter=my-app (single package)
- Remote cache: linked to Vercel team for shared caching
- Env vars: globalEnv and env arrays in turbo.json for cache keys

## Conventions
- turbo.json at root defines all tasks
- Tasks: build, test, lint, typecheck, dev
- Dev task: { persistent: true, cache: false }
- Build outputs: ["dist/**", ".next/**"] in pipeline config
- Environment variables that affect build in env/globalEnv arrays
- Use turbo run lint test typecheck — runs all three in parallel
- Never run tasks manually in individual packages
```

## Workflow Example

You want to configure Turborepo for a monorepo with a Next.js app and shared packages. Prompt Claude Code:

"Set up turbo.json for a monorepo with apps/web (Next.js), packages/ui (component library), and packages/utils (shared utilities). Configure build, dev, lint, and test tasks with proper dependency ordering and cache outputs."

Claude Code should create `turbo.json` with `build` depending on `^build` (workspace deps first) with outputs `[".next/**", "dist/**"]`, `dev` as `{ persistent: true, cache: false }`, `lint` and `test` tasks, and proper `env` arrays listing environment variables that affect each task's cache.

## Common Pitfalls

1. **Missing cache outputs.** Claude defines tasks without the `outputs` array. Turborepo cannot cache tasks that do not declare their outputs — builds run from scratch every time. Always specify which directories are produced by each task.

2. **Env variables not in turbo.json.** Claude sets environment variables that affect the build but does not list them in `turbo.json` `env` or `globalEnv`. Turborepo includes env vars in the cache key — unlisted vars mean stale caches when the variable changes.

3. **Running `dev` tasks with caching.** Claude configures the `dev` task with default caching. Dev servers are long-running and should never be cached. Set `"cache": false` and `"persistent": true` for dev tasks.

## Related Guides

- [What Is the Best Way to Organize Claude Skills in a Monorepo](/what-is-the-best-way-to-organize-claude-skills-in-a-monorepo/)
- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
