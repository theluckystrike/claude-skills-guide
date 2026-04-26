---
layout: default
title: "Claude Skill Registry Pattern for Teams (2026)"
description: "Build a skill registry that gives teams centralized discovery, version tracking, and controlled distribution of Claude Code skills across projects."
permalink: /claude-skill-registry-pattern-for-teams/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, team-registry, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

Your engineering team of 20 developers has created 35 Claude Code skills across 8 projects. Nobody knows which skills exist, which are production-ready, or which duplicate functionality. The security team wrote a "dependency-audit" skill in the auth-service repo, and the platform team wrote a nearly identical "dep-scanner" in the gateway repo. Three developers maintain personal skills at `~/.claude/skills/` that never get shared.

A skill registry pattern solves discovery, prevents duplication, tracks versions, and provides controlled distribution through plugins or managed settings.

## Technical Foundation

Claude Code discovers skills from four scopes: enterprise (managed policy), personal (`~/.claude/skills/`), project (`.claude/skills/`), and plugin (`<plugin>/skills/`). Precedence is enterprise > personal > project, with plugin skills namespaced as `plugin-name:skill-name` to avoid conflicts.

For team distribution, two mechanisms exist. First, **plugins**: create a skills directory in a plugin, and any project that enables the plugin gets those skills namespaced under the plugin name. Second, **managed settings**: deploy organization-wide skills through the managed CLAUDE.md or managed skill directories via MDM, Group Policy, or Ansible.

Live change detection means skills can be updated without restarting Claude Code sessions (as long as the top-level skills directory already existed at session start).

## The Working SKILL.md

Create a registry index skill at `.claude/skills/skill-registry/SKILL.md`:

```yaml
---
name: skill-registry
description: >
  Team skill registry. Lists all approved skills, their locations,
  versions, owners, and status. Use when searching for an existing
  skill before creating a new one, or when checking if a skill
  is production-ready. Invoke with: /skill-registry [search-term]
disable-model-invocation: true
---

# Team Skill Registry

## How to Use This Registry
1. Before creating a new skill, search here for existing ones
2. If a matching skill exists, use it or propose improvements
3. New skills must be registered here before team adoption

## Registry Index

### Production Skills (approved for all projects)
| Name | Location | Owner | Version | Description |
|------|----------|-------|---------|-------------|
| code-style | plugin:team-standards | @platform | 2.1.0 | Enforces team coding standards |
| pr-summary | plugin:team-standards | @platform | 1.4.0 | Generates PR descriptions from diff |
| deploy-check | .claude/skills/deploy-check | @devops | 1.2.0 | Pre-deployment validation |
| test-gen | plugin:team-standards | @qa-team | 1.0.3 | Generates unit tests for uncovered functions |
| dep-audit | plugin:team-security | @security | 1.1.0 | Scans dependencies for known CVEs |

### Beta Skills (approved for opt-in testing)
| Name | Location | Owner | Version | Status |
|------|----------|-------|---------|--------|
| perf-review | .claude/skills/perf-review | @platform | 0.9.0 | Needs wider testing |
| db-migration | .claude/skills/db-migration | @data-eng | 0.8.0 | Schema change review |

### Deprecated Skills (do not use)
| Name | Replaced By | Sunset Date |
|------|-------------|-------------|
| dep-scanner | dep-audit | 2026-03-01 |
| old-linter | code-style | 2026-02-15 |

## Registration Template
To register a new skill, add an entry with:
- Name, location (project path or plugin), owner (team/person)
- Version (semver), description (under 100 words)
- Status: draft → beta → production → deprecated
- Required review: at least 1 team member outside the owning team

## Distribution Channels
- **Plugin** (recommended): Package skills in a team plugin repo.
  Skills are namespaced (team-standards:code-style) and version-controlled.
- **Project**: Copy skill to .claude/skills/ in each project.
  Use when skill is project-specific and not reusable.
- **Personal**: ~/.claude/skills/ for personal productivity.
  Never use for team-shared workflows.
- **Managed**: IT-deployed via MDM for org-wide mandates.
  Use for compliance and security skills only.

## Version Convention
- MAJOR: Breaking changes to skill behavior or output format
- MINOR: New features, backward-compatible
- PATCH: Bug fixes, documentation updates
```

Plugin directory structure for team distribution:

```
team-standards-plugin/
  skills/
    code-style/
      SKILL.md
      references/
        eslint-overrides.md
    pr-summary/
      SKILL.md
    test-gen/
      SKILL.md
      scripts/
        coverage-check.sh
```

## Common Problems and Fixes

**Duplicate skills discovered only after conflicts.** Two skills with the same name at different scopes cause confusion. The precedence rule (enterprise > personal > project) resolves which loads, but developers may not realize their personal skill is overriding the project skill. Use unique, descriptive names and check the registry before creating.

**Plugin skill not loading in a project.** Plugins must be explicitly enabled per project. Check that the plugin is listed in the project's Claude Code configuration. Also verify the plugin directory contains a `skills/` subdirectory with proper SKILL.md files.

**Registry becomes stale.** The registry skill is a static markdown file. It does not auto-update when skills are added or removed. Assign registry maintenance to a specific team member or use a CI check that validates registry entries against actual skill directories.

**Version numbers not enforced.** Without tooling, developers forget to bump versions. Add a pre-commit hook that checks if SKILL.md content changed but the version in the registry was not updated. This is a manual process -- there is no built-in version field in Claude Code skill frontmatter.

## Production Gotchas

Managed policy skills (enterprise scope) cannot be excluded or overridden by project skills. This is intentional for compliance. If a managed security-audit skill conflicts with a project-specific audit skill, the managed one wins. Design managed skills to be additive (do not conflict with project conventions) or clearly scoped to compliance-only tasks.

The plugin namespace (`plugin-name:skill-name`) prevents conflicts between plugin and project skills, but it also means users must type the full namespace when manually invoking: `/team-standards:code-style` instead of just `/code-style`. Design plugin skill names to be short enough that the namespaced version remains usable.

## Checklist

- [ ] All team skills registered with owner, version, and status
- [ ] Distribution channel chosen per skill (plugin vs project vs managed)
- [ ] Deprecated skills marked with replacement and sunset date
- [ ] Plugin skills tested for namespace usability
- [ ] Registry review scheduled quarterly to remove stale entries

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- sharing resources across skills
- [Claude Skills for Monorepo Projects](/claude-skills-for-monorepo-projects/) -- skill organization in large codebases
- [Claude Skill Inheritance and Composition](/claude-skill-inheritance-composition/) -- extending team skills in projects

## Related Articles

- [Build a Claude Skills Library for Your Organization — 2026](/claude-skills-library-pattern-for-orgs/)
