---
layout: default
title: "How to Write Token-Efficient Claude (2026)"
description: "Write Claude Code skills that minimize token usage with telegraphic formatting, layered depth, and information-dense patterns saving 500-2,000 tokens each."
permalink: /write-token-efficient-claude-code-skills/
date: 2026-04-22
last_tested: "2026-04-22"
---

# How to Write Token-Efficient Claude Code Skills

## What It Does

Claude Code skills are markdown files in `.claude/skills/` that load domain knowledge on demand. A well-written skill costs 200-500 tokens to load and replaces 20K-80K tokens of file exploration. A poorly written skill costs 1,500-3,000 tokens and provides marginal savings. This guide covers the formatting and structural patterns that maximize information density per token, ensuring every skill delivers maximum cost savings.

## Installation / Setup

Skills require no installation. Create the skills directory and add markdown files:

```bash
# Create skills directory
mkdir -p .claude/skills

# Create a skill file
touch .claude/skills/my-skill.md

# Skills are automatically detected by Claude Code
# No registration or configuration needed
```

Reference skills from CLAUDE.md to signal their availability:

```markdown
# CLAUDE.md
## Skills Available
- Database schema: .claude/skills/database.md
- API routes: .claude/skills/api-routes.md
- Deploy process: .claude/skills/deploy.md
```

## Configuration for Cost Optimization

### Rule 1: Telegraphic Style

Remove articles, pronouns, and filler words. Every token must carry information.

```markdown
# BAD: 156 tokens
# .claude/skills/database.md

## Database Information

Our project uses a PostgreSQL database managed through Prisma ORM.
The database has the following tables that you should be aware of:

The users table contains the following columns:
- id: This is a UUID that serves as the primary key
- email: This is a unique varchar field for the user's email address
- password_hash: This stores the bcrypt hash of the user's password
- created_at: This is a timestamp that is automatically set when the record is created

# GOOD: 52 tokens
# .claude/skills/database.md

## DB: PostgreSQL + Prisma
### users: id(uuid PK), email(unique), password_hash(bcrypt), created_at(auto)
### posts: id(uuid PK), user_id(FK->users), title(varchar 500), body(text), status(draft|pub|arch)
### comments: id(uuid PK), post_id(FK), user_id(FK), body(text), created_at(auto)
```

The good version conveys the same information in 67% fewer tokens. Over a 30-turn session, that saves (156-52) x 30 = 3,120 tokens per skill reference.

### Rule 2: One Skill per Domain, One File

```bash
# BAD: monolithic skill (1,200 tokens)
.claude/skills/everything.md

# GOOD: focused skills (200-400 tokens each, loaded selectively)
.claude/skills/database.md      # 250 tokens
.claude/skills/api-routes.md    # 300 tokens
.claude/skills/auth-patterns.md # 200 tokens
.claude/skills/deploy-process.md # 180 tokens
```

Focused skills mean Claude loads only what it needs. A database task loads only the database skill (250 tokens), not the full 1,200-token monolith. Savings: 79% per task that touches only one domain.

### Rule 3: Structured Data Over Prose

```markdown
# BAD: prose format (180 tokens)
The API has several important routes. The auth routes handle login and registration
and are located in src/routes/auth.ts. The user routes handle CRUD operations for
user management and are in src/routes/users.ts. They require authentication except
for the GET endpoints. The post routes handle blog post operations...

# GOOD: structured format (80 tokens)
## Routes (src/routes/)
| File | Endpoints | Auth |
|------|-----------|------|
| auth.ts | POST /login, /register, /refresh | public |
| users.ts | GET/POST/PUT/DELETE /users | GET:public, rest:auth |
| posts.ts | GET/POST/PUT/DELETE /posts | GET:public, rest:auth |
| comments.ts | GET/POST/DELETE /comments | all:auth |
```

Tables are 55% more token-efficient than prose for structured data, and Claude parses them more accurately.

## Usage Examples

### Basic Usage

```markdown
# .claude/skills/deploy.md (minimal, 120 tokens)

## Deploy
- Build: npm run build (must pass before deploy)
- Test: npm test (must pass before deploy)
- Deploy: vercel deploy --prod
- Verify: curl -s https://myapp.com/health | grep "ok"
- Rollback: vercel rollback
```

### Advanced: Cost-Saving Pattern with Conditional Sections

```markdown
# .claude/skills/testing.md (180 tokens)

## Testing
- Framework: Jest + Testing Library
- Run all: npm test
- Run one: npm test -- --testPathPattern="<file>"
- Run matching: npm test -- --testNamePattern="<name>"
- Coverage: npm test -- --coverage (threshold: 80%)

## Patterns
- Unit: mock externals, test pure logic
- Integration: use test DB (supabase start)
- Snapshot: __snapshots__/ (update: npm test -- -u)

## If tests fail
- Read ONLY the failing test file first
- Check test name matches implementation
- Max 3 fix attempts, then report
```

The "If tests fail" section provides error-handling guidance that prevents retry loops -- a small investment of ~30 tokens that saves 20K-50K tokens per retry incident.

## Token Usage Measurements

| Skill Quality | Tokens | Info Density | Cost Per 30-Turn Session (Sonnet) |
|--------------|--------|-------------|----------------------------------|
| Verbose prose | 1,500 | Low | $0.135 |
| Mixed format | 800 | Medium | $0.072 |
| Telegraphic + tables | 350 | High | $0.032 |
| Ultra-compact | 200 | Very high | $0.018 |

**Annual savings from optimizing 5 skills from verbose to telegraphic:**
- Per session: (1,500 - 350) x 5 skills x 30 turns = 172,500 tokens
- At 1 session/day, 260 days: 44.85M tokens
- Sonnet cost: $134.55 input savings per year
- Opus cost: $672.75 input savings per year

## Comparison with Alternatives

| Context Method | Tokens | Load Time | Freshness | Best For |
|---------------|--------|-----------|-----------|----------|
| Skills (optimized) | 200-500 | Instant | Manual updates | Stable knowledge |
| CLAUDE.md inline | 200-1,000 | Every turn | Always current | Critical rules |
| Full file reads | 2,000-10,000 | 1 tool call | Always current | Dynamic content |
| MCP tool queries | 500-2,000 + overhead | 1+ calls | Real-time | External services |

Skills are the best choice for knowledge that changes infrequently (weekly or less) and is needed often (daily or more).

## Troubleshooting

**Skill not loading when expected:** Verify the file is in `.claude/skills/` and has a `.md` extension. Check that CLAUDE.md references the skill.

**Skill content outdated:** Add a date header to each skill: `## Last updated: 2026-04-22`. Set a calendar reminder to audit skills monthly.

**Skill too large (over 1,000 tokens):** Split into two skills by subdomain. A 1,200-token "database" skill becomes a 300-token "db-schema" skill and a 400-token "db-patterns" skill, loaded independently.

## Skill Templates by Domain

### Template: Database Schema Skill

```markdown
# .claude/skills/database.md
## Updated: YYYY-MM-DD
### table1: col1(type PK), col2(type), col3(FK->ref)
### table2: col1(type PK), col2(type UNIQUE), col3(enum: a|b|c)
## Indexes: table1(col2), table2(col2,col3)
## Conventions: soft deletes(deleted_at), UTC timestamps, uuid PKs
## Commands: migrate(cmd), generate(cmd), seed(cmd)
```
Target: 200-350 tokens.

### Template: API Routes Skill

```markdown
# .claude/skills/api-routes.md
## Updated: YYYY-MM-DD
| Route File | Endpoints | Auth |
|-----------|-----------|------|
| auth.ts | POST /login, /register | public |
| users.ts | CRUD /users | auth required |
## Middleware: cors -> rateLimit -> auth -> validate -> handler
## Response: { data: T, meta?: { page, total } }
## Errors: { error: { code: string, message: string } }
```
Target: 200-300 tokens.

### Template: Deployment Skill

```markdown
# .claude/skills/deploy.md
## Updated: YYYY-MM-DD
## Environments: dev(localhost:3000), staging(staging.app.com), prod(app.com)
## Deploy: build(cmd) -> test(cmd) -> deploy(cmd) -> verify(curl cmd)
## Rollback: rollback_cmd
## CI: GitHub Actions, auto-deploy on main push
## Secrets: managed in provider (never in code)
```
Target: 150-200 tokens.

### Template: Error Codes Skill

```markdown
# .claude/skills/error-codes.md
## Updated: YYYY-MM-DD
| Exit Code | Meaning | Claude Action |
|-----------|---------|---------------|
| 0 | Success | Continue |
| 10 | Type error | Fix types |
| 20 | Test failure | Fix test/implementation |
| 30 | Deploy auth | Report to developer |
| 99 | Unknown | Read full output |
```
Target: 100-200 tokens.

## Measuring Skill ROI

For each skill, calculate the return on investment:

```
Skill ROI = (Tokens saved per use x Uses per day x Working days) / Tokens to maintain

Example: database schema skill
- Tokens saved per use: 8,000 (replaces schema file read)
- Uses per day: 5
- Working days per month: 22
- Tokens to maintain: 300 (monthly update)

Monthly ROI = (8,000 x 5 x 22) / 300 = 2,933x return
Dollar savings (Sonnet): 880K tokens x $3/MTok = $2.64/month per skill
```

The highest-ROI skills are those used most frequently. Audit skill usage monthly and retire skills that are rarely loaded -- they represent maintenance cost without benefit.

## Skill Size Budget Guide

| Skill Type | Target Words | Target Tokens | Rationale |
|-----------|-------------|---------------|-----------|
| Schema reference | 150-250 | 200-325 | Tables + columns, dense data |
| API route map | 150-200 | 200-260 | Route list + auth requirements |
| Command reference | 80-120 | 100-155 | Simple list format |
| Pattern library | 200-350 | 260-455 | Includes code snippets |
| Error code map | 100-150 | 130-195 | Table format, very dense |
| Deployment process | 100-150 | 130-195 | Step-by-step, concise |

Keep each skill within these budgets. A skill that exceeds its budget should be split into two focused skills, each loaded independently based on task relevance. Regularly auditing skill sizes against these targets prevents gradual bloat as teams add information over time -- a common failure mode where skills grow from 200 tokens to 800 tokens through incremental additions without pruning.



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Skills Guide](/skills/) -- complete skills reference and API
- [Skills as Context Engineering](/skills-context-engineering-zero-round-trip-loading/) -- the theory behind skills-as-context
- [CLAUDE.md Token Optimization](/claude-md-token-optimization-rules-save-money/) -- optimizing the always-loaded context layer
