---
layout: default
title: "Claude Code Config File Location and Settings"
description: "Find and configure Claude Code settings files — global settings.json, project settings, MCP config, and environment variables."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-code-config-file-location/
reviewed: true
categories: [Installation & Setup]
tags: ["claude-code", "config", "settings", "configuration"]
---

# Claude Code Config File Location and Settings

> **TL;DR:** Global settings live at `~/.claude/settings.json`. Project settings at `.claude/settings.json` in your repo root. MCP servers, permissions, and hooks are all configured through these files.

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
| 2 | Environment variables | Current shell session |
| 3 | `.claude/settings.json` | Current project |
| 4 | `~/.claude/settings.json` | Global (all projects) |
| 5 | `CLAUDE_CONFIG_DIR/settings.json` | Custom config directory |

### Step 2 — Find Your Config Files

```bash
# Global settings
ls -la ~/.claude/settings.json

# Project settings (from your repo root)
ls -la .claude/settings.json

# Custom config directory (if CLAUDE_CONFIG_DIR is set)
echo "$CLAUDE_CONFIG_DIR"

# Memory files
ls -la ~/.claude/CLAUDE.md
ls -la .claude/CLAUDE.md

# Credentials (macOS uses Keychain, Linux uses this file)
ls -la ~/.claude/credentials.json
```

### Step 3 — Edit Global Settings

```bash
# Create the directory if needed
mkdir -p ~/.claude

# Edit settings
${EDITOR:-nano} ~/.claude/settings.json
```

**Common global settings:**

```json
{
  "defaultMode": "allowEdits",
  "skipDangerousModePermissionPrompt": false,
  "autoCompactThreshold": 80,
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user"]
    }
  },
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

### Step 4 — Edit Project Settings

```bash
# From your project root
mkdir -p .claude
${EDITOR:-nano} .claude/settings.json
```

**Common project settings:**

```json
{
  "mcpServers": {
    "project-db": {
      "command": "node",
      "args": ["./tools/mcp-server.js"]
    }
  },
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run build)"
    ]
  }
}
```

### Step 5 — Configure Memory Files

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
cat > .claude/CLAUDE.md << 'EOF'
# Project: My App
- This is a Next.js 14 app with App Router
- Database: PostgreSQL via Prisma
- Tests: Vitest + Playwright
EOF
```

### Step 6 — Verify Settings Are Loaded

```bash
# Use /config command inside Claude Code to see active settings
claude
> /config
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Settings not taking effect | Wrong file location | Check both global and project paths |
| `CLAUDE_CONFIG_DIR` not isolating | Credentials use Keychain (macOS) | On Linux, set `CLAUDE_CONFIG_DIR` fully |
| MCP servers not loading | Config in project, running from different dir | Use absolute paths in MCP command |
| `/config` freezes terminal | Known bug in v2.1.104 | Do not run `/config` twice; restart session |
| Settings reset after update | npm reinstall overwrites defaults | Settings files are not overwritten by updates |

## Prevention

- **Version control project settings:** Commit `.claude/settings.json` and `.claude/CLAUDE.md` so all team members share the same config.
- **Use environment variables for secrets:** Never put API keys in settings.json; use `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` env vars.

## Related Issues

- [Set Up MCP Servers in Claude Code](/claude-code-mcp-server-setup) — MCP configuration details
- [Claude Code Permission Modes Explained](/claude-code-permission-modes) — Permission configuration
- [Hub: Installation & Setup](/claude-code-installation-hub) — Browse all setup guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
