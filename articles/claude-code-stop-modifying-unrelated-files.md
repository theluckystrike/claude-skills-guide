---
title: "Stop Claude Code from Modifying Unrelated Files — Fix Guide (2026)"
description: "Why Claude Code edits files you did not ask about and how to prevent it with CLAUDE.md rules, permissions, and scope constraints."
permalink: /claude-code-stop-modifying-unrelated-files/
render_with_liquid: false
categories: [claude-md, fixes]
tags: [claude-code, unrelated-files, scope, permissions, fix]
last_updated: 2026-04-19
---

## The Problem

You ask Claude Code to fix a bug in the user authentication module. Claude fixes the bug -- and also reformats an unrelated configuration file, adds a TODO comment to a service you did not mention, and changes an import in a test file three directories away. None of those changes were requested. Some introduce bugs.

This is the most common frustration with Claude Code, and it has concrete causes and fixes.

## Why Claude Modifies Unrelated Files

Claude modifies unrelated files for three reasons:

1. **Vague instructions.** "Fix the login flow" is ambiguous about scope. Claude interprets it broadly and touches anything that might be related to login.

2. **No scope constraints in CLAUDE.md.** Without explicit boundaries, Claude follows whatever chain of dependencies it discovers. A bug in auth leads to the user service, which leads to the database repository, which leads to the migration file.

3. **Reformatting impulse.** Claude has a tendency to "clean up" files it reads. If it opens a file to check an import and notices inconsistent formatting, it fixes the formatting -- even though you did not ask.

## Fix 1: Add Scope Rules to CLAUDE.md

The most effective fix is explicit scope instructions:

```markdown
## Scope Rules (MANDATORY)
- Only modify files directly related to the user's request
- Do NOT reformat or refactor code in files you open for reference
- Do NOT add comments, TODOs, or documentation to files unless asked
- Do NOT change imports or exports in files outside the requested scope
- When fixing a bug, change the minimum code necessary — no opportunistic refactoring
- If a related file needs changes, explain why and ask before modifying it
```

These rules work because they are concrete and verifiable. "Do NOT reformat code in files you open for reference" is a clear instruction Claude can follow.

## Fix 2: Use Permissions to Limit File Access

Claude Code's permission system can restrict which files Claude modifies. In `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Edit(config/**)",
      "Edit(.env*)",
      "Edit(*.lock)",
      "Edit(migrations/**)"
    ]
  }
}
```

This prevents Claude from editing configuration files, environment files, lock files, and migrations regardless of what it decides to do. Claude can still read these files for context but cannot modify them.

For temporary scope restrictions during a session, use the `/permissions` command to add or remove tool permissions.

## Fix 3: Be Specific in Your Requests

The way you phrase requests controls Claude's scope:

```
# Broad (Claude will explore widely):
"Fix the login flow"

# Scoped (Claude stays focused):
"Fix the password validation in src/services/auth-service.ts —
 the regex on line 47 does not accept passwords with special characters.
 Only modify auth-service.ts and its test file."
```

Adding "only modify X" to your request is the simplest way to constrain scope. Claude respects explicit file constraints more reliably than implicit ones.

## Fix 4: Path-Specific Rules for Sensitive Areas

Use `.claude/rules/` with path patterns to protect sensitive areas of your codebase:

```markdown
# .claude/rules/protected-files.md
---
paths:
  - "migrations/**"
  - "config/**"
  - "scripts/**"
---

## Protected File Rules
- NEVER modify these files unless the user explicitly asks to change them
- NEVER add, remove, or reorder content in configuration files
- NEVER modify migration files after they have been applied
- If changes are needed here, explain the change and ask for permission first
```

## Fix 5: Review Before Accepting

Enable Claude Code's diff view to review every change before accepting. When Claude modifies a file you did not expect:

1. Check if the change is actually necessary for your request
2. If not, reject the change and add a scope rule to CLAUDE.md
3. If yes, accept it but add a note to CLAUDE.md about the dependency

## Diagnostic Checklist

If Claude keeps modifying unrelated files despite your rules:

1. **Run `/memory`** to verify your scope rules are loaded
2. **Check for contradictions** — another instruction file might say "always fix formatting issues you find"
3. **Check file length** — if CLAUDE.md exceeds 200 lines, rules near the bottom may be ignored
4. **Check rule specificity** — "be careful with changes" is too vague; "only modify files listed in the request" is specific

The scope rules should be near the top of your CLAUDE.md, in the first 50 lines, where Claude's adherence is strongest.

For the complete troubleshooting guide to CLAUDE.md instruction-following, see the [ignoring CLAUDE.md fix guide](/how-to-fix-claude-code-ignoring-my-claude-md-file/). For general best practices in writing rules Claude follows, see the [CLAUDE.md best practices](/claude-code-claude-md-best-practices/). For setting up permissions, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/).
