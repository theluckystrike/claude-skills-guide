---
title: "CLAUDE.md Length Optimization — Why 200 Lines Is the Hard Ceiling (2026)"
description: "How to keep your CLAUDE.md under 200 lines using imports, rules directories, and skills. Data-backed guidance on what happens when you exceed the limit."
permalink: /claude-md-length-optimization/
render_with_liquid: false
categories: [claude-md, patterns]
tags: [claude-md, optimization, length, imports, context-window]
last_updated: 2026-04-19
---

## The 200-Line Problem

Anthropic's official documentation states a clear recommendation: keep each CLAUDE.md file under 200 lines. This is not arbitrary. Longer files consume more context window, and Claude's adherence to instructions degrades as the context grows. If your CLAUDE.md has grown to 300 or 400 lines, you are paying a real cost in instruction-following quality -- even if Claude never throws an error.

The symptom is subtle. Claude does not refuse to read long files. It simply starts ignoring rules near the bottom, or picks arbitrarily between contradictory instructions that accumulate in bloated configs. You notice it when Claude stops sorting imports the way you specified, or starts using console.log despite your logging rule.

## Measuring Your Current File

Count your lines and identify what can move:

```bash
# Count total lines
wc -l CLAUDE.md

# Count lines by section (assumes ## headers)
awk '/^## /{section=$0; next} {lines[section]++} END{for(s in lines) print lines[s], s}' CLAUDE.md | sort -rn
```

If you are over 200 lines, the question is not whether to split -- it is where.

## Three Strategies to Get Under 200 Lines

### Strategy 1: @path Imports

The import system lets you split content across files while keeping a clean root CLAUDE.md. Use the `@path` syntax to pull in external files:

```markdown
# CLAUDE.md (root — 45 lines)

## Project Identity
- Language: Python 3.12
- Framework: FastAPI + SQLAlchemy
- Database: PostgreSQL 16

## Build Commands
- Install: pip install -e ".[dev]"
- Test: pytest -x --tb=short
- Lint: ruff check . --fix

## Core Rules
@docs/coding-standards.md
@docs/api-conventions.md

## Architecture
@docs/architecture-decisions.md
```

Each imported file loads into the context as if its contents were inline. Imports resolve relative to the file containing the `@` reference, not the working directory. The maximum import depth is 5 hops for recursive imports.

### Strategy 2: .claude/rules/ Directory

Move file-type-specific rules into `.claude/rules/` with path frontmatter. These files load conditionally -- only when Claude reads files matching the glob pattern:

```markdown
# .claude/rules/testing.md
---
paths:
  - "tests/**/*.py"
  - "**/*_test.py"
---

- Use pytest fixtures, not setUp/tearDown
- Mock external services with responses library
- Every test function name starts with test_ and describes the scenario
- Assert one behavior per test function
```

This is more efficient than imports because testing rules never load when Claude is working on API routes. The rules directory supports subdirectories and recursive discovery.

### Strategy 3: Move Procedures to Skills

Multi-step procedures do not belong in CLAUDE.md. A deployment checklist, a migration workflow, or a release process should be a skill. Skills load on demand, costing zero context until invoked:

```
Before (in CLAUDE.md — 30 lines wasted):
  ## Database Migration Process
  1. Create migration file...
  2. Review the SQL...
  3. Run against staging...
  ...

After (in .claude/skills/db-migrate/SKILL.md):
  Full procedure with templates, examples, and validation steps
  — loads only when invoked with /db-migrate
```

## What Goes Where: Decision Matrix

| Content type | Location | Why |
|---|---|---|
| Build commands | Root CLAUDE.md | Always needed |
| Architecture rules | Root CLAUDE.md | Always needed |
| File-type rules | .claude/rules/ with paths | Conditional loading |
| Procedures | Skills (.claude/skills/) | On-demand loading |
| Personal prefs | CLAUDE.local.md | Not shared with team |
| Reference docs | @imported files | Split for readability |

## After Splitting: Verify Loading

Run `/memory` in Claude Code to see every loaded instruction file. The output lists each CLAUDE.md, CLAUDE.local.md, and rules file currently in context. If a file is missing, check that its path matches the expected loading behavior:

- **Ancestor directories**: loaded at launch
- **Subdirectories**: loaded on demand when Claude reads files there
- **Rules with paths**: loaded when Claude reads files matching the glob

## Real-World Splitting Example

Before optimization, a production project's CLAUDE.md:

```
Line 1-15:    Project identity (keep)
Line 16-45:   Build commands (keep)
Line 46-95:   API conventions (move to .claude/rules/api.md with paths)
Line 96-140:  Testing standards (move to .claude/rules/testing.md with paths)
Line 141-180: Database conventions (move to .claude/rules/database.md with paths)
Line 181-220: Deployment procedure (move to .claude/skills/deploy/SKILL.md)
Line 221-260: Migration workflow (move to .claude/skills/migrate/SKILL.md)
Line 261-290: Security rules (keep — applies everywhere)
Line 291-310: Documentation rules (keep — applies everywhere)
```

After optimization: root CLAUDE.md is 75 lines (identity + build + security + docs). Three rules files load conditionally. Two skills load on demand. Total instruction content increased from 310 lines to 350 lines, but context consumption dropped because most content loads only when relevant.

## Avoiding Re-Growth

CLAUDE.md files tend to grow. New team members add rules. Features require new conventions. Set a monthly review where you audit the file and move anything over 200 lines back into rules files or skills. A CI check that warns on CLAUDE.md line count helps enforce this:

```bash
# In CI pipeline
LINES=$(wc -l < CLAUDE.md)
if [ "$LINES" -gt 200 ]; then
  echo "::warning::CLAUDE.md is $LINES lines (recommended: under 200)"
fi
```

For a deeper look at the import system and resolution mechanics, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). If your file grew long because of team standards, the [team collaboration guide](/claude-md-team-collaboration-best-practices/) explains how to split shared versus personal content. For context window management beyond CLAUDE.md, see the [context window optimization guide](/claude-md-too-long-context-window-optimization/).

## Related Articles

- [Claude Md Character Limit And — Complete Developer Guide](/claude-md-character-limit-and-optimization-guide/)
