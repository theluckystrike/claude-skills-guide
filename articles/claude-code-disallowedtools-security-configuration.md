---
layout: default
title: "Configure disallowedTools in Claude (2026)"
description: "Restrict tool access in Claude Code with disallowedTools configuration. Control file operations, bash commands, and MCP tools for safer AI workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, security, disallowedtools, configuration]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-disallowedtools-security-configuration/
geo_optimized: true
last_tested: "2026-04-21"
---

# Claude Code disallowedTools Security Configuration

[When you run Claude Code in your development environment, the model has access to a powerful set of built-in tools](/best-claude-code-skills-to-install-first-2026/), reading files, executing shell commands, running git operations, and more. For many workflows, this open access accelerates development. However, there are situations where restricting tool access becomes essential: isolating risky operations, creating focused skill environments, or implementing defense-in-depth for automated agents.

[The `disallowedTools` configuration in Claude Code provides granular control](/mcp-server-permission-auditing-best-practices/) over which tools the model cannot access, regardless of what the user requests. This feature gives developers and security-conscious teams precise control over their AI assistant's capabilities.

## Understanding the disallowedTools Mechanism

The `disallowedTools` field works as a deny-list at the configuration level. When a tool is marked as disallowed, Claude Code will refuse to invoke it, even when the user explicitly requests the operation. This differs from simply omitting tools from a skill's allowed list, `disallowedTools` operates at a more fundamental level, blocking specific capabilities across all interactions unless explicitly overridden.

The primary use cases for `disallowedTools` fall into three categories:

1. Security hardening. Preventing accidental execution of destructive commands in production environments
2. Skill isolation. Creating focused AI assistant behaviors that cannot access certain system capabilities
3. Compliance requirements. Meeting organizational policies that restrict specific operations (like shell execution or file system access)

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

## Read-Only Analysis Environment

For security audits and code review workflows, restrict Claude to read-only operations:

```json
{
 "disallowedTools": ["Bash", "Write", "Edit", "ToolUse"]
}
```

This configuration lets Claude analyze your codebase using `Read`, `Glob`, and `Grep` tools while preventing any modifications. When working with skills like `frontend-design` or `tdd`, this creates a safe environment for generating architecture recommendations or test plans without risk of accidental file changes.

## Production Environment Isolation

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

This comprehensive restriction ensures your automated agents cannot execute shell commands or modify files, useful for monitoring and alerting use cases where Claude purely processes data and generates reports.

## Skill-Specific Tool Restrictions

To restrict tool access for specific workflows, you can set `disallowedTools` in your project-level `.claude/settings.json`. For example, to restrict the session to only file reading and pattern matching when using the `frontend-design` skill:

```json
{
 "permissions": {
 "deny": ["Bash", "Write"]
 }
}
```

This creates a session that can read and analyze design files but cannot execute build commands or write files, appropriate for a review-only design workflow.

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

Configuration persistence: Claude Code configurations persist across sessions. Verify your settings regularly, especially when sharing configurations across teams.

Override attempts: While `disallowedTools` blocks tool invocation, a sufficiently capable model might attempt workarounds. For high-security environments, combine tool restrictions with operating system-level permissions and container isolation.

Skill interactions: When using multiple skills together, each skill's tool configuration interacts with global settings. Test your skill workflows to ensure tool access behaves as expected.

Logging and audit trails: Claude Code logs tool invocation attempts, including blocked calls. Monitor these logs to understand when and why tool access was denied.

## Common Patterns and Anti-Patterns

Effective `disallowedTools` configurations follow certain patterns. Start with the most restrictive configuration reasonable for your use case, then selectively enable tools as needed. This approach, deny-by-default with explicit allow-listing, reduces the attack surface more effectively than trying to block specific risky operations.

A common anti-pattern is blocking only obviously dangerous tools while leaving others accessible. For example, blocking `Write` but allowing `Bash` still permits file modification through shell commands. Consider the full range of ways Claude might accomplish an action when designing your restrictions.

## Real-World Application

Teams implementing AI-assisted development workflows frequently use `disallowedTools` to create tiered environments. Junior developers might work with Claude configured for read-only analysis and limited tool access, while senior developers have broader capabilities. Automated systems in CI/CD pipelines run with minimal tool access, often just analysis and reporting tools, while local development environments permit full tool access.

The `pdf` skill demonstrates practical skill-level tool configuration. When generating documents, this skill typically needs file write access but benefits from restricted shell access to prevent unintended command execution during document generation.

## Testing Your disallowedTools Configuration

After configuring tool restrictions, verify they actually work before relying on them in security-sensitive workflows. A misconfigured `disallowedTools` entry (typo in a tool name, wrong nesting in the JSON) silently fails. Claude will still have access to the tool you intended to block.

Create a simple test session to verify each blocked tool:

```
Run the following command and tell me the output: echo "test_confirmation"
```

If `Bash` is correctly blocked, Claude should respond that it cannot execute that tool rather than running the command. If it runs, your configuration is not applying correctly.

For write tool restrictions, test with:

```
Create a file called test-disallowed.txt in the current directory with the content "verification"
```

A correctly blocked Write tool should produce a refusal. If the file appears on disk, the block is not working.

Run these checks after any configuration change and after updating Claude Code to a new version. tool names and configuration schemas can change between releases.

## Auditing Tool Usage in Logs

Claude Code logs tool invocations to `~/.claude/logs/` by default. After a session where you tested restricted tools, examine the log to confirm blocked invocations were recorded:

```bash
Check most recent session log for blocked tool attempts
tail -100 ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

Blocked tool attempts appear as error entries in the log. Regular auditing of these logs. especially in automated agent deployments. reveals whether any session is attempting to use tools outside your approved set, which may indicate a prompt injection attempt or a skills misconfiguration that is trying to invoke unavailable capabilities.

## Summary

The `disallowedTools` configuration in Claude Code provides essential security control for development teams. By carefully designing your tool access restrictions, you create safe, focused AI assistant environments that enhance productivity without introducing unnecessary risk. Start with restrictive configurations, understand the tool interactions in your workflows, and regularly audit your settings as your usage evolves.

## Documenting Tool Restrictions for Your Team

When deploying Claude Code with restricted tool configurations in a team environment, documenting the restrictions prevents confusion when team members encounter unexpected refusals. A developer who does not know that `Bash` is blocked in the CI environment will waste time troubleshooting what looks like a Claude Code bug.

Add a `CLAUDE.md` file to each project with a section describing active tool restrictions:

```markdown
Claude Code Configuration

This project runs Claude Code with the following tool restrictions:

Disallowed in CI/CD environments:
- `Bash`. shell execution disabled; use Read/Write/Edit for file operations
- `WebFetch` / `WebSearch`. no external network access in CI

Available everywhere:
- Read, Write, Edit, Glob, Grep. full file system access
- All MCP tools configured in .claude/mcp-servers.json

If you encounter "tool not available" errors locally, check ~/.claude/settings.json
for any project-overriding restrictions applied during onboarding.
```

This documentation surfaces in every Claude Code session because CLAUDE.md is read automatically at session start. Developers working in the project know upfront which capabilities are available rather than discovering restrictions through error messages during active work.




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to --dangerously-skip-permissions and safer alternatives
---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-disallowedtools-security-configuration)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code MCP Tool Allow and Deny Lists](/claude-code-mcp-tool-allow-and-deny-lists/)
- [MCP Server Permission Auditing Best Practices](/mcp-server-permission-auditing-best-practices/)
- [Claude Code Skill Permission Scope Error Explained](/claude-code-skill-permission-denied-error-fix-2026/)
- [Advanced Hub](/advanced-hub/)
- [Manifest V3 vs V2 Security — Developer Comparison 2026](/manifest-v3-vs-v2-security/)
- [Claude Code for Security Scan Automation? (2026)](/claude-code-for-security-scan-automation/)
- [Claude Code for Zero Trust Security Workflow Guide](/claude-code-for-zero-trust-security-workflow-guide/)
- [Claude Code for Falco Runtime Security Workflow](/claude-code-for-falco-runtime-security-workflow/)
- [Claude Code For Security Hub — Complete Developer Guide](/claude-code-for-security-hub-workflow/)
- [Claude Code Checkov Security Scanning Guide](/claude-code-checkov-security-scanning-guide/)
- [Should I Use Claude Code For Security — Developer Guide](/should-i-use-claude-code-for-security-sensitive-applications/)
- [Claude Code Security Engineer Vulnerability Triage Workflow](/claude-code-security-engineer-vulnerability-triage-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



