---
layout: default
title: "Pre-Loading Context (2026)"
description: "Pre-load context in CLAUDE.md sections to save 50%+ tokens per Claude Code session with project maps, error protocols, and architecture summaries."
permalink: /pre-loading-context-claude-md-sections-save-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Pre-Loading Context: CLAUDE.md Sections That Save 50%+ Tokens

## The Pattern

Pre-loading context means placing high-value project information directly in CLAUDE.md so Claude Code has it available from the first turn, eliminating the discovery phase that typically consumes 30K-100K tokens per session.

## Why It Matters for Token Cost

The discovery phase is the most wasteful phase of any Claude Code session. Before Claude can do useful work, it needs to understand the project structure, conventions, and constraints. Without CLAUDE.md, this understanding comes from file reads -- each costing 1,000-5,000 tokens.

A well-structured CLAUDE.md replaces 15-30 file reads with a single 200-500 token document. The math is straightforward:
- Without pre-loading: 15 reads x 3K avg tokens = 45K discovery tokens
- With pre-loading: 1 CLAUDE.md load = 400 tokens
- **Savings: 44,600 tokens (99%) on discovery alone**

At $3/MTok (Sonnet input), that is $0.13 saved per session. At 5 sessions/day, 22 working days/month: **$14.52/month per developer.** On Opus 4.6: **$72.60/month.**

## The Anti-Pattern (What NOT to Do)

```markdown
# BAD: empty or generic CLAUDE.md

# My Project
This is a web application.
```

Or worse: no CLAUDE.md at all. Claude starts every session blind, exploring the file tree, reading package.json, checking directory structures, and opening random files to understand the stack.

## The Pattern in Action

### Step 1: Project Identity Section (Most Critical)

```markdown
# CLAUDE.md

## Project: TaskFlow API
Stack: TypeScript, Express.js, Prisma, PostgreSQL, Jest
Repo: monorepo (api + shared packages)
Status: production (launched 2025-11, ~2K DAU)
```

**Token cost: ~40 tokens.** Replaces: reading package.json (800 tokens), README (1,500 tokens), and config files (2,000 tokens). **Savings: 4,260 tokens.**

### Step 2: Directory Map Section

```markdown
## Directory Map
- src/routes/ -- 15 REST endpoint files (Express Router)
- src/services/ -- business logic (1 service per domain)
- src/repositories/ -- Prisma DB queries (1 repo per table)
- src/middleware/ -- auth, validation, rate-limit, error-handler
- src/types/ -- shared TypeScript interfaces
- __tests__/ -- Jest tests (mirrors src/ structure)
- prisma/schema.prisma -- database schema (source of truth)
```

**Token cost: ~80 tokens.** Replaces: `ls` commands across 5+ directories (1,500 tokens), reading multiple index.ts files for exports (3,000 tokens). **Savings: 4,420 tokens.**

### Step 3: Command Reference Section

```markdown
## Commands
- Dev: npm run dev (port 3000)
- Test all: npm test
- Test one: npm test -- --testPathPattern="<file>"
- Build: npm run build
- Lint: npm run lint --fix
- Migrate: npx prisma migrate dev --name <desc>
- Generate types: npx prisma generate
```

**Token cost: ~60 tokens.** Replaces: reading package.json scripts section (400 tokens), trying commands and reading errors (2,000 tokens). **Savings: 2,340 tokens.**

### Step 4: Conventions Section

```markdown
## Conventions
- Repository pattern: all DB access through src/repositories/
- Zod validation on all route inputs
- JWT auth middleware on all routes except /health and /auth/*
- Error format: { error: { code: string, message: string } }
- Soft deletes: deleted_at column on users, posts, comments
- No raw SQL -- always use Prisma query builder
```

**Token cost: ~70 tokens.** Replaces: reading multiple code files to infer patterns (10,000-20,000 tokens). **Savings: 9,930-19,930 tokens.** This is the highest-ROI section because conventions are invisible -- they cannot be discovered without reading many files.

### Step 5: Error Protocol Section

```markdown
## Error Protocol
- Build errors: run scripts/build-structured.sh (not npm run build)
- Test failures: fix ONE test at a time, run specific test, not full suite
- Maximum 3 fix attempts per error, then report to developer
- After fixing, run lint before committing
```

**Token cost: ~50 tokens.** Prevents: retry loops that cost 50K-200K tokens per incident. **Expected savings: 25K-100K tokens** per prevented loop.

## Before and After

| Section | Tokens in CLAUDE.md | Tokens Replaced | ROI (tokens saved per token spent) |
|---------|--------------------|-----------------|------------------------------------|
| Project identity | 40 | 4,300 | 107x |
| Directory map | 80 | 4,500 | 56x |
| Commands | 60 | 2,400 | 40x |
| Conventions | 70 | 10K-20K | 143-286x |
| Error protocol | 50 | 25K-100K | 500-2,000x |
| **Total** | **300** | **46K-131K** | **153-437x** |

The error protocol section has the highest ROI because it prevents catastrophic token waste events, not just routine exploration.

## When to Use This Pattern

- Every project that uses Claude Code (there is no scenario where CLAUDE.md is not beneficial)
- Projects with more than 10 files
- Projects with non-obvious conventions
- Team projects where knowledge is distributed across team members

## When NOT to Use This Pattern

- There is no scenario where skipping CLAUDE.md is the right choice. Even a 5-line CLAUDE.md saves thousands of tokens per session.

## Implementation in CLAUDE.md

The complete template, optimized for minimum tokens and maximum information:

```markdown
# CLAUDE.md

## Project: {name}
Stack: {languages, frameworks, DB, test framework}
Repo: {monorepo/single, any special notes}

## Map
- {dir}/ -- {description} ({count} files)
[repeat for 5-8 key directories]

## Commands
- Dev: {command}
- Test: {command}
- Build: {command}
- Lint: {command}
[add project-specific commands]

## Conventions
- {pattern 1}
- {pattern 2}
[5-8 critical conventions]

## Error Protocol
- Max 3 fix attempts per error
- Fix one error at a time
- Use structured wrappers in scripts/
- After fix: run lint, then targeted test

## Skills: .claude/skills/
- {skill-name}.md -- {purpose}
[list 3-5 key skills]
```

**Total cost: 200-400 tokens.** This template saves 50-130K tokens per session, delivering a **250-650x return** on the token investment.

## Section Priority: What to Include First

When creating or optimizing CLAUDE.md, add sections in this priority order. Each section delivers diminishing returns, so start with the highest-impact sections:

### Priority 1: Project Identity (ROI: 107x)

Without this, Claude reads 3-5 config files on every session. Two lines of project identity save 4,300 tokens per session.

### Priority 2: Directory Map (ROI: 56x)

Without this, Claude scans directory trees with ls/glob commands. Five lines of directory description save 4,500 tokens per session.

### Priority 3: Error Protocol (ROI: 500-2,000x)

This has the highest per-token ROI because it prevents catastrophic waste events. A 50-token section preventing one retry loop saves 25K-100K tokens.

### Priority 4: Conventions (ROI: 143-286x)

Conventions are invisible without documentation. Claude cannot infer "we use repository pattern" or "we use soft deletes" without reading multiple files. Six lines of conventions save 10K-20K tokens per session.

### Priority 5: Commands (ROI: 40x)

Less critical because Claude can discover commands from package.json, but pre-loading them saves 2,400 tokens and prevents incorrect command attempts.

### Priority 6: Skills Reference (ROI: varies)

Listing available skills costs ~30 tokens and ensures Claude loads the right skill for each task type.

## CLAUDE.md by Project Size

The optimal CLAUDE.md varies by project size:

### Small Project (under 50 files)

```markdown
# CLAUDE.md
## {Project}: {Stack}
## Commands: dev({cmd}), test({cmd}), build({cmd})
## Rules: {3-5 rules}
```
~100 tokens. Minimal because the project is small enough for Claude to explore efficiently.

### Medium Project (50-500 files)

```markdown
# CLAUDE.md
## {Project}: {one-line}
Stack: {languages, frameworks}
## Map: {5-8 directories}
## Commands: {4-6 commands}
## Rules: {5-8 rules}
## Skills: {list 3-5}
```
~250 tokens. The sweet spot for most projects.

### Large Project (500+ files)

```markdown
# CLAUDE.md
## {Project}: {one-line}
Stack: {languages, frameworks}
## Map: {8-12 directories}
## Commands: {6-8 commands}
## Rules: {8-10 rules, including file budget and subagent caps}
## Error protocol: {3-5 rules}
## Skills: {list 5-8}
## Out of scope: {directories to never touch}
```
~350 tokens. Larger projects need more rules to prevent exploration waste, but the CLAUDE.md should never exceed 400 tokens. Additional detail goes to skills.

## Real-World Before/After Example

**Before CLAUDE.md (actual session data):**

```
Task: "Add created_at field to the comments table"
Turn 1: ls src/ (1,200 tokens)
Turn 2: cat package.json (800 tokens)
Turn 3: ls prisma/ (500 tokens)
Turn 4: cat prisma/schema.prisma (3,200 tokens)
Turn 5: ls src/repositories/ (400 tokens)
Turn 6: cat src/repositories/comment.ts (2,800 tokens)
Turn 7: Edit prisma/schema.prisma (800 tokens)
Turn 8: Run migration (500 tokens)
Turn 9: Edit comment.ts (600 tokens)
Turn 10: Run test (800 tokens)
Total input (cumulative): 87,400 tokens -- $0.26 Sonnet
```

**After CLAUDE.md (same task):**

```
Task: "Add created_at field to the comments table"
Turn 1: Read CLAUDE.md + skills/database.md (700 tokens)
Turn 2: Edit prisma/schema.prisma (800 tokens)
Turn 3: Run migration (500 tokens)
Turn 4: Edit comment.ts (600 tokens)
Turn 5: Run test (800 tokens)
Total input (cumulative): 14,200 tokens -- $0.04 Sonnet
Savings: 84% ($0.22 per task)
```

Over 22 working days at 5 database tasks per day: $0.22 x 5 x 22 = **$24.20/month saved from this single CLAUDE.md optimization.**

The before/after pattern demonstrates the core value proposition of pre-loading: converting expensive exploration turns into cheap reference lookups. Every project has 3-5 common tasks where pre-loaded context eliminates 50-80% of the exploration phase. Identifying these tasks through `/cost` tracking and creating the corresponding CLAUDE.md sections and skills is the highest-ROI investment in Claude Code cost optimization.

## Related Guides

- [CLAUDE.md Token Optimization](/claude-md-token-optimization-rules-save-money/) -- minimizing CLAUDE.md token cost
- [Progressive Disclosure Pattern](/progressive-disclosure-pattern-claude-code-skills/) -- layered context loading
- [Context Engineering vs Prompt Engineering](/context-engineering-vs-prompt-engineering-agents/) -- the theoretical foundation

## See Also

- [Best CLAUDE.md Templates for Teams (2026)](/best-claude-md-templates-enterprise-2026/)
