---
title: "Install Claude Code Templates CLI Tool (2026)"
description: "Install the Claude Code Templates CLI with npx to browse and install 600+ agents, 200+ commands, and 55+ MCP configs. Full walkthrough with examples."
permalink: /how-to-install-claude-code-templates-cli-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Install Claude Code Templates CLI Tool (2026)

Claude Code Templates provides a CLI that installs pre-built agents, commands, hooks, MCP configurations, and settings into your Claude Code project. Here is how to set it up and use it.

## Prerequisites

- Node.js 18+ installed
- Claude Code installed
- A project directory to install templates into

## Step 1: Run the CLI

No global install needed — npx handles everything:

```bash
cd /path/to/your/project
npx claude-code-templates@latest
```

The CLI launches an interactive menu with categories:
- Agents (600+)
- Commands (200+)
- MCP Configurations (55+)
- Settings (60+)
- Hooks (39+)

## Step 2: Browse and Select a Category

Use arrow keys to navigate categories. Each category shows the total count and a brief description. Select a category to see its entries.

For your first install, start with **Agents** — they provide the most visible improvement to your Claude Code experience.

## Step 3: Install a Template

Browse entries within a category. Each shows:
- Name and description
- What files will be created or modified
- Any dependencies (MCP servers, packages)

Select an entry and confirm installation. The CLI copies the necessary files to your project:
- Agent templates create or modify your CLAUDE.md
- Command templates add files to `.claude/commands/`
- Hook templates modify `.claude/settings.json`
- MCP templates configure server connections
- Settings templates update Claude Code preferences

## Step 4: Verify Installation

Start Claude Code and test the installed template:

```bash
claude
```

For an agent template, give Claude a task that triggers the agent behavior. For a command template, run the new slash command. For hooks, trigger the event the hook responds to.

## Step 5: Browse the Web UI (Optional)

If you prefer browsing before installing, visit aitmpl.com. The web interface shows all templates with descriptions, preview of files, and installation instructions. Find what you want on the web, then install via CLI.

## Recommended Starter Templates

If you are unsure where to begin, install these five templates in order:

**1. General Coding Agent** — A balanced CLAUDE.md agent that improves code quality across languages. Good foundation for any project.

**2. Pre-commit Hook** — Automatically runs linting and formatting before Claude commits code. Catches style violations early.

**3. Code Review Command** — A `/review` slash command that gives consistent, thorough code reviews. Saves time on manual review.

**4. Filesystem MCP Config** — Gives Claude access to read files outside your project directory. Useful for referencing shared configs or documentation.

**5. TypeScript Strict Settings** — Enforces strict TypeScript conventions if you are working in a TS project.

## Managing Multiple Templates

As your template collection grows, keep track of what you have installed:

```bash
# List all installed commands
ls .claude/commands/

# Check your CLAUDE.md for agent rules
head -50 CLAUDE.md

# Review hook configuration
cat .claude/settings.json
```

When templates conflict (two agents with contradictory rules, or two hooks that modify the same file), resolve by prioritizing one and commenting out the other. The CLI does not handle conflict resolution automatically.

## Global vs Project Templates

Templates installed via the CLI land in your current project. For templates you want across all projects, install them in your user-level config:

```bash
# User-level commands (available everywhere)
mkdir -p ~/.claude/commands
cp .claude/commands/useful-command.md ~/.claude/commands/

# User-level settings (careful — affects all projects)
# Only put universal preferences in ~/.claude/settings.json
```

Keep project-specific templates in the project and universal tools in your user config. This prevents a testing hook for one project from running in every project.

## Troubleshooting

**CLI does not launch**: Ensure Node.js 18+ is installed. Run `node --version` to check. If npx hangs, try clearing the npm cache: `npm cache clean --force`.

**Template conflicts**: If a template modifies a file that already has custom content, the CLI warns you. Back up your existing files before proceeding, or manually merge the template content. A safe pattern: `cp CLAUDE.md CLAUDE.md.backup` before any agent install.

**MCP template needs a server**: Some MCP configurations require the actual MCP server to be installed separately. The CLI tells you which packages to install. Run the suggested `npm install` command before restarting Claude Code.

**Outdated templates**: Always use `@latest` to get the most recent versions. Templates are updated weekly. If you pinned a specific version, update with `npx claude-code-templates@latest`.

**Permission errors on macOS**: If npx fails with EACCES, do not use sudo. Instead, fix npm permissions: `mkdir ~/.npm-global && npm config set prefix '~/.npm-global'` and add `~/.npm-global/bin` to your PATH.

## Next Steps

- Compare Templates with [Awesome Toolkit](/claude-code-templates-vs-awesome-toolkit-2026/) for coverage differences
- Learn about [Claude Code hooks](/claude-code-hooks-explained/) to complement your templates
- Build a [custom CLAUDE.md](/claude-md-file-best-practices-guide/) that extends your installed agents
- Browse the [skills directory](/claude-skills-directory-where-to-find-skills/) for additional resources
