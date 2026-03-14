---
layout: default
title: "Claude Code MCP Tool Allow and Deny Lists"
description: "A comprehensive guide to configuring tool allow and deny lists in Claude Code's Model Context Protocol. Learn how to control which tools your MCP servers."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, claude-skills, mcp, security, tool-permissions]
reviewed: true
score: 8
permalink: /claude-code-mcp-tool-allow-and-deny-lists/
---

# Claude Code MCP Tool Allow and Deny Lists

[The Model Context Protocol (MCP) serves as the backbone for extending Claude Code's capabilities](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/) through external tools and services. When you connect MCP servers to Claude Code, you gain access to a wide array of tools—from file system operations to database queries. However, with great power comes the need for careful access control. This is where tool allow and deny lists become essential for developers and power users who need granular control over their AI assistant's capabilities.

## Understanding MCP Tool Access Control

MCP tool allow and deny lists provide a mechanism to filter which tools are available when Claude Code interacts with your MCP servers. Rather than granting blanket access to all tools an MCP server offers, you can explicitly whitelist the tools you need or blacklist those that pose security risks or simply aren't relevant to your workflow.

This feature becomes particularly valuable in [enterprise environments where security compliance](/claude-skills-guide/claude-skills-access-control-and-permissions-enterprise/) requires limiting tool access, or when working with MCP servers that expose many tools but you only need a subset for your current task.

For example, [when using the `pdf` skill to work with PDF documents](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/), you might only need read and extraction capabilities rather than full document generation. Similarly, when using the `xlsx` skill for spreadsheet operations, you might want to restrict access to file deletion operations while allowing read, write, and formula operations.

## Configuring Allow Lists

The allow list approach explicitly specifies which tools are permitted. This is the recommended approach for security-sensitive environments because it follows the principle of least privilege—you only get access to exactly what you need.

Add the `allowedTools` field to your MCP server configuration in `claude.settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/projects"],
      "allowedTools": ["read_file", "write_file", "create_directory", "list_directory"]
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "./app.db"],
      "allowedTools": ["sqlite_query", "sqlite_execute"]
    }
  }
}
```

In this configuration, the filesystem MCP server can only read and write files within the specified directory, while the database server can only execute queries. Claude Code will refuse to call any tool not explicitly listed, even if the MCP server offers it.

This pattern works exceptionally well when combined with specialized skills. When using the `tdd` skill for test-driven development, you might configure your MCP servers to only allow test execution and code reading tools, preventing any accidental file deletions or system command executions.

## Configuring Deny Lists

Deny lists work in the opposite direction—they specify which tools should be blocked while allowing everything else. This approach is useful when you want to use most tools from an MCP server but need to exclude a few problematic ones.

Add the `deniedTools` field to your configuration:

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"],
      "deniedTools": ["git_force_push", "git_delete_branch"]
    },
    "docker": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-docker"],
      "deniedTools": ["docker_remove_container", "docker_remove_image"]
    }
  }
}
```

The docker configuration prevents accidental removal of containers and images while keeping all other docker operations available. Similarly, the git configuration blocks potentially destructive operations like force pushes and branch deletions.

When using the `frontend-design` skill for UI development, you might want to deny tools that modify your source code directly, allowing only tools that read files and execute design-related commands.

## Combining Allow and Deny Lists

For complex scenarios, you can use both allow and deny lists together. Claude Code evaluates the deny list after the allow list, so denied tools take precedence:

```json
{
  "mcpServers": {
    "search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-search"],
      "allowedTools": ["search_files", "grep", "find_files"],
      "deniedTools": ["search_files"] 
    }
  }
}
```

In this case, even though `search_files` appears in the allowed list, the deny list removes it from availability. This layered approach provides flexibility for fine-tuning tool access.

## Practical Examples for Common Workflows

When working with the `supermemory` skill for persistent context management, you might configure your MCP servers to allow memory read and write operations while denying deletion operations to prevent accidental data loss:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "allowedTools": ["memory_read", "memory_write", "memory_search"]
    }
  }
}
```

For documentation workflows using skills like `pdf` and `docx`, restrict access to prevent modifications to source code:

```json
{
  "mcpServers": {
    "docs": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./docs"],
      "allowedTools": ["read_file", "write_file", "list_directory"]
    }
  }
}
```

This ensures Claude Code can read and write documentation files but cannot execute system commands or access files outside the designated directory.

## Security Best Practices

When configuring tool access control for MCP servers, consider these recommendations for maintaining security without sacrificing productivity.

First, prefer allow lists over deny lists whenever possible. Explicitly permitting only the tools you need provides stronger security guarantees than trying to remember which tools to block.

Second, [review your MCP server configurations regularly](/claude-skills-guide/how-to-audit-claude-code-mcp-server-permissions/). As your workflows evolve, you may accumulate tool permissions that are no longer necessary. Periodic audits help maintain minimal access privileges.

Third, use environment-specific configurations. Your development environment might need more permissive access than production, so maintain separate configuration files for different contexts.

Fourth, when using custom skills that interact with external services, restrict their MCP tool access to only what is necessary for the intended functionality.

## Troubleshooting Tool Access Issues

If Claude Code refuses to use a tool you expect to be available, check your configuration for typos in tool names. Tool names are case-sensitive and must match exactly what the MCP server exposes.

You can verify which tools are available by running Claude Code with verbose logging or checking the MCP server documentation for the exact tool names.

When tools you previously used suddenly become unavailable, you may have accidentally modified your configuration file. Restore a known-good configuration or review recent changes. For broader tool restriction at the session level, the [`disallowedTools` security configuration](/claude-skills-guide/claude-code-disallowedtools-security-configuration/) offers a complementary approach to identify the issue.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [MCP Server Permission Auditing Best Practices](/claude-skills-guide/mcp-server-permission-auditing-best-practices/)
- [Claude Code Skill Permission Scope Error Explained](/claude-skills-guide/claude-code-skill-permission-scope-error-explained/)
- [Advanced Hub](/claude-skills-guide/advanced-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
