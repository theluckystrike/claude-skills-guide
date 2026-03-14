---
layout: default
title: "Claude Code disallowedTools Security Configuration"
description: "Master disallowedTools configuration in Claude Code to control tool access, enhance security, and build safer AI-assisted workflows for development teams."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, security, disallowedtools, configuration]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code disallowedTools Security Configuration

When you run Claude Code in your development environment, the model has access to a powerful set of built-in tools—reading files, executing shell commands, running git operations, and more. For many workflows, this open access accelerates development. However, there are situations where restricting tool access becomes essential: isolating potentially risky operations, creating focused skill environments, or implementing defense-in-depth for automated agents.

[The `disallowedTools` configuration in Claude Code provides granular control](/claude-skills-guide/mcp-server-permission-auditing-best-practices/) over which tools the model cannot access, regardless of what the user requests. This feature gives developers and security-conscious teams precise control over their AI assistant's capabilities.

## Understanding the disallowedTools Mechanism

The `disallowedTools` field works as a deny-list at the configuration level. When a tool is marked as disallowed, Claude Code will refuse to invoke it, even when the user explicitly requests the operation. This differs from simply omitting tools from a skill's allowed list—`disallowedTools` operates at a more fundamental level, blocking specific capabilities across all interactions unless explicitly overridden.

The primary use cases for `disallowedTools` fall into three categories:

1. **Security hardening** — Preventing accidental execution of destructive commands in production environments
2. **Skill isolation** — Creating focused AI assistant behaviors that cannot access certain system capabilities
3. **Compliance requirements** — Meeting organizational policies that restrict specific operations (like shell execution or file system access)

## Configuring disallowedTools

You configure `disallowedTools` in your Claude Code settings file, typically located at `~/.claude/settings.json` or within project-specific configuration. The configuration accepts an array of tool names to block:

```json
{
  "allowedTools": ["Read", "Write", "Edit", "Glob", "Grep"],
  "disallowedTools": ["Bash", "ToolUse", "WebFetch", "WebSearch"]
}
```

This example creates a read-only Claude Code instance that can analyze code but cannot execute commands or access the web. Such a configuration proves valuable for code review scenarios or when you want Claude to provide guidance without taking direct action.

## Practical Security Configurations

### Read-Only Analysis Environment

For security audits and code review workflows, restrict Claude to read-only operations:

```json
{
  "disallowedTools": ["Bash", "Write", "Edit", "ToolUse"]
}
```

This configuration lets Claude analyze your codebase using `Read`, `Glob`, and `Grep` tools while preventing any modifications. When working with skills like `frontend-design` or `tdd`, this creates a safe environment for generating architecture recommendations or test plans without risk of accidental file changes.

### Production Environment Isolation

When deploying Claude Code in production systems or CI/CD pipelines, consider this more restrictive setup:

```json
{
  "disallowedTools": [
    "Bash",
    "Write",
    "Edit",
    "ToolUse",
    "WebFetch",
    "WebSearch",
    "bash"
  ]
}
```

This comprehensive restriction ensures your automated agents cannot execute shell commands or modify files—useful for monitoring and alerting use cases where Claude purely processes data and generates reports.

### Skill-Specific Tool Restrictions

Individual skills can override the global configuration using their own tool declarations. The `frontend-design` skill might allow file operations but restrict shell access:

```yaml
---
tools: [Read, Glob, Grep, Write]
disallowedTools: [Bash, ToolUse]
---
```

This creates a skill that can generate and modify design files but cannot execute build commands or run external programs—appropriate for a skill focused on design specification and implementation.

## Integration with MCP Servers

Model Context Protocol (MCP) servers extend Claude's capabilities with additional tools and services. When configuring `disallowedTools`, consider how MCP tool access interacts with your restrictions:

```json
{
  "mcpServers": {
    "supermemory": {
      "command": "npx",
      "args": ["-y", "supermemory-mcp"]
    }
  },
  "disallowedTools": ["WebFetch", "WebSearch"]
}
```

In this configuration, Claude can use the `supermemory` MCP server for memory management but cannot directly fetch web content. The MCP server operates within the bounds of your disallowed tools configuration.

## Security Considerations

The `disallowedTools` configuration provides defense-in-depth but should not be your only security measure. Keep these considerations in mind:

**Configuration persistence**: Claude Code configurations persist across sessions. Verify your settings regularly, especially when sharing configurations across teams.

**Override attempts**: While `disallowedTools` blocks tool invocation, a sufficiently capable model might attempt workarounds. For high-security environments, combine tool restrictions with operating system-level permissions and container isolation.

**Skill interactions**: When using multiple skills together, each skill's tool configuration interacts with global settings. Test your skill workflows to ensure tool access behaves as expected.

**Logging and audit trails**: Claude Code logs tool invocation attempts, including blocked calls. Monitor these logs to understand when and why tool access was denied.

## Common Patterns and Anti-Patterns

Effective `disallowedTools` configurations follow certain patterns. Start with the most restrictive configuration reasonable for your use case, then selectively enable tools as needed. This approach—deny-by-default with explicit allow-listing—reduces the attack surface more effectively than trying to block specific risky operations.

A common anti-pattern is blocking only obviously dangerous tools while leaving others accessible. For example, blocking `Write` but allowing `Bash` still permits file modification through shell commands. Consider the full range of ways Claude might accomplish an action when designing your restrictions.

## Real-World Application

Teams implementing AI-assisted development workflows frequently use `disallowedTools` to create tiered environments. Junior developers might work with Claude configured for read-only analysis and limited tool access, while senior developers have broader capabilities. Automated systems in CI/CD pipelines run with minimal tool access—often just analysis and reporting tools—while local development environments permit full tool access.

The `pdf` skill demonstrates practical skill-level tool configuration. When generating documents, this skill typically needs file write access but benefits from restricted shell access to prevent unintended command execution during document generation.

## Summary

The `disallowedTools` configuration in Claude Code provides essential security control for development teams. By carefully designing your tool access restrictions, you create safe, focused AI assistant environments that enhance productivity without introducing unnecessary risk. Start with restrictive configurations, understand the tool interactions in your workflows, and regularly audit your settings as your usage evolves.

## Related Reading

- [Claude Code MCP Tool Allow and Deny Lists](/claude-skills-guide/claude-code-mcp-tool-allow-and-deny-lists/)
- [MCP Server Permission Auditing Best Practices](/claude-skills-guide/mcp-server-permission-auditing-best-practices/)
- [Claude Code Skill Permission Scope Error Explained](/claude-skills-guide/claude-code-skill-permission-scope-error-explained/)
- [Advanced Hub](/claude-skills-guide/advanced-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
