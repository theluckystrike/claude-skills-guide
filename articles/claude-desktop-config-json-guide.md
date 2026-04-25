---
layout: default
title: "claude_desktop_config.json Setup (2026)"
description: "Full reference for claude_desktop_config.json. File location, every config field, MCP server setup, validation commands, and common mistakes fixed."
permalink: /claude-desktop-config-json-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# claude_desktop_config.json: Complete Guide (2026)

The `claude_desktop_config.json` file is the configuration file for the Claude Desktop application. It controls MCP server connections, keyboard shortcuts, appearance, and telemetry settings. If you want Claude Desktop to connect to external tools, databases, or APIs through MCP, this file is where you define those connections.

## What claude_desktop_config.json Is

Claude Desktop reads this JSON file at startup to determine which MCP servers to launch, what keyboard shortcuts to register, and how the application should behave. Unlike Claude Code (which uses `.claude/settings.json`), this file is specific to the Claude Desktop app.

The file does not exist by default. You create it when you need to configure MCP servers or customize settings.

## File Location by Operating System

The file location depends on your operating system.

### macOS

```
~/Library/Application Support/Claude/claude_desktop_config.json
```

To open the directory in Finder:

```bash
open ~/Library/Application\ Support/Claude/
```

To create or edit the file:

```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Or open it with VS Code:

```bash
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Windows

```
%APPDATA%\Claude\claude_desktop_config.json
```

In most installations, this resolves to:

```
C:\Users\YourUsername\AppData\Roaming\Claude\claude_desktop_config.json
```

To open the directory in Explorer, press `Win + R` and type:

```
%APPDATA%\Claude
```

### Linux

```
~/.config/Claude/claude_desktop_config.json
```

To create or edit:

```bash
nano ~/.config/Claude/claude_desktop_config.json
```

If the `Claude` directory does not exist, create it first:

```bash
mkdir -p ~/.config/Claude
```

## Complete Configuration Structure

Here is the full schema with every configurable field.

```json
{
  "mcpServers": {
    "server-name": {
      "command": "string",
      "args": ["array", "of", "strings"],
      "env": {
        "KEY": "value"
      }
    }
  },
  "globalShortcut": "string",
  "theme": "string",
  "telemetry": {
    "enabled": true
  }
}
```

### `mcpServers` — MCP Server Configurations

This is the most commonly used section. Each key in the `mcpServers` object is a server name, and its value defines how to launch that server.

**Fields per server:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | The executable to run (e.g., `npx`, `node`, `python3`, `docker`) |
| `args` | string[] | No | Command-line arguments passed to the executable |
| `env` | object | No | Environment variables set for the server process |

The server must communicate via stdio (standard input/output) using the MCP JSON-RPC protocol.

### `globalShortcut` — Keyboard Shortcut to Activate

Defines a system-wide keyboard shortcut to bring Claude Desktop to the foreground.

```json
{
  "globalShortcut": "CommandOrControl+Space"
}
```

Key names follow [Electron accelerator syntax](https://www.electronjs.org/docs/latest/api/accelerator):
- `CommandOrControl` — Cmd on macOS, Ctrl on Windows/Linux
- `Alt` — Option on macOS, Alt on Windows/Linux
- `Shift`
- `Super` — Windows key or Cmd key
- Letters, numbers, and special keys (`Space`, `Tab`, `Enter`, `Escape`, function keys)

### `theme` — Appearance Settings

Controls the visual theme of the application:

```json
{
  "theme": "dark"
}
```

Options: `"light"`, `"dark"`, `"system"` (follows OS setting).

### `telemetry` — Usage Data Settings

Controls whether anonymized usage data is sent to Anthropic:

```json
{
  "telemetry": {
    "enabled": false
  }
}
```

## MCP Server Configuration Examples

### Filesystem Server

Gives Claude Desktop read and write access to specific directories:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/you/Documents",
        "/Users/you/Projects"
      ]
    }
  }
}
```

Each path after the package name is an allowed directory. Claude Desktop can only access files within these directories through this server.

### SQLite Server

Connects Claude Desktop to a local SQLite database:

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic/mcp-server-sqlite",
        "/Users/you/data/mydb.sqlite"
      ]
    }
  }
}
```

### GitHub Server

Provides access to GitHub repositories, issues, and pull requests:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_personal_access_token"
      }
    }
  }
}
```

The `GITHUB_TOKEN` must have appropriate scopes for the operations you want to perform (repo, issues, pull requests).

### Brave Search Server

Adds web search capabilities to Claude Desktop:

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your_brave_api_key"
      }
    }
  }
}
```

### Custom Server with Environment Variables

For custom or third-party MCP servers that need multiple environment variables:

```json
{
  "mcpServers": {
    "custom-api": {
      "command": "node",
      "args": ["/Users/you/mcp-servers/custom-server/index.js"],
      "env": {
        "API_KEY": "sk-your-api-key",
        "API_BASE_URL": "https://api.example.com",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

### Multiple Servers Together

A realistic configuration with several servers:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/Projects"],
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres", "postgresql://localhost:5432/mydb"]
    }
  },
  "globalShortcut": "CommandOrControl+Shift+Space"
}
```

## Common Mistakes and Fixes

### 1. Trailing Commas

JSON does not allow trailing commas. This is the most common syntax error.

**Wrong:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "package"],
    },
  }
}
```

**Correct:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "package"]
    }
  }
}
```

### 2. Wrong Path Separators on Windows

Windows uses backslashes, but JSON requires escaping them.

**Wrong:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "package", "C:\Users\you\Documents"]
    }
  }
}
```

**Correct (escaped backslashes):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "package", "C:\\Users\\you\\Documents"]
    }
  }
}
```

**Also correct (forward slashes work on Windows):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "package", "C:/Users/you/Documents"]
    }
  }
}
```

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

### 3. Missing Environment Variables

If a server requires an API key via environment variable and you do not set it in `env`, the server will start but fail to authenticate.

**Symptom:** Server connects but returns authentication errors.

**Fix:** Add the required environment variable:

```json
{
  "env": {
    "GITHUB_TOKEN": "ghp_your_actual_token"
  }
}
```

### 4. Server Command Not Found

If `npx` is not in the system PATH when Claude Desktop launches, the server fails silently.

**Fix on macOS:** Ensure Node.js is installed via the official installer or Homebrew, and test from a fresh terminal:

```bash
which npx
npx --version
```

If you installed Node.js via nvm, you may need to use the full path:

```json
{
  "command": "/Users/you/.nvm/versions/node/v20.11.0/bin/npx",
  "args": ["-y", "package-name"]
}
```

### 5. File Not Created in the Right Location

Double-check the file path. A common mistake is creating the file one directory too deep or with a typo in the filename.

```bash
# macOS — verify the file exists and is valid JSON
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool
```

## How to Validate Your Configuration

Before restarting Claude Desktop, validate the JSON:

**macOS:**
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool
```

**Windows (PowerShell):**
```powershell
Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" | python -m json.tool
```

**Linux:**
```bash
cat ~/.config/Claude/claude_desktop_config.json | python3 -m json.tool
```

If the JSON is valid, `python3 -m json.tool` will pretty-print it. If there is a syntax error, it will show the line number and error type.

You can also use `jq`:

```bash
jq . ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Claude Desktop Config vs Claude Code Config

These are two separate configuration systems for two separate products.

| Feature | Claude Desktop | Claude Code |
|---------|---------------|-------------|
| Config file | `claude_desktop_config.json` | `.claude/settings.json` and `~/.claude/settings.json` |
| Location | OS-specific app data directory | Project root or home directory |
| Product | Claude Desktop app (GUI) | Claude Code CLI (terminal) |
| MCP support | Yes, via `mcpServers` | Yes, via `mcpServers` |
| Scope system | Single file | User scope + project scope |
| CLI management | None (manual edit only) | `claude mcp add/remove/list` |

If you use both Claude Desktop and Claude Code, you need to configure MCP servers in both files separately. They do not share configuration. See the [Claude Code MCP configuration guide](/claude-code-mcp-configuration-guide/) for details on the CLI-side setup.

## Frequently Asked Questions

### Do I need to restart Claude Desktop after editing the config?

Yes. Claude Desktop reads the configuration file at startup. After making changes, quit and relaunch the application.

### Can I use comments in claude_desktop_config.json?

No. JSON does not support comments. If you need to document your configuration, maintain a separate notes file alongside it.

### What happens if the config file has a syntax error?

Claude Desktop will start but MCP servers will not be loaded. Check the developer console (Help > Toggle Developer Tools) for error messages.

### Can I use environment variables like $HOME in the config?

No. JSON values are literal strings. Use the full expanded path (`/Users/you/...`) rather than shell variables or tilde (`~`).

### Where can I find MCP server package names?

The [Awesome MCP Servers directory](/awesome-mcp-servers-directory-guide-2026/) maintains a comprehensive list. The official Anthropic servers use the `@anthropic/mcp-server-*` naming convention on npm.

### Can I run MCP servers on a remote machine?

The standard configuration runs servers locally via stdio. For remote servers, you need an MCP server that supports HTTP transport, or you can use SSH tunneling. See the [remote MCP server setup guide](/claude-code-mcp-remote-http-server-setup/) for details.

### Is claude_desktop_config.json synced across devices?

No. The file is local to each machine. You need to manually copy it to configure multiple computers identically.

### Can I configure multiple instances of the same MCP server?

Yes, by giving them different names:

```json
{
  "mcpServers": {
    "postgres-dev": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres", "postgresql://localhost:5432/dev"]
    },
    "postgres-staging": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres", "postgresql://staging-host:5432/app"]
    }
  }
}
```

## Related Guides

- [How to Add an MCP Server to Claude Code](/how-to-add-mcp-server-claude-code-2026/) — CLI-side MCP setup
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — curated server recommendations
- [MCP Servers Complete Setup Guide](/mcp-servers-claude-code-complete-setup-2026/) — end-to-end walkthrough
- [Claude Code MCP Configuration Guide](/claude-code-mcp-configuration-guide/) — settings.json reference
- [MCP Server Connection Refused Fix](/claude-code-mcp-server-connection-refused-fix/) — troubleshoot failed connections
- [Awesome MCP Servers Directory](/awesome-mcp-servers-directory-guide-2026/) — find servers to install
- [Configuration Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/) — understand config precedence
- [The Claude Code Playbook](/playbook/) — comprehensive workflow reference
- [Claude MCP List Command Guide](/claude-mcp-list-command-guide/) — CLI command reference for MCP management

### How do I debug why my MCP server is not starting?

Run the server command directly in your terminal to see error output. For example: npx -y @modelcontextprotocol/server-filesystem --help. If this fails, the server will not start from Claude Desktop either.

### Can I use relative paths in claude_desktop_config.json?

No. Always use absolute paths. JSON values are literal strings and shell expansions like ~ or $HOME do not work. Use the full path like /Users/you/Documents.

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Do I need to restart Claude Desktop after editing the config?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Claude Desktop reads the configuration file at startup. After making changes, quit and relaunch the application."}},
    {"@type": "Question", "name": "Can I use comments in claude_desktop_config.json?", "acceptedAnswer": {"@type": "Answer", "text": "No. JSON does not support comments. If you need to document your configuration, maintain a separate notes file alongside it."}},
    {"@type": "Question", "name": "What happens if the config file has a syntax error?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Desktop will start but MCP servers will not be loaded. Check the developer console (Help > Toggle Developer Tools) for error messages."}},
    {"@type": "Question", "name": "Can I use environment variables like $HOME in the config?", "acceptedAnswer": {"@type": "Answer", "text": "No. JSON values are literal strings. Use the full expanded path rather than shell variables or tilde."}},
    {"@type": "Question", "name": "Where can I find MCP server package names?", "acceptedAnswer": {"@type": "Answer", "text": "The Awesome MCP Servers directory maintains a comprehensive list. The official Anthropic servers use the @anthropic/mcp-server-* naming convention on npm."}},
    {"@type": "Question", "name": "Can I run MCP servers on a remote machine?", "acceptedAnswer": {"@type": "Answer", "text": "The standard configuration runs servers locally via stdio. For remote servers, you need an MCP server that supports HTTP transport, or you can use SSH tunneling."}},
    {"@type": "Question", "name": "Is claude_desktop_config.json synced across devices?", "acceptedAnswer": {"@type": "Answer", "text": "No. The file is local to each machine. You need to manually copy it to configure multiple computers identically."}},
    {"@type": "Question", "name": "Can I configure multiple instances of the same MCP server?", "acceptedAnswer": {"@type": "Answer", "text": "Yes, by giving them different names. For example, postgres-dev and postgres-staging can each point to different database connection strings."}},
    {"@type": "Question", "name": "How do I debug why my MCP server is not starting?", "acceptedAnswer": {"@type": "Answer", "text": "Run the server command directly in your terminal to see error output. If the command fails in the terminal, it will not start from Claude Desktop either."}},
    {"@type": "Question", "name": "Can I use relative paths in claude_desktop_config.json?", "acceptedAnswer": {"@type": "Answer", "text": "No. Always use absolute paths. JSON values are literal strings and shell expansions like ~ or $HOME do not work. Use the full path."}}
  ]
}
</script>

Related Reading

- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide

{% endraw %}
