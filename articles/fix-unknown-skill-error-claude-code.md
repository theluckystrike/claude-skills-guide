---
title: "Fix Unknown Skill Error in Claude Code: All Causes and Solutions — 2026"
description: "Resolve the 'unknown skill' error when Claude Code cannot find your SKILL.md file due to path, naming, directory structure, or discovery issues."
permalink: /fix-unknown-skill-error-claude-code/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, error, unknown-skill, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You type `/my-skill` in Claude Code and get an error indicating the skill is unknown or not found. You can see the SKILL.md file on disk. The path looks correct. But Claude Code cannot find it. This error has six distinct causes, each with a different fix.

## Technical Foundation

Claude Code discovers skills by scanning specific directories for SKILL.md files. Discovery happens at three scopes:

- Personal: `~/.claude/skills/<skill-name>/SKILL.md`
- Project: `.claude/skills/<skill-name>/SKILL.md`
- Plugin: `<plugin>/skills/<skill-name>/SKILL.md`

The scan happens at session start and continues via file system watchers during the session. If a SKILL.md exists but is not in one of these exact paths, Claude Code will never find it.

## The Working SKILL.md

Here is the correct structure that Claude Code will always discover:

```yaml
---
name: my-skill
description: >
  Perform a specific task. Use when the user says "run my skill"
  or "execute my skill".
---

# My Skill

Instructions for Claude when this skill is invoked.

1. Step one
2. Step two
3. Step three
```

The file MUST be at one of these paths:

```
~/.claude/skills/my-skill/SKILL.md          # Personal
.claude/skills/my-skill/SKILL.md             # Project
<plugin-path>/skills/my-skill/SKILL.md       # Plugin
```

## Cause 1: Wrong Directory Structure

The most common cause. The SKILL.md must be inside a named subdirectory, not directly in the skills folder.

```bash
# WRONG - file directly in skills/
.claude/skills/SKILL.md

# WRONG - no SKILL.md file
.claude/skills/my-skill/my-skill.md

# WRONG - nested too deep
.claude/skills/category/my-skill/SKILL.md

# CORRECT
.claude/skills/my-skill/SKILL.md
```

Fix: Move the file to `.claude/skills/<skill-name>/SKILL.md`.

## Cause 2: New Skills Directory Created Mid-Session

Claude Code watches existing skill directories for changes. But if you create the `.claude/skills/` directory for the first time during an active session, the watcher was never started for that path.

```bash
# This works (directory existed before session start):
mkdir .claude/skills/new-skill  # Adding to existing skills/
# Edit SKILL.md -> detected immediately

# This does NOT work (creating skills/ for first time):
mkdir -p .claude/skills/my-skill  # New top-level directory
# SKILL.md is NOT detected until restart
```

Fix: Restart Claude Code after creating a new top-level `.claude/skills/` directory.

## Cause 3: Name Mismatch

The `name` field in frontmatter determines what you type to invoke the skill. If it differs from the directory name, use the frontmatter name.

```yaml
# Directory: .claude/skills/my-tool/SKILL.md
---
name: helper-tool
---
```

This skill is invoked as `/helper-tool`, not `/my-tool`. If you type `/my-tool`, it fails.

Fix: Either match the `name` field to the directory name or invoke using the frontmatter name.

## Cause 4: Invalid Name Characters

The `name` field only accepts lowercase letters, numbers, and hyphens. Max 64 characters.

```yaml
# INVALID names (will cause discovery issues):
name: My Skill        # uppercase, spaces
name: my_skill        # underscores
name: my.skill        # dots
name: mySkill123!     # uppercase, special chars

# VALID names:
name: my-skill
name: my-skill-123
name: deploy-v2
```

Fix: Rename using only lowercase letters, numbers, and hyphens.

## Cause 5: Skill Tool Denied in Permissions

If the Skill tool is denied in `/permissions`, all skills become invisible.

Fix: Check your permissions. Run `/permissions` and look for deny rules on `Skill`. Remove the deny rule or add a specific allow rule: `Skill(my-skill)`.

Specific skill denials also apply:
- `Deny Skill(deploy)` blocks only the deploy skill
- `Deny Skill(deploy *)` blocks the deploy skill and any arguments
- `Deny Skill` blocks ALL skills

## Cause 6: Working Directory Mismatch

Project skills are discovered relative to the working directory. If Claude Code was started from `/home/user/` but the skill is in `/home/user/project/.claude/skills/`, Claude may not find it unless it navigates to the project directory.

Fix: Start Claude Code from the project root where `.claude/skills/` exists.

## Diagnostic Steps

Run this sequence to identify the cause:

```bash
# 1. Verify the file exists at the correct path
ls -la .claude/skills/*/SKILL.md
ls -la ~/.claude/skills/*/SKILL.md

# 2. Verify the file is valid YAML
head -20 .claude/skills/my-skill/SKILL.md

# 3. Check if skills directory existed before this session
# (if you just created it, restart is needed)

# 4. Ask Claude
# Type: "What skills are available?"
# If the skill is not listed, discovery failed
```

## Common Problems and Fixes

**Skill appears in "What skills are available?" but /name fails**: The `name` field may differ from what you are typing. Check the exact name in the listing.

**Skill found on one machine but not another**: Personal skills (`~/.claude/skills/`) are per-machine. Project skills (`.claude/skills/`) require `git pull` on the other machine.

**Skill in monorepo subdirectory not found**: Nested skills at `packages/frontend/.claude/skills/` are only discovered when Claude works with files in `packages/frontend/`. They are invisible until Claude reads a file in that directory.

**Plugin skill not found with /name**: Plugin skills use namespace: `plugin-name:skill-name`. Type `/plugin-name:skill-name`, not just `/skill-name`.

## Production Gotchas

The `--add-dir` flag grants file access to additional directories. If that directory contains `.claude/skills/`, those skills are loaded automatically as an exception. But the skills directory must exist in the added directory -- it is not recursive.

There is no `claude --list-skills` CLI command. The only way to verify skill discovery is within a session by asking Claude "What skills are available?" or invoking the skill directly.

If you rename a skill directory while Claude Code is running, the old name becomes invalid immediately, but the new name is detected by the file watcher. No restart needed for renames within an existing skills directory.

## Checklist

- [ ] SKILL.md is at `<scope>/skills/<skill-name>/SKILL.md` exactly
- [ ] `name` field uses only lowercase, numbers, hyphens (max 64 chars)
- [ ] `.claude/skills/` directory existed before session start (or restarted)
- [ ] Skill tool not denied in `/permissions`
- [ ] Claude Code started from the correct working directory

## Related Guides

- [Fix Claude Code Skills Not Showing Up](/fix-claude-code-skills-not-showing-up/)
- [Fix Claude Not Finding Skills Directory](/fix-claude-not-finding-skills-directory/)
- [Build Your First Claude Code Skill](/building-your-first-claude-skill/)
