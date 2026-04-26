---
layout: default
title: "Claude Code Azure MCP Server Guide (2026)"
description: "Set up the Azure MCP server for Claude Code. Manage Azure resources, deploy apps, and monitor services through the Model Context Protocol."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-azure-mcp/
categories: [guides]
tags: [claude-code, claude-skills, azure, mcp, cloud]
reviewed: true
score: 6
geo_optimized: true
---

The Azure MCP server connects Claude Code to your Azure cloud resources through the Model Context Protocol. This guide walks through setup, authentication, and practical usage so Claude Code can manage App Services, Azure Functions, Storage, and other Azure resources directly from your terminal.

## The Problem

Azure developers managing cloud infrastructure alongside code changes face constant context switching. The Azure Portal is browser-based, the Azure CLI outputs raw text, and Claude Code has no native Azure awareness. You lose time describing your infrastructure state, copying resource details, and translating between tools.

## Quick Solution

1. Ensure Azure CLI is installed and authenticated:

```bash
az login
az account show
```

2. Add the Azure MCP server to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "azure": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-azure"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "your-subscription-id",
        "AZURE_RESOURCE_GROUP": "your-resource-group"
      }
    }
  }
}
```

3. Restart Claude Code and verify:

```bash
claude /mcp
# Should list "azure" with available tools
```

4. Test the connection with a resource query:

```text
List all App Services in my resource group
```

## How It Works

The Azure MCP server wraps the Azure SDK for JavaScript, exposing Azure Resource Manager operations as structured tools. When Claude Code starts, it spawns the MCP server process, which authenticates using your local Azure CLI session or environment credentials.

The server exposes tools organized by service: compute (VMs, App Services, Functions), storage (Blob, Table, Queue), networking (VNets, NSGs, Load Balancers), and monitoring (Metrics, Logs, Alerts). Each tool accepts typed parameters and returns structured JSON.

Authentication follows the Azure DefaultAzureCredential chain: environment variables, managed identity, Azure CLI, and then interactive browser. For local development, the Azure CLI credential is the most common path. The MCP server inherits whatever permissions your Azure identity has, so role-based access control (RBAC) governs what Claude Code can do.

## Common Issues

**DefaultAzureCredential failure**: If the MCP server cannot authenticate, ensure `az login` is current. Check with `az account get-access-token` to verify your session is valid.

**Wrong subscription context**: Azure accounts often have multiple subscriptions. Set the correct one with `az account set --subscription "name-or-id"` and match it in your MCP env config.

**Resource group not found**: Double-check the resource group name and ensure it exists in the configured subscription. Names are case-insensitive but must match exactly.

## Example CLAUDE.md Section

```markdown
# Azure Cloud Context

## MCP Server
- Azure MCP configured in .claude/settings.json
- Subscription: Production (sub-123)
- Resource Group: rg-webapp-prod
- Region: East US 2

## Infrastructure
- App Service Plan: asp-webapp-prod (P1v3)
- Web App: webapp-api-prod
- Azure Functions: func-workers-prod
- Storage: stwebappprod (Blob + Queue)
- Azure SQL: sql-webapp-prod/db-main
- Application Insights: ai-webapp-prod

## Rules
- NEVER scale down the App Service Plan without approval
- Use deployment slots (staging) before swapping to production
- Storage account is geo-redundant; do not change replication settings
- Always check Application Insights after deployments
```

## Best Practices

- **Scope to a single resource group.** Set `AZURE_RESOURCE_GROUP` in the MCP config so Claude Code defaults to your project's resource group without needing to specify it each time.
- **Use RBAC Reader role for safety.** Assign the `Reader` role to your service principal for day-to-day querying. Escalate to `Contributor` only for deployment sessions.
- **Document infrastructure relationships.** Azure resources have dependencies (App Service depends on App Service Plan, which depends on Resource Group). Map these in CLAUDE.md.
- **Tag resources consistently.** Azure tags help Claude Code filter and identify resources. Use tags like `project:myapp` and `environment:prod`.
- **Review cost impact.** Before letting Claude Code create or scale resources, document cost constraints in CLAUDE.md to prevent unexpected charges.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-azure-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)
- [Claude Code MCP Server Disconnected Fix](/claude-code-mcp-server-disconnected/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code azure mcp server?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Resources

- [Claude Code AWS MCP Server Setup Guide](/claude-code-aws-mcp-server/)
- [Claude Code FastAPI MCP Server Guide](/claude-code-fastapi-mcp/)
- [Claude Code Flutter MCP Server Guide](/claude-code-flutter-mcp/)
