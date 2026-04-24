---
title: "Webpack Tree-Shaking Breaks Build — Fix"
permalink: /claude-code-webpack-tree-shaking-breaks-fix-2026/
description: "Fix webpack tree-shaking removing needed code. Add sideEffects field to package.json and mark imports correctly."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
TypeError: Cannot read properties of undefined (reading 'create')
  at UserService.init (webpack:///./src/services/user.ts:15:22)
// Module was removed by tree-shaking — the import exists but resolves to undefined
```

This error occurs in production builds when webpack's tree-shaking removes a module that your code actually uses. The import appears to succeed but the exported value is `undefined`.

## The Fix

1. Mark the module as having side effects in package.json:

```json
{
  "sideEffects": [
    "*.css",
    "./src/polyfills.ts",
    "./src/services/init.ts"
  ]
}
```

2. Or mark the entire package as not tree-shakeable:

```json
{
  "sideEffects": true
}
```

3. Alternatively, use explicit named imports instead of namespace imports:

```typescript
// Before (tree-shaking may remove):
import * as utils from './utils';

// After (explicit, tree-shaking preserves):
import { createUser, deleteUser } from './utils';
```

4. Rebuild and test:

```bash
npx webpack --mode production
node dist/main.js
```

## Why This Happens

Webpack's tree-shaking analyzes static imports to determine which exports are used and removes unused ones. When Claude generates code using dynamic patterns, re-exports, or barrel files, webpack may incorrectly determine that an import is unused. Barrel files (`index.ts` that re-export everything) are especially problematic because webpack must trace through the entire re-export chain.

## If That Doesn't Work

- Add a webpack comment to preserve the import:

```typescript
import(/* webpackExports: ["create"] */ './services/user');
```

- Disable tree-shaking for a specific module in webpack config:

```javascript
module.exports = {
  optimization: {
    usedExports: true,
    sideEffects: true
  }
};
```

- Replace barrel files with direct imports from source files.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Webpack Build
- Use named imports, never import * from barrel files.
- Mark files with side effects in package.json sideEffects array.
- Test production builds after every code change: npx webpack --mode production.
```

## See Also

- [Stop Claude Code Breaking Working Features (2026)](/claude-code-breaks-working-features-fix-2026/)
