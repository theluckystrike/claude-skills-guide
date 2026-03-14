---

layout: default
title: "Setting Up Claude Code Approved Tools List for Enterprise"
description: "A comprehensive guide for enterprise developers on configuring approved tools, skills, and MCP servers in Claude Code. Learn how to implement."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /setting-up-claude-code-approved-tools-list-for-enterprise/
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills]
---

{% raw %}
## Introduction

As organizations adopt Claude Code across development teams, the need for governance becomes critical. Enterprise environments require control over which tools, skills, and Model Context Protocol (MCP) servers are accessible to developers. An approved tools list helps security teams maintain compliance, ensures developers use vetted solutions, and prevents unauthorized extensions from introducing vulnerabilities.

This guide walks you through setting up a Claude Code approved tools list for enterprise environments. You'll learn the configuration methods, security considerations, and practical patterns for implementing tool governance across your organization.

## Understanding Claude Code Tool Governance

Claude Code provides several layers of tool access that enterprises can control. The primary components include built-in CLI tools, community skills from the skills directory, custom MCP servers, and file system access permissions. Each layer requires different configuration approaches.

The governance model follows a deny-by-default philosophy—developers can only use tools explicitly approved by your organization. This approach aligns with enterprise security frameworks like SOC 2 and ISO 27001, where controlling access to external resources is essential for compliance.

### Tool Categories to Consider

Before implementing your approved tools list, categorize the tools your teams need:

- **Development tools**: Git operations, code editors, linters, formatters
- **Testing frameworks**: Unit testing libraries, E2E testing tools, security scanners
- **Infrastructure tools**: Cloud provider CLIs, container tools, IaC utilities
- **Communication tools**: Slack, Jira, Confluence integrations
- **Data tools**: Database clients, API testing tools, ETL utilities

Understanding these categories helps you create targeted policies rather than a monolithic allowlist.

## Configuring the Approved Tools List

Claude Code supports configuration through the `CLAUDE_CODE_CONFIG` environment variable and project-level `claude.md` files. For enterprise deployments, combine both approaches for comprehensive coverage.

### Global Configuration via Environment Variables

Set up a global configuration that applies to all Claude Code sessions in your organization:

```bash
# Set approved tools globally
export CLAUDE_CODE_ALLOWED_TOOLS="git,read_file,write_file,bash,grep"
export CLAUDE_CODE_ALLOWED_SKILLS="code-review,security-scan,docs-generator"
export CLAUDE_CODE_ALLOWED_MCP="github,gitlab,aws-sdk"
export CLAUDE_CODE_DENIED_TOOLS="curl,wget,exec"
```

This configuration uses a whitelist approach—only tools explicitly listed are permitted. The `DENIED_TOOLS` variable provides an additional layer for known problematic tools.

### Project-Level Tool Restrictions

For project-specific controls, create a `CLAUDE.md` file in your repository:

```markdown
# Claude Code Configuration

## Approved Tools
- git: Version control operations
- read_file: Reading source files
- write_file: Creating and modifying code
- bash: Running tests and builds
- grep: Code search and analysis

## Approved Skills
- code-review: Automated code review
- security-scan: Vulnerability scanning
- docs-generator: Documentation generation

## Restricted Operations
- No external network calls except through approved MCP servers
- No execution of untrusted scripts
- File system access limited to project directory
```

This project-level configuration overrides global settings, allowing teams to customize tool access based on project requirements.

## MCP Server Governance

MCP servers extend Claude Code's capabilities significantly. Enterprise deployments require careful management of these extensions.

### Approved MCP Server List

Configure allowed MCP servers through the Claude Code configuration:

```json
{
  "mcpServers": {
    "approved": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "allowed_repos": ["org/frontend-*", "org/backend-*"]
      },
      "aws-sdk": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-aws"],
        "region": "us-east-1",
        "allowed_services": ["s3", "lambda", "dynamodb"]
      },
      "database": {
        "command": "./mcp-servers/database-server",
        "allowed_databases": ["prod-read-replica", "staging"]
      }
    },
    "denied": [
      "unofficial-twitter",
      "unverified-payment-processor"
    ]
  }
}
```

This configuration explicitly lists approved MCP servers and their parameters, preventing developers from connecting unauthorized services.

### MCP Server Security Considerations

When approving MCP servers for enterprise use, evaluate each server against your security criteria:

- **Data access**: What data can the server access?
- **Network permissions**: Does the server make external network calls?
- **Credential handling**: How does the server manage authentication?
- **Audit logging**: Does the server log all operations?
- **Update frequency**: How often is the server maintained?

Create a security review checklist and require approval from your security team before adding new MCP servers to the approved list.

## Implementing Team-Specific Tool Policies

Large organizations often need different tool policies for different teams. Claude Code supports this through environment-based configuration.

### Team Configuration Example

```bash
# Backend team configuration
export CLAUDE_CODE_TEAM="backend"
export CLAUDE_CODE_ALLOWED_TOOLS="git,read_file,write_file,bash,grep,docker"
export CLAUDE_CODE_ALLOWED_MCP="github,aws-sdk,database-server"
export CLAUDE_CODE_ALLOWED_SKILLS="code-review,security-scan,migration-helper"

# Data science team configuration  
export CLAUDE_CODE_TEAM="data-science"
export CLAUDE_CODE_ALLOWED_TOOLS="git,read_file,write_file,bash,python,jupyter"
export CLAUDE_CODE_ALLOWED_MCP="github,jupyter-kernel,s3-data-connector"
export CLAUDE_CODE_ALLOWED_SKILLS="data-analysis,ml-pipeline,visualization-helper"
```

Each team gets a tailored toolset that supports their specific workflows while maintaining organizational security standards.

## Enforcing Policies with CI/CD Integration

Enterprise tool governance works best when integrated with your continuous integration pipeline. Add validation checks to ensure compliance:

```yaml
# .github/workflows/claude-code-compliance.yml
name: Claude Code Compliance Check

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  validate-claude-config:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate approved tools list
        run: |
          # Check if CLAUDE.md exists
          if [ -f "CLAUDE.md" ]; then
            # Validate tool permissions
            node scripts/validate-claude-tools.js
          fi
          
      - name: Check for unauthorized MCP servers
        run: |
          # Scan for MCP server configurations
          grep -r "mcpServers" .claude/ || true
          # Report any unapproved servers
          ./scripts/report-unapproved-mcp.sh
```

This workflow validates that all Claude Code configurations comply with your organization's policies before code merges.

## Monitoring and Auditing Tool Usage

Effective governance requires visibility into how tools are being used. Implement logging and monitoring:

```javascript
// Tool usage logger
const fs = require('fs');

function logToolUsage(toolName, params, userId) {
  const logEntry = {
    timestamp: new Date().toISOString(),
    tool: toolName,
    user: userId,
    params: sanitizeParams(params),
    session: process.env.CLAUDE_SESSION_ID
  };
  
  fs.appendFileSync(
    '/var/log/claude-code/usage.jsonl',
    JSON.stringify(logEntry) + '\n'
  );
}

// Audit report generation
function generateAuditReport(startDate, endDate) {
  const logs = fs.readFileSync('/var/log/claude-code/usage.jsonl', 'utf8');
  const entries = logs.split('\n')
    .filter(line => line)
    .map(line => JSON.parse(line))
    .filter(entry => 
      entry.timestamp >= startDate && entry.timestamp <= endDate
    );
    
  return {
    totalOperations: entries.length,
    toolUsage: entries.reduce((acc, entry) => {
      acc[entry.tool] = (acc[entry.tool] || 0) + 1;
      return acc;
    }, {}),
    uniqueUsers: [...new Set(entries.map(e => e.user))],
    complianceViolations: entries.filter(e => e.violation).length
  };
}
```

Regular audit reports help security teams identify policy violations, usage patterns, and opportunities for tool policy refinement.

## Best Practices Summary

Implementing an approved tools list for Claude Code in enterprise environments requires a layered approach:

1. **Start with a whitelist**: Default to denying all tools, then explicitly approve those meeting your security criteria
2. **Categorize tools**: Group tools by function to create targeted policies for different teams
3. **Layer configurations**: Combine global environment variables with project-level `CLAUDE.md` files
4. **Review MCP servers carefully**: Evaluate each server's security posture before approval
5. **Integrate with CI/CD**: Validate configurations automatically in your pipeline
6. **Monitor usage**: Implement logging to track tool usage and identify compliance issues

Following these practices ensures your organization maintains security and compliance while giving developers the tool access they need to be productive.

## Conclusion

Setting up an approved tools list for Claude Code is essential for enterprise security and compliance. By configuring tool permissions at the global and project levels, implementing MCP server governance, and integrating compliance checks into your development workflow, you can confidently deploy Claude Code across your organization.

Start with basic tool whitelisting, gradually add team-specific policies, and continuously refine your approach based on audit findings and developer feedback.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

