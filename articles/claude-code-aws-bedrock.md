---
sitemap: false
layout: default
title: "Claude Code with AWS Bedrock Guide (2026)"
description: "Run Claude Code through AWS Bedrock for enterprise deployment with VPC isolation, IAM access control, and no direct API keys."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-aws-bedrock/
categories: [guides]
tags: [claude-code, claude-skills, aws-bedrock, enterprise]
reviewed: true
score: 6
geo_optimized: true
---

Running Claude Code through AWS Bedrock lets you use Claude models within your AWS account, with IAM-based access control and no direct Anthropic API keys. This guide covers the environment configuration, IAM setup, and CLAUDE.md practices for Bedrock-backed Claude Code.

## The Problem

Enterprise teams cannot use direct Anthropic API keys due to security policies. Data must stay within AWS infrastructure, access must be controlled through IAM, and usage must be tracked through AWS billing. Claude Code defaults to the Anthropic API, and switching it to Bedrock requires specific environment variables and IAM permissions that are not obvious from the documentation.

## Quick Solution

**Step 1: Enable Claude models in Bedrock**

In the AWS Console, go to Amazon Bedrock > Model access. Request access to `anthropic.claude-sonnet-4-20250514` (or your preferred model). Access is typically granted within minutes.

**Step 2: Configure AWS credentials**

Ensure your AWS CLI is configured:

```bash
aws configure
```

Or use SSO:

```bash
aws sso login --profile your-profile
```

**Step 3: Set environment variables for Claude Code**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v2:0
```

Add these to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence:

```bash
echo 'export CLAUDE_CODE_USE_BEDROCK=1' >> ~/.zshrc
echo 'export AWS_REGION=us-east-1' >> ~/.zshrc
echo 'export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v2:0' >> ~/.zshrc
```

**Step 4: Verify the connection**

```bash
claude "Hello, which model am I talking to?"
```

Claude Code should respond through Bedrock. You can verify in AWS CloudWatch or the Bedrock console under Model invocations.

## How It Works

When `CLAUDE_CODE_USE_BEDROCK=1` is set, Claude Code routes all API calls through the AWS Bedrock `InvokeModel` endpoint instead of Anthropic's direct API. Authentication uses your AWS credentials (IAM user, role, or SSO session) rather than an Anthropic API key.

The `AWS_REGION` variable determines which Bedrock endpoint is used. Model availability varies by region -- `us-east-1` and `us-west-2` have the broadest model selection. The `ANTHROPIC_MODEL` variable specifies which Bedrock model ID to use. Bedrock model IDs differ from Anthropic API model IDs -- they include version suffixes and regional prefixes.

All data flows through your AWS account's VPC. Requests never touch Anthropic's infrastructure directly. This satisfies compliance requirements for data residency, audit logging, and access control. Usage is billed through your AWS account at Bedrock pricing rates.

## Common Issues

**"Access denied" when invoking models**
Your IAM user or role needs the `bedrock:InvokeModel` permission. Attach this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.*"
    }
  ]
}
```

**"Model not found" error**
Ensure you requested model access in the Bedrock console AND that you are using the correct model ID format. Bedrock IDs look like `us.anthropic.claude-sonnet-4-20250514-v2:0`, not `claude-sonnet-4-20250514`. Check available models with:

```bash
aws bedrock list-foundation-models --query "modelSummaries[?providerName=='Anthropic']" --region us-east-1
```

**Slower responses than direct API**
Bedrock adds a routing layer. Responses may be 200-500ms slower than the direct API. This is normal and expected. Use streaming (enabled by default in Claude Code) to mitigate perceived latency.

## Example CLAUDE.md Section

```markdown
# AWS Bedrock Configuration

## API
- Claude Code runs through AWS Bedrock (not direct Anthropic API)
- Model: Claude Sonnet via Bedrock in us-east-1
- Auth: AWS SSO profile "dev-account"
- Rate limits: Bedrock service quotas apply (check AWS console)

## AWS Context
- Account: 123456789012 (development)
- Region: us-east-1
- VPC: vpc-0a1b2c3d4e (private subnets only)
- Services used: Lambda, DynamoDB, S3, API Gateway, Bedrock

## Rules
- All infrastructure changes via CDK (TypeScript), never console
- Never hardcode AWS account IDs — use CDK context or SSM
- Log all Bedrock invocations to CloudWatch
- Respect Bedrock token limits: 200K input, 4K output per request

## Deployment
- CDK deploy: `npx cdk deploy --profile dev-account`
- Test: `npm test`
- Synth: `npx cdk synth`
```

## Best Practices

1. **Use IAM roles, not IAM users** -- For team setups, create an IAM role with Bedrock permissions and let developers assume it via SSO. This avoids long-lived credentials.

2. **Set per-user Bedrock quotas** -- AWS Bedrock supports service quotas. Set invocation limits per IAM principal to prevent runaway usage from Claude Code sessions.

3. **Choose the closest region** -- Bedrock latency depends on region proximity. Use the region closest to your development team for the best interactive experience.

4. **Monitor with CloudWatch** -- Enable Bedrock model invocation logging in CloudWatch. This gives you per-user usage tracking, error rates, and latency metrics.

5. **Pin the model version** -- Always use the full model ID with version suffix (e.g., `v2:0`). Bedrock may update default versions, which could change behavior unexpectedly.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-aws-bedrock)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Anthropic API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

