---
sitemap: false
layout: default
title: "CLAUDE.md Not Loading in Claude Code (2026)"
description: "Step-by-step fix when Claude Code does not load your CLAUDE.md file. Covers file placement, naming, exclusions, subdirectory behavior, and --add-dir."
permalink: /claude-md-not-loading-fix/
date: 2026-04-20
categories: [claude-md, fixes]
tags: [claude-md, not-loading, fix, placement, exclusions, troubleshooting]
last_updated: 2026-04-19
---

## Quick Diagnostic

Your CLAUDE.md exists but Claude Code ignores it. Run `/memory` to check if the file appears in the loaded instructions list. If it does not appear, one of the following causes applies. Work through them in order -- most loading failures are caused by the first two.

## Cause 1: Wrong File Name

CLAUDE.md must be named exactly `CLAUDE.md` with uppercase letters:

```bash
# Check what you have
ls -la CLAUDE* claude* 2>/dev/null
```

Common mistakes:
- `claude.md` (lowercase) -- not recognized
- `CLAUDE.MD` (uppercase extension) -- not recognized
- `CLAUDE.md.txt` (extra extension) -- not recognized
- `CLAUDE .md` (space before dot) -- not recognized

The fix: rename to exactly `CLAUDE.md`.

## Cause 2: Wrong Location

CLAUDE.md loads from specific locations in a defined order:

```
Recognized locations:
  ./CLAUDE.md                                    # project root
  ./.claude/CLAUDE.md                            # alternative project location
  ~/.claude/CLAUDE.md                            # user-level (all projects)
  /Library/Application Support/ClaudeCode/CLAUDE.md  # managed (macOS)
  /etc/claude-code/CLAUDE.md                     # managed (Linux)
```

If your file is in a subdirectory like `docs/CLAUDE.md` or `src/CLAUDE.md`, it loads on demand -- only when Claude reads files in that directory, not at launch.

**Fix for subdirectory CLAUDE.md:** If you need these instructions loaded at launch, move the critical rules to the project-root CLAUDE.md and use imports:

```markdown
# ./CLAUDE.md (project root)
@docs/CLAUDE.md
```

## Cause 3: Excluded by Settings

Check if your CLAUDE.md is excluded by `claudeMdExcludes`:

```bash
# Check all settings files
cat .claude/settings.json 2>/dev/null | python3 -m json.tool | grep -A10 "claudeMdExcludes"
cat .claude/settings.local.json 2>/dev/null | python3 -m json.tool | grep -A10 "claudeMdExcludes"
cat ~/.claude/settings.json 2>/dev/null | python3 -m json.tool | grep -A10 "claudeMdExcludes"
```

If your file path matches an exclusion pattern, remove it from the array:

```json
{
  "claudeMdExcludes": [
    "**/other-team/CLAUDE.md"
  ]
}
```

Note: Managed CLAUDE.md (OS-level) cannot be excluded by any settings.

## Cause 4: --add-dir Without Environment Variable

If your CLAUDE.md is in a directory added with `--add-dir`, it is NOT loaded by default. This is a deliberate security decision -- external directories should not inject instructions without explicit opt-in.

**Fix:**

```bash
# Set the environment variable before launching Claude
export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
claude --add-dir /path/to/other/project/
```

With this variable set, Claude loads CLAUDE.md, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and CLAUDE.local.md from the added directory.

## Cause 5: Subdirectory Loading Behavior

CLAUDE.md files in subdirectories load on demand, not at launch:

```
project/
  CLAUDE.md          ← loads at launch
  src/
    CLAUDE.md        ← loads when Claude reads files in src/
    api/
      CLAUDE.md      ← loads when Claude reads files in src/api/
```

After compaction, nested CLAUDE.md files are NOT re-injected automatically. They reload when Claude next reads a file in that subdirectory.

**Fix:** Move critical instructions to the project-root CLAUDE.md. It survives compaction because Claude re-reads it from disk.

## Cause 6: New .claude/ Directory

If you just created the `.claude/` directory (including `.claude/rules/` or `.claude/skills/`) for the first time, Claude Code may not detect it until the next session. The directory watcher initializes at launch and does not pick up new top-level `.claude/` directories created mid-session.

**Fix:** Restart your Claude Code session after creating the `.claude/` directory for the first time.

## Verification Checklist

After applying a fix, verify loading:

```
1. Run /memory in Claude Code
2. Confirm your file appears in the loaded list
3. Ask Claude a question that should trigger one of your rules
4. Verify Claude follows the rule
```

If the file loads but Claude does not follow instructions, the problem is instruction quality, not loading. See the [ignoring CLAUDE.md diagnostic guide](/claude-ignoring-claude-md-entirely/) for that case.

## Cause 7: File Encoding Issues

CLAUDE.md must be a UTF-8 text file. Files created on Windows with BOM (byte order mark) or files saved in non-UTF-8 encodings may fail to load correctly:

```bash
# Check file encoding
file CLAUDE.md
# Expected: "UTF-8 Unicode text" or "ASCII text"
# Problem: "UTF-8 Unicode (with BOM) text" or other encodings

# Fix BOM issue
sed -i '1s/^\xEF\xBB\xBF//' CLAUDE.md
```

## Cause 8: Symlink Not Resolving

If your CLAUDE.md is a symlink, verify the target exists:

```bash
# Check if symlink is valid
ls -la CLAUDE.md
readlink -f CLAUDE.md
# If the target file does not exist, Claude cannot load it
```

Broken symlinks produce no error message -- the file simply does not appear in the loaded instruction list.

## When Multiple Causes Combine

In some cases, multiple causes compound. For example, you might have a correctly named CLAUDE.md in the project root (loads fine) but an exclusion pattern in settings that blocks it. Or the file loads but is immediately overshadowed by a longer managed CLAUDE.md that contradicts it. Work through each cause systematically and verify with `/memory` after each fix.

For the complete CLAUDE.md loading specification, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For resolving conflicts between loaded files, see the [conflicting instructions fix guide](/claude-md-conflicting-instructions-fix/). For optimizing file size, see the [length optimization guide](/claude-md-length-optimization/).



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code CLAUDE.md Not Found Fix (2026)](/claude-code-claude-md-not-found-parent-directories-fix/)
