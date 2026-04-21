---
title: "Claude Code for Turborepo Monorepo Management (2026)"
permalink: /claude-code-turborepo-monorepo-management-2026/
description: "Manage JavaScript/TypeScript monorepos with Turborepo and Claude Code. Configure task pipelines, remote caching, and boundary enforcement."
last_tested: "2026-04-22"
domain: "monorepo tooling"
render_with_liquid: false
---
{% raw %}


## Why Claude Code for Turborepo

Turborepo makes JavaScript/TypeScript monorepos fast through intelligent task scheduling and content-aware caching. But configuring it correctly requires understanding the task dependency graph, setting up remote cache for team-wide sharing, configuring package boundaries to prevent import violations, and structuring workspace packages for optimal cache hit rates. Misconfigured pipelines lead to stale caches, unnecessary rebuilds, and CI times worse than without Turborepo.

Claude Code generates turbo.json configurations with correct task dependencies, sets up Vercel Remote Cache or custom S3 backends, and structures workspace packages to maximize cache hit rates across development and CI.

## The Workflow

### Step 1: Initialize Turborepo Workspace

```bash
# Create new monorepo
npx create-turbo@latest my-monorepo

# Or add to existing workspace
cd existing-project
npm install turbo --save-dev
```

### Step 2: Configure Task Pipeline

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "ui": "tui",
  "globalDependencies": [
    "**/.env.*local",
    "tsconfig.base.json"
  ],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "tsconfig.json", "package.json"],
      "outputs": ["dist/**", ".next/**"],
      "outputLogs": "new-only"
    },
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**", "tests/**", "vitest.config.*"],
      "outputs": ["coverage/**"],
      "outputLogs": "new-only"
    },
    "lint": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "biome.json", ".eslintrc.*"],
      "outputs": []
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "tsconfig.json"],
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "db:migrate": {
      "cache": false,
      "dependsOn": []
    }
  }
}
```

```json
// packages/shared-ui/package.json
{
  "name": "@myorg/shared-ui",
  "version": "0.1.0",
  "private": true,
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsup src/index.ts --format esm,cjs --dts",
    "test": "vitest run",
    "lint": "biome check src/",
    "typecheck": "tsc --noEmit",
    "dev": "tsup src/index.ts --watch"
  }
}
```

### Step 3: Configure Remote Cache

```bash
# Vercel Remote Cache (simplest)
npx turbo login
npx turbo link

# Or custom S3 backend
cat > .turbo/config.json << 'EOF'
{
  "teamId": "myteam",
  "apiUrl": "https://turbo-cache.internal.myorg.com"
}
EOF
```

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2  # For turbo change detection
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile

      # Run only affected packages on PRs
      - name: Build (affected only)
        if: github.event_name == 'pull_request'
        run: turbo build --filter='...[HEAD^1]'
        env:
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ secrets.TURBO_TEAM }}

      # Run everything on main
      - name: Build (all)
        if: github.ref == 'refs/heads/main'
        run: turbo build
        env:
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ secrets.TURBO_TEAM }}

      - run: turbo test lint typecheck --concurrency=4
```

### Step 4: Verify

```bash
# Run full pipeline
turbo build test lint typecheck

# Check what would run (dry run)
turbo build --dry=json | jq '.tasks[] | {package: .package, task: .task, cache: .cache.status}'

# Run only affected packages
turbo build --filter='...[main]'

# Show task dependency graph
turbo build --graph=graph.html
```

## CLAUDE.md for Turborepo Monorepo

```markdown
# Turborepo Monorepo Standards

## Domain Rules
- Every package must have build, test, lint, typecheck scripts
- Build output must be in dist/ or .next/ (defined in turbo.json outputs)
- Shared packages use tsup for building (ESM + CJS + DTS)
- Internal packages: prefix with @myorg/ namespace
- Never import from another package's src/ - always from dist/
- Remote cache enabled for all team members and CI
- Use --filter for PR builds to reduce CI time

## File Patterns
- turbo.json (root pipeline configuration)
- packages/*/package.json (workspace packages)
- apps/*/package.json (applications)
- pnpm-workspace.yaml (workspace definition)
- .turbo/config.json (remote cache configuration)

## Common Commands
- turbo build (build all packages in dependency order)
- turbo build --filter=@myorg/api (build specific package)
- turbo build --filter='...[main]' (build affected since main)
- turbo build --dry=json (show what would run)
- turbo build --graph=graph.html (visualize task graph)
- turbo prune --scope=@myorg/api --docker (create minimal Docker context)
```

## Common Pitfalls in Turborepo Management

- **Missing inputs causing stale cache:** If `turbo.json` inputs do not include all files that affect the build (e.g., missing `.env` or config files), Turborepo serves stale cached results. Claude Code audits inputs against actual build dependencies.

- **Circular dependencies between packages:** Package A imports from B and B imports from A. Turborepo cannot resolve the build order. Claude Code detects cycles in package.json dependencies and restructures with a shared-types package.

- **Docker builds ignoring cache:** `turbo prune --docker` creates a minimal context, but multi-stage Dockerfiles must install dependencies before copying source for caching to work. Claude Code generates proper multi-stage Dockerfiles.

## Related

- [Claude Code for Nx Workspace Orchestration](/claude-code-nx-workspace-orchestration-2026/)
- [Claude Code for Biome Formatter Setup](/claude-code-biome-formatter-setup-2026/)
- [Claude Code for Earthly CI Pipeline](/claude-code-earthly-ci-pipeline-2026/)
{% endraw %}
