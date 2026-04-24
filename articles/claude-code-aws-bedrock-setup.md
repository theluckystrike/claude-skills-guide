---
layout: default
title: "Claude Code AWS Bedrock Setup Guide (2026)"
description: "Set up Claude Code with AWS Bedrock for enterprise-grade AI coding. Complete guide covering IAM, model access, environment config, and testing."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-aws-bedrock-setup/
categories: [guides]
tags: [claude-code, claude-skills, aws-bedrock, enterprise]
reviewed: true
score: 7
geo_optimized: true
---

Claude Code can connect to AWS Bedrock instead of the direct Anthropic API, giving you enterprise billing, VPC isolation, and compliance controls. This guide walks through the complete setup from IAM permissions to your first working session.

## The Problem

You want to use Claude Code at work but your organization requires all AI API calls to go through AWS Bedrock for compliance, billing, or network policy reasons. Claude Code defaults to the Anthropic API, and the Bedrock configuration is not obvious from the docs alone.

## Quick Solution

**Step 1:** Enable Claude model access in AWS Bedrock. Go to the [AWS Console > Bedrock > Model access](https://console.aws.amazon.com/bedrock/home#/modelaccess) and request access to Anthropic Claude models. This may take a few minutes to approve.

**Step 2:** Ensure your AWS CLI is configured with credentials that have Bedrock permissions:

```bash
aws sts get-caller-identity
```

If this fails, configure your credentials:

```bash
aws configure
```

**Step 3:** Verify your IAM role or user has the required Bedrock permissions. At minimum, you need:

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
      "Resource": "arn:aws:bedrock:*::foundation-model/anthropic.*"
    }
  ]
}
```

**Step 4:** Configure Claude Code to use Bedrock by setting these environment variables:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

Add these to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence.

**Step 5:** Launch Claude Code and verify it connects through Bedrock:

```bash
claude
```

Ask a simple question. If it responds, Bedrock is working. If you get a permissions error, double-check your IAM policy.

## How It Works

When `CLAUDE_CODE_USE_BEDROCK=1` is set, Claude Code switches from the Anthropic API endpoint to the AWS Bedrock `InvokeModelWithResponseStream` endpoint. It uses your local AWS credentials (from `~/.aws/credentials`, environment variables, or IAM instance roles) to sign requests using AWS Signature V4. The request is routed through your AWS account, which means all usage appears on your AWS bill, traffic stays within your VPC if configured, and you get CloudTrail logging for every API call. Claude Code handles the translation between its internal message format and the Bedrock request/response format automatically.

## Common Issues

**Model access not enabled.** If you get `AccessDeniedException`, you likely have not enabled Claude models in the Bedrock console. Model access must be explicitly requested per region.

**Wrong AWS region.** Bedrock model availability varies by region. Claude models are available in `us-east-1`, `us-west-2`, and `eu-west-1` among others. Set `AWS_REGION` to a region where you have model access enabled.

**SSO token expired.** If you use AWS SSO, your session token expires periodically. Refresh it:

```bash
aws sso login --profile your-profile
export AWS_PROFILE=your-profile
```

## Example CLAUDE.md Section

```markdown
# AWS Bedrock Configuration

## Environment
- Claude Code connects via AWS Bedrock (CLAUDE_CODE_USE_BEDROCK=1)
- Region: us-east-1
- Auth: AWS SSO profile "dev-team"
- All API calls logged in CloudTrail

## Before Starting
- Ensure AWS SSO session is active: `aws sts get-caller-identity`
- If expired: `aws sso login --profile dev-team`

## Constraints
- Bedrock has its own rate limits separate from Anthropic direct
- Max input tokens may differ from direct API — keep context lean
- No MCP server features that require direct Anthropic API access

## Cost Tracking
- Usage billed to AWS account, tagged under project cost center
- Monitor in AWS Cost Explorer under Bedrock service
```

## Best Practices

1. **Use IAM roles, not access keys, in production.** If running Claude Code on EC2 or ECS, attach an instance profile with Bedrock permissions instead of exporting access keys.

2. **Pin a specific AWS region.** Do not rely on the default region. Explicitly set `AWS_REGION` to avoid accidentally routing to a region where Claude models are not enabled.

3. **Enable CloudTrail for audit logging.** Every Bedrock invocation is logged in CloudTrail. Enable this for compliance and to track which team members are making API calls.

4. **Test with a minimal prompt first.** Before starting a complex coding session, send a simple test prompt through Claude Code to verify the Bedrock connection is working. This saves you from hitting auth errors mid-task.

5. **Set up billing alerts.** Create a CloudWatch billing alarm for the Bedrock service to avoid surprise costs, especially when multiple developers share the same account.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-aws-bedrock-setup)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Claude Code Failed to Authenticate API Error 401](/claude-code-failed-to-authenticate-api-error-401/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
