---
title: "Claude Code Search Index Corrupted Error — Fix (2026)"
permalink: /claude-code-search-index-corrupted-fix-2026/
description: "Delete .claude/cache/search-index files to fix corrupted index error. The index rebuilds automatically on the next Grep or Glob search operation."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Search index corrupted or incompatible. Rebuilding...
```

## The Fix

```bash
# Remove the cached search index to force a clean rebuild
rm -rf .claude/cache/search-index*

# If no .claude/cache directory exists, check the global location:
rm -rf ~/.claude/cache/search-index*

# The index rebuilds automatically on the next search operation
```

## Why This Works

Claude Code maintains a local search index for fast file lookups. This index can become corrupted after abrupt process termination, disk full conditions, or version upgrades that change the index format. Deleting the index files forces a full rebuild from the current filesystem state, eliminating any inconsistencies.

## If That Doesn't Work

```bash
# Remove the entire Claude cache directory
rm -rf .claude/cache/

# If the issue persists, check for disk space problems
df -h .

# Ensure the filesystem isn't read-only or full:
touch .claude/cache/test-write && rm .claude/cache/test-write

# As a last resort, remove all Claude local state:
rm -rf .claude/
```

If disk space is below 100MB, the index cannot be rebuilt. Free space first.

## Prevention

Add to your CLAUDE.md:
```
If search operations produce stale or incorrect results, delete .claude/cache/search-index* before continuing. Maintain at least 500MB free disk space in the workspace partition for index operations.
```
