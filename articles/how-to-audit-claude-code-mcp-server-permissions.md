---
layout: default
title: "How to Audit Claude Code MCP Server Permissions"
description: "A practical guide for developers and power users to audit, review, and maintain secure MCP server permissions in Claude Code. Includes CLI commands and code examples."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, mcp, security, auditing, permissions]
author: theluckystrike
reviewed: true
score: 8
permalink: /how-to-audit-claude-code-mcp-server-permissions/
---

# How to Audit Claude Code MCP Server Permissions

Regularly auditing your MCP server permissions ensures that Claude Code maintains a secure configuration as your toolset evolves. New servers get added, existing ones get updated, and permission scopes can drift over time. A systematic audit catches these changes before they become security issues.

This guide covers practical methods for reviewing MCP server permissions using built-in Claude Code commands, manual configuration inspection, and automated checking workflows.

## Finding Your MCP Server Configuration

Claude Code stores MCP server configurations in your global settings file. The location depends on your operating system:

- **macOS**: `~/Library/Application Support/Claude/settings.json`
- **Linux**: `~/.config/Claude/settings.json`
- **Windows**: `%APPDATA%/Claude/settings.json`

Open this file and look for the `mcpServers` section. This is your permission inventory.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace/projects"],
      "env": {}
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "your-key-here" }
    },
    "super-memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-super-memory"],
      "env": {}
    }
  }
}
```

Each entry represents a server with specific access capabilities. Understanding what each server can do is the first step in auditing.

## Using the Built-in /mcp Command

Claude Code provides a native command for reviewing MCP server status. Type `/mcp` in the chat interface to see a list of all configured servers, their running status, and available tools.

For power users, the same information is accessible via the `--printMcpServers` flag when launching Claude Code from the terminal:

```bash
claude --printMcpServers
```

This outputs a structured list of servers and the tools each provides. Use this output to verify that only intended servers are running.

## Auditing File System Access

The filesystem MCP server grants Claude Code the ability to read and write files. This is one of the most sensitive permissions to audit.

When configuring the filesystem server, you specify allowed directories:

```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", 
    "/workspace/projects",
    "/tmp/claude-cache"
  ],
  "env": {}
}
```

Audit this configuration by asking: should this server really access all these directories? Consider creating separate filesystem server instances with different scopes instead of granting broad access.

For example, a frontend-design workflow might need access to a specific project directory only:

```json
"filesystem-frontend": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", 
    "/workspace/frontend-project"
  ],
  "env": {}
}
```

This approach, known as permission compartmentalization, limits the blast radius if a server gets compromised.

## Checking Network-Bound Servers

Servers like brave-search, aws-mcp-server, or custom API integrations make network requests on your behalf. Audit these by reviewing environment variables and understanding what data they transmit.

In your settings.json, examine the `env` field for each server:

```json
"brave-search": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-brave-search"],
  "env": { "BRAVE_API_KEY": "***" }
}
```

Ask these questions during audit:
- Does this server need API keys, or can I use read-only credentials?
- What data leaves my system through this server?
- Are the servers still actively used, or should they be removed?

Unused servers create unnecessary attack surface. Remove servers you no longer need.

## Verifying Skill-Specific MCP Configurations

Certain Claude skills bundle their own MCP server configurations. Skills like the tdd skill, pdf skill, or xlsx skill may automatically configure servers when installed.

To audit these, check your settings.json after installing new skills. Look for servers with names matching the skill:

```json
"tdd": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-tdd"],
  "env": {}
}
```

Each skill documents which MCP servers it requires. Cross-reference your active configuration against skill documentation to ensure only necessary servers are enabled.

## Creating an Audit Checklist

Develop a personal audit routine. A simple checklist keeps your configuration secure:

1. **List all configured servers** using `/mcp` or the CLI flag
2. **Review each server's purpose** — can you explain what it does?
3. **Check file system scopes** — are directory permissions minimal?
4. **Verify environment variables** — are API keys necessary and rotated periodically?
5. **Remove unused servers** — delete entries you no longer use
6. **Document exceptions** — note any intentionally broad permissions and why they exist

Run this audit monthly or after installing new skills.

## Automating Permission Reviews

For teams managing Claude Code across multiple machines, automate the audit process. Create a script that extracts and validates MCP configurations:

```bash
#!/bin/bash
# audit-mcp.sh - Extract MCP server configuration for review

CONFIG_PATH="$HOME/Library/Application Support/Claude/settings.json"

echo "=== MCP Server Audit ==="
echo "Configuration: $CONFIG_PATH"
echo ""

if [ -f "$CONFIG_PATH" ]; then
  echo "Active servers:"
  grep -A2 '"mcpServers"' "$CONFIG_PATH" | grep -v '^{' | grep -v '^}$' | grep '"command"\|"args"' | head -20
else
  echo "No settings.json found"
fi
```

Run this script during security reviews or before deploying new Claude Code installations.

## Responding to Permission Issues

If you discover unexpected servers or overly broad permissions, take immediate action:

1. **Disable the server** by removing it from settings.json
2. **Restart Claude Code** to apply changes
3. **Re-enable with corrected permissions** after reviewing the configuration

For servers requiring API keys, rotate credentials after removing unexpected access.

## Conclusion

Auditing MCP server permissions is a straightforward process that significantly improves your Claude Code security posture. By regularly reviewing your configuration, practicing permission compartmentalization, and removing unused servers, you maintain control over what data and capabilities Claude Code can access.

The built-in `/mcp` command and settings.json inspection give you full visibility into your MCP landscape. Combine these tools with a simple audit checklist to keep your configuration aligned with your actual workflow needs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
