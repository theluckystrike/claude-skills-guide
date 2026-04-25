---
layout: default
title: "Claude Skills Versioning (2026)"
description: "Version control strategies for SKILL.md files using git, semantic versioning in frontmatter, and safe rollback patterns for team skills."
permalink: /claude-skills-versioning-strategies/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, versioning, git, version-control]
last_updated: 2026-04-19
---

## The Specific Situation

Your team shares a `code-review` skill via `.claude/skills/code-review/SKILL.md` in the project repository. A developer updates the skill to enforce stricter review criteria. They push to main. Every team member's Claude Code session immediately picks up the change (live change detection). Three developers mid-review suddenly get different output. One of them is demoing to a client. You need a versioning strategy that prevents surprise breaking changes.

## Technical Foundation

Claude Code watches skill directories and detects file changes in real time. When you edit a SKILL.md, the changes take effect within the current session without restarting. This is powerful for iteration but dangerous for shared skills -- any push to the repository instantly changes behavior for everyone.

Skills do not have a built-in versioning system. The `version` field exists in some official Anthropic skills (e.g., `version: 0.1.0` in the skill-development plugin), but it is informational only. Claude does not use it for compatibility checking or version selection.

The practical versioning strategy combines git (for history and rollback) with naming conventions (for parallel versions) and frontmatter metadata (for tracking).

## The Working SKILL.md

Here is a versioned skill with metadata tracking:

```yaml
---
name: code-review
description: >
  Review code changes for quality, security, and consistency.
  Use when the user says "review this code", "check my changes",
  or "code review".
version: 2.1.0
allowed-tools: Read Grep Glob
---

# Code Review Skill v2.1.0

## Changelog
- 2.1.0 (2026-04-19): Added security check for env var leaks
- 2.0.0 (2026-04-01): Rewrote review criteria, breaking change
- 1.0.0 (2026-03-15): Initial version

## Review Checklist

For each changed file, evaluate:

1. **Correctness**: Does the code do what the PR description says?
2. **Edge cases**: Are null/empty/boundary cases handled?
3. **Security**: Check for hardcoded secrets, SQL injection,
   unvalidated input, env vars in client code
4. **Tests**: Are new code paths covered by tests?
5. **Naming**: Do variable and function names describe their purpose?

## Output Format

Provide a structured review with:
- PASS / NEEDS_CHANGES / BLOCK verdict
- Specific file:line references for each issue
- Suggested fix for each issue found
```

## Three Versioning Strategies

### Strategy 1: Git-Based Versioning (Recommended for Teams)

Track skills in version control like any other code:

```bash
# View skill change history
git log --oneline .claude/skills/code-review/SKILL.md

# Rollback to previous version
git checkout HEAD~1 -- .claude/skills/code-review/SKILL.md

# Create a branch for skill changes
git checkout -b update-code-review-skill
# Edit the skill, test, then merge via PR
```

Use pull requests for skill changes. This gives team members a chance to review the new behavior before it goes live. Since Claude detects file changes instantly, the moment the PR merges to main and someone pulls, the new version is active.

### Strategy 2: Named Versions for Parallel Skills

When you need the old and new version to coexist during migration:

```
.claude/skills/
├── code-review/          # Current stable (v2)
│   └── SKILL.md
└── code-review-v3/       # New version being tested
    └── SKILL.md
```

Developers testing v3 invoke `/code-review-v3`. Once validated, rename the directories.

### Strategy 3: Frontmatter Version Tracking

Add `version` to frontmatter for documentation, even though Claude does not enforce it:

```yaml
---
name: code-review
version: 2.1.0
description: Review code changes for quality and security.
---
```

Combine with a changelog section in the skill body so Claude (and developers) can see what changed.

## Common Problems and Fixes

**Breaking change deployed instantly**: Use feature branches and PRs for skill changes. Never edit shared skills directly on main.

**Cannot rollback a bad skill update**: Use `git checkout HEAD~1 -- .claude/skills/skill-name/SKILL.md` to restore the previous version. Claude picks up the change immediately.

**Personal skill overrides project skill**: Personal skills (precedence) always win over project skills. If a developer has a personal `~/.claude/skills/code-review/SKILL.md`, they will never see the project version. Communicate naming conventions to avoid this.

**Skill works differently for different team members**: Check if anyone has personal skills with the same name. Run `ls ~/.claude/skills/` on each developer's machine, or establish a naming convention where personal skills use a `my-` prefix.

## Production Gotchas

Git tracks skill changes, but there is no way to pin a Claude Code session to a specific skill version. If you pull from main mid-session, the skill updates immediately. For critical workflows (deploys, migrations), consider using `disable-model-invocation: true` so the skill only fires when explicitly invoked.

The `version` field in frontmatter is not standardized across the Claude Code ecosystem. Anthropic's plugin skills use it, but Claude does not parse or compare version numbers. It is purely for human and documentation purposes.

In monorepo setups, nested skills in `packages/frontend/.claude/skills/` are only discovered when Claude works with frontend files. Version changes to those skills are invisible to developers working in other packages until they touch frontend code.

## Checklist

- [ ] Skill changes go through pull requests, not direct main edits
- [ ] `version` field in frontmatter tracks current version
- [ ] Changelog section in skill body documents changes
- [ ] Breaking changes use parallel skill directories during migration
- [ ] Team naming conventions prevent personal/project collisions

## Related Guides

- [Publishing Claude Skills to GitHub](/publishing-claude-skills-to-github/)
- [Updating Shared Skills Without Breaking Workflows](/updating-shared-claude-skills-without-breaking-workflows/)
- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
