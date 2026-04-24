---
title: "Claude Code Turborepo Cache Miss — Fix"
description: "Fix Turborepo cache miss on Claude-generated files. Configure turbo.json inputs and hash strategy correctly. Step-by-step solution."
permalink: /claude-code-turborepo-cache-miss-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
 Tasks:    12 successful, 12 total
 Cached:    0 cached, 12 total
   Time:    4m 32s
# Expected most tasks to be cached but got 0 cache hits

# Or in verbose mode:
[turbo] cache miss, executing task {build}
  Hash: abc123def456
  Inputs changed:
    - .claude/settings.json (added)
    - CLAUDE.md (modified)
```

## The Fix

1. **Exclude Claude Code files from turbo hash inputs**

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["tsconfig.json"],
  "globalPassThroughEnv": ["ANTHROPIC_API_KEY"],
  "tasks": {
    "build": {
      "inputs": [
        "src/**",
        "package.json",
        "tsconfig.json",
        "!.claude/**",
        "!CLAUDE.md",
        "!**/*.test.ts"
      ],
      "outputs": ["dist/**"]
    }
  }
}
```

2. **Verify what is busting the cache**

```bash
# Run with hash debugging to see exact inputs
npx turbo build --dry=json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for task in data.get('tasks', []):
    print(f\"{task['taskId']}: {task['cache']['status']}\")
    if task['cache']['status'] != 'HIT':
        print(f\"  Hash inputs: {task.get('inputs', {}).get('files', [])[:5]}...\")
"
```

3. **Verify the fix:**

```bash
# Run build twice — second should be cached
npx turbo build && npx turbo build 2>&1 | grep "Cached"
# Expected: Cached: 12 cached, 12 total (on second run)
```

## Why This Happens

Turborepo generates a content hash of all input files to determine cache validity. By default, it hashes every file in the package directory. When Claude Code creates or modifies files like `CLAUDE.md`, `.claude/settings.json`, or generates temporary files, these changes alter the hash even though they don't affect build output. Each Claude Code session that touches these files invalidates the entire cache, causing full rebuilds that waste CI minutes.

## If That Doesn't Work

- **Alternative 1:** Add `.claude/` to `.gitignore` so Turborepo's git-based hashing excludes it automatically
- **Alternative 2:** Use `inputs: ["src/**"]` explicitly in every task to only hash source files
- **Check:** Run `npx turbo build --summarize` and inspect `.turbo/runs/` for the full hash breakdown

## Prevention

Add to your `CLAUDE.md`:
```markdown
Exclude .claude/ and CLAUDE.md from turbo.json task inputs. Always specify explicit inputs arrays in turbo.json rather than relying on defaults. After modifying turbo.json, run builds twice to verify caching works.
```

**Related articles:** [Monorepo Setup Guide](/claude-code-monorepo-setup-guide/), [Claude Code Slow Response Fix](/claude-code-slow-response-fix/), [Errors Atlas](/errors-atlas/)
