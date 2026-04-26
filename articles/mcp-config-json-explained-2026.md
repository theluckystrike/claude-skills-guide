---
layout: default
title: "MCP Config JSON Explained (2026)"
description: "Every field in the MCP config file explained with examples. Understand mcpServers, command, args, env, and advanced options. April 2026."
date: 2026-04-26
permalink: /mcp-config-json-explained-2026/
categories: [guides, claude-code]
tags: [MCP, configuration, JSON, reference, tutorial]
last_modified_at: 2026-04-26
---

# MCP Config JSON Explained (2026)

The MCP configuration file is a single JSON document that tells Claude Code which MCP servers to connect to and how to start them. Every field matters. A misplaced comma breaks the connection. A wrong argument silently starts the wrong server version. This reference explains every field, its valid values, and common mistakes. To generate a valid config without memorizing the format, use the [MCP Config Generator](/mcp-config/).

## File Location

Claude Code looks for MCP configuration in these locations, in order:

| Priority | Location | Scope |
|----------|----------|-------|
| 1 (highest) | `.claude/mcp.json` (project root) | Project-specific |
| 2 | `~/.claude/mcp.json` | Global (all projects) |

Project-level config takes priority. If both files define a server with the same name, the project-level definition wins.

## The Top-Level Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "...",
      "args": ["..."],
      "env": {}
    }
  }
}
```

The file contains a single object with one required key: `mcpServers`. This key maps to an object where each property is a server configuration.

### mcpServers (required)

Type: `Object<string, ServerConfig>`

An object where keys are server names and values are server configurations. Server names:
- Must be unique within the file
- Should be descriptive (e.g., "postgres", "github", "brave-search")
- Cannot contain spaces
- Are used in Claude's tool names (e.g., `mcp__postgres__query`)

## Server Configuration Fields

### command (required)

Type: `string`

The executable to run. Common values:

| Value | When to Use |
|-------|-------------|
| `"npx"` | npm-published MCP servers (most common) |
| `"node"` | Local JavaScript MCP servers |
| `"python"` | Python MCP servers |
| `"uvx"` | Python MCP servers via uv |
| `"docker"` | Containerized MCP servers |

```json
"command": "npx"
```

The command must be available in your PATH. If Claude Code cannot find the command, the server fails to start silently.

### args (required)

Type: `string[]`

Arguments passed to the command. For npx, the first argument is typically `-y` (auto-confirm install) followed by the package name:

```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/me/project"]
```

Argument breakdown for common patterns:

**npm packages:**
```json
"args": ["-y", "@org/package-name", "--option", "value"]
```

**Local scripts:**
```json
"args": ["./mcp-servers/my-server.js", "--port", "3100"]
```

**Python packages:**
```json
"args": ["-m", "mcp_server_package", "--config", "./config.yaml"]
```

**Docker containers:**
```json
"args": ["run", "--rm", "-i", "mcp-server-image:latest"]
```

### env (optional)

Type: `Object<string, string>`

Environment variables passed to the server process. Used for API keys, database URLs, and configuration:

```json
"env": {
  "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx",
  "DATABASE_URL": "postgresql://user:pass@localhost:5432/db"
}
```

**Environment variable resolution:** Values starting with `$` or wrapped in `${...}` are resolved from your shell environment:

```json
"env": {
  "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
}
```

This reads `GITHUB_TOKEN` from your shell environment, keeping secrets out of the config file.

**Security note:** Never commit env values containing secrets to version control. Use environment variable references or add `.claude/mcp.json` to `.gitignore`.

## Complete Example: Multi-Server Configuration

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/me/projects/current"
      ],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://dev:dev@localhost:5432/myapp"
      ],
      "env": {}
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

## How Claude Uses MCP Tools

When Claude Code connects to MCP servers, each server's tools become available as callable functions. The tool names follow the pattern:

```
mcp__[server-name]__[tool-name]
```

For example, the GitHub server's "create_pull_request" tool becomes `mcp__github__create_pull_request`. Claude calls these tools automatically when they match the task at hand.

You can see available MCP tools by asking Claude: "What MCP tools are available?"

## Try It Yourself

Writing MCP config JSON by hand is tedious and error-prone. One missing comma, one wrong package name, and the server fails silently. The [MCP Config Generator](/mcp-config/) eliminates these errors by building your configuration interactively. Select servers, enter credentials, and download a validated `mcp.json` file. It knows the correct package names, argument formats, and required environment variables for every popular MCP server.

## Common Mistakes

### Trailing Commas

JSON does not allow trailing commas. This is invalid:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {},   // <-- trailing comma on last property: INVALID
    },   // <-- trailing comma on last server: INVALID
  }
}
```

### Wrong Package Names

The official MCP server packages follow this naming convention:
- `@modelcontextprotocol/server-[name]` for official servers
- `@[org]/mcp-server` for third-party servers

Common wrong names:
- `mcp-server-github` (wrong) vs `@modelcontextprotocol/server-github` (correct)
- `@mcp/filesystem` (wrong) vs `@modelcontextprotocol/server-filesystem` (correct)

### Missing -y Flag

Without `-y`, npx prompts for installation confirmation, which hangs because Claude Code cannot respond to the prompt:

```json
"args": ["@modelcontextprotocol/server-github"]     // WRONG: will hang
"args": ["-y", "@modelcontextprotocol/server-github"] // CORRECT: auto-confirms
```

### Paths with Spaces

If your directory path contains spaces, the path must be a single argument, not split across multiple args:

```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/me/My Projects"]  // CORRECT
```



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

- [MCP Server Setup Complete Guide](/mcp-server-setup-complete-guide-2026/) — Full installation walkthrough
- [Best MCP Servers for Claude Code](/best-mcp-servers-claude-code-2026/) — Server recommendations
- [Claude Code MCP Configuration Guide](/claude-code-mcp-configuration-guide/) — Official reference
- [Building a Custom MCP Server](/building-custom-mcp-server-claude-code/) — Create custom servers
- [MCP Empty Arguments Bug Fix](/anthropic-sdk-mcp-empty-arguments-bug/) — Common MCP bug fix
- [MCP Config Generator](/mcp-config/) — Generate valid config files

## Frequently Asked Questions

### Can I use both project and global MCP configs?
Yes. Claude Code loads both. Global config provides servers available everywhere. Project config adds project-specific servers. If both define a server with the same name, the project config wins.

### What happens if an MCP server fails to start?
Claude Code continues without that server. Other servers still work. Check your terminal for error messages. Common causes are wrong package names, missing dependencies, or invalid environment variables.

### Can I use relative paths in MCP config?
Relative paths in args are resolved from your current working directory when Claude Code starts. This is unreliable. Always use absolute paths to avoid confusion.

### How do I update an MCP server to the latest version?
NPX downloads the latest version by default unless your npm cache serves an old version. Clear the cache with `npx clear-npx-cache` or specify a version: `"args": ["-y", "@modelcontextprotocol/server-github@latest"]`.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I use both project and global MCP configs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code loads both. Global config provides servers for all projects. Project config adds specific servers. Same-name servers use the project config."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if an MCP server fails to start?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code continues without that server. Other servers still work. Check terminal for errors. Common causes are wrong package names or missing dependencies."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use relative paths in MCP config?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Relative paths resolve from the working directory when Claude Code starts which is unreliable. Always use absolute paths to avoid confusion."
      }
    },
    {
      "@type": "Question",
      "name": "How do I update an MCP server to the latest version?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "NPX downloads the latest version by default. Clear cache with npx clear-npx-cache or specify a version with the at-latest suffix in your args."
      }
    }
  ]
}
</script>
