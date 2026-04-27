---
sitemap: false
layout: default
title: "Deploy to AWS with Claude Code (2026)"
description: "Use Claude Code to deploy applications to AWS. Covers Lambda, ECS, S3, and CloudFormation with CLAUDE.md templates and automation hooks."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-deploy-to-aws/
categories: [guides]
tags: [claude-code, claude-skills, aws, deployment, devops]
reviewed: true
score: 6
geo_optimized: true
---

Claude Code can orchestrate AWS deployments by generating CloudFormation templates, configuring Lambda functions, managing ECS services, and running deployment scripts. With proper CLAUDE.md configuration, it becomes a deployment copilot that handles infrastructure-as-code generation and deployment automation.

## The Problem

Deploying to AWS involves juggling multiple services, IAM policies, environment configurations, and deployment scripts. Each service has its own CLI syntax and gotchas. You want Claude Code to handle the boilerplate and automate the deployment pipeline, but without proper context it generates incomplete or insecure configurations.

## Quick Solution

1. Configure your CLAUDE.md with AWS deployment context:

```markdown
# AWS Deployment
- Region: us-east-1
- Account: 123456789012
- Profile: production
- Deploy command: `aws cloudformation deploy --template-file template.yml --stack-name my-app --capabilities CAPABILITY_IAM`
```

2. Generate a Lambda deployment with Claude:

```bash
claude "Create a Lambda function deployment for the Express
API in src/api/. Use Node.js 20 runtime, 256MB memory,
30s timeout. Include API Gateway integration with CORS.
Generate the CloudFormation template."
```

3. Deploy an ECS service:

```bash
claude "Create an ECS Fargate task definition and service
for the Docker image in ./Dockerfile. Use 512 CPU, 1024
memory. Include ALB health check on /health endpoint.
Generate the CloudFormation template and deploy script."
```

4. Automate with a pre-deploy hook:

```json
{
  "hooks": {
    "preDeployCommand": "pnpm test && pnpm build && aws sts get-caller-identity"
  }
}
```

5. Verify the deployment:

```bash
claude "Check the CloudFormation stack status for my-app.
If the deployment failed, read the stack events and
identify the root cause."
```

## How It Works

Claude Code interacts with AWS through the AWS CLI and SDK. When you provide deployment context in CLAUDE.md, Claude generates infrastructure-as-code templates (CloudFormation or CDK) that match your project structure and then executes deployment commands.

The deployment workflow follows a pattern: Claude reads your application code, determines the appropriate AWS service (Lambda for serverless, ECS for containers, S3 for static sites), generates the infrastructure template, and creates a deployment script. The CLAUDE.md file provides critical context like AWS region, account ID, and naming conventions.

For Lambda deployments, Claude generates the handler wrapper, packages dependencies, creates the CloudFormation template with API Gateway integration, and runs `aws cloudformation deploy`. For ECS, it generates the Dockerfile (if needed), task definition, service configuration, and load balancer setup.

Hooks extend this workflow by running tests and builds automatically before any deployment command executes, preventing broken code from reaching production.

## Common Issues

**IAM permissions errors during deployment.** Claude generates CloudFormation templates that require `CAPABILITY_IAM` or `CAPABILITY_NAMED_IAM`. Always include these in your deploy command. Add to CLAUDE.md:

```markdown
# Deployment Rules
- Always use --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
- Never create IAM policies with Action: "*"
- Use least-privilege permissions for all roles
```

**Lambda package size exceeds 50MB limit.** Claude may include development dependencies in the deployment package. Specify in CLAUDE.md that production builds should use `pnpm install --prod` and exclude test files:

```bash
# Build for Lambda
pnpm install --prod
zip -r function.zip . -x "*.test.*" "tests/*" "node_modules/.cache/*"
```

**CloudFormation stack stuck in ROLLBACK_COMPLETE.** This state prevents updates. Claude needs to delete the stack first and redeploy. Add to CLAUDE.md: "If stack is in ROLLBACK_COMPLETE state, delete it with `aws cloudformation delete-stack` before redeploying."

## Example CLAUDE.md Section

```markdown
# AWS Deployment Configuration

## Environment
- Region: us-east-1
- Profile: production (use --profile production)
- Stack naming: {project}-{service}-{env}

## Lambda Conventions
- Runtime: nodejs20.x
- Memory: 256MB default, 512MB for API handlers
- Timeout: 30s API, 300s background jobs
- Layers: shared dependencies in arn:aws:lambda:us-east-1:123:layer:deps

## ECS Conventions
- Cluster: production-cluster
- Task CPU: 512, Memory: 1024
- Health check path: /health
- Min/Max tasks: 2/10 with target tracking scaling

## Safety Rules
- NEVER deploy without running tests first
- NEVER use IAM Action: "*" in policies
- ALWAYS include --capabilities CAPABILITY_IAM
- ALWAYS verify stack status after deployment
```

## Best Practices

- **Store AWS deployment context in CLAUDE.md** including region, account, naming conventions, and safety rules. This prevents Claude from generating configurations with wrong regions or insecure IAM policies.
- **Use CloudFormation over raw CLI commands** for reproducible deployments. Claude excels at generating declarative templates that can be version-controlled and reviewed.
- **Add a pre-deploy hook** that runs tests and builds before any deployment command. This creates an automatic gate that prevents broken code from reaching AWS.
- **Include rollback instructions** in CLAUDE.md for common deployment failures. CloudFormation rollback states are confusing and Claude handles them better with explicit guidance.
- **Use environment-specific stack names** to prevent accidentally overwriting production with staging configurations.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-deploy-to-aws)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)
- [Claude Code Docker Build Failed Fix](/claude-code-docker-build-failed-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Railway Deploy — Workflow Guide](/claude-code-for-railway-deploy-workflow-guide/)
