---
title: "Fix Skill Name Already in Use (2026)"
description: "Diagnose and fix skill name collisions between personal, project, plugin, and legacy command scopes with specific resolution steps."
permalink: /fix-skill-name-already-in-use-error/
categories: [skills, 2026]
tags: [claude-code, claude-skills, naming-conflict, precedence, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You create a project-level skill called `deploy`. When you invoke `/deploy`, you get behavior you did not write. The description does not match your SKILL.md. The allowed-tools are different. Another version of `deploy` exists somewhere -- personal scope, a plugin, or a legacy command file -- and it is winning the precedence battle. You need to find and resolve the conflict.

## Technical Foundation

Claude Code resolves skill names using strict precedence. When multiple skills share the same name, the highest-precedence version wins silently. There is no collision warning.

Precedence order:
1. **Enterprise** (managed settings) -- always wins
2. **Personal** (`~/.claude/skills/`) -- overrides project
3. **Project** (`.claude/skills/`) -- lowest for non-plugin skills

Plugin skills use `plugin-name:skill-name` namespacing and never conflict with other scopes.

Legacy commands at `.claude/commands/deploy.md` conflict with skills at `.claude/skills/deploy/SKILL.md`. When both exist, the skill wins.

## The Working SKILL.md

A properly scoped project skill with a unique name:

```yaml
---
name: deploy-prod
description: >
  Deploy the application to production. Runs tests, builds, and
  pushes to the production target.
disable-model-invocation: true
argument-hint: "[branch]"
allowed-tools: Bash(npm run build *) Bash(npm test *) Bash(git push *)
---

# Deploy to Production

Deploy $ARGUMENTS to production:

1. Run full test suite: `npm test`
2. Build production artifacts: `npm run build`
3. Push to production: `git push production $ARGUMENTS`
4. Verify health check
```

Using `deploy-prod` instead of `deploy` avoids collision with personal deploy skills that team members may have created.

## Finding the Conflicting Skill

Run this diagnostic sequence:

```bash
# 1. Check personal skills
ls ~/.claude/skills/deploy/SKILL.md 2>/dev/null && \
  echo "FOUND: Personal deploy skill"

# 2. Check project skills
ls .claude/skills/deploy/SKILL.md 2>/dev/null && \
  echo "FOUND: Project deploy skill"

# 3. Check legacy commands
ls .claude/commands/deploy.md 2>/dev/null && \
  echo "FOUND: Legacy command deploy.md"

# 4. Check for all skills with "deploy" in the name
find ~/.claude/skills .claude/skills -name "SKILL.md" \
  -path "*/deploy*" 2>/dev/null
```

In Claude Code, ask: "What skills are available? Show me the full details for the deploy skill." The response shows which version Claude is using.

## Resolution Strategies

### Strategy 1: Rename the Lower-Priority Skill

If your project skill conflicts with a personal skill:

```bash
# Rename the personal skill
mv ~/.claude/skills/deploy ~/.claude/skills/my-deploy
```

Now `/deploy` uses the project version and `/my-deploy` uses the personal version.

### Strategy 2: Remove the Legacy Command

If `.claude/commands/deploy.md` conflicts with `.claude/skills/deploy/SKILL.md`:

```bash
# The skill wins, but the command file causes confusion
# Migrate or remove the command
rm .claude/commands/deploy.md
# or
mv .claude/commands/deploy.md .claude/commands/deploy.md.bak
```

Skills supersede commands. The command file is ignored when a skill with the same name exists, but keeping both creates maintenance confusion.

### Strategy 3: Use Plugin Namespacing

Move the skill to a plugin to avoid all precedence conflicts:

```
my-plugin/
└── skills/
    └── deploy/
        └── SKILL.md
```

The skill becomes `my-plugin:deploy`. No conflict possible with personal or project skills named `deploy`.

### Strategy 4: Team Naming Convention

Establish a rule: specific names over generic.

```
BAD:  deploy, test, lint, review, fix
GOOD: deploy-prod, deploy-staging, run-unit-tests,
      lint-typescript, review-pr, fix-eslint
```

Generic names are the most likely to collide. Specific names describe what the skill does and naturally avoid conflicts.

## Common Problems and Fixes

**Skill behavior changes between developers**: Developer A has a personal `deploy` skill. Developer B does not. They get different behavior from `/deploy`. Fix: Standardize on project-level skills and use the `my-` prefix convention for personal overrides.

**Deleted skill still appears**: Claude Code caches discovered skills within a session. After deleting a skill file, the cache may retain it briefly. Fix: Wait a few seconds for the file watcher to detect the deletion, or restart Claude Code.

**Cannot override enterprise skill**: Enterprise skills (managed settings) have the highest precedence and cannot be overridden by personal or project skills. This is by design. Contact your IT team to modify the enterprise skill.

**Plugin skill has same base name as project skill**: No conflict. Plugin skills are namespaced. `my-plugin:deploy` and `.claude/skills/deploy` coexist. But if a user types `/deploy`, they get the project version (or personal if it exists). To invoke the plugin version, type `/my-plugin:deploy`.

## Production Gotchas

When a personal skill overrides a project skill, the developer may not realize they are running different instructions than their teammates. The `/` menu shows one `deploy` skill -- but each developer may see a different version. There is no visual indicator of which scope a skill comes from in the menu.

The `name` field defaults to the directory name if omitted. If your directory is named `deploy` and you omit the `name` field, the skill name is `deploy`. This means directory naming matters for conflict resolution even when frontmatter is minimal.

In monorepos, nested skills can conflict with root-level skills. A skill at `.claude/skills/lint/SKILL.md` and another at `packages/frontend/.claude/skills/lint/SKILL.md` both have the name `lint`. The nested one is only discovered when working in the frontend package. When it is discovered, it does not override the root skill -- both may coexist, causing confusion about which one triggers.

## Checklist

- [ ] Checked all three scopes for naming conflicts (personal, project, enterprise)
- [ ] Checked for legacy `.claude/commands/` with same name
- [ ] Used specific verb-noun names to prevent future conflicts
- [ ] Team naming convention documented and communicated
- [ ] Personal skills use `my-` prefix

## Related Guides

- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/)
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/)
- [Fix Unknown Skill Error in Claude Code](/fix-unknown-skill-error-claude-code/)
