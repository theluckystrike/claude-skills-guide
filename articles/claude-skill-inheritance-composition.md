---
sitemap: false
layout: default
title: "Claude Skill Inheritance and Composition Guide (2026)"
description: "Extend team-shared base skills with project-specific overrides using scope precedence, layered invocation, and the wrapper skill pattern."
permalink: /claude-skill-inheritance-composition/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, inheritance, composition]
last_updated: 2026-04-19
---

## The Specific Situation

Your platform team ships a `code-style` skill via a plugin that enforces company-wide standards: 2-space indentation, no semicolons in TypeScript, max function length of 50 lines. But your project uses a stricter variant: max function length of 30 lines, required JSDoc on all exported functions. You cannot modify the plugin skill because 15 other projects use it. You need to extend it with project-specific rules without duplication.

Claude Code does not have a formal inheritance mechanism for skills. But the scope precedence system (enterprise > personal > project) and skill composition patterns create effective inheritance when used deliberately.

## Technical Foundation

When two skills have the same name at different scopes, Claude Code loads the higher-precedence version. Enterprise overrides personal, personal overrides project. Plugin skills use a `plugin-name:skill-name` namespace, so they never conflict with same-named skills at other scopes.

This means you cannot "override" a plugin skill by creating a project skill with the same name -- the plugin skill stays accessible at its namespaced name. Instead, you create a new project skill that layers on top of the plugin skill, adding or modifying rules.

Skills loaded simultaneously share context. If a reference skill is auto-invoked and a task skill is manually invoked, the task skill operates within the reference context. This is the basis for composition-based inheritance.

## The Working SKILL.md

Base skill (distributed via plugin `team-standards`):

```yaml
---
name: code-style
description: >
  Company-wide coding standards. TypeScript: 2-space indent,
  no semicolons, max 50 line functions, prefer const over let.
  Auto-activates on TypeScript files.
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Code Style Standards (Company-Wide)

## TypeScript Rules
- 2-space indentation (no tabs)
- No semicolons (rely on ASI)
- Max function length: 50 lines
- Prefer const, use let only when reassignment is needed
- No var declarations
- Use template literals over string concatenation
- Arrow functions for callbacks, named functions for top-level
```

Project-level extension at `.claude/skills/code-style-extended/SKILL.md`:

```yaml
---
name: code-style-extended
description: >
  Project-specific coding standards that extend team-standards:code-style.
  Adds stricter function length limits, JSDoc requirements, and
  project-specific naming conventions. Auto-activates on TypeScript files.
paths:
  - "**/*.ts"
  - "**/*.tsx"
user-invocable: false
---

# Project-Specific Code Style Extensions

NOTE: These rules extend team-standards:code-style. All company-wide
rules still apply. The following are additional or stricter requirements.

## Stricter Rules (override base)
- Max function length: 30 lines (stricter than company-wide 50)
- Max file length: 300 lines
- Max parameters per function: 4

## Additional Rules (not in base)
- All exported functions MUST have JSDoc with @param and @returns
- All exported types/interfaces MUST have JSDoc description
- React components: use FC<Props> type, not inline prop typing
- API route handlers: must include error boundary try/catch
- Database queries: must use parameterized queries (no string interpolation)

## Naming Conventions (project-specific)
- API routes: camelCase file names matching the endpoint verb (getUser.ts)
- Components: PascalCase directories matching component name
- Hooks: use{Feature} prefix (useAuth, useCart)
- Utils: pure functions, named exports only, no default exports
```

The wrapper pattern for task skills:

```yaml
---
name: review-extended
description: >
  Extended code review that applies both company-wide and project-specific
  standards. Invokes team-standards:code-style then applies project extensions.
disable-model-invocation: true
allowed-tools: Skill(team-standards:code-style *) Read Grep
---

# Extended Code Review

## Workflow
1. First, load team-standards:code-style for company-wide rules
2. Then apply project-specific extensions from code-style-extended
3. Review all changed files against both rule sets
4. Report violations grouped by: company-standard vs project-specific
```

## Common Problems and Fixes

**Project skill does not override plugin skill.** Plugin skills are namespaced and cannot be overridden by project skills with the same bare name. Use the wrapper pattern: create a project skill that references the plugin skill and adds extensions on top.

**Both base and extended skills auto-invoke, creating duplicate rules.** If the base skill says "max 50 lines" and the extension says "max 30 lines," Claude sees both and may be confused. The extension skill should explicitly state "This overrides X from the base" rather than just stating a different number.

**Extended skill loads but base skill does not.** The `paths` field on the extension activates it, but if the base skill is in a plugin that is not enabled for this project, the extension has no base to build on. Verify the plugin is enabled before relying on the base.

**Scope precedence causes unexpected overrides.** A developer's personal `~/.claude/skills/code-style/SKILL.md` overrides the project-level version. Personal skills take precedence over project skills. If team standards must be consistent, distribute via plugin or managed settings, not project-level skills.

## Production Gotchas

There is no way to formally "import" one skill into another. The inheritance pattern relies on both skills being loaded into context simultaneously. If only one loads (due to path mismatch or scope conflict), the composition breaks silently. Test with `What skills are available?` to verify both load when expected.

The compaction budget (25,000 tokens total) treats base and extension as separate skills. Two skills at 4,000 tokens each consume 8,000 tokens of budget. If you have many layered extensions, the total may exceed the budget, causing oldest content to be dropped.

## Checklist

- [ ] Base skill distributed via plugin or managed settings (not project-level)
- [ ] Extension skill explicitly references which base rules it modifies
- [ ] Wrapper skills use `allowed-tools: Skill(base-name *)` for invocation
- [ ] Personal skills checked for unintended overrides via scope precedence
- [ ] Total combined token usage of layered skills under 10,000 tokens

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- five composition architectures
- [Claude Skill Registry Pattern for Teams](/claude-skill-registry-pattern-for-teams/) -- team discovery and distribution
- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- shared resources without duplication
