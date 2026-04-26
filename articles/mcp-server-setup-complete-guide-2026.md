---
layout: default
title: "MCP Server Setup Complete Guide (2026)"
description: "End-to-end MCP server configuration for Claude Code. Install, configure, and verify MCP servers with step-by-step instructions. April 2026."
date: 2026-04-26
permalink: /mcp-server-setup-complete-guide-2026/
categories: [guides, claude-code]
tags: [MCP, server, setup, configuration, tutorial]
last_modified_at: 2026-04-26
---

# MCP Server Setup Complete Guide (2026)

Model Context Protocol (MCP) servers extend Claude Code with external capabilities: database access, file system operations, API integrations, and more. Setting up your first MCP server takes under 10 minutes, but getting the configuration right avoids hours of debugging later. The [MCP Config Generator](/mcp-config/) can build your config file automatically.

This guide walks through the complete setup process from installation to verification, covering both local and remote MCP servers.

## What MCP Servers Do

Without MCP, Claude Code can only read files and run shell commands in your project. MCP servers add structured tool access:

- **Database MCP** — Query and modify databases without writing raw SQL in bash
- **GitHub MCP** — Create PRs, review code, manage issues from within Claude
- **Filesystem MCP** — Safe, sandboxed file operations with access controls
- **Brave Search MCP** — Web search integrated into Claude's workflow
- **Custom MCP** — Any capability you build and expose via the MCP protocol

Each MCP server appears as a set of tools that Claude can call during your session.

## Prerequisites

Before setting up MCP servers, verify:

```bash
# Claude Code is installed
claude --version

# Node.js 18+ (most MCP servers require it)
node --version

# npm or npx available
npx --version
```

## Step 1: Understanding the Config File

MCP servers are configured in `.claude/mcp.json` at your project root or `~/.claude/mcp.json` globally. The structure is:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"],
      "env": {}
    }
  }
}
```

Each server entry has:
- **command** — The executable to run (usually `npx`, `node`, or `python`)
- **args** — Command-line arguments passed to the server
- **env** — Environment variables the server needs (API keys, tokens)

## Step 2: Install Your First MCP Server

The filesystem MCP server is the best starting point because it requires no API keys:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"],
      "env": {}
    }
  }
}
```

Save this to `.claude/mcp.json` in your project root.

**Important:** Replace `/Users/you/projects` with the actual directory you want Claude to access. This is a security boundary. Claude can only access files within this directory through the MCP server.

## Step 3: Verify the Server Works

Start a new Claude Code session. Claude automatically detects and connects to configured MCP servers:

```
$ claude
> What MCP servers are connected?
```

Claude should list the filesystem server and its available tools. If it does not, check:

1. The config file is valid JSON (no trailing commas)
2. The path in args points to an existing directory
3. npx is available in your PATH

## Step 4: Add More Servers

Here is a practical multi-server configuration:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSAxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

Each server starts as a separate process. Claude connects to all of them and can use tools from any server during a session.

## Step 5: Secure Your Configuration

**Never commit API keys to version control.** Use environment variable references or a separate secrets file:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Set `GITHUB_TOKEN` in your shell profile (`~/.zshrc` or `~/.bashrc`). Claude Code resolves environment variables in the config.

Add `.claude/mcp.json` to `.gitignore` if it contains secrets, or use the global `~/.claude/mcp.json` for personal servers.

## Common Server Configurations

### PostgreSQL Database

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/mydb"],
      "env": {}
    }
  }
}
```

### Supabase

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://xxxx.supabase.co",
        "SUPABASE_SERVICE_KEY": "eyJxxxxxxx"
      }
    }
  }
}
```

### Memory / Persistent Context

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    }
  }
}
```

## Try It Yourself

Manually writing MCP config JSON is error-prone. A missing comma, wrong path, or typo in a server name causes silent failures. The [MCP Config Generator](/mcp-config/) builds valid configuration files interactively. Select the servers you want, provide your credentials, and it generates a correctly formatted `mcp.json` ready to drop into your project.

## Troubleshooting

**Server not connecting.** Check that the npx package name is correct and published to npm. Run the npx command manually in your terminal to see error output.

**Permission denied.** File system MCP servers respect OS permissions. The directory path must be readable by your user account.

**Environment variables not resolving.** Restart your terminal after adding variables to your shell profile. Claude Code reads the environment at startup.

**Server crashes on startup.** Some servers require specific Node.js versions. Check the server's README for version requirements.

**Multiple servers conflicting.** If two servers expose tools with the same name, Claude may call the wrong one. Rename the server entry to disambiguate.



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — Top server recommendations
- [MCP Config JSON Explained](/mcp-config-json-explained-2026/) — Every config field decoded
- [Building a Custom MCP Server](/building-custom-mcp-server-claude-code/) — Build your own server
- [Claude Code MCP Configuration Guide](/claude-code-mcp-configuration-guide/) — Official config reference
- [Supabase MCP Integration Tutorial](/supabase-mcp-claude-code-integration-tutorial/) — Database MCP setup
- [MCP Config Generator](/mcp-config/) — Generate your config automatically

## Frequently Asked Questions

### How many MCP servers can I run simultaneously?
There is no hard limit, but each server runs as a separate process consuming memory. Practically, 5-10 servers work well. Beyond that, startup time increases and you may hit system resource limits.

### Do MCP servers persist between Claude Code sessions?
The configuration persists in mcp.json. Servers start fresh with each Claude Code session. Any in-memory state is lost between sessions unless the server implements persistence (like the memory server writing to disk).

### Can I use MCP servers with Claude API directly, without Claude Code?
MCP is a protocol. You can implement MCP client support in any application that calls the Claude API. Claude Code has built-in MCP client support. For custom applications you need to implement the client side yourself.

### Are MCP servers secure?
MCP servers run with your user permissions. A malicious server could access anything your user account can. Only install MCP servers from trusted sources. Review the source code of community servers before installing.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How many MCP servers can I run simultaneously?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No hard limit but each server runs as a separate process consuming memory. Practically 5-10 servers work well. Beyond that startup time increases."
      }
    },
    {
      "@type": "Question",
      "name": "Do MCP servers persist between Claude Code sessions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Configuration persists in mcp.json. Servers start fresh each session. In-memory state is lost unless the server implements disk persistence."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use MCP servers with Claude API directly without Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "MCP is a protocol. Claude Code has built-in MCP client support. For custom applications you need to implement the client side of the protocol yourself."
      }
    },
    {
      "@type": "Question",
      "name": "Are MCP servers secure?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "MCP servers run with your user permissions. A malicious server could access anything your account can. Only install servers from trusted sources and review community server source code."
      }
    }
  ]
}
</script>
