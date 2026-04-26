---
layout: default
title: "Claude Code Maximum Turns Exceeded Loop — Fix (2026)"
permalink: /claude-code-max-turns-exceeded-fix-2026/
date: 2026-04-20
description: "Increase the --max-turns flag or decompose task to fix agent turn limit. Break large multi-file operations into focused sequential subtasks."
last_tested: "2026-04-21"
---

## The Error

```
Maximum turns exceeded (50). Agent loop terminated.
```

## The Fix

```bash
# Increase the turn limit for complex tasks using the --max-turns flag
claude --max-turns 100 "Refactor the entire auth module"

# Or set it via environment variable for the session:
export CLAUDE_MAX_TURNS=100
claude "Continue the refactoring task"
```

## Why This Works

Claude Code limits agent loops to 50 turns by default to prevent runaway execution and excessive API costs. Each tool call (read, edit, bash, search) counts as one turn. Complex tasks involving many files can legitimately require more than 50 operations. Raising the limit allows completion while still providing an upper bound.

## If That Doesn't Work

```bash
# Decompose the task into smaller scoped operations
claude "Refactor auth module step 1: extract token validation to src/auth/tokens.ts"
claude "Refactor auth module step 2: update all imports to use new tokens.ts"
claude "Refactor auth module step 3: add tests for extracted functions"

# Or use continue to resume where it left off:
claude "continue"
```

Breaking work into sub-tasks that each complete within 50 turns is more reliable than raising the limit indefinitely.

## Prevention

Add to your CLAUDE.md:
```
Decompose tasks requiring more than 30 file operations into sequential subtasks. Each subtask should target a single module or concern. Use explicit step numbering (step 1, step 2) to maintain progress across sessions.
```

## See Also

- [File Exceeds 10MB Limit in Claude Code — Fix (2026)](/claude-code-max-file-size-exceeded-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.


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
