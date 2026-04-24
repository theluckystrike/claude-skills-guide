---
title: "Add an MCP Server to Claude Code (2026)"
description: "Add any MCP server to Claude Code in 5 steps. Configure settings.json, set environment variables, verify the connection, and troubleshoot common errors."
permalink: /how-to-add-mcp-server-claude-code-2026/
last_tested: "2026-04-22"
---

# How to Add an MCP Server to Claude Code (2026)

MCP (Model Context Protocol) servers extend Claude Code with external capabilities — databases, APIs, file systems, and more. Here is the exact process for adding any MCP server.

## Prerequisites

- Claude Code installed and working
- The MCP server you want to add (installed or installable)
- Terminal access

## Step 1: Install the MCP Server

Most MCP servers are npm packages or standalone binaries. Common installation patterns:

npm-based server:
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

Python-based server:
```bash
pip install mcp-server-sqlite
```

Docker-based server:
```bash
docker pull mcp/server-postgres
```

Check the server's README for its specific installation method.

## Step 2: Configure Claude Code

Add the server to your Claude Code MCP configuration. Edit or create the settings file:

Project-level (recommended):
```bash
mkdir -p .claude
```

Edit `.claude/settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    }
  }
}
```

User-level (applies to all projects):

Edit `~/.claude/settings.json` with the same structure.

## Step 3: Add Environment Variables (If Needed)

Some MCP servers require API keys or credentials:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "args": ["--connection-string"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

Keep secrets out of version control. Use environment variable references or a separate untracked config file.

## Step 4: Restart Claude Code

MCP servers are loaded at session start. After adding a new server, restart Claude Code:

```bash
# Exit current session
# Start a new one
claude
```

## Step 5: Verify the Connection

Ask Claude to use the MCP server's capabilities:

For a filesystem server:
```
List the files in /path/to/allowed/directory using the filesystem MCP server
```

For a database server:
```
List all tables in the connected database
```

If Claude uses the MCP server's tools successfully, the setup is complete.

## Common MCP Server Configurations

**SQLite database**:
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "mcp-server-sqlite",
      "args": ["--db-path", "/path/to/database.db"]
    }
  }
}
```

**GitHub integration**:
```json
{
  "mcpServers": {
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

## Step 6: Configure Multiple Servers

You can run multiple MCP servers simultaneously. Each gets its own entry in the configuration:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/docs"]
    },
    "postgres": {
      "command": "mcp-server-postgres",
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token"
      }
    }
  }
}
```

Each server adds its tools to Claude's available toolkit. Claude selects the appropriate tool based on your request — ask about database tables and it uses the PostgreSQL server, ask about files and it uses the filesystem server.

**Performance consideration**: Each MCP server adds tool definitions to the context window and consumes tokens. Only configure servers you actively use. If you are not querying a database this week, remove the PostgreSQL server and add it back when needed.

## Security Best Practices

MCP servers can be powerful, which means they can also be dangerous if misconfigured:

**Use read-only credentials for production databases**. Never give Claude write access to production data through MCP unless you have reviewed and approved the specific operation.

**Scope filesystem access narrowly**. Point the filesystem server at a specific directory, not your home directory or root. Avoid giving access to directories containing `.env` files, SSH keys, or other secrets.

**Rotate API tokens**. If you put a GitHub token in your MCP config, rotate it regularly. Do not commit tokens to version control — use environment variables or a secrets manager.

**Review server permissions**. Before installing any MCP server, read its documentation to understand what permissions it requests and what operations it can perform.

## Troubleshooting

**"MCP server failed to start"**: Run the server command directly in your terminal to see error output. Common causes: missing dependencies, wrong path, or permission issues.

**Claude does not use the server**: Claude may not know the server exists if the configuration has a syntax error. Validate your JSON:
```bash
python3 -c "import json; json.load(open('.claude/settings.json'))"
```

**Server starts but tools fail**: Some servers need additional setup (database migrations, API permissions). Check the server's documentation for prerequisites.

**Multiple servers conflict**: Two servers providing tools with the same name will conflict. Use only one server per capability.

**Server is slow**: MCP adds latency to each tool call. If a server adds more than 2 seconds, check its documentation for performance tuning options.

## Next Steps

- Browse the [Awesome MCP Servers directory](/how-to-browse-awesome-mcp-servers-2026/) for more servers
- Learn about [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) that complement MCP servers
- See the [MCP setup guide](/mcp-servers-claude-code-complete-setup-2026/) for advanced configuration patterns
- Explore [best MCP servers for Claude Code](/best-mcp-servers-for-claude-code-2026/)
