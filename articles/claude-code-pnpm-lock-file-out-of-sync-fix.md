---
title: "Claude Code pnpm Lock File Out of Sync"
description: "Fix Claude Code pnpm lock file out of sync error. Regenerate pnpm-lock.yaml and resolve version conflicts. Step-by-step solution."
permalink: /claude-code-pnpm-lock-file-out-of-sync-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
 ERR_PNPM_OUTDATED_LOCKFILE  Cannot install with "frozen-lockfile" because
  pnpm-lock.yaml is not up to date with package.json.

Note that in CI environments this setting is turned on by default.

# Or:
 ERR_PNPM_LOCKFILE_BREAKING_CHANGE  Lockfile /path/pnpm-lock.yaml not
  compatible with current pnpm version. Please delete it and run pnpm install.

# Or:
Lockfile is up to date, but some packages are missing.
  Run pnpm install to install them.
```

## The Fix

1. **Regenerate the lock file from package.json**

```bash
# Remove existing lock and node_modules
rm pnpm-lock.yaml
rm -rf node_modules

# Reinstall everything
pnpm install

# Verify lock file was created
ls -la pnpm-lock.yaml
```

2. **If the issue is a pnpm version mismatch**

```bash
# Check pnpm version
pnpm --version

# Check required version in package.json
cat package.json | python3 -c "import sys,json; print(json.load(sys.stdin).get('packageManager','not set'))"

# Install the required version with corepack
corepack enable
corepack prepare pnpm@9.15.0 --activate
pnpm install
```

3. **Verify the fix:**

```bash
pnpm install --frozen-lockfile
# Expected: No errors — lockfile matches package.json exactly
```

## Why This Happens

The pnpm-lock.yaml file is a snapshot of the exact dependency tree. When Claude Code modifies package.json (adding, removing, or updating dependencies) without running `pnpm install` afterward, the lock file becomes stale. Running `pnpm install --frozen-lockfile` (the CI default) then fails because it refuses to modify the lock file. Additionally, pnpm lock file format versions change between major pnpm releases — a lock file created with pnpm 8 may be incompatible with pnpm 9.

## If That Doesn't Work

- **Alternative 1:** Use `pnpm install --no-frozen-lockfile` to update the lock file in place without deleting it
- **Alternative 2:** If merge conflicts corrupted the lock file: `git checkout main -- pnpm-lock.yaml && pnpm install`
- **Check:** Run `pnpm why <package-name>` to trace dependency resolution and find version conflicts

## Prevention

Add to your `CLAUDE.md`:
```markdown
After modifying any package.json, always run `pnpm install` to update pnpm-lock.yaml. Commit the updated lock file with the package.json change. Pin pnpm version in package.json "packageManager" field. Never manually edit pnpm-lock.yaml.
```

**Related articles:** [Monorepo Setup Guide](/claude-code-monorepo-setup-guide/), [NPM Install Fails Fix](/claude-code-error-npm-install-fails-in-skill-workflow/), [Troubleshooting Hub](/troubleshooting-hub/)
