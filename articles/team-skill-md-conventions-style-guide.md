---
layout: default
title: "Team SKILL.md Conventions (2026)"
description: "Claude Code resource: writing standards for team-shared SKILL.md files covering description triggers, body structure, naming, and progressive..."
permalink: /team-skill-md-conventions-style-guide/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, style-guide, conventions, team]
last_updated: 2026-04-19
---

## The Specific Situation

Your team has 12 skills in `.claude/skills/`. Half have vague descriptions like "helps with stuff." Three use inconsistent naming (`deployApp`, `fix-bug`, `CODE_REVIEW`). Two have 800-line SKILL.md files. Nobody knows which skills trigger automatically vs manually. When new developers join, they cannot tell what the skills do without reading every file. You need a style guide.

## Technical Foundation

Anthropic's official skill development guidance establishes specific writing standards:

- **Imperative/infinitive form** in the body: "Create a new file" not "You should create"
- **Third-person in description**: "Generates API documentation" not "I generate API docs"
- **SKILL.md target**: 1,500-2,000 words
- **References**: 2,000-5,000+ words per reference file
- **Description + when_to_use**: Combined cap of 1,536 characters

Claude uses the `description` field to decide when to auto-invoke a skill. Vague descriptions cause misfires. Missing descriptions mean the skill never auto-triggers. The style guide below prevents both.

## The Working SKILL.md (Template)

Every team skill should follow this structure:

```yaml
---
name: [verb]-[noun]
description: >
  [What it does in one sentence]. Use when [trigger condition 1],
  [trigger condition 2], or [trigger condition 3].
argument-hint: "[expected-input]"
disable-model-invocation: false
allowed-tools: [space-separated tool list]
paths: "[glob pattern if scoped]"
---

# [Skill Name]

[One paragraph: what this skill does and when to use it. 2-3 sentences.]

## Steps

1. [First action, imperative form]
2. [Second action]
3. [Third action]

## Rules

- [Constraint 1: what to always do]
- [Constraint 2: what to never do]
- [Constraint 3: boundary condition]

## Output Format

[Exact format Claude should produce]

## References

For [detailed topic], read ${CLAUDE_SKILL_DIR}/references/[file].md
```

## Convention Rules

### 1. Naming: verb-noun, Lowercase, Hyphens

```
GOOD: generate-tests, deploy-staging, review-pr, fix-lint
BAD:  generateTests, Deploy_Staging, ReviewPR, fixlint, helper
```

Name field: lowercase letters, numbers, hyphens only. Max 64 characters. If omitted, defaults to directory name. Use specific nouns -- `review-pr` not `review`, `deploy-staging` not `deploy`.

### 2. Descriptions: Front-Load Triggers

The description must contain words users naturally say. Claude matches against this text.

```yaml
# GOOD: specific triggers
description: >
  Generate unit tests for React components. Use when the user says
  "write tests", "add test coverage", or "test this component".

# BAD: vague
description: Helps with testing stuff
```

Front-load the primary use case. The combined description + when_to_use is capped at 1,536 characters and gets truncated. If the important triggers are at the end, they may be cut.

### 3. Body: Imperative Form, No Second-Person

```
GOOD: "Run the test suite." / "Generate a report."
BAD:  "You should run the test suite." / "You will generate a report."
```

This matches Anthropic's official writing style for skills. Imperative form is clearer and more concise.

### 4. Side-Effect Skills: Manual Only

Any skill that creates files, commits code, deploys, sends emails, or modifies external state MUST have `disable-model-invocation: true`. Without this, Claude may auto-trigger the skill when it thinks it is relevant, causing unintended side effects.

```yaml
# Correct: manual-only for side effects
disable-model-invocation: true

# These need manual-only: deploy, commit, send-email,
# create-ticket, run-migration, delete-branch
```

### 5. Size Limits: Progressive Disclosure

| Content | Location | Size Target |
|---------|----------|-------------|
| Trigger metadata | Frontmatter | Under 1,536 chars |
| Core instructions | SKILL.md body | 1,500-2,000 words |
| Detailed references | `references/*.md` | 2,000-5,000 words each |
| Templates | `templates/*.md` | As needed |
| Scripts | `scripts/*` | As needed |

Never put a 5,000-word reference doc in the SKILL.md body. Move it to `references/` and add a line: "For detailed X, read `${CLAUDE_SKILL_DIR}/references/x.md`."

## Common Problems and Fixes

**Inconsistent naming across skills**: Enforce the convention in a CLAUDE.md rule: add "Skill names follow verb-noun format with lowercase hyphens" to your project CLAUDE.md.

**Descriptions too similar**: Two skills with descriptions containing "review code" will compete for the same trigger. Differentiate: one says "review pull request changes" and the other says "review code style and formatting."

**New team members cannot find skills**: Run "What skills are available?" in Claude Code. This lists all discovered skills with their descriptions. Add this command to your onboarding checklist.

**Skill body too long**: If you cannot say it in 2,000 words, split into a main SKILL.md (workflow steps) and reference files (detailed documentation). Claude loads references only when instructed.

## Production Gotchas

The overall budget for all skill descriptions scales at 1% of the context window, with a fallback of 8,000 characters. If you have 20 skills with 400-character descriptions, that is 8,000 characters -- hitting the budget. Descriptions beyond the budget are dropped. Keep descriptions concise and set `SLASH_COMMAND_TOOL_CHAR_BUDGET` if needed.

When `user-invocable: false` is set, the skill's description stays permanently in context (Claude needs it to decide when to auto-trigger), but the skill is hidden from the `/` menu. Use this for background knowledge skills, not for task skills.

Review skills quarterly. Remove unused ones, update descriptions for skills with low trigger accuracy, and archive deprecated skills instead of deleting them (move to `.claude/skills/_archived/`).

## Checklist

- [ ] All skill names follow verb-noun lowercase-hyphen convention
- [ ] All descriptions front-load trigger phrases within 1,536 chars
- [ ] All side-effect skills have `disable-model-invocation: true`
- [ ] No SKILL.md body exceeds 2,000 words
- [ ] Reference docs moved to `references/` directory



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/)
- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
- [Claude Skills Onboarding New Developers](/claude-skills-onboarding-new-developers/)
