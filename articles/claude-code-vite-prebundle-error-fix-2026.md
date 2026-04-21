---
title: "Vite Prebundle Dependency Error — Fix (2026)"
permalink: /claude-code-vite-prebundle-error-fix-2026/
description: "Fix Vite prebundle errors on new dependencies. Clear .vite cache and add missing deps to optimizeDeps.include in config."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
[vite] Internal server error: Failed to resolve import "new-dependency" from "src/App.tsx".
Does the file exist?
[vite] Pre-bundling dependencies: new-dependency... failed
Error: Build failed with 1 error: node_modules/new-dependency/dist/index.mjs:1:0: error: Could not resolve "node:crypto"
```

This error occurs when Vite's dependency pre-bundling fails on a newly added package, typically because the package uses Node.js built-in modules not available in the browser.

## The Fix

1. Clear Vite's cache and restart:

```bash
rm -rf node_modules/.vite
npx vite --force
```

2. If the dependency uses Node builtins, add polyfills:

```bash
npm install node-stdlib-browser vite-plugin-node-stdlib-browser
```

3. Update vite.config.ts:

```typescript
import nodePolyfills from 'vite-plugin-node-stdlib-browser';
export default {
  plugins: [nodePolyfills()],
  optimizeDeps: {
    include: ['new-dependency']
  }
};
```

4. Restart the dev server:

```bash
npx vite
```

## Why This Happens

Vite pre-bundles dependencies using esbuild for faster dev server startup. When Claude adds a new dependency to your project, Vite may not detect it until restart. Some packages import Node.js built-ins (crypto, fs, path) that do not exist in the browser. Unlike webpack, Vite does not automatically polyfill Node built-ins.

## If That Doesn't Work

- Force Vite to include the dependency explicitly:

```typescript
// vite.config.ts
export default {
  optimizeDeps: {
    include: ['new-dependency', 'new-dependency/dist/module'],
    esbuildOptions: {
      target: 'esnext'
    }
  }
};
```

- If the dependency is server-only, mark it as external:

```typescript
export default {
  build: {
    rollupOptions: {
      external: ['new-dependency']
    }
  }
};
```

- Use a browser-compatible alternative package.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Vite Dependencies
- After adding npm packages, restart Vite with --force flag.
- Add Node-dependent packages to optimizeDeps.include in vite.config.ts.
- Never import Node.js built-in modules in frontend code.
```
