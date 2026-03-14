---
layout: default
title: "Linear MCP Server Issue Tracking with Claude Code"
description: "Learn how to integrate Linear issue tracking into Claude Code using the Linear MCP server for streamlined development workflow management."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, mcp, linear, issue-tracking, workflow]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Linear MCP Server Issue Tracking with Claude Code

Managing issues and projects directly from your coding environment saves context-switching overhead and keeps your development workflow fluid. [The Linear MCP server enables Claude Code to interact with your Linear workspace](/claude-skills-guide/articles/claude-code-mcp-server-setup-complete-guide-2026/), creating, updating, and querying issues without leaving your terminal or IDE.

This guide walks you through setting up the Linear MCP server and demonstrates practical workflows for issue tracking with Claude Code.

## Setting Up the Linear MCP Server

Before using Linear with Claude Code, you need to configure the MCP server. You'll need your Linear API key and the MCP server package installed.

First, create a configuration file for the MCP server. The server communicates with Linear's GraphQL API and exposes tools for issue management:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@linear/mcp-server"],
      "env": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
      }
    }
  }
}
```

Add your Linear API key to your environment variables or Claude Code configuration. You can generate an API key from your Linear workspace settings under API.

Once configured, Claude Code gains access to Linear tools including createIssue, updateIssue, listIssues, and searchIssues. These tools map directly to Linear's GraphQL API operations.

## Creating Issues from Claude Code

The most common workflow involves creating issues directly from your coding context. When you encounter a bug or feature request during a coding session, you can log it without switching applications.

```bash
# Example: Creating an issue via MCP tool call
createIssue(
  title: "Fix authentication token refresh",
  description: "The token refresh logic in auth.ts fails when the refresh token is expired. Implement proper error handling and redirect to login.",
  teamId: "TEAM_ID",
  priority: 2
)
```

This creates an issue in your specified team with priority level 2 (urgent). The description can include code snippets, error messages, or any context you gather during your coding session.

The integration works particularly well when combined with other skills. Use the tdd skill to generate test cases for your new issue, then create the issue with those test details included. Or use the code-analysis skill to gather relevant code context before writing your issue description. For a broader view of how Claude skills fit into issue-driven workflows, see the [Claude skills workflow for technical product managers guide](/claude-skills-guide/claude-skills-workflow-for-technical-product-managers/).

## Querying and Managing Issues

Beyond creation, the Linear MCP server lets you query existing issues to stay organized. You can list issues by status, assignee, or project:

```bash
# List all issues assigned to you with high priority
listIssues(
  filter: {
    assignee: { isMe: true },
    priority: { gte: 2 }
  },
  first: 10
)
```

This returns a structured list of issues you can review. The query syntax follows Linear's filter conventions, supporting complex conditions for refined searches.

For daily standups or planning sessions, retrieve issues by project and status:

```bash
listIssues(
  filter: {
    project: { id: "PROJECT_ID" },
    state: { name: { in: ["In Progress", "Backlog"] } }
  }
)
```

## Integrating with Development Workflows

The real power emerges when you combine Linear issue tracking with Claude Code's other capabilities. Here are practical integration patterns:

**Test-Driven Development with tdd**: When the tdd skill identifies a failing test, create a Linear issue immediately:

```
Use createIssue to log the test failure with the test output and relevant code context. Assign it to the current sprint and set priority based on whether it blocks other work.

```

**Documentation with pdf**: Generate PDF documentation for release notes, then create a Linear issue to track the documentation review:

```
Use the pdf skill to create release documentation, then createIssue to route it through your team's review workflow.

```

**Frontend Design Collaboration with frontend-design**: When the frontend-design skill produces UI mockups or specifications, create design review issues:

```
After frontend-design generates component specs, createIssue with the design deliverables attached for team review.

```

**Knowledge Management with supermemory**: Use supermemory to recall similar past issues or solutions before creating new ones:

```
Query supermemory for related historical context, then createIssue with links to previous relevant issues or solutions.

```

## Automating Issue Workflows

You can script common issue management patterns. Create a skill that handles routine updates:

```yaml
---
name: daily-issue-update
description: Update Linear issues with daily progress
tools: [createIssue, updateIssue, listIssues]
---

For each issue in the current sprint, check if there's been activity. If the issue has been waiting for review for more than 2 days, add a comment requesting review. If an issue is blocked, update the status to reflect that and notify the assignee.
```

This automation reduces manual status updates and keeps your team aware of bottlenecks. You can explore even more patterns in the [Claude skills with Linear project management tutorial](/claude-skills-guide/articles/claude-skills-with-linear-project-management-tutorial/).

## Practical Example: Bug Reporting Workflow

Here's a complete workflow for reporting and tracking bugs:

1. **Identify**: Use Claude Code to reproduce and understand the bug
2. **Contextualize**: Use the code-analysis skill to find related code and dependencies
3. **Create**: Use the Linear MCP server to create an issue with all context
4. **Link**: Reference the issue in your code comments or PR descriptions

```bash
createIssue(
  title: "User dashboard fails to load with large datasets",
  description: "## Steps to Reproduce\n1. Create more than 1000 items\n2. Navigate to /dashboard\n3. Observe loading spinner that never completes\n\n## Root Cause\nThe dashboard component loads all items into memory rather than using pagination.\n\n## Related Files\n- src/components/Dashboard.tsx\n- src/api/items.ts\n\n## Proposed Fix\nImplement cursor-based pagination in the API and update the component to handle paginated responses.",
  teamId: "TEAM_ID",
  priority: 3,
  labels: ["bug", "performance"]
)
```

## Best Practices

Keep your Linear integration effective with these approaches:

- **Create issues with actionable descriptions**: Include reproduction steps, root cause analysis, and relevant code references
- **Use labels consistently**: Establish a labeling convention and apply it across your team
- **Link issues to code**: Reference issue IDs in commit messages and PR descriptions for automatic tracking
- **Leverage priority levels**: Use priorities to help Claude Code focus on high-impact work first

Before committing your Linear API key to any config file, review the [MCP credential management and secrets handling guide](/claude-skills-guide/articles/mcp-credential-management-and-secrets-handling/) for secure storage patterns.

## Conclusion

The Linear MCP server transforms Claude Code into a powerful issue tracking hub. By creating and managing issues directly in your coding workflow, you maintain focus, preserve context, and keep your team synchronized. Combined with Claude Code skills like tdd for test management, pdf for documentation generation, and supermemory for knowledge recall, you build a cohesive development environment that bridges coding and project management.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/articles/claude-code-mcp-server-setup-complete-guide-2026/)
- [Jira MCP Server Claude Code Integration Guide](/claude-skills-guide/articles/jira-mcp-server-claude-code-integration-guide/)
- [ClickUp MCP Server Workflow Automation Guide](/claude-skills-guide/articles/clickup-mcp-server-workflow-automation-guide/)
- [Integrations Hub](/claude-skills-guide/integrations-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
