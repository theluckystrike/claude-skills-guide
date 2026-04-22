---
title: "Progressive Disclosure in CLAUDE.md: Load Only What You Need"
description: "Reduce CLAUDE.md token cost by 60-80% with progressive disclosure patterns that load context only when Claude Code needs it for the current task."
permalink: /progressive-disclosure-claude-md-load-only-needed/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Progressive Disclosure in CLAUDE.md: Load Only What You Need

## The Problem

A monolithic CLAUDE.md file costs 200-1,000 tokens every time Claude Code starts a session, regardless of the task. When a developer asks Claude to fix a typo, the agent still loads database migration rules, deployment checklists, and API style guidelines. At Sonnet 4.6 rates ($3/$15 per MTok input/output), loading 800 unnecessary tokens across 100 daily sessions costs a team $0.24-$1.20 per day -- $5-$25 per month -- for context that never gets used.

## Quick Wins (Under 5 Minutes)

1. **Measure your CLAUDE.md size** -- count tokens with `wc -w CLAUDE.md` (tokens are roughly 0.75x word count). Anything over 500 tokens deserves splitting.
2. **Move domain-specific rules to skills** -- database conventions, deployment steps, and API patterns belong in `.claude/skills/` files, not CLAUDE.md.
3. **Delete stale rules** -- remove CLAUDE.md entries that reference deprecated tools, old API versions, or resolved one-time issues.
4. **Use directory-level CLAUDE.md files** -- place rules in subdirectory CLAUDE.md files so they load only when Claude works in that directory.

## Deep Optimization Strategies

### Strategy 1: Split by Concern into Directory-Level Files

Claude Code loads CLAUDE.md files hierarchically. Place rules where they apply:

```text
project-root/
  CLAUDE.md              # 150 tokens: universal rules only
  src/
    CLAUDE.md            # 200 tokens: code style, imports
    api/
      CLAUDE.md          # 180 tokens: API conventions
    db/
      CLAUDE.md          # 220 tokens: migration rules
  tests/
    CLAUDE.md            # 150 tokens: test conventions
  deploy/
    CLAUDE.md            # 170 tokens: deployment rules
```

Root CLAUDE.md (keep lean -- universal rules only):

```markdown
# Project Rules

## Code Style
- TypeScript strict mode
- No `any` types
- All functions under 60 lines (NASA P10)
- Minimum 2 assertions per function

## Git
- Conventional commits: feat|fix|chore|docs(scope): message
- Never force-push to main
```

Database-specific rules in `src/db/CLAUDE.md`:

```markdown
# Database Rules

## Migrations
- Always create reversible migrations
- Name format: YYYYMMDD_HHMMSS_description.sql
- Test rollback before committing
- Never drop columns in production without 2-week deprecation

## Schema Conventions
- Tables: snake_case, plural (e.g., user_accounts)
- Primary keys: `id` (uuid)
- Always include created_at, updated_at
```

When Claude fixes a typo in `src/components/Button.tsx`, it loads only the root CLAUDE.md (150 tokens) and `src/CLAUDE.md` (200 tokens) -- not the database or deployment rules.

**Before: 1,000 tokens (monolithic). After: 350 tokens (relevant subset). Savings: 65%**

### Strategy 2: Extract Procedures to Skills

Skills are loaded on-demand based on task relevance, not directory location. Move detailed procedures out of CLAUDE.md:

```markdown
# .claude/skills/deploy.md

## Deployment Procedure

### Pre-flight
1. Run `pnpm test` -- all tests must pass
2. Run `pnpm build` -- no build errors
3. Check `git status` -- working tree must be clean

### Deploy
1. `vercel build --prod --yes`
2. `vercel deploy --prebuilt --prod --yes`
3. Wait 30 seconds for propagation
4. `curl -sf https://example.com/health || echo "HEALTH CHECK FAILED"`

### Rollback (if health check fails)
1. `vercel rollback`
2. Verify health check passes on previous version
3. Create incident report in .claude/incidents/
```

This skill (~300 tokens) loads only when the user asks about deployment. In CLAUDE.md, replace the full procedure with a one-line pointer:

```markdown
## Deployment
- See deploy skill for full procedure
```

That pointer costs ~15 tokens versus the full procedure's 300 tokens.

**Savings: 285 tokens per non-deployment session**

### Strategy 3: Use Conditional Sections with File Patterns

Structure CLAUDE.md rules with clear file-type context so Claude Code can prioritize relevant sections:

```markdown
# Project Rules

## When editing .tsx files
- Use functional components only
- Props interfaces must be exported
- No inline styles -- use Tailwind classes

## When editing .sql files
- All queries must use parameterized inputs
- Include EXPLAIN plan for queries touching >100K rows
- Foreign keys must have ON DELETE specified

## When editing .test.ts files
- Use describe/it blocks (no test())
- Mock external services, never hit real APIs
- Assert both success and error paths
```

Claude Code naturally attends more to sections matching the current file type, but explicitly labeling sections ("When editing .tsx files") makes this behavior more reliable and reduces the chance of applying irrelevant rules.

### Strategy 4: Establish a Token Budget for CLAUDE.md

Set a hard limit and enforce it:

```bash
#!/bin/bash
# .claude/hooks/check-claude-md-size.sh
# Run as a pre-commit hook or periodic check

MAX_TOKENS=400
WORD_COUNT=$(wc -w < CLAUDE.md)
ESTIMATED_TOKENS=$((WORD_COUNT * 100 / 75))

if [ "$ESTIMATED_TOKENS" -gt "$MAX_TOKENS" ]; then
  echo "ERROR: CLAUDE.md estimated at ${ESTIMATED_TOKENS} tokens (max: ${MAX_TOKENS})"
  echo "Move detailed rules to .claude/skills/ or subdirectory CLAUDE.md files"
  exit 1
fi

echo "CLAUDE.md: ~${ESTIMATED_TOKENS} tokens (budget: ${MAX_TOKENS})"
```

A 400-token budget forces discipline. When new rules need adding, existing rules must be migrated to skills or subdirectory files first.

### Strategy 5: The CLAUDE.md Audit Workflow

Periodically audit and prune CLAUDE.md to prevent organic bloat:

```bash
#!/bin/bash
# scripts/audit-claude-md.sh
# Audit all CLAUDE.md files for token efficiency
set -euo pipefail

echo "=== CLAUDE.md Token Audit ==="

TOTAL_TOKENS=0

# Find all CLAUDE.md files
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | while read -r file; do
  WORDS=$(wc -w < "$file" | tr -d ' ')
  TOKENS=$((WORDS * 100 / 75))
  TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))

  if [ "$TOKENS" -gt 300 ]; then
    echo "REVIEW: $file (~$TOKENS tokens) -- consider splitting"
  else
    echo "OK: $file (~$TOKENS tokens)"
  fi
done

echo ""
echo "Audit complete. Review any files marked REVIEW for splitting opportunities."
echo "Target: root CLAUDE.md under 400 tokens, directory-level under 300 tokens each."
```

Run this monthly. The most common bloat pattern is developers adding temporary rules ("Until the migration is complete, always check X") that remain long after the migration is finished. A monthly audit catches these stale entries.

Another bloat source: duplicated rules across directory-level files. If three subdirectory CLAUDE.md files all contain "Use TypeScript strict mode," that rule belongs in the root CLAUDE.md instead, reducing total token load by ~30 tokens per duplicated directory.

## Measuring Your Savings

Compare session costs before and after restructuring:

```bash
# Check current CLAUDE.md token cost (rough estimate)
wc -w CLAUDE.md
# Example output: 600 words ≈ 800 tokens

# After restructuring to progressive disclosure
wc -w CLAUDE.md
# Example output: 112 words ≈ 150 tokens

# Verify with /cost at end of sessions
# Before: typical small task session = 15,000 tokens
# After: typical small task session = 14,350 tokens
# The 650 token savings compounds across 100 sessions/day (team) = 65,000 tokens/day
```

### Strategy 6: Template CLAUDE.md for New Projects

Create a lean CLAUDE.md template that enforces progressive disclosure from day one:

```markdown
# {Project Name}

## Build & Test
- Build: `{build_command}`
- Test: `{test_command}`
- Lint: `{lint_command}`

## Architecture
- {One-sentence description of architecture}
- Entry point: {main_file}
- Key directories: {list 3-5 directories with purposes}

## Conventions
- {3-5 universal rules, one line each}

## Skills Reference
- {List available skills by name for on-demand loading}
```

This template stays under 200 tokens regardless of project complexity. All detailed knowledge flows through skills and directory-level CLAUDE.md files.

Starting every project with this template prevents the natural tendency to grow CLAUDE.md organically until it becomes a 1,000-token monolith. The discipline of "if it does not fit the template, it belongs in a skill" maintains lean context loading for the lifetime of the project.

### Measuring Progressive Disclosure Effectiveness

Compare session costs before and after implementing progressive disclosure:

```bash
# Before progressive disclosure (monolithic CLAUDE.md):
# Average CLAUDE.md size: 800 tokens
# Loaded every session: 800 x 100 sessions = 80,000 tokens/month
# Cost: $0.24/month in CLAUDE.md overhead alone

# After progressive disclosure:
# Root CLAUDE.md: 150 tokens x 100 sessions = 15,000 tokens
# Skills (loaded 30% of sessions): 300 tokens x 30 sessions = 9,000 tokens
# Directory CLAUDE.md (loaded 50% of sessions): 200 tokens x 50 sessions = 10,000 tokens
# Total: 34,000 tokens/month
# Cost: $0.10/month

# Savings: $0.14/month per developer in direct overhead
# With context compounding (20-turn sessions): 3-5x multiplier = $0.42-$0.70/month
```

## Cost Impact Summary

| Technique | Token Savings per Session | Monthly Savings (Team of 5) |
|-----------|--------------------------|----------------------------|
| Split to directory-level files | 400-650 tokens | $1.20-$5.85 |
| Extract procedures to skills | 200-500 tokens | $0.60-$4.50 |
| Conditional sections | 100-200 tokens | $0.30-$1.80 |
| Token budget enforcement | Prevents bloat | Prevents regression |
| **Combined** | **700-1,350 tokens** | **$2.10-$12.15** |

Monthly estimates: 5 developers, 20 sessions/day each, Sonnet 4.6 rates ($3/$15 per MTok).

The compounding effect is the key insight: every token saved in CLAUDE.md is saved on every turn of every session. A 500-token reduction in CLAUDE.md saves 500 x 20 turns = 10,000 tokens per session, not just 500. Over a month of 100 sessions, that is 1,000,000 tokens = $3.00 on Sonnet 4.6 input costs alone. This makes CLAUDE.md optimization one of the highest-impact activities for cost control.

## Related Guides

- [Claude Code Context Window Management](/claude-code-context-window-management/) -- broader strategies for managing context costs
- [Claude Code Skills Guide](/claude-code-skills-guide/) -- how to create and organize skills files
- [Claude Code Compact Command Guide](/claude-code-compact-command-guide/) -- reducing context mid-session
