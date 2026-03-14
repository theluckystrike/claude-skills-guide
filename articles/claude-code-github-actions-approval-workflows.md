---
layout: default
title: "Claude Code GitHub Actions Approval Workflows"
description: "Learn how to implement manual approval gates in GitHub Actions workflows with Claude Code. Practical examples for production deployments, environment protection, and security-conscious automation."
date: 2026-03-14
categories: [workflows]
tags: [claude-code, claude-skills, github-actions, approval-workflows, cicd, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude Code GitHub Actions Approval Workflows

Manual approval gates are essential for production deployments, security-sensitive operations, and any workflow requiring human oversight before critical actions execute. GitHub Actions provides native environment protection through required reviewers, and Claude Code skills can enhance these workflows with intelligent decision-making, automated checks, and streamlined approval processes.

This guide covers practical implementations of approval workflows using GitHub Actions environments and Claude Code skills for developers who need controlled deployment pipelines.

## Understanding GitHub Actions Environment Protection

GitHub repository environments provide the foundation for approval workflows. Environments allow you to configure protection rules, including required reviewers who must approve workflow runs before they can proceed.

To enable environment protection, navigate to your repository settings and create an environment:

1. Go to **Settings** → **Environments**
2. Click **New environment** and name it (e.g., `production`, `staging`)
3. Enable **Required reviewers** and select team members or users
4. Optionally set a timeout for how long a workflow can wait for approval

Once configured, any workflow job that references this environment will pause and wait for approval before executing.

## Basic Approval Workflow Implementation

Here is a straightforward workflow that requires approval before deploying to a production environment:

```yaml
# .github/workflows/production-deploy.yml
name: Production Deployment

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build application
        run: npm ci && npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-output
          path: dist/
      
      - name: Deploy to production
        run: ./deploy.sh production
```

The `environment: production` line triggers GitHub's built-in approval mechanism. When the workflow reaches this job, it enters a waiting state until at least one required reviewer approves it.

## Enhancing Approvals with Claude Code Skills

Claude Code skills can augment approval workflows by performing automated pre-checks, gathering context, and providing recommendations to reviewers. The **supermemory** skill is particularly useful for retrieving relevant deployment history and context before approval decisions.

Create a skill that prepares approval context:

```markdown
# skill: approval-context
## Description
Gathers deployment context and recent changes for approval review

## Tools
- read_file
- bash

## Action
{{
  metadata:
    purpose: "pre-approval-context"
}}

1. Read the most recent commit messages from the default branch
2. Check for any failed deployments in the last 7 days
3. List any open security issues tagged for this release
4. Output a summary including:
   - Number of commits since last deployment
   - Recent deployment success/failure status
   - Security considerations
}}
```

Invoke this skill before approval to give reviewers actionable information:

```bash
claude -p "/approval-context project=myapp environment=production"
```

## Multi-Environment Approval Chains

Complex projects often require sequential approvals across multiple environments. You can model this with a staged deployment approach where each environment requires approval:

```yaml
# .github/workflows/staged-deployment.yml
name: Staged Deployment Pipeline

on:
  push:
    branches:
      - release/*

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.semver }}
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm test
      - id: version
        run: echo "semver=$VERSION" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build-and-test
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: ./deploy.sh staging ${{ needs.build-and-test.outputs.version }}

  integration-tests:
    needs: deploy-staging
    runs-on: ubuntu-latest
    steps:
      - name: Run integration tests
        run: npm run test:integration

  deploy-production:
    needs: integration-tests
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: ./deploy.sh production ${{ needs.build-and-test.outputs.version }}
```

This workflow creates a clear chain: build → staging approval → tests → production approval. Each environment has its own protection rules, allowing different reviewers for each stage.

## Using the tdd Skill for Approval Validation

The **tdd** skill can generate automated validation tests that run as part of the approval process. Create tests specifically for deployment validation:

```yaml
# .github/workflows/deployment-approval-checks.yml
name: Deployment Approval Checks

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production

jobs:
  pre-approval-checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate deployment validation tests
        run: |
          claude -p "/tdd generate deployment validation for ${{ github.event.inputs.environment }}"
      
      - name: Run validation tests
        run: npm run test:deployment

  wait-for-approval:
    needs: pre-approval-checks
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Approved for deployment
        run: echo "Deployment approved for ${{ github.event.inputs.environment }}"
```

The workflow runs automated checks before requiring human approval, ensuring that deployments meet specific criteria regardless of approval status.

## Slack Integration for Approval Notifications

Real-world teams need timely approval notifications. The **slack-gif-creator** skill can generate context-aware notification visuals, but for actual integrations, use GitHub's official Slack actions:

```yaml
# .github/workflows/approval-notification.yml
name: Approval Notification

on:
  workflow_run:
    types: [requested]
    workflows:
      - Production Deployment
      - Staged Deployment Pipeline

jobs:
  notify:
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.status == 'waiting' }}
    steps:
      - name: Send approval request to Slack
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          fields: repo,message,workflow
          custom_payload: |
            {
              "attachments": [{
                "color": "warning",
                "title": "Deployment Approval Required",
                "text": "Workflow '${{ github.event.workflow_run.name }}' needs approval for ${{ github.event.workflow_run.repository.name }}",
                "fields": [
                  { "title": "Environment", "value": "production", "short": true },
                  { "title": "Requested By", "value": "${{ github.actor }}", "short": true },
                  { "title": "Link", "value": "${{ github.event.workflow_run.html_url }}", "short": false }
                ]
              }]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

This configuration notifies your Slack channel when approval is needed, with a direct link to the workflow run.

## Best Practices for Approval Workflows

Implement these practices to make approval workflows effective:

**Keep environments specific.** Create separate environments for development, staging, and production rather than reusing a single environment. Each environment should have appropriate reviewers.

**Timeout stale approvals.** GitHub automatically cancels workflow runs after a default period, but you can configure shorter timeouts for sensitive environments:

```yaml
deploy-production:
  environment:
    name: production
    url: https://production.example.com
    required_reviewers: 2
    timeout: 30
```

**Use the principle of least privilege.** Grant approval permissions to the smallest possible group of people. The **pdf** skill can generate audit reports documenting who approved which deployments for compliance purposes.

**Document approval criteria.** Create a skill that presents reviewers with a checklist of things to verify before approving:

```markdown
# skill: pre-approval-checklist
## Description
Displays deployment approval checklist for reviewers

## Action
Present the following checklist to the user:

## Pre-Approval Checklist

- [ ] Code review completed and approved
- [ ] Security scan passed (no critical vulnerabilities)
- [ ] Database migrations tested in staging
- [ ] Rollback plan documented
- [ ] Communication sent to stakeholders
- [ ] On-call engineer notified

Confirm each item before proceeding with approval.
```

## Conclusion

GitHub Actions environment protection combined with Claude Code skills creates powerful approval workflows for production systems. Start with basic environment protection, then enhance workflows with the **tdd** skill for automated validation, **supermemory** for context gathering, and Slack notifications for timely approvals.

The key is finding the right balance between security controls and developer velocity. Too many approval gates create bottlenecks; too few expose you to risk. Review your workflows regularly and adjust based on team size, project criticality, and deployment frequency.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
