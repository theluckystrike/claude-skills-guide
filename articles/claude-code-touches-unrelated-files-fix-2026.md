---
title: "Stop Claude Code Touching Unrelated Files (2026)"
description: "Add CLAUDE.md scope rules to prevent Claude Code from modifying files outside the task — scope declarations, read-vs-write separation, and diff audits."
permalink: /claude-code-touches-unrelated-files-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Touching Unrelated Files (2026)

You asked for a bug fix in one file. Claude Code modified six. Here's how to enforce file scope boundaries.

## The Problem

Claude Code reads files for context, then "improves" them while it's there:
- Reformats imports in files it opened for reference
- Adds types to unrelated functions
- Fixes style issues in adjacent code
- Refactors utilities it discovered during investigation

## Root Cause

Claude Code treats every opened file as a modification candidate. Reading `utils.ts` to understand a helper function becomes "while I'm here, let me also fix the typing on line 45." There's no built-in separation between files opened for reading and files that need writing.

## The Fix

```markdown
## File Scope Control
- Before making changes, list which files will be modified and why
- Reading a file for context does NOT mean you can modify it
- Only modify files that MUST change for the task to work
- Reformatting (imports, whitespace, semicolons) in files outside the task scope is prohibited
```

## CLAUDE.md Rule to Add

```markdown
## Scope Declaration (Required)
Before starting any modification:
**Will modify:**
- [file1] — [reason it must change for this task]
- [file2] — [reason it must change for this task]

**Read for context only (will NOT modify):**
- [file3], [file4]

If a file needs to move from "read only" to "will modify" during the task,
explain why before making the change.
```

## Verification

```
Fix the null reference in src/services/order-service.ts line 87
```

**Bad:** modifies `order-service.ts`, `types.ts`, `utils/format.ts`, `index.ts`
**Good:** modifies only `order-service.ts`, lists others in "noticed but not fixed"

Related: [Karpathy Surgical Changes](/karpathy-surgical-changes-principle-2026/) | [Diff-Minimizing Examples](/karpathy-surgical-changes-examples-2026/) | [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/)
