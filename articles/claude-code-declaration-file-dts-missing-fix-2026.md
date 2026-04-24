---
title: "Declaration File .d.ts Missing Error — Fix (2026)"
permalink: /claude-code-declaration-file-dts-missing-fix-2026/
description: "Fix 'Could not find declaration file' TypeScript error. Install @types package or create a custom .d.ts declaration."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
error TS7016: Could not find a declaration file for module 'some-library'.
  '/node_modules/some-library/index.js' implicitly has an 'any' type.
  Try `npm i --save-dev @types/some-library` if it exists or add a new declaration (.d.ts) file.
```

This error occurs when TypeScript cannot find type declarations for an imported JavaScript library. The library works at runtime but TypeScript cannot type-check it.

## The Fix

1. Try installing the community types package:

```bash
npm install --save-dev @types/some-library
```

2. If no @types package exists, create a declaration file:

```bash
mkdir -p src/types
```

```typescript
// src/types/some-library.d.ts
declare module 'some-library' {
  export function doSomething(input: string): Promise<string>;
  export default function init(config: Record<string, unknown>): void;
}
```

3. Ensure tsconfig includes the types directory:

```json
{
  "compilerOptions": {
    "typeRoots": ["./node_modules/@types", "./src/types"]
  }
}
```

4. Verify:

```bash
npx tsc --noEmit
```

## Why This Happens

Many npm packages are written in JavaScript without TypeScript declarations. TypeScript needs `.d.ts` files to understand the types of imported modules. When Claude adds a dependency that lacks types, the compiler throws TS7016. The `@types/` namespace on npm hosts community-maintained declarations, but not every package has one.

## If That Doesn't Work

- Suppress the error for a single import:

```typescript
// @ts-ignore
import something from 'untyped-library';
```

- Set `noImplicitAny: false` in tsconfig (not recommended for strict projects).
- Use `skipLibCheck: true` to skip checking all .d.ts files:

```json
{
  "compilerOptions": { "skipLibCheck": true }
}
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# TypeScript Declarations
- After adding a new dependency, check: npm info @types/PACKAGE
- If no @types exists, create src/types/PACKAGE.d.ts with at least basic types.
- Keep typeRoots in tsconfig pointing to both node_modules/@types and src/types.
```

## See Also

- [Devcontainer Claude Code Path Missing Fix](/claude-code-devcontainer-path-missing-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.
