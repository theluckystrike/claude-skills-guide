---
layout: default
title: "Modernizing Legacy Codebases (2026)"
description: "Use Claude Code to modernize legacy code. Refactor jQuery to React, upgrade Node.js versions, add TypeScript, replace callbacks with async/await."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-for-legacy-code-modernization/
reviewed: true
categories: [guides, claude-code]
tags: [legacy, modernization, refactoring, migration, typescript]
geo_optimized: true
---

# Modernizing Legacy Codebases with Claude Code

## The Problem

Your codebase is years old. It uses jQuery, CommonJS modules, callback-based async patterns, and has no TypeScript. Dependency versions are outdated with known vulnerabilities. No tests exist, so every change feels risky. You need to modernize incrementally without stopping feature development and without breaking production.

## Quick Start

Ask Claude Code to assess the current state:

```
Analyze this legacy codebase and create a modernization report:
1. Node.js/runtime version and compatibility issues
2. Outdated dependencies with known vulnerabilities
3. Code patterns that need updating (callbacks, var, CommonJS)
4. Missing type safety (no TypeScript)
5. Test coverage (or lack thereof)
6. Estimated effort for each modernization area
Prioritize by risk reduction and developer experience improvement.
```

## What's Happening

Legacy code modernization is one of Claude Code's strongest use cases because it requires understanding existing code deeply, planning a safe migration path, and making systematic changes across many files. Claude Code can:

1. Read and understand old patterns (jQuery, Backbone, AngularJS, CommonJS)
2. Plan incremental migration paths that keep the app running at every step
3. Make systematic find-and-replace transformations across hundreds of files
4. Add TypeScript types to existing JavaScript code
5. Generate tests for untested code before refactoring it
6. Verify each change by running the application

## Step-by-Step Guide

### Step 1: Audit the codebase

Ask Claude Code to produce a detailed audit:

```
Read the project structure, package.json, and sample files from each
directory. Create a modernization audit covering:
- Language: JS vs TS, module system, ES version
- Framework: jQuery/Backbone/Angular/React version
- Build tools: Grunt/Gulp/Webpack/Vite
- Package manager: npm/yarn/pnpm, lockfile present?
- Node.js version requirements
- Test framework and coverage
- Linting and formatting tools
- Known vulnerability count (npm audit)
```

### Step 2: Add tests before refactoring

Never refactor without tests. Ask Claude Code to add tests to the most critical code paths first:

```
Add tests for the payment processing module (src/payments/).
This code has no tests. Write integration tests that verify:
- Successful payment creates a transaction record
- Failed payment returns the correct error
- Duplicate payment IDs are rejected
- Refund processing updates the transaction status
Use the existing patterns (if any) or set up Jest from scratch.
```

Claude Code reads the existing code, understands the logic, and generates tests that verify current behavior. This creates a safety net for refactoring.

### Step 3: Upgrade Node.js version

```
Assess compatibility with Node.js 20 LTS. Check for:
- Dependencies that don't support Node 20
- Native modules that need rebuilding
- Deprecated APIs (url.parse, crypto.createCipher)
- Changes needed in package.json engines field
Create a migration plan with specific file changes.
```

Common issues Claude Code catches:

```javascript
// Deprecated: url.parse
const parsed = url.parse(myUrl);

// Modern: URL constructor
const parsed = new URL(myUrl);

// Deprecated: crypto.createCipher
const cipher = crypto.createCipher('aes-256-cbc', key);

// Modern: crypto.createCipheriv
const iv = crypto.randomBytes(16);
const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
```

### Step 4: Convert CommonJS to ES Modules

```
Convert this project from CommonJS to ES Modules incrementally.
Start with utility files that have no dependencies, then work up
to the main entry points.
For each file:
1. Change require() to import
2. Change module.exports to export
3. Add .js extensions to relative imports (required for ESM)
4. Update package.json type field
5. Run tests after each file to verify nothing breaks
```

**Before:**

```javascript
const express = require('express');
const { UserService } = require('./services/user');
const config = require('../config');

module.exports = function createRouter() {
 const router = express.Router();
 // ...
 return router;
};
```

**After:**

```javascript
import express from 'express';
import { UserService } from './services/user.js';
import config from '../config.js';

export function createRouter() {
 const router = express.Router();
 // ...
 return router;
}
```

### Step 5: Add TypeScript incrementally

```
Add TypeScript to the project without converting all files at once.
1. Install TypeScript and configure tsconfig.json with allowJs: true
2. Convert src/types/ to TypeScript first (create type definitions)
3. Convert utility files (src/utils/) next
4. Convert service layer (src/services/) next
5. Leave route handlers for last (most complex)
Each converted file should use strict types, not 'any'.
```

TypeScript config for incremental adoption:

```json
{
 "compilerOptions": {
 "target": "ES2022",
 "module": "NodeNext",
 "moduleResolution": "NodeNext",
 "strict": true,
 "allowJs": true,
 "checkJs": false,
 "outDir": "dist",
 "rootDir": "src",
 "declaration": true,
 "esModuleInterop": true,
 "skipLibCheck": true
 },
 "include": ["src/**/*"]
}
```

### Step 6: Replace callbacks with async/await

```
Find all callback-based async patterns in the codebase and convert
them to async/await. Handle these patterns:
1. Callback pyramids (nested callbacks)
2. Event emitter patterns that should be promises
3. fs callbacks (use fs/promises)
4. Database query callbacks
Preserve error handling — every try/catch should match the original error paths.
```

**Before:**

```javascript
function getUser(id, callback) {
 db.query('SELECT * FROM users WHERE id = ?', [id], function(err, rows) {
 if (err) return callback(err);
 if (rows.length === 0) return callback(new Error('Not found'));

 db.query('SELECT * FROM orders WHERE user_id = ?', [id], function(err, orders) {
 if (err) return callback(err);
 rows[0].orders = orders;
 callback(null, rows[0]);
 });
 });
}
```

**After:**

```typescript
async function getUser(id: string): Promise<UserWithOrders> {
 const rows = await db.query('SELECT * FROM users WHERE id = ?', [id]);
 if (rows.length === 0) {
 throw new Error('Not found');
 }

 const orders = await db.query('SELECT * FROM orders WHERE user_id = ?', [id]);
 return { ...rows[0], orders };
}
```

### Step 7: Replace jQuery with modern JavaScript

For frontend legacy code:

```
Convert jQuery DOM manipulation to vanilla JavaScript or React.
Start with the simplest components and work toward complex ones.
For each jQuery usage:
- $.ajax → fetch API
- $(selector).on('click') → addEventListener
- $.each → Array.forEach/map
- $(selector).html() → element.innerHTML or React state
- $(selector).show/hide() → CSS classes or conditional rendering
```

### Step 8: Update build tools

```
Migrate from Webpack 4 to Vite:
1. Identify all Webpack-specific features in use (loaders, plugins)
2. Map each to the Vite equivalent
3. Create a vite.config.ts that replaces webpack.config.js
4. Update all import paths for Vite compatibility
5. Update package.json scripts
6. Test the dev server and production build
```

## Modernization Order

The safest order for modernization:

1. **Add tests** (safety net for everything else)
2. **Upgrade Node.js** (enables modern syntax)
3. **Add TypeScript** (catches bugs during refactoring)
4. **Convert to ES Modules** (modern import system)
5. **Replace callbacks** (cleaner async code)
6. **Update framework** (jQuery to React, etc.)
7. **Update build tools** (Webpack to Vite, etc.)
8. **Update dependencies** (now that the code is modern)

Each step should be a separate PR with passing tests.

## Prevention

Add modernization standards to your CLAUDE.md:

```markdown
## Code Standards
- TypeScript strict mode (no any, no ts-ignore)
- ES Modules (import/export, not require/module.exports)
- Async/await (no callbacks for async operations)
- Modern APIs (fetch, URL, fs/promises)
- Every new file must have tests
- Every refactored file must have tests added before refactoring
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-legacy-code-modernization)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude Code Migration Guide Express to Fastify](/claude-code-migration-guide-express-to-fastify/)
- [Claude Code Test Driven Refactoring Guide](/claude-code-test-driven-refactoring-guide/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)

## See Also

- [Help Claude Code Work With Legacy Code (2026)](/claude-code-cant-handle-legacy-code-fix-2026/)
