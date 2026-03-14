---
layout: default
title: "Best Way to Set Up Claude Code for a New Project"
description: "A practical guide to configuring Claude Code for new projects. Learn how to create CLAUDE.md files, organize project context, and leverage skills like supermemory, frontend-design, and tdd for faster development."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-md, project-setup, claude-skills, supermemory, frontend-design, tdd]
author: theluckystrike
reviewed: true
score: 9
permalink: /best-way-to-set-up-claude-code-for-new-project/
---

# Best Way to Set Up Claude Code for a New Project

Setting up Claude Code correctly from day one determines how effectively it assists throughout your project lifecycle. A well-configured project means Claude understands your stack, coding conventions, and project structure — resulting in higher-quality code with less iteration. This guide covers the practical steps to configure Claude Code for new projects.

## Create Your CLAUDE.md File

The CLAUDE.md file serves as the primary configuration mechanism. Place it in your project root, and Claude automatically reads it when working in that directory. This file replaces the need for lengthy prompt explanations in every session.

```markdown
# Project Overview
- Project name: MyApp
- Type: Full-stack web application
- Stack: Next.js 14, PostgreSQL, Prisma, TypeScript
- Core functionality: E-commerce platform with real-time inventory

# Development Guidelines
- Use functional components with TypeScript
- Prefer async/await over .then() chains
- All API routes go in /app/api/

# Testing Requirements
- Minimum 80% code coverage
- Use Vitest for unit tests, Playwright for e2e
- Run tests before every commit
```

The file supports environment-specific sections. Add a `.claude/` folder with context files for more complex setups, or reference external documentation that Claude should follow.

## Install Essential Skills Immediately

Skills extend Claude's capabilities for domain-specific tasks. For a new project, install these skills right after initialization:

The **supermemory** skill helps maintain persistent context across sessions. Rather than re-explaining your project architecture in every session, supermemory stores project knowledge and automatically provides relevant context when needed.

```bash
claude /skill install supermemory
```

The **tdd** skill enforces test-driven development workflows. When working on new features, invoke it to ensure tests are written before implementation:

```
/tdd write user authentication module
```

For frontend work, the **frontend-design** skill provides component design patterns and accessibility guidelines:

```
/frontend-design create login form component
```

The **pdf** skill proves valuable when generating project documentation, API docs, or technical specifications:

```
/pdf generate API documentation
```

Install additional skills based on your stack. A Python project benefits from data workflow skills; a Go project needs Go-specific patterns loaded.

## Configure Project-Specific Settings

Beyond CLAUDE.md, several configuration options shape how Claude interacts with your project.

### Allowed Directories

Restrict Claude's file access to relevant directories. In your CLAUDE.md:

```
Allowed directories: /src, /tests, /config
```

This prevents accidental modifications to node_modules or other non-project files.

### Execution Permissions

Define which commands Claude can run:

```
Allowed commands: npm, npx, git, docker, npm run
```

You can expand permissions as trust builds, but starting restrictive prevents unintended deployments or destructive operations.

### Tool Restrictions

For sensitive projects, limit available tools:

```
Disabled tools: Bash(rm -rf), Edit(write_file)
```

## Set Up Context Files

Large projects benefit from organized context files in a `.claude/` directory:

```
.claude/
├── architecture.md      # System design decisions
├── api-spec.md          # API contracts and endpoints
├── database-schema.md  # Database structure
└── coding-standards.md  # Language-specific conventions
```

Reference these files in your CLAUDE.md to keep the root file clean:

```
See .claude/architecture.md for system design details.
```

## Initialize Git Repository Early

Initialize git before writing significant code:

```bash
git init
git add .
git commit -m "Initial project structure"
```

This creates a clean baseline. Claude can then track changes, understand your version control workflow, and help with commit messages using conventional commits:

```
/conventional-commit create user login feature
```

## Configure Environment Variables

Store environment variable templates in `.env.example` (never commit actual secrets). Document required variables in CLAUDE.md:

```
Environment variables required:
- DATABASE_URL: PostgreSQL connection string
- API_KEY: External service authentication
- NODE_ENV: development | production
```

Claude can then validate your `.env` file against requirements and flag missing variables before they cause runtime errors.

## Project Structure Conventions

Establish clear directory organization from the start. Common patterns include:

```
src/
├── components/     # Reusable UI components
├── lib/           # Utility functions
├── services/      # Business logic
├── hooks/         # Custom React hooks
├── types/         # TypeScript definitions
tests/
├── unit/          # Unit tests
├── integration/  # Integration tests
├── e2e/          # End-to-end tests
```

Document your chosen structure in CLAUDE.md. Claude will then respect your organization when generating new files.

## Enable Automatic Context Loading

With supermemory skill installed, configure it to automatically load project context:

```bash
claude /skill config supermemory --auto-load true
```

This means every new session starts withClaude understanding your project without manual context sharing. The skill maintains awareness of your tech stack, recent changes, and architectural decisions.

## Verify Your Setup Works

After initial configuration, run a quick validation:

1. Start a new Claude session in your project
2. Ask: "What is this project's tech stack?"
3. Verify it reads your CLAUDE.md correctly
4. Test a skill: "/tdd explain the testing workflow"
5. Confirm environment variable awareness

If responses lack context, check your CLAUDE.md syntax and ensure it's in the correct location.

## Iterative Improvement

Your CLAUDE.md evolves with the project. Update it when:

- New dependencies are added
- Architecture decisions change
- Coding standards are revised
- Team members join (document their conventions)

A well-maintained CLAUDE.md compounds in value over time, making each subsequent session more productive than the last.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
