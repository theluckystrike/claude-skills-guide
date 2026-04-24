---
title: "esbuild Target Mismatch Error — Fix"
permalink: /claude-code-esbuild-target-mismatch-fix-2026/
description: "Fix esbuild target mismatch transforming modern syntax. Set target to match your Node or browser minimum version."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
X [ERROR] Transforming top-level await is not supported with the "cjs" output format
  src/index.ts:5:0:
    5 | const data = await fetchConfig();
      ^ Top-level await requires "esm" format or target "node18" or higher
```

This error occurs when esbuild's target setting does not support syntax features used in your code. Top-level await, import assertions, and decorators require specific target configurations.

## The Fix

1. Update the esbuild target to match your runtime:

```javascript
// esbuild.config.js
require('esbuild').build({
  entryPoints: ['src/index.ts'],
  bundle: true,
  platform: 'node',
  target: 'node22',
  format: 'esm',
  outfile: 'dist/index.js'
});
```

2. Or via CLI:

```bash
npx esbuild src/index.ts --bundle --platform=node --target=node22 --format=esm --outfile=dist/index.js
```

3. Verify the build:

```bash
node dist/index.js
```

## Why This Happens

esbuild transforms modern JavaScript syntax to match the specified target. When the target is older than the syntax used (e.g., target `node14` with top-level await which requires Node 14.8+ in ESM), esbuild cannot downcompile certain features and throws an error. Claude-generated code often uses the latest syntax without checking the build target.

## If That Doesn't Work

- If building for browsers, set appropriate targets:

```bash
npx esbuild src/index.ts --bundle --target=chrome100,firefox100,safari15
```

- Wrap top-level await in an async IIFE for CJS output:

```typescript
(async () => {
  const data = await fetchConfig();
})();
```

- Check if your tsconfig target conflicts with esbuild target — they should agree.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# esbuild Configuration
- Target: node22 for backend, chrome100 for frontend.
- Format: esm for new projects. Only use cjs for legacy compatibility.
- Do not use top-level await in CJS output format.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`
- `MODULE_NOT_FOUND: Cannot find module 'node:fs'`
- `Error reading configuration file`
- `JSON parse error in config`

## Frequently Asked Questions

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.

### How do I manage multiple Node.js versions?

Use nvm (Node Version Manager): `nvm install 20 && nvm use 20`. This lets you switch between Node.js versions per-project without affecting other applications. Add a `.nvmrc` file with `20` to your project root so nvm automatically selects the right version.

### Why does Claude Code fail with the node:fs prefix?

The `node:` prefix for built-in modules was introduced in Node.js 16. If you see errors about `node:fs` or `node:path`, you are running an older Node.js version that does not support this syntax. Upgrade to Node.js 18 or later.

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.
