---
title: "esbuild Target Mismatch Error — Fix (2026)"
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
