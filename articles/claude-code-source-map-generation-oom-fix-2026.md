---
title: "Source Map Generation Out of Memory — Fix (2026)"
permalink: /claude-code-source-map-generation-oom-fix-2026/
description: "Fix OOM crash during source map generation. Increase Node heap size or switch to cheap-source-map for large bundles."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
  at SourceMapGenerator.addMapping (node_modules/source-map/lib/source-map-generator.js:107)
  generating source maps for bundle.js (12.4 MB)
```

This error occurs when building source maps for large bundles exhausts Node's default 4GB heap. The source map generator holds the entire mapping in memory.

## The Fix

1. Increase Node's memory limit for the build:

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
npm run build
```

2. Or use a lighter source map strategy in webpack:

```javascript
// webpack.config.js
module.exports = {
  devtool: 'cheap-module-source-map',  // Instead of 'source-map'
};
```

3. For Vite, disable source maps in production:

```typescript
// vite.config.ts
export default {
  build: {
    sourcemap: false,  // Or 'hidden' for error tracking only
  }
};
```

4. Rebuild:

```bash
NODE_OPTIONS="--max-old-space-size=8192" npm run build
```

## Why This Happens

Full source maps (`devtool: 'source-map'`) generate a complete mapping from every character in the output back to the original source. For large bundles (10MB+), this mapping structure can consume 3-5x the bundle size in memory. Node's default heap of 4GB is insufficient for bundles that produce source maps exceeding 50MB.

## If That Doesn't Work

- Split the bundle to reduce per-chunk source map size:

```javascript
module.exports = {
  optimization: {
    splitChunks: { chunks: 'all', maxSize: 500000 }
  }
};
```

- Use `nosources-source-map` which includes line mappings but not source content:

```javascript
module.exports = { devtool: 'nosources-source-map' };
```

- Upload source maps separately to your error tracking service and exclude them from the bundle.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Source Maps
- Use cheap-module-source-map for development, hidden-source-map for production.
- Set NODE_OPTIONS=--max-old-space-size=8192 in CI build scripts.
- Split bundles to keep chunks under 500KB for manageable source maps.
```
