---
layout: default
title: "Claude Code MCP Servers: Complete Setup Guide (2026)"
description: "Step-by-step guide to setting up MCP servers in Claude Code. Install, configure, and test your first Model Context Protocol server with full terminal walkthrough."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-mcp-servers-complete-setup-2026/
reviewed: true
categories: [tutorials]
tags: [claude, claude-code, mcp, model-context-protocol, setup, configuration]
---

# Claude Code MCP Servers: Complete Setup Guide (2026)

The Model Context Protocol (MCP) gives Claude Code direct access to external tools and data sources — databases, APIs, file systems, and more — without leaving your terminal. Instead of copying data between tools, you connect MCP servers that let Claude read, query, and act on external systems natively. The [MCP Config Generator](/mcp-config/) makes this setup fast by producing ready-to-use configuration files. This guide walks through a complete setup from scratch, including installing your first server, testing the connection, and fixing the most common issues.

## What MCP Actually Does

MCP is a standardized protocol that connects AI assistants to external tools. Each MCP server exposes a set of **tools** (actions the AI can take) and **resources** (data the AI can read). When you configure an MCP server in Claude Code, the assistant gains new capabilities without any custom code on your side.

The architecture is straightforward:

```
Claude Code CLI → MCP Client (built-in) → MCP Server (your config) → External Service
```

For example, connecting the GitHub MCP server lets Claude create pull requests, read issues, and search repositories — all through natural conversation.

## Installing Your First MCP Server

The GitHub MCP server is the best starting point. It requires only a personal access token and covers the most common developer workflow.

### Step 1: Generate a GitHub Token

```bash
# Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens
# Create a token with these permissions:
# - Repository access: All repositories (or select specific ones)
# - Permissions: Contents (read/write), Issues (read/write), Pull requests (read/write)
```

### Step 2: Add the MCP Server Configuration

Create or edit `~/.claude/mcp-servers.json`:

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

You can generate this configuration instantly with the [MCP Config Generator](/mcp-config/) — select GitHub from the dropdown, paste your token, and copy the output.

### Step 3: Restart Claude Code

```bash
# Exit any running session
# Start fresh
claude

# Verify the server loaded
/mcp
```

The `/mcp` command shows all connected servers and their status. You should see `github` listed as `connected`.

### Step 4: Test the Connection

```bash
# Inside Claude Code, try:
"List my 5 most recent GitHub repositories"

# Expected: Claude calls the GitHub MCP server and returns your repo list
```

## Adding Multiple Servers

Your `mcp-servers.json` file supports multiple servers simultaneously:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"],
      "env": {}
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

Each server runs as a separate process. Claude Code manages their lifecycle automatically — starting them when needed and shutting them down when your session ends.

## Project-Level vs Global Configuration

MCP servers can be configured at two levels:

| Level | File Location | Scope |
|-------|--------------|-------|
| Global | `~/.claude/mcp-servers.json` | Available in all projects |
| Project | `.claude/mcp-servers.json` | Available only in this project |

Project-level configuration is useful when a server needs project-specific credentials or when you want to share MCP setup with your team via version control.

```bash
# Create project-level config
mkdir -p .claude
cat > .claude/mcp-servers.json << 'EOF'
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_TOKEN}"
      }
    }
  }
}
EOF
```

## Debugging Common Issues

### Server Shows "disconnected"

```bash
# Check if the npm package exists
npx -y @modelcontextprotocol/server-github --help

# If it fails, clear npm cache
npm cache clean --force
```

### Authentication Errors

```bash
# Verify your token works outside Claude Code
curl -H "Authorization: token ghp_your_token" https://api.github.com/user

# Common fix: regenerate the token with correct scopes
```

### Server Crashes on Startup

Check the Claude Code logs for the actual error:

```bash
# Logs are typically at:
cat ~/.claude/logs/mcp-*.log

# Common causes:
# 1. Missing Node.js (need v18+)
# 2. npm registry timeout
# 3. Invalid JSON in config file
```

### Validate Your Configuration

```bash
# Check JSON syntax before restarting
python3 -m json.tool ~/.claude/mcp-servers.json
```

## Try It Yourself

Generate a working MCP configuration in seconds with the [MCP Config Generator](/mcp-config/). Select your server, enter credentials, and get a copy-paste config file — no manual JSON editing required.

<details>
<summary>What is MCP in Claude Code?</summary>
MCP (Model Context Protocol) is a standardized protocol that connects Claude Code to external tools and data sources. It allows Claude to interact with databases, APIs, and services directly from your terminal session.
</details>

<details>
<summary>How many MCP servers can I run at once?</summary>
There is no hard limit on simultaneous MCP servers. Most developers run 2-5 servers. Each server runs as a separate process, so resource usage scales linearly. Monitor memory if you add more than 10.
</details>

<details>
<summary>Do MCP servers work with Claude Code on all operating systems?</summary>
Yes. MCP servers work on macOS, Linux, and Windows (via WSL or native). The configuration format is identical across platforms. File paths in server arguments should use your OS conventions.
</details>

<details>
<summary>Can I use MCP servers with the Claude API directly?</summary>
MCP servers are designed for Claude Code (the CLI tool). The Claude API uses a different tool-use format. However, you can use the MCP SDK to build bridges between MCP servers and API-based applications.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is MCP in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "MCP (Model Context Protocol) is a standardized protocol that connects Claude Code to external tools and data sources. It allows Claude to interact with databases, APIs, and services directly from your terminal session."
      }
    },
    {
      "@type": "Question",
      "name": "How many MCP servers can I run at once?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There is no hard limit on simultaneous MCP servers. Most developers run 2-5 servers. Each server runs as a separate process, so resource usage scales linearly. Monitor memory if you add more than 10."
      }
    },
    {
      "@type": "Question",
      "name": "Do MCP servers work with Claude Code on all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. MCP servers work on macOS, Linux, and Windows (via WSL or native). The configuration format is identical across platforms. File paths in server arguments should use your OS conventions."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use MCP servers with the Claude API directly?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "MCP servers are designed for Claude Code (the CLI tool). The Claude API uses a different tool-use format. However, you can use the MCP SDK to build bridges between MCP servers and API-based applications."
      }
    }
  ]
}
</script>

## Related Guides

- [MCP Config Generator](/mcp-config/) — Generate MCP server configurations instantly
- [Claude Code Configuration Guide](/configuration/) — Full settings and preferences reference
- [Command Reference](/commands/) — All Claude Code commands explained
- [Advanced Usage Patterns](/advanced-usage/) — Power-user workflows and automation
- [Permissions and Security](/permissions/) — Control what Claude Code can access
