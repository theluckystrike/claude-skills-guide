---
layout: default
title: "Claude Code for n8n Automation"
description: "Build n8n automation workflows with Claude Code nodes. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-n8n-automation-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, n8n, workflow]
---

## The Setup

You are building automation workflows with n8n, the open-source workflow automation tool with a visual editor and 400+ integrations. Claude Code can generate custom n8n nodes and workflow JSON, but it defaults to Zapier patterns or generates standalone scripts instead of n8n-compatible workflow definitions.

## What Claude Code Gets Wrong By Default

1. **Writes standalone Node.js scripts.** Claude generates Express servers or standalone scripts for automation. n8n uses a visual workflow with connected nodes — code goes into Code nodes or custom node packages, not standalone files.

2. **Uses Zapier webhook format.** Claude formats webhooks for Zapier's trigger format. n8n's Webhook node expects different headers and configuration, and workflows are triggered differently.

3. **Generates n8n workflow JSON incorrectly.** Claude tries to generate workflow JSON but gets the node connection format wrong. n8n's connection schema has specific `main: [[{ node, type, index }]]` formatting.

{% raw %}4. **Ignores n8n's expression syntax.** Claude hardcodes values in nodes. n8n uses `{{ $json.fieldName }}` expressions to reference data from previous nodes in the workflow chain.{% endraw %}

## The CLAUDE.md Configuration

```
{% raw %}
# n8n Workflow Automation

## Platform
- Automation: n8n (self-hosted or n8n.cloud)
- Custom nodes: TypeScript with @n8n/n8n-nodes-base
- Code nodes: JavaScript/Python in workflow
- API: n8n REST API for workflow management

## n8n Rules
- Workflows are node graphs with connections
- Reference previous node data: {{ $json.field }}
- Code node: JavaScript with items array input/output
- Custom nodes: implement INodeType interface
- Credentials: managed in n8n, not hardcoded
- Webhook trigger: /webhook/ path auto-configured
- Error handling: Error Trigger node for workflow failures

## Conventions
- Custom nodes in packages/nodes-custom/ directory
- Workflow JSON exported for version control
- Credentials stored in n8n, referenced by name
- Code nodes for data transformation between services
- Use expressions over Code nodes when possible
- Test with n8n's built-in execution preview
- Pin data on nodes for consistent testing
{% endraw %}
```

## Workflow Example

You want to create a custom n8n node for your internal API. Prompt Claude Code:

"Create a custom n8n node for our project management API. It should have operations for listing projects, creating a project, and updating project status. Include credential definition for API key authentication."

Claude Code should create a node class implementing `INodeType` with `description` defining properties, operations, and credentials, a `credentials` file defining the API key auth type, and an `execute` method that makes HTTP requests to your API based on the selected operation.

## Common Pitfalls

{% raw %}1. **Expression vs static value confusion.** Claude sets node parameters as static strings when they should be expressions referencing previous nodes. In n8n, use the `=` toggle on fields to switch to expression mode and reference `{{ $json.data }}`.{% endraw %}

2. **Code node return format.** Claude returns plain objects from Code nodes. n8n Code nodes must return an array of items: `return items.map(item => ({ json: { ...item.json, newField: 'value' } }))`. Wrong format causes silent data loss.

3. **Webhook URL vs production URL.** Claude uses the test webhook URL in external service configurations. n8n has separate test and production webhook URLs — the test URL only works during manual execution, not for live triggers.

## Related Guides

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
