---
layout: default
title: "Deploy AWS Lambda Functions with Claude (2026)"
description: "Use Claude Code to build, test, and deploy AWS Lambda functions. SAM templates, cold start optimization, layers, and CI/CD integration."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-aws-lambda-deployment-guide/
reviewed: true
categories: [guides, claude-code]
tags: [aws, lambda, serverless, deployment, sam]
render_with_liquid: false
geo_optimized: true
---
{% raw %}
# Deploy AWS Lambda Functions with Claude Code

## The Problem

Deploying AWS Lambda functions involves writing the function code, configuring IAM roles, setting up API Gateway triggers, managing environment variables, handling cold starts, packaging dependencies, and coordinating deployments across multiple functions. The AWS console is tedious, and Infrastructure as Code templates have a steep learning curve.

## Quick Start

Ask Claude Code to scaffold a Lambda function with SAM:

```
Create an AWS Lambda function that:
- Handles POST /api/webhooks/stripe for Stripe webhook processing
- Validates the Stripe signature
- Processes payment events (payment_intent.succeeded, charge.refunded)
- Stores events in DynamoDB
- Uses SAM for deployment
- Includes proper IAM permissions (least privilege)
- Has a local testing setup
```

## What's Happening

AWS Lambda runs your code without provisioning servers. You upload a function, configure triggers (API Gateway, SQS, S3 events, etc.), and AWS handles scaling, availability, and infrastructure. The Serverless Application Model (SAM) is an extension of CloudFormation that simplifies Lambda deployment.

Claude Code handles the full Lambda development workflow: writing the function, creating the SAM template, configuring permissions, setting up local testing, and preparing the CI/CD pipeline.

## Step-by-Step Guide

### Step 1: Set up the project structure

Ask Claude Code to create the project:

```
Set up a SAM project for a webhook processing service with:
- TypeScript Lambda functions
- DynamoDB table for event storage
- API Gateway with custom domain
- Local development with SAM CLI
```

```
my-webhook-service/
├── src/
│ ├── handlers/
│ │ ├── stripeWebhook.ts
│ │ └── processEvent.ts
│ ├── lib/
│ │ ├── stripe.ts
│ │ └── dynamodb.ts
│ └── types/
│ └── events.ts
├── tests/
│ ├── unit/
│ │ └── stripeWebhook.test.ts
│ └── events/
│ └── stripe-webhook.json
├── template.yaml
├── samconfig.toml
├── tsconfig.json
├── package.json
└── esbuild.config.ts
```

### Step 2: Write the Lambda function

```typescript
// src/handlers/stripeWebhook.ts
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import Stripe from 'stripe';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
 apiVersion: '2024-12-18.acacia',
});

const dynamodb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE_NAME = process.env.EVENTS_TABLE!;

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
 // Validate Stripe signature
 const signature = event.headers['stripe-signature'];
 if (!signature || !event.body) {
 return { statusCode: 400, body: JSON.stringify({ error: 'Missing signature or body' }) };
 }

 let stripeEvent: Stripe.Event;
 try {
 stripeEvent = stripe.webhooks.constructEvent(
 event.body,
 signature,
 process.env.STRIPE_WEBHOOK_SECRET!,
 );
 } catch (err) {
 console.error('Signature verification failed:', err);
 return { statusCode: 400, body: JSON.stringify({ error: 'Invalid signature' }) };
 }

 // Store event for idempotency and audit
 try {
 await dynamodb.send(new PutCommand({
 TableName: TABLE_NAME,
 Item: {
 pk: stripeEvent.id,
 sk: stripeEvent.type,
 data: stripeEvent.data.object,
 createdAt: new Date().toISOString(),
 processed: false,
 },
 ConditionExpression: 'attribute_not_exists(pk)', // Idempotency
 }));
 } catch (err: unknown) {
 if ((err as { name: string }).name === 'ConditionalCheckFailedException') {
 // Already processed, return success
 return { statusCode: 200, body: JSON.stringify({ received: true, duplicate: true }) };
 }
 throw err;
 }

 // Process based on event type
 switch (stripeEvent.type) {
 case 'payment_intent.succeeded':
 await handlePaymentSuccess(stripeEvent.data.object as Stripe.PaymentIntent);
 break;
 case 'charge.refunded':
 await handleRefund(stripeEvent.data.object as Stripe.Charge);
 break;
 default:
 console.log(`Unhandled event type: ${stripeEvent.type}`);
 }

 return { statusCode: 200, body: JSON.stringify({ received: true }) };
}

async function handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent): Promise<void> {
 console.log(`Payment succeeded: ${paymentIntent.id}, amount: ${paymentIntent.amount}`);
 // Business logic here
}

async function handleRefund(charge: Stripe.Charge): Promise<void> {
 console.log(`Charge refunded: ${charge.id}, amount refunded: ${charge.amount_refunded}`);
 // Business logic here
}
```

### Step 3: Create the SAM template

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Stripe webhook processing service

Globals:
 Function:
 Timeout: 30
 MemorySize: 256
 Runtime: nodejs20.x
 Architectures:
 - arm64 # Graviton2 - cheaper and faster
 Environment:
 Variables:
 EVENTS_TABLE: !Ref EventsTable

Parameters:
 Stage:
 Type: String
 Default: dev
 AllowedValues: [dev, staging, prod]

Resources:
 StripeWebhookFunction:
 Type: AWS::Serverless::Function
 Properties:
 Handler: dist/handlers/stripeWebhook.handler
 Description: Processes Stripe webhook events
 Environment:
 Variables:
 STRIPE_SECRET_KEY: !Sub '{{resolve:secretsmanager:${Stage}/stripe:SecretString:secret_key}}'
 STRIPE_WEBHOOK_SECRET: !Sub '{{resolve:secretsmanager:${Stage}/stripe:SecretString:webhook_secret}}'
 Policies:
 - DynamoDBCrudPolicy:
 TableName: !Ref EventsTable
 Events:
 StripeWebhook:
 Type: Api
 Properties:
 Path: /api/webhooks/stripe
 Method: POST
 Metadata:
 BuildMethod: esbuild
 BuildProperties:
 Minify: true
 Target: es2022
 EntryPoints:
 - src/handlers/stripeWebhook.ts

 EventsTable:
 Type: AWS::DynamoDB::Table
 Properties:
 TableName: !Sub '${Stage}-webhook-events'
 BillingMode: PAY_PER_REQUEST
 AttributeDefinitions:
 - AttributeName: pk
 AttributeType: S
 - AttributeName: sk
 AttributeType: S
 KeySchema:
 - AttributeName: pk
 KeyType: HASH
 - AttributeName: sk
 KeyType: RANGE
 TimeToLiveSpecification:
 AttributeName: ttl
 Enabled: true

Outputs:
 WebhookUrl:
 Description: Stripe webhook URL
 Value: !Sub 'https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/api/webhooks/stripe'
```

### Step 4: Optimize for cold starts

Ask Claude Code to reduce cold start latency:

```
Optimize my Lambda function for minimal cold start time:
- Minimize bundle size with tree-shaking
- Move initialization outside the handler
- Use the AWS SDK v3 (modular imports)
- Consider Lambda SnapStart or provisioned concurrency
```

```typescript
// Move SDK initialization outside the handler (reused across invocations)
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

// These are created once during cold start and reused
const client = new DynamoDBClient({});
const dynamodb = DynamoDBDocumentClient.from(client);

// Import only what you need from the SDK (tree-shaking)
// Good: import { PutCommand } from '@aws-sdk/lib-dynamodb'
// Bad: import AWS from 'aws-sdk' (imports everything)
```

### Step 5: Test locally

```bash
# Start local API Gateway + Lambda
sam local start-api

# Invoke with a test event
sam local invoke StripeWebhookFunction -e tests/events/stripe-webhook.json

# Run unit tests
npm test
```

Create test events:

```json
{
 "httpMethod": "POST",
 "path": "/api/webhooks/stripe",
 "headers": {
 "stripe-signature": "t=1234567890,v1=test-signature"
 },
 "body": "{\"id\":\"evt_test\",\"type\":\"payment_intent.succeeded\",\"data\":{\"object\":{\"id\":\"pi_test\",\"amount\":2000}}}"
}
```

### Step 6: Set up deployment pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy Lambda
on:
 push:
 branches: [main]

jobs:
 deploy:
 runs-on: ubuntu-latest
 permissions:
 id-token: write
 contents: read
 steps:
 - uses: actions/checkout@v4

 - uses: actions/setup-node@v4
 with:
 node-version: 20
 cache: npm

 - run: npm ci

 - run: npm test

 - uses: aws-actions/configure-aws-credentials@v4
 with:
 role-to-assume: arn:aws:iam::123456789012:role/github-deploy
 aws-region: us-east-1

 - uses: aws-actions/setup-sam@v2

 - run: sam build

 - run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset --parameter-overrides Stage=prod
```

### Step 7: Add monitoring and alerting

Ask Claude Code to add observability:

```
Add CloudWatch alarms for:
- Function errors > 1% of invocations
- P99 latency > 5 seconds
- Throttling events
- DynamoDB capacity consumption
Include structured logging with correlation IDs.
```

```yaml
# Add to template.yaml
 ErrorAlarm:
 Type: AWS::CloudWatch::Alarm
 Properties:
 AlarmName: !Sub '${Stage}-webhook-errors'
 MetricName: Errors
 Namespace: AWS/Lambda
 Dimensions:
 - Name: FunctionName
 Value: !Ref StripeWebhookFunction
 Statistic: Sum
 Period: 300
 EvaluationPeriods: 1
 Threshold: 5
 ComparisonOperator: GreaterThanThreshold
 AlarmActions:
 - !Ref AlertTopic
```

## Prevention

Add Lambda development rules to your CLAUDE.md:

```markdown
## AWS Lambda Rules
- Use ARM64 (Graviton) for all functions
- Keep handlers thin — delegate to service modules
- Initialize SDK clients outside the handler
- Use AWS SDK v3 with modular imports
- Store secrets in Secrets Manager, never in environment variables
- Set function timeout to 2x expected execution time
- Use DynamoDB condition expressions for idempotency
- Every function must have error alarms
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-aws-lambda-deployment-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code AWS ECS Fargate Setup Deployment Tutorial](/claude-code-aws-ecs-fargate-setup-deployment-tutorial/)
- [Claude Code AWS S3 Multipart Upload Workflow Guide](/claude-code-aws-s3-multipart-upload-workflow-guide/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
{% endraw %}



## Related Articles

- [Claude Code for S3 Object Lambda Workflow](/claude-code-for-s3-object-lambda-workflow/)
- [Claude Code for Lambda SnapStart Workflow](/claude-code-for-lambda-snapstart-workflow/)
- [Claude Code for Lambda Layers Workflow](/claude-code-for-lambda-layers-workflow/)
