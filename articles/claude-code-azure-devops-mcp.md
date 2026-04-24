---
layout: default
title: "Claude Code Azure DevOps MCP Setup (2026)"
description: "Configure the Azure DevOps MCP server for Claude Code. Connect pipelines, repos, and work items through the Model Context Protocol."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-azure-devops-mcp/
categories: [guides]
tags: [claude-code, claude-skills, azure-devops, mcp, devops]
reviewed: true
score: 6
geo_optimized: true
---

The Azure DevOps MCP server gives Claude Code structured access to your pipelines, repos, boards, and artifacts through the Model Context Protocol. This guide covers installation, authentication, and configuration so Claude Code can manage your Azure DevOps resources natively.

## The Problem

Using `az devops` CLI commands within Claude Code works but produces unstructured text output that Claude Code must parse heuristically. The MCP approach provides typed, structured tools that Claude Code can invoke reliably. Without MCP, complex queries like "show me all bugs assigned to me in the current sprint with failed linked builds" require chaining multiple CLI commands and manual interpretation.

## Quick Solution

1. Generate a Personal Access Token in Azure DevOps with full scope for your project:

```text
Azure DevOps > User Settings > Personal Access Tokens > New Token
Scopes: Code (Read & Write), Build (Read & Execute), Work Items (Read & Write)
```

2. Add the MCP server to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-azure-devops"],
      "env": {
        "AZURE_DEVOPS_ORG_URL": "https://dev.azure.com/your-org",
        "AZURE_DEVOPS_PAT": "your-pat-token",
        "AZURE_DEVOPS_DEFAULT_PROJECT": "your-project"
      }
    }
  }
}
```

3. Restart Claude Code and check the MCP connection:

```bash
claude /mcp
# Expected: azure-devops server listed with tools
```

4. Test a basic query:

```text
List open pull requests in the main repository
```

## How It Works

The Azure DevOps MCP server translates Claude Code tool calls into Azure DevOps REST API requests. When Claude Code starts, it launches the MCP server process, which registers its available tools: `list-work-items`, `create-work-item`, `get-pipeline-run`, `list-pull-requests`, `get-build-logs`, and others.

Each tool has a defined input schema and output format. When you ask Claude Code about your project state, it selects the appropriate tool, passes structured parameters, and receives typed JSON responses. This eliminates the parsing ambiguity of raw CLI output.

The MCP server maintains a persistent connection to Azure DevOps through your PAT token. It handles pagination, retries on transient failures, and rate limiting automatically. Tool responses include metadata like timestamps and IDs that Claude Code can use for follow-up queries.

## Common Issues

**MCP server fails to start**: Check that Node.js 18+ is installed. The MCP server requires a modern Node runtime. Run `node --version` to verify.

**Work items not returned**: WIQL queries through the MCP server default to the current project. If your work items are in a different project, specify the project name explicitly in your query or update `AZURE_DEVOPS_DEFAULT_PROJECT`.

**Build logs truncated**: Large build logs may be truncated by the MCP response size limit. Ask Claude Code to fetch specific task logs rather than the full build log to get complete output.

## Example CLAUDE.md Section

```markdown
# Azure DevOps MCP Configuration

## MCP Server
- Server: azure-devops (configured in .claude/settings.json)
- Org: https://dev.azure.com/acme-corp
- Project: web-platform

## Available MCP Tools
- list-work-items: Query work items by WIQL
- create-work-item: Create bugs, tasks, user stories
- get-pipeline-run: Fetch pipeline run details and logs
- list-pull-requests: List PRs with filters
- get-repository: Get repo metadata

## Usage Rules
- Always check pipeline status before creating PRs
- Use WIQL for complex queries, natural language for simple ones
- Link work items to PRs when creating them
- Never close work items without verifying pipeline passes
```

## Best Practices

- **Rotate PAT tokens regularly.** Set a 90-day expiration on your Azure DevOps PAT and update the MCP config when you rotate.
- **Use project-scoped tokens.** Restrict the PAT to a single project rather than granting organization-wide access.
- **Combine MCP with CLAUDE.md context.** List your team's branching strategy, PR conventions, and work item types in CLAUDE.md so Claude Code follows your process.
- **Monitor API usage.** Azure DevOps has rate limits per PAT. If Claude Code makes many queries in a session, monitor for 429 responses in the MCP server output.
- **Test with read-only first.** Start with a read-only PAT to validate the setup, then upgrade to read-write when you are confident in the configuration.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-azure-devops-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected Fix](/claude-code-mcp-server-disconnected/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
