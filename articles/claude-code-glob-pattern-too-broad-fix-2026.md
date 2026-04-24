---
title: "Claude Code Glob Pattern Too Broad"
permalink: /claude-code-glob-pattern-too-broad-fix-2026/
description: "Narrow glob pattern scope to fix the 10000-file match limit error. Add a specific directory prefix or targeted extension filter to stay under the cap."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Glob pattern matched too many files (>10000). Narrow your pattern.
```

## The Fix

```bash
# Instead of searching the entire repo:
# BAD:  **/*.ts
# GOOD: src/**/*.ts

# Instead of matching all files:
# BAD:  **/*
# GOOD: src/components/**/*.tsx

# Scope to the specific directory you care about
ls src/  # verify structure first, then target precisely
```

## Why This Works

Claude Code caps glob results at 10,000 files to prevent memory exhaustion and response overflow. Large monorepos with `node_modules`, `dist`, or `data` directories easily exceed this. Prefixing the pattern with a specific subdirectory eliminates irrelevant matches and stays within the limit.

## If That Doesn't Work

```bash
# Use multiple targeted globs instead of one broad one
# Search specific directories separately:
# First:  src/api/**/*.ts
# Then:   src/components/**/*.tsx
# Then:   src/utils/**/*.ts

# Or use Grep with a file type filter instead:
# pattern: "functionName"  type: "ts"  path: "src/"
```

Grep with type filters is more efficient than glob when you know what content you are looking for.

## Prevention

Add to your CLAUDE.md:
```
Never use bare **/* or **/*.ext globs from the repo root. Always scope glob patterns to specific directories (src/, lib/, app/). For content searches, prefer Grep with type filters over globbing.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`
- `MODULE_NOT_FOUND: Cannot find module 'node:fs'`
- `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`
- `JavaScript heap out of memory`

## Frequently Asked Questions

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.

### How do I manage multiple Node.js versions?

Use nvm (Node Version Manager): `nvm install 20 && nvm use 20`. This lets you switch between Node.js versions per-project without affecting other applications. Add a `.nvmrc` file with `20` to your project root so nvm automatically selects the right version.

### Why does Claude Code fail with the node:fs prefix?

The `node:` prefix for built-in modules was introduced in Node.js 16. If you see errors about `node:fs` or `node:path`, you are running an older Node.js version that does not support this syntax. Upgrade to Node.js 18 or later.

### How much memory does Claude Code use?

Claude Code typically uses 200-500MB of RAM. Large file operations, parallel tool calls, and long conversation histories can push usage above 1GB. Monitor with `ps aux | grep claude` to see current memory usage.
