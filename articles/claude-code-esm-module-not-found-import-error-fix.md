---
layout: default
title: "Fix Claude Code Esm Module Not Found"
description: "Learn how to resolve ESM module not found and import errors in Claude Code. Practical solutions for CommonJS vs ESM conflicts, package.json."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting, guides]
tags: [claude-code, esm, module, import-error, javascript, troubleshooting, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-esm-module-not-found-import-error-fix/
geo_optimized: true
---
If you're working with Claude Code and encounter the dreaded "Module not found" or "Cannot find module" error, you're not alone. This is one of the most common issues developers face when building skills that interact with JavaScript or TypeScript projects. this guide covers the root causes of these errors and provide practical solutions to fix them.

## Understanding ESM and CommonJS in Claude Code

Before diving into fixes, it's essential to understand the difference between ES Modules (ESM) and CommonJS (CJS), as this distinction lies at the heart of most import errors.

ES Modules (`import`/`export` syntax) are the standard JavaScript module system introduced in ES6. CommonJS (`require()`/`module.exports`) was the older system that Node.js originally used. Modern Node.js projects often mix both, which creates conflicts.

When Claude Code interacts with your project, it needs to correctly resolve modules based on your project's configuration. Understanding this helps you diagnose and fix import errors quickly.

## ESM vs CommonJS at a Glance

| Feature | CommonJS (CJS) | ES Modules (ESM) |
|---|---|---|
| Syntax | `require()` / `module.exports` | `import` / `export` |
| Loading | Synchronous | Asynchronous |
| File extension | `.js` (default) | `.mjs` or `.js` with `"type":"module"` |
| Node.js version | All versions | 12+ (stable in 14+) |
| Browser native | No | Yes |
| Dynamic imports | `require()` anywhere | `import()` (returns Promise) |
| `__dirname` available | Yes | No (use `import.meta.url`) |
| Tree-shakeable | No | Yes (bundlers can eliminate dead code) |

This table matters because the error messages you see differ based on which direction the conflict runs. `ERR_REQUIRE_ESM` means CJS code tried to `require()` an ESM-only package. `ERR_UNKNOWN_FILE_EXTENSION` means Node.js couldn't determine the module type from the file extension. Each has a different fix.

## Diagnosing the Error Before Fixing It

Before applying any fix, identify which error you actually have. Copy the exact error text and match it against this reference:

| Error Message | Root Cause | Jump To |
|---|---|---|
| `Cannot find module 'X'` | Package not installed | Missing Dependencies |
| `Error [ERR_MODULE_NOT_FOUND]` | Import path not resolving | File Extension or Exports |
| `Error [ERR_REQUIRE_ESM]` | CJS tried to require an ESM package | Converting CJS to ESM |
| `Error [ERR_UNKNOWN_FILE_EXTENSION]` | Node.js confused by extension | Package.json Type |
| `SyntaxError: Cannot use import outside a module` | ESM syntax in a CJS context | Package.json Type |
| `Named export 'X' not found` | Wrong export resolution | Dual Packages |
| `Cannot resolve '@/something'` | Path alias not configured | Alias Resolution |

Reading the error message carefully saves significant debugging time. The most common mistake is treating all module errors as "just install the package" when the actual problem is a module type mismatch.

## Common Causes of Module Not Found Errors

1. Missing Dependencies

The most straightforward cause is a missing package. When Claude Code tries to import a module that isn't installed, you'll see an error similar to:

```bash
Error: Cannot find module 'lodash'
```

Fix: Install the missing dependency:

```bash
npm install lodash
or with yarn
yarn add lodash
or with pnpm
pnpm add lodash
```

After installing, verify the package is in `node_modules`:

```bash
ls node_modules/lodash
```

If the directory does not exist after install, check for npm errors in the output. A corrupted `node_modules` directory can cause this. delete it and reinstall:

```bash
rm -rf node_modules
npm install
```

2. Incorrect Package.json Type Configuration

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

Fix: Ensure your `package.json` type matches your import syntax. For ESM:

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

You can also control module type on a per-file basis regardless of the `package.json` setting:

- `.mjs` extension forces ESM treatment
- `.cjs` extension forces CommonJS treatment

This is useful when you have a mostly-CJS project but need one file to use ESM syntax, or vice versa.

3. Wrong File Extension

Node.js requires explicit extensions in imports when using ESM. If you have:

```javascript
import { helperFunction } from './utils';
```

But your file is actually `utils.js` or `utils.ts`, you'll get a module not found error.

Fix: Always include the file extension in ESM imports:

```javascript
import { helperFunction } from './utils.js';
```

This trips up developers migrating from TypeScript, where the compiler traditionally handled extension resolution automatically. In native ESM Node.js, you must be explicit. Even when importing a `.ts` file in a TypeScript project that uses `tsx` or `ts-node`, the convention is to write `.js` in the import path. the TypeScript resolver maps it to the `.ts` source file at build time.

```typescript
// TypeScript with ESM. write .js even though the source file is .ts
import { helperFunction } from './utils.js';
```

4. Missing index.js or package.json Exports

When importing from a directory, Node.js looks for either an `index.js` file or a `package.json` with an `"exports"` field:

```javascript
import { something } from './lib/utils';
```

Fix: Either create an `index.js` in the directory:

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

The `"exports"` field is important to understand because it also acts as an access control mechanism. If a package defines `"exports"`, Node.js will refuse to load any path that is not listed there. even if the file physically exists on disk. This is a common source of confusion when using internal APIs of third-party packages:

```
Error [ERR_PACKAGE_PATH_NOT_EXPORTED]: Package subpath './internal/parser'
is not defined by "exports" in node_modules/some-package/package.json
```

The solution is to use only the public API exposed in `"exports"`, or to check if the package offers an alternative entry point.

5. Alias Resolution Issues

Many projects use path aliases (like `@/` or `#/`) to shorten imports:

```javascript
import { helper } from '@/utils/helper';
```

Claude Code needs these aliases resolved correctly.

Fix: Ensure your `jsconfig.json` or `tsconfig.json` properly defines paths:

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

However, TypeScript path aliases in `tsconfig.json` only affect the TypeScript compiler. they do not affect Node.js module resolution at runtime. If you are running code directly with Node.js (or through `ts-node`), you need an additional runtime mapping.

For `ts-node`:

```json
// tsconfig.json
{
 "compilerOptions": {
 "baseUrl": ".",
 "paths": { "@/*": ["src/*"] }
 },
 "ts-node": {
 "require": ["tsconfig-paths/register"]
 }
}
```

For Jest:

```json
// jest.config.js
module.exports = {
 moduleNameMapper: {
 '^@/(.*)$': '<rootDir>/src/$1'
 }
};
```

For Vite (which handles this automatically through `vite.config.ts`):

```typescript
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
 resolve: {
 alias: {
 '@': path.resolve(__dirname, './src')
 }
 }
});
```

Each tool in your chain. TypeScript compiler, test runner, bundler, Node.js runtime. must independently know about your aliases. Fixing one without fixing the others produces errors that appear only in certain contexts.

## Troubleshooting Claude Code Specifically

When working with Claude Code skills, consider these additional factors:

## Skill Execution Context

Claude Code skills execute within a specific Node.js context. If your skill runs a script, that script inherits your project's module resolution settings. Ensure your skill's working directory has a proper `package.json` with correct dependencies.

If your skill spawns a subprocess (for example, running a Node.js script via `exec` or `spawn`), the subprocess has its own module resolution context based on its `cwd`. Make sure the subprocess runs from a directory that has the required `package.json` and `node_modules`.

## Dependency Installation

Before running any code that imports modules, verify dependencies are installed:

```bash
npm install
```

In monorepo setups, also check that workspace dependencies are installed at the right level. A package in `packages/skill-runner` may need its own `npm install` even if the root has been installed.

## Checking Node Version

ESM support requires Node.js version 14 or higher. Older versions won't recognize ESM syntax:

```bash
node --version
```

If you're on an older version, upgrade:

```bash
nvm install latest
nvm use latest
```

More specifically, here is the ESM support history by Node.js version:

| Node.js Version | ESM Status |
|---|---|
| 10.x | Experimental (behind flag) |
| 12.x | Experimental (`--experimental-modules`) |
| 14.x | Stable (unflagged) |
| 16.x | Full support, `"exports"` enforced |
| 18.x | LTS, full support |
| 20.x | LTS, full support, `--input-type` flag |
| 22.x | Current, `require(esm)` experimental |

If you are on Node.js 20 or higher, note that Node.js 22 introduced an experimental flag (`--experimental-require-module`) that allows `require()` to load ESM modules, which may change how some errors behave. Do not rely on this in production until it is stable.

## Practical Examples

## Example 1: Fixing a Simple Import

Error:
```
Error: Cannot find module 'axios'
```

Solution:
```bash
npm install axios
```

Then verify the import syntax matches the package type. `axios` supports both CJS and ESM:

```javascript
// ESM
import axios from 'axios';

// CJS
const axios = require('axios');
```

## Example 2: Converting CommonJS to ESM

Error:
```
Error [ERR_REQUIRE_ESM]: Must use import to load ES Module
```

This error appears when a CJS `require()` call tries to load a package that only ships ESM. Many modern packages (like `node-fetch` v3, `chalk` v5, `ora` v6) dropped CJS support.

Solution: Convert your code to use ESM syntax:

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

If you cannot convert to ESM (for example, because other parts of your codebase depend on CJS), use dynamic `import()` instead:

```javascript
// CJS file dynamically loading an ESM-only package
async function getChalk() {
 const { default: chalk } = await import('chalk');
 return chalk;
}

async function run() {
 const chalk = await getChalk();
 console.log(chalk.green('Success'));
}
```

This approach lets CJS and ESM-only packages coexist, at the cost of making the import asynchronous.

Alternatively, pin the package to an older CJS-compatible version while you plan the migration:

```bash
Use chalk v4 (last CJS version) instead of v5+ (ESM-only)
npm install chalk@4
```

## Example 3: Handling Dual Packages

Some packages provide both CommonJS and ESM versions. This causes conflicts:

```
Error: Multiple exports found for [package-name]
```

Solution: Use the package's ESM entry point explicitly or configure your bundler:

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

Dual packages that provide both CJS and ESM versions use a `package.json` `"exports"` field with condition keys. Understanding this helps you debug which version is being loaded:

```json
{
 "exports": {
 ".": {
 "import": "./esm/index.js",
 "require": "./cjs/index.js",
 "default": "./cjs/index.js"
 }
 }
}
```

When Node.js loads this package with `import`, it uses `./esm/index.js`. When loaded with `require()`, it uses `./cjs/index.js`. Bundlers like webpack and Rollup add their own condition keys (like `"browser"` or `"module"`) which can override the default resolution.

If you are seeing unexpected behavior from a dual package, add `--trace-warnings` to your Node.js invocation to see which file is actually being loaded:

```bash
node --trace-warnings your-script.js
```

Example 4: The `__dirname` Problem in ESM

A frequent stumbling block when converting CJS files to ESM is that `__dirname` and `__filename` are not available:

```javascript
// CJS. works fine
const path = require('path');
const configPath = path.join(__dirname, 'config.json');

// ESM. __dirname is not defined!
import path from 'path';
const configPath = path.join(__dirname, 'config.json'); // ReferenceError
```

Fix: Use `import.meta.url` to reconstruct `__dirname`:

```javascript
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const configPath = path.join(__dirname, 'config.json'); // works
```

Or use `import.meta.resolve` in newer Node.js versions:

```javascript
const configPath = new URL('./config.json', import.meta.url).pathname;
```

## Debugging Module Resolution Step by Step

When none of the standard fixes work, use these diagnostic commands to understand exactly what Node.js is doing.

Check what package.json "type" field Node.js sees for a given file:

```bash
node -e "const m = require('module'); console.log(m._resolveFilename('./src/index.js', null, false))"
```

Trace the full module resolution process:

```bash
node --trace-warnings --experimental-vm-modules your-script.js 2>&1 | head -50
```

Inspect a package's exports map:

```bash
node -e "const p = require('./node_modules/some-package/package.json'); console.log(JSON.stringify(p.exports, null, 2))"
```

Check if a module resolves correctly before running your full script:

```bash
node -e "import('some-package').then(m => console.log(Object.keys(m)))"
```

List all versions of a package in your dependency tree (useful for version conflicts):

```bash
npm ls some-package
```

## Best Practices to Avoid Import Errors

1. Use consistent module syntax: Choose either ESM or CommonJS for your project and stick with it. Mixed projects are harder to maintain and debug.

2. Keep dependencies updated: Outdated packages may have resolution issues. Run `npm outdated` periodically to see which packages have newer versions available.

3. Document your module structure: Clear exports and imports make debugging easier. A barrel file (an `index.js` that re-exports from subdirectories) makes the public API explicit.

4. Test imports in isolation: Verify each import works before combining them. A quick `node -e "import('./module.js').then(console.log)"` catches problems early.

5. Use TypeScript: TypeScript's module resolution is often more solid and catches issues early. Errors appear at compile time rather than at runtime.

6. Lock your Node.js version: Use an `.nvmrc` file at the project root so every developer and CI system uses the same Node.js version.

```bash
.nvmrc
20.11.0
```

7. Separate tools by concern: Keep your TypeScript config, Jest config, bundler config, and Node.js runtime config aligned. A mismatch in any one tool produces errors that look like code problems but are actually configuration problems.

8. Use `"exports"` in your own packages: If you are publishing or sharing internal packages, define `"exports"` explicitly rather than relying on implicit file-system access. This prevents accidental use of internal files.

## Conclusion

ESM module not found errors in Claude Code typically stem from misconfigured package.json settings, missing dependencies, or incorrect import syntax. By understanding how Node.js resolves modules and following the fixes outlined in this guide, you can quickly diagnose and resolve these issues.

Remember to check your dependencies first, verify your `package.json` configuration, ensure correct file extensions, and test your imports incrementally. The diagnostic table at the top of this guide maps error messages to their root causes. start there to avoid applying the wrong fix to the right symptom.

With these practices, you'll spend less time debugging import errors and more time building with Claude Code. Module system problems are entirely avoidable with a consistent project setup and the right understanding of how CJS and ESM interact.

If you continue to experience issues, consider using tools like `npm ls` to inspect your dependency tree or `node --trace-warnings` for detailed resolution debugging.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-esm-module-not-found-import-error-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading


- [Troubleshooting Guide](/troubleshooting/). Diagnose and fix any Claude Code issue
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [ESM vs CJS Module Resolution Failure — Fix (2026)](/claude-code-esm-vs-cjs-module-resolution-fix-2026/)
- [Claude Code Notebook Kernel Not Found — Fix (2026)](/claude-code-notebook-kernel-not-found-fix-2026/)
