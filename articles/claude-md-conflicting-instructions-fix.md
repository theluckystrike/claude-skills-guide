---
title: "Fix Conflicting CLAUDE.md Instructions"
description: "When CLAUDE.md files contradict each other, Claude picks arbitrarily. This guide shows how to find conflicts, understand loading order, and resolve them."
permalink: /claude-md-conflicting-instructions-fix/
render_with_liquid: false
categories: [claude-md, fixes]
tags: [claude-md, conflicting, instructions, fix, loading-order]
last_updated: 2026-04-19
---

## How Conflicting Instructions Manifest

You write "use 2-space indentation" in your CLAUDE.md. Claude generates code with 4-space indentation. You check your CLAUDE.md -- the rule is there. You add it again, more emphatically. Claude still uses 4 spaces sometimes and 2 spaces other times.

The problem is not that Claude ignores your CLAUDE.md. The problem is that another instruction file says something different, and Claude picks between them unpredictably. All CLAUDE.md files are concatenated into a single context, and contradictions produce arbitrary behavior.

## Step 1: List All Loaded Files

Run `/memory` in Claude Code. This shows every instruction source currently loaded:

```
Loaded instruction files:
  /Library/Application Support/ClaudeCode/CLAUDE.md  (managed)
  ~/.claude/CLAUDE.md                                 (user)
  ~/.claude/rules/formatting.md                       (user rule)
  /project/CLAUDE.md                                  (project)
  /project/.claude/rules/typescript.md                (project rule)
  /project/CLAUDE.local.md                            (personal)
```

Any of these files could contain a conflicting instruction. The more files loaded, the more likely a conflict exists.

## Step 2: Search for Conflicting Topics

Pick the rule Claude is not following and search for it across all loaded files:

```bash
# Search across all instruction sources
grep -rn "indent" \
  CLAUDE.md \
  CLAUDE.local.md \
  .claude/rules/ \
  ~/.claude/CLAUDE.md \
  ~/.claude/rules/ \
  2>/dev/null

# Example output revealing the conflict:
# ~/.claude/CLAUDE.md:5:    - Use 4-space indentation
# ./CLAUDE.md:12:           - Use 2-space indentation
```

Found it. Your user-level CLAUDE.md says 4 spaces, your project CLAUDE.md says 2 spaces. Claude sees both and picks one.

## Step 3: Understand the Loading Priority

When instructions conflict, the later-loaded file wins:

```
Priority (lowest to highest):
1. Managed CLAUDE.md (OS-level)       ← lowest priority
2. ~/.claude/CLAUDE.md (user)
3. ~/.claude/rules/ (user rules)
4. ./CLAUDE.md (project)
5. ./.claude/rules/ (project rules)
6. ./CLAUDE.local.md (personal)       ← highest priority
```

In the indentation example, the project CLAUDE.md (priority 4) should win over the user CLAUDE.md (priority 2). But Claude's adherence to loading priority is not perfect -- it can be influenced by instruction phrasing, position in file, and context window pressure.

## Step 4: Resolve the Conflict

Three resolution strategies:

### Remove the Duplicate
The cleanest fix. Remove the lower-priority instruction entirely:

```markdown
# ~/.claude/CLAUDE.md — remove the indentation line
# Let each project define its own indentation
```

### Make Instructions Non-Overlapping
If both files need to address indentation, make them apply to different scopes:

```markdown
# ~/.claude/CLAUDE.md
- Use 4-space indentation for Python files

# ./CLAUDE.md (TypeScript project)
- Use 2-space indentation for TypeScript files
```

Better yet, use path-specific rules:

```markdown
# .claude/rules/python.md
---
paths: ["**/*.py"]
---
- Use 4-space indentation
```

```markdown
# .claude/rules/typescript.md
---
paths: ["**/*.ts"]
---
- Use 2-space indentation
```

Path-specific rules cannot conflict with each other because they load for different file types.

### Override in CLAUDE.local.md
If you need different behavior than the team standard for your local workflow:

```markdown
# CLAUDE.local.md
- Use tabs for indentation (my editor converts to spaces on save)
```

CLAUDE.local.md has the highest priority and overrides everything else.

## Common Conflict Patterns

| Conflict | Typical cause | Fix |
|---|---|---|
| Formatting (tabs/spaces/semis) | User vs project CLAUDE.md | Remove from user, define per-project |
| Error handling (throw vs Result) | Old rule not removed after migration | Remove outdated rule |
| Naming (camelCase vs snake_case) | Multi-language project | Use path-specific rules per language |
| Testing (Jest vs Vitest) | Tool migration incomplete | Remove old tool references |
| Imports (sorted vs unsorted) | Contradicting linter config and CLAUDE.md | Align CLAUDE.md with linter config |

## Prevention

1. **One topic, one location.** Never define the same rule in multiple files.
2. **Use path-specific rules** for language or file-type conventions.
3. **Review CLAUDE.md changes in PRs** -- reviewers catch contradictions.
4. **Run `/memory` monthly** and scan for overlapping topics.
5. **Keep each file under 200 lines** -- shorter files are easier to audit.

## Using /memory for Regular Audits

Make conflict checking part of your workflow. At the start of each session, run `/memory` and quickly scan the loaded files list. Check for unexpected files -- a rules file you forgot about, a user-level CLAUDE.md that sets conflicting preferences, or a managed policy from your IT department that overrides your project settings.

If you find a file you do not recognize, read it to understand what instructions it adds. Managed CLAUDE.md files (deployed by your organization) cannot be excluded, so you may need to align your project rules with organizational policy rather than the other way around.

## Conflict-Free Architecture

The ideal CLAUDE.md setup has zero overlap between files:

```
Root CLAUDE.md          → project identity, build commands, architecture rules
.claude/rules/api.md    → API-specific rules (paths: src/routes/**)
.claude/rules/test.md   → testing rules (paths: **/*.test.ts)
.claude/rules/db.md     → database rules (paths: src/repositories/**)
CLAUDE.local.md         → personal preferences only (debug settings, local URLs)
~/.claude/CLAUDE.md     → cross-project preferences (commit format, indentation)
```

Each file owns a distinct domain. No topic appears in more than one file. Path-specific rules cannot conflict because they load for different file types. This structure eliminates conflicts by design rather than resolution.

For the complete loading order and concatenation mechanics, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For team strategies that prevent conflicts, see the [conflict resolution guide](/claude-md-conflict-resolution/). For optimizing file length, see the [context window optimization guide](/claude-md-too-long-fix/).

## Related Articles

- [Why Does Claude Code Sometimes Ignore My — Developer Guide](/why-does-claude-code-sometimes-ignore-my-instructions/)
