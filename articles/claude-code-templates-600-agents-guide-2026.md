---
layout: default
title: "Claude Code Templates (2026)"
description: "Install and use claude-code-templates — 600+ agents, 200+ commands, 55+ MCPs, and 60+ settings via CLI or web UI at aitmpl.com."
permalink: /claude-code-templates-600-agents-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Templates: 600+ Agents Guide (2026)

The `claude-code-templates` repository by davila7 packs 600+ agent configurations, 200+ slash commands, 55+ MCP server configs, 60+ settings presets, and 39+ hook definitions into one CLI tool. At 25K+ stars, it's the largest template library for Claude Code. Run `npx claude-code-templates@latest` to browse, or visit aitmpl.com for the web interface.

## What It Is

A CLI-driven template manager that scaffolds Claude Code configurations. Instead of writing CLAUDE.md rules, hook scripts, or MCP configs from scratch, you pick from a categorized library and the tool generates the files in your project.

The templates span:

- **Agents** — pre-configured behavioral profiles for specific roles (code reviewer, test writer, docs generator, security auditor)
- **Commands** — custom slash commands packaged as `.md` files in `.claude/commands/`
- **MCPs** — ready-to-use MCP server configurations for databases, APIs, and dev tools
- **Settings** — `.claude/settings.json` presets for different team sizes and workflows
- **Hooks** — pre/post execution hooks for linting, testing, and validation

## Why It Matters

Writing Claude Code configurations from zero is time-consuming and error-prone. You need to know the exact file structure, the right directive syntax, and which combinations work well together. This repo eliminates that bootstrapping cost.

The 600+ agent templates alone cover enough specializations that most teams can find a near-exact match for their use case and customize from there rather than starting blank.

## Installation

### Via npx (Recommended)

```bash
npx claude-code-templates@latest
```

This launches an interactive CLI that walks you through category selection, template preview, and installation.

### Global Install

```bash
npm install -g claude-code-templates
claude-code-templates
```

### Web Interface

Browse all templates with search and filtering at [aitmpl.com](https://aitmpl.com). The site shows full template previews and one-click copy for manual installation.

## Key Features

1. **600+ Agent Templates** — behavioral profiles for roles like `security-auditor`, `react-specialist`, `python-data-pipeline`, `api-designer`. Each template is a complete CLAUDE.md section.

2. **200+ Slash Commands** — pre-built command files for `.claude/commands/`. Includes `/review`, `/test-plan`, `/refactor`, `/document`, and domain-specific commands.

3. **55+ MCP Configurations** — ready-to-paste configs for popular MCP servers (PostgreSQL, Redis, GitHub, Jira, Notion, Slack). Each config includes the server binary path and required environment variables.

4. **60+ Settings Presets** — `.claude/settings.json` files tuned for solo developers, small teams, enterprise environments, and specific workflows (TDD, code review, documentation).

5. **39+ Hook Definitions** — pre/post hooks for common tasks: run ESLint before committing, execute tests after file changes, validate API schemas, check for secrets.

6. **Interactive CLI** — category browsing, fuzzy search, template preview, and diff view before installation.

7. **Composable Templates** — install multiple templates that layer on top of each other. The CLI handles merge conflicts in CLAUDE.md sections.

8. **Version Pinning** — templates tagged with the Claude Code version they target, so you don't install configs that rely on features your version doesn't support.

## Real Usage Example

### Scaffolding a Full-Stack Project

```bash
$ npx claude-code-templates@latest

? Select category: Agents
? Select subcategory: Full Stack
? Select template: nextjs-fullstack-agent

Installing template...
  ✓ Created .claude/CLAUDE.md (agent behavioral rules)
  ✓ Created .claude/commands/review.md
  ✓ Created .claude/commands/test-plan.md
  ✓ Created .claude/settings.json
  ✓ Created .claude/hooks/pre-commit-lint.sh

Template installed. Start Claude Code to activate.
```

The generated CLAUDE.md includes:

```markdown
# Next.js Full-Stack Agent

## Behavioral Rules
- Use App Router, not Pages Router
- Server Components by default; add 'use client' only when state/effects are needed
- Data fetching in Server Components using async/await, not useEffect
- API routes in /app/api/ using Route Handlers
- Styling with Tailwind CSS utility classes

## Code Standards
- TypeScript strict mode, no 'any' types
- Zod validation on all API inputs
- Error boundaries around client component trees
- Loading.tsx and error.tsx files for every route segment
```

### Installing Just a Hook

```bash
$ npx claude-code-templates@latest

? Select category: Hooks
? Select template: pre-commit-test-runner

Installing hook...
  ✓ Created .claude/hooks/pre-commit-test.sh
  ✓ Updated .claude/settings.json (hook registration)
```

## When To Use

- **New project setup** — get a production-quality Claude Code config in under a minute
- **Exploring Claude Code capabilities** — browse the template library to discover features you didn't know existed
- **Standardizing team configurations** — pick a template, customize it, and distribute across repos
- **Learning configuration patterns** — read the generated files to understand how CLAUDE.md rules, hooks, and commands interact
- **Rapid prototyping** — install a domain-specific agent and start coding immediately

## When NOT To Use

- **Mature projects with established configs** — if your CLAUDE.md is already tuned, templates may overwrite your customizations
- **Minimal setups** — if you only need 3-4 rules, writing them by hand is faster than running the CLI
- **Offline environments** — the CLI fetches templates from the registry; no network means no templates (clone the repo for offline use)
- **Highly custom workflows** — templates cover common patterns; if your setup is unusual, you'll spend more time modifying a template than writing from scratch

## FAQ

### Can I contribute templates?

Yes. The repo accepts PRs following the template schema defined in `CONTRIBUTING.md`. Each template needs a category, description, compatibility tag, and the actual config files.

### Do templates auto-update?

No. Once installed, templates are local files in your project. Run `npx claude-code-templates@latest` again to check for updated versions and selectively reinstall.

### Can I combine multiple agent templates?

The CLI supports installing multiple templates sequentially. It appends CLAUDE.md sections rather than overwriting. For hooks and settings, it merges configurations.

### What happens to my existing CLAUDE.md?

The CLI detects existing files and offers three options: append, replace, or skip. It shows a diff preview before any write operation.

### Are the MCP configs secure?

The configs include placeholder values for secrets (API keys, tokens). You must fill in your own credentials. The templates never ship with real secrets.

## Our Take

**8/10.** The sheer volume of templates makes this the fastest way to bootstrap a Claude Code project. The CLI is polished and the web UI at aitmpl.com is a nice touch for browsing. Loses points because template quality varies — the top 100 agents are excellent, but deep in the catalog you'll find templates that are barely modified copies of each other. Stick to the high-star templates or use the web UI's sort-by-popularity filter.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Resources

**Quick setup →** Launch your project with our [Project Starter](/starter/).

- [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/) — understand the hooks these templates generate
- [MCP Setup Guide](/mcp-servers-claude-code-complete-setup-2026/) — configure the MCP servers referenced in templates
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — how to maintain the generated CLAUDE.md files

## See Also

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Templates vs Awesome Toolkit (2026)](/claude-code-templates-vs-awesome-toolkit-2026/)
