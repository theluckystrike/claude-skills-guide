---
layout: default
title: "Claude Code Config Hierarchy Explained (2026)"
description: "Understand how Claude Code resolves configuration from organization, user, and project levels, with precedence rules and override patterns."
permalink: /claude-code-configuration-hierarchy-explained-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Configuration Hierarchy Explained (2026)

Claude Code reads configuration from multiple locations. When two settings conflict, one wins. Understanding which level takes precedence prevents confusion when rules seem to be ignored or overridden.

## The Three Configuration Levels

### Level 1: Organization (Highest Priority)
Enterprise-managed settings pushed to all users. Set by admins, not editable by individual developers.

**Location:** Managed through Anthropic's organization settings or pushed via MDM (Mobile Device Management).

**What it controls:**
- Allowed/blocked MCP servers
- Permission policies (which tools Claude Code can use)
- Data handling rules
- Model selection restrictions

### Level 2: User
Personal settings that apply across all your projects.

**Location:** `~/.claude/settings.json` and `~/.claude/CLAUDE.md`

**What it controls:**
- Default hooks for all projects
- Personal MCP server connections (GitHub, memory)
- Global behavioral preferences
- Cross-project conventions

### Level 3: Project (Lowest Priority for Settings, Highest for CLAUDE.md)
Project-specific configuration checked into your repository.

**Locations:**
- `.claude/settings.json` — Project hooks, MCP servers
- `CLAUDE.md` — Project-specific behavioral rules (root and subdirectories)

**What it controls:**
- Project-specific hooks
- Project-specific MCP servers
- Architecture, conventions, and coding rules
- Directory-level overrides via nested CLAUDE.md files

## Precedence Rules

### For settings.json

```
Organization > User > Project
```

Organization settings always win. If your org blocks a specific MCP server, your user or project config cannot enable it.

For hooks, the behavior is additive — project hooks run alongside user hooks, not instead of them.

### For CLAUDE.md

```
Closest CLAUDE.md to the working file wins
```

CLAUDE.md files cascade. If `CLAUDE.md` at the root says "use camelCase" and `src/legacy/CLAUDE.md` says "use snake_case," files in `src/legacy/` follow snake_case.

## File Locations

```
Organization:
  (managed externally — not a file you edit)

User:
  ~/.claude/
  ├── settings.json     # User hooks, MCP servers, permissions
  ├── CLAUDE.md         # Global behavioral rules
  └── commands/         # Global slash commands
      └── review.md

Project:
  your-repo/
  ├── .claude/
  │   ├── settings.json # Project hooks, MCP servers
  │   └── commands/     # Project slash commands
  │       └── deploy.md
  ├── CLAUDE.md         # Root project rules
  └── src/
      └── legacy/
          └── CLAUDE.md # Directory-specific overrides
```

## What Goes Where

### User Level (~/.claude/)

Put things that apply to ALL your projects:

```json
// ~/.claude/settings.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..." }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

```markdown
<!-- ~/.claude/CLAUDE.md -->
## Global Preferences
- I prefer TypeScript over JavaScript
- Use pnpm, not npm or yarn
- Write tests for all new functions
- Commit messages: conventional commits format
```

### Project Level (.claude/ and CLAUDE.md)

Put things specific to THIS project:

```json
// .claude/settings.json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx eslint --fix $FILE 2>/dev/null"
    }]
  },
  "mcpServers": {
    "project-db": {
      "command": "npx",
      "args": ["-y", "@mcp/postgres", "postgresql://localhost:5432/myapp"]
    }
  }
}
```

```markdown
<!-- CLAUDE.md -->
## This Project
- Framework: Next.js 14 App Router
- Database: PostgreSQL via Prisma
- Testing: Vitest + Testing Library
```

### Directory Level (Nested CLAUDE.md)

Put overrides for specific directories:

```markdown
<!-- src/legacy/CLAUDE.md -->
## Legacy Module Rules
- This directory uses CommonJS (require/module.exports), NOT ESM
- Do not convert to modern patterns unless explicitly asked
- Match the callback style used in existing files
```

## How Hooks Merge

Hooks from different levels are additive:

```
User hooks:  [lint on write]
Project hooks: [type check on write, security scan on write]
→ Effective: [lint on write, type check on write, security scan on write]
```

All three hooks run on every file write. They do not replace each other.

If you need a project to NOT run a user-level hook, you must remove it from `~/.claude/settings.json` or scope it to specific directories.

## How CLAUDE.md Content Merges

CLAUDE.md content from all levels is concatenated:

```
~/.claude/CLAUDE.md → "Use TypeScript, use pnpm"
./CLAUDE.md → "Framework: Next.js, Database: Prisma"
./src/legacy/CLAUDE.md → "Use CommonJS in this directory"
```

For a file in `src/legacy/`, Claude Code sees all three. If they conflict, the closest CLAUDE.md's instruction is most salient because it appears last in the context.

## Common Configuration Mistakes

### Mistake 1: Secrets in project settings
**Wrong:** Putting API keys in `.claude/settings.json` that gets committed to git.
**Right:** Put secrets in `~/.claude/settings.json` (user level) or use environment variables.

### Mistake 2: Project-specific hooks at user level
**Wrong:** Putting project-specific lint commands in `~/.claude/settings.json`.
**Right:** Put project hooks in `.claude/settings.json` at the project level.

### Mistake 3: Conflicting CLAUDE.md rules
**Wrong:** Root CLAUDE.md says "use ESM" and subdirectory CLAUDE.md says "use CommonJS" without scoping.
**Right:** Clearly scope rules: "Files in src/legacy/ use CommonJS. All other files use ESM."

### Mistake 4: Missing .gitignore for settings
**Wrong:** Committing `.claude/settings.json` with local file paths or tokens.
**Right:** Add sensitive parts to `.gitignore` or use environment variables.

## FAQ

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

### Can I see what configuration Claude Code is using?
Start a session and ask: "What rules from CLAUDE.md are you following?" Claude Code will summarize the active configuration.

### Do organization settings override my CLAUDE.md?
Organization settings control tool permissions and MCP access. They do not override CLAUDE.md behavioral rules. The two systems are complementary, not hierarchical, for behavioral configuration.

### Should I commit .claude/settings.json to git?
Commit it if it contains only project-relevant hooks and non-sensitive MCP configurations. Do not commit it if it contains API tokens or local paths.

### How do I debug configuration issues?
Check files in order: `~/.claude/CLAUDE.md` → `./CLAUDE.md` → `./.claude/settings.json`. The [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) repo helps you understand what Claude Code sees by default.

For CLAUDE.md writing guides, see the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). For hook configuration, read the [hooks guide](/claude-code-hooks-explained-complete-guide-2026/). For enterprise setup with organization-level config, see the [enterprise guide](/claude-code-enterprise-setup-guide-2026/).
