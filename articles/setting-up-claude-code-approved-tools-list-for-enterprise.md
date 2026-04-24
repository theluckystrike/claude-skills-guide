---
layout: default
title: "Setting Up Claude Code Approved Tools"
description: "Learn how to configure an approved tools list for Claude Code in enterprise environments. This guide covers security policies, tool restrictions, and."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /setting-up-claude-code-approved-tools-list-for-enterprise/
categories: [guides]
tags: [claude-code, claude-skills, enterprise, security, tool-restrictions]
reviewed: true
score: 7
geo_optimized: true
---
Enterprise development environments require careful control over which tools AI assistants can access. Claude Code's approved tools list feature enables security teams to define exactly which capabilities developers can use while working with AI-assisted coding. This guide walks through setting up and managing tool restrictions for enterprise deployments.

## Understanding Approved Tools Lists

The approved tools list is a security configuration that restricts which tools Claude Code can access during a session. In enterprise environments, this serves multiple purposes:

- Security compliance: Prevent sensitive data exposure through unauthorized file access
- Environment isolation: Limit tool access to approved development environments
- Audit requirements: Maintain clear boundaries around AI-assisted operations
- Risk management: Reduce the attack surface of AI coding assistants

When you configure an approved tools list, Claude Code will only use tools explicitly included in your configuration. Any attempt to use a non-approved tool will be blocked, and the model will either request approval or work around the limitation.

## Configuring Tool Restrictions

Claude Code supports tool restrictions through configuration files and environment variables. The primary method uses a JSON configuration file that lists approved tools.

## Basic Configuration Structure

Create a configuration file named `claude-tools.json` in your project's configuration directory:

```json
{
 "approvedTools": [
 "Read",
 "Edit",
 "Write",
 "Bash",
 "Glob",
 "Grep",
 "WebFetch"
 ],
 "blockedTools": [
 "TodoWrite",
 "TodoRead",
 "WebSearch"
 ],
 "allowMcpTools": false,
 "strictMode": true
}
```

This configuration explicitly allows core file operation tools while blocking risky operations. The `strictMode` flag ensures that any tool not explicitly approved is automatically denied.

## Environment-Based Configuration

For enterprise deployments, use environment variables to manage tool restrictions across different environments:

```bash
Development environment - more permissive
export CLAUDE_TOOLS_CONFIG="./config/claude-tools-dev.json"

Production environment - stricter controls
export CLAUDE_TOOLS_CONFIG="./config/claude-tools-prod.json"
```

Create environment-specific configurations to match your deployment workflows:

```json
{
 "approvedTools": [
 "Read",
 "Edit",
 "Write",
 "Bash",
 "Glob"
 ],
 "blockedTools": [
 "WebFetch",
 "WebSearch",
 "McpTools"
 ],
 "strictMode": true,
 "logLevel": "verbose"
}
```

## Implementing Per-Project Tool Policies

Enterprise teams often need different tool access levels for different projects. Claude Code supports project-level configurations that override global settings.

## Project-Specific Configuration

Add a `claude` section to your project's `.claude/settings.json`:

```json
{
 "claude": {
 "tools": {
 "approved": ["Read", "Edit", "Write", "Glob", "Grep"],
 "blocked": ["WebFetch", "McpTools", "Bash"],
 "requireApproval": ["Bash"]
 }
 }
}
```

The `requireApproval` field adds an extra layer of control by prompting for confirmation before executing specific tools. This is particularly useful for shell commands that could modify the system.

## Skill-Based Tool Restrictions

For skills that require specific tool access, define tool requirements in the skill's front matter:

```yaml
---
name: Security Review Skill
description: "Review code for security vulnerabilities"
---
```

This approach ensures that skills only have access to the minimum tools necessary for their purpose, following the principle of least privilege.

## Enterprise Integration Patterns

Large organizations typically integrate tool restrictions with their existing security infrastructure. Here are common patterns for enterprise deployments.

## Integration with Directory Services

Sync approved tools lists with your organization's directory service:

```bash
Fetch tool configuration from enterprise config
curl -H "Authorization: Bearer $ENTERPRISE_TOKEN" \
 "https://config.enterprise.com/claude-tools" \
 > claude-tools.json
```

This approach ensures consistent tool policies across all developers and automatically applies updates when security requirements change.

## Audit Logging Configuration

Enterprise environments require comprehensive audit trails. Configure logging for all tool operations:

```json
{
 "approvedTools": ["Read", "Edit", "Glob", "Grep"],
 "auditLog": {
 "enabled": true,
 "endpoint": "https://audit.enterprise.com/claude",
 "includePayloads": true,
 "redactPatterns": [
 "api_key",
 "password",
 "secret"
 ]
 }
}
```

The `redactPatterns` field automatically removes sensitive information from logs, maintaining security while preserving operational visibility.

## Multi-Team Tool Policies

Larger organizations may need different policies for different teams. Use hierarchical configurations:

```
config/
 claude-tools-base.json # Default restrictions
 claude-tools-security.json # Security team - full access
 claude-tools-devops.json # DevOps - infrastructure tools
 claude-tools-qa.json # QA - testing tools only
```

Apply team-specific configurations using environment selection or directory-based defaults.

## Best Practices for Enterprise Tool Lists

Following these practices ensures your tool restriction strategy remains effective as your organization evolves.

## Start Restrictive, Expand Carefully

Begin with minimal tool access and gradually add tools as your team proves its needs. This approach prevents accidental over-permissioning:

```json
{
 "approvedTools": ["Read", "Glob"],
 "strictMode": true
}
```

As developers demonstrate legitimate use cases, update the configuration through your established change management process.

## Regular Policy Reviews

Schedule quarterly reviews of approved tools lists to ensure configurations remain aligned with current requirements:

- Remove tools that are no longer needed
- Add newly approved capabilities
- Update blocking rules based on emerging threats
- Document any configuration changes

## Document Exceptions

Create a clear process for requesting tool access exceptions:

```markdown
Tool Access Exception Request

Requested Tool: [Tool Name]
Justification: [Business need]
Duration: [Temporary/Permanent]
Approved By: [Security contact]
```

This documentation ensures visibility into why certain tools are accessible and maintains accountability.

## Test Configurations Before Deployment

Before rolling out new tool restrictions, test them in a controlled environment:

```bash
Validate configuration syntax
claude --print "Validate the tool configuration in claude-tools.json"

Test with restricted allowedTools before deploying
claude --allowedTools "Read,Edit" --print "Test task with restricted tools"
```

This prevents configuration errors that could block legitimate development work.

## Troubleshooting Common Issues

When tool restrictions don't work as expected, these solutions address frequent problems.

## Tool Silently Denied

If Claude Code appears to ignore tool restrictions, verify the configuration is being loaded:

```bash
Check which config is active
claude config show

Validate JSON syntax
cat claude-tools.json | python3 -m json.tool
```

Configuration loading failures often stem from syntax errors or incorrect file paths.

## Overly Restrictive Policies

When tool restrictions prevent legitimate work, the model may struggle to complete tasks. Review Claude Code's feedback, it typically indicates which tools would help but are blocked. Use this information to make informed policy adjustments.

## Conflicts Between Global and Project Settings

Project-level configurations should override global settings. If you encounter unexpected behavior, check for conflicting files:

```bash
Find all potential configurations
find . -name "claude*.json" -o -name ".claude"
```

## Conclusion

Implementing an approved tools list for Claude Code in enterprise environments requires balancing security requirements with developer productivity. Start with restrictive configurations, establish clear processes for policy changes, and maintain comprehensive audit logs. Regularly review and update your tool policies to ensure they evolve with your organization's needs while maintaining the security posture your enterprise requires.

By following these patterns, security teams can confidently deploy Claude Code across their organization, knowing that tool access aligns with established policies and compliance requirements.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=setting-up-claude-code-approved-tools-list-for-enterprise)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Password Manager Policy: A Practical Guide for Developers](/chrome-enterprise-password-manager-policy/)
- [Chrome Incognito Mode Disable Enterprise: A Complete Guide](/chrome-incognito-mode-disable-enterprise/)
- [Chrome Verified Access Enterprise: A Developer's Guide](/chrome-verified-access-enterprise/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


