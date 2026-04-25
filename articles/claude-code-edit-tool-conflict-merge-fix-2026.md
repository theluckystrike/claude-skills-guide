---
title: "Claude Edit Tool File Modified — Fix"
permalink: /claude-code-edit-tool-conflict-merge-fix-2026/
description: "Re-read the file before editing to fix external modification conflict. Resolves stale content checksum mismatch caused by formatters or watchers."
last_tested: "2026-04-21"
---

## The Error

```
Edit failed: file was modified externally since last read
```

## The Fix

```bash
# Re-read the file to refresh Claude's view of the current content
# Then retry the edit with the updated content

# If using Claude interactively, simply tell it:
# "Read the file again, then make the edit"

# If the file was modified by a formatter or pre-commit hook:
git diff path/to/file.ts
```

## Why This Works

Claude Code tracks file checksums between read and edit operations. When an external process (formatter, linter, file watcher, or another editor) modifies the file after Claude read it, the checksum no longer matches. Re-reading resets the baseline so the edit applies cleanly.

## If That Doesn't Work

```bash
# Disable file watchers temporarily
# For VS Code, add to .vscode/settings.json:
echo '{"files.watcherExclude": {"**/*": true}}' > .vscode/settings.json

# Or pause formatters:
echo '{"editor.formatOnSave": false}' >> .vscode/settings.json
```

Formatters triggered by file save events are the most common cause of this race condition.

## Prevention

Add to your CLAUDE.md:
```
When editing files that have active watchers or format-on-save enabled, always read the file immediately before editing. Do not batch multiple file reads followed by multiple edits — read then edit each file sequentially.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `Hook execution failed with exit code 1`
- `pre-commit hook rejected the commit`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What are Claude Code hooks?

Claude Code hooks are user-defined scripts that run at specific lifecycle points: before/after file edits, before/after bash commands, and before/after commits. They are configured in `.claude/hooks/` or via the Claude Code settings file.


## Related Guides

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
