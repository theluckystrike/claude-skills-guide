---
layout: default
title: "Claude Code Caching (2026)"
description: "Claude Code re-discovers project structure every session, wasting 5,000-15,000 tokens. Caching strategies using skills and CLAUDE.md eliminate repeat discovery."
permalink: /claude-code-caching-strategies-dont-rediscover/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Caching Strategies: Don't Re-Discover What You Already Know

## The Pattern

The caching pattern pre-computes frequently-needed project knowledge into files that Claude Code reads instead of re-discovering through tool calls. Like a software cache (store expensive computations for cheap retrieval), these files store the results of expensive exploration sequences so that subsequent sessions start with full knowledge at a fraction of the token cost.

## Why It Matters for Token Cost

Claude Code has no memory between sessions. Every new session starts from zero knowledge of the project. Without caching, the first 5-10 tool calls of every session are identical: read the project structure, find key files, understand conventions. This "cold start" costs 5,000-15,000 tokens per session.

A cached project knowledge file (CLAUDE.md + skills) provides the same information in 200-1,000 tokens. Over 100 monthly sessions, the savings are 480,000-1,400,000 tokens -- $1.44-$4.20 per month on Sonnet 4.6 input alone.

The cost mechanism: each token saved in the first turn saves that same token on every subsequent turn (because conversation history is re-sent). A 10,000-token cold start in turn 1 accumulates to 10,000 x 20 turns = 200,000 tokens of unnecessary input across a 20-turn session.

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: Claude Code discovers the same information every session

# Session 1 (Monday):
# > Read package.json (245 tokens + 2,000 response)
# > Glob for source files (245 tokens + 500 response)
# > Read src/index.ts (150 tokens + 1,500 response)
# > Read tsconfig.json (150 tokens + 800 response)
# > Grep for "export" in routes/ (245 tokens + 600 response)
# Discovery cost: ~6,435 tokens

# Session 2 (Monday afternoon):
# Same discovery sequence: ~6,435 tokens
# Nothing changed. Pure waste.

# Session 3 (Tuesday):
# Same discovery sequence: ~6,435 tokens
# 19,305 tokens spent discovering the SAME unchanging facts
```

## The Pattern in Action

### Step 1: Cache Project Structure

After the first session's discovery, capture the findings:

```markdown
# CLAUDE.md -- Cached Project Knowledge (~300 tokens)

## Project: user-management-api
## Stack: TypeScript, Express, Prisma, PostgreSQL
## Entry point: src/index.ts
## Build: `pnpm build` (output: dist/)
## Test: `pnpm test` (Jest)
## Lint: `pnpm lint` (ESLint)

## Directory Map
- src/routes/ -- API endpoints (users.ts, auth.ts, billing.ts)
- src/services/ -- Business logic (one service per route file)
- src/middleware/ -- Auth (JWT), validation (Zod), rate limiting
- prisma/schema.prisma -- 15 models, PostgreSQL

## Conventions
- Functional style, no classes
- All handlers: async (req, res) => Result<T, Error>
- Error responses: { error: { code, message } }
```

This 300-token file replaces the 6,435-token discovery sequence.

### Step 2: Cache Frequently-Read Files as Summaries

Large files that Claude reads repeatedly (but only needs partial information from) can be summarized in skills:

```markdown
# .claude/skills/schema-cache.md -- Cached schema summary (~400 tokens)

## Database Models (15 models, last updated 2026-04-22)

### Core Models
- User: id, email (unique), name, role (USER|ADMIN), createdAt
- Session: id, userId->User, token (unique), expiresAt, ip
- Subscription: id, userId->User, plan (FREE|PRO|TEAM), status, stripeId

### Business Models
- Invoice: id, userId->User, amountCents, status, paidAt
- Team: id, name, ownerId->User, plan
- TeamMember: id, teamId->Team, userId->User, role

### Supporting Models
- AuditLog: id, userId, action, resource, ts
- ApiKey: id, userId->User, keyHash, lastUsed, expiresAt
- Webhook: id, teamId->Team, url, events[], active
```

Reading the full schema.prisma: ~3,000-5,000 tokens. Reading this cached summary: ~400 tokens.

**Savings: 2,600-4,600 tokens per schema lookup**

### Step 3: Auto-Regenerate Caches

```bash
#!/bin/bash
# scripts/update-claude-cache.sh
# Regenerates cached knowledge files when source changes
set -euo pipefail

CACHE_DIR=".claude/skills"
mkdir -p "$CACHE_DIR"

# Regenerate schema cache if schema changed
if git diff --name-only HEAD~1 | grep -q "prisma/schema.prisma"; then
  echo "Schema changed -- regenerating cache..."
  ./scripts/generate-schema-summary.sh
fi

# Regenerate route cache if routes changed
if git diff --name-only HEAD~1 | grep -q "src/routes/"; then
  echo "Routes changed -- regenerating route map..."

  echo "# Route Map (auto-generated $(date +%Y-%m-%d))" > "$CACHE_DIR/routes.md"
  echo "" >> "$CACHE_DIR/routes.md"

  # Extract route definitions (bounded: max 100 routes)
  grep -rn "router\.\(get\|post\|put\|delete\)" src/routes/ | head -100 | \
    sed 's/.*router\./- /' >> "$CACHE_DIR/routes.md"
fi

echo "Cache update complete"
```

Add to git hooks for automatic maintenance:

```bash
# .git/hooks/post-commit (append to existing)
./scripts/update-claude-cache.sh 2>/dev/null || true
```

## Before and After

| Metric | No Caching | With Caching | Savings |
|--------|-----------|-------------|---------|
| Discovery tokens (per session) | 5,000-15,000 | 300-1,000 | 80-93% |
| Schema lookup | 3,000-5,000 | 400 | 87-92% |
| Route discovery | 2,000-4,000 | 200 | 90-95% |
| Convention inference | 3,000-6,000 | 150 | 95-98% |
| **Total per session** | **13,000-30,000** | **1,050-1,750** | **88-94%** |
| **Monthly (100 sessions, Sonnet 4.6)** | **$3.90-$9.00** | **$0.32-$0.53** | **$3.58-$8.47** |

### Step 4: Cache Test Patterns and Common Commands

Beyond structure and schema, cache the commands and patterns that Claude Code uses repeatedly:

```markdown
# .claude/skills/common-commands.md

## Testing
- Unit tests: `pnpm test` (Jest, ~30 seconds)
- Integration tests: `pnpm test:integration` (needs Docker, ~2 minutes)
- Single file: `pnpm test -- src/services/user.test.ts`
- Watch mode: `pnpm test -- --watch`

## Debugging
- Type check: `npx tsc --noEmit`
- Lint: `npx eslint src/ --quiet`
- Database console: `npx prisma studio`
- Logs: `tail -f logs/app.log`

## Database
- Migrate: `npx prisma migrate dev --name description`
- Generate client: `npx prisma generate`
- Seed: `npx tsx scripts/seed.ts`
- Reset: `npx prisma migrate reset` (WARNING: deletes all data)
```

Without this cache, Claude Code discovers these commands through package.json reading (~2,000 tokens), README scanning (~3,000 tokens), or trial and error (~1,000+ tokens per failed attempt). The cache provides all commands in ~200 tokens.

**Savings: 3,000-6,000 tokens per session that involves testing or database operations**

## When to Use This Pattern

- **Stable projects**: Codebases where structure changes infrequently (weekly or less).
- **Team environments**: Where multiple developers run Claude Code sessions on the same project daily.
- **Large codebases**: Where discovery is especially expensive (100K+ lines of code).

### Step 5: Cache Validation

Ensure cached knowledge stays accurate with automated checks:

```bash
#!/bin/bash
# scripts/validate-caches.sh
# Check that cached knowledge files match current source
set -euo pipefail

echo "=== Cache Validation ==="
STALE=0

# Check if schema cache matches current schema
if [ -f ".claude/skills/schema-cache.md" ] && [ -f "prisma/schema.prisma" ]; then
  CACHE_DATE=$(grep "last updated" .claude/skills/schema-cache.md | grep -o '[0-9-]*' || echo "unknown")
  SCHEMA_MOD=$(stat -f%Sm -t%Y-%m-%d prisma/schema.prisma 2>/dev/null || stat -c%y prisma/schema.prisma | cut -d' ' -f1)

  if [ "$CACHE_DATE" != "$SCHEMA_MOD" ]; then
    echo "STALE: schema-cache.md (cached: $CACHE_DATE, schema modified: $SCHEMA_MOD)"
    echo "  Run: ./scripts/generate-schema-summary.sh"
    STALE=$((STALE + 1))
  else
    echo "OK: schema-cache.md is current"
  fi
fi

# Check if route cache matches current routes
if [ -f ".claude/skills/routes.md" ]; then
  ROUTE_FILES_CHANGED=$(git diff --name-only HEAD~5 | grep "src/routes/" | wc -l | tr -d ' ')
  if [ "$ROUTE_FILES_CHANGED" -gt 0 ]; then
    echo "STALE: routes.md ($ROUTE_FILES_CHANGED route files changed in last 5 commits)"
    echo "  Run: ./scripts/update-claude-cache.sh"
    STALE=$((STALE + 1))
  else
    echo "OK: routes.md is current"
  fi
fi

# Check if CLAUDE.md references match reality
if [ -f "CLAUDE.md" ]; then
  REFERENCED_FILES=$(grep -oP '`[^`]+\.(ts|js|json)`' CLAUDE.md | tr -d '`' | head -20)
  for ref in $REFERENCED_FILES; do
    if [ ! -f "$ref" ]; then
      echo "STALE: CLAUDE.md references $ref but file does not exist"
      STALE=$((STALE + 1))
    fi
  done
fi

echo ""
if [ "$STALE" -eq 0 ]; then
  echo "All caches current."
else
  echo "$STALE stale cache(s) found. Run regeneration scripts."
fi
```

Add this to the CI pipeline or run weekly to prevent cache drift. Stale caches are worse than no caches -- they provide wrong information that leads to incorrect implementations, triggering expensive error-and-retry cycles.

## When NOT to Use This Pattern

- **Rapidly evolving prototypes**: If the project structure changes multiple times per day, caches go stale quickly. The maintenance cost may exceed the savings.
- **Single-session projects**: One-off scripts or throwaway projects that have 1-2 sessions total do not benefit from caching.

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md

## Cached Knowledge
- Project structure is described in this file. Do NOT re-discover with Glob/Grep.
- Schema summary: see database-schema skill (regenerated on schema changes)
- Route map: see routes skill (regenerated on route changes)
- Read source files only when making changes or when cached info is insufficient.
```

This instruction explicitly tells Claude Code to trust the cache, preventing redundant discovery.

### Cache Maintenance Schedule

Establish a maintenance cadence to keep caches useful:

```markdown
## Cache Refresh Schedule
- Schema cache: regenerate after every migration (automated via git hook)
- Route cache: regenerate after adding/removing API endpoints (weekly manual check)
- CLAUDE.md architecture map: review monthly or after major refactors
- Command cache: update when tooling changes (new build tool, new test runner)
- Dependency summary: update quarterly or after major version upgrades
```

A consistent refresh schedule prevents the most common caching failure: stale information that causes Claude Code to write code against outdated structures, triggering expensive error-and-fix cycles that cost 3,000-10,000 tokens per incident. The refresh effort (5-10 minutes per week) is minimal compared to the potential token waste from stale caches.

## Related Guides

- [Progressive Disclosure in CLAUDE.md: Load Only What You Need](/progressive-disclosure-claude-md-load-only-needed/) -- structure cached knowledge for efficient loading
- [Claude Code for Large Codebases: Cost-Effective Strategies](/claude-code-large-codebases-cost-effective-strategies/) -- caching as part of large codebase strategy
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- broader context optimization
