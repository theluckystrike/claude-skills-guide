---
layout: default
title: "Claude Code AWS MCP Setup Guide (2026)"
description: "Claude Code AWS MCP Setup Guide — practical setup steps, configuration examples, and working code you can use in your projects today."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-aws-mcp/
categories: [guides]
tags: [claude-code, claude-skills, aws, mcp]
reviewed: true
score: 6
geo_optimized: true
---

Adding AWS MCP to Claude Code gives it direct access to your AWS resources -- S3 buckets, DynamoDB tables, Lambda functions, and CloudWatch logs -- without leaving your editor. This guide covers the setup for connecting Claude Code to AWS services through MCP for infrastructure-aware development.

## The Problem

Claude Code generates AWS SDK code and CDK constructs without knowing your actual infrastructure. It guesses S3 bucket names, assumes DynamoDB table schemas, and writes Lambda handlers for runtimes you do not use. You spend time correcting resource names, ARNs, and configurations that Claude Code could have read directly from your AWS account.

## Quick Solution

**Step 1: Install the AWS MCP server**

```bash
npm install -g @anthropic-ai/mcp-server-aws
```

**Step 2: Ensure AWS credentials are configured**

```bash
aws sts get-caller-identity
```

If this returns your account info, your credentials are set. If not:

```bash
aws configure
```

Or for SSO:

```bash
aws sso login --profile your-profile
```

**Step 3: Configure MCP in your project**

Create `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-aws"],
      "env": {
        "AWS_PROFILE": "your-profile",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

**Step 4: Restart Claude Code and test**

```bash
claude
```

Test with:

```text
> List my S3 buckets in us-east-1
```

Claude Code will use the AWS MCP tools to query your account directly.

## How It Works

The AWS MCP server wraps the AWS SDK and exposes it as MCP tools. When Claude Code needs to reference an AWS resource, it calls tools like `s3_list_buckets`, `dynamodb_describe_table`, `lambda_list_functions`, or `cloudwatch_get_log_events`. These tools use your local AWS credentials (from `~/.aws/credentials`, environment variables, or SSO session) to make API calls.

This means Claude Code can read your actual DynamoDB table schemas before generating queries, check S3 bucket configurations before writing upload code, and read CloudWatch logs to diagnose deployment issues. All API calls go through your local machine using your credentials -- no data passes through Anthropic.

The MCP server respects the IAM permissions of whatever credentials you provide. If your IAM user has read-only access, Claude Code can only read resources. If you give it admin access, it could potentially modify resources -- which is why scoping permissions is critical.

## Common Issues

**"Credentials not found" on startup**
The MCP server needs AWS credentials available to the process. If you use named profiles, ensure `AWS_PROFILE` is set in the MCP config env. If you use SSO, run `aws sso login` before starting Claude Code -- SSO tokens expire and must be refreshed.

**MCP server shows tools but queries fail**
Your IAM permissions may be too restrictive. The AWS MCP server needs at minimum these read-only permissions for the services you want to query:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "dynamodb:DescribeTable",
        "dynamodb:Scan",
        "lambda:ListFunctions",
        "lambda:GetFunction",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

**Slow responses for resource-heavy accounts**
Accounts with hundreds of S3 buckets or Lambda functions cause slow list operations. Tell Claude Code to query specific resources by name rather than listing everything. Add resource names to CLAUDE.md.

## Example CLAUDE.md Section

```markdown
# AWS Project Configuration

## AWS Account
- Account: 123456789012 (development)
- Region: us-east-1 (primary), us-west-2 (DR)
- MCP configured in .claude/mcp.json
- Profile: dev-account (SSO, read-only role)

## Key Resources
- S3: myapp-uploads-dev, myapp-assets-dev
- DynamoDB: Users, Orders, Sessions (on-demand capacity)
- Lambda: api-handler, image-processor, email-sender
- API Gateway: myapp-api (REST, v1)
- CloudWatch: /aws/lambda/api-handler log group

## Infrastructure
- IaC: AWS CDK v2 (TypeScript)
- CDK app: /infra/cdk/
- Stacks: NetworkStack, DatabaseStack, ApiStack, FrontendStack

## Rules
- NEVER create or delete AWS resources through MCP
- Use MCP for reading resource configs and logs only
- All changes go through CDK: `npx cdk deploy`
- Always check CloudWatch logs after deployment
- Use dev account only — never connect MCP to production

## Commands
- Deploy: `npx cdk deploy --all --profile dev-account`
- Diff: `npx cdk diff --profile dev-account`
- Logs: `aws logs tail /aws/lambda/api-handler --follow`
```

## Best Practices

1. **Use a read-only IAM role for MCP** -- Create a dedicated IAM role with only read permissions. This prevents Claude Code from accidentally modifying infrastructure through MCP tool calls.

2. **Never connect MCP to production AWS** -- Always use a development or staging account. Production access through MCP creates too much risk for accidental data reads or resource modifications.

3. **List key resources in CLAUDE.md** -- Even with MCP, Claude Code works faster when it knows resource names upfront. Listing your S3 buckets, DynamoDB tables, and Lambda functions saves list-all API calls.

4. **Refresh SSO tokens before sessions** -- AWS SSO tokens expire (typically after 8 hours). Run `aws sso login` before starting a Claude Code session to avoid mid-session authentication failures.

5. **Scope the region** -- Set `AWS_REGION` in the MCP config to prevent Claude Code from querying resources across all regions, which is slow and may return unexpected results from other environments.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-aws-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
