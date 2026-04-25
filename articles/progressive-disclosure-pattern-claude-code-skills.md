---
layout: default
title: "Progressive Disclosure Pattern (2026)"
description: "Apply the progressive disclosure pattern to Claude Code skills for 40-60% token savings by loading context in layers based on task complexity."
permalink: /progressive-disclosure-pattern-claude-code-skills/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Progressive Disclosure Pattern for Claude Code Skills

## What This Means for Claude Code Users

Progressive disclosure loads context in layers: essential information first, detailed information only when needed. Applied to Claude Code skills, this pattern reduces average session token usage by 40-60% compared to loading all project knowledge upfront. A project with 3,000 tokens of domain knowledge can be restructured to load only 200-400 tokens for simple tasks, reserving the full 3,000 tokens for complex work.

## The Concept

In UX design, progressive disclosure shows users basic options first and reveals advanced options on demand. The same principle applies to agent context: load the minimum viable context for the current task, and make additional context available for escalation.

The cost mechanism is straightforward. Every token in the context window is re-read on every turn. A 3,000-token skill loaded for a 30-turn session costs 90,000 input tokens ($0.27 on Sonnet 4.6, $1.35 on Opus 4.6). If the task only required the first 400 tokens of that skill, 86,000 tokens were wasted -- $0.26 on Sonnet or $1.29 on Opus, per session.

Progressive disclosure for Claude Code organizes context into three tiers:

1. **Tier 0 (Always loaded):** CLAUDE.md -- project identity, critical rules, under 400 tokens
2. **Tier 1 (Task-triggered):** Skills -- domain knowledge, loaded when relevant, 200-500 tokens each
3. **Tier 2 (Escalation):** Full file reads -- complete source code, loaded only when Tier 0-1 insufficient

The goal is to resolve as many tasks as possible at Tier 0-1, escalating to Tier 2 only when necessary.

## How It Works in Practice

### Example 1: Three-Tier Database Context

**Tier 0: CLAUDE.md (always loaded, ~50 tokens for DB section)**

```markdown
## Database
- Prisma ORM, PostgreSQL, schema in prisma/schema.prisma
- Repositories in src/repositories/ (one per table)
- Soft deletes on users and posts tables
```

**Tier 1: Database skill (loaded for DB tasks, ~300 tokens)**

```markdown
# .claude/skills/database.md

## Tables
- users: id(uuid), email(unique), password_hash, role(admin|user), created_at, deleted_at
- posts: id(uuid), user_id(FK), title, body, status(draft|published|archived), created_at, deleted_at
- comments: id(uuid), post_id(FK), user_id(FK), body, created_at
- tags: id(uuid), name(unique), slug(unique)
- post_tags: post_id, tag_id (junction)

## Indexes: users(email), posts(user_id, status, created_at), comments(post_id)
## Migrations: npx prisma migrate dev --name <desc>
## Seed: npx prisma db seed
```

**Tier 2: Full schema file (loaded only for complex migrations)**

```bash
# Only when Claude needs the complete Prisma schema:
# Read prisma/schema.prisma (~2,500 tokens)
```

**Cost analysis for 10 database tasks:**
- 7 simple tasks (add field, fix query): resolved at Tier 0-1 = 7 x 350 tokens = 2,450 tokens
- 2 moderate tasks (new table, relation): resolved at Tier 1 = 2 x 350 tokens = 700 tokens
- 1 complex task (migration refactor): escalated to Tier 2 = 1 x 2,850 tokens = 2,850 tokens
- **Total: 6,000 tokens**

Without progressive disclosure, all 10 tasks load the full schema: 10 x 2,850 = 28,500 tokens.
**Savings: 79%.**

### Example 2: Multi-Layer API Documentation

```markdown
# CLAUDE.md (Tier 0 -- ~40 tokens for API section)
## API: Express.js REST, routes in src/api/routes/, JWT auth middleware
```

```markdown
# .claude/skills/api-quick-ref.md (Tier 1 -- ~200 tokens)
## Routes
- /auth: login, register, refresh, logout (public)
- /users: CRUD (auth required, admin for delete)
- /posts: CRUD (public read, auth for mutations)
- /comments: CRUD (auth required)
## Middleware order: cors -> rateLimit -> auth -> validate -> handler
## Response format: { data: T, meta?: { page, total } }
```

```markdown
# .claude/skills/api-detailed.md (Tier 1.5 -- ~500 tokens, loaded for complex API work)
## Route Details
### POST /auth/login
- Body: { email: string, password: string }
- Returns: { accessToken, refreshToken, user: { id, email, role } }
- Errors: 401 (invalid credentials), 429 (rate limited)

### POST /users
- Body: { email, password, role? }
- Auth: admin only
- Validation: email format, password min 8 chars
- Returns: { id, email, role, createdAt }

[... additional endpoints ...]
```

The Tier 1 quick reference resolves 80% of API tasks. The Tier 1.5 detailed reference handles the remaining 20%. Full file reads (Tier 2) are rarely needed.

## Token Cost Impact

Measured across a representative workweek (100 tasks):

| Task Complexity | Percentage | Resolution Tier | Tokens Per Task | Total |
|----------------|------------|-----------------|-----------------|-------|
| Simple | 60% | Tier 0-1 | 300 | 18,000 |
| Moderate | 30% | Tier 1-1.5 | 700 | 21,000 |
| Complex | 10% | Tier 2 | 3,500 | 35,000 |
| **Progressive Total** | | | | **74,000** |
| **Flat loading** | 100% | Always Tier 2 | 3,500 | **350,000** |
| **Savings** | | | | **79%** |

At $3/MTok (Sonnet input), weekly savings: (350K - 74K) x $3/1000 = $0.83/week or $3.59/month per developer in skill-loading costs alone. The real savings come from reduced context accumulation: 276K fewer tokens loaded means 276K fewer tokens carried across every subsequent turn.

Over a 30-turn session with progressive disclosure savings, the compounded reduction is approximately 4.1M tokens/month per developer, worth **$12.30/month on Sonnet or $61.50/month on Opus.**

## Implementation Checklist

- [ ] Audit existing CLAUDE.md and split into Tier 0 (under 400 tokens) and Tier 1 skills
- [ ] Create 3-5 domain skills in `.claude/skills/` at 200-500 tokens each
- [ ] Add a "quick reference" skill per major domain (DB, API, auth, deployment)
- [ ] Optionally create "detailed" skills for complex domains (~500-1,000 tokens)
- [ ] Reference skills from CLAUDE.md without inlining their content
- [ ] Test: run `/cost` on simple and complex tasks to verify tier separation
- [ ] Review monthly: promote frequently-needed Tier 1 info to Tier 0 if under 50 tokens

## The CCG Framework Connection

Progressive disclosure is the organizational pattern that connects CLAUDE.md optimization, skills authoring, and context window management. The [Claude Code Skills Guide](/skills/) covers skill creation mechanics. [CLAUDE.md Token Optimization](/claude-md-token-optimization-rules-save-money/) covers Tier 0 optimization. This article provides the architectural framework for deciding what goes where.

## Anti-Patterns in Progressive Disclosure

### Anti-Pattern 1: Tier 0 Overload

Putting too much information in CLAUDE.md defeats the purpose. If CLAUDE.md exceeds 500 tokens, information that does not apply to every single task should be moved to Tier 1 skills.

```markdown
# BAD: CLAUDE.md with 1,200 tokens (Tier 0 overload)
## Project Map
[80 tokens]
## Database Schema
[300 tokens -- should be a Tier 1 skill]
## API Routes
[250 tokens -- should be a Tier 1 skill]
## Deploy Process
[200 tokens -- should be a Tier 1 skill]
## Error Codes
[170 tokens -- should be a Tier 1 skill]
## Coding Standards
[200 tokens]
```

```markdown
# GOOD: CLAUDE.md with 350 tokens (Tier 0 right-sized)
## Project Map
[80 tokens]
## Coding Standards
[200 tokens]
## Skills
- .claude/skills/database.md
- .claude/skills/api-routes.md
- .claude/skills/deploy.md
- .claude/skills/error-codes.md
[70 tokens]
```

The good version loads 350 tokens per turn. The bad version loads 1,200 tokens per turn. Over a 30-turn session, the difference is 25,500 tokens ($0.08 Sonnet, $0.38 Opus).

### Anti-Pattern 2: Missing Tier 1

Going directly from CLAUDE.md (Tier 0) to full file reads (Tier 2) skips the most cost-effective layer. Without skills, moderate-complexity tasks default to expensive file reads.

### Anti-Pattern 3: Non-Hierarchical Skills

Skills that duplicate CLAUDE.md information or duplicate each other waste tokens on redundancy. Each skill should contain unique information not available in any other tier.

## Implementing Progressive Disclosure Step by Step

**Step 1: Inventory.** List all project knowledge that Claude needs. Group by domain (DB, API, auth, deploy, testing).

**Step 2: Classify.** For each knowledge item, determine the tier:
- Tier 0 (CLAUDE.md): needed for 90%+ of tasks (project identity, core conventions, commands)
- Tier 1 (Skills): needed for 30-70% of tasks (domain-specific patterns, schemas, route maps)
- Tier 2 (File reads): needed for <30% of tasks (specific implementation details, edge cases)

**Step 3: Write.** Create CLAUDE.md (under 400 tokens) and 3-5 skills (200-500 tokens each). Use telegraphic style -- no prose, no explanations, just facts.

**Step 4: Reference.** Add a "Skills" section to CLAUDE.md listing available skills so Claude knows they exist.

**Step 5: Measure.** Run `/cost` on 10 tasks before and after implementation. Target: 50-70% reduction in exploration tokens.

**Step 6: Iterate.** After 1 week, review which skills are loaded most often. If a skill is loaded on 90%+ of tasks, consider promoting its most critical 2-3 lines to Tier 0. If a skill is rarely loaded, it may be too granular -- consider merging with a related skill.

The iteration cycle is where progressive disclosure transforms from a static pattern to a dynamic optimization process. Each week's data reveals whether the tier boundaries are correctly placed. The most common finding during iteration is that Tier 1 skills need consolidation -- teams often start with too many granular skills and merge them into 3-5 broader domain skills after the first review cycle.

## Further Reading

- [Claude Code Skills Guide](/skills/) -- creating and managing skills
- [Context Engineering vs Prompt Engineering](/context-engineering-vs-prompt-engineering-agents/) -- theoretical foundation
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- mechanics of context growth across tiers
