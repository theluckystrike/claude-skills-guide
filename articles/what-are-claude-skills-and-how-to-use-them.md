---
layout: default
title: "What Are Claude Skills and How to Use Them"
description: "Learn what Claude skills are, how they work in Claude Code, and step-by-step instructions for using built-in and custom skills to automate your."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /what-are-claude-skills-and-how-to-use-them/
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills, beginner, getting-started]
---

{% raw %}

# What Are Claude Skills and How to Use Them

Claude skills are reusable instruction sets that tell Claude Code how to handle specific types of tasks. Instead of repeating the same context and instructions every time you start a conversation, skills let you define your preferences, workflows, and domain knowledge once and have Claude apply them automatically.

This guide covers what skills are, how they work under the hood, and practical steps for using them in your projects.

## What Exactly Is a Claude Skill?

A Claude skill is a markdown file containing structured instructions that Claude Code reads before responding to your requests. Think of it as a persistent prompt that stays active across conversations.

Each skill typically includes:

- **When to activate**: Conditions that tell Claude when this skill is relevant
- **Instructions**: The specific rules, patterns, or behaviors Claude should follow
- **Examples**: Sample inputs and outputs that demonstrate expected behavior
- **Constraints**: Boundaries on what Claude should and should not do

Skills live in your project's `.claude/` directory and are automatically loaded when Claude Code starts a session in that project.

## How Claude Skills Work

When you invoke Claude Code in a project directory, it scans for skill files in several locations:

1. **Project skills**: `.claude/skills/` in your project root
2. **User skills**: `~/.claude/skills/` for personal skills that apply everywhere
3. **Organization skills**: Shared skills distributed through your team's configuration

Claude reads these files and incorporates their instructions into its context. When a task matches a skill's activation conditions, Claude applies the skill's rules automatically.

### Skill File Structure

A basic skill file looks like this:

```markdown
# Code Review Skill

## When to Use
Activate when the user asks for a code review, PR review, or feedback on code changes.

## Instructions
- Check for security vulnerabilities first
- Verify error handling is comprehensive
- Ensure tests cover edge cases
- Flag any hardcoded credentials or secrets
- Suggest performance improvements where applicable

## Style
- Be direct and specific
- Reference line numbers when pointing out issues
- Provide corrected code snippets, not just descriptions of problems
```

## Using Built-In Skills

Claude Code ships with several built-in skills that handle common development tasks. These are available immediately without any setup.

### The Commit Skill

The `/commit` skill analyzes your staged changes and generates a meaningful commit message:

```bash
# Stage your changes
git add src/auth.py tests/test_auth.py

# Use the commit skill
claude /commit
```

Claude examines the diff, understands the nature of the changes, and creates a commit message that accurately describes what changed and why.

### The Review PR Skill

The `/review-pr` skill provides a thorough code review of a pull request:

```bash
# Review a specific PR
claude /review-pr 142
```

This skill fetches the PR diff, analyzes the changes across all files, and provides feedback organized by severity.

## Creating Custom Skills

Custom skills are where Claude Code becomes truly powerful. You define exactly how Claude should handle tasks specific to your project.

### Step 1: Create the Skills Directory

```bash
mkdir -p .claude/skills
```

### Step 2: Write Your Skill File

Create a markdown file in `.claude/skills/`. The filename should describe the skill's purpose:

```bash
touch .claude/skills/api-endpoint-builder.md
```

### Step 3: Define the Skill

```markdown
# API Endpoint Builder

## When to Use
Activate when the user asks to create a new API endpoint, route, or handler.

## Instructions
1. Create the route handler in `src/routes/`
2. Add input validation using Zod schemas
3. Include error handling with proper HTTP status codes
4. Write integration tests in `tests/routes/`
5. Update the OpenAPI spec in `docs/openapi.yaml`

## Conventions
- Use async/await, never callbacks
- Return consistent response shapes: `{{ status, data, error }}`
- Log all requests using the project logger
- Rate limit all public endpoints

## Example
When asked "create an endpoint for user registration":

1. Create `src/routes/users/register.ts`
2. Define Zod schema for registration input
3. Implement handler with password hashing
4. Add test in `tests/routes/users/register.test.ts`
5. Add POST /users/register to OpenAPI spec
```

### Step 4: Test Your Skill

Start a new Claude Code session and make a request that matches your skill's activation conditions. Claude will automatically apply the skill's instructions.

## Combining Multiple Skills

Projects often benefit from multiple skills working together. For example, a web application might use:

- A **frontend skill** that enforces component patterns and styling conventions
- A **backend skill** that defines API design rules and database access patterns
- A **testing skill** that specifies test structure and coverage requirements
- A **deployment skill** that handles CI/CD pipeline configurations

Claude intelligently combines relevant skills based on the task at hand. If you ask it to build a feature that spans the frontend and backend, it applies both skills simultaneously.

## Sharing Skills with Your Team

Skills can be committed to your repository so every team member benefits:

```bash
# Add skills to version control
git add .claude/skills/
git commit -m "Add team Claude skills for API and testing patterns"
git push
```

When teammates pull the repository, Claude Code automatically picks up the shared skills. This ensures consistent AI-assisted development across the team.

## Common Patterns and Tips

### Be Specific Over General

Skills work best when they contain concrete, actionable instructions rather than vague guidelines. Instead of "write clean code," specify exactly what clean code means in your project:

```markdown
## Code Style Rules
- Maximum function length: 30 lines
- Maximum file length: 300 lines
- No more than 3 parameters per function
- Extract complex conditionals into named boolean variables
```

### Include Negative Examples

Telling Claude what NOT to do is just as important as telling it what to do:

```markdown
## Do Not
- Never use `any` type in TypeScript
- Never commit `.env` files
- Never use `SELECT *` in database queries
- Never disable ESLint rules inline without a comment explaining why
```

### Keep Skills Focused

Each skill should cover one area of responsibility. A skill that tries to cover everything becomes too broad to be effective. Split large skills into focused, composable pieces.

### Update Skills as Your Project Evolves

Skills should grow with your codebase. When you establish new conventions, update your skills to reflect them. When patterns change, revise the skill instructions accordingly.

## Troubleshooting

### Skills Not Activating

If a skill is not being applied:

- Verify the file is in the correct directory (`.claude/skills/`)
- Check that the file has a `.md` extension
- Ensure the "When to Use" section matches your request
- Try explicitly mentioning the skill's domain in your prompt

### Conflicting Skills

If two skills give contradictory instructions:

- Make activation conditions more specific so only one skill matches
- Add priority hints in the skill file
- Consolidate overlapping skills into a single file

### Skills Producing Unexpected Results

If Claude follows a skill but produces wrong output:

- Add more examples to the skill file
- Make instructions more explicit
- Remove ambiguous language
- Test with simple cases before complex ones

## Conclusion

Claude skills transform Claude Code from a general-purpose assistant into a specialized tool that understands your project's conventions, patterns, and requirements. By investing time in writing good skills, you get consistently better results and reduce the need to repeat instructions across conversations.

Start with one or two skills for your most common tasks, refine them based on results, and gradually expand your skill library as you discover new patterns worth codifying.

{% endraw %}

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Explained Simply for Non-Programmers](/claude-skills-guide/claude-skills-explained-simply-for-non-programmers/)
- [How to Share Claude Skills with Your Team](/claude-skills-guide/how-to-share-claude-skills-with-your-team/)
