---
layout: default
title: "PagerDuty MCP Server Incident Management Guide"
description: "Learn how to automate PagerDuty incident management using MCP servers with Claude for streamlined DevOps workflows and faster response times."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, pagerduty, mcp, incident-management, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /pagerduty-mcp-server-incident-management-guide/
---

# PagerDuty MCP Server Incident Management Guide

[Incident management represents one of the most critical workflows in any production environment](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) When systems fail, every second counts toward minimizing downtime and restoring service. Integrating PagerDuty with Claude through Model Context Protocol (MCP) servers transforms how teams respond to incidents, enabling AI-assisted automation that accelerates resolution times and reduces human error.

[This guide walks you through setting up and using the PagerDuty MCP server for automated incident management](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/), providing practical examples that developers and DevOps engineers can implement immediately.

## Prerequisites and Initial Setup

Before configuring the PagerDuty MCP server, ensure you have a PagerDuty account with API access. You'll need to generate an API key with appropriate permissions for incident operations. The key should include read/write access to incidents, services, and escalation policies.

Install the required packages in your project:

```bash
npm install @modelcontextprotocol/server-pagerduty
```

Configure your MCP settings in the project configuration file:

```json
{
  "mcpServers": {
    "pagerduty": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-pagerduty"],
      "env": {
        "PAGERDUTY_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

Replace `your-api-key-here` with your actual PagerDuty API key. For production deployments, consider using environment variables or a secrets management solution rather than hardcoding credentials.

## Retrieving and Managing Incidents

Once connected, you can query active incidents directly through natural language. The MCP server exposes comprehensive incident management capabilities that integrate with Claude's reasoning abilities.

Query active incidents in your production environment:

```
Show me all critical incidents from the past 24 hours
```

This returns structured data including incident numbers, titles, current status, assigned responders, and escalation paths. You can filter by urgency level, service, or time range using natural language parameters.

For more specific queries, structure your requests with clear parameters:

```
Get all unresolved incidents assigned to the database-team escalation policy
```

The MCP server translates these requests into appropriate PagerDuty API calls, handling pagination and rate limiting automatically.

## Creating and Triggering Incidents Programmatically

Automating incident creation proves essential for integrating monitoring systems with PagerDuty. The MCP server enables you to create incidents from any data source or automated workflow.

Trigger a new incident when a critical threshold is exceeded:

```
Create a high-urgency incident with title "Database Connection Pool Exhausted" 
in the production-services schedule, 
assigning it to the database-oncall escalation policy
```

This single command creates the incident, assigns it to the appropriate schedule, and triggers the escalation chain. The response includes the new incident ID, which you can store for follow-up actions.

You can also create incidents with custom fields and urgency levels:

```
Create a low-urgency incident titled "Weekly Backup Verification" 
for the backup-team service with the note "Automated weekly check"
```

## Incident Lifecycle Automation

Managing incident lifecycle transitions manually consumes significant time during high-severity events. Automating status updates, acknowledgments, and resolutions accelerates response workflows.

Acknowledge an incident to prevent further escalation:

```
Acknowledge incident P12345 with note "Investigating - starting database diagnostics"
```

When you begin working on an incident, acknowledgment signals to the team that someone is actively addressing the issue. The note provides context for other responders who might view the incident.

Resolve incidents once remediation completes:

```
Resolve incident P12345 with note "Connection pool size increased from 50 to 100, monitoring for 15 minutes"
```

Resolution notes serve as documentation for post-incident reviews and help future responders understand what actions resolved the problem.

## Building Automated Response Workflows

Combining the PagerDuty MCP server with other Claude skills creates powerful automated incident response systems. The key lies in composing multiple capabilities into coherent workflows.

For example, integrate with the `tdd` skill to automatically generate test cases for incidents related to code changes:

```
After resolving incident P12345, use the tdd skill to generate regression tests 
for the database connection handling code that caused the issue
```

This creates a feedback loop where incidents drive test coverage improvements, reducing the likelihood of recurrence.

Similarly, use the `supermemory` skill to maintain a persistent knowledge base of incident resolutions:

```
Store the resolution details from incident P12345 in supermemory 
with tags ["database", "connection-pool", "production"]
```

Over time, this builds an searchable archive of institutional knowledge that accelerates future incident resolution.

## Escalation Policy Management

Understanding and manipulating escalation policies through natural language simplifies on-call management. You can query policy details, temporarily reassign responsibilities, or modify schedules without accessing the PagerDuty dashboard.

Query escalation policy details:

```
Show me the current members of the platform-oncall escalation policy
```

This returns the policy structure, including all users, schedules, and rotation rules. Use this information to verify coverage or identify gaps in on-call rotations.

Temporarily override on-call assignments during planned absences:

```
Add user john.doe@company.com to the platform-oncall schedule 
for the next 7 days starting today
```

This command handles the complexity of override scheduling, ensuring continuity during vacations or other absences.

## Generating Incident Reports

Post-incident documentation often requires significant effort to compile. The PagerDuty MCP server can extract incident data for analysis and reporting.

Request a summary of incident activity for a specific time period:

```
Generate a summary of all incidents from the past week, 
including total count by severity, average time to acknowledge, 
and average time to resolve
```

Use this data with other Claude skills like `xlsx` to create formatted reports:

```
Create an Excel spreadsheet with the weekly incident data, 
formatting it with separate sheets for each severity level
```

This automation transforms what traditionally required manual data gathering into a single command execution.

## Best Practices and Security Considerations

When implementing PagerDuty MCP server automation, follow security best practices to protect sensitive incident data and maintain appropriate access controls.

Store API keys in environment variables or secret management systems rather than configuration files committed to version control. Rotate keys regularly and revoke them immediately if compromised.

Implement appropriate rate limiting in your automation scripts to avoid triggering PagerDuty's API limits. The MCP server handles some rate limiting automatically, but your workflow logic should include retry logic with exponential backoff.

Audit automation actions through PagerDuty's integration logs. All MCP-triggered actions appear in the integration event log, maintaining compliance with incident management policies.

## Conclusion

The PagerDuty MCP server transforms incident management from reactive firefighting into proactive automation. By using Claude's natural language understanding and reasoning capabilities, teams can respond faster, document more thoroughly, and build institutional knowledge that improves over time.

Start with simple automations like incident acknowledgment and resolution notes, then expand into more complex workflows as your confidence grows. The combination of PagerDuty's incident management with Claude's AI capabilities creates a powerful foundation for modern DevOps practices.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [Datadog MCP Server Monitoring Automation with Claude](/claude-skills-guide/datadog-mcp-server-monitoring-automation-claude/)
- [MCP Server Logging Audit Trail Security Guide](/claude-skills-guide/mcp-server-logging-audit-trail-security-guide/)
- [Integrations Hub](/claude-skills-guide/integrations-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
