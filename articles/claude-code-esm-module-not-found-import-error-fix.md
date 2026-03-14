---
layout: default
title: "Claude Code ESM Module Not Found Import Error Fix"
description: "Learn how to resolve ESM module not found and import errors in Claude Code. Practical solutions for CommonJS vs ESM conflicts, package.json."
date: 2026-03-14
categories: [troubleshooting, guides]
tags: [claude-code, esm, module, import-error, javascript, troubleshooting]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-esm-module-not-found-import-error-fix/
---

# Claude Code ESM Module Not Found Import Error Fix

If you're working with Claude Code and encounter the dreaded "Module not found" or "Cannot find module" error, you're not alone. This is one of the most common issues developers face when building skills that interact with JavaScript or TypeScript projects. In this guide, we'll explore the root causes of these errors and provide practical solutions to fix them.

## Understanding ESM and CommonJS in Claude Code

Before diving into fixes, it's essential to understand the difference between ES Modules (ESM) and CommonJS (CJS), as this distinction lies at the heart of most import errors.

ES Modules (`import`/`export` syntax) are the standard JavaScript module system introduced in ES6. CommonJS (`require()`/`module.exports`) was the older system that Node.js originally used. Modern Node.js projects often mix both, which creates conflicts.

When Claude Code interacts with your project, it needs to correctly resolve modules based on your project's configuration. Understanding this helps you diagnose and fix import errors quickly.

## Common Causes of Module Not Found Errors

### 1. Missing Dependencies

The most straightforward cause is a missing package. When Claude Code tries to import a module that isn't installed, you'll see an error similar to:

```bash
Error: Cannot find module 'lodash'
```

**Fix**: Install the missing dependency:

```bash
npm install lodash
# or with yarn
yarn add lodash
# or with pnpm
pnpm add lodash
```

### 2. Incorrect Package.json Type Configuration

Your `package.json` defines module behavior through the `"type"` field. If this is misconfigured, Node.js may look for the wrong type of exports:

```json
{
  "name": "my-claude-skill",
  "type": "module",
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
```

Without `"type": "module"`, Node.js defaults to CommonJS, which can cause ESM-specific imports to fail.

**Fix**: Ensure your `package.json` type matches your import syntax. For ESM:

```json
{
  "type": "module"
}
```

For CommonJS:

```json
{
  "type": "commonjs"
}
```

### 3. Wrong File Extension

Node.js requires explicit extensions in imports when using ESM. If you have:

```javascript
import { helperFunction } from './utils';
```

But your file is actually `utils.js` or `utils.ts`, you'll get a module not found error.

**Fix**: Always include the file extension in ESM imports:

```javascript
import { helperFunction } from './utils.js';
```

### 4. Missing index.js or package.json Exports

When importing from a directory, Node.js looks for either an `index.js` file or a `package.json` with an `"exports"` field:

```javascript
import { something } from './lib/utils';
```

**Fix**: Either create an `index.js` in the directory:

```javascript
// lib/utils/index.js
export { something } from './something';
```

Or define exports in `package.json`:

```json
{
  "exports": {
    ".": "./index.js",
    "./utils": "./lib/utils/index.js"
  }
}
```

### 5. Alias Resolution Issues

Many projects use path aliases (like `@/` or `#/`) to shorten imports:

```javascript
import { helper } from '@/utils/helper';
```

Claude Code needs these aliases resolved correctly.

**Fix**: Ensure your `jsconfig.json` or `tsconfig.json` properly defines paths:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

## Troubleshooting Claude Code Specifically

When working with Claude Code skills, consider these additional factors:

### Skill Execution Context

Claude Code skills execute within a specific Node.js context. If your skill runs a script, that script inherits your project's module resolution settings. Ensure your skill's working directory has a proper `package.json` with correct dependencies.

### Dependency Installation

Before running any code that imports modules, verify dependencies are installed:

```bash
npm install
```

### Checking Node Version

ESM support requires Node.js version 14 or higher. Older versions won't recognize ESM syntax:

```bash
node --version
```

If you're on an older version, upgrade:

```bash
nvm install latest
nvm use latest
```

## Practical Examples

### Example 1: Fixing a Simple Import

**Error**:
```
Error: Cannot find module 'axios'
```

**Solution**:
```bash
npm install axios
```

### Example 2: Converting CommonJS to ESM

**Error**:
```
Error [ERR_REQUIRE_ESM]: Must use import to load ES Module
```

**Solution**: Convert your code to use ESM syntax:

```javascript
// Before (CommonJS)
const axios = require('axios');
module.exports = { getData };

// After (ESM)
import axios from 'axios';
export function getData() {
  return axios.get('/api/data');
}
```

And ensure `package.json` has `"type": "module"`.

### Example 3: Handling Dual Packages

Some packages provide both CommonJS and ESM versions. This causes conflicts:

```
Error: Multiple exports found for [package-name]
```

**Solution**: Use the package's ESM entry point explicitly or configure your bundler:

```javascript
// Explicitly use ESM version
import pkg from 'package-name';
// or configure in package.json
{
  "imports": {
    "#pkg": "package-name/esm/index.js"
  }
}
```

## Best Practices to Avoid Import Errors

1. **Use consistent module syntax**: Choose either ESM or CommonJS for your project and stick with it.

2. **Keep dependencies updated**: Outdated packages may have resolution issues.

3. **Document your module structure**: Clear exports and imports make debugging easier.

4. **Test imports in isolation**: Verify each import works before combining them.

5. **Use TypeScript**: TypeScript's module resolution is often more robust and catches issues early.

## Conclusion

ESM module not found errors in Claude Code typically stem from misconfigured package.json settings, missing dependencies, or incorrect import syntax. By understanding how Node.js resolves modules and following the fixes outlined in this guide, you can quickly diagnose and resolve these issues.

Remember to check your dependencies first, verify your `package.json` configuration, ensure correct file extensions, and test your imports incrementally. With these practices, you'll spend less time debugging import errors and more time building with Claude Code.

If you continue to experience issues, consider using tools like `npm ls` to inspect your dependency tree or `node --trace-warnings` for detailed resolution debugging.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-skills-guide/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)

