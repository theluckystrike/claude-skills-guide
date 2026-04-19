---
title: "CLAUDE.md Conflict Resolution — When Instructions Contradict Each Other (2026)"
description: "How Claude Code handles conflicting instructions across CLAUDE.md, CLAUDE.local.md, rules files, and managed policies. Diagnosis and resolution steps."
permalink: /claude-md-conflict-resolution/
render_with_liquid: false
categories: [claude-md, workflow]
tags: [claude-md, conflicts, resolution, loading-order, troubleshooting]
last_updated: 2026-04-19
---

## How Conflicts Happen

Conflicts appear when two instruction files say different things about the same topic. One CLAUDE.md says "use tabs," another says "use spaces." A rules file says "return errors as Result types," while the root CLAUDE.md says "throw exceptions." Claude does not report these contradictions -- it picks one instruction and follows it, often inconsistently across interactions.

The result is unpredictable behavior. Claude generates code with tabs in one session and spaces in the next. You blame Claude for being unreliable, when the real problem is contradictory instructions.

## How Claude Code Loads Instructions

Understanding the loading order is essential for diagnosing conflicts:

```
Loading order (all concatenated, not replaced):

1. Managed CLAUDE.md (OS-level, cannot be excluded)
2. ~/.claude/CLAUDE.md (user-level, all projects)
3. ~/.claude/rules/*.md (user-level rules)
4. Ancestor directory CLAUDE.md files (loaded at launch)
5. ./CLAUDE.md (project root)
6. ./.claude/CLAUDE.md (alternative project location)
7. ./.claude/rules/*.md (project rules, path-matched)
8. ./CLAUDE.local.md (personal overrides)
```

All files are concatenated into a single instruction set. When two instructions conflict, the later-loaded file wins. CLAUDE.local.md has the highest priority for personal overrides.

## Diagnosing Conflicts

Run `/memory` as your first step. It shows every loaded instruction file:

```
$ /memory

Loaded instruction files:
  ~/.claude/CLAUDE.md
  /project/CLAUDE.md
  /project/.claude/rules/testing.md
  /project/.claude/rules/api-design.md
  /project/CLAUDE.local.md
```

Once you know which files are loaded, search for conflicting instructions across them:

```bash
# Find all mentions of indentation across instruction files
grep -rn "indent\|tabs\|spaces" CLAUDE.md CLAUDE.local.md .claude/rules/ ~/.claude/CLAUDE.md

# Find all error handling instructions
grep -rn "error\|throw\|exception\|Result" CLAUDE.md CLAUDE.local.md .claude/rules/
```

Common conflict patterns:
- **Formatting conflicts**: tabs vs spaces, semicolons vs no semicolons
- **Pattern conflicts**: throw exceptions vs return Result types
- **Naming conflicts**: camelCase vs snake_case for the same context
- **Tool conflicts**: different linters or test runners specified in different files

## Resolution Strategies

### Strategy 1: Consolidate Duplicates

If the same topic appears in multiple files, consolidate to one location:

```markdown
# Before: indentation mentioned in 3 files
# ~/.claude/CLAUDE.md: "Use tabs"
# ./CLAUDE.md: "Use 2-space indentation"
# ./.claude/rules/formatting.md: "4-space indent for Python"

# After: one source of truth per topic
# ~/.claude/CLAUDE.md: (remove indentation rule)
# ./CLAUDE.md: "Use 2-space indentation for TypeScript"
# ./.claude/rules/python.md: "Use 4-space indentation" (with paths: ["**/*.py"])
```

### Strategy 2: Use Path-Specific Rules

When different rules apply to different file types, use `.claude/rules/` with paths instead of putting everything in the root CLAUDE.md:

```markdown
# .claude/rules/typescript.md
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---
- 2-space indentation
- Semicolons required
- Named exports only
```

```markdown
# .claude/rules/python.md
---
paths:
  - "**/*.py"
---
- 4-space indentation (PEP 8)
- Type hints on all function signatures
- Docstrings in Google format
```

Path-specific rules avoid conflicts because they only load when Claude reads matching files.

### Strategy 3: CLAUDE.local.md for Personal Overrides

When a team member needs different behavior for their workflow, use CLAUDE.local.md instead of modifying the shared CLAUDE.md:

```markdown
# CLAUDE.local.md (gitignored)
# Override: I need verbose error messages during debugging
- When generating error messages, include the full stack trace context
- This overrides the team rule of "concise error messages in production"
```

CLAUDE.local.md loads last and wins on conflicts, so this is the correct mechanism for personal overrides.

## Preventing Future Conflicts

1. **One topic, one file.** Testing rules in one file, API rules in another. Never split a topic across files.
2. **Use path-specific rules** for file-type conventions. They cannot conflict with each other.
3. **Review CLAUDE.md changes in PRs.** A second pair of eyes catches contradictions you miss.
4. **Run `/memory` periodically.** Check what files are loaded and scan for overlapping topics.
5. **Keep total instruction count under 200 lines per file.** Long files accumulate contradictions.

## Using the InstructionsLoaded Hook

For advanced conflict diagnosis, add a hook that logs which instruction files load and in what order:

```json
{
  "hooks": {
    "InstructionsLoaded": {
      "command": "echo \"$(date): Instructions loaded\" >> /tmp/claude-instructions.log"
    }
  }
}
```

This confirms timing and loading order. If a file loads before you expect it to, that explains why its rules take lower priority. The log also shows whether excluded files are correctly being skipped.

## Monorepo Conflict Management

Monorepos have the highest conflict risk because multiple teams share the same repository. Use `claudeMdExcludes` to prevent one team's CLAUDE.md from loading in another team's context:

```json
{
  "claudeMdExcludes": [
    "**/backend-team/CLAUDE.md",
    "**/mobile-team/.claude/rules/**"
  ]
}
```

Combined with path-specific rules, this gives each team in a monorepo isolation from other teams' instructions. Shared, cross-team rules go in the repository root CLAUDE.md.

For the complete loading order and mechanics, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For managing team versus personal files, see the [team vs personal guide](/team-claude-md-vs-personal-claude-md/). For version control practices that prevent conflicts during merges, see the [version control strategies guide](/claude-md-version-control-strategies/).

## Related Articles

- [How to Use Claude Md Conflicting — Complete Developer (2026)](/claude-md-conflicting-instructions-resolution-guide/)
