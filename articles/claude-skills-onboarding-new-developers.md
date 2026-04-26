---
layout: default
title: "Onboarding New Developers to Your (2026)"
description: "Step-by-step onboarding checklist for new team members covering skill discovery, naming conventions, personal vs project scope, and common pitfalls."
permalink: /claude-skills-onboarding-new-developers/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, onboarding, team, documentation]
last_updated: 2026-04-19
---

## The Specific Situation

A new developer joins your team on Monday. The codebase has 8 custom skills. The developer does not know they exist, creates a personal skill with a conflicting name, and wonders why Claude gives them different output than their teammates. By Wednesday, they have disabled skills entirely because "they are unpredictable." This onboarding guide prevents that first-week frustration.

## Technical Foundation

Claude Code discovers skills automatically from `.claude/skills/` in the project repository. When a new developer clones the repo and starts Claude Code, all project-level skills are immediately available. No installation, no configuration, no opt-in.

Personal skills at `~/.claude/skills/` are per-developer. They override project skills with the same name (personal > project precedence). New developers start with no personal skills, so they see exactly the project skills -- which is the ideal starting state.

The command "What skills are available?" in any Claude Code session lists all discovered skills with descriptions. This is the single most useful command for new team members.

## The Working SKILL.md (Onboarding Skill)

Create a skill that introduces new developers to the team's skill setup:

```yaml
---
name: onboarding
description: >
  Show the team's Claude Code skills setup, conventions, and getting
  started guide. Use when the user says "onboarding", "getting started",
  "new developer setup", or "how do skills work here".
---

# Team Onboarding: Claude Code Skills

Welcome to the team. This project uses Claude Code skills to
standardize common workflows.

## Available Skills

Run "What skills are available?" to see all active skills.

## Key Skills

| Skill | What It Does | Invocation |
|-------|-------------|------------|
| /deploy-staging | Deploy to staging | Manual only |
| /deploy-prod | Deploy to production | Manual only |
| /generate-tests | Write tests for a file | Auto or /generate-tests |
| /code-review | Review current changes | /code-review |
| /api-conventions | API design standards | Auto when writing APIs |

## Rules

1. **Never create personal skills with names matching project skills**.
   Personal skills override project skills. Use a `my-` prefix for
   personal skills.

2. **Side-effect skills are manual-only**. Skills that deploy, commit,
   or modify external state require explicit `/skill-name` invocation.

3. **Check the /menu before creating a new skill**. Your idea may
   already exist.

## Getting Help

- Ask Claude: "What skills are available?"
- Read skill source: `.claude/skills/<name>/SKILL.md`
- Team channel: #claude-skills in Slack
```

## The Onboarding Checklist

### Day 1: Discovery

1. Clone the repository and start Claude Code
2. Type "What skills are available?" to see all project skills
3. Read the CLAUDE.md file for project conventions
4. Invoke each skill once to see what it does:
   - `/onboarding` (this guide)
   - `/generate-tests src/utils/helpers.ts`
   - `/code-review` (on a branch with changes)

### Day 2: Understanding Scope

Explain the skill scope system:

```
Enterprise (highest priority) - managed by IT
  ↓
Personal (~/.claude/skills/) - just you, all projects
  ↓
Project (.claude/skills/) - team, this project only
  ↓
Plugin (plugin/skills/) - namespaced, no conflicts
```

Key rule: **personal skills override project skills**. If a new developer creates `~/.claude/skills/deploy/SKILL.md`, they will never see the project's deploy skill. This is the most common onboarding mistake.

### Day 3: Creating Personal Skills

Teach the naming convention:

```bash
# Personal skills use my- prefix
mkdir -p ~/.claude/skills/my-snippets
# Write SKILL.md for personal workflow
```

Show them the difference between auto-invocable skills and manual skills. Skills with `disable-model-invocation: true` only fire on explicit `/name` invocation. All others can auto-trigger based on description matching.

### Day 4: Contributing Skills

Walk through the skill contribution workflow:

```bash
# Create a branch
git checkout -b add-lint-fix-skill

# Create the skill
mkdir -p .claude/skills/lint-fix
# Write SKILL.md

# Test locally (changes detected live)
# Invoke /lint-fix and verify

# Submit for review
git add .claude/skills/lint-fix/SKILL.md
git commit -m "feat: add lint-fix skill"
gh pr create
```

All skill changes go through PRs for team review.

## Common Problems and Fixes

**New developer cannot see skills**: They need to run Claude Code from the project root (where `.claude/skills/` exists). Running Claude Code from a parent or child directory may not discover the skills.

**Skills produce different output for the new developer**: Check for personal skills: `ls ~/.claude/skills/`. If any personal skill name matches a project skill, the personal version wins.

**Developer overwhelmed by too many skills**: Mark background knowledge skills with `user-invocable: false` to hide them from the `/` menu. They still auto-trigger but do not clutter the interface.

**Developer does not know which skills are manual-only**: Ask Claude "which skills have disable-model-invocation set to true?" or review the frontmatter of each SKILL.md file.

## Production Gotchas

There is no skill documentation generator built into Claude Code. The onboarding skill above manually lists available skills. If the team adds or removes skills, someone must update the onboarding skill too. Consider making this part of the PR checklist for skill changes.

New developers may have Claude Code configured with different permission settings. If their permissions deny the Skill tool entirely (`Deny Skill` in `/permissions`), no skills work. Have them check `/permissions` during onboarding.

The `--add-dir` flag can be used to grant access to a shared skills repository. If your team has a central skills repo, add the install command to the onboarding docs: `claude --add-dir /path/to/team-skills-repo`.

## Checklist

- [ ] New developer ran "What skills are available?" on first day
- [ ] Personal skills directory is empty or uses `my-` prefix convention
- [ ] Developer understands manual-only vs auto-invocable distinction
- [ ] Developer knows skill changes go through PRs
- [ ] Onboarding skill content is up to date with current skill list

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
- [Team SKILL.md Conventions Style Guide](/team-skill-md-conventions-style-guide/)
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/)
