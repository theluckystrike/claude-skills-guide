---
title: "Fix Claude Code Ignoring Project Context (2026)"
description: "Make Claude Code read your codebase before writing code — CLAUDE.md rules for mandatory context loading, reference files, and pattern matching."
permalink: /claude-code-ignores-project-context-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Ignoring Project Context (2026)

Claude Code writes code that works in isolation but doesn't match your project's patterns, conventions, or architecture. It's ignoring context.

## The Problem

- Uses different naming conventions than the rest of the codebase
- Creates patterns that conflict with existing architecture
- Duplicates functionality already present in utility files
- Misses project-specific types, helpers, and shared code

## Root Cause

Claude Code doesn't proactively explore your codebase before starting work. It reads files when referenced or when searching for something specific. Without a directive to understand existing patterns, it defaults to its training data.

## The Fix

```markdown
## Context Loading (Required)
Before writing any new code:
1. Read at least ONE existing file of the same type (service, route, component, test)
2. Identify the patterns: naming, structure, error handling, imports
3. Match those patterns in your new code

### Reference Files
- Service pattern: src/services/user-service.ts
- Route pattern: src/routes/users.ts
- Component pattern: src/components/UserCard.tsx
- Test pattern: tests/services/user-service.test.ts
- Types pattern: src/types/user.ts
```

## CLAUDE.md Rule to Add

```markdown
## Mandatory Context
Before creating a new file, search for existing files of the same type:
- grep for similar names, imports, or patterns
- read the closest match
- follow its structure exactly unless you have a reason not to

Before modifying a file, read it completely first. Do not edit based on assumptions about its contents.
```

## Verification

```
Create a new service for handling inventory
```

**Ignoring context:** creates a class-based service when the project uses functions, uses different error handling
**Using context:** reads `user-service.ts` first, matches its exact function pattern, naming, error types, and export style

Related: [Karpathy Don't Assume Principle](/karpathy-dont-assume-principle-claude-code-2026/) | [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Make Claude Code Read Existing Code](/claude-code-doesnt-read-existing-code-fix-2026/)
