---
title: "Monorepo Workspace Package Resolution"
permalink: /claude-code-monorepo-workspace-package-resolution-fix-2026/
description: "Fix monorepo workspace package not found error. Configure workspace protocol and ensure packages are listed in root config."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Cannot find module '@myorg/shared-utils' or its corresponding type declarations.
  Require stack:
  - /packages/api/src/index.ts
  Module not found in workspace: @myorg/shared-utils is not linked
```

This error occurs in monorepo setups when one workspace package cannot resolve another. The dependency exists in the monorepo but is not linked correctly.

## The Fix

1. Ensure the dependency uses the workspace protocol in package.json:

```json
{
  "dependencies": {
    "@myorg/shared-utils": "workspace:*"
  }
}
```

2. Run install to link workspaces:

```bash
# For pnpm:
pnpm install
# For npm:
npm install
# For yarn:
yarn install
```

3. Verify the link exists:

```bash
ls -la node_modules/@myorg/shared-utils
# Should be a symlink to ../../packages/shared-utils
```

4. Rebuild the shared package:

```bash
cd packages/shared-utils && npm run build
cd ../..
npx tsc --noEmit
```

## Why This Happens

Monorepo workspace packages must be explicitly declared in the root package.json workspaces array and properly referenced with workspace protocols. When Claude creates a new package or adds a cross-package import, it may not update the workspace configuration. Without proper linking, Node's module resolution cannot find the sibling package.

## If That Doesn't Work

- Verify the package is listed in root workspaces:

```bash
python3 -c "import json; print(json.load(open('package.json')).get('workspaces', 'NOT SET'))"
```

- Check for TypeScript path mapping:

```json
{
  "compilerOptions": {
    "paths": {
      "@myorg/*": ["packages/*/src"]
    }
  }
}
```

- Clean and reinstall:

```bash
rm -rf node_modules packages/*/node_modules
pnpm install
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Monorepo
- All cross-package deps must use workspace:* protocol.
- After creating a new package, add it to root workspaces array.
- Run pnpm install after any dependency change.
- Add TypeScript paths for @myorg/* in root tsconfig.json.
```

## See Also

- [Claude Code Monorepo: Best Setup Guide (2026)](/claude-code-monorepo-best-setup-2026/)
- [ESM vs CJS Module Resolution Failure — Fix (2026)](/claude-code-esm-vs-cjs-module-resolution-fix-2026/)
- [Claude Code Monorepo Workspace Resolution Failure — Fix (2026)](/claude-code-monorepo-workspace-resolution-failure-fix/)
