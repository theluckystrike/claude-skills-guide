---
title: "Enforce Coding Standards with CLAUDE.md"
description: "How to write CLAUDE.md rules that Claude Code actually follows for coding standards: naming, formatting, import ordering, and type safety."
permalink: /claude-md-for-coding-standards-enforcement/
categories: [claude-md, patterns]
tags: [claude-md, coding-standards, enforcement, linting, claude-code]
last_updated: 2026-04-19
---

## Why Linters Are Not Enough

Linters catch syntax violations. CLAUDE.md catches design violations. ESLint can flag an unused variable, but it cannot enforce "all repository methods return Result types instead of throwing exceptions" or "API endpoints must validate input with zod before touching the database." Those rules live in your CLAUDE.md because they require understanding intent, not just syntax.

The practical result: Claude Code becomes a second reviewer that catches architectural violations before the code reaches human review. This works only if your instructions are specific enough for Claude to verify.

## The Specificity Rule

Anthropic's documentation gives a clear guideline: write concrete, verifiable instructions. Here is the difference in practice:

```markdown
# Bad — too vague for Claude to verify
- Format code properly
- Use good naming conventions
- Keep functions small

# Good — Claude can check these mechanically
- Use camelCase for variables and functions, PascalCase for types and classes
- Function names start with a verb: get, set, create, delete, validate, parse
- Maximum function body: 40 lines including comments
- No single-letter variable names except i, j, k in loop counters
```

The bad examples leave Claude guessing. "Format code properly" means different things in every codebase. The good examples give Claude a binary test: either the function name starts with a verb or it does not.

## Standards by Category

### Naming Conventions

```markdown
## Naming
- Files: kebab-case (user-service.ts, not UserService.ts)
- React components: PascalCase file and export (UserProfile.tsx)
- Constants: SCREAMING_SNAKE_CASE (MAX_RETRY_COUNT)
- Database columns: snake_case matching Prisma schema exactly
- API endpoints: kebab-case plural nouns (/api/user-profiles, not /api/userProfile)
- Boolean variables: prefixed with is, has, should, can (isActive, hasPermission)
```

### Import Ordering

```markdown
## Imports (enforced order, blank line between groups)
1. Node built-ins (node:fs, node:path)
2. External packages (express, zod, prisma)
3. Internal aliases (@/lib, @/utils, @/types)
4. Relative imports (./helpers, ../shared)
- No default exports. Use named exports exclusively.
- No barrel files (index.ts re-exports). Import from the source file directly.
```

### Type Safety

```markdown
## Types
- No 'any' type. Use 'unknown' with type guards when type is uncertain.
- Function return types: always explicit, never inferred for public functions.
- Prefer 'readonly' arrays and Readonly<T> for objects not meant to be mutated.
- Union types over enums for string literals.
- Zod schemas as the source of truth — derive TypeScript types with z.infer<>.
```

## Using .claude/rules/ for File-Specific Standards

Not every rule applies everywhere. Test files have different standards than production code. Use path-specific rules:

```markdown
# .claude/rules/test-standards.md
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
---

## Test File Standards
- One describe block per file, named after the module under test
- Use test() not it() for consistency
- Arrange-Act-Assert pattern with blank lines between sections
- No test-specific utilities in test files — import from tests/helpers/
- Mock external dependencies, never internal modules
```

This file loads only when Claude reads test files. Production code rules stay in the root CLAUDE.md or their own rules file. The separation prevents Claude from applying test patterns to production code or vice versa.

## Measuring Effectiveness

Track how often Claude follows your standards by reviewing its output against your rules. If Claude consistently ignores a rule, the problem is usually one of three things:

1. **The rule is too vague.** Rewrite it with a concrete test.
2. **The rule contradicts another instruction.** Check all loaded files with `/memory`.
3. **The file is too long.** Claude's adherence drops past 200 lines per file.

The `/memory` command shows every instruction file currently loaded. Use it as your first diagnostic step when standards are not being enforced.

## Documentation Standards

Standards are not just about code -- they include how Claude generates documentation:

```markdown
## Documentation
- Every public function has JSDoc with @param and @returns
- @param descriptions state the expected type AND what it represents
- @returns describes both success and error return values
- No @example in JSDoc — put examples in the test file instead
- README updates required when adding new public API
- CHANGELOG entry required for every user-facing change
```

## Enforcing Across Multiple Languages

In polyglot projects, standards vary by language. Do not put Python rules in the same CLAUDE.md section as TypeScript rules. Instead, use path-specific rules files:

```markdown
# .claude/rules/go-standards.md
---
paths:
  - "**/*.go"
---
- Exported functions: PascalCase, godoc comment required
- Unexported functions: camelCase
- Error return: always last return value
- Use errors.Is and errors.As for error comparison
```

Each language gets its own file with its own path pattern. No conflicts, no confusion.

For the complete writing guide to CLAUDE.md instructions, see the [best practices guide](/claude-code-claude-md-best-practices/). For architecture-level enforcement beyond coding standards, see the [architecture patterns guide](/claude-md-for-enforcing-architecture-patterns/). Teams managing shared standards should read the [team collaboration guide](/claude-md-team-collaboration-best-practices/).

## Related Articles

- [Claude.md for API Design Standards Guide](/claude-md-for-api-design-standards-guide/)
- [How Claude Code Eliminated Boilerplate Coding](/how-claude-code-eliminated-boilerplate-coding/)
- [Make Claude Code Follow Coding Standards (2026)](/claude-code-wont-follow-coding-standards-fix-2026/)
