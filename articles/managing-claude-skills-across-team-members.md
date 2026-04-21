---
title: "Managing Claude Skills Across Team Members Without Conflicts — 2026"
description: "Prevent skill collisions between personal, project, and plugin scopes with precedence rules, naming conventions, and discovery debugging."
permalink: /managing-claude-skills-across-team-members/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, team-management, precedence, conflicts]
last_updated: 2026-04-19
---

## The Specific Situation

Your 8-person team shares a `deploy` skill in the project repo. Developer Alice has a personal `deploy` skill at `~/.claude/skills/deploy/SKILL.md` that skips tests (she uses it for hotfixes). Developer Bob installed a plugin that also has a `deploy` skill. When Alice types `/deploy`, she gets her personal version. When Bob types `/deploy`, he gets the project version, but the plugin version shows as `plugin-name:deploy`. Nobody knows who gets what, and a production deploy just ran without tests. We cover this further in [Claude Skills for Travel Booking Platforms — Automate GDS Parsing, Fare Rules, and PNR Validation — 2026](/claude-skills-for-travel-booking-platforms/).

## Technical Foundation

Claude Code resolves skill names using a strict precedence system:

1. **Enterprise** (managed settings) -- highest priority, cannot be overridden
2. **Personal** (`~/.claude/skills/`) -- overrides project
3. **Project** (`.claude/skills/`) -- lowest priority for non-plugin skills
4. **Plugin** (`<plugin>/skills/`) -- separate namespace, no conflict possible

When two skills share the same name at different scopes, the higher-precedence version wins silently. There is no warning, no merge, no notification. The losing skill is completely invisible.

Plugin skills avoid this entirely through namespacing. A plugin skill named `deploy` in the `acme-tools` plugin appears as `acme-tools:deploy`. It never conflicts with a project or personal skill named `deploy`.

## The Working SKILL.md (Audit Skill)

Create a skill that audits skill conflicts across your team:

```yaml
---
name: audit-skills
description: >
  Audit all discoverable skills and report conflicts, duplicates,
  and precedence issues. Use when the user says "check skills",
  "audit skills", or "skill conflicts".
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(ls *) Bash(find *)
---

# Skill Audit

Scan all skill locations and report the current state.

## Steps

1. List personal skills:
   ```bash
   ls ~/.claude/skills/ 2>/dev/null || echo "No personal skills"
   ```

2. List project skills:
   ```bash
   ls .claude/skills/ 2>/dev/null || echo "No project skills"
   ```

3. For each skill name that appears in BOTH personal and project:
   - Flag as CONFLICT
   - Report which version wins (personal)
   - Show the description from each version

4. List all skill names and their effective scope

## Output Format

```
SKILL AUDIT REPORT
==================
Personal skills: [count]
Project skills: [count]

CONFLICTS:
  deploy - personal overrides project
    Personal: "Deploy to prod (skips tests)"
    Project:  "Deploy to prod (runs full test suite)"

NO CONFLICTS:
  code-review - project only
  explain-code - personal only
```
```

## Preventing Conflicts

### Strategy 1: Personal Skill Naming Convention

Establish a rule: personal skills always use a `my-` prefix.

```
~/.claude/skills/my-deploy/SKILL.md    # Personal
.claude/skills/deploy/SKILL.md          # Project (team standard)
```

Now `/deploy` always runs the team version. `/my-deploy` runs the personal version. No collision.

### Strategy 2: Document Skill Ownership

Add a comment in your project CLAUDE.md:

```markdown
## Skills

Project skills in `.claude/skills/`:
- `deploy` - Production deploy (DO NOT override with personal skill)
- `code-review` - Team code review standard
- `generate-tests` - Test generation with team patterns

Personal skills should use `my-` prefix to avoid conflicts.
```

### Strategy 3: Plugin Distribution for Standards

Move critical team skills to a plugin. Plugin skills cannot be overridden by personal or project skills because they live in a separate namespace. The tradeoff: developers must type `plugin-name:skill-name` instead of just `skill-name`.

## Common Problems and Fixes

**Developer has personal skill overriding team standard**: Run `ls ~/.claude/skills/` on their machine. If a conflicting skill exists, rename it with a `my-` prefix or delete it.

**Skill works for some developers but not others**: Check personal skill directories. Different developers may have different personal skills with the same name, producing different behavior.

**New skill not appearing**: If `.claude/skills/` was just created for the first time, Claude Code requires a restart. Subsequent skill additions to an existing directory are detected live.

**Skill appears in one package but not another (monorepo)**: Nested `.claude/skills/` directories in subdirectories are only discovered when Claude works with files in that subdirectory. A skill at `packages/frontend/.claude/skills/lint/` only appears when editing frontend code.

**Cannot determine which version of a skill is active**: Ask Claude "What skills are available?" The response lists all discovered skills. The active version for any name is the highest-precedence one.

## Production Gotchas

There is no `--list-skills` CLI flag or audit log. The only way to see active skills is to ask Claude within a session. This makes debugging cross-team issues difficult. The audit skill above partially solves this by scanning the filesystem directly.

Enterprise-managed skills via managed settings cannot be excluded or overridden by any developer. If IT deploys a `deploy` skill via managed settings, every developer gets that exact version regardless of their personal or project skills with the same name.

The `claudeMdExcludes` setting works for CLAUDE.md files but does NOT apply to skills. There is no equivalent `skillExcludes` setting. All discovered skills in all scopes are active. Learn more in [Polyglot Claude Skills — Building Skills That Work Across TypeScript, Python, Rust, and Go — 2026](/polyglot-claude-skills-multi-language/).

When a legacy command exists at `.claude/commands/deploy.md` and a skill exists at `.claude/skills/deploy/SKILL.md`, the skill takes precedence. The command file is ignored. Migrate or delete the command file to avoid confusion.

## Checklist

- [ ] Team naming convention documented (personal skills use `my-` prefix)
- [ ] No personal skills conflict with project skills
- [ ] Critical team skills listed in project CLAUDE.md
- [ ] Audit skill or manual check run before onboarding new members
- [ ] Legacy `.claude/commands/` files migrated or removed

## Related Guides

- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/)
- [Fix Skill Name Already in Use Error](/fix-skill-name-already-in-use-error/)
