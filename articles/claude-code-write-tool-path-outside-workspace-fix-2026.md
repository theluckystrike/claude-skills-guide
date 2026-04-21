---
title: "Claude Code Write Path Outside Workspace — Fix (2026)"
permalink: /claude-code-write-tool-path-outside-workspace-fix-2026/
description: "Use absolute paths within workspace root to fix outside-workspace write error. Move target files inside the project boundary or use Bash tool."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Cannot write file: path is outside the workspace root
```

## The Fix

```bash
# Check your current workspace root
pwd

# Ensure the target path is under this directory
# BAD:  /tmp/output.json
# BAD:  ../other-project/file.ts
# GOOD: /Users/you/project/output/result.json

# If you need the file elsewhere, write it inside the workspace first
# then move it manually after Claude finishes
```

## Why This Works

Claude Code restricts file writes to the workspace root directory (the directory where the session was started) as a security boundary. This prevents accidental or malicious writes to system directories, other projects, or sensitive locations. All file operations must target paths that resolve to somewhere inside the workspace tree.

## If That Doesn't Work

```bash
# Create a symlink inside your workspace pointing to the target location
ln -s /path/to/external/dir ./external-link

# Or start Claude Code from a parent directory that encompasses both locations
cd /Users/you/projects && claude

# Or use Bash tool to write outside workspace (if permissions allow)
echo "content" > /path/to/external/file.txt
```

The Bash tool has broader filesystem access than the Write tool, though sandbox mode may still restrict it.

## Prevention

Add to your CLAUDE.md:
```
All generated files must be written inside the project workspace. For outputs needed in external locations, write to a local output/ directory and include a post-processing step to copy them to their final destination.
```
