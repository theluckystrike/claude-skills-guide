---
layout: post
title: "How Do I Migrate from Cursor Rules to Claude Skills"
description: "A practical guide for developers moving custom AI rules from Cursor to Claude Code skills. Includes step-by-step migration, code examples, and skill rec..."
date: 2026-03-14
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# How Do I Migrate from Cursor Rules to Claude Skills

If you have invested time building custom rules in Cursor, you might wonder whether those configurations translate to Claude Code. The good news: both systems use similar concepts—custom instructions that shape AI behavior—but they organize and invoke them differently. This guide walks you through migrating your Cursor rules to Claude Code skills with practical examples.

## Understanding the Difference

Cursor rules live in `.cursorrules` files placed at your project root or in a dedicated rules directory. These files contain instructions that shape how Cursor's AI assistant behaves within your codebase. Claude Code takes a different approach: skills are Markdown files stored in `~/.claude/skills/` that you invoke with a slash command during conversations.

The key distinction is invocation method. In Cursor, your rules apply globally to every conversation in that project. In Claude Code, you activate a skill when needed using `/skill-name`, then describe your task. This gives you finer control—you load only the expertise you need for a specific task.

## Step 1: Export Your Cursor Rules

First, locate your `.cursorrules` files. They typically live in your project root or a `.cursor` folder. Open each file and copy its contents. If you have multiple rule sets (for different project types or workflows), organize them by purpose—you will create separate skills for each.

Review each rule set and identify its core purpose. A rule that enforces specific code formatting becomes a style skill. A rule that guides code review becomes a review skill. This separation aligns with how Claude Code skills work best.

## Step 2: Create Your Skill Directory

Claude Code skills live in `~/.claude/skills/`. Each skill is a Markdown file with a descriptive name. Create this directory if it does not exist:

```bash
mkdir -p ~/.claude/skills
```

Name your skill files descriptively. For a code formatting skill, use something like `code-style.md`. For a review-focused skill, `code-review.md`. The filename becomes the invocation command—`/code-style` or `/code-review`.

## Step 3: Structure Your Skill File

Claude Code skills use a specific format. The file should contain clear instructions that a skilled human specialist would follow. Here is a template:

```markdown
# Code Style Skill

You are an expert code reviewer specializing in [your focus area].

## Guidelines

- Review code for [specific criteria]
- Suggest improvements using [your preferred patterns]
- Flag issues with [your severity scale]

## Examples

When reviewing a function:
1. Check for [first concern]
2. Verify [second concern]
3. Suggest [improvement approach]
```

## Step 4: Migrate Specific Rule Types

Let us walk through migrating common Cursor rule patterns to Claude skills.

### Code Style Rules

If your Cursor rules enforce specific formatting, create a `code-style.md` skill:

```markdown
# Code Style Skill

You enforce consistent code style following these principles:

- Use meaningful variable names (no single letters unless for loops)
- Prefer early returns over nested conditionals
- Keep functions under 30 lines
- Add type hints to all function signatures
- Use docstrings for public APIs

When reviewing code, provide specific line numbers and concrete suggestions.
```

Invoke it in Claude Code with `/code-style review my new module`

### Testing Rules

For Cursor rules focused on test creation, use the built-in **tdd** skill or create a custom testing skill:

```markdown
# Testing Skill

You specialize in writing comprehensive tests.

Requirements:
- Use pytest for Python projects
- Follow AAA pattern (Arrange, Act, Assert)
- Name tests descriptively: test_[method]_[expected_behavior]
- Include edge case tests
- Mock external dependencies
```

The **tdd** skill ships with Claude Code and provides test-first development workflows. Use it for projects where you want the AI to write tests before implementation:

```
/tdd generate unit tests for this authentication module
```

### Frontend Development Rules

For frontend-focused rules, combine the **frontend-design** skill with custom guidelines:

```markdown
# Frontend Standards Skill

You ensure frontend code follows modern best practices:

- Use functional React components with hooks
- Keep CSS in dedicated files or CSS modules
- Implement proper accessibility (ARIA labels, keyboard navigation)
- Use TypeScript for all new components
- Follow mobile-first responsive design

When reviewing, check component composition and reusability.
```

### Documentation Rules

For documentation-focused rules, leverage the **pdf** skill alongside custom documentation standards:

```markdown
# Documentation Skill

You ensure code has clear, maintainable documentation.

Standards:
- README files must include: installation, usage, and API reference
- Use JSDoc for JavaScript/TypeScript
- Include code examples in docstrings
- Keep documentation near the code it describes
- Generate API docs automatically from type definitions
```

The **pdf** skill helps when you need to extract existing documentation from files or generate new documentation as PDFs:

```
/pdf extract all API documentation from this codebase
```

## Step 5: Organize Multiple Skills

As you accumulate skills, organize them logically. Common categories include:

- **Development**: code-style, tdd, code-review
- **Frontend**: frontend-design, accessibility, responsive-check
- **Documentation**: docs, pdf
- **Research**: Use the **supermemory** skill to query your personal knowledge base

Create a README in your skills directory explaining each skill:

```bash
ls ~/.claude/skills/
# code-review.md  code-style.md  docs.md  tdd.md  frontend.md
```

## Step 6: Test Your Migration

Invoke each new skill to verify it works:

```
/code-style review src/auth.ts
/tdd write tests for utils/parser.py
/docs generate README for this project
```

Adjust the skill instructions based on results. Claude Code skills are just Markdown—you can edit them anytime.

## Recommendations for Common Workflows

For data analysis projects, the **xlsx** skill handles spreadsheet operations:

```
/xlsx analyze this sales data and create a summary report
```

For memory and knowledge management, the **supermemory** skill queries your stored information:

```
/supermemory what did I learn about Redis optimization last week
```

For document creation, the **pptx** skill builds presentations:

```
/pptx create a technical architecture overview from my notes
```

## Summary

Migrating from Cursor rules to Claude Code skills involves three main steps: exporting your existing rules, converting them to Markdown skill files in `~/.claude/skills/`, and invoking them with slash commands during conversations. The separation of concerns—loading only the skill you need—provides more flexibility than Cursor's project-wide rules.

Start by migrating your most-used rules first. Test each skill thoroughly. Over time, you will build a personalized toolkit that makes Claude Code feel like an expert partner for every type of task you encounter.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
