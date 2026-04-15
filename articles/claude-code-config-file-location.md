---
layout: default
title: "Claude Code Config File Location and Settings"
description: "Find and configure Claude Code settings files — global settings.json, project settings, MCP config, and environment variables."
date: 2026-04-14
last_modified_at: 2026-04-15
author: "Claude Code Guides"
permalink: /claude-code-config-file-location/
reviewed: true
categories: [Installation & Setup]
tags: ["claude-code", "config", "settings", "configuration"]
---

# Claude Code Config File Location and Settings

> **TL;DR:** Global settings live at `~/.claude/settings.json`. Project settings at `.claude/settings.json` in your repo root. MCP servers are configured separately in `~/.claude.json` (user scope) or `.mcp.json` (project scope).

## The Problem

You need to customize Claude Code's behavior but are unsure where configuration files are stored, or your changes to settings are not taking effect.

## Why This Happens

Claude Code uses a layered configuration system with multiple file locations. Settings are merged in order of precedence, and changes to the wrong file may be overridden by a higher-priority source.

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
<strong>Built by Michael</strong> · Top Rated Plus on Upwork · $400K+ earned building with AI · 16 Chrome extensions · 3,000+ users · Building with Claude Code since launch.
<a href="https://zovo.one/lifetime?utm_source=ccg&utm_medium=author-bio&utm_campaign=social-proof">See what I ship with →</a>
</div>

---


<div class="before-after">
<div class="before">
<h4>Without CLAUDE.md</h4>
<p>You: "Add authentication to my Next.js app"</p>
<p>Claude Code generates a <code>pages/</code> directory (your App Router uses <code>app/</code>), picks NextAuth v4 (v5 is current), creates <code>.js</code> files in a TypeScript project, and uses <code>getServerSession</code> incorrectly with the wrong adapter pattern.</p>
<p><strong>Result:</strong> You spend 45 minutes fixing what Claude broke.</p>
</div>
<div class="after">
<h4>With a Professional CLAUDE.md</h4>
<p>You: Same prompt.</p>
<p>Claude Code reads CLAUDE.md &rarr; knows App Router + TypeScript strict + NextAuth v5 &rarr; generates <code>app/api/auth/[...nextauth]/route.ts</code> with correct session handling, middleware config, and type-safe session types that match your existing schema.</p>
<p><strong>Result:</strong> It works on the first run. You ship.</p>
</div>
</div>

<div class="mastery-cta">

**You're configuring this manually. There's a faster way.**

Production-ready CLAUDE.md templates for 16 frameworks. Copy into your project, Claude Code immediately understands your stack — right conventions, right patterns, right versions. No more fixing what it gets wrong.

**[Get the production config →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-config-file-location)**

$99 once. Yours forever. 47/500 founding spots left.

</div>

## Related Issues

- [Set Up MCP Servers in Claude Code](/claude-code-mcp-server-setup) — MCP configuration details
- [Claude Code Permission Modes Explained](/claude-code-permission-modes) — Permission configuration
- [Claude Code Install Guide](/claude-code-install-guide/) — Browse all setup guides

---

*Last verified: 2026-04-15. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
