---
title: "Claude Code Monorepo Workspace"
description: "Fix Claude Code monorepo workspace resolution failure. Configure workspace protocols and package paths. Step-by-step solution."
permalink: /claude-code-monorepo-workspace-resolution-failure-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
ERR_PNPM_WORKSPACE_PKG_NOT_FOUND: Package "@myorg/shared" not found
  in any of the workspace packages.

# Or with npm workspaces:
npm ERR! 404 Not Found - GET https://registry.npmjs.org/@myorg%2fshared
  (Package is local but npm tried to fetch from registry)

# Or:
Error: Cannot find module '@myorg/shared' or its corresponding type declarations.
  at resolveModuleName (typescript/lib/typescript.js:42567:35)
```

## The Fix

1. **Verify workspace configuration matches your package manager**

```bash
# For pnpm — check pnpm-workspace.yaml exists
cat pnpm-workspace.yaml
# Should contain:
# packages:
#   - 'packages/*'
#   - 'apps/*'

# For npm — check package.json workspaces
cat package.json | python3 -c "import sys,json; print(json.load(sys.stdin).get('workspaces', 'NOT SET'))"
```

2. **Use the workspace protocol for local dependencies**

```bash
# In packages/app/package.json, reference local packages with workspace:
# For pnpm:
# "dependencies": { "@myorg/shared": "workspace:*" }

# For npm:
# "dependencies": { "@myorg/shared": "*" }

# Then install to create proper symlinks:
pnpm install  # or npm install
```

3. **Verify the fix:**

```bash
# Check that the workspace package is linked correctly
ls -la node_modules/@myorg/shared
# Expected: Symlink pointing to ../../packages/shared

# Verify TypeScript can resolve it
npx tsc --noEmit --traceResolution 2>&1 | grep "@myorg/shared" | head -5
# Expected: Resolution path showing local package, not registry
```

## Why This Happens

Monorepo workspace resolution depends on three things aligning: the workspace root configuration (pnpm-workspace.yaml or package.json workspaces), the dependency declaration in consuming packages (using `workspace:*` protocol for pnpm), and the actual symlinks in node_modules. When Claude Code adds a new package dependency or creates a new workspace package, it often misses the workspace protocol prefix, causing the package manager to search the npm registry instead of linking locally. TypeScript resolution fails separately because it needs `paths` or `references` in tsconfig.json.

## If That Doesn't Work

- **Alternative 1:** Add TypeScript project references: `"references": [{"path": "../shared"}]` in tsconfig.json
- **Alternative 2:** Add path aliases in tsconfig.json: `"paths": {"@myorg/shared": ["../shared/src"]}`
- **Check:** Run `pnpm ls --depth 0` or `npm ls` to see which packages are resolved and whether they point to local or registry versions

## Prevention

Add to your `CLAUDE.md`:
```markdown
This is a pnpm monorepo. Always use workspace:* protocol for local package dependencies. After adding a new workspace package, run pnpm install. Include the package in pnpm-workspace.yaml before referencing it. Check tsconfig.json paths for TypeScript resolution.
```

**Related articles:** [Monorepo Setup Guide](/claude-code-monorepo-setup-guide/), [Claude Code Not Working After Update](/claude-code-not-working-after-update-how-to-fix/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Claude Code Monorepo: Best Setup Guide (2026)](/claude-code-monorepo-best-setup-2026/)
- [Plugin Load Failure Error — Fix (2026)](/claude-code-plugin-load-failure-fix-2026/)
- [IPv6 Fallback Failure Error — Fix (2026)](/claude-code-ipv6-fallback-failure-fix-2026/)
- [TLS Version Negotiation Failure — Fix (2026)](/claude-code-tls-version-negotiation-failure-fix-2026/)
- [Monorepo Workspace Package Resolution — Fix (2026)](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
