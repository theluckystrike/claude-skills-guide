---
title: "Team CLAUDE.md vs Personal CLAUDE.md (2026)"
description: "How to split instructions between shared CLAUDE.md, personal CLAUDE.local.md, and user-level ~/.claude/CLAUDE.md for team projects."
permalink: /team-claude-md-vs-personal-claude-md/
categories: [claude-md, workflow]
tags: [claude-md, team, personal, CLAUDE.local.md, collaboration]
last_updated: 2026-04-19
---

## Three Layers of Instructions

Claude Code loads instructions from three distinct layers, each with a different scope and purpose. Understanding where each instruction belongs prevents conflicts, reduces bloat, and keeps your team aligned.

| Layer | File | Scope | Who writes it |
|---|---|---|---|
| User | ~/.claude/CLAUDE.md | All your projects | You |
| Project (shared) | ./CLAUDE.md | This project, all team members | Team |
| Project (personal) | ./CLAUDE.local.md | This project, only you | You |

Claude loads them in this order: user-level first, then project CLAUDE.md, then CLAUDE.local.md. When instructions conflict, later files win. CLAUDE.local.md has the final say for your session.

## What Goes in Team CLAUDE.md

The shared CLAUDE.md contains decisions the team agreed on. These are facts about the project and rules that apply to everyone:

```markdown
# CLAUDE.md (committed to git)

## Project
- Language: Go 1.22
- Database: PostgreSQL 16
- API framework: Chi router
- Build: make build
- Test: make test
- Lint: golangci-lint run

## Architecture
- HTTP handlers in internal/handler/
- Business logic in internal/service/
- Database access in internal/repository/
- Handlers call services. Services call repositories. No skipping layers.

## Code Standards
- Error handling: return errors, never panic in library code
- Naming: follow Go conventions (exported = PascalCase, unexported = camelCase)
- Comments: every exported function has a godoc comment
- Tests: table-driven tests with subtests
```

Every developer on the team gets these same instructions. Changes go through pull requests and code review, just like any other shared configuration.

## What Goes in Personal CLAUDE.local.md

CLAUDE.local.md holds your personal workflow preferences. Things that would cause friction if forced on the whole team:

```markdown
# CLAUDE.local.md (gitignored)

## My Preferences
- When I ask for help debugging, start with the error message analysis, then check logs
- I prefer verbose explanations over terse ones
- My local database: postgresql://localhost:5432/myapp_dev
- My preferred test flags: -v -count=1 -race
- When generating code, add a TODO comment at points where I should review the logic
```

Common content for CLAUDE.local.md:
- Local environment URLs and ports
- Personal debugging preferences
- Editor integration settings
- Sandbox URLs for testing
- Verbose/terse output preferences

## What Goes in User-Level ~/.claude/CLAUDE.md

Your global file contains preferences that apply across all projects:

```markdown
# ~/.claude/CLAUDE.md (applies everywhere, never committed)

## Cross-Project Preferences
- Use spaces, not tabs, in all languages
- Commit messages: conventional commits format (feat:, fix:, refactor:)
- When suggesting terminal commands, prefer verbose flags over short flags
- Always mention performance implications of suggested changes
```

This file is machine-local and never shared. It loads before any project CLAUDE.md, so project rules override your global preferences when they conflict.

## Loading Order and Conflict Resolution

When Claude encounters conflicting instructions, the later-loaded file wins:

```
1. ~/.claude/CLAUDE.md         → "Use tabs for indentation"
2. ./CLAUDE.md                 → "Use 2-space indentation"     ← wins over #1
3. ./CLAUDE.local.md           → "Use 4-space indentation"     ← wins over #2
```

All files are concatenated, not replaced. Non-conflicting instructions from all three files are active simultaneously. Only direct contradictions follow the priority order.

You can verify which files are loaded and in what order by running `/memory` in Claude Code. The output lists every active instruction source.

## Common Mistakes

**Putting personal URLs in team CLAUDE.md.** Your localhost database port, staging environment, or sandbox URL should be in CLAUDE.local.md. Other developers have different ports.

**Putting team rules in ~/.claude/CLAUDE.md.** Global preferences apply to all projects. If you put Go-specific rules in your global file, they load when you work on Python projects too.

**Not creating CLAUDE.local.md.** Many developers skip this file and either crowd the team CLAUDE.md with personal preferences or miss out on personalizing their Claude experience. Running `/init` with personal preferences creates it automatically and adds it to .gitignore.

**Contradicting team rules in CLAUDE.local.md.** While technically CLAUDE.local.md wins on conflicts, deliberately overriding team standards defeats the purpose of shared rules. Use it for additions, not overrides.

## Enterprise Layer: Managed CLAUDE.md

Large organizations add a fourth layer -- managed CLAUDE.md deployed to all machines:

```
macOS:   /Library/Application Support/ClaudeCode/CLAUDE.md
Linux:   /etc/claude-code/CLAUDE.md
Windows: C:\Program Files\ClaudeCode\CLAUDE.md
```

Managed policies cannot be excluded by individual developers. They load at the lowest priority level but enforce organizational requirements. Common managed policy content includes security standards, data handling rules, and compliance requirements that apply regardless of project.

Deploy managed CLAUDE.md through your existing configuration management tooling (MDM, Ansible, Group Policy). The file format is identical to any other CLAUDE.md.

## Decision Framework

When you write a new instruction, ask these questions in order:

1. Does this apply to all my projects? Put it in `~/.claude/CLAUDE.md`.
2. Does this apply to this project for all team members? Put it in `./CLAUDE.md`.
3. Does this apply to this project for only me? Put it in `./CLAUDE.local.md`.
4. Does this apply to specific file types? Put it in `.claude/rules/` with paths.
5. Is this a multi-step procedure? Make it a skill in `.claude/skills/`. Learn more in [Migrate CLAUDE.md Between Projects — Portable Patterns (2026)](/migrating-claude-md-between-projects/).

Following this decision tree prevents the two most common problems: rules in the wrong layer (causing conflicts) and rules duplicated across layers (causing maintenance burden).

For managing CLAUDE.md across multiple repositories, see the [version control strategy guide](/claude-md-version-control-strategy-best-practices/). For the full file format specification, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For enterprise-level policy deployment, see the [team collaboration guide](/claude-md-team-collaboration-best-practices/).

## Related Articles

- [Update Team CLAUDE.md Without Breaking Existing Workflows (2026)](/updating-team-claude-md-without-breaking-workflows/)
