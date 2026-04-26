---
layout: default
title: "Claude Code MCP Server Setup (2026)"
description: "Claude Code MCP Server Setup — practical setup steps, configuration examples, and working code you can use in your projects today."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-mcp-server-setup/
reviewed: true
categories: [MCP Server Configuration]
tags: ["claude-code", "mcp", "model-context-protocol", "server-setup"]
geo_optimized: true
---
# Set Up MCP Servers in Claude Code

> **TL;DR:** Add MCP server definitions to `~/.claude/settings.json` under the `mcpServers` key. Use stdio transport for local tools and SSE for remote servers. Test with `claude mcp list`.

## The Problem

You want to extend Claude Code with custom tools via the Model Context Protocol (MCP) but the configuration is not documented in one place. Or you have configured an MCP server and it is not loading:

```
Error: MCP server "my-server" failed to start
```

Or tools from your MCP server are not appearing when you run `claude [claude mcp list command guide](/claude-mcp-list-command-guide/)`.

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

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-mcp-server-setup)**

</div>

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-server-setup)**

47/500 founding spots. Price goes up when they're gone.

</div>



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Issues

- [Fix: Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/) — Debugging tool discovery
- [Fix: Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/) — Endless permission prompts
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/) — Browse all MCP guides


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



- [Claude Desktop config.json guide](/claude-desktop-config-json-guide/) — How to configure Claude Desktop with config.json
## Related Articles

- [Claude Code Angular MCP Configuration](/claude-code-angular-mcp/)
- [Set Up Django MCP Server for Claude Code](/claude-code-django-mcp/)
- [Set Up Docker MCP Server for Claude Code](/claude-code-docker-mcp/)
- [Add MySQL MCP to Claude Code](/claude-code-add-mysql-mcp/)
- [Add Angular MCP to Claude Code](/claude-code-add-angular-mcp/)
- [Connect Claude Code to Remote MCP Servers](/claude-code-mcp-remote-http-server-setup/)
- [Add MongoDB MCP to Claude Code](/claude-code-add-mongodb-mcp/)
- [Claude Code Supabase MCP Setup Guide](/claude-code-supabase-mcp-setup/)


