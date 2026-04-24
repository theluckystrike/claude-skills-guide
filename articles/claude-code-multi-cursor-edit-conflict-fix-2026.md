---
title: "Multi-Cursor Edit Conflict Fix"
permalink: /claude-code-multi-cursor-edit-conflict-fix-2026/
description: "Fix multi-cursor edit conflict between IDE and Claude Code. Save and close editor buffers before Claude edits to prevent simultaneous write collisions."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Edit tool failed — old_string not found in file
  File 'src/components/Header.tsx' was modified by editor (multi-cursor edit active)
  File on disk differs from Claude Code's cached version
  3 unsaved editor changes conflict with Claude Code's planned edit
```

This appears when you are actively editing a file in your IDE with multi-cursor selections while Claude Code tries to edit the same file via its Edit tool.

## The Fix

```bash
# In your editor: Save all files (Cmd+S / Ctrl+S)
# Then ask Claude to retry:
claude "Retry the edit on src/components/Header.tsx"
```

1. Save all open files in your editor to flush changes to disk.
2. Wait for the editor's auto-save to complete (if enabled).
3. Ask Claude Code to retry the edit — it will re-read the file and apply the change.

## Why This Happens

Claude Code's Edit tool works by reading the file from disk, finding an exact string match (`old_string`), and writing the replacement. If your IDE has unsaved changes (especially from multi-cursor edits that modify many lines simultaneously), the file on disk differs from what Claude Code expects. The exact string match fails because the old_string was based on the pre-edit file state. This race condition is most common with VS Code's auto-save delay.

## If That Doesn't Work

Disable auto-save temporarily and save manually:

```json
// .vscode/settings.json
{
  "files.autoSave": "off"
}
```

Close the file in your editor before asking Claude to edit:

```bash
claude "Close any editor tabs for Header.tsx, then edit it"
```

Use Claude Code's Write tool for a full file replacement instead:

```bash
claude "Rewrite the entire Header.tsx file with the updated version"
```

## Prevention

```markdown
# CLAUDE.md rule
Before making edits, save all open editor files. Do not edit files in the IDE while Claude Code is working on them. Use VS Code auto-save with a short delay (1 second) to minimize conflicts.
```

## See Also

- [Windows WSL Path Conflict Error — Fix (2026)](/claude-code-windows-wsl-path-conflict-fix-2026/)
- [Certificate Pinning Conflict Error — Fix (2026)](/claude-code-certificate-pinning-conflict-fix-2026/)
- [Git Worktree Lock Conflict Fix](/claude-code-worktree-lock-conflict-fix-2026/)
- [Claude Edit Tool File Modified Externally — Fix (2026)](/claude-code-edit-tool-conflict-merge-fix-2026/)
- [Peer Dependency Conflict npm Error — Fix (2026)](/claude-code-peer-dependency-conflict-fix-2026/)
