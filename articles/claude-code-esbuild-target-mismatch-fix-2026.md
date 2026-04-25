---
title: "esbuild Target Mismatch Error — Fix"
permalink: /claude-code-esbuild-target-mismatch-fix-2026/
description: "Claude Code troubleshooting: esbuild Target Mismatch Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for..."
last_tested: "2026-04-22"
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


## Related Guides

- [Token Count Estimation Mismatch — Fix (2026)](/claude-code-token-count-estimation-mismatch-fix-2026/)
- [MCP Protocol Version Mismatch in Claude — Fix (2026)](/claude-code-model-context-protocol-version-mismatch-fix-2026/)
- [Claude Code Node Version Mismatch — Fix](/claude-code-node-version-mismatch-fix/)
- [Claude API Key Organization Mismatch — Fix (2026)](/claude-code-api-key-organization-mismatch-fix-2026/)

## Build Tool Configuration with Claude Code

When Claude Code generates or modifies build configurations, ensure the output matches your project's build pipeline:

**Webpack specifics.** Claude Code may generate webpack 4 syntax when your project uses webpack 5. Key differences: `module.rules` (not `module.loaders`), `asset/resource` (not `file-loader`), and native module federation. Always specify your webpack version in CLAUDE.md.

**Vite projects.** Claude Code sometimes generates Create React App patterns when the project uses Vite. Add to CLAUDE.md: "This project uses Vite, not CRA. Use `import.meta.env` for environment variables, not `process.env`. Dev server runs on port 5173."

**Tree-shaking requirements.** For tree-shaking to work, modules must use ES module syntax (`import`/`export`), not CommonJS (`require`/`module.exports`). Claude Code defaults to whichever pattern it finds in existing code. If your project mixes both, add a CLAUDE.md rule specifying which to use.

## Build Error Debugging Steps

When Claude Code's generated code causes build failures:

1. **Read the full error output.** Build tools often show the root cause at the beginning of the output, not the end. Scroll up to find the first error.
2. **Check the import graph.** Circular dependencies cause subtle build failures. Run your bundler's analyze mode to visualize the dependency graph.
3. **Verify TypeScript configuration.** If `tsconfig.json` has strict settings, Claude Code's generated code must comply. Common issues: missing null checks, implicit any types, and unused imports.
