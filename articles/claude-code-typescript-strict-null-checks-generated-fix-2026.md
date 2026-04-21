---
title: "TypeScript Strict Null Checks in Generated Code — Fix (2026)"
permalink: /claude-code-typescript-strict-null-checks-generated-fix-2026/
description: "Fix TypeScript strict null check errors in Claude-generated code. Add null guards and optional chaining to generated functions."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
error TS2531: Object is possibly 'null'.
  src/services/user.ts:24:15 - error TS2531
    const name = user.profile.displayName;
                 ~~~~
```

This error appears when Claude generates code that does not account for `strictNullChecks: true` in your tsconfig.json. Claude may produce code that accesses properties without null guards.

## The Fix

1. Add null guards to the generated code:

```typescript
// Before (fails strict null):
const name = user.profile.displayName;

// After (passes strict null):
const name = user?.profile?.displayName ?? 'Unknown';
```

2. Tell Claude about your strict config in CLAUDE.md:

```bash
echo '- TypeScript strict mode is ON. Always use optional chaining (?.) and nullish coalescing (??).' >> CLAUDE.md
```

3. Verify the fix compiles:

```bash
npx tsc --noEmit
```

## Why This Happens

Claude generates code based on the prompt and context, but without access to your full tsconfig.json, it defaults to non-strict patterns. When `strictNullChecks` is true, TypeScript requires explicit null handling for every potentially null value. Claude's generated code often assumes values exist, causing compile errors in strict projects.

## If That Doesn't Work

- Add type assertions where null is impossible by design:

```typescript
const name = (user.profile as NonNullable<typeof user.profile>).displayName;
```

- Use a type guard function:

```typescript
function assertDefined<T>(val: T | null | undefined, name: string): asserts val is T {
  if (val == null) throw new Error(`${name} is null`);
}
assertDefined(user.profile, 'user.profile');
```

- Run Claude with strict context: include the tsconfig.json in your prompt.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# TypeScript Rules
- strictNullChecks is ON. Always handle null/undefined.
- Use optional chaining (?.) for property access on optional types.
- Use nullish coalescing (??) for default values, never || for booleans/numbers.
- Run npx tsc --noEmit after every code change.
```
