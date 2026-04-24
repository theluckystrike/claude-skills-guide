---
layout: default
title: "Debug MCP Servers in Claude Code (2026)"
description: "Fix broken MCP server connections in Claude Code with step-by-step debugging for transport errors, timeouts, and configuration issues."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-debugging-mcp/
categories: [guides]
tags: [claude-code, claude-skills, mcp, debugging, server-configuration]
reviewed: true
score: 6
geo_optimized: true
---

MCP server issues in Claude Code usually stem from transport misconfigurations, missing dependencies, or process crashes. This guide walks through systematic debugging for every common MCP failure pattern so you can identify and fix connection problems in minutes.

## The Problem

You have configured an MCP server in Claude Code but it refuses to connect, returns cryptic errors, or silently fails. The MCP inspector shows nothing useful, and your tools are unavailable. This is one of the most frustrating experiences because the error messages rarely point to the actual root cause.

## Quick Solution

1. Check your MCP server status inside Claude Code:

```bash
claude mcp list
```

2. Inspect the server logs for transport errors:

```bash
# Check stderr output from the MCP process
claude --mcp-debug
```

3. Validate your configuration file syntax:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./mcp-server/index.js"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

4. Test the MCP server independently outside Claude Code:

```bash
node ./mcp-server/index.js
```

5. Restart Claude Code completely after any config change to ensure the MCP process is re-spawned.

## How It Works

Claude Code communicates with MCP servers through stdio transport by default. When you launch Claude Code, it reads `.mcp.json` (project-level) or `~/.claude/mcp.json` (global) and spawns each configured server as a child process. Communication happens over stdin/stdout using JSON-RPC messages.

The debugging flow follows this hierarchy:

- **Configuration errors** -- malformed JSON, wrong paths, missing fields in `.mcp.json`
- **Process spawn failures** -- the command does not exist, missing dependencies, wrong Node.js version
- **Transport errors** -- the server starts but does not respond to the `initialize` handshake within the timeout window
- **Runtime crashes** -- the server initializes but crashes when handling tool calls

The `claude --mcp-debug` flag enables verbose logging of all JSON-RPC messages between Claude Code and each MCP server. This shows you the exact point of failure in the communication chain.

## Common Issues

**Server process exits immediately.** The most common cause is the MCP server writing non-JSON output to stdout. Any console.log statements, warning banners, or debug output on stdout will corrupt the JSON-RPC stream. Redirect all logging to stderr instead:

```javascript
// Wrong - breaks MCP transport
console.log("Server starting...");

// Correct - uses stderr
console.error("Server starting...");
```

**Environment variables not passed through.** Claude Code does not inherit your shell environment by default for MCP child processes. You must explicitly declare every needed variable in the `env` block of your MCP config. Missing API keys or database URLs are a frequent silent failure.

**Timeout on initialize.** If your MCP server takes more than 30 seconds to start (loading large models, connecting to databases), it will be killed. Move heavy initialization into lazy loading patterns triggered by the first tool call rather than server startup.

## Example CLAUDE.md Section

```markdown
# MCP Server Debugging

## Active MCP Servers
- `db-server`: PostgreSQL query tool (port 5432 must be running)
- `api-server`: REST API integration (requires API_KEY env var)

## Debugging Steps
1. Run `claude mcp list` to verify server status
2. Check stderr logs: `claude --mcp-debug`
3. Test server standalone: `node ./mcp-servers/db-server.js`
4. Validate .mcp.json: `cat .mcp.json | python3 -m json.tool`

## Common Fixes
- If db-server fails: ensure `pg_isready` returns success
- If api-server fails: verify API_KEY is set in .mcp.json env block
- After any .mcp.json change: restart Claude Code fully
- Never use console.log in MCP servers — use console.error
```

## Best Practices

- **Always test [claude mcp list command guide](/claude-mcp-list-command-guide/) manually and verify it produces valid JSON-RPC on stdout.
- **Use the `--mcp-debug` flag** as your primary diagnostic tool. It shows every message exchanged and where the protocol breaks down.
- **Keep `.mcp.json` in version control** so your team shares the same server configuration, but use environment variables for secrets rather than hardcoding them.
- **Set up a health check in CLAUDE.md** that documents the expected MCP servers and how to verify each one is operational.
- **Prefer project-level `.mcp.json`** over global config to avoid conflicts between different projects that need different server versions.


## Related

- [Claude Desktop config.json guide](/claude-desktop-config-json-guide/) — How to configure Claude Desktop with config.json
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-debugging-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


