---
title: "ESM vs CJS Module Resolution Failure"
permalink: /claude-code-esm-vs-cjs-module-resolution-fix-2026/
description: "Claude Code comparison: eSM vs CJS Module Resolution Failure — Fix — step-by-step fix with tested commands, error codes, and verified solutions for..."
last_tested: "2026-04-22"
---

## The Error

```
Error [ERR_REQUIRE_ESM]: require() of ES Module /node_modules/some-package/index.mjs is not supported.
Instead change the require of index.mjs to a dynamic import() which is available in all CommonJS modules.
```

This error occurs when Claude generates `require()` calls for a package that only exports ESM modules, or when your project mixes ESM and CJS formats.

## The Fix

1. Check your package.json `type` field:

```bash
python3 -c "import json; print(json.load(open('package.json')).get('type', 'commonjs'))"
```

2. If your project is ESM (`"type": "module"`), use import syntax:

```typescript
// Before (CJS - fails in ESM project):
const pkg = require('some-package');

// After (ESM - correct):
import pkg from 'some-package';
```

3. If your project is CJS and the dependency is ESM-only, use dynamic import:

```javascript
// In a .cjs or "type": "commonjs" project:
const pkg = await import('some-package');
```

4. Verify the fix:

```bash
node --experimental-vm-modules your-script.js
```

## Why This Happens

Node.js has two module systems: CommonJS (require/module.exports) and ES Modules (import/export). They are not interchangeable. Claude sometimes generates CJS code for an ESM project or vice versa because it does not always detect the project's module format. Many npm packages have migrated to ESM-only, breaking require() calls.

## If That Doesn't Work

- Add explicit file extensions to all imports (required in ESM):

```typescript
// ESM requires extensions:
import { helper } from './utils.js';  // Not './utils'
```

- Configure tsconfig.json for ESM:

```json
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "bundler"
  }
}
```

- Use a bundler (Vite, esbuild) that handles mixed module formats transparently.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Module Format
- This project uses ESM ("type": "module" in package.json).
- Always use import/export, never require()/module.exports.
- Always include .js extensions in relative imports.
- Check dependency module format before importing.
```

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


## Related Guides

- [Monorepo Workspace Package Resolution](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
- [CLAUDE.md Conflict Resolution](/claude-md-conflict-resolution/)
- [Claude Code Merge Conflict Resolution](/claude-code-merge-conflict-resolution-guide/)
- [DNS Resolution Timeout Error — Fix](/claude-code-dns-resolution-timeout-fix-2026/)

## Making the Right Choice

When deciding between these options, consider these practical factors:

**Project requirements.** The best tool depends on what your project actually needs, not which is more popular. A small personal project has different requirements than an enterprise application with compliance needs.

**Team familiarity.** Choosing a tool your team already knows reduces onboarding time. The productivity gains from familiarity often outweigh the theoretical advantages of switching to a newer tool.

**Ecosystem maturity.** Check the package ecosystem, community size, and documentation quality. A tool with 10,000 npm packages and active Stack Overflow answers will be easier to work with than a newer tool with cutting-edge features but sparse documentation.

**Migration cost.** If you are considering switching, estimate the migration effort realistically. Include time for rewriting tests, updating CI/CD pipelines, retraining the team, and handling edge cases that only appear in production.

## Decision Framework

| Factor | Weight | Option A | Option B |
|--------|--------|----------|----------|
| Performance | Medium | Score 1-5 | Score 1-5 |
| Ecosystem | High | Score 1-5 | Score 1-5 |
| Learning curve | Medium | Score 1-5 | Score 1-5 |
| Long-term viability | High | Score 1-5 | Score 1-5 |

Score each factor for your specific situation, multiply by weight, and compare totals. This structured approach prevents decisions based on hype or recency bias.
