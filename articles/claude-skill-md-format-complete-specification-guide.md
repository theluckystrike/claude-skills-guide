---
layout: post
title: "Claude Skill .md File Format: Full Specification"
description: "Everything you need to know about the Claude skill .md file format: structure, placement, invocation, and body content with working examples."
date: 2026-03-13
categories: [skills, reference, guides]
tags: [claude-code, claude-skills, skill-format, markdown, reference]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Skill .md Format: Complete Specification Guide

Every Claude skill is a Markdown file. The format is straightforward, but getting it wrong means your skill either fails silently or never fires. This guide covers every field and edge case.

## What Is a Skill File?

A skill file is a plain Markdown document placed in `.claude/skills/` in your project (or `~/.claude/skills/` globally). Claude Code scans these directories and registers each `.md` file as a callable skill.

The format has two parts: YAML front matter between `---` delimiters, and a Markdown body that serves as the system prompt.

```
---
name: my-skill
description: Does something useful
triggers:
  - phrase: do the thing
---

You are a specialized assistant. When invoked, you will...
```

## Front Matter Fields

**name** (required): The canonical identifier. Used for manual invocation via `/skill-name`. Rules: lowercase, hyphens only, no spaces.

**description** (required): Human-readable explanation. Used for auto-invocation semantic matching. Write as a precise, complete sentence.

**triggers** (optional but strongly recommended): Array of phrase objects defining auto-invocation conditions. Without triggers, the skill only activates via explicit `/skill-name` invocation.

```yaml
triggers:
  - phrase: create a component
  - phrase: build a new page
  - phrase: design the UI for
```

Matching is semantic. "Can you design the login screen?" matches `design the UI for`.

## The Skill Body

Everything after the closing `---` is the skill body. This becomes the system prompt Claude receives when the skill is invoked.

Effective skill bodies:
1. State the role the skill plays
2. Define expected input format
3. Specify output format
4. Include constraints or guardrails
5. Provide 1-2 examples if non-obvious

Example for a tdd skill:

```
You are a test-driven development assistant. When given a feature description:

1. Write failing tests first (using the project test framework)
2. Write minimum implementation to pass those tests
3. Refactor implementation without changing tests

Always check existing test files for naming conventions.
Never write implementation before tests.

Output: test file(s), then implementation, then brief explanation.
```

### Injecting Project Context

Instruct the skill body to read specific files for project-specific context:

```
---
name: frontend-design
description: Builds React components using the project design system
---

At the start of every invocation, read:
- docs/design-tokens.md
- src/components/Button.tsx (as a reference example)

Build all components following the established patterns.
```

## File Placement and Loading Order

1. Built-in skills bundled with Claude Code
2. Global skills: `~/.claude/skills/*.md`
3. Project skills: `{project_root}/.claude/skills/*.md`

Later-loaded skills win on name conflicts. Project skills always override global skills with the same name.

## Common Mistakes

**Missing triggers**: Without triggers, users must invoke manually.

**Overly broad trigger phrases**: `- phrase: help me` matches almost everything.

**Wrong directory**: Files must be in `.claude/skills/` (not `.claude/skill/`).

## Validating Your Skill

Invoke directly to test:

```
/your-skill-name test this
```

If the skill does not respond as expected, check: file is in `.claude/skills/`, YAML parses cleanly, name uses only lowercase and hyphens.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/)
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/)
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/)

Built by theluckystrike - More at [zovo.one](https://zovo.one)
