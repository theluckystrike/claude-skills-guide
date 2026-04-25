---
layout: default
title: "Claude Code for Windmill Dev (2026)"
description: "Claude Code for Windmill Dev — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-windmill-dev-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, windmill, workflow]
---

## The Setup

You are building internal tools and workflows with Windmill, an open-source platform for scripts, flows, and apps. Windmill lets you write scripts in TypeScript, Python, Go, or Bash, chain them into workflows, and build UIs on top — all with built-in scheduling, webhooks, and approval steps. Claude Code can build internal tools, but it creates standalone Express/Flask applications instead of Windmill scripts.

## What Claude Code Gets Wrong By Default

1. **Builds standalone web applications.** Claude creates Express servers with React dashboards for internal tools. Windmill provides the infrastructure — you write the script logic, Windmill handles the UI, scheduling, and execution.

2. **Manages secrets in .env files.** Claude puts API keys and database credentials in `.env`. Windmill has a built-in secret management system — secrets are stored encrypted and referenced as `$res:secrets/my_secret` in scripts.

3. **Creates custom job queues.** Claude sets up Redis/Bull for background job processing. Windmill is a job execution engine — scripts automatically queue, retry, and log results without custom queue infrastructure.

4. **Ignores the type system for parameters.** Claude writes scripts with untyped parameters. Windmill auto-generates input forms from TypeScript/Python type annotations — properly typed parameters give you free UI forms.

## The CLAUDE.md Configuration

```
# Windmill Internal Tools

## Platform
- Tool: Windmill (open-source internal tool builder)
- Scripts: TypeScript, Python, Go, Bash
- Flows: multi-step workflows with branching
- Apps: low-code UI builder with script backends

## Windmill Rules
- Scripts: typed functions with main() export
- Resources: $res:resource_type/name for connections
- Variables: $var:name for config values
- Secrets: $res:secrets/name for API keys
- Flows: chain scripts with approval, branching, loops
- Apps: drag-and-drop UI connected to scripts
- Schedule: cron-based scheduling per script

## Conventions
- Export async function main(param: type) in TypeScript
- Type all parameters for auto-generated forms
- Use resources for database/API connections
- Flows for multi-step operations
- Return value is the script output
- Use Windmill CLI (wmill) for local development
- Sync with git: wmill sync push/pull
```

## Workflow Example

You want to create an automated data pipeline that syncs data between two systems. Prompt Claude Code:

"Create a Windmill flow that fetches new orders from Shopify API, transforms them to match our internal format, upserts them into PostgreSQL, and sends a Slack notification with the sync summary. Use TypeScript scripts for each step."

Claude Code should create four Windmill TypeScript scripts: a Shopify fetch script using `$res:shopify/api_key`, a transform script with typed input/output, a PostgreSQL upsert script using `$res:postgresql/connection`, and a Slack notification script. Then define a flow that chains them with error handling.

## Common Pitfalls

1. **Not using resources for connections.** Claude hardcodes database URLs and API keys in script code. Windmill resources provide centralized connection management with encrypted storage — scripts reference resources, not raw credentials.

2. **Ignoring type annotations for UI.** Claude writes `function main(data: any)`. Windmill generates input forms from type annotations — `function main(email: string, count: number)` automatically creates a form with text input and number input fields.

3. **Building custom error handling.** Claude wraps everything in try-catch with custom logging. Windmill captures script output, errors, and execution time automatically. Let errors propagate — Windmill logs them and can trigger retry or notification flows.

## Related Guides

- [Claude Code for n8n Automation Workflow Guide](/claude-code-for-n8n-automation-workflow-guide/)
- [Claude Code for Activepieces Workflow Guide](/claude-code-for-activepieces-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code for Coder — Workflow Guide](/claude-code-for-coder-remote-dev-workflow-guide/)
- [Claude Code for GitHub Codespaces — Guide](/claude-code-for-codespaces-dev-environments-workflow-guide/)
- [Claude Code for Mise — Workflow Guide](/claude-code-for-mise-dev-tool-manager-workflow-guide/)
- [Claude Code for Encore Dev — Workflow Guide](/claude-code-for-encore-dev-workflow-guide/)


## Common Questions

### How do I get started with claude code for windmill dev?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Set Up Claude Code in Dev Containers](/claude-code-dev-containers-setup-2026/)
- [Claude Code for Dutch Dev Teams](/claude-code-for-dutch-developer-team-workflow-guide/)
- [Claude Code for Encore Dev](/claude-code-for-encore-dev-workflow-guide/)
