---
layout: default
title: "Claude Code AWS MCP Server Setup Guide"
description: "Claude Code AWS MCP Server Setup Guide — practical setup steps, configuration examples, and working code you can use in your projects today."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-aws-mcp-server/
categories: [guides]
tags: [claude-code, claude-skills, aws, mcp, devops]
reviewed: true
score: 6
geo_optimized: true
---

Setting up an AWS MCP server for Claude Code gives your AI assistant direct access to AWS services like S3, Lambda, and DynamoDB. This guide walks through the full configuration so Claude Code can query, deploy, and manage your AWS infrastructure from the terminal.

## The Problem

Developers working with AWS spend significant time switching between the AWS Console, CLI, and their editor. Claude Code alone cannot interact with AWS APIs. Without an MCP bridge, you have to manually copy outputs, describe infrastructure state, and paste error logs into your prompts.

## Quick Solution

1. Install the AWS MCP server package:

```bash
npm install -g @anthropic/mcp-server-aws
```

2. Configure your AWS credentials (ensure `~/.aws/credentials` is set):

```bash
aws configure
# Enter your Access Key ID, Secret, region (e.g., us-east-1)
```

3. Add the MCP server to your Claude Code settings file at `.claude/settings.json`:

```json
{
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-aws"],
      "env": {
        "AWS_PROFILE": "default",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

4. Restart Claude Code and verify the connection:

```bash
claude /mcp
# Should show "aws" server with available tools
```

5. Test with a simple command in your Claude Code session:

```text
List all S3 buckets in my account
```

## How It Works

The MCP (Model Context Protocol) server acts as a bridge between Claude Code and the AWS SDK. When Claude Code starts, it launches the MCP server as a subprocess. The server exposes AWS API operations as tools that Claude Code can invoke during conversations.

The server uses your local AWS credentials from `~/.aws/credentials` or environment variables. It supports IAM role assumption, SSO profiles, and temporary session tokens. Each AWS API call goes through the MCP server, which handles authentication, request signing, and response formatting.

Claude Code sees the available AWS tools (list-buckets, describe-instances, invoke-lambda, etc.) and selects the right one based on your natural language request. The response is parsed and presented in your terminal session.

## Common Issues

**Authentication failures**: If you see `ExpiredTokenError` or `InvalidClientTokenId`, refresh your credentials. For SSO users, run `aws sso login --profile your-profile` before starting Claude Code.

**Region mismatch**: Resources not found usually means the [Claude Code MCP configuration guide](/claude-code-mcp-configuration-guide/) or pass it per-request.

**Permission denied on specific services**: The IAM user or role attached to your credentials needs permissions for the services you want Claude Code to access. Start with `ReadOnlyAccess` policy for safety, then add write permissions for specific services as needed.

## Example CLAUDE.md Section

```markdown
# AWS Infrastructure Context

## MCP Servers
- AWS MCP server is configured in .claude/settings.json
- Default region: us-east-1
- Profile: development

## AWS Project Resources
- S3 bucket: my-app-assets-prod
- Lambda functions: my-app-api-*, my-app-worker-*
- DynamoDB tables: users, sessions, events
- CloudFront distribution: E1A2B3C4D5

## AWS Rules
- NEVER delete S3 buckets or DynamoDB tables without explicit confirmation
- ALWAYS use --dry-run flag first for EC2 operations
- Lambda deployments go through the CI pipeline, not direct updates
- Read-only access to production; write access to staging only
```

## Best Practices

- **Use read-only credentials by default.** Create a dedicated IAM user with `ReadOnlyAccess` for Claude Code and only escalate when deploying.
- **Scope MCP server per project.** Place the config in `.claude/settings.json` at the project root rather than globally, so each project connects to the right AWS account.
- **Set guardrails in CLAUDE.md.** Explicitly list which AWS operations are allowed and which require confirmation to prevent accidental destructive actions.
- **Use named profiles for multi-account setups.** If you work across staging and production, configure separate MCP entries with different `AWS_PROFILE` values.
- **Monitor costs.** AWS API calls from the MCP server count toward your API rate limits and can incur charges. Keep an eye on CloudTrail logs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-aws-mcp-server)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Claude Code MCP Server Disconnected Fix](/claude-code-mcp-server-disconnected/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code aws mcp server setup?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code AWS MCP Setup Guide](/claude-code-aws-mcp/)
- [Claude Code AWS Bedrock Setup Guide](/claude-code-aws-bedrock-setup/)
- [Claude Code Azure MCP Server Guide](/claude-code-azure-mcp/)
