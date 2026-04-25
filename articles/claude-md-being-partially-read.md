---
layout: default
title: "CLAUDE.md Being Partially Read (2026)"
description: "Fix the problem where Claude Code follows some CLAUDE.md rules but ignores others. Covers compaction behavior, file length, rule priority, and diagnostic steps."
permalink: /claude-md-being-partially-read/
date: 2026-04-20
categories: [claude-md, fixes]
tags: [claude-md, partially-read, compaction, ignored-rules, troubleshooting]
last_updated: 2026-04-19
---

## The Partial Reading Problem

You notice that Claude follows your first five CLAUDE.md rules perfectly but ignores the last three. Or Claude follows all rules at the start of a session but drifts away from them after extended conversation. This is not random -- it has specific, diagnosable causes.

## Cause 1: File Length Exceeding 200 Lines

The most common cause. When CLAUDE.md exceeds the recommended 200-line maximum, rules near the bottom receive less attention. Claude's instruction adherence is strongest for rules near the top of the context and weakens as the context grows.

**Diagnostic:**

```bash
# Check your file length
wc -l CLAUDE.md

# Identify which rules are being ignored — they are probably near the bottom
tail -50 CLAUDE.md
```

**Fix:** Restructure so your most critical rules appear in the first 50 lines:

```markdown
# Lines 1-50: Critical rules (architecture, security, error handling)
# Lines 51-100: Important rules (naming, testing)
# Lines 101-150: Nice-to-have rules (style preferences)
```

Better yet, split into `.claude/rules/` files with path patterns so each file stays short and loads conditionally.

## Cause 2: Compaction Dropped Nested Files

Claude Code's auto-compaction summarizes long conversations to stay within context limits. During compaction:

- **Project-root CLAUDE.md**: Survives. Re-read from disk after compaction.
- **Nested CLAUDE.md** (subdirectories): NOT re-injected automatically. Reloads when Claude next reads a file in that subdirectory.
- **Conversation-only instructions**: Lost permanently.

**Diagnostic:**

If rules worked at the start of a session but stopped after extended conversation, compaction likely dropped them.

```
# Run /memory after a long session
# Check if nested CLAUDE.md files are still listed
# If they disappeared, compaction dropped them
```

**Fix:** Move critical instructions to the project-root CLAUDE.md. This file always survives compaction because Claude re-reads it from disk:

```markdown
# ./CLAUDE.md (project root — survives compaction)
## Critical Rules
- All database access through repositories
- Error handling uses Result types
- No default exports

# Import less critical rules that can reload on demand
@src/api/CLAUDE.md
```

## Cause 3: Contradicting Instructions

When two rules contradict each other, Claude follows one and ignores the other. This looks like partial reading, but it is actually a conflict:

```markdown
# Rule in CLAUDE.md line 15:
- Return errors as exceptions using throw

# Rule in CLAUDE.md line 85:
- Return errors as Result<T, AppError>

# Claude follows one, ignores the other — appears as partial reading
```

**Diagnostic:**

Search for topics mentioned multiple times:

```bash
grep -n "error\|throw\|exception\|Result" CLAUDE.md
```

**Fix:** Remove the contradicting rule. Each topic should appear exactly once.

## Cause 4: Rules Too Vague to Verify

Claude follows specific rules and skips vague ones:

```markdown
# These get followed (specific):
- Function names start with a verb: get, set, create, delete
- Maximum function body: 40 lines
- No any type — use unknown

# These get skipped (vague):
- Write clean code
- Follow best practices
- Keep things organized
```

**Diagnostic:** Read each ignored rule and ask: "Can Claude check this with a yes/no test?" If not, the rule is too vague.

**Fix:** Rewrite vague rules as concrete, verifiable statements.

## Cause 5: Path-Specific Rules Not Matching

If you use `.claude/rules/` with path patterns, rules only load when Claude reads files matching the glob. If Claude does not read any matching files during a session, the rules never load:

```markdown
# .claude/rules/api-design.md
---
paths:
  - "src/routes/**/*.ts"
---
# These rules only load when Claude reads files in src/routes/
```

**Diagnostic:** Run `/memory` to see which rules files are currently loaded. Ask Claude to read a file matching the glob, then run `/memory` again to see if the rules file appears.

**Fix:** Rules that must always be active should NOT have path patterns. Remove the `paths` frontmatter or move the rules to the root CLAUDE.md.

## Diagnostic Summary

| Symptom | Likely Cause | Fix |
|---|---|---|
| Bottom rules ignored | File too long | Move rules up or split into files |
| Rules stop working mid-session | Compaction dropped nested files | Move to project-root CLAUDE.md |
| Some rules followed, others not | Contradicting instructions | Search and remove conflicts |
| Obvious rules ignored | Rules too vague | Rewrite with concrete criteria |
| Rules never active | Path patterns not matching | Check glob patterns or remove paths |

For splitting long CLAUDE.md files, see the [length optimization guide](/claude-md-length-optimization/). For diagnosing conflict-specific issues, see the [conflicting instructions fix guide](/claude-md-conflicting-instructions-fix/). For the complete CLAUDE.md loading specification, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/).


## Common Questions

### How do I get started with claude.md being partially read?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Fix Claude Md Not Being Read By Claude](/claude-md-not-being-read-by-claude-code-fix/)
- [Best CLAUDE.md Templates for Teams](/best-claude-md-templates-enterprise-2026/)
- [Building a Chrome Extension for a Read](/chrome-extension-read-later-list/)
