---
sitemap: false
layout: default
title: "CLAUDE.md Too Long? How to Split (2026)"
description: "Fix CLAUDE.md files that exceed 200 lines by splitting into imports, rules directories, and skills. Step-by-step optimization with before/after examples."
permalink: /claude-md-too-long-fix/
date: 2026-04-20
categories: [claude-md, fixes]
tags: [claude-md, too-long, context-window, optimization, split, fix]
last_updated: 2026-04-19
---

## Symptoms of an Overloaded CLAUDE.md

Your CLAUDE.md has grown to 300, 400, or even 600 lines. Claude Code does not throw an error -- it just gets worse. The symptoms:

- Claude ignores rules near the bottom of the file
- Claude picks one rule over another seemingly at random
- Claude's responses slow down as more context is consumed
- Rules that worked last month stop working after you added 50 more lines

The root cause: Anthropic's documentation recommends keeping CLAUDE.md under 200 lines. Beyond that, instruction adherence degrades because the file consumes more context window, leaving less room for Claude to reason about your actual request.

## Diagnostic: Measure Your File

```bash
# Line count
wc -l CLAUDE.md

# Word count (for a sense of context consumption)
wc -w CLAUDE.md

# Count sections
grep -c "^## " CLAUDE.md

# Find the longest section
awk '/^## /{if(section) print count, section; section=$0; count=0; next} {count++} END{print count, section}' CLAUDE.md | sort -rn | head -5
```

If your file is over 200 lines, the next step is categorizing every section into one of three buckets: keep, move to rules, or move to skills.

## Step 1: Identify What Stays

Only two categories belong in the root CLAUDE.md:

1. **Project identity** — language, framework, database, build commands
2. **Universal architecture rules** — layer boundaries, dependency direction, naming conventions

These are facts Claude needs on every interaction regardless of which file it is working on.

```markdown
# These stay in root CLAUDE.md (about 40-60 lines)

## Project
- Language: TypeScript 5.4
- Framework: NestJS 11
- Database: PostgreSQL via TypeORM
- Build: pnpm build
- Test: pnpm test

## Architecture
- Controllers in src/controllers/ — HTTP only
- Services in src/services/ — business logic
- Repositories in src/repositories/ — database access
- No cross-layer imports (controllers never import repositories)
```

## Step 2: Move File-Specific Rules to .claude/rules/

Rules that apply only to certain file types should use path-specific rules:

```markdown
# .claude/rules/controllers.md
---
paths:
  - "src/controllers/**/*.ts"
---

## Controller Rules
- Use @Controller() decorator with resource name
- Validate DTOs with class-validator decorators
- Return through response interceptor
- Log request/response with built-in logger
```

```markdown
# .claude/rules/repositories.md
---
paths:
  - "src/repositories/**/*.ts"

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).
---

## Repository Rules
- Extend BaseRepository<T>
- Use QueryBuilder for complex queries
- Return domain entities, not ORM entities
- Handle unique constraint errors as ConflictException
```

These files load conditionally -- only when Claude reads files matching the glob pattern. A 400-line CLAUDE.md might become a 60-line CLAUDE.md plus four 40-line rules files, with each file loading only when relevant.

## Step 3: Move Procedures to Skills

Multi-step procedures are the biggest CLAUDE.md bloat offenders. A deployment checklist, database migration workflow, or release process does not need to be in context at all times:

```
# Before: 45 lines in CLAUDE.md for deployment procedure
## Deployment
1. Run tests...
2. Build docker image...
3. Push to registry...
...

# After: .claude/skills/deploy/SKILL.md
# Loads only when invoked with /deploy
# All 45 lines available on demand, zero context cost otherwise
```

Skills load only when invoked. Moving three procedures out of CLAUDE.md can save 100+ lines of context.

## Step 4: Use @imports for Reference Content

Large reference blocks (API conventions, coding standards, style guides) can be imported from separate files:

```markdown
# CLAUDE.md — lean root file
@docs/coding-standards.md
@docs/api-conventions.md
@docs/error-handling.md
```

Imports are inlined at load time, so Claude sees the content. The benefit is organizational -- your root CLAUDE.md stays readable and maintainable. For context optimization, .claude/rules/ with path patterns is more effective because it loads conditionally.

## Before and After

```
Before:
  CLAUDE.md — 420 lines, everything in one file
  Result: Claude ignores bottom half of rules

After:
  CLAUDE.md — 55 lines (identity + architecture)
  .claude/rules/controllers.md — 30 lines (path-specific)
  .claude/rules/repositories.md — 25 lines (path-specific)
  .claude/rules/testing.md — 35 lines (path-specific)
  .claude/skills/deploy/SKILL.md — 45 lines (on-demand)
  .claude/skills/migrate/SKILL.md — 40 lines (on-demand)
  Result: Claude follows all rules, context stays lean
```

## Verify After Splitting

Run `/memory` to confirm all files load correctly. Check that:
- Root CLAUDE.md shows as loaded
- Rules files appear when you open matching files
- Skills appear in the `/` menu

## Measuring the Impact of Splitting

After restructuring, verify that Claude's behavior improved. Run a quick test:

1. Start a new Claude Code session
2. Ask Claude to generate a function that exercises your most important rules
3. Check every rule against the output
4. Compare adherence to your pre-split experience

If adherence improved, the split worked. If specific rules are still ignored, check whether they ended up in a path-specific rules file that has not loaded yet (run `/memory` to confirm).

## Common Mistakes When Splitting

**Moving everything to rules files.** Some instructions belong in the root CLAUDE.md because they apply universally. Build commands, project identity, and architecture boundaries should stay in the root file. Only file-type-specific rules benefit from `.claude/rules/`.

**Creating too many small rules files.** Five rules files with 10 lines each is harder to maintain than two files with 25 lines. Group related rules together. One file per domain (testing, API, database) is the right granularity.

**Forgetting to update imports.** After moving content to a new file, remove the original content from CLAUDE.md. Leaving both creates duplicates that might contradict each other as they evolve independently.

For the detailed import system syntax, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For writing rules that Claude actually follows, see the [best practices guide](/claude-code-claude-md-best-practices/). For keeping CLAUDE.md lean in team settings, see the [team vs personal guide](/team-claude-md-vs-personal-claude-md/).
