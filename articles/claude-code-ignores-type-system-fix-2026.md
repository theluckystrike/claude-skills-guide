---
title: "Make Claude Code Respect Your Type System (2026)"
description: "Force Claude Code to use your TypeScript types, Zod schemas, and interfaces instead of generating untyped or loosely-typed code."
permalink: /claude-code-ignores-type-system-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Respect Your Type System (2026)

Claude Code generates a function that takes `any` as a parameter. Your project has strict TypeScript with `noImplicitAny` enabled. The code fails type checking and you spend time adding types that should have been there from the start.

## The Problem

Claude Code sometimes produces:
- `any` types instead of using your defined interfaces
- Loose types (`object`, `Function`) when specific types exist
- Missing return type annotations
- Type assertions (`as`) instead of proper type narrowing
- New type definitions when equivalent ones already exist

## Root Cause

The model generates code that works at runtime without prioritizing type safety. TypeScript's type system is a compile-time concern, and Claude Code optimizes for functional correctness first. Without explicit instructions, it takes shortcuts that pass runtime tests but fail `tsc --strict`.

## The Fix

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) (4K+ stars, 22K+ lines) includes a detailed TypeScript enforcement section. Combined with CLAUDE.md rules, you can force type-safe output.

### Step 1: Declare Your Type Strategy

```markdown
## TypeScript Rules — STRICT
- tsconfig.json has "strict": true — ALL code must pass
- NEVER use `any` — use `unknown` if the type is genuinely unknown
- NEVER use type assertions (as) unless narrowing from `unknown`
- ALL functions must have explicit return types
- ALL parameters must have explicit types
- Use existing types from src/types/ before creating new ones
```

### Step 2: Register Your Type Definitions

```markdown
## Type Registry (src/types/)
- user.ts: User, UserProfile, UserSettings, CreateUserInput
- api.ts: ApiResponse<T>, ApiError, PaginatedResponse<T>
- auth.ts: AuthToken, Session, LoginCredentials
- common.ts: ID, Timestamp, Email (branded types)

## Zod Schemas (src/schemas/)
- user.schema.ts: createUserSchema, updateUserSchema
- auth.schema.ts: loginSchema, registerSchema
- ALWAYS derive TypeScript types from Zod: type User = z.infer<typeof userSchema>
```

### Step 3: Add Type-Check Verification

```markdown
## Before Completing Any Task
Run `npx tsc --noEmit` to verify type safety.
If there are type errors, fix them before reporting the task as done.
```

## CLAUDE.md Code to Add

```markdown
## Type Safety Protocol
1. Import types from src/types/ — check there first
2. For new data shapes, create a Zod schema first, then derive the type
3. Generic functions must have constrained type parameters (T extends Base)
4. Prefer discriminated unions over optional properties
5. Use branded types for IDs: type UserId = string & { readonly __brand: 'UserId' }
```

## Verification

1. Ask Claude Code to write a function that fetches user data
2. Check: Does it use your `User` type from `src/types/user.ts`?
3. Check: Does the return type use `ApiResponse<User>` from `src/types/api.ts`?
4. Check: Are there zero instances of `any`?
5. Run `npx tsc --noEmit` — zero errors expected

## Prevention

Add a [pre-commit hook](/understanding-claude-code-hooks-system-complete-guide/) that runs `tsc --noEmit`. The [claude-code-templates](https://github.com/davila7/claude-code-templates) collection includes TypeScript-strict agent templates that enforce type safety by default.

Configure your hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx tsc --noEmit 2>&1 | head -20"
    }]
  }
}
```

For more on configuring Claude Code behavior, see [The Claude Code Playbook](/playbook/). Browse TypeScript-specific skills in our [skills directory](/claude-skills-directory-where-to-find-skills/).
