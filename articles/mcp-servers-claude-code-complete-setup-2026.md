---
layout: default
title: "MCP Servers for Claude Code (2026)"
description: "Set up MCP servers for Claude Code with step-by-step configuration for databases, APIs, file systems, and cloud service integrations."
permalink: /mcp-servers-claude-code-complete-setup-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# MCP Servers for Claude Code: Complete Setup Guide (2026)

The Model Context Protocol (MCP) lets Claude Code connect to external services — databases, APIs, cloud providers, and custom tools. Instead of copying data into your conversation, MCP gives Claude Code direct access to query, read, and interact with external systems.

## What Is MCP?

MCP is an open protocol that standardizes how AI tools connect to external services. An MCP server exposes tools (functions) and resources (data) that Claude Code can call during a session. Think of it as a plugin API that works across AI tools.

The [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) repository (85K+ stars) indexes 200+ community-built MCP servers across 30+ categories.

## How MCP Works With Claude Code

```
Claude Code → MCP Client → MCP Server → External Service
                                           (Database, API, etc.)
```

1. You configure an MCP server in `.claude/settings.json`
2. Claude Code starts the MCP server process when needed
3. The server exposes tools (e.g., `query_database`, `list_files`)
4. Claude Code calls these tools during your session
5. Results are returned to Claude Code as context

## Installation Methods

### Method 1: npx (Recommended for npm packages)

Most MCP servers are distributed as npm packages:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

### Method 2: Direct Command

For Python or Go-based servers:

```json
{
  "mcpServers": {
    "custom-server": {
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

### Method 3: Docker

For isolated server environments:

```json
{
  "mcpServers": {
    "database": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "mcp/postgres-server"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@host:5432/db"
      }
    }
  }
}
```

## Configuration Location

MCP servers are configured in `.claude/settings.json`:

**Project-level** (`.claude/settings.json` in your repo):
```json
{
  "mcpServers": {
    "project-db": {
      "command": "npx",
      "args": ["-y", "@mcp/postgres", "postgresql://localhost:5432/myapp"]
    }
  }
}
```

**User-level** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@mcp/github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

## Essential MCP Server Setups

### 1. Filesystem Access

Give Claude Code access to specific directories outside your project:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
               "/Users/you/documents", "/Users/you/downloads"]
    }
  }
}
```

### 2. Database (PostgreSQL)

Query your database directly from Claude Code:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@mcp/postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb"
      }
    }
  }
}
```

Claude Code can then run: "Show me all users who signed up this week" and the MCP server translates that into SQL.

### 3. GitHub

Access repos, issues, and PRs:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  }
}
```

### 4. Web Fetch / Browsing

Let Claude Code read web pages:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

### 5. Memory / Knowledge Graph

Persistent memory across sessions:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

## Security Considerations

MCP servers run with your user permissions. Before installing any server:

1. **Review the source code** — Most servers are small enough to read in 10 minutes
2. **Limit filesystem access** — Only expose directories the server needs
3. **Use environment variables for secrets** — Never hardcode tokens in settings.json
4. **Prefer project-level config** — Database servers should be project-specific, not global
5. **Audit server network access** — Some servers make external API calls

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) includes a threat model for MCP server security.

## Troubleshooting

### Server not starting
```bash
# Test the server manually
npx -y @modelcontextprotocol/server-filesystem /tmp
```
If it fails standalone, the issue is the server, not Claude Code.

### Permission errors
Check that environment variables are set and the server has access to the target resource (database, API, directory).

### Server timeout
MCP servers must respond within a timeout window. Slow servers (external API calls) may need optimization or caching.

### Tools not appearing
Restart Claude Code after modifying `.claude/settings.json`. The server configuration is read at session start.

## Building a Custom MCP Server

If no existing server covers your use case, build your own:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio";

const server = new Server({
  name: "my-custom-server",
  version: "1.0.0"
});

server.setRequestHandler("tools/list", async () => ({
  tools: [{
    name: "get_weather",
    description: "Get current weather for a city",
    inputSchema: {
      type: "object",
      properties: {
        city: { type: "string", description: "City name" }
      },
      required: ["city"]
    }
  }]
}));

server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "get_weather") {
    const city = request.params.arguments.city;
    // Your logic here
    return { content: [{ type: "text", text: `Weather in ${city}: 72F` }] };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## FAQ

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

### How many MCP servers can I run simultaneously?
There is no hard limit, but each server is a running process. Keep it under 10 for reasonable resource usage.

### Do MCP servers consume Claude Code tokens?
The tool definitions add to context. Each server's tools add ~100-500 tokens to every session. Tool call results consume additional tokens.

### Can MCP servers modify my files?
Only if the server exposes write tools and you approve the action. Claude Code still asks for permission before executing tool calls.

### Are MCP servers compatible with Cursor?
MCP is an open standard. Servers work with any MCP-compatible client, including Cursor, which added MCP support in 2025.

### Where do I find more MCP servers?
The [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) repo is the definitive index with 200+ servers. The [claude-code-templates](https://github.com/davila7/claude-code-templates) also includes 55+ MCP configurations.

For the full Claude Code ecosystem map, see our [tools overview](/claude-code-ecosystem-complete-map-2026/). For hook integration with MCP, read the [hooks guide](/claude-code-hooks-explained-complete-guide-2026/). For best MCP integrations, see our [MCP roundup](/best-claude-code-mcp-integrations-2026/).
