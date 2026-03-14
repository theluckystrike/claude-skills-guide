---
layout: default
title: "Claude Skill Metadata Header vs Full Body Loading: What Gets Loaded When"
description: "Understand how Claude skills load metadata versus the full body, and when each component matters for performance and functionality."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, skill-authoring, front-matter]
reviewed: true
score: 8
permalink: /claude-skill-metadata-header-vs-full-body-loading/
---

# Claude Skill Metadata Header vs Full Body Loading

[invoke a Claude skill with `/skill-name`](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/), Claude reads the entire `.md` file from `~/.claude/skills/`. There is no separate metadata-only loading phase — the front matter and the skill body load together. This guide explains what belongs in each section and how to structure skills for clarity.

## What Is Skill Metadata?

Skill metadata lives in the YAML front matter at the top of your skill file. [only recognized front matter fields](/claude-skills-guide/claude-skill-yaml-front-matter-parsing-error-fix/):

```yaml
---
name: pdf-editor
description: Edit and manipulate PDF documents
---
```

These two fields identify the skill. Fields like `version`, `tags`, `author`, `permissions`, `tools`, and `auto_invoke` are not recognized by Claude Code. Do not add them — they have no effect and can mislead readers.

## What Is the Skill Body?

The skill body is everything after the closing `---` in your Markdown file. This content becomes part of the context when the skill runs:

```markdown
---
name: tdd-helper
description: Assist with test-driven development workflows
---

# TDD Helper Skill

You are a test-driven development assistant. When the user shares code:

1. First, write failing tests that specify expected behavior
2. Then implement the minimum code to pass those tests
3. Finally, refactor while keeping tests green

Always ask clarifying questions before writing tests.
```

The body contains the instructions, examples, and guidance that shape Claude's behavior during the skill session. This is where you define what the skill does and how it operates.

## When the Skill Loads

When you type `/skill-name` in a Claude Code session, Claude reads the complete file — front matter and body together. There is no separate initialization phase that parses metadata before the body.

[Skills are discovered by filename](/claude-skills-guide/how-do-i-know-which-claude-skill-is-currently-active/). Typing `/my-skill` looks for `~/.claude/skills/my-skill.md`. There is no search registry and no CLI command to list or filter skills. To see what skills are available, list the files in your skills directory:

```bash
ls ~/.claude/skills/
```

## Why the Distinction Matters

### Keeping Skills Focused

The front matter should be minimal — just `name` and `description`. The body should contain everything Claude needs to perform the task. A common mistake is trying to configure behavior through front matter fields that Claude Code does not recognize.

For example, a skill like `/[maintains project context](/claude-skills-guide/building-stateful-agents-with-claude-skills-guide/) about how to store and retrieve memories in the body:

```markdown
---
name: supermemory
description: Maintain persistent context and memory across Claude Code sessions
---

# Supermemory Skill

You help maintain project context across sessions. When invoked:

1. Ask what the user wants to remember or retrieve
2. Store important decisions, architectural choices, and conventions
3. Reference stored context when answering questions about the project

Keep memories concise and organized by topic.
```

### Body Length and Performance

[Large skill bodies consume more context tokens](/claude-skills-guide/claude-skills-context-window-management-best-practices/) at each turn. To keep skills manageable:

- Put only the instructions Claude needs in the skill body
- Move reference material to separate files and instruct Claude to read them when needed using the `read_file` tool
- Break very large workflows into smaller, focused skills

### Practical Examples

A minimal skill with a clear, focused body:

```markdown
---
name: sql-formatter
description: Format and validate SQL queries
---

Format SQL queries according to these rules:
- UPPERCASE keywords
- Indent joins and subqueries
- Use trailing commas in column lists
- Add inline comments for complex logic
```

A skill with extended body content for a richer workflow:

```markdown
---
name: api-documentation
description: Generate API documentation from code
---

# API Documentation Generator

Generate OpenAPI 3.0 documentation from code.

## Supported Frameworks
- Express.js
- FastAPI
- Flask
- Spring Boot

## Output Format
Always produce valid OpenAPI YAML with:
- Operation summaries from route names
- Request/response schemas
- Example payloads
```

## Best Practices for Skill Authors

**Keep front matter minimal.** Use only `name` and `description`. Any additional fields are ignored.

**Put all behavior in the body.** Instructions, examples, rules, and context all belong in the Markdown body, not in front matter.

**Separate core instructions from reference material.** Put essential instructions directly in the body. Reference external files for examples and templates by instructing Claude to read them with `read_file`.

**Keep the body focused.** A skill that does one thing well is easier to invoke correctly than one that handles every possible case. If a skill covers too many scenarios, split it into multiple focused skills.

## Common Mistakes to Avoid

**Adding unsupported front matter fields.** Fields like `version`, `tags`, `permissions`, `auto_invoke`, and `tools` are not recognized. They do nothing.

**Putting behavior in front matter.** The body defines what Claude does. Front matter is for identification only.

**Making skills too large.** Skills that load hundreds of lines of examples for every invocation consume context unnecessarily. Use external file references for non-essential content.

## Conclusion

Claude Code skills have a simple structure: minimal front matter with `name` and `description`, followed by a Markdown body with all instructions. The entire file loads when you invoke the skill. There is no complex metadata system, no permission declarations, and no separate loading phases. Design each section with this in mind, and your skills will be clear, correct, and maintainable.

## Related Reading

- [How Do I Test a Claude Skill Before Deploying to Team](/claude-skills-guide/how-do-i-test-a-claude-skill-before-deploying-to-team/) — Validate skill structure and behavior before sharing with teammates
- [Open Source Claude Skills Ecosystem Outlook 2026](/claude-skills-guide/open-source-claude-skills-ecosystem-outlook-2026/) — How community skills are structured and shared
- [Claude Skills Getting Started Hub](/claude-skills-guide/getting-started-hub/) — Start with the basics of skill authoring and invocation

Built by theluckystrike — More at [zovo.one](https://zovo.one)
