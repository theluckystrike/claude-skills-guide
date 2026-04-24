---
title: "Stop Claude Code Touching Unrelated"
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

## See Also

- [Claude Code spending tokens on files I didn](/claude-code-spending-tokens-files-didnt-ask-about/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`
- `Warning: response may be incomplete due to token limit`
- `Error: ENOENT: no such file or directory`
- `Cannot resolve path outside workspace`

## Frequently Asked Questions

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.

### How do I reduce token consumption in long sessions?

Start new conversations for unrelated tasks. Each message in a conversation includes the full history, so long conversations consume exponentially more tokens. A 50-message conversation may use 10x the tokens of five 10-message conversations.

### Can I see my token usage?

Run `claude usage` to see your current billing period's token consumption broken down by model. The Anthropic console at console.anthropic.com provides detailed usage graphs and per-day breakdowns.

### Why does Claude Code reject paths outside the workspace?

Claude Code sandboxes file operations to the current workspace directory for security. Writing to paths outside the project root (like `/etc/` or `~/`) is blocked by default. This prevents accidental modification of system files or other projects.
