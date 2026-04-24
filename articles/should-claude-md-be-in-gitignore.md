---
title: "Should CLAUDE.md Be in .gitignore? When (2026)"
description: "The definitive answer on whether CLAUDE.md belongs in version control, .gitignore, or both. Covers CLAUDE.local.md, team standards, and personal preferences."
permalink: /should-claude-md-be-in-gitignore/
categories: [claude-md, workflow]
tags: [claude-md, gitignore, version-control, team, claude-code]
last_updated: 2026-04-19
---

## The Short Answer

Commit CLAUDE.md. Gitignore CLAUDE.local.md. This separation exists by design in Claude Code: CLAUDE.md holds team standards that everyone shares, while CLAUDE.local.md holds personal preferences that only you need.

The longer answer depends on what is in your file and who needs to see it.

## What Gets Committed (CLAUDE.md)

Your project's CLAUDE.md belongs in version control when it contains shared team standards:

```markdown
# CLAUDE.md — committed to git

## Project Identity
- Language: TypeScript 5.4, strict mode
- Framework: Next.js 15, App Router
- Database: PostgreSQL 16 via Prisma

## Build Commands
- Install: pnpm install
- Dev: pnpm dev
- Test: pnpm test
- Lint: pnpm lint

## Architecture Rules
- All database access through src/repositories/
- API routes return responses through the envelope helper
- No default exports — named exports only
```

These instructions represent decisions the entire team agreed on. Committing them means every developer gets the same Claude behavior, new team members start with the right conventions, and rule changes go through code review.

## What Gets Gitignored (CLAUDE.local.md)

CLAUDE.local.md stores personal preferences. Add it to your .gitignore:

```bash
# .gitignore
CLAUDE.local.md
```

```markdown
# CLAUDE.local.md — gitignored, personal only

## My Preferences
- When generating tests, include console.log for debugging (I remove before commit)
- Use verbose variable names — I find abbreviations harder to read
- Default test database: postgresql://localhost:5433/myproject_test
- My sandbox URLs: http://localhost:3001 for frontend, http://localhost:4000 for API
```

CLAUDE.local.md loads after CLAUDE.md in the same directory. When instructions conflict, CLAUDE.local.md wins. This means you can override team defaults for your local workflow without changing the shared config.

Running `/init` with the personal preferences option automatically creates CLAUDE.local.md and adds it to .gitignore.

## The .claude/ Directory

The `.claude/` directory also has files that split between committed and ignored:

```
.claude/
  settings.json          # team settings — commit
  settings.local.json    # personal settings — gitignore
  CLAUDE.md              # alternative location for team CLAUDE.md — commit
  rules/                 # team rules files — commit
    testing.md
    api-design.md
  skills/                # team skills — commit
    deploy/
      SKILL.md
```

The `.claude/settings.local.json` file contains your personal tool permissions and should be gitignored. The `settings.json` file contains team-level permissions and should be committed.

## When CLAUDE.md Should NOT Be Committed

There are two situations where gitignoring CLAUDE.md makes sense:

**Personal projects.** If you are the only developer, there is no team to share with. You might still commit it for backup and history, but it is not critical.

**Sensitive information.** If your CLAUDE.md contains internal URLs, staging credentials, or proprietary architecture details, think carefully about committing it to public repositories. Move sensitive content to CLAUDE.local.md (gitignored) or use environment variables.

```markdown
# Bad — committed CLAUDE.md with sensitive info
- Staging API: https://staging-api.internal.company.com
- Admin password: use "test123" for local dev

# Good — sensitive info in CLAUDE.local.md (gitignored)
# CLAUDE.md just references the pattern:
- Staging API URL is in CLAUDE.local.md
- Test credentials are in .env.local
```

## User-Level CLAUDE.md

Your global preferences go in `~/.claude/CLAUDE.md`. This file loads for every project and is never part of any git repository:

```markdown
# ~/.claude/CLAUDE.md — applies to all projects

## My Global Preferences
- Use 2-space indentation in all languages
- Prefer const over let in JavaScript/TypeScript
- When generating git commit messages, use conventional commits format
- Always suggest running tests after code changes
```

User-level rules load before project rules, so project CLAUDE.md instructions take precedence when they conflict.

## Practical .gitignore Setup

Here is the standard .gitignore block for Claude Code files:

```gitignore
# Claude Code — personal files (do not commit)
CLAUDE.local.md
.claude/settings.local.json

# Claude Code — team files (DO commit)
# CLAUDE.md
# .claude/settings.json
# .claude/rules/
# .claude/skills/
```

To verify your setup, run `/memory` in Claude Code. It shows every loaded instruction file, including whether it comes from the project, user, or managed level.

## The .claude/rules/ Decision

Rules files in `.claude/rules/` follow the same pattern as CLAUDE.md: commit the shared ones, gitignore any personal rule files. If you have team-wide testing standards, commit `testing.md` to `.claude/rules/`. If you have personal debugging rules, create them in your user-level rules directory at `~/.claude/rules/` instead.

```bash
# Good: team rules committed
.claude/rules/testing.md           # committed
.claude/rules/api-design.md        # committed
.claude/rules/security.md          # committed

# Good: personal rules in user directory (never in project)
~/.claude/rules/my-debug-prefs.md  # personal, all projects
```

## Skills and Commands

The `.claude/skills/` directory should be committed when skills represent team workflows (deployment, migration, code review). Personal scripts and one-off automations belong in your personal skills directory at `~/.claude/skills/`.

## When Open Source Projects Should Commit CLAUDE.md

For open source projects, committing CLAUDE.md benefits contributors. It tells Claude Code how to work with your project -- build commands, coding standards, and contribution guidelines. Contributors who use Claude Code get correct guidance from their first interaction. Include a note in your README that you maintain a CLAUDE.md for AI-assisted development.

For managing shared CLAUDE.md across multiple team members, see the [team collaboration guide](/claude-md-team-collaboration-best-practices/). For the complete file format and loading order, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For version control strategies beyond basic commit/ignore, see the [version control strategy guide](/claude-md-version-control-strategy-best-practices/).
