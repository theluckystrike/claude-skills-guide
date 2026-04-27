---
sitemap: false
layout: default
title: "Claude Code Ignoring CLAUDE.md Entirely (2026)"
description: "Step-by-step diagnostic when Claude Code does not follow any CLAUDE.md instructions. Covers loading verification, file placement, specificity, and enforcement."
permalink: /claude-ignoring-claude-md-entirely/
date: 2026-04-20
categories: [claude-md, fixes]
tags: [claude-code, ignoring, claude-md, diagnostic, fix, troubleshooting]
last_updated: 2026-04-19
---

## The Frustration

You spent an hour writing a detailed CLAUDE.md. You start a Claude Code session and ask it to generate code. Claude ignores every rule -- wrong naming conventions, wrong architecture patterns, wrong error handling. It behaves as if the file does not exist.

This has four possible causes, and the diagnostic process takes about two minutes.

## Diagnostic Step 1: Is the File Being Loaded?

Run `/memory` in Claude Code. This lists every instruction file currently in context:

```
$ /memory

Loaded instruction files:
  ~/.claude/CLAUDE.md
  /project/CLAUDE.md           ← your file should appear here
  /project/CLAUDE.local.md
```

If your CLAUDE.md does NOT appear in the list, the file is not being loaded. Move to Step 2.

If your CLAUDE.md DOES appear, the file is loaded but instructions are not being followed. Skip to Step 3.

## Diagnostic Step 2: Fix File Placement

CLAUDE.md must be in a location Claude Code recognizes. Check these requirements:

**File name must be exact.** `CLAUDE.md` (uppercase), not `claude.md`, not `Claude.md`, not `CLAUDE.MD`.

**File must be in a recognized location:**

```
# Project level (most common)
./CLAUDE.md                    # project root
./.claude/CLAUDE.md            # alternative location

# User level
~/.claude/CLAUDE.md            # personal, all projects

# Managed (enterprise)
/Library/Application Support/ClaudeCode/CLAUDE.md  # macOS
/etc/claude-code/CLAUDE.md                          # Linux
```

**Check for claudeMdExcludes.** Your file might be excluded by settings:

```bash
# Check all settings files for exclusions
cat .claude/settings.json 2>/dev/null | grep -A5 "claudeMdExcludes"
cat .claude/settings.local.json 2>/dev/null | grep -A5 "claudeMdExcludes"
cat ~/.claude/settings.json 2>/dev/null | grep -A5 "claudeMdExcludes"
```

If your CLAUDE.md path matches an exclusion pattern, remove it from the exclusions list.

**Check for --add-dir.** If your CLAUDE.md is in an additional directory (added with `--add-dir`), it is NOT loaded by default. Set the environment variable:

```bash
export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
```

## Diagnostic Step 3: Are Instructions Specific Enough?

If the file loads but Claude ignores it, the problem is usually instruction quality. Compare:

```markdown
# Vague — Claude cannot verify compliance
- Write clean code
- Use good naming conventions
- Handle errors properly
- Follow best practices

# Specific — Claude can verify compliance
- Use camelCase for variables, PascalCase for classes
- Functions under 40 lines
- Return Result<T, AppError> from services, never throw
- No default exports — named exports only
```

Claude follows specific, verifiable instructions much more reliably than vague guidelines. Rewrite any instruction that contains words like "properly," "clean," "good," or "best practices."

## Diagnostic Step 4: Is the File Too Long?

```bash
wc -l CLAUDE.md
```

If over 200 lines, Claude's adherence degrades. Instructions near the bottom of long files are less likely to be followed. Split the file using imports, `.claude/rules/`, or skills:

```markdown
# Root CLAUDE.md — under 60 lines
## Project identity and core rules here

# Detailed rules in .claude/rules/
# .claude/rules/testing.md (with paths for test files)
# .claude/rules/api-design.md (with paths for route files)
```

## Diagnostic Step 5: Check for Contradictions

Search for conflicting instructions across all loaded files:

```bash
# Find topics mentioned in multiple files
for topic in "indent" "export" "error" "naming" "test"; do
  echo "--- $topic ---"
  grep -rn "$topic" CLAUDE.md CLAUDE.local.md .claude/rules/ ~/.claude/CLAUDE.md 2>/dev/null
done
```

If the same topic appears in multiple files with different guidance, Claude picks one arbitrarily. Remove duplicates and consolidate each topic to a single file.

## Diagnostic Step 6: Use InstructionsLoaded Hook

For advanced debugging, add a hook that logs which instruction files load:

```json
{
  "hooks": {
    "InstructionsLoaded": {
      "command": "echo \"Instructions loaded at $(date)\" >> /tmp/claude-instructions.log"
    }
  }
}
```

This confirms that instruction files are being processed, and when.

## Quick Fix Checklist

1. Run `/memory` -- is the file listed?
2. Check file name is exactly `CLAUDE.md` (uppercase)
3. Check file is in project root or `.claude/` directory
4. Check for `claudeMdExcludes` in settings files
5. Check file is under 200 lines
6. Check instructions are specific and verifiable
7. Check for contradictions across all loaded files
8. Restart Claude Code session if you just created the file

## Diagnostic Step 7: Check for Managed Policy Override

If your organization deploys a managed CLAUDE.md, its instructions load before your project file. If the managed policy contradicts your project rules, the managed policy may win depending on instruction phrasing:

```bash
# Check for managed CLAUDE.md
ls -la "/Library/Application Support/ClaudeCode/CLAUDE.md" 2>/dev/null  # macOS
ls -la "/etc/claude-code/CLAUDE.md" 2>/dev/null                          # Linux
```

If a managed file exists, read it to check for contradictions with your project CLAUDE.md. You cannot exclude managed CLAUDE.md -- it always loads. Align your project rules with organizational policy or contact your IT team.

## When Nothing Works: --append-system-prompt

As a last resort for critical instructions, use `--append-system-prompt` to inject instructions at the system prompt level rather than as a user message:

```bash
claude --append-system-prompt "CRITICAL: All code must use TypeScript strict mode with no any types"
```

This is a per-invocation flag, not a permanent setting. It provides the strongest instruction adherence because system prompt content has the highest priority. Use it sparingly for rules that are genuinely non-negotiable.

For resolving specific contradictions between files, see the [conflicting instructions fix guide](/claude-md-conflicting-instructions-fix/). For the complete CLAUDE.md specification, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For writing instructions Claude reliably follows, see the [best practices guide](/claude-code-claude-md-best-practices/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.


**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

