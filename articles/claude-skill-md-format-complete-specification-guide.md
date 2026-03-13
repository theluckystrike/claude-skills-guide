---
layout: default
title: "Claude Skill .md Format: Complete Specification Guide"
description: "A precise technical breakdown of how Claude skill Markdown files are structured, parsed, and executed — including every field, trigger type, and edge case."
date: 2026-03-13
author: theluckystrike
---

# Claude Skill .md Format: Complete Specification Guide

Every Claude skill is a Markdown file. That sentence sounds simple, but the format is carefully specified, and getting it wrong means your skill either fails silently or never fires at all. This guide covers every field, every option, and every edge case in the Claude skill `.md` format.

## What Is a Skill File?

A skill file is a plain Markdown document placed in the `.claude/skills/` directory of your project (or globally in `~/.claude/skills/`). When Claude Code starts, it scans these directories, parses every `.md` file it finds, and registers each one as a callable skill.

The format has two parts: a YAML front matter block (between `---` delimiters) and a Markdown body that serves as the system prompt for the skill.

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

### `name` (required)

The canonical identifier for the skill. Used for manual invocation via `/skill-name` in the Claude Code terminal.

Rules:
- Lowercase letters, numbers, and hyphens only
- No spaces, no underscores, no special characters
- Must be unique across all loaded skills (last-loaded wins on conflict)
- Maximum 64 characters

```yaml
name: frontend-design
```

### `description` (required)

A human-readable explanation of what the skill does. Claude Code surfaces this in `/skills list` output and uses it when doing semantic matching for auto-invocation.

```yaml
description: Generates React components with Tailwind CSS, following project design tokens
```

Write this as a full sentence. The description is also passed to the model as context when the skill is invoked, so be precise — vague descriptions lead to vague behavior.

### `triggers` (optional but strongly recommended)

An array of trigger objects that define when the skill fires automatically. Without triggers, the skill only activates via explicit `/skill-name` invocation.

Each trigger has a `phrase` key:

```yaml
triggers:
  - phrase: create a component
  - phrase: build a new page
  - phrase: design the UI for
```

Trigger matching is semantic, not literal string matching. If a user types "can you design the UI for the login screen?", the phrase `design the UI for` will match. Claude Code computes a similarity score between the user input and each trigger phrase; if any score exceeds the configured threshold (default: 0.75), the skill is auto-invoked.

### `model` (optional)

Override the model used for this specific skill. Useful when a skill does heavy reasoning and you want to route it to a more capable model, or when you want to use a faster model for lightweight tasks.

```yaml
model: claude-opus-4-6
```

Omitting this field uses the session default.

### `tools` (optional)

Restrict which tools the skill has access to. By default, a skill inherits all tools available to the current session. You can scope this down:

```yaml
tools:
  - read_file
  - write_file
  - bash
```

This is useful for skills like `pdf` or `docx` where you want to prevent unexpected tool calls (like web search or git operations).

### `max_turns` (optional)

Limit the number of agentic turns the skill can take before returning control to the user. Default is unbounded (inherits session setting).

```yaml
max_turns: 5
```

Use this for skills that should give a quick answer and stop, rather than running a long autonomous loop.

### `context_files` (optional)

A list of files that should be automatically included in the skill's context window every time it runs. Paths are relative to the project root.

```yaml
context_files:
  - docs/design-system.md
  - src/components/index.ts
```

This is how the `frontend-design` skill typically gets access to your project's design token documentation without you having to paste it each time.

### `memory` (optional)

Whether the skill should persist learned information across sessions using the supermemory integration.

```yaml
memory: true
```

When set to `true`, the skill has read/write access to the supermemory store scoped to its name. Skills like `supermemory` use this to build persistent context.

## The Skill Body

Everything after the closing `---` of the front matter is the skill body. This becomes the system prompt that Claude receives when the skill is invoked.

### Writing Effective Skill Bodies

The body should:
1. State the role the skill plays ("You are a test engineer...")
2. Define the input format the skill expects
3. Specify the output format
4. Include any constraints or guardrails
5. Provide 1-2 examples if the task is non-obvious

Example for a `tdd` skill:

```markdown
You are a test-driven development assistant. When given a description of a feature, you will:

1. Write failing tests first (using the project's test framework)
2. Write the minimum implementation to pass those tests
3. Refactor the implementation without changing the tests

Always check the existing test files to understand naming conventions before writing new tests. Never write implementation code before writing tests.

Output format:
- First: the test file(s)
- Then: the implementation file(s)
- Finally: a brief explanation of the approach
```

### Variable Substitution in Skill Bodies

Skill bodies support a small set of template variables:

- `{{project_root}}` — absolute path to the project root
- `{{user}}` — git config user.name
- `{{date}}` — current date in ISO format
- `{{skill_name}}` — the skill's own name (useful for meta-skills)

These are resolved at invocation time, not at load time.

## File Placement and Loading Order

Skills are loaded in this priority order (later sources override earlier):

1. Built-in skills bundled with Claude Code
2. Global skills: `~/.claude/skills/*.md`
3. Project skills: `{project_root}/.claude/skills/*.md`
4. Workspace overrides: `.claude/skills/overrides/*.md`

If two skills share the same `name`, the later-loaded one wins. This means a project-level skill will always override a global skill with the same name — useful for customizing `tdd` or `frontend-design` per project.

## Common Mistakes

**Missing triggers**: If you skip the `triggers` block, users must invoke your skill manually. This is fine for power users but reduces adoption.

**Overly broad trigger phrases**: `- phrase: help me` will match almost everything and flood your workflow with unwanted skill invocations.

**Forgetting `context_files`**: Skills that need project-specific knowledge but don't declare `context_files` will produce generic output. Always wire in the relevant docs.

**Skill name collisions**: If you have both a global and a project `frontend-design` skill, only the project one runs. Check `/skills list` to see which version is active.

## Validating Your Skill

Run `/skills list` in any Claude Code session to see all loaded skills, their trigger counts, and their source path. If your skill doesn't appear, check:

- Is the file in `.claude/skills/` (not `.claude/skill/` without the `s`)?
- Does the YAML front matter parse cleanly? (Use a YAML linter)
- Is the `name` field present and valid?

Run `/skill your-skill-name` to invoke it directly and verify the output matches your expectations.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Complementary examples and annotated templates for the fields covered in this specification
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — A practical walkthrough for writing your first skill from scratch, following the format rules in this guide
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — How skill body design and context_files declarations affect token consumption in every skill invocation

Built by theluckystrike — More at [zovo.one](https://zovo.one)
