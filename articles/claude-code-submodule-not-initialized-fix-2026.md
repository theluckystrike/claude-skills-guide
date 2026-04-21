---
title: "Git Submodule Not Initialized Error Fix"
permalink: /claude-code-submodule-not-initialized-fix-2026/
description: "Fix git submodule not initialized error in Claude Code. Run git submodule update --init --recursive to clone missing submodule directories."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
fatal: No url found for submodule path 'lib/shared-utils' in .gitmodules
Error: Claude Code cannot read files in 'lib/shared-utils/' — directory is empty
Submodule 'lib/shared-utils' is registered but not initialized
```

This appears when Claude Code tries to read or edit files inside a git submodule directory that has not been cloned yet, finding an empty directory instead of source files.

## The Fix

```bash
git submodule update --init --recursive
```

1. Initialize and clone all registered submodules.
2. Verify the submodule directory now contains files: `ls lib/shared-utils/`.
3. Resume your Claude Code session — it can now read and edit submodule files.

## Why This Happens

Git submodules are separate repositories embedded within a parent repo. After a fresh `git clone`, submodule directories exist but are empty until explicitly initialized. Claude Code does not automatically run `git submodule update` and treats the empty directory as though the files do not exist. This commonly occurs in CI/CD environments, fresh clones, or when a teammate adds a new submodule.

## If That Doesn't Work

If the submodule URL has changed or is inaccessible:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

If the submodule is pinned to a detached commit that no longer exists:

```bash
cd lib/shared-utils
git fetch origin
git checkout main
cd ../..
```

Remove and re-add a corrupted submodule:

```bash
git submodule deinit lib/shared-utils
git rm lib/shared-utils
rm -rf .git/modules/lib/shared-utils
git submodule add <url> lib/shared-utils
```

## Prevention

```markdown
# CLAUDE.md rule
After cloning this repo, always run 'git submodule update --init --recursive'. Submodule directories: lib/shared-utils, vendor/third-party. These must be initialized before editing.
```
