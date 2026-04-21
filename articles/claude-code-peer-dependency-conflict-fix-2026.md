---
title: "Peer Dependency Conflict npm Error — Fix (2026)"
permalink: /claude-code-peer-dependency-conflict-fix-2026/
description: "Fix npm ERESOLVE peer dependency conflict. Use --legacy-peer-deps or align versions to resolve conflicting requirements."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! peer react@"^17.0.0" from some-component@2.1.0
npm ERR! node_modules/some-component
npm ERR!   some-component@"^2.1.0" from the root project
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^17.0.0" from some-component@2.1.0
npm ERR! Conflicting peer dependency: react@17.0.2
```

This error occurs when Claude adds a dependency that requires a different version of a peer dependency than what your project uses.

## The Fix

1. Check what version you have vs what is required:

```bash
npm ls react
```

2. Try installing with legacy peer deps (quick fix):

```bash
npm install --legacy-peer-deps
```

3. Better: update the conflicting package to a version compatible with your React:

```bash
npm install some-component@latest
```

4. Verify no conflicts remain:

```bash
npm ls --all 2>&1 | grep "ERESOLVE\|peer dep\|invalid"
```

## Why This Happens

npm v7+ enforces strict peer dependency resolution by default. When package A requires `react@^17` but your project uses `react@18`, npm refuses to install because it cannot satisfy both constraints. Claude adds dependencies based on functionality without checking peer dependency compatibility against your existing packages.

## If That Doesn't Work

- Force the installation (use with caution):

```bash
npm install --force
```

- Use pnpm which handles peer deps more gracefully:

```bash
npm install -g pnpm
pnpm import  # Convert from npm
pnpm install
```

- Pin the overriding version in package.json:

```json
{
  "overrides": {
    "react": "^18.0.0"
  }
}
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Dependencies
- Check peer dependencies before adding packages: npm info PACKAGE peerDependencies
- Use overrides in package.json to resolve peer conflicts.
- Prefer packages that support our React/Next.js version.
- Run npm ls after every install to catch conflicts early.
```
