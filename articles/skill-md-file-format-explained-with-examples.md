---
layout: default
title: "Skill MD File Format Explained With Examples Guide"
description: "The skill.md file format for Claude Code: front matter fields, body structure, and practical examples for building effective skill definitions."
date: 2026-03-13
categories: [tutorials]
tags: [claude-code, claude-skills, skill-md, skill-format, reference]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Skill MD File Format Explained With Examples

Claude skills are plain Markdown files. The format combines YAML front matter with a Markdown body. The front matter stores metadata; the body is the system prompt.

## The Basic Structure

A minimal skill file:

```
---
name: example-skill
description: A sample skill demonstrating the fundamental format
triggers:
  - phrase: do the example task
---

You are a specialized assistant for example tasks.

When invoked, you will:
1. Do the first thing
2. Do the second thing
3. Report back clearly
```

## Front Matter Fields

**name** (required): The skill identifier. Used for manual invocation: `/skill-name`.

**description** (required): What the skill does. Used for auto-invocation matching. Write as a full sentence.

**triggers** (optional but recommended): Phrases that cause automatic invocation.

```yaml
triggers:
  - phrase: create a component
  - phrase: build a new page
```

## A Practical Example: The pdf Skill

The [pdf skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) extracts text, tables, and content from PDF files and can generate new PDFs. Here is its skill definition:

```
---
name: pdf
description: Extracts text and tables from PDF files and creates new PDFs
triggers:
  - phrase: read this PDF
  - phrase: extract from the PDF
  - phrase: create a PDF document
---

# PDF Skill

You are a PDF document specialist.

When to use this skill:
- Extracting text and tables from existing PDFs
- Creating new PDFs from Markdown or provided content
- Merging multiple PDF files

How to work:
1. Ask the user for the PDF file path or content
2. Use available tools to read the file or generate output
3. Present extracted content in clean, structured format
```

Invoke with: `/pdf extract all tables from Q3-financial-report.pdf`

## A Practical Example: The tdd Skill

The [tdd skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) enforces test-driven development by writing failing tests before implementation. Here is its skill definition:

```
---
name: tdd
description: Test-driven development: writes failing tests first, then implementation
triggers:
  - phrase: write tests for
  - phrase: add test coverage to
---

# TDD Skill

You are a test-driven development assistant.

Workflow:
1. Red phase: Write failing tests that describe the desired behavior
2. Green phase: Write the minimum code to make those tests pass
3. Refactor phase: Clean up implementation without changing tests

Before writing tests, check existing test files for:
- Testing framework (Jest, pytest, Vitest, etc.)
- Test file naming conventions
- Mock and fixture patterns already in use

Output: test file(s), then implementation file(s), then brief explanation.
```

## Advanced Pattern: Reading Project Context Files

Skills can instruct Claude to read specific files at the start of every invocation:

```
---
name: frontend-design
description: Builds React components using the project's design system
---

At the start of every invocation, read:
- docs/design-tokens.md (color palette, spacing scale, typography)
- src/components/Button.tsx (as a component reference example)

Then build the requested component following the established patterns.
```

This is the correct way to inject project context into a skill: by instructing Claude to read files, not via special YAML configuration.

## Common Mistakes

**Missing description**: Skills without descriptions do not contribute to auto-invocation.

**Generic trigger phrases**: `- phrase: help me with code` fires on almost everything.

**Wrong directory**: Files must be in `.claude/skills/` or `~/.claude/skills/`.

---

## Related Reading

- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/)
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/)

Built by theluckystrike - More at [zovo.one](https://zovo.one)
