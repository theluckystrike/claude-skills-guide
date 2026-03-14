---
layout: default
title: "Claude MD Template for New Projects Starter Guide"
description: "A practical guide to using Claude MD templates for new projects. Learn how to structure prompts and use Claude skills like tdd, pdf, frontend-design, and supermemory for faster development."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, claude-md, starter-template, project-setup]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude MD Template for New Projects Starter Guide

When you start a new project, having a solid prompt template saves time and ensures consistent results. [Claude MD templates are structured Markdown files that define how Claude should approach](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) different types of project tasks. This guide walks you through creating and using these templates effectively.

## What Is a Claude MD Template

A Claude MD template is a Markdown file containing predefined prompts, instructions, and context that you can reuse across multiple projects. Unlike Claude skills which extend Claude's capabilities, MD templates focus on structuring your prompts for specific workflows. Think of them as reusable project blueprints.

When you combine a template with skills like **tdd** or **frontend-design**, you get a powerful starting point for any project phase.

## Creating Your First Template

Start by creating a templates folder in your project:

```
mkdir -p .claude/templates
touch .claude/templates/new-project.md
```

A basic template includes sections for project context, tech stack, and common tasks. Here is a practical example:

```markdown
# Project Context
- Project name: [NAME]
- Framework: [FRAMEWORK]
- Language: [LANGUAGE]

# Tech Stack
- Frontend: [DETAILS]
- Backend: [DETAILS]
- Database: [DETAILS]

# Common Tasks
## Generate component
Create a [COMPONENT_TYPE] component with props interface and basic styling.

## Write test
Write unit tests using [TESTING_FRAMEWORK] for [MODULE_NAME].

## Code review
Review [FILE_PATH] for performance issues and security concerns.
```

## Using Templates with Claude Skills

Templates become powerful when paired with Claude skills. The **tdd** skill works exceptionally well with project templates:

```
/tdd create test-first development template for API endpoints using Jest
```

For frontend projects, combine your template with the **frontend-design** skill:

```
/frontend-design generate responsive component template following our design system
```

The **pdf** skill helps when you need to document your templates or extract requirements from existing documents:

```
/pdf extract project requirements from brief.md and format as template sections
```

## Template Structure for Different Project Types

### Web Application Template

```markdown
# Web App Project Template

## Architecture
- SPA or SSR: [CHOICE]
- State management: [CHOICE]
- API approach: [REST/GraphQL]

## Scaffolding Commands
```
npm create vite@latest [PROJECT_NAME] -- --template [TYPE]
```

## Common Patterns
### Component structure
- Presentational components in /components
- Container components in /containers
- Hooks in /hooks

### File naming
- Components: PascalCase (UserProfile.tsx)
- Hooks: camelCase with use prefix (useAuth.ts)
- Utilities: camelCase (formatDate.ts)
```

### API Project Template

```markdown
# API Project Template

## Endpoint Structure
- RESTful or GraphQL: [CHOICE]
- Authentication: [METHOD]

## Standard Endpoints
- GET /resources - List all
- GET /resources/:id - Get one
- POST /resources - Create
- PUT /resources/:id - Update
- DELETE /resources/:id - Delete

## Error Handling
Return standard error format:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```
```

### Documentation Template

Pair this with the **supermemory** skill to maintain project knowledge:

```
/supermemory create documentation template with API reference, examples, and troubleshooting sections
```

## Advanced Template Techniques

### Variables and Placeholders

Use consistent placeholder syntax across templates:

```markdown
# Replace [VARIABLE] with actual values
# Example:
# - [PROJECT_NAME] → my-awesome-app
# - [COMPONENT_NAME] → UserCard
```

### Including External Context

Reference other files in your template:

```markdown
# See ./SPEC.md for full requirements
# See ./ARCHITECTURE.md for system design
# See ./DEPENDENCIES.md for package list
```

### Skill Chaining

Chain multiple skills within templates:

```
## Deployment
Use /tdd to verify all tests pass before deploying, then use /pdf to generate release notes.
```

## Best Practices

Keep templates focused and modular. Instead of one massive template, create smaller focused templates for different scenarios:

- `scaffold.md` - Initial project setup
- `component.md` - Component creation
- `test.md` - Testing workflow
- `deploy.md` - Deployment configuration
- `review.md` - Code review checklist

Version your templates and include a changelog. This helps team members understand what changed and why.

## Example Workflow

Here is how a typical session might flow using templates and skills:

```
1. Start new project:
   Ask Claude to scaffold a React TypeScript project structure

2. Add first feature:
   /tdd create user authentication module with tests

3. Build component:
   /frontend-design create login form following material design

4. Document:
   /pdf generate API documentation from OpenAPI spec

5. Remember context:
   /supermemory save project architecture decisions
```

## Conclusion

Claude MD templates transform how you start new projects. By creating reusable prompt structures, you standardize your workflow and reduce repetitive setup time. Combine templates with skills like **tdd**, **frontend-design**, **pdf**, and **supermemory** to build a comprehensive project toolkit.

Start with one simple template, test it in your next project, and iterate. The best template is one you actually use.

## Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)
- [Claude MD File Complete Guide: What It Does](/claude-skills-guide/claude-md-file-complete-guide-what-it-does/)
- [How to Write Effective CLAUDE.md for Your Project](/claude-skills-guide/how-to-write-effective-claude-md-for-your-project/)
- [Getting Started Hub](/claude-skills-guide/getting-started-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
