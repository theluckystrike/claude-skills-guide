---
title: "VS Code Extension Consuming Excessive"
permalink: /claude-code-vscode-extension-excessive-cpu-fix-2026/
description: "Fix VS Code Claude Code extension consuming excessive CPU. Disable file watchers on large directories and limit workspace indexing to reduce CPU load."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
[Extension Host] High CPU usage detected: claude-code extension (92% CPU, 1.4GB RAM)
  File watcher processing 48,000+ files in workspace
  VS Code becoming unresponsive — extension host consuming all available cores
```

This appears in VS Code's process explorer (Help > Open Process Explorer) showing the Claude Code extension using abnormally high CPU.

## The Fix

```json
// .vscode/settings.json
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/dist/**": true,
    "**/.git/objects/**": true,
    "**/build/**": true
  }
}
```

1. Add large directories to VS Code's watcher exclude list.
2. Create a `.claudeignore` file with the same exclusions.
3. Reload VS Code window: `Cmd+Shift+P > Developer: Reload Window`.

## Why This Happens

The Claude Code VS Code extension indexes your workspace to provide context-aware suggestions. In large monorepos with many files (node_modules alone can contain 50,000+ files), the file watcher and indexer consume significant CPU. The extension re-indexes on every file change, and if the workspace includes generated files or build outputs that change frequently, the indexer enters a loop of continuous reprocessing.

## If That Doesn't Work

Disable the extension's file watcher entirely:

```json
// .vscode/settings.json
{
  "claude-code.fileWatcher.enabled": false
}
```

Reduce the workspace scope to just the source directory:

```bash
code src/
# Instead of: code .
```

Check VS Code's process explorer and kill runaway processes:

```
Help > Open Process Explorer
# Right-click on high-CPU extension host > Kill Process
```

## Prevention

```markdown
# CLAUDE.md rule
Always maintain a .claudeignore that excludes node_modules, dist, build, .git/objects, and any directory with more than 1,000 generated files. Open only the relevant subdirectory in VS Code for large monorepos.
```

## See Also

- [VS Code Extension Connection Timeout Fix](/claude-code-vscode-extension-connection-timeout-fix-2026/)
- [Claude Code VS Code Extension Fails to Activate — Fix (2026)](/claude-code-vscode-extension-fails-to-activate-fix/)
- [Claude Code VS Code Connection Lost — Fix (2026)](/claude-code-vscode-connection-lost-fix-2026/)
