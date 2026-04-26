---
layout: default
title: "Claude Code Deployment with Amazon (2026)"
description: "Deploy Claude Code applications using Amazon Bedrock. Covers IAM setup, model access, cost optimization, and production deployment patterns."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-deployment-patterns-and-best-practices-with-amazon-bedrock/
categories: [guides]
tags: [claude-code, claude-skills, aws, bedrock, deployment]
reviewed: true
score: 6
geo_optimized: true
---

Amazon Bedrock provides a managed way to run Claude models within your AWS infrastructure, avoiding data leaving your VPC. Deploying Claude Code applications through Bedrock requires specific IAM configuration, model access requests, and endpoint management that differ significantly from the standard Anthropic API workflow.

## The Problem

You want to use Claude Code within your AWS environment for compliance, data residency, or cost reasons, but the Bedrock integration has its own authentication model, pricing structure, and operational patterns. The standard Claude Code setup assumes the Anthropic API, and switching to Bedrock requires configuration changes across multiple layers.

## Quick Solution

1. Enable Claude model access in Bedrock:

```bash
# Request model access via AWS Console or CLI
aws bedrock list-foundation-models \
  --query "modelSummaries[?contains(modelId, 'claude')]" \
  --region us-east-1
```

2. Configure Claude Code to use Bedrock as the provider:

```bash
# Set environment variables for Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=production
```

3. Create the IAM policy for Bedrock access:

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
      "Resource": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-*"
    }
  ]
}
```

4. Verify the connection:

```bash
claude "Hello, confirm you are running through Bedrock
by checking the response headers."
```

5. Set up cost monitoring:

```bash
# Enable CloudWatch metrics for Bedrock usage
aws cloudwatch get-metric-statistics \
  --namespace AWS/Bedrock \
  --metric-name Invocations \
  --dimensions Name=ModelId,Value=anthropic.claude-sonnet-4-20250514 \
  --start-time 2026-04-16T00:00:00Z \
  --end-time 2026-04-17T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

## How It Works

Amazon Bedrock acts as a proxy layer between your application and the Claude model. Instead of sending requests to the Anthropic API, Claude Code sends them to the Bedrock endpoint within your AWS region. This keeps all data within your AWS account and VPC.

The authentication flow differs from standard API key authentication. Bedrock uses IAM roles and AWS credentials (access key + secret key or instance profiles) instead of Anthropic API keys. The `CLAUDE_CODE_USE_BEDROCK=1` environment variable tells Claude Code to use the Bedrock provider, and standard AWS credential resolution handles authentication.

Bedrock supports both synchronous and streaming invocations. Claude Code uses streaming by default for real-time responses. The `InvokeModelWithResponseStream` permission is required for this -- without it, you get a permissions error that can be confusing because the non-streaming invocation succeeds.

Pricing on Bedrock follows input/output token pricing specific to your AWS agreement, which may differ from standard Anthropic API pricing. Provisioned throughput is available for consistent workloads at reduced per-token cost.

## Common Issues

**Model access not enabled.** Bedrock requires explicit model access requests for Claude models. This is not automatic -- you must request access through the AWS Console under Bedrock > Model Access. It can take minutes to hours for approval.

**IAM permissions missing streaming action.** The most common error is allowing `bedrock:InvokeModel` but forgetting `bedrock:InvokeModelWithResponseStream`. Claude Code defaults to streaming, so you need both:

```json
{
  "Action": [
    "bedrock:InvokeModel",
    "bedrock:InvokeModelWithResponseStream"
  ]
}
```

**Region mismatch.** Claude models are not available in all AWS regions on Bedrock. Check model availability for your region. If your default region does not support Claude, set `AWS_REGION` explicitly to a supported region like `us-east-1` or `us-west-2`.

## Example CLAUDE.md Section

```markdown
# Amazon Bedrock Deployment

## Configuration
- Provider: Amazon Bedrock (CLAUDE_CODE_USE_BEDROCK=1)
- Region: us-east-1
- Model: anthropic.claude-sonnet-4-20250514
- Auth: IAM role via instance profile (no API keys)

## IAM Requirements
- bedrock:InvokeModel (sync calls)
- bedrock:InvokeModelWithResponseStream (streaming)
- Resource: arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-*

## Cost Management
- Monitor via CloudWatch: AWS/Bedrock namespace
- Set billing alarm at $100/day threshold
- Use Provisioned Throughput for sustained workloads > $500/mo

## Deployment Checklist
1. Verify model access: `aws bedrock list-foundation-models`
2. Test IAM permissions: `aws bedrock invoke-model --model-id anthropic.claude-sonnet-4-20250514`
3. Set env vars: CLAUDE_CODE_USE_BEDROCK=1, AWS_REGION
4. Verify streaming works: check for InvokeModelWithResponseStream permission
```

## Best Practices

- **Use IAM instance profiles** instead of access keys for production deployments. Instance profiles provide automatic credential rotation and are more secure than long-lived access keys.
- **Enable CloudWatch billing alarms** for the Bedrock namespace. Token-based pricing can accumulate quickly with long Claude Code sessions, and a $100/day alarm catches unexpected usage spikes.
- **Set up VPC endpoints for Bedrock** to keep all traffic within your private network. This is required for compliance in regulated industries and eliminates data transit over the public internet.
- **Test with on-demand pricing first** before committing to Provisioned Throughput. Understand your actual usage patterns for at least two weeks before purchasing reserved capacity.
- **Document the Bedrock setup in CLAUDE.md** so every team member has the correct environment variables, IAM requirements, and region configuration without searching through internal wikis.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-deployment-patterns-and-best-practices-with-amazon-bedrock)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Anthropic API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).
