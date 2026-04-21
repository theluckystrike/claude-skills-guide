---
title: "Claude Code Glob Pattern Too Broad Error — Fix (2026)"
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
