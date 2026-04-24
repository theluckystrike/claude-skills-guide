---
title: "Make Claude Code Follow Coding"
description: "Enforce your team's coding standards in Claude Code with CLAUDE.md directives, reference files, and pre-commit hooks that reject violations."
permalink: /claude-code-wont-follow-coding-standards-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Follow Coding Standards (2026)

Claude Code generates syntactically valid code that ignores your team's conventions — wrong naming patterns, different error handling, inconsistent patterns. Here's how to make it comply.

## The Problem

Your team uses specific patterns: camelCase vs. snake_case, Result types vs. exceptions, functional vs. OOP, specific import ordering. Claude Code defaults to the most common pattern from its training data, not yours.

## Root Cause

Claude Code doesn't automatically scan your entire codebase for conventions. It reads files as needed and may not encounter the file that establishes your patterns. Without explicit rules, it falls back to statistical defaults.

## The Fix

### 1. Document Standards in CLAUDE.md

```markdown
## Coding Standards

### Naming
- Variables and functions: camelCase
- Types and interfaces: PascalCase
- Constants: UPPER_SNAKE_CASE
- File names: kebab-case.ts

### Patterns
- Error handling: Result<T, E> type, no try/catch for business logic
- Async: async/await, never .then() chains
- Validation: Zod schemas at API boundaries
- State: useState for local, Zustand for shared

### Reference Files
- See src/services/user-service.ts for the service pattern
- See src/routes/users.ts for the route handler pattern
- See src/types/result.ts for the error handling pattern
```

### 2. Add a Pre-Commit Hook

Use a [hook](/understanding-claude-code-hooks-system-complete-guide/) that runs your linter:

```bash
#!/bin/bash
# .claude/hooks/pre-commit-lint.sh
npx eslint --fix $(git diff --cached --name-only --diff-filter=ACM -- '*.ts')
```

### 3. Point to Examples

```markdown
## Before Writing Code
Read these files first to match the existing patterns:
- src/services/user-service.ts (service pattern)
- src/routes/users.ts (route pattern)
- tests/services/user-service.test.ts (test pattern)
```

## CLAUDE.md Rule to Add

```markdown
## Standards Enforcement
- Before writing new code, read at least one existing file of the same type to match patterns
- Follow the naming conventions in this CLAUDE.md exactly
- When unsure about a convention, check the nearest existing file for the pattern
- NEVER use patterns not established in the codebase without asking first
```

## Verification

```
Create a new service for handling product inventory
```

**Non-compliant:** uses classes when the project uses functions, throws errors when the project uses Result types, uses different naming conventions

**Compliant:** matches the exact pattern from `user-service.ts` — same file structure, same naming, same error handling

Related: [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [Fix Inconsistent Style](/claude-code-inconsistent-style-fix-2026/)
