---
layout: default
title: "Claude Code Config File Location (2026)"
description: "Find and configure Claude Code settings files — global settings.json, project settings, MCP config, and environment variables."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-config-file-location/
reviewed: true
categories: [Installation & Setup]
tags: ["claude-code", "config", "settings", "configuration"]
geo_optimized: true
---

# Claude Code Config File Location and Settings

> **TL;DR:** Global settings live at `~/.claude/settings.json`. Project settings at `.claude/settings.json` in your repo root. MCP servers are configured separately in `~/.claude.json` (user scope) or `.mcp.json` (project scope).

## The Problem

You need to customize Claude Code's behavior but are unsure where configuration files are stored, or your changes to settings are not taking effect.

## Why This Happens

Claude Code uses a layered configuration system with multiple file locations. Settings are merged in order of precedence, and changes to the wrong file is overridden by a higher-priority source.

## The Fix

### Step 1 — Understand the Configuration Hierarchy

Claude Code reads settings from these locations, in order of precedence (highest first):

| Priority | Location | Scope |
|----------|----------|-------|
| 1 | CLI flags | Current session only |
| 2 | `~/.claude/settings.local.json` | Local (machine-specific, not committed) |
| 3 | `.claude/settings.json` | Project (committed to repo) |
| 4 | `~/.claude/settings.json` | User (all projects) |

> **Note:** Enterprise deployments may also have a "Managed" policy layer that sits above CLI flags and cannot be overridden by users.

### Step 2 — Find Your Config Files

```bash
# User settings (applies to all projects)
ls -la ~/.claude/settings.json

# Local settings (machine-specific overrides, not committed)
ls -la ~/.claude/settings.local.json

# Project settings (from your repo root, committed to version control)
ls -la .claude/settings.json

# MCP server config — user scope
ls -la ~/.claude.json

# MCP server config — project scope
ls -la .mcp.json

# Memory files
ls -la ~/.claude/CLAUDE.md
ls -la CLAUDE.md

# Credentials (macOS uses Keychain, Linux uses this file)
ls -la ~/.claude/credentials.json
```

### Step 3 — Edit User Settings

```bash
# Create the directory if needed
mkdir -p ~/.claude

# Edit settings
${EDITOR:-nano} ~/.claude/settings.json
```

**Common user settings (`~/.claude/settings.json`):**

```json
{
 "defaultMode": "acceptEdits",
 "skipDangerousModePermissionPrompt": false,
 "permissions": {
 "allow": [
 "Bash(git *)",
 "Read(*)"
 ],
 "deny": [
 "Bash(rm -rf *)"
 ]
 },
 "hooks": {
 "PreToolUse": [],
 "PostToolUse": []
 }
}
```

> **Valid `defaultMode` values:** `default` (plan/ask mode), `acceptEdits` (auto-accept file edits), `fullAuto` (no prompts).

### Step 4 — Edit Project Settings

```bash
# From your project root
mkdir -p .claude
${EDITOR:-nano} .claude/settings.json
```

**Common project settings (`.claude/settings.json`):**

```json
{
 "permissions": {
 "allow": [
 "Bash(npm test)",
 "Bash(npm run build)"
 ]
 }
}
```

### Step 5 — Configure MCP Servers

MCP servers are **not** configured inside `settings.json`. They have their own dedicated config files:

- **User scope** (`~/.claude.json`): MCP servers available in all projects.
- **Project scope** (`.mcp.json` in your repo root): MCP servers for a specific project, committed to version control.

**User-scoped MCP config (`~/.claude.json`):**

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user"]
 }
 }
}
```

**Project-scoped MCP config (`.mcp.json`):**

```json
{
 "mcpServers": {
 "project-db": {
 "command": "node",
 "args": ["./tools/mcp-server.js"]
 }
 }
}
```

### Step 6 — Configure Memory Files

Claude Code reads `CLAUDE.md` files for persistent context:

```bash
# Global memory (loaded in every session)
cat > ~/.claude/CLAUDE.md << 'EOF'
# Global Preferences
- I prefer TypeScript over JavaScript
- Always use pnpm as package manager
- Follow NASA Power of 10 coding rules
EOF

# Project memory (loaded when in this project)
cat > CLAUDE.md << 'EOF'
# Project: My App
- This is a Next.js 14 app with App Router
- Database: PostgreSQL via Prisma
- Tests: Vitest + Playwright
EOF
```

### Step 7 — Verify Settings Are Loaded

```bash
# Use /config command inside Claude Code to see active settings
claude
> /config
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Settings not taking effect | Wrong file location | Check both user and project paths |
| MCP servers not loading | Config placed in `settings.json` instead of `~/.claude.json` or `.mcp.json` | Move MCP config to the correct file |
| Project MCP servers not found | Running Claude from a different directory | Use absolute paths in MCP server command args |
| `/config` freezes terminal | Known bug in v2.1.104 | Do not run `/config` twice; restart session |
| Settings reset after update | npm reinstall overwrites defaults | Settings files are not overwritten by updates |

## Prevention

- **Version control project settings:** Commit `.claude/settings.json`, `CLAUDE.md`, and `.mcp.json` so all team members share the same config.
- **Use `settings.local.json` for machine-specific overrides:** This file is not committed to version control and sits above project settings in priority.
- **Use environment variables for secrets:** Never put API keys in settings files; use `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` env vars.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-config-file-location)**

</div>

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-config-file-location)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Issues

- [Set Up MCP Servers in Claude Code](/claude-code-mcp-server-setup) — MCP configuration details
- [Claude Code Permission Modes Explained](/claude-code-permission-modes) — Permission configuration
- [Claude Code Install Guide](/claude-code-install-guide/) — Browse all setup guides

---

*Last verified: 2026-04-15. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



- [Claude Desktop config.json guide](/claude-desktop-config-json-guide/) — How to configure Claude Desktop with config.json

## See Also

- [Claude Code Config YAML Parse Error — Fix (2026)](/claude-code-config-yaml-parse-error-fix/)
- [Config File JSON Parse Error — Fix (2026)](/claude-code-config-json-corrupted-parse-error-fix-2026/)
- [XDG Config Directory Permissions Fix](/claude-code-xdg-config-directory-permissions-fix-2026/)
- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide
