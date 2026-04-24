---
title: "Vite Prebundle Dependency Error — Fix"
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
