---
title: "Claude Code ENOMEM Out of Memory Large Repos — Fix (2026)"
description: "Fix Claude Code ENOMEM out of memory on large repos. Increase Node.js heap and exclude heavy directories. Step-by-step solution."
permalink: /claude-code-enomem-out-of-memory-large-repos-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
 1: 0x100a4c0d4 node::Abort() [/usr/local/bin/node]
 2: 0x100a4c248 node::OOMErrorHandler(char const*, v8::OOMDetails const&)

# Or:
Error: ENOMEM: not enough memory, read
    at Object.readSync (node:fs:735:3)
    at readFileSync (node:fs:623:35)
```

## The Fix

1. **Increase Node.js heap size for Claude Code**

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
claude
```

2. **Add a .claudeignore file to exclude heavy directories**

```bash
cat > .claudeignore << 'EOF'
node_modules/
.git/objects/
dist/
build/
*.min.js
*.bundle.js
data/
*.sqlite
*.db
EOF
```

3. **Verify the fix:**

```bash
NODE_OPTIONS="--max-old-space-size=8192" claude --version
# Expected: @anthropic-ai/claude-code/X.X.X (no OOM crash)

# Check current memory limit:
node -e "console.log('Heap limit:', (v8.getHeapStatistics().heap_size_limit / 1024 / 1024).toFixed(0), 'MB')"
# Expected: Heap limit: 8192 MB
```

## Why This Happens

Claude Code indexes files in your working directory to build context for the AI. On repositories with hundreds of thousands of files (monorepos, repos with vendored dependencies, or large data directories), this indexing process exhausts Node.js's default heap limit of ~4 GB. The V8 engine throws a fatal OOM error and the process crashes. The `.claudeignore` file tells Claude Code to skip directories that don't need AI analysis.

## If That Doesn't Work

- **Alternative 1:** Run Claude Code from a subdirectory — `cd src/ && claude` — to limit the scope of file discovery
- **Alternative 2:** Set heap even higher for very large repos: `NODE_OPTIONS="--max-old-space-size=16384"` (16 GB)
- **Check:** Run `find . -not -path '*/node_modules/*' -not -path '*/.git/*' | wc -l` to count files Claude Code will scan

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always create a .claudeignore excluding node_modules, .git/objects, dist, build, and data directories. For repos with over 50K files, set NODE_OPTIONS="--max-old-space-size=8192" in shell profile. Run Claude Code from the most specific subdirectory possible.
```

**Related articles:** [Claude Code Out of Memory Fix](/claude-code-error-out-of-memory-large-codebase-fix/), [Claude Code Slow Response Fix](/claude-code-slow-response-fix/), [Claude Code Not Responding Fix](/claude-code-not-responding-terminal-hangs-fix/)
