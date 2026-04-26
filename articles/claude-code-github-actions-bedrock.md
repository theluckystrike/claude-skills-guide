---
layout: default
title: "Claude Code GitHub Actions with Bedrock (2026)"
description: "Set up Claude Code in GitHub Actions CI/CD pipelines using Amazon Bedrock for automated code reviews, testing, and deployment assistance."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-github-actions-bedrock/
categories: [guides]
tags: [claude-code, claude-skills, github-actions, bedrock, aws, ci-cd]
reviewed: true
score: 7
geo_optimized: true
---

Running Claude Code in GitHub Actions with Amazon Bedrock as the backend lets you automate code reviews, generate test cases, and get AI-assisted deployment checks in your CI/CD pipeline. This guide covers the complete setup from IAM roles to workflow YAML, using Bedrock instead of the Anthropic API for enterprise compliance.

## The Problem

Teams want Claude Code in their CI/CD pipeline for automated code review and testing, but using the Anthropic API directly raises compliance concerns. Amazon Bedrock provides Claude models through your existing AWS account, keeping all data within your AWS boundary. However, configuring GitHub Actions to authenticate with Bedrock through OIDC and run Claude Code headlessly requires careful setup.

## Quick Solution

1. Enable Claude models in Amazon Bedrock Console for your AWS region.

2. Create an IAM role for GitHub Actions with OIDC trust:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

3. Attach the Bedrock invoke policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"],
      "Resource": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-*"
    }
  ]
}
```

4. Create `.github/workflows/claude-review.yml`:

```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::YOUR_ACCOUNT:role/github-claude-role
          aws-region: us-east-1

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude Review
        env:
          CLAUDE_CODE_USE_BEDROCK: "1"
          AWS_REGION: us-east-1
        run: |
          claude --print "Review the changes in this PR for bugs, security issues, and code quality. Output a summary." > review.txt
          cat review.txt
```

5. Push the workflow and open a PR to trigger the review.

## How It Works

GitHub Actions OIDC federation lets your workflow assume an AWS IAM role without storing long-lived credentials. The `configure-aws-credentials` action exchanges the GitHub OIDC token for temporary AWS credentials, which Claude Code uses to call Bedrock.

Setting `CLAUDE_CODE_USE_BEDROCK=1` tells Claude Code to route all API calls through Amazon Bedrock instead of the Anthropic API. The `--print` flag runs Claude in non-interactive mode, outputting results to stdout, which is essential for CI/CD pipelines.

The workflow triggers on pull requests, giving Claude access to the diff. You can extend this to post review comments directly on the PR using the GitHub CLI or API.

## Common Issues

**"Access denied" on Bedrock InvokeModel.** Verify your IAM role has the `bedrock:InvokeModel` permission and the resource ARN matches the Claude model you are using. Check that the model is enabled in your Bedrock Console for the specified region.

**OIDC trust policy rejects the token.** The `sub` claim must match your repository path exactly. Use `repo:YOUR_ORG/YOUR_REPO:*` for all branches or `repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main` for specific branches. Check the GitHub Actions OIDC documentation for the exact claim format.

**Claude Code hangs in CI.** Ensure you use `--print` or pipe input to avoid interactive prompts. Claude Code in CI must run non-interactively. Set a timeout on the step to prevent runaway costs:

```yaml
      - name: Run Claude Review
        timeout-minutes: 5
```

## Example CLAUDE.md Section

```markdown
# CI/CD Claude Code Configuration

## Environment
- Runtime: GitHub Actions (ubuntu-latest)
- Auth: AWS Bedrock via OIDC federation
- Model: Claude Sonnet via Bedrock

## CI Rules
- Non-interactive mode only (--print flag)
- Maximum 5 minute timeout per invocation
- Review scope: changed files in PR only
- Never modify files during CI review

## Review Checklist
- Check for security vulnerabilities
- Validate error handling patterns
- Verify test coverage for new code
- Flag breaking API changes

## Bedrock Configuration
- Region: us-east-1
- Model ID: anthropic.claude-sonnet-4-20250514-v1:0
- Max tokens: 4096
```

## Best Practices

- **Use OIDC federation** instead of storing AWS access keys as GitHub secrets. OIDC provides temporary credentials that automatically rotate.
- **Set strict timeouts** on Claude Code CI steps to prevent runaway costs. A 5-minute timeout is reasonable for code reviews.
- **Scope IAM permissions tightly** to only `bedrock:InvokeModel` on the specific Claude model ARN. Never use wildcard resource permissions.
- **Cache the Claude Code installation** using `actions/cache` to speed up subsequent workflow runs.
- **Post review results as PR comments** using the GitHub API so developers see Claude's feedback inline with the diff.


## Related

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-github-actions-bedrock)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


