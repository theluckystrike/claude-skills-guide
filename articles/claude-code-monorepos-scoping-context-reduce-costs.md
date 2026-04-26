---
layout: default
title: "Claude Code for Monorepos (2026)"
description: "Reduce Claude Code costs in monorepos by 50-70% with context scoping techniques including nested CLAUDE.md, package boundaries, and targeted file access."
permalink: /claude-code-monorepos-scoping-context-reduce-costs/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code for Monorepos: Scoping Context to Reduce Costs

## The Pattern

Monorepo context scoping restricts Claude Code's file access and knowledge loading to the relevant package or module, preventing the agent from scanning the entire repository for every task.

## Why It Matters for Token Cost

Monorepos amplify Claude Code costs because the file tree is 5-50x larger than a single-package project. A monorepo with 5 packages, each containing 200 files, presents 1,000+ files to Claude's search tools. Without scoping, a task in one package triggers file reads across all packages.

Measured impact on a typical 5-package monorepo:
- Unscoped session (Claude explores freely): 200K-500K tokens per task
- Scoped session (Claude restricted to relevant package): 40K-100K tokens per task
- **Savings: 60-80% per task**

At $3/MTok (Sonnet input), a developer running 15 tasks/day saves $7.20-$26.40/day, or **$158-$581/month** with proper scoping. On Opus 4.6, savings scale to **$792-$2,904/month**.

## The Anti-Pattern (What NOT to Do)

```
monorepo/
  CLAUDE.md  # 2,000-token monolith describing ALL packages
  packages/
    api/
    web/
    shared/
    mobile/
    admin/
```

```markdown
# BAD CLAUDE.md -- describes everything, loaded every session

## API Package
Express REST API with 23 routes, PostgreSQL via Prisma...
[500 tokens of API details]

## Web Package
Next.js frontend with 45 pages, TailwindCSS...
[500 tokens of web details]

## Shared Package
TypeScript utilities and type definitions...
[300 tokens of shared details]

## Mobile Package
React Native app with 30 screens...
[400 tokens of mobile details]

## Admin Package
Internal admin dashboard, Vue.js...
[300 tokens of admin details]
```

This 2,000-token CLAUDE.md loads on every session regardless of which package the task targets. Over 30 turns, that is 60,000 tokens of irrelevant context -- $0.18/session on Sonnet.

## The Pattern in Action

### Step 1: Root CLAUDE.md -- Minimal Router

```markdown
# monorepo/CLAUDE.md (~150 tokens)

## Monorepo: my-app
5 packages: api, web, shared, mobile, admin

## Package Map
- packages/api/ -- Express REST API (see packages/api/CLAUDE.md)
- packages/web/ -- Next.js frontend (see packages/web/CLAUDE.md)
- packages/shared/ -- shared types and utils
- packages/mobile/ -- React Native app
- packages/admin/ -- Vue.js admin dashboard

## Cross-Package Rules
- Shared types: packages/shared/src/types/
- Never import directly between api/web/mobile/admin
- All cross-package dependencies go through shared/
```

### Step 2: Package-Level CLAUDE.md Files

```markdown
# packages/api/CLAUDE.md (~250 tokens)

## API Package
Express.js REST API. PostgreSQL via Prisma.

## Structure
- src/routes/ -- 23 endpoint files
- src/services/ -- business logic
- src/repositories/ -- Prisma queries
- src/middleware/ -- auth, rate-limit, validation
- __tests__/ -- Jest tests, mirrors src/

## Commands (run from packages/api/)
- Dev: npm run dev
- Test: npm test -- --testPathPattern="<file>"
- Build: npm run build
- Migrate: npx prisma migrate dev --name <desc>

## Conventions
- Repository pattern, no raw SQL
- Zod validation on all inputs
- JWT auth middleware on protected routes
```

```markdown
# packages/web/CLAUDE.md (~200 tokens)

## Web Package
Next.js 14 with App Router. TailwindCSS.

## Structure
- src/app/ -- routes (file-based)
- src/components/ -- React components (atomic design)
- src/hooks/ -- custom React hooks
- src/lib/ -- utility functions

## Commands (run from packages/web/)
- Dev: npm run dev (port 3001)
- Test: npm test
- Build: npm run build
- Lint: npm run lint
```

### Step 3: Package-Level .claudeignore

```bash
# packages/api/.claudeignore
node_modules/
dist/
coverage/
prisma/migrations/**/migration_lock.toml
```

```bash
# Root .claudeignore
node_modules/
dist/
build/
.git/
*.lock
coverage/
__snapshots__/
# Ignore other packages when working in one (optional, aggressive)
# packages/mobile/
# packages/admin/
```

### Step 4: Package-Scoped Skills

```markdown
# packages/api/.claude/skills/api-routes.md

## API Routes
| Route File | Endpoints | Auth |
|-----------|-----------|------|
| auth.ts | POST /login, /register, /refresh | public |
| users.ts | CRUD /users | auth required |
| posts.ts | CRUD /posts | read:public, write:auth |
| billing.ts | POST /subscribe, /cancel | auth required |
```

## Before and After

| Metric | Unscoped Monorepo | Scoped Monorepo | Savings |
|--------|-------------------|-----------------|---------|
| CLAUDE.md tokens per turn | 2,000 | 150-400 | 80-92% |
| Files in search scope | 1,000+ | 100-200 | 80-90% |
| Exploration tokens per task | 80K-200K | 10K-30K | 75-85% |
| Cross-package reads (waste) | 50K-150K | 0-5K | 95-100% |
| Average task cost (Sonnet) | $0.90-$2.10 | $0.18-$0.45 | 78-80% |
| Monthly per developer (Sonnet) | $396-$924 | $79-$198 | 78-80% |

## When to Use This Pattern

- Monorepos with 3+ packages
- Monorepos where most tasks target a single package
- Teams where multiple developers work on different packages
- Any repository with more than 500 files

## When NOT to Use This Pattern

- Small repositories (under 200 files) where scoping overhead exceeds savings
- Projects where every task genuinely touches all packages
- Solo projects with a single package (use standard CLAUDE.md instead)

## Implementation in CLAUDE.md

```markdown
# monorepo/CLAUDE.md

## Context Scoping Rules
- When a task targets a specific package, work ONLY within that package directory
- Read the package-level CLAUDE.md before starting work
- Never read files from other packages unless explicitly asked
- If a change requires modifying shared/, ask before proceeding
- Maximum 5 files read outside the target package per task

## Package Isolation
- Each package has its own CLAUDE.md, skills, and .claudeignore
- Run commands from the package directory, not the monorepo root
- Use package-specific test commands (not monorepo-wide test)
```

## Advanced Scoping: Cross-Package Task Protocol

Some tasks genuinely require cross-package changes. Without a protocol, these tasks trigger monorepo-wide exploration. A structured cross-package protocol limits exploration to only the packages involved.

```markdown
# monorepo/CLAUDE.md -- Cross-Package Protocol

## Cross-Package Changes
When a task requires changes across packages:
1. Identify all affected packages BEFORE starting (ask if unclear)
2. Load CLAUDE.md from each affected package
3. Make changes in shared/ FIRST (type definitions, utilities)
4. Then update each consuming package sequentially
5. Run tests per-package, not monorepo-wide
6. Maximum 3 packages per task -- decompose larger changes

## Cross-Package Dependency Rules
- shared/ types are consumed by: api, web, mobile, admin
- api/ exposes endpoints consumed by: web, mobile, admin
- No direct imports between web/mobile/admin -- use shared/
```

### Real-World Cross-Package Example

A task like "add user preferences to the API and display them on the web dashboard" touches 3 packages:

**Without scoping:** Claude scans all 5 packages (1,000 files), reads 30+ files, spawns 5 subagents. Token cost: 300K-500K ($0.90-$1.50 Sonnet).

**With scoping protocol:**
1. Identify packages: shared/ (types), api/ (endpoint), web/ (display)
2. Load 3 package CLAUDE.md files: ~750 tokens
3. Sequential changes: shared types (5K tokens) -> API endpoint (15K tokens) -> web component (15K tokens)
4. Per-package tests: 3 x 5K = 15K tokens
5. Total: ~51K tokens ($0.15 Sonnet)

**Savings: 83-90% per cross-package task.**

## Tooling Integration

### Turborepo Scoping

For monorepos using Turborepo, use its dependency graph to scope Claude Code:

```bash
# Run tests only for affected packages (not entire monorepo)
npx turbo test --filter=api

# Build only changed packages
npx turbo build --filter=...[HEAD^1]
```

Add these commands to the package-level CLAUDE.md files:

```markdown
# packages/api/CLAUDE.md
## Commands
- Test (this package only): npx turbo test --filter=api
- Build (this package only): npx turbo build --filter=api
- Test affected: npx turbo test --filter=...[HEAD^1]
```

Using scoped turbo commands instead of monorepo-wide commands reduces build/test output from 5,000-20,000 tokens to 500-3,000 tokens per run.

### Nx Scoping

For Nx monorepos:

```bash
# Affected commands only build/test what changed
nx affected --target=test
nx affected --target=build

# Specific project
nx test api
nx build web
```

### pnpm Workspace Scoping

```bash
# Run commands in a specific package
pnpm --filter api test
pnpm --filter web build
```

## Measuring Monorepo Scoping Effectiveness

Track these metrics weekly to verify scoping is working:

```bash
# Count files read per session (estimate from token usage)
# Target: 5-10 files for single-package tasks
# Red flag: 20+ files for single-package tasks

# Check /cost at task boundaries
/cost
# Single-package task target: under 50K tokens
# Cross-package task target: under 100K tokens

# Monitor with ccusage
ccusage --period week --by-project
# Compare costs between monorepo projects and single-package projects
# Monorepo tasks should cost no more than 1.5x equivalent single-package tasks
```

## Common Monorepo Mistakes with Claude Code

### Mistake 1: Running Commands at Root Level

```bash
# BAD: runs tests across all packages
npm test
# Output: 800 tests, 20,000 tokens of output, 10 minutes

# GOOD: runs tests in the target package only
cd packages/api && npm test -- --testPathPattern="users"
# Output: 12 tests, 800 tokens of output, 30 seconds
```

Monorepo-wide commands produce output proportional to the total number of packages. A 5-package monorepo produces 5x the output of a single-package project, and all of that output enters the context window.

### Mistake 2: Single CLAUDE.md Describing Everything

A monolithic CLAUDE.md that describes all packages loads unnecessary context for every task. The cost: 2,000 tokens per turn for a 5-package description, versus 200-400 tokens for a single-package description. Over 30 turns: 60,000 vs 6,000-12,000 tokens. Savings from scoping: 80%.

### Mistake 3: Not Using .claudeignore in Package Directories

Each package should have its own .claudeignore to exclude package-specific build artifacts:

```bash
# packages/web/.claudeignore
.next/
out/
node_modules/

# packages/api/.claudeignore
dist/
node_modules/
prisma/migrations/**/migration_lock.toml
```

### Mistake 4: Cross-Package Subagents

Spawning subagents that each explore different packages creates massive duplication. Each subagent loads its own CLAUDE.md, scans its package directory, and builds independent context. For a 3-package task with 3 subagents: 3 x 5K overhead + 3 x 20K exploration = 75K tokens in duplicated work.

**Fix:** Sequential cross-package work is cheaper than parallel subagents when packages share dependencies or require coordinated changes.

## Dynamic Scoping for Polyglot Monorepos

Monorepos that mix languages (TypeScript backend, Swift mobile, Python ML) require dynamic scoping because the conventions, build tools, and test frameworks differ per package. A single set of CLAUDE.md rules cannot cover all languages effectively.

```markdown
# monorepo/CLAUDE.md -- Polyglot Routing

## Language-Specific Conventions
- TypeScript packages (api, web, admin): see packages/<name>/CLAUDE.md
- Swift packages (ios): see packages/ios/CLAUDE.md
- Python packages (ml-pipeline): see packages/ml-pipeline/CLAUDE.md

## Build Tool Map
- TypeScript: npm/pnpm (managed by turborepo)
- Swift: xcodebuild (Xcode 16+)
- Python: poetry run pytest
```

Each language package gets its own CLAUDE.md with language-appropriate commands, test patterns, and linting rules. This prevents Claude from applying TypeScript conventions to Python code or vice versa -- a mistake that costs 5K-15K tokens in retries per incident.

### Scoping Metrics to Track

Monitor these weekly to ensure scoping remains effective as the monorepo evolves:

| Metric | Target | Red Flag |
|--------|--------|----------|
| Files read per single-package task | 5-10 | 20+ |
| Cross-package reads per task | 0-2 | 5+ |
| Orientation tokens (before first edit) | Under 15K | Over 40K |
| Build/test output tokens | Under 3K | Over 10K |

When any metric exceeds the red flag threshold for three consecutive tasks, update the package CLAUDE.md and .claudeignore. The monorepo is evolving faster than the scoping configuration, and the gap creates token waste.



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Multi-Agent Token Budgeting](/multi-agent-token-budgeting-allocate-subagents/) -- controlling subagents in monorepos
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- understanding context growth
- [Why Claude Code Gets Expensive on Large Projects](/why-claude-code-expensive-large-projects-fix/) -- general large project optimization
