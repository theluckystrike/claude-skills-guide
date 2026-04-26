---

layout: default
title: "How to Use Local Development Setup (2026)"
description: "A practical guide to setting up Claude Code for local development, including environment configuration, skill integration, and optimization tips."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-local-development-setup-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Setting up Claude Code for local development transforms your terminal into an intelligent coding assistant. This guide walks through the complete setup process, from installation to advanced configuration that unlocks the full potential of Claude Code for your development workflow. Rather than covering only the happy path, this guide addresses the real friction points. environment quirks, permission systems, skill orchestration, and monorepo layouts. that developers encounter after the initial install.

## Prerequisites and Initial Installation

Before beginning, ensure you have Node.js 18+ and npm installed. Claude Code operates as a local CLI tool, giving you direct access to AI-assisted coding without relying on web interfaces.

Install Claude Code globally using npm:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation by running:

```bash
claude --version
```

The CLI should respond with the current version number. If you encounter permission errors on macOS or Linux, the most reliable fix is correcting your npm prefix rather than using `sudo`:

```bash
Check current prefix
npm config get prefix

Move it to a user-owned location (run once)
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global

Add to your shell profile (~/.zshrc or ~/.bashrc)
export PATH=~/.npm-global/bin:$PATH

Reload and reinstall
source ~/.zshrc
npm install -g @anthropic-ai/claude-code
```

Using `sudo npm install -g` works but creates files owned by root, which causes permission cascades on future updates. The prefix fix is the permanent solution.

## API Key Setup

Claude Code requires an Anthropic API key to function. Set it in your shell profile so it persists across sessions:

```bash
Add to ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

Verify Claude Code can reach the API:

```bash
claude "Say hello in one sentence"
```

If this returns a response, your installation is complete. If it times out, check whether your network requires a proxy. Claude Code respects the `HTTPS_PROXY` environment variable.

## Understanding the CLAUDE.md File

Before diving into settings files, understand the most important configuration mechanism: `CLAUDE.md`. This Markdown file, placed in your project root (or `~/.claude/CLAUDE.md` for global settings), is read automatically at the start of every Claude Code session. It gives Claude persistent context about your project without you having to re-explain conventions each time.

A well-crafted `CLAUDE.md` file covers:

```markdown
Project: Payments API

Stack
- Node.js 20, TypeScript 5.4
- Express 4, Prisma ORM, PostgreSQL 15
- Jest for testing, ESLint + Prettier for linting

Conventions
- Use async/await, never callbacks
- All database access goes through the repository layer in src/repositories/
- New endpoints require an integration test in tests/integration/
- Environment variables are documented in .env.example

Common Commands
- `npm run dev`. start dev server with hot reload
- `npm test`. run full test suite
- `npm run migrate`. run pending Prisma migrations

Do Not Touch
- Never modify generated files in src/generated/
- Never commit .env files. use .env.local instead
```

This file is the difference between Claude giving generic advice and Claude giving advice that fits your actual project. Spend 10 minutes writing it when you set up a new project.

## Project-Specific Configuration

Create a `claude-settings.json` file in your project root to configure Claude Code behavior per-project. This file controls which files Claude can read, write, and execute, providing granular control over the AI's capabilities.

```json
{
 "permissions": {
 "allow": ["./src/", "./tests/", "./package.json"],
 "deny": ["./secrets/", "./.env*"]
 },
 "env": {
 "NODE_ENV": "development"
 }
}
```

The permissions system ensures Claude Code respects your project's boundaries. You can explicitly grant read access to source directories while blocking sensitive areas like environment files or credentials.

## Permission Patterns That Matter

The `deny` list deserves careful attention. A solid baseline for most projects:

```json
{
 "permissions": {
 "allow": [
 "./src/",
 "./tests/",
 "./scripts/",
 "./package.json",
 "./tsconfig.json",
 "./.eslintrc*",
 "./Dockerfile"
 ],
 "deny": [
 "./.env",
 "./.env.*",
 "./secrets/",
 "./*.pem",
 "./*.key",
 "./node_modules/",
 "./dist/",
 "./.git/"
 ]
 }
}
```

The `node_modules` and `dist` exclusions keep Claude's context focused. it should be reading your source, not generated output. The `.git` exclusion prevents accidental modification of Git history.

## Integrating Claude Skills

Claude Code gains superpowers through skill integrations. Skills extend the CLI with specialized capabilities for different development tasks. The skill system loads automatically based on your current working directory or can be invoked explicitly.

Skills live in `~/.claude/skills/` for global availability, or `.claude/skills/` within a project for project-scoped skills. Each skill is a Markdown file that gives Claude specific instructions, conventions, and tool usage patterns for a domain.

## PDF Manipulation with the pdf Skill

The pdf skill enables programmatic PDF creation and editing. Install it by creating a skills directory in your project:

```bash
mkdir -p .claude/skills
```

Create a skill definition file at `.claude/skills/pdf.md`:

```markdown
---
name: pdf
description: Work with PDF documents using pdfkit or puppeteer
---

PDF Generation

When generating PDFs, prefer pdfkit for programmatic documents
and puppeteer for HTML-to-PDF conversions.

Always include proper page margins (40pt minimum) and embed fonts
to ensure portability across systems.
```

Once configured, you can instruct Claude to generate reports, invoices, or documentation directly as PDF files without re-explaining your preferred library in each session.

## Test-Driven Development with tdd

The tdd skill streamlines the test-first development workflow. It creates test files alongside your source code, runs tests automatically, and helps debug failures. Activate it by mentioning "using tdd" in your request:

```
claude "Create a user authentication module using tdd"
```

The skill generates test cases before implementation, ensuring your code meets requirements from the start. A project-level tdd skill can encode your specific testing conventions:

```markdown
---
name: tdd
description: Test-driven development for this project
---

TDD Conventions

Test files go in tests/ mirroring src/ structure.
src/auth/login.ts -> tests/auth/login.test.ts

Use Jest with the following patterns:
- describe blocks for each exported function
- it() descriptions start with "should"
- Mock external dependencies with jest.mock()
- Use beforeEach for setup, afterEach for cleanup

Always run `npm test -- --testPathPattern=FILENAME` after
generating tests to verify they fail before implementing.
```

## Frontend Design with frontend-design

The frontend-design skill assists with UI component creation, responsive layouts, and design system implementation. It understands modern frameworks like React, Vue, and Tailwind CSS. When working on front-end features, invoke it explicitly:

```
claude "Build a dashboard component using frontend-design"
```

This skill provides design suggestions, generates accessible markup, and ensures consistency with common design patterns. For design-system-aware projects, encode your token names:

```markdown
---
name: frontend-design
description: React + Tailwind component generation
---

Design System

Colors: use only design system tokens (primary-500, neutral-200, etc.)
Typography: text-sm / text-base / text-lg. avoid arbitrary sizes
Spacing: use 4/8/12/16/24/32/48 scale only
Components: check src/components/ui/ before creating new ones
Accessibility: all interactive elements need aria-labels and keyboard handlers
```

## Memory Management with supermemory

The supermemory skill maintains context across sessions. It indexes your codebase, remembers previous discussions, and retrieves relevant information when needed. This proves invaluable for large projects where you return to specific features days later.

Configure memory persistence in your `claude-settings.json`:

```json
{
 "memory": {
 "enabled": true,
 "indexPaths": ["./src", "./docs"],
 "excludePaths": ["./node_modules", "./dist"]
 }
}
```

Memory is most valuable when working on a large codebase where the same architectural patterns repeat. Instead of re-explaining "our services use the repository pattern, repositories are in src/repositories/" every session, the memory skill recalls this from previous conversations.

## Environment Variables and API Keys

For production workflows, you may need to provide Claude Code with API access. Never commit API keys to your repository. Instead, use environment variables that Claude Code can access securely:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

Claude Code respects your shell's environment variables. For project-specific secrets, use a `.env.local` file and ensure it is listed in your `.gitignore`.

## Layered Environment Variable Strategy

Most projects need different values in development, staging, and production. A clean layering approach:

```
.env # committed. default values, no secrets
.env.local # gitignored. developer overrides
.env.test # committed. test-specific non-secrets
.env.production # never committed. production secrets via CI/CD
```

Add this to your `.gitignore`:

```
.env.local
.env.production
.env.*.local
*.pem
*.key
```

When Claude Code generates code that reads environment variables, it will follow whatever pattern you document in your `CLAUDE.md`. If you specify "use dotenv with the `.env.local` override pattern," Claude generates `require('dotenv').config({ path: '.env.local' })` automatically.

## Custom Command Aliases

Speed up your workflow with shell aliases for common Claude Code commands. Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
alias cc="claude"
alias ccr="claude --resume"
alias ccs="claude --stop"
```

The `--resume` flag continues interrupted sessions, maintaining the previous context window. This is particularly useful when you close a terminal mid-session and want to pick up exactly where you left off.

For project-level aliases, consider a `Makefile` or `package.json` scripts section:

```json
{
 "scripts": {
 "ai": "claude",
 "ai:review": "claude 'Review the staged changes and suggest improvements'",
 "ai:test": "claude 'Write tests for any untested functions in src/'"
 }
}
```

Running `npm run ai:review` before every commit builds a habit of AI-assisted code review without requiring any typing.

## Working with Git Integration

Claude Code integrates with Git for version control workflows. Stage and commit changes through natural language:

```
claude "Commit the new authentication feature"
```

The CLI understands Git semantics and will propose appropriate commit messages based on your changes. For code review workflows, ask Claude to explain changes before committing:

```
claude "Show me what changed in the auth module"
```

## Pre-Commit Review Workflow

A practical pattern is to run Claude Code as part of a pre-commit review step:

```bash
Before every commit, stage your changes then ask Claude to review
git add -p # interactive staging
claude "Review the staged diff for bugs, security issues, and style"
```

Claude will flag issues like:
- SQL injection risks from string concatenation
- Missing error handling on async functions
- Hardcoded values that should be configuration
- Missing input validation on new endpoints

This catches issues that linters miss because Claude understands intent, not just syntax. For teams, codifying this in a `CONTRIBUTING.md` as a recommended step (not a required hook) maintains developer autonomy while improving review quality.

## Writing Commit Messages

Claude Code follows your project's commit message conventions if you document them in `CLAUDE.md`:

```markdown
Commit Messages
Follow Conventional Commits: feat/fix/chore/docs/refactor/test
feat(auth): add OAuth2 login with Google
Keep subject under 72 characters, body explains the why not the what.
```

With this context, `claude "Commit the changes"` produces properly formatted commit messages matching your team's style.

## Performance Optimization

Large codebases benefit from optimized configuration. Limit the context window for faster responses by restricting file scanning:

```json
{
 "context": {
 "maxFiles": 50,
 "maxTokens": 100000
 }
}
```

For monorepos, create separate `claude-settings.json` files in each workspace to maintain focused context per component.

## Monorepo Layout

In a typical monorepo with multiple packages, scope Claude's context to the package you are actively working on:

```
my-monorepo/
 packages/
 api/
 claude-settings.json # scoped to api/src, api/tests
 CLAUDE.md # API-specific conventions
 web/
 claude-settings.json # scoped to web/src, web/components
 CLAUDE.md # frontend conventions
 shared/
 claude-settings.json # scoped to shared/src
 CLAUDE.md # monorepo-wide conventions
```

Claude reads `CLAUDE.md` files from the current directory up to the root, merging them. This means your root `CLAUDE.md` can document monorepo-wide patterns (like "use pnpm workspaces, not npm") while package-level files document local conventions.

## Excluding Generated Code

A common performance bottleneck is Claude scanning generated files. Be explicit in your settings:

```json
{
 "permissions": {
 "deny": [
 "./node_modules/",
 "./dist/",
 "./build/",
 "./.next/",
 "./coverage/",
 "./src/generated/",
 "./__generated__/"
 ]
 }
}
```

Generated GraphQL types, Prisma client files, and compiled JavaScript all add noise without value. Excluding them keeps responses faster and more accurate.

## Troubleshooting Common Issues

If Claude Code fails to respond, check your network connection first. the CLI requires internet access for API calls. Permission errors typically stem from incorrect file ownership; verify your project directories are writable.

For persistent issues, run with verbose logging:

```bash
claude --verbose "your request"
```

This outputs detailed diagnostics that help identify configuration problems or missing dependencies.

## Issue Reference

| Symptom | Likely Cause | Fix |
|---|---|---|
| `EACCES` on install | npm prefix owned by root | Reset npm prefix to user directory |
| `401 Unauthorized` | Invalid or missing API key | Verify `ANTHROPIC_API_KEY` is set and correct |
| Slow responses | Large context / many files | Add exclusions to `deny` list, lower `maxFiles` |
| Claude ignores conventions | No `CLAUDE.md` | Create `CLAUDE.md` in project root |
| Skills not loading | Wrong file location | Check `~/.claude/skills/` or `.claude/skills/` |
| Session context lost | No `--resume` flag | Use `claude --resume` to continue previous session |
| Hangs on startup | Proxy required | Set `HTTPS_PROXY` environment variable |

## Resetting a Broken Session

If a session gets into a bad state (Claude is confused about the project state or stuck in a loop), reset cleanly:

```bash
End the current session
claude --stop

Start fresh (omit --resume)
claude "Start fresh. ..."
```

For reproducible workflows, consider scripting your session start with an initial context prompt that re-establishes project state:

```bash
#!/bin/bash
start-claude.sh. standard session opener for this project
claude "You are working on the Payments API (Node.js/TypeScript).
Read CLAUDE.md for conventions. The current task is: $1"
```

## Conclusion

Claude Code becomes genuinely powerful when properly configured. Project-specific settings, skill integrations, and environment configuration transform it from a simple CLI into an intelligent development partner. Start with basic setup, then gradually add skills and customization as your workflow matures.

The highest-value setup steps in order of impact: write a thorough `CLAUDE.md`, add explicit `deny` rules to keep context focused, create project-specific skills for your most repeated workflows, and wire Claude into your pre-commit review loop. Each step compounds on the previous. a well-described project with focused context and domain-aware skills produces dramatically better results than a default install against the same codebase.

The investment in proper configuration pays dividends through faster development cycles, consistent code quality, and reduced context-switching between documentation and implementation.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-local-development-setup-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/). Setting up Claude Code as part of local dev
- [Claude Code Environment Setup Automation](/claude-code-environment-setup-automation/). Automate your local development environment
- [Claude Code Dotenv Configuration Workflow](/claude-code-dotenv-configuration-workflow/). .env files are essential for local dev
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/). Start here for first-time setup

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Get started →** Generate your project setup with our [Project Starter](/starter/).

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).
