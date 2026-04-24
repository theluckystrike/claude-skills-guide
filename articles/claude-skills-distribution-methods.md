---
title: "Claude Skills Distribution (2026)"
description: "Detailed comparison of three SKILL.md distribution methods including setup steps, tradeoffs, and which to use for teams of 5, 50, and 500 people."
permalink: /claude-skills-distribution-methods/
categories: [skills, 2026]
tags: [claude-code, claude-skills, distribution, plugins, enterprise]
last_updated: 2026-04-19
---

## The Specific Situation

Your organization has 200 developers across 15 repositories. You need to distribute a code review skill to all of them. Some teams want the ability to customize it for their specific codebase. Others want a single standard enforced from the top. You have three distribution methods available -- each solves a different organizational shape.

## Technical Foundation

Claude Code discovers skills from four scope levels. Each level maps to a distribution method:

- **Project scope** (`.claude/skills/`): Distributed via git, specific to one repository
- **Personal scope** (`~/.claude/skills/`): Not distributed, per-developer only
- **Plugin scope** (`<plugin>/skills/`): Distributed via plugin installation, cross-project
- **Enterprise scope** (managed settings): Distributed via MDM/Ansible, organization-wide

Precedence is enterprise > personal > project. Plugin skills use separate namespacing (`plugin-name:skill-name`), so they coexist without precedence conflicts.

## The Working SKILL.md

A code review skill designed for distribution:

```yaml
---
name: code-review
description: >
  Review code changes for quality, security, and team conventions.
  Use when the user says "review this", "check my code", or
  "code review".
allowed-tools: Read Grep Glob
---

# Code Review

Review the specified changes for:

1. **Correctness**: Logic errors, off-by-one, null handling
2. **Security**: Hardcoded secrets, unvalidated input, SQL injection
3. **Conventions**: Naming, file placement, import order per CLAUDE.md
4. **Tests**: New logic paths have corresponding test coverage

## Output Format

For each issue found:
```
[SEVERITY] file:line - description
  Suggested fix: ...
```

Severity levels: BLOCK (must fix), WARN (should fix), NOTE (consider)
```

## Method 1: Git (Project-Level)

**Setup time**: 2 minutes
**Scope**: Single repository
**Team size**: 2-50 developers

Place the skill in the repository:

```bash
mkdir -p .claude/skills/code-review
# Write SKILL.md
git add .claude/skills/code-review/SKILL.md
git commit -m "feat: add code-review skill"
git push
```

**How developers get it**: `git pull`. The skill activates immediately. If `.claude/skills/` did not exist before, they restart Claude Code once.

**Customization**: Teams can modify the skill in their repository. Changes go through normal code review via pull requests.

**Limitations**: Must be added to each repository separately. No centralized update mechanism -- each repo has its own copy.

## Method 2: Plugin Distribution

**Setup time**: 15 minutes
**Scope**: Cross-repository, opt-in
**Team size**: 10-200 developers

Create a plugin repository:

```
claude-team-skills-plugin/
├── skills/
│   └── code-review/
│       ├── SKILL.md
│       ├── references/
│       │   └── security-checklist.md
│       └── templates/
│           └── review-output.md
└── README.md
```

**How developers get it**: Configure the plugin in their Claude Code settings. The skill appears as `claude-team-skills-plugin:code-review`.

**Customization**: Plugin skills are read-only for consumers. The plugin maintainer controls updates. Teams can still create a project-level `code-review` skill that coexists because plugin skills are namespaced.

**Central updates**: Push to the plugin repository. Developers get updates automatically on their next Claude Code session start.

## Method 3: Enterprise Managed Settings

**Setup time**: 30-60 minutes (initial infrastructure setup)
**Scope**: All users in the organization
**Team size**: 50-5000+ developers

Deploy a managed CLAUDE.md file system-wide:

- **macOS**: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- **Linux**: `/etc/claude-code/CLAUDE.md`
- **Windows**: `C:\Program Files\ClaudeCode\CLAUDE.md`

Deployment tools: Jamf, Intune, SCCM, Ansible, Chef, Puppet.

**How developers get it**: Automatically present on every managed device. No opt-in required.

**Customization**: None for individual developers. Managed settings cannot be overridden or excluded.

**Central updates**: Push via MDM or configuration management tool. Takes effect on next Claude Code session start.

## Decision Matrix

| Factor | Git | Plugin | Managed |
|--------|-----|--------|---------|
| Setup effort | Low | Medium | High |
| Per-repo customization | Yes | No | No |
| Central updates | No | Yes | Yes |
| Override by users | Yes (personal scope) | No (namespaced) | No (top precedence) |
| Requires IT/DevOps | No | No | Yes |
| Multi-repo | Manual per repo | Automatic | Automatic |
| Compliance enforcement | No | No | Yes |

## Common Problems and Fixes

**Plugin skill conflicts with project skill**: They cannot conflict. Plugin skills are namespaced as `plugin-name:skill-name`. A project skill named `code-review` and a plugin skill at `my-plugin:code-review` coexist.

**Managed settings too restrictive**: Managed settings override everything but cannot be selectively disabled. For guidelines that should be customizable, use plugin distribution instead.

**Git distribution gets out of sync**: Each repo has its own copy of the skill. When the standard changes, every repo must be updated. Consider scripting this: a CI job that opens PRs to all repos with the updated skill.

**Developers override with personal skills**: Personal scope has higher precedence than project. If a developer creates `~/.claude/skills/code-review/SKILL.md`, it shadows the project version. Establish team naming conventions where personal skills use a `my-` prefix.

## Production Gotchas

There is no skill analytics or usage tracking built into Claude Code. You cannot see which developers use a distributed skill, how often it triggers, or whether it produces good results. Build feedback loops through code review conversations, not through telemetry.

Plugin distribution has no versioning mechanism. When you update a plugin's skill, all users get the new version on their next session. There is no way to pin a specific version. For gradual rollouts, maintain two plugin versions (e.g., `team-skills-v1` and `team-skills-v2`) and migrate teams incrementally.

The `--add-dir` flag can grant access to additional directories. If pointed at a directory containing `.claude/skills/`, those skills are loaded automatically. This can be used as an informal distribution method for cross-project skills without setting up a formal plugin.

## Checklist

- [ ] Chosen distribution method matches team size and governance needs
- [ ] Plugin skills tested across at least two different projects
- [ ] Managed settings validated on all target OS platforms
- [ ] Update workflow documented (who updates, how, and when)
- [ ] Naming conventions established to prevent personal/project collisions

## Related Guides

- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
- [Publishing Claude Skills to GitHub](/publishing-claude-skills-to-github/)
- [Claude Skills Library Pattern for Orgs](/claude-skills-library-pattern-for-orgs/)
