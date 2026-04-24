---
layout: default
title: "Claude Code for SST — Workflow Guide (2026)"
description: "Claude Code for SST — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-sst-serverless-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, sst, workflow]
---

## The Setup

You are building a serverless application with SST (Serverless Stack) v3, the framework that uses Pulumi's Infrastructure-as-Code engine under the hood and provides high-level components for AWS resources. SST v3 manages your entire AWS infrastructure — functions, databases, queues, storage — through TypeScript configuration. Claude Code can write SST infrastructure, but it defaults to raw AWS CDK, Serverless Framework YAML, or outdated SST v2 patterns.

## What Claude Code Gets Wrong By Default

1. **Writes Serverless Framework YAML.** Claude generates `serverless.yml` with plugin configurations. SST v3 is TypeScript-only — infrastructure is defined in `sst.config.ts` and `infra/` directory.

2. **Uses SST v2 constructs.** Claude references `new Api()` and `new Function()` from SST v2. SST v3 uses a completely different API: `new sst.aws.Function()`, `new sst.aws.ApiGatewayV2()` with different constructor arguments.

3. **Creates CloudFormation templates.** Claude writes raw CloudFormation JSON/YAML. SST v3 abstracts this through its component system — you never write CloudFormation directly.

4. **Ignores SST's linking system.** Claude hardcodes resource ARNs and connection strings. SST v3 uses `link` to automatically pass resource references between components with proper IAM permissions.

## The CLAUDE.md Configuration

```
# SST v3 Serverless Project

## Infrastructure
- Framework: SST v3 (uses Pulumi engine)
- Config: sst.config.ts at project root
- Infra: infra/ directory for resource definitions
- Deploy: npx sst deploy --stage prod

## SST v3 Rules
- Infrastructure in TypeScript: sst.config.ts + infra/*.ts
- Components: new sst.aws.Function(), new sst.aws.Bucket(), etc.
- Link resources: link: [myBucket, myTable] on functions
- Access linked: Resource.MyBucket.name in function code
- Dev mode: npx sst dev (live Lambda, not emulated)
- Stages: dev, staging, prod (each gets separate resources)
- Secrets: npx sst secret set MY_SECRET value

## Conventions
- infra/api.ts for API routes and functions
- infra/storage.ts for S3, DynamoDB resources
- infra/auth.ts for authentication resources
- Function code in packages/functions/src/
- Use Resource.* for linked resource access, not env vars
- One sst.config.ts entry point importing from infra/
- Never hardcode AWS ARNs — use SST linking
```

## Workflow Example

You want to create an API with a DynamoDB table and S3 bucket. Prompt Claude Code:

"Set up SST v3 infrastructure with a REST API that has endpoints for file upload and user management. Create a DynamoDB table for users and an S3 bucket for file storage. Link both resources to the API functions."

Claude Code should create resources in `infra/storage.ts` using `new sst.aws.Dynamo()` and `new sst.aws.Bucket()`, define API routes in `infra/api.ts` with `new sst.aws.ApiGatewayV2()`, link resources with the `link` property, and write handler functions that access resources via `Resource.UserTable.name` and `Resource.FileBucket.name`.

## Common Pitfalls

1. **Using `process.env` instead of `Resource`**. Claude reads linked resources from environment variables. SST v3's `Resource` object provides type-safe access to linked resources — `Resource.MyBucket.name` is typed and validated at build time, unlike `process.env.BUCKET_NAME`.

2. **Running `sst deploy` without stage.** Claude deploys without specifying `--stage`. This uses the default stage which can conflict with other developers. Always specify: `sst deploy --stage mike-dev` for personal environments.

3. **Live dev confusion with hot reload.** Claude expects to restart the server after function changes. SST's `sst dev` provides live Lambda — your function code runs locally but is invoked by real AWS events. Changes take effect immediately, no restart needed.

## Related Guides

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)

## Related Articles

- [Claude Code Netlify Serverless Functions Workflow](/claude-code-netlify-serverless-functions-workflow/)
- [Claude Code for Modal Serverless ML — Guide](/claude-code-for-modal-serverless-ml-workflow-guide/)
- [How to Use Xata Database Branching (2026)](/claude-code-xata-serverless-database-branching-guide/)
