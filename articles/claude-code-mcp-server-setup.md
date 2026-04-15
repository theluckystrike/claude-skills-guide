---
layout: default
title: "Set Up MCP Servers in Claude Code"
description: "Configure MCP servers in Claude Code. Covers stdio and SSE transports, settings.json, and common setup errors."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-code-mcp-server-setup/
reviewed: true
categories: [MCP Server Configuration]
tags: ["claude-code", "mcp", "model-context-protocol", "server-setup"]
---

# Set Up MCP Servers in Claude Code

> **TL;DR:** Add MCP server definitions to `~/.claude/settings.json` under the `mcpServers` key. Use stdio transport for local tools and SSE for remote servers. Test with `claude mcp list`.

## The Problem

You want to extend Claude Code with custom tools via the Model Context Protocol (MCP) but the configuration is not documented in one place. Or you have configured an MCP server and it is not loading:

```
Error: MCP server "my-server" failed to start
```

Or tools from your MCP server are not appearing when you run `claude mcp list`.

## Why This Happens

MCP servers must be correctly configured in Claude Code's settings file with the right transport type, command path, and arguments. Common causes of failure:

- Wrong file path for the MCP server binary or script
- Missing or incorrect transport type (`stdio` vs `sse`)
- The MCP server process crashes on startup (check stderr)
- Settings file JSON is malformed
- Server configured in project settings but not in global settings (or vice versa)

## The Fix

### Step 1 — Create or Edit Settings File

Claude Code reads MCP configuration from `~/.claude/settings.json` (global) or `.claude/settings.json` (project-level):

```bash
# Create the settings directory if it does not exist
mkdir -p ~/.claude

# Edit the settings file
${EDITOR:-nano} ~/.claude/settings.json
```

### Step 2 — Add MCP Server Configuration

**Stdio transport (local process):**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

**SSE transport (remote server):**

```json
{
  "mcpServers": {
    "remote-tools": {
      "url": "http://localhost:3001/sse",
      "transport": "sse"
    }
  }
}
```

### Step 3 — Verify the MCP Server Loads

```bash
# List all configured MCP servers and their tools
claude mcp list
```

**Expected output:**

```
MCP Servers:
  filesystem (stdio) — 11 tools
  github (stdio) — 8 tools
```

If a server shows 0 tools or is missing, check the server logs:

```bash
# Test the MCP server independently
npx -y @modelcontextprotocol/server-filesystem /tmp 2>&1 | head -5
```

### Step 4 — Test a Tool Call

Inside a Claude Code session, ask Claude to use one of the MCP tools:

```
> Use the filesystem tool to list files in /tmp
```

Claude should invoke the MCP tool and return results.

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| "Failed to start" error | Wrong command path | Use `which npx` to verify path, use absolute paths |
| Tools load but fail with 401 | Missing env vars | Add API tokens to the `env` block in config |
| "Not allowlisted" error | MCP tool not in allowed list | Update `access.json` or approve in permission prompt |
| 14% context consumed on init | Too many MCP tools | Reduce tool count or use `toolFilter` |
| stdin pipe closed (v2.1.105) | Regression in stdio handling | Update to latest version or downgrade to v2.1.104 |
| Server works in Desktop, not CLI | Different settings file | Check both `~/.claude/settings.json` and project `.claude/settings.json` |

## Prevention

- **Start minimal:** Add one MCP server at a time and verify it loads before adding more.
- **Use absolute paths:** Avoid relying on `PATH` resolution for MCP server commands.
- **Pin MCP package versions:** Use `npx -y @modelcontextprotocol/server-filesystem@1.0.0` instead of latest to avoid breaking changes.

---

**[Get the Claude Code Mastery Bundle — included free in Zovo Lifetime →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-mcp-server-setup)**

16 CLAUDE.md templates · 80+ prompts · orchestration configs · workflow playbooks. One payment, lifetime access.

## Related Issues

- [Fix: Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/) — Debugging tool discovery
- [Fix: Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/) — Endless permission prompts
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/) — Browse all MCP guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
