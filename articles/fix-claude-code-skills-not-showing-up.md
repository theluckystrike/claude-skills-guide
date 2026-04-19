---
title: "Fix Claude Code Skills Not Showing in the Slash Menu — 2026"
description: "Troubleshoot skills that exist on disk but do not appear in Claude Code's / menu due to discovery, scope, visibility, or description budget issues."
permalink: /fix-claude-code-skills-not-showing-up/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, error, not-showing, menu, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You created a SKILL.md file at `.claude/skills/generate-tests/SKILL.md`. You type `/` in Claude Code and scroll through the menu. Your skill is not there. The file exists. The YAML looks correct. But it is invisible. There are five reasons this happens, and they are all fixable.

## Technical Foundation

Claude Code builds the `/` menu from all discovered skills across all scopes (personal, project, plugin, enterprise). Each skill appears with its `name` and `description`. Two settings control visibility:

- `user-invocable: false` hides the skill from the `/` menu entirely (Claude can still auto-invoke it)
- `disable-model-invocation: true` keeps the skill in the `/` menu but prevents Claude from auto-triggering it

The description budget for all skills scales at 1% of the context window, with a fallback of 8,000 characters. If you have many skills, some descriptions may be truncated or dropped entirely.

## The Working SKILL.md

A properly configured skill that will always appear in the menu:

```yaml
---
name: generate-tests
description: >
  Generate unit tests for the specified file. Use when the user
  says "write tests", "add test coverage", or "test this file".
user-invocable: true
---

# Generate Tests

Write unit tests for $ARGUMENTS.

1. Read the source file
2. Identify exported functions and their types
3. Generate test cases covering happy path and edge cases
4. Write test file to __tests__/ directory
```

Key: `user-invocable` defaults to `true`. If your skill has `user-invocable: false`, it is intentionally hidden from the menu.

## Cause 1: user-invocable Set to false

```yaml
# This skill is intentionally hidden from / menu:
---
name: api-guidelines
user-invocable: false
description: API design guidelines for this codebase
---
```

When `user-invocable: false`, the skill is background knowledge. Claude loads it automatically when relevant, but users cannot invoke it with `/api-guidelines`.

Fix: Remove `user-invocable: false` or set it to `true`.

## Cause 2: Skill Directory Not Discovered

Claude Code discovers skills from specific paths. If the file is not in the right location, it is invisible.

```bash
# Verify skill exists at the correct path
ls .claude/skills/generate-tests/SKILL.md    # Project scope
ls ~/.claude/skills/generate-tests/SKILL.md  # Personal scope
```

Common path mistakes:
- File named `skill.md` (lowercase) -- must be `SKILL.md`
- File at `.claude/skills/SKILL.md` (no subdirectory)
- File at `.claude/skill/generate-tests/SKILL.md` (singular "skill")

Fix: Ensure the path follows `<scope>/skills/<name>/SKILL.md` exactly.

## Cause 3: New Directory Not Detected

If you created `.claude/skills/` for the first time during the current session, the file watcher was never initialized for that path.

Fix: Restart Claude Code. Subsequent additions to the existing directory are detected live.

## Cause 4: Description Budget Exhausted

All skill descriptions share a character budget: 1% of context window, fallback 8,000 characters. Each entry is capped at 1,536 characters. If you have 20+ skills with long descriptions, later skills may be dropped.

Diagnostic: Ask Claude "What skills are available?" If some skills are missing from the response, the budget may be exhausted.

Fix: Shorten descriptions. Front-load trigger phrases. Set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable to increase the budget.

```bash
# Increase the description budget
export SLASH_COMMAND_TOOL_CHAR_BUDGET=16000
```

## Cause 5: Higher-Precedence Skill Shadowing

If a personal skill has the same name as a project skill, the personal version appears in the menu instead. The project version is completely hidden.

Precedence: enterprise > personal > project.

```bash
# Check for shadowing
ls ~/.claude/skills/generate-tests/SKILL.md    # Personal (wins)
ls .claude/skills/generate-tests/SKILL.md       # Project (hidden)
```

Fix: Rename one of the conflicting skills. Use a `my-` prefix for personal skills.

## Diagnostic Flowchart

```
Skill not in / menu?
│
├─ Does SKILL.md exist at correct path?
│  NO → Create at .claude/skills/<name>/SKILL.md
│
├─ Was .claude/skills/ created this session?
│  YES → Restart Claude Code
│
├─ Does frontmatter have user-invocable: false?
│  YES → Remove it or set to true
│
├─ Does a personal/enterprise skill have the same name?
│  YES → Rename one of them
│
├─ Do you have 20+ skills with long descriptions?
│  YES → Shorten descriptions or increase budget
│
└─ Ask "What skills are available?"
   └─ If skill listed there but not in / menu → likely a display issue
```

## Common Problems and Fixes

**Skill shows in "What skills are available?" but not in / menu**: The skill list and the `/` autocomplete menu use the same discovery mechanism. If the skill appears in one but not the other, try typing the full name after `/` instead of scrolling.

**Skill appears intermittently**: In monorepo setups, nested `.claude/skills/` directories appear only when Claude works with files in that subdirectory. The skill disappears from the menu when Claude is working in a different package.

**Plugin skills missing**: Plugin skills appear with their namespace prefix. Look for `plugin-name:skill-name` in the menu, not just `skill-name`.

**All skills missing**: Check if the Skill tool is denied in `/permissions`. A deny on `Skill` disables all skills entirely.

## Production Gotchas

The `/` menu may lag slightly behind file system changes. If you just created a skill and it does not appear, wait 2-3 seconds and try again. The file watcher has a small debounce period.

Atomic file saves (common in VS Code and vim) write to a temp file and rename. Most file watchers handle this correctly, but on some file systems or network drives, the rename event may be missed. If edits are not detected, delete the file and recreate it.

The description budget is per-session. If you have many skills loaded from multiple scopes and added directories, the budget is shared across all of them. In large setups, personal skills (higher precedence) get budget priority over project skills.

## Checklist

- [ ] SKILL.md at correct path: `<scope>/skills/<name>/SKILL.md`
- [ ] File named `SKILL.md` (uppercase, exact)
- [ ] `user-invocable` not set to `false` (unless intentional)
- [ ] No naming conflict with higher-precedence scope
- [ ] Claude Code restarted if skills directory was newly created

## Related Guides

- [Fix Unknown Skill Error in Claude Code](/fix-unknown-skill-error-claude-code/)
- [Fix Claude Not Finding Skills Directory](/fix-claude-not-finding-skills-directory/)
- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
