---
layout: default
title: "10 CLAUDE.md Templates for Different Project Types (2026)"
description: "Ready-to-use CLAUDE.md templates for React, API, CLI, monorepo, data pipeline, mobile, Chrome extension, microservices, static site, and ML projects."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /10-claude-md-templates-project-types/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, claude-md, templates, project-setup]
---

# 10 CLAUDE.md Templates for Different Project Types

A CLAUDE.md tuned for a React SPA looks nothing like one for a data pipeline or a CLI tool. Each project type has different file structures, testing patterns, forbidden operations, and coding conventions that Claude needs to know. These 10 templates cover the most common project types -- copy the one that matches yours, customize the specifics, and drop it in your project root. Or use the [CLAUDE.md Generator](/generator/) to build a customized version automatically.

## 1. React SPA

```markdown
# Project: React Single Page Application
Tech: React 19, TypeScript, Vite, TanStack Query, Tailwind CSS

# Commands
- Dev: `pnpm dev` (port 5173)
- Build: `pnpm build`
- Test: `pnpm vitest run`

# Architecture
/src/pages      → Route components (file-based routing)
/src/components → Reusable UI (no business logic)
/src/hooks      → Custom hooks (data fetching, state)
/src/lib        → Utilities and API client

# Rules
- Functional components only, no class components
- Co-locate styles with components (module CSS or Tailwind)
- All API calls through TanStack Query hooks in /hooks
- Never store derived state -- compute it
```

## 2. API Server

```markdown
# Project: REST API Server
Tech: Node.js, Hono, TypeScript, Drizzle ORM, PostgreSQL

# Commands
- Dev: `pnpm dev`
- Test: `pnpm test`
- Migrate: `pnpm drizzle-kit push`

# Architecture
/src/routes     → Route handlers (validation + response only)
/src/services   → Business logic (no DB imports here)
/src/db         → Drizzle schema and queries
/src/middleware  → Auth, rate limiting, error handling

# Rules
- Validate all inputs with Zod schemas
- Services never import from db directly -- use repository pattern
- Return proper HTTP status codes (201 for creation, 204 for deletion)
- All endpoints need integration tests
```

## 3. CLI Tool

```markdown
# Project: CLI Tool
Tech: Node.js, TypeScript, Commander.js, chalk

# Commands
- Build: `pnpm build`
- Test: `pnpm test`
- Run locally: `node dist/index.js`

# Architecture
/src/commands   → One file per CLI command
/src/lib        → Shared utilities
/src/prompts    → Interactive prompt definitions

# Rules
- Every command must have --help text
- Use stderr for progress/status, stdout for data output
- Support --json flag for machine-readable output
- Exit code 0 = success, 1 = user error, 2 = system error
- No interactive prompts when stdin is not a TTY
```

## 4. Monorepo

```markdown
# Project: Monorepo
Tech: pnpm workspaces, Turborepo, TypeScript

# Commands
- Build all: `pnpm turbo build`
- Test all: `pnpm turbo test`
- Dev (specific): `pnpm --filter @app/web dev`

# Structure
/packages/ui        → Shared component library
/packages/config    → Shared tsconfig, eslint
/apps/web           → Next.js frontend
/apps/api           → Hono API server
/packages/db        → Shared database client

# Rules
- Never use relative imports across package boundaries
- Use workspace protocol: "workspace:*"
- Shared types go in @app/types package
- Each package has its own tsconfig extending packages/config
```

## 5. Data Pipeline

```markdown
# Project: Data Pipeline
Tech: Python 3.12, Polars, DuckDB, Prefect

# Commands
- Run: `python -m pipeline.main`
- Test: `pytest tests/ -v`
- Lint: `ruff check . --fix`

# Architecture
/pipeline/extract    → Data source connectors
/pipeline/transform  → Transformation steps (pure functions)
/pipeline/load       → Output writers (Parquet, DB)
/pipeline/schemas    → Pandera/Pydantic validation schemas

# Rules
- Transform functions must be pure -- no side effects
- Validate data at every boundary (extract output, transform output)
- Use Polars lazy frames, call .collect() only at pipeline boundaries
- Log row counts at every step
- Never hardcode file paths -- use environment variables
```

## 6. Mobile App (React Native)

```markdown
# Project: Mobile App
Tech: React Native 0.76, Expo, TypeScript, Zustand

# Commands
- Dev: `npx expo start`
- Test: `pnpm jest`
- Build: `eas build --profile preview`

# Architecture
/app            → Expo Router file-based routes
/components     → Shared UI components
/stores         → Zustand state stores
/services       → API client and business logic

# Rules
- Test on both iOS and Android before marking complete
- Use Platform.select() for platform-specific code
- Keep bundle size minimal -- lazy load heavy screens
- Use expo-secure-store for sensitive data, never AsyncStorage
```

## 7. Chrome Extension

```markdown
# Project: Chrome Extension (Manifest V3)
Tech: TypeScript, Vite, Chrome APIs

# Commands
- Dev: `pnpm dev` (watch mode + auto-reload)
- Build: `pnpm build` (outputs to /dist)

# Architecture
/src/background     → Service worker (MV3)
/src/content        → Content scripts (DOM access)
/src/popup          → Extension popup UI
/src/options        → Options page

# Rules
- Service worker has no DOM access -- use chrome.scripting
- Content scripts cannot use chrome.storage.sync directly
- Minimize permissions in manifest.json
- Message passing between contexts via chrome.runtime
- All chrome API calls must handle the case where the extension is disabled
```

## 8. Microservices

```markdown
# Project: Microservices Architecture
Tech: Go, gRPC, Protocol Buffers, Docker, Kubernetes

# Commands
- Build: `make build`
- Test: `make test`
- Proto: `make proto-gen`
- Local: `docker compose up`

# Architecture
/services/user      → User service
/services/order     → Order service
/proto              → Shared protobuf definitions
/infra/k8s          → Kubernetes manifests

# Rules
- Each service owns its database -- no shared databases
- Inter-service communication via gRPC only
- Every service must have health check and readiness endpoints
- Use structured logging (zerolog) with correlation IDs
- Circuit breaker on all outbound calls
```

## 9. Static Site (Jekyll/11ty)

```markdown
# Project: Static Site
Tech: Jekyll, Liquid, Markdown, SCSS

# Commands
- Dev: `bundle exec jekyll serve --livereload`
- Build: `JEKYLL_ENV=production bundle exec jekyll build`

# Architecture
/_posts         → Blog posts (YYYY-MM-DD-slug.md)
/_layouts       → HTML layouts
/_includes      → Reusable HTML partials
/assets/css     → SCSS source files

# Rules
- Every post needs title, date, description, permalink in frontmatter
- Images go in /assets/img/ with descriptive filenames
- Use include tags for repeated HTML, not copy-paste
- Optimize images before committing (max 200KB)
```

## 10. ML Project

```markdown
# Project: ML Pipeline
Tech: Python 3.12, PyTorch, Weights & Biases, DVC

# Commands
- Train: `python train.py --config configs/base.yaml`
- Evaluate: `python evaluate.py --checkpoint runs/latest`
- Test: `pytest tests/ -v`

# Architecture
/data           → DVC-tracked datasets (never commit raw data)
/models         → Model definitions (nn.Module subclasses)
/configs        → YAML experiment configs
/runs           → Training outputs (gitignored)

# Rules
- Never commit model weights or datasets to git
- Log all hyperparameters to W&B at training start
- Every experiment must be reproducible from its config YAML
- Use torch.compile() for production inference
- Pin all dependency versions in requirements.txt
```

## Try It Yourself

These templates are starting points. Your project has specific patterns, forbidden operations, and conventions that need to be captured. The [CLAUDE.md Generator](/generator/) asks targeted questions about your stack and generates a complete, customized CLAUDE.md that goes beyond these templates. Generate yours, review it, and paste it into your project root.

<details>
<summary>Should I modify these templates or use them as-is?</summary>
Always modify them. These templates provide the structure and common rules, but your project has specific conventions -- naming patterns, directory structures, testing requirements, forbidden packages -- that only you know. Treat these as a starting point and add your project-specific rules.
</details>

<details>
<summary>What if my project combines multiple types?</summary>
Combine the relevant sections. A monorepo with a React frontend and API backend would merge templates 1, 2, and 4. Put shared rules in the root CLAUDE.md and package-specific rules in subdirectory CLAUDE.md files.
</details>

<details>
<summary>How often should I update my CLAUDE.md?</summary>
Update it whenever Claude consistently gets something wrong or when you add a major architectural change. Most teams update their CLAUDE.md 2-3 times per month. A stale CLAUDE.md is better than no CLAUDE.md, but an accurate one saves the most tokens.
</details>

<details>
<summary>Do these templates work with the CLAUDE.md Generator?</summary>
The CLAUDE.md Generator produces output in the same format as these templates. You can use the generator to create a base config and then manually add sections from these templates that apply to your project type.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should I modify these CLAUDE.md templates or use them as-is?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Always modify them. These templates provide the structure and common rules, but your project has specific conventions -- naming patterns, directory structures, testing requirements, forbidden packages -- that only you know. Treat these as a starting point and add your project-specific rules."
      }
    },
    {
      "@type": "Question",
      "name": "What if my project combines multiple types?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Combine the relevant sections. A monorepo with a React frontend and API backend would merge templates 1, 2, and 4. Put shared rules in the root CLAUDE.md and package-specific rules in subdirectory CLAUDE.md files."
      }
    },
    {
      "@type": "Question",
      "name": "How often should I update my CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Update it whenever Claude consistently gets something wrong or when you add a major architectural change. Most teams update their CLAUDE.md 2-3 times per month. A stale CLAUDE.md is better than no CLAUDE.md, but an accurate one saves the most tokens."
      }
    },
    {
      "@type": "Question",
      "name": "Do these templates work with the CLAUDE.md Generator?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The CLAUDE.md Generator produces output in the same format as these templates. You can use the generator to create a base config and then manually add sections from these templates that apply to your project type."
      }
    }
  ]
}
</script>

## Related Guides

- [CLAUDE.md Generator](/generator/) -- Generate a customized CLAUDE.md for your specific project
- [Claude Code Starter Guide](/starter/) -- First-time setup guide for Claude Code
- [Claude Code Best Practices](/best-practices/) -- Battle-tested patterns for productive Claude Code sessions
- [Claude Code Configuration Guide](/configuration/) -- All configuration options explained
- [Skill Finder Tool](/skill-finder/) -- Find the right Claude Code skill for your task
