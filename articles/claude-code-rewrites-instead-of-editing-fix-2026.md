---
title: "Stop Claude Code Rewriting Entire Files (2026)"
description: "Stop Claude Code from rewriting entire files when you ask for small edits by adding surgical edit rules and diff-size limits to CLAUDE.md."
permalink: /claude-code-rewrites-instead-of-editing-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Rewriting Entire Files (2026)

You ask Claude Code to fix a typo in line 42 and it rewrites the entire 300-line file. The diff is massive, unreviewable, and may contain unintended changes buried in the rewrite.

## The Problem

Claude Code sometimes replaces an entire file when it should edit a few lines. This causes:
- Unreviewable diffs (300+ lines changed for a 2-line fix)
- Hidden side effects (reformatting, import reordering, whitespace changes)
- Lost intentional formatting (comment alignment, blank line groupings)
- Git blame pollution (every line shows the same commit)
- Merge conflicts with other developers' work

## Root Cause

The model's write_file tool replaces the entire file content. When Claude Code uses write_file instead of the edit tool (which does targeted string replacement), it rewrites everything. The model sometimes prefers write_file because it is simpler to generate a complete file than to craft a precise edit.

## The Fix

The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) enforces surgical edits through its behavioral modes. Its `/sc:implement` command defaults to minimal-diff changes. Apply the same principle in your CLAUDE.md.

### Step 1: Enforce Edit Over Write

```markdown
## File Modification Rules — CRITICAL
1. ALWAYS use the Edit tool for modifying existing files
2. NEVER use write_file on existing files unless rewriting >80% of content
3. Each edit should change the MINIMUM lines needed
4. Keep surrounding context unchanged (imports, spacing, comments)
```

### Step 2: Set Diff Size Limits

```markdown
## Diff Size Limits
- Typo/bug fix: < 10 lines changed
- Feature addition: < 50 lines changed per file
- Refactoring: < 100 lines changed per file
- If a change exceeds these limits, ask before proceeding
```

### Step 3: Prohibit Drive-By Changes

```markdown
## No Drive-By Changes
When editing a file, DO NOT:
- Reorder imports (unless that is the explicit task)
- Reformat code that you did not change
- Remove blank lines between sections
- Change quotes (single to double or vice versa)
- Update comments in code you did not modify
- Convert var/let/const in unchanged lines
```

## CLAUDE.md Code to Add

```markdown
## Surgical Edit Protocol
1. Identify the exact lines that need to change
2. Use the Edit tool with the smallest possible old_string
3. Include just enough context in old_string to be unique
4. new_string should differ from old_string by only what is necessary
5. After editing, verify only the intended lines changed
```

## Verification

1. Ask Claude Code to fix a specific bug on a specific line
2. Check the tool call: Did it use Edit (targeted) or write_file (full rewrite)?
3. Count changed lines: Is it proportional to the fix?
4. Check for drive-by changes: Did anything else in the file change?

## Prevention

Review Claude Code's tool usage in your session. If you see write_file on an existing file for a small change, explicitly say: "Use the Edit tool, not write_file."

The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) "Goal-Driven Execution" principle reinforces this: do exactly what was asked, nothing more.

For more on controlling Claude Code's editing behavior, see [The Claude Code Playbook](/playbook/). For refactoring-specific scope control, read the [refactoring quality guide](/claude-code-bad-at-refactoring-fix-2026/). For overall code quality patterns, see our [best practices guide](/karpathy-skills-vs-claude-code-best-practices-2026/).
