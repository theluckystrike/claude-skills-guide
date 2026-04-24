---
layout: default
title: "Claude Md Template For New"
description: "A practical guide to using Claude MD templates for new projects. Learn how to structure prompts and use Claude skills like tdd, pdf, frontend-design, and."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, claude-md, starter-template, project-setup]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-md-template-for-new-projects-starter-guide/
geo_optimized: true
---
# Claude MD Template for New Projects Starter Guide

When you start a new project, having a solid prompt template saves time and ensures consistent results. [Claude MD templates are structured Markdown files that define how Claude should approach](/claude-skill-md-format-complete-specification-guide/) different types of project tasks. This guide walks you through creating and using these templates effectively, with real-world examples that apply across web apps, APIs, and backend services.

## What Is a Claude MD Template

[A Claude MD template is a Markdown file containing predefined prompts, instructions, and context that you can reuse across multiple projects.](/claude-skill-md-format-complete-specification-guide/) Unlike Claude skills which extend Claude's capabilities, MD templates focus on structuring your prompts for specific workflows. Think of them as reusable project blueprints. documents that carry your team's conventions, your tech stack preferences, and the exact phrasing that produces the output you want.

When you combine a template with skills like tdd or frontend-design, you get a powerful starting point for any project phase. The template provides context and structure; the skill provides the action.

The key insight is that Claude performs much better when it has explicit context upfront. A developer who pastes their stack, constraints, and patterns into a template before asking for code gets dramatically more useful output than one who starts from scratch each time.

## Creating Your First Template

Start by creating a templates folder in your project:

```
mkdir -p .claude/templates
touch .claude/templates/new-project.md
```

A basic template includes sections for project context, tech stack, and common tasks. Here is a practical example:

```markdown
Project Context
- Project name: [NAME]
- Framework: [FRAMEWORK]
- Language: [LANGUAGE]
- Node version: [VERSION]

Tech Stack
- Frontend: [DETAILS]
- Backend: [DETAILS]
- Database: [DETAILS]
- Auth: [DETAILS]

Code Conventions
- Use functional components (no class components)
- Prefer async/await over promise chains
- Export types from a central types/ directory
- All components must have JSDoc comments

Common Tasks
Generate component
Create a [COMPONENT_TYPE] component with props interface and basic styling.

Write test
Write unit tests using [TESTING_FRAMEWORK] for [MODULE_NAME].

Code review
Review [FILE_PATH] for performance issues and security concerns.
```

The `Code Conventions` section is what separates a useful template from a generic one. Claude will apply those rules without being asked again in each individual prompt.

## Why Conventions Belong in Your Template

Without conventions in your template, you will spend time correcting output: asking Claude to switch from class components to functional, or to use async/await instead of `.then()`. With a template, Claude absorbs your codebase's style once and applies it consistently.

Consider what happens across a two-week sprint without a template versus with one:

| Scenario | Without Template | With Template |
|---|---|---|
| Component generation | Must specify style each time | Applies team style automatically |
| Test generation | Must name testing framework each time | Uses correct framework from context |
| Error handling | May generate inconsistent patterns | Follows project's established pattern |
| Type usage | May skip TypeScript types | Generates proper interfaces from context |
| Import paths | Uses whatever convention | Matches your configured aliases |

That consistency compounds. By week two, the generated code needs far less manual adjustment.

## Using Templates with Claude Skills

Templates become powerful when paired with Claude skills. The tdd skill works exceptionally well with project templates:

```
/tdd create test-first development template for API endpoints using Jest
```

For frontend projects, combine your template with the frontend-design skill:

```
/frontend-design generate responsive component template following our design system
```

The pdf skill helps when you need to document your templates or extract requirements from existing documents:

```
/pdf extract project requirements from brief.md and format as template sections
```

The skill handles the mechanical work. scaffolding, formatting, reading files. while your template handles the context. Neither replaces the other.

## Template Structure for Different Project Types

## Web Application Template

```markdown
Web App Project Template

Architecture
- SPA or SSR: [CHOICE]
- State management: [CHOICE]
- API approach: [REST/GraphQL]

Scaffolding Commands
```
npm create vite@latest [PROJECT_NAME] -- --template [TYPE]
```

Common Patterns
Component structure
- Presentational components in /components
- Container components in /containers
- Hooks in /hooks

File naming
- Components: PascalCase (UserProfile.tsx)
- Hooks: camelCase with use prefix (useAuth.ts)
- Utilities: camelCase (formatDate.ts)

Error boundaries
Wrap route-level components in ErrorBoundary.
Log errors to Sentry using the logError() utility.
```

## API Project Template

```markdown
API Project Template

Endpoint Structure
- RESTful or GraphQL: [CHOICE]
- Authentication: [METHOD]
- Rate limiting: [DETAILS]

Standard Endpoints
- GET /resources - List all
- GET /resources/:id - Get one
- POST /resources - Create
- PUT /resources/:id - Update
- DELETE /resources/:id - Delete

Error Handling
Return standard error format:
```json
{
 "error": {
 "code": "ERROR_CODE",
 "message": "Human readable message"
 }
}
```

Middleware Stack
1. Request ID injection
2. Rate limiting
3. Auth verification
4. Request validation
5. Route handler
6. Error serializer
```

## CLI Tool Template

When building command-line tools, the template should capture flag conventions and output formats:

```markdown
CLI Tool Template

Command Structure
- Use commander.js or yargs for argument parsing
- Every command has --help, --verbose, and --dry-run flags
- Output in JSON when --json flag is passed
- Use chalk for colored terminal output

File Structure
- src/commands/. one file per command
- src/utils/. shared helpers
- src/config.ts. configuration loader
- test/. mirrors src/ structure

Output Conventions
- Success: green checkmark + message
- yellow triangle + message
- Error: red cross + message, exit code 1
```

## Documentation Template

Pair this with the supermemory skill to maintain project knowledge:

```
/supermemory create documentation template with API reference, examples, and troubleshooting sections
```

## Advanced Template Techniques

## Variables and Placeholders

Use consistent placeholder syntax across templates. The bracket convention works well because it is easy to search and replace:

```markdown
Replace [VARIABLE] with actual values before pasting
- [PROJECT_NAME] → my-awesome-app
- [COMPONENT_NAME] → UserCard
- [DB_TABLE] → users
```

Some teams go further and write a small shell script that accepts arguments and populates the template automatically:

```bash
#!/bin/bash
init-template.sh
PROJECT_NAME=$1
FRAMEWORK=$2
sed -e "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" \
 -e "s/\[FRAMEWORK\]/$FRAMEWORK/g" \
 .claude/templates/new-project.md > .claude/CONTEXT.md
echo "Template initialized at .claude/CONTEXT.md"
```

This turns your template into a proper initialization step you run once at project start.

## Including External Context

Reference other files in your template so Claude always has the full picture:

```markdown
See ./SPEC.md for full requirements
See ./ARCHITECTURE.md for system design
See ./DEPENDENCIES.md for package list
See ./api/openapi.yaml for API contracts
```

When you include references like this, you can ask Claude to read them: "Follow the patterns in ARCHITECTURE.md when creating this service." Claude will request those files and incorporate their content.

## Skill Chaining

Chain multiple skills within templates to define a complete workflow:

```
Deployment
Use /tdd to verify all tests pass before deploying, then use /pdf to generate release notes.

Feature completion checklist
1. /tdd. write tests first, confirm they fail
2. Implement the feature
3. /tdd. confirm tests pass
4. /frontend-design. review component for accessibility
5. /pdf. update the relevant docs section
```

Writing skill chains in your template documents your team's process and makes it executable.

## Organizing a Template Library

Keep templates focused and modular. Instead of one massive template, create smaller focused templates for different scenarios:

- `scaffold.md`. Initial project setup
- `component.md`. Component creation
- `test.md`. Testing workflow
- `deploy.md`. Deployment configuration
- `review.md`. Code review checklist
- `db-migration.md`. Database migration workflow
- `incident.md`. Incident response runbook

Each file stays short enough that you can paste the entire thing into a conversation without overwhelming the context. When you need multiple concerns, paste two small templates instead of maintaining one unwieldy one.

Version your templates and include a changelog. This helps team members understand what changed and why. A simple header block works:

```markdown
<!--
Template: component.md
Version: 1.3.0
Last updated: 2026-02-10
Changes: Added accessibility section after Q1 audit findings
-->
```

## Example Workflow

Here is how a typical session might flow using templates and skills:

```
1. Start new project:
 Paste scaffold.md into conversation
 Ask Claude to scaffold a React TypeScript project structure

2. Add first feature:
 Paste component.md into conversation
 /tdd create user authentication module with tests

3. Build component:
 /frontend-design create login form following material design

4. Document:
 /pdf generate API documentation from OpenAPI spec

5. Remember context:
 /supermemory store: [paste key architecture decisions here]

6. Review before merge:
 Paste review.md into conversation
 Ask Claude to review the PR diff for issues
```

Each step builds on the previous. By step six, Claude has accumulated context about your project conventions, your test setup, your component patterns, and your architecture decisions. That accumulated context makes the review substantially more useful than a generic code review.

## Common Mistakes to Avoid

Making templates too generic. A template that just says "use best practices" gives Claude nothing to work with. Spell out your specific conventions.

Never updating templates. When your stack or conventions change, update the template. Outdated templates produce code that diverges from the rest of the codebase.

Putting everything in one file. A 500-line template is hard to maintain and wastes context space. Break it up.

Skipping the tech stack section. Claude will make assumptions about your stack if you do not specify. Those assumptions is wrong. Always include exact versions for critical dependencies.

## Conclusion

Claude MD templates transform how you start new projects. By creating reusable prompt structures, you standardize your workflow and reduce repetitive setup time. Combine templates with skills like tdd, frontend-design, pdf, and supermemory to build a comprehensive project toolkit.

The best teams treat their templates as living documents. They refine them after each sprint when they notice Claude generating something that needed correction. Over time, the templates encode hard-won institutional knowledge about what works. and that knowledge carries forward into every new project automatically.

Start with one simple template, test it in your next project, and iterate. The best template is one you actually use.

## Step-by-Step Guide: Building Your Starter CLAUDE.md

Here is a concrete process for creating a CLAUDE.md template that your team actually uses.

Step 1. Interview your senior developers. Spend 30 minutes with each senior developer on your team asking two questions: What are the three things you most often have to correct in code reviews? What are the three things Claude Code does by default that do not match our conventions? Their answers become the core content of your CLAUDE.md. Claude Code compiles interview notes into a structured draft.

Step 2. Write the project overview section first. Start CLAUDE.md with a brief paragraph describing what the project does, its primary language and framework, and its deployment target. This context shapes every subsequent code generation decision. Claude Code uses this overview to infer appropriate defaults for things not explicitly specified.

Step 3. Document your directory structure. Explicitly list which directories contain what type of code and what file naming conventions apply in each. Developers and AI assistants both benefit from knowing where new files should go. Claude Code generates a directory tree with annotations explaining each directory's purpose and the file naming conventions expected within it.

Step 4. Add code generation constraints. List specific patterns you want enforced: always use dependency injection, never write raw SQL queries (use the ORM), always handle errors with the custom AppError class. These constraints produce the most immediate improvement in generated code quality. Claude Code can audit your existing codebase for violations and turn each violation category into a CLAUDE.md rule.

Step 5. Include examples of correct and incorrect patterns. For non-obvious conventions, pair the rule with a code example showing the right pattern and a comment explaining why the alternative is wrong. Claude Code generates these examples by extracting patterns from your existing codebase and presenting the most idiomatic version as the positive example.

## Common Pitfalls

Writing CLAUDE.md for an audience of developers rather than for Claude Code. CLAUDE.md is parsed by an AI, not a human. Prose that developers find clear ("follow good OOP principles") is too vague for Claude Code to act on. Every instruction should be concrete enough that you could write an automated test to check for compliance.

Including too much documentation context. If your CLAUDE.md tries to explain the business domain in depth, the coding instructions get diluted. Keep domain explanation to two or three sentences. Use a separate ADR (Architecture Decision Record) or wiki for deeper context that developers need but Claude Code does not.

Not updating CLAUDE.md when the tech stack changes. Outdated CLAUDE.md instructions that reference retired frameworks or deprecated patterns mislead Claude Code into generating code that does not compile. Assign ownership of CLAUDE.md to a specific team member and review it at the start of each sprint.

## Best Practices

Start with the smallest possible CLAUDE.md. A 50-line CLAUDE.md that your team consistently maintains beats a 500-line document that drifts out of date within a month. Add sections when you identify a repeated correction in code review rather than trying to anticipate everything upfront.

Use CLAUDE.md as onboarding documentation. New team members should read CLAUDE.md to understand how the team works. If your CLAUDE.md would embarrass you as onboarding documentation, it needs improvement. Claude Code can help you identify which sections are incomplete or unclear by asking it to summarize the project from the CLAUDE.md alone.

Pair CLAUDE.md with automated linting. Coding standards that can be automatically enforced should be in linter configuration, not CLAUDE.md. Reserve CLAUDE.md for the standards that require judgment. things that pass the linter but still violate your team's quality standards.

## Integration Patterns

Template repository with CLAUDE.md scaffolding. Create a GitHub template repository that includes a base CLAUDE.md for your organization's common standards. When teams create new projects from the template, they start with the organizational baseline and add project-specific rules. Claude Code helps generate the project-specific additions by analyzing the initial project description and tech stack.

Pre-commit hook compliance check. Claude Code generates a pre-commit hook that runs a static analysis check against your CLAUDE.md rules. The hook uses AST-based analysis for rules like required docstrings and consistent error handling patterns, and line-based analysis for simpler rules like banned imports and prohibited function names.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-template-for-new-projects-starter-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/)
- [Claude MD File Complete Guide: What It Does](/claude-md-file-complete-guide-what-it-does/)
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/)
- [Getting Started Hub](/getting-started-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


