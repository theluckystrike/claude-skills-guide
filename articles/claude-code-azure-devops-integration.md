---
layout: default
title: "Claude Code Azure DevOps Integration (2026)"
description: "Integrate Claude Code with Azure DevOps pipelines, repos, and boards. Automate CI/CD, code reviews, and work item management."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-azure-devops-integration/
categories: [guides]
tags: [claude-code, claude-skills, azure-devops, ci-cd, devops]
reviewed: true
score: 6
geo_optimized: true
---

Integrating Claude Code with Azure DevOps connects your AI assistant to pipelines, repositories, boards, and artifacts. This guide shows how to set up the connection so Claude Code can create work items, trigger builds, review pull requests, and manage your Azure DevOps workflow from the terminal.

## The Problem

Azure DevOps teams split their attention between the web portal for boards and pipelines, the IDE for code, and the terminal for CLI operations. Claude Code has no native awareness of your Azure DevOps project. Without integration, you manually describe pipeline failures, copy build logs, and switch contexts constantly between tools.

## Quick Solution

1. Install the Azure DevOps CLI extension:

```bash
az extension add --name azure-devops
az devops configure --defaults organization=https://dev.azure.com/your-org project=your-project
```

2. Create a Personal Access Token (PAT) in Azure DevOps with the scopes you need (Code, Build, Work Items).

3. Set the token for CLI authentication:

```bash
export AZURE_DEVOPS_EXT_PAT="your-pat-token"
```

4. Add Azure DevOps context to your `.claude/settings.json`:

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-azure-devops"],
      "env": {
        "AZURE_DEVOPS_ORG": "https://dev.azure.com/your-org",
        "AZURE_DEVOPS_PAT": "your-pat-token",
        "AZURE_DEVOPS_PROJECT": "your-project"
      }
    }
  }
}
```

5. Restart Claude Code and test:

```text
Show me the last 5 failed pipeline runs
```

## How It Works

Claude Code interacts with Azure DevOps through the REST API via an MCP server or by executing `az devops` CLI commands. The MCP server wraps the Azure DevOps REST API, exposing operations like creating work items, querying build status, listing pull requests, and reading pipeline logs.

When you ask Claude Code about a failed build, it calls the MCP tool to fetch the pipeline run details, reads the logs, and identifies the failure point. For work item management, Claude Code can create, update, and query items using WIQL (Work Item Query Language) through the API.

The PAT token controls access scope. Claude Code can only perform operations that the token allows. This gives you fine-grained control over what the AI assistant can do in your Azure DevOps environment.

## Common Issues

**PAT token scope too narrow**: If Claude Code cannot list pipelines or create work items, verify your PAT has the required scopes. Common scopes needed: `vso.build_execute`, `vso.code_write`, `vso.work_write`.

**Organization URL format**: The organization URL must be `https://dev.azure.com/your-org` (new format), not `https://your-org.visualstudio.com` (legacy format). Using the wrong format causes authentication failures.

**Pipeline YAML not found**: When Claude Code tries to read pipeline definitions, ensure the `azure-pipelines.yml` file is at the repository root or the path is specified in your CLAUDE.md context.

## Example CLAUDE.md Section

```markdown
# Azure DevOps Integration

## Project Details
- Organization: https://dev.azure.com/our-company
- Project: mobile-app
- Default branch: main
- Pipeline: mobile-app-ci (ID: 42)

## Workflow Rules
- Work items follow format: Feature > User Story > Task
- PRs require 2 approvers minimum
- Pipeline must pass before merge
- Use area path: mobile-app\backend for API work
- Sprint cadence: 2 weeks, starting Monday

## Common Commands
- Check build status: `az pipelines runs list --top 5`
- Create bug: `az boards work-item create --type Bug`
- List active PRs: `az repos pr list --status active`
```

## Best Practices

- **Use least-privilege PAT tokens.** Create separate tokens for read-only querying and write operations. Use the read-only token by default.
- **Store PAT in environment variables, not in config files.** Never commit tokens to `.claude/settings.json` that gets checked into source control. Use environment variable references instead.
- **Document sprint context in CLAUDE.md.** Include current sprint name, iteration path, and active work item IDs so Claude Code can reference them accurately.
- **Automate pipeline monitoring with hooks.** Set up Claude Code hooks to run `az pipelines runs show` after git push operations to monitor build status.
- **Keep pipeline YAML in CLAUDE.md context.** Reference your `azure-pipelines.yml` path so Claude Code can read and suggest improvements to your CI/CD configuration.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-azure-devops-integration)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code azure devops integration?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Azure DevOps Integration](/claude-code-azure-devops-integration-workflow-tutorial/)
- [Claude Code Azure API Integration Guide](/claude-code-azure-api/)
- [Claude Code Azure DevOps MCP Setup](/claude-code-azure-devops-mcp/)
