---
layout: default
title: "Claude Code Glob Pattern Too Broad — Fix (2026)"
permalink: /claude-code-glob-pattern-too-broad-fix-2026/
date: 2026-04-20
description: "Narrow glob pattern scope to fix the 10000-file match limit error. Add a specific directory prefix or targeted extension filter to stay under the cap."
last_tested: "2026-04-21"
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


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
