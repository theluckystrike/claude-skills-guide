---
title: "Migrate CLAUDE.md Between Projects"
description: "How to extract, adapt, and apply CLAUDE.md patterns from one project to another. Covers universal rules, project-specific adaptation, and shared libraries."
permalink: /migrating-claude-md-between-projects/
render_with_liquid: false
categories: [claude-md, workflow]
tags: [claude-md, migration, portable, cross-project, reuse]
last_updated: 2026-04-19
---

## When You Start a New Project

You have a CLAUDE.md that works well in one project. You start a new project and want the same level of Claude Code quality. Copying the entire file rarely works because project-specific details (framework, database, directory structure) differ. The solution is separating portable rules from project-specific ones.

## Identify Portable vs Project-Specific Rules

A typical CLAUDE.md mixes two types of content:

```markdown
# Portable rules (apply to any TypeScript project)
- Use camelCase for variables, PascalCase for types
- No any type — use unknown with type guards
- Functions under 40 lines
- Named exports only

# Project-specific rules (only for this project)
- Database access through src/repositories/
- API responses use src/responses/envelope.ts
- Build: pnpm build
- Test: pnpm test:unit && pnpm test:integration
```

Portable rules encode your engineering principles. Project-specific rules encode this project's architecture. When migrating, you want to carry the principles and rewrite the architecture section.

## Step 1: Extract Portable Rules

Create a standalone file with your universal standards:

```markdown
# ~/claude-standards/universal.md

## Code Quality (Language-Agnostic)
- Maximum function body: 40 lines including comments
- Single responsibility: one function does one thing
- Early returns over nested if/else
- No TODO comments without linked issue numbers
- Error messages include what happened, why, and what to do

## Git Conventions
- Commit messages: conventional commits (feat:, fix:, refactor:, test:)
- One logical change per commit
- PR descriptions explain WHY, not just WHAT

## Documentation
- Every public function has a doc comment with params and return
- README explains how to run, test, and deploy
- Architecture decisions documented in docs/adr/
```

This file travels with you across projects. Import it from any project's CLAUDE.md:

```markdown
# New project's CLAUDE.md
@~/claude-standards/universal.md

## Project: new-api
- Language: Go 1.22
- Framework: Chi
...
```

## Step 2: Create Language-Specific Templates

Maintain one template per language you commonly use:

```markdown
# ~/claude-standards/typescript.md

## TypeScript Standards
- Strict mode enabled
- No any type — use unknown + type guards
- Prefer readonly arrays and Readonly<T>
- Union types over enums for string literals
- Named exports only — no default exports
- Import sorting: node builtins → external → internal → relative
```

```markdown
# ~/claude-standards/python.md

## Python Standards
- Type hints on all function signatures
- Dataclasses over plain dicts for structured data
- Pathlib over os.path for file operations
- F-strings for formatting, never .format() or %
- Docstrings in Google format
```

Import the relevant language template in each project:

```markdown
# CLAUDE.md for a TypeScript project
@~/claude-standards/universal.md
@~/claude-standards/typescript.md

## Project-Specific
...
```

## Step 3: Adapt the Architecture Section

The architecture section always needs rewriting for a new project. Use the old project as a reference, but update every path, framework, and pattern:

```markdown
# Old project (Express + Prisma)
## Architecture
- Handlers in src/routes/
- Services in src/services/
- Repositories in src/repositories/ (Prisma)

# New project (Fastify + Drizzle) — adapted, not copied
## Architecture
- Handlers in src/handlers/
- Services in src/domain/
- Repositories in src/data/ (Drizzle ORM)
```

## Step 4: Migrate .claude/rules/ Files

Rules files with path-specific patterns need their globs updated:

```markdown
# Old project
---
paths:
  - "src/routes/**/*.ts"
---

# New project — different directory structure
---
paths:
  - "src/handlers/**/*.ts"
---
```

Copy the rules file, update the paths, and review the instructions for framework-specific references.

## Using /init for New Projects

Claude Code's `/init` command generates a starter CLAUDE.md by analyzing your project. Run it in your new project, then merge in your portable standards:

```bash
# In new project
claude
# Then type: /init

# Claude generates a CLAUDE.md based on your project's package.json,
# directory structure, and existing configuration

# Then manually add your portable imports:
# @~/claude-standards/universal.md
# @~/claude-standards/typescript.md
```

The `/init` output handles project-specific details (build commands, test runners, directory structure). Your imports handle your engineering standards.

## Migration Checklist

When migrating CLAUDE.md to a new project:

1. Copy portable rules via imports (not copy-paste)
2. Run `/init` to generate project-specific sections
3. Update all file paths and directory references
4. Update framework and library references
5. Update build/test/lint commands
6. Verify with `/memory` that all files load correctly
7. Test by asking Claude to generate code and checking compliance

For maintaining shared standards across multiple projects, see the [cross-team sharing guide](/share-reuse-claude-md-across-teams/). For the import system syntax and resolution, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For version controlling your CLAUDE.md files, see the [version control strategies guide](/claude-md-version-control-strategies/).
