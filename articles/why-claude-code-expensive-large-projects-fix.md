---
title: "Why Claude Code Gets Expensive on Large Projects (Fix)"
description: "Discover why Claude Code costs spike on large projects and apply 7 targeted fixes to cut token usage by 50-70% on codebases with 1,000+ files."
permalink: /why-claude-code-expensive-large-projects-fix/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Why Claude Code Gets Expensive on Large Projects (And How to Fix It)

## The Problem

A project with 50 files might cost $3-5/day in Claude Code API usage. Scale that same project to 1,000+ files and costs jump to $30-80/day -- not because the tasks are harder, but because Claude Code's context window fills with irrelevant information. On Opus 4.6 at $15/MTok input and $75/MTok output, a single exploratory session on a large codebase can consume 500K-2M tokens ($7.50-$30 in input alone).

## Quick Wins (Under 5 Minutes)

1. **Create a `.claudeignore` file** listing `node_modules/`, `dist/`, `build/`, `.git/`, `vendor/`, and any generated code directories.
2. **Add a project map to CLAUDE.md** -- 20-30 lines describing the directory structure saves Claude from scanning hundreds of files.
3. **Run `/compact` every 15-20 minutes** during active sessions on large projects.
4. **Set `CLAUDE_CODE_MAX_TURNS=20`** to prevent runaway exploration loops.
5. **Use absolute file paths in every prompt** -- "edit src/api/routes/users.ts" instead of "edit the users route file."

## Deep Optimization Strategies

### Strategy 1: The Project Map Pattern

The single most impactful optimization for large projects. A well-structured CLAUDE.md eliminates 80% of exploratory file reads.

```markdown
# CLAUDE.md

## Architecture Overview
Monorepo with 3 packages: api (Express), web (Next.js), shared (TypeScript libs).

## Directory Map
- packages/api/src/routes/ -- 23 REST endpoints
- packages/api/src/middleware/ -- auth, rate-limit, logging
- packages/api/src/services/ -- business logic (one file per domain)
- packages/web/src/pages/ -- Next.js pages (file-based routing)
- packages/web/src/components/ -- React components (atomic design)
- packages/shared/src/types/ -- shared TypeScript interfaces
- packages/shared/src/utils/ -- shared utility functions

## Key Conventions
- All route files export a single Router
- Services use dependency injection via constructor
- Tests mirror src/ structure in __tests__/
- Database queries only in packages/api/src/repositories/
```

**Token impact:** Loading this CLAUDE.md costs ~400 tokens. Without it, Claude typically reads 20-40 files to build a mental model, costing 40K-120K tokens. That is a 99% reduction in orientation cost.

### Strategy 2: Scoped Workspaces with Nested CLAUDE.md Files

Large monorepos benefit from CLAUDE.md files at multiple levels.

```
project/
  CLAUDE.md              # Top-level: architecture, conventions
  packages/
    api/
      CLAUDE.md          # API-specific: routes, middleware, DB patterns
    web/
      CLAUDE.md          # Web-specific: component patterns, state management
    shared/
      CLAUDE.md          # Shared: type conventions, utility patterns
```

```markdown
# packages/api/CLAUDE.md

## API Package
Express.js REST API. 23 routes, PostgreSQL via Prisma.

## Common Tasks
- Add new route: copy src/routes/_template.ts, register in src/routes/index.ts
- Add migration: npx prisma migrate dev --name <name>
- Run tests: npm test -- --testPathPattern=api

## Database
- Schema: prisma/schema.prisma (source of truth)
- Migrations: prisma/migrations/ (never edit manually)
- Seed: prisma/seed.ts
```

When working in `packages/api/`, Claude loads only the relevant CLAUDE.md files, keeping context lean. Each nested file costs ~200-400 tokens instead of a full project scan at 50K+ tokens.

### Strategy 3: The File Budget Rule

Add an explicit file-reading budget to CLAUDE.md.

```markdown
# CLAUDE.md

## Agent Constraints
- Read at most 5 files before proposing a solution
- If more than 5 files seem relevant, ask the user which to prioritize
- Never read test files unless the task is specifically about tests
- Never read config files unless the task involves configuration
```

**Before:** Average files read per task on a 1,000-file project: 18 files (~90K tokens).
**After:** Average files read per task: 5 files (~25K tokens).
**Monthly savings at 20 tasks/day on Sonnet:** (65K tokens x 20 tasks x 22 days) x $3/MTok = $85.80/month in input alone.

### Strategy 4: Semantic Directory Exclusion

Beyond `.claudeignore`, use CLAUDE.md to set semantic boundaries.

```markdown
# CLAUDE.md

## Out of Scope Directories
These directories should NEVER be read or modified by Claude:
- legacy/ -- deprecated code, do not touch
- scripts/internal/ -- internal DevOps scripts, not relevant to app code
- docs/archive/ -- archived documentation
- e2e/ -- end-to-end tests managed by QA team separately
```

This prevents Claude from reading files that are technically part of the project but irrelevant to development tasks. On a project with 30% legacy code, this eliminates 30% of potential file reads.

### Strategy 5: Task Decomposition for Large Changes

Large tasks on large projects trigger the worst cost behavior: Claude reads many files, builds a huge context, then makes changes across multiple files.

```bash
# Instead of one massive prompt:
# "Migrate all 23 API routes from Express to Fastify"

# Decompose into scoped sessions:
claude "Migrate src/api/routes/users.ts from Express to Fastify.
Reference the migration pattern in CLAUDE.md."

claude "Migrate src/api/routes/posts.ts from Express to Fastify.
Follow the same pattern used in users.ts."

claude "Migrate src/api/routes/comments.ts from Express to Fastify.
Follow the same pattern used in users.ts."
```

**Before (single session):** 800K-1.5M tokens, $2.40-$4.50 on Sonnet.
**After (decomposed):** 23 sessions x 30K tokens = 690K tokens, $2.07 on Sonnet.
The decomposed approach also produces cleaner commits and allows for review between migrations.

### Strategy 6: Incremental Context with /compact

On large projects, run `/compact` aggressively:

```bash
# Start of session
"Add pagination to the users API endpoint"
# ... Claude reads files, makes changes ...

# After completing the task (~80K tokens used)
/compact
# Context reduced to ~20K tokens

# Next task in same session
"Now add pagination to the posts API endpoint"
```

Without `/compact`, the second task starts with 80K tokens of context from the first task, most of which is irrelevant. With `/compact`, it starts with a clean 20K-token summary. Over a day of 8 tasks, this prevents context from growing to 500K+ tokens.

### Strategy 7: Pre-computed Dependency Maps

For large projects, maintain a dependency map that Claude can reference instead of tracing imports.

```markdown
# .claude/skills/dependency-map.md

## Critical Dependency Chains
- User login: routes/auth.ts -> services/auth.ts -> repositories/user.ts -> prisma
- Post creation: routes/posts.ts -> services/posts.ts -> repositories/post.ts -> prisma
- Email sending: services/notification.ts -> providers/email.ts -> resend SDK
- Payment: routes/billing.ts -> services/stripe.ts -> stripe SDK

## Shared Modules (changes here affect many files)
- src/types/api.ts -- used by all 23 route files
- src/middleware/auth.ts -- used by 19 protected routes
- src/utils/validation.ts -- used by all service files
```

**Token savings:** Tracing a dependency chain through imports costs 3-5 file reads (15K-25K tokens). Reading this skill costs ~300 tokens. For dependency-heavy debugging tasks, this saves 98% of orientation tokens.

## Measuring Your Savings

```bash
# Track per-session costs
/cost

# Example output before optimization:
# Session: 487,231 input / 89,442 output
# Cost: $1.46 input + $1.34 output = $2.80 (Sonnet)

# Example output after optimization:
# Session: 142,887 input / 45,231 output
# Cost: $0.43 input + $0.68 output = $1.11 (Sonnet)
# Savings: 60%
```

## Cost Impact Summary

| Technique | Tokens Saved Per Task | Monthly Savings (Sonnet, 20 tasks/day) |
|-----------|----------------------|----------------------------------------|
| Project map in CLAUDE.md | 40K-120K | $52-$158 |
| Nested CLAUDE.md files | 20K-50K | $26-$66 |
| File budget rule | 65K | $86 |
| Semantic exclusion | 15K-30K | $20-$40 |
| Task decomposition | 30-50% overall | $75-$150 |
| Aggressive /compact | 50-70% per session | $100-$200 |
| Dependency maps | 15K-25K per debug task | $20-$33 |

A team of 5 developers on a large project can reasonably expect to reduce Claude Code costs from $3,000/month to $1,000-1,500/month by applying these techniques systematically.

## The Growth Curve: When Projects Cross the Threshold

Projects typically cross the cost threshold -- where optimization becomes essential -- at these file counts:

| File Count | Cost Behavior | Action Required |
|------------|--------------|-----------------|
| 0-50 files | Costs stable, $2-5/day | Basic CLAUDE.md sufficient |
| 50-200 files | Costs rising, $5-15/day | Add .claudeignore, skills |
| 200-500 files | Costs accelerating, $15-30/day | Full context engineering |
| 500-1,000 files | Costs critical, $30-60/day | Monorepo scoping, subagent caps |
| 1,000+ files | Costs unsustainable, $60+/day | All optimizations required |

The transition from 50 to 200 files is the critical window. Teams that implement optimizations during this growth phase maintain flat cost curves. Teams that wait until 500+ files face a much steeper optimization challenge because bad habits and missing documentation have compounded.

## Case Study: Express API Growing from 100 to 800 Files

**Month 1 (100 files, no optimization):**
- Average tokens per task: 45K
- Daily cost (15 tasks, Sonnet): $2.97
- Monthly cost: $65

**Month 6 (400 files, no optimization):**
- Average tokens per task: 130K (2.9x increase)
- Daily cost: $8.58
- Monthly cost: $189 (2.9x increase)

**Month 6 (400 files, with optimization applied at 200 files):**
- Average tokens per task: 52K (only 1.15x increase from baseline)
- Daily cost: $3.43
- Monthly cost: $75

The team that optimized at the 200-file threshold saved $114/month by month 6 and prevented a cost trajectory that would have reached $400+/month by month 12.

**Key insight:** The best time to implement context engineering is when the project has 50-100 files. The second best time is now.

## Emergency Optimization for Already-Large Projects

For teams already at 500+ files with high costs, apply this triage protocol:

```bash
# Emergency Day 1: Create .claudeignore (10 minutes)
# Immediate impact: 30-50% cost reduction on file scanning

# Emergency Day 1: Add project map to CLAUDE.md (20 minutes)
# Immediate impact: 50-70% cost reduction on orientation

# Emergency Day 2: Set environment variables (5 minutes)
export CLAUDE_MODEL="claude-sonnet-4-6"
export CLAUDE_CODE_MAX_TURNS=25
# Immediate impact: prevent worst-case sessions

# Emergency Day 3-5: Create 3-5 skills files (2 hours)
# Impact: 80-95% reduction in domain knowledge exploration

# Week 2: Add structured error wrappers (2 hours)
# Impact: 90% reduction in error-related token waste
```

Expected total cost reduction within 2 weeks: 50-70%, dropping a $400/month spend to $120-$200/month.

The emergency triage prioritizes by immediate impact:
- Day 1 interventions reduce costs by 30-50% (no code changes required, just configuration files)
- Day 2 interventions add 10-15% (environment variable setup)
- Days 3-5 interventions add 15-25% (skills require understanding the codebase)
- Week 2 interventions add 5-10% (structured wrappers require script writing)

Teams that apply the full protocol typically see costs stabilize within 3 weeks and continue declining as skills are refined and .claudeignore coverage expands. The key to sustained improvement is treating context engineering as ongoing maintenance rather than a one-time setup -- allocating 15-30 minutes per week to update skills, expand .claudeignore, and refine CLAUDE.md rules based on the latest `/cost` data.

## Measuring Success on Large Projects

Track these metrics weekly to verify that large-project optimizations are working:

| Metric | Before Optimization | Target After |
|--------|-------------------|-------------|
| Files read per task | 15-30 | 3-8 |
| Tokens per task | 100K-300K | 30K-80K |
| Cost per task (Sonnet) | $0.30-$0.90 | $0.09-$0.24 |
| Sessions exceeding 500K tokens | 20-30% | Under 5% |
| Retry incidents per day | 3-5 | 0-1 |

## Related Guides

- [Claude Code Context Window Management](/claude-code-context-window-management/) -- understanding how context grows
- [Claude Code Monorepos: Scoping Context to Reduce Costs](/claude-code-monorepos-scoping-context-reduce-costs/) -- monorepo-specific strategies
- [Cost Optimization Hub](/cost-optimization/) -- complete cost optimization guide index
