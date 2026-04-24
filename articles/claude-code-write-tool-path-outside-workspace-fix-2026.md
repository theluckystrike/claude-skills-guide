---
title: "Claude Code Write Path Outside — Fix (2026)"
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

## See Also

- [Make Claude Code Write Tests First (TDD) (2026)](/claude-code-write-tests-first-tdd-setup-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `SyntaxError: Unexpected token in JSON at position 0`
- `JSON.parse: unexpected character at line 1 column 1`
- `Error: invalid JSON response from API`
- `Error: ENOENT: no such file or directory`
- `Cannot resolve path outside workspace`

## Frequently Asked Questions

### Why does JSON parsing fail on API responses?

JSON parse failures on API responses typically indicate a network issue where an intermediate proxy returned an HTML error page instead of JSON. Check the raw response by enabling debug logging with `CLAUDE_LOG_LEVEL=debug` to see the actual content received.

### How do I fix corrupted JSON config files?

Open the file in a text editor and look for common issues: trailing commas, missing quotes, or truncated content (from a crash during write). Use `python3 -m json.tool < file.json` to validate and identify the exact parse error location.

### Can Claude Code handle JSON files with comments?

Standard JSON does not support comments. If your project uses JSONC (JSON with Comments), Claude Code handles it when reading via tools. For configuration files like `tsconfig.json` that support JSONC, Claude Code strips comments before parsing.

### Why does Claude Code reject paths outside the workspace?

Claude Code sandboxes file operations to the current workspace directory for security. Writing to paths outside the project root (like `/etc/` or `~/`) is blocked by default. This prevents accidental modification of system files or other projects.
