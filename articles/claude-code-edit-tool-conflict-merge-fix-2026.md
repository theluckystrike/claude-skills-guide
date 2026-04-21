---
title: "Claude Edit Tool File Modified Externally — Fix (2026)"
permalink: /claude-code-edit-tool-conflict-merge-fix-2026/
description: "Re-read the file before editing to fix external modification conflict. Resolves stale content checksum mismatch caused by formatters or watchers."
last_tested: "2026-04-21"
render_with_liquid: false
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
