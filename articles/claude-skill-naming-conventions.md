---
title: "Claude Skill Naming Conventions (2026)"
description: "Naming rules for SKILL.md name field, directory names, and plugin namespaces with examples of what works and what breaks."
permalink: /claude-skill-naming-conventions/
categories: [skills, 2026]
tags: [claude-code, claude-skills, naming, conventions, organization]
last_updated: 2026-04-19
---

## The Specific Situation

Your team has three skills: `deploy`, `deploy-staging`, and `Deploy`. One developer created a personal skill also called `deploy`. Another installed a plugin with a skill named `deploy`. Nobody can predict which `deploy` actually runs. Half the team has stopped using skills because "they do random things." The root cause is naming collisions across scopes, and the fix requires understanding naming rules, precedence, and namespacing.

## Technical Foundation

The `name` field in SKILL.md frontmatter accepts lowercase letters, numbers, and hyphens only, with a maximum of 64 characters. If omitted, Claude uses the directory name as the skill name. This name determines what appears in the `/` menu and what you type to invoke the skill manually.

Skills exist at four scopes with strict precedence: enterprise > personal > project. Plugin skills use a separate `plugin-name:skill-name` namespace, so they cannot collide with skills at other levels. If a skill and a legacy command share the same name (e.g., both `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` exist), the skill takes precedence.

## The Working SKILL.md

Here is a well-named skill that avoids collision risks:

```yaml
---
name: deploy-prod
description: >
  Deploy the application to production. Runs tests, builds artifacts,
  and pushes to the production target. Use when the user says
  "deploy to production" or "ship to prod".
disable-model-invocation: true
argument-hint: "[branch-name]"
allowed-tools: Bash(npm run build *) Bash(npm test *) Bash(git push *)
---

Deploy $ARGUMENTS to production:

1. Verify current branch is clean: `git status --porcelain`
2. Run full test suite: `npm test`
3. Build production artifacts: `npm run build`
4. Push to production: `git push production $ARGUMENTS`
5. Verify deployment health check passes
```

And the corresponding staging variant:

```yaml
---
name: deploy-staging
description: >
  Deploy the application to the staging environment. Use when the
  user says "deploy to staging" or "push to stage".
disable-model-invocation: true
argument-hint: "[branch-name]"
---

Deploy $ARGUMENTS to staging:

1. Run quick test suite: `npm test -- --bail`
2. Build staging artifacts: `npm run build:staging`
3. Push to staging: `git push staging $ARGUMENTS`
```

## Naming Rules Summary

| Rule | Valid | Invalid |
|------|-------|---------|
| Lowercase only | `deploy-prod` | `Deploy-Prod` |
| Hyphens for separators | `fix-issue` | `fix_issue`, `fix.issue` |
| Max 64 characters | `generate-test-for-component` | (anything over 64) |
| Numbers allowed | `deploy-v2` | -- |
| No spaces | `code-review` | `code review` |
| Directory name fallback | `my-skill/SKILL.md` (name = `my-skill`) | -- |

## Naming Patterns That Scale

**Verb-noun format**: `generate-tests`, `fix-issue`, `review-pr`, `deploy-staging`. The verb tells users what happens. The noun tells them what it acts on.

**Scope prefixes for large teams**: `fe-lint` (frontend), `be-deploy` (backend), `infra-provision` (infrastructure). Prevents collisions across sub-teams.

**Environment suffixes**: `deploy-prod`, `deploy-staging`, `deploy-dev`. Keeps deployment skills separate and explicit.

**Avoid**: Generic names like `helper`, `util`, `run`, `do`. These collide easily and give users no context in the `/` menu.

## Common Problems and Fixes

**Name collision across scopes**: A personal skill at `~/.claude/skills/deploy/SKILL.md` overrides a project skill at `.claude/skills/deploy/SKILL.md` because personal > project in precedence. Rename one of them.

**Plugin skill name collision**: Plugin skills are namespaced as `plugin-name:skill-name`. They appear in the `/` menu with the prefix. No collision with project or personal skills is possible.

**Legacy command conflict**: If `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both exist, the skill wins. Migrate the command file to a skill directory or delete it.

**Name too long**: The 64-character limit means `generate-comprehensive-integration-test-suite-for-react-components` is too long. Shorten to `gen-integration-tests`.

**Uppercase in name**: Claude silently lowercases the `name` field, but your directory name is case-sensitive on Linux. Use lowercase for both to avoid confusion.

## Production Gotchas

The `/` menu shows all discoverable skills from all scopes. In a monorepo with nested `.claude/skills/` directories, skills from subdirectories appear only when Claude is working with files in that subdirectory. This means the `/` menu changes depending on which files Claude has recently read.

When two team members create personal skills with the same name (both `~/.claude/skills/deploy/SKILL.md`), there is no conflict because personal skills are per-user. The problem arises when one of them also has a project-level skill with the same name -- their personal version always wins, causing different behavior than teammates who only have the project version.

The `argument-hint` field (e.g., `[branch-name]`) appears during autocomplete. Use it to distinguish similarly named skills: `deploy-prod [branch]` vs `deploy-staging [branch]`.

## Checklist

- [ ] Name uses only lowercase letters, numbers, and hyphens
- [ ] Name is under 64 characters
- [ ] Name follows verb-noun pattern for clarity
- [ ] No collision with skills at other scopes (personal vs project)
- [ ] Legacy `.claude/commands/` files with same name removed or migrated

## Related Guides

- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/)
- [Fix Skill Name Already in Use Error](/fix-skill-name-already-in-use-error/)
