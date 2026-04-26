---
layout: default
title: "Fix TypeScript Strict Mode Errors (2026)"
description: "Resolve TypeScript strict mode errors using Claude Code. Fix strictNullChecks, noImplicitAny, strictPropertyInitialization, and more. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-typescript-strict-mode-errors-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [typescript, strict-mode, type-safety, refactoring, errors]
geo_optimized: true
---

# Fix TypeScript Strict Mode Errors with Claude Code

## The Problem

You enable `"strict": true` in `tsconfig.json` and suddenly your project has hundreds of errors:

```
src/api/users.ts:23:5 - error TS2322: Type 'string | undefined' is not assignable to type 'string'.
src/utils/format.ts:8:22 - error TS7006: Parameter 'item' implicitly has an 'any' type.
src/models/User.ts:12:3 - error TS2564: Property 'email' has no initializer and is not definitely assigned in the constructor.
```

Strict mode enables multiple compiler flags at once, and the error count can be overwhelming. Fixing them manually across a large codebase takes days.

## Quick Fix

Ask Claude Code to fix strict mode errors file by file:

```
I just enabled strict mode in tsconfig.json. Fix all TypeScript errors
in src/api/users.ts. Use proper types, not 'any'. Add null checks where
needed. Do not use non-null assertions (!) unless the value is provably non-null.
```

For a bulk approach:

```
Run tsc --noEmit and show me the error count per file. Then fix each file
starting with the one that has the most errors. Use proper types, not any.
```

## What's Happening

TypeScript's `"strict": true` enables these individual flags:

| Flag | What it catches |
|------|----------------|
| `strictNullChecks` | Variables that is `null` or `undefined` used without checking |
| `noImplicitAny` | Parameters and variables without type annotations |
| `strictFunctionTypes` | Contravariant function parameter checking |
| `strictBindCallApply` | Type-checking for `bind`, `call`, and `apply` |
| `strictPropertyInitialization` | Class properties not initialized in constructor |
| `noImplicitThis` | `this` with implicit `any` type |
| `alwaysStrict` | Emit `"use strict"` in every file |
| `useUnknownInCatchVariables` | Catch variables typed as `unknown` instead of `any` |

Each flag catches real bugs. The errors are not false positives. They represent places where your code makes unsafe assumptions about types.

## Step-by-Step Fix

### Step 1: Enable strict mode incrementally

Instead of enabling everything at once, start with individual flags:

```json
{
 "compilerOptions": {
 "strict": false,
 "strictNullChecks": true
 }
}
```

Ask Claude Code to fix all `strictNullChecks` errors first, then enable the next flag:

```
Enable strictNullChecks in tsconfig.json. Run tsc --noEmit and fix
every resulting error. Use proper null guards, not type assertions.
```

### Step 2: Fix strictNullChecks errors

These are the most common and most valuable errors. They catch potential runtime crashes:

```typescript
// Error: Object is possibly 'undefined'
function getUserName(user?: User): string {
 return user.name; // TS2532
}

// Fix with a guard
function getUserName(user?: User): string {
 if (!user) {
 throw new Error('User is required');
 }
 return user.name;
}

// Or with a default
function getUserName(user?: User): string {
 return user?.name ?? 'Anonymous';
}
```

For function return types:

```typescript
// Error: Type 'string | undefined' is not assignable to type 'string'
function findUser(id: string): User {
 return users.find(u => u.id === id); // is undefined
}

// Fix: update the return type
function findUser(id: string): User | undefined {
 return users.find(u => u.id === id);
}

// Or throw if not found
function findUserOrThrow(id: string): User {
 const user = users.find(u => u.id === id);
 if (!user) {
 throw new Error(`User not found: ${id}`);
 }
 return user;
}
```

### Step 3: Fix noImplicitAny errors

These errors flag parameters and variables without type annotations:

```typescript
// Error: Parameter 'item' implicitly has an 'any' type
function processItems(items) {
 return items.map(item => item.name);
}

// Fix: add type annotations
interface Item {
 name: string;
 value: number;
}

function processItems(items: Item[]): string[] {
 return items.map(item => item.name);
}
```

Ask Claude Code to infer the correct types from usage:

```
Fix all noImplicitAny errors in src/utils/. Analyze how each function is
called throughout the codebase to determine the correct types. Do not use 'any'.
```

### Step 4: Fix strictPropertyInitialization errors

Class properties must be initialized in the constructor or declared as optional:

```typescript
// Error: Property 'email' has no initializer
class User {
 name: string; // TS2564
 email: string; // TS2564

 async init(id: string) {
 const data = await fetchUser(id);
 this.name = data.name;
 this.email = data.email;
 }
}

// Fix Option 1: Initialize in constructor
class User {
 name: string;
 email: string;

 constructor(name: string, email: string) {
 this.name = name;
 this.email = email;
 }
}

// Fix Option 2: Use the definite assignment assertion (only when truly needed)
class User {
 name!: string; // Only if you guarantee initialization before use
 email!: string;
}

// Fix Option 3: Make optional with default
class User {
 name: string = '';
 email: string = '';
}
```

### Step 5: Fix useUnknownInCatchVariables errors

Catch variables are now `unknown` instead of `any`:

```typescript
// Error: Object is of type 'unknown'
try {
 await fetchData();
} catch (error) {
 console.log(error.message); // TS18046
}

// Fix: type guard
try {
 await fetchData();
} catch (error) {
 if (error instanceof Error) {
 console.log(error.message);
 } else {
 console.log('Unknown error:', String(error));
 }
}
```

### Step 6: Bulk fix with Claude Code

For large codebases, ask Claude Code to process files systematically:

```
Run tsc --noEmit 2>&1 | head -200 and categorize the errors by type.
Then fix files in this order:
1. Shared types/interfaces first (src/types/)
2. Utility functions (src/utils/)
3. Data models (src/models/)
4. API handlers (src/api/)
5. Components (src/components/)
```

This order matters because fixing shared types first resolves cascading errors in dependent files.

## Prevention

Always start new projects with strict mode enabled:

```json
{
 "compilerOptions": {
 "strict": true,
 "noUncheckedIndexedAccess": true,
 "exactOptionalPropertyTypes": true
 }
}
```

Add to your CLAUDE.md:

```markdown
## TypeScript Rules
- strict mode is enabled, do not add @ts-ignore or type assertions
- Use proper null guards, not non-null assertions (!)
- Every function parameter must have an explicit type
- Prefer 'unknown' over 'any' for dynamic values
- Use discriminated unions for complex state types
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-typescript-strict-mode-errors-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code VS Copilot for TypeScript Refactoring](/claude-code-vs-copilot-for-typescript-refactoring/)
- [Claude Code CLAUDE.md Best Practices](/claude-code-claude-md-best-practices/)

## See Also

- [Locale LC_ALL Not Set Encoding Errors Fix](/claude-code-locale-lc-all-not-set-encoding-errors-fix-2026/)
- [TypeScript Strict Mode Breaks Claude Generated Code — Fix (2026)](/claude-code-typescript-strict-mode-breaks-generated-code-fix/)
- [TypeScript Strict Null Checks in Generated Code — Fix (2026)](/claude-code-typescript-strict-null-checks-generated-fix-2026/)
