---
layout: default
title: "Claude Skills Serverless Function (2026)"
description: "Build Claude skills that deploy serverless functions. A practical workflow for creating, testing, and deploying cloud functions."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [workflows]
tags: [claude-code, claude-skills, serverless, aws-lambda, cloud-functions]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-serverless-function-development-workflow/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[Creating Claude skills that deploy serverless functions](/claude-skill-md-format-complete-specification-guide/) transforms your AI assistant into a powerful infrastructure automation tool. This workflow guides you through building skills that generate, test, and deploy cloud functions across AWS Lambda, Google Cloud Functions, and Azure Functions.

## Why Serverless Functions in Claude Skills

Claude skills excel at automating repetitive development tasks. When you add serverless function deployment to your skill toolkit, you can spin up API endpoints, background workers, and event-driven handlers without leaving your conversation. The skill handles boilerplate generation, configuration, and deployment while you focus on business logic.

Serverless development traditionally involves a lot of context switching: writing code, opening a terminal, configuring deployment files, managing IAM permissions, and wiring up triggers. Claude skills collapse that cycle. You describe what you want. "an HTTP endpoint that accepts a JSON body and writes to DynamoDB". and the skill generates function code, deployment config, and a test harness in one pass.

This workflow assumes you have Claude Code installed and basic familiarity with your cloud provider's CLI tools.

## Choosing the Right Runtime for Your Use Case

Before diving into code, the skill should help you choose the right runtime. Different runtimes have distinct cold start profiles, memory overhead, and ecosystem strengths:

| Runtime | Cold Start | Best For | Ecosystem Strength |
|---|---|---|---|
| Python 3.11 | ~200ms | Data processing, ML integrations | boto3, pandas, requests |
| Node.js 20 | ~100ms | Low-latency APIs, webhooks | npm, Express patterns |
| TypeScript (Node 20) | ~150ms | Type-safe APIs, large teams | Full TypeScript toolchain |
| Go | ~50ms | High-throughput, cost-sensitive | Minimal dependencies |
| Java 21 (SnapStart) | ~1s (with SnapStart: ~100ms) | Enterprise integrations | AWS SDK v2 |

A well-written skill prompts for this choice upfront rather than defaulting to a single runtime. The conversation should feel natural: "What will this function primarily do, and does latency matter for your use case?"

## Setting Up Your Skill Structure

A serverless function skill needs a clean directory structure. Create these folders in your skill repository:

```
serverless-function-skill/
 functions/
 hello-world/
 api-handler/
 templates/
 python/
 nodejs/
 typescript/
 deploy.yaml
```

The skill prompt should define the structure and guide Claude on how to interact with you during function creation. Here's an effective skill header:

```markdown
Serverless Function Builder

You help create and deploy serverless functions. When I ask for a function:
1. Ask which runtime (Python, Node.js, TypeScript)
2. Ask about the trigger type (HTTP, scheduled, event-based)
3. Generate the function code with proper handler structure
4. Create deployment configuration (serverless.yml, package.json)
5. Offer to deploy or provide deployment commands
```

The skill definition is short by design. Claude Code handles the intelligence; the skill file defines the boundaries and workflow steps. Overly detailed skill files often produce rigid, unhelpful responses. keep the instructions outcome-focused.

## Generating Function Code

When Claude generates a serverless function, the code should follow established patterns for your chosen runtime. Here's a Python example Claude can generate:

```python
import json
import os

def handler(event, context):
 """AWS Lambda handler for HTTP requests."""
 http_method = event.get('httpMethod', 'GET')

 response = {
 'statusCode': 200,
 'headers': {'Content-Type': 'application/json'},
 'body': json.dumps({
 'message': 'Function executed successfully',
 'method': http_method
 })
 }

 return response
```

For Node.js, the handler follows a different pattern:

```javascript
exports.handler = async (event) => {
 const response = {
 statusCode: 200,
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({
 message: 'Function executed successfully',
 timestamp: Date.now()
 })
 };

 return response;
};
```

For TypeScript, the skill should generate typed interfaces for the event and context objects, which prevents entire categories of bugs:

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

interface RequestBody {
 userId: string;
 action: string;
}

export const handler = async (
 event: APIGatewayProxyEvent,
 context: Context
): Promise<APIGatewayProxyResult> => {
 const body: RequestBody = JSON.parse(event.body || '{}');

 if (!body.userId) {
 return {
 statusCode: 400,
 body: JSON.stringify({ error: 'userId is required' })
 };
 }

 return {
 statusCode: 200,
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({ processed: true, userId: body.userId })
 };
};
```

## Creating Deployment Configuration

[A production-ready skill generates deployment files automatically](/claude-skills-for-automated-changelog-generation/). For the Serverless Framework, Claude should produce a `serverless.yml`:

```yaml
service: my-serverless-function

provider:
 name: aws
 runtime: python3.11
 stage: dev
 region: us-east-1

functions:
 helloWorld:
 handler: handler.handler
 events:
 - http:
 path: hello
 method: get
 cors: true
```

For Google Cloud Functions, generate a `cloudbuild.yaml` or use the Firebase CLI structure. Azure Functions require a `host.json` and `function.json` structure.

Beyond the minimal `serverless.yml`, production deployments need IAM configuration. The skill should generate least-privilege IAM statements rather than leaving users with overly permissive defaults:

```yaml
service: user-processor

provider:
 name: aws
 runtime: nodejs20.x
 stage: ${opt:stage, 'dev'}
 region: us-east-1
 iam:
 role:
 statements:
 - Effect: Allow
 Action:
 - dynamodb:GetItem
 - dynamodb:PutItem
 - dynamodb:UpdateItem
 Resource:
 - arn:aws:dynamodb:us-east-1:*:table/Users
 - Effect: Allow
 Action:
 - logs:CreateLogGroup
 - logs:CreateLogStream
 - logs:PutLogEvents
 Resource: arn:aws:logs:*:*:*

functions:
 processUser:
 handler: src/handler.process
 timeout: 30
 memorySize: 256
 environment:
 TABLE_NAME: Users
 events:
 - http:
 path: /users/{id}
 method: get
 cors: true
 request:
 parameters:
 paths:
 id: true
```

## Testing Locally Before Deployment

Your skill should guide users through local testing. The Serverless Framework provides offline testing capabilities. Add testing commands to your skill guidance:

```
To test locally:
1. Install Serverless Offline: npm install -g serverless-offline
2. Run: serverless offline
3. Test with curl:
 curl http://localhost:3000/dev/hello
```

For Python functions, create a simple test script:

```python
import json
from handler import handler

def test_handler():
 event = {'httpMethod': 'GET'}
 result = handler(event, None)

 assert result['statusCode'] == 200
 data = json.loads(result['body'])
 assert 'message' in data
 print("All tests passed")

if __name__ == '__main__':
 test_handler()
```

For Node.js and TypeScript projects, the skill should generate a Jest test suite alongside the function code:

```typescript
// handler.test.ts
import { handler } from './handler';
import { APIGatewayProxyEvent } from 'aws-lambda';

describe('processUser handler', () => {
 it('returns 400 when userId is missing', async () => {
 const event = {
 body: JSON.stringify({ action: 'fetch' }),
 pathParameters: null
 } as unknown as APIGatewayProxyEvent;

 const result = await handler(event, {} as any);
 expect(result.statusCode).toBe(400);
 });

 it('returns 200 with valid userId', async () => {
 const event = {
 body: JSON.stringify({ userId: 'u123', action: 'fetch' }),
 pathParameters: { id: 'u123' }
 } as unknown as APIGatewayProxyEvent;

 const result = await handler(event, {} as any);
 expect(result.statusCode).toBe(200);
 });
});
```

Run these with `npx jest --coverage` to verify function logic before touching AWS credentials.

## Deployment Workflow

When you're ready to deploy, the skill generates provider-specific commands. For AWS:

```bash
Set up credentials
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret

Deploy using Serverless
serverless deploy --stage production

Or deploy a single function
serverless deploy function --function helloWorld
```

For Google Cloud:

```bash
Deploy HTTP function
gcloud functions deploy my-function \
 --runtime python311 \
 --trigger-http \
 --allow-unauthenticated
```

For Azure:

```bash
az functionapp deployment source config-local-git \
 --resource-group my-group \
 --name my-function-app
```

For teams using CI/CD, the skill should offer to generate a GitHub Actions workflow that runs tests and deploys on merge to main:

```yaml
.github/workflows/deploy.yml
name: Deploy Serverless Function

on:
 push:
 branches: [main]

jobs:
 deploy:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Setup Node.js
 uses: actions/setup-node@v4
 with:
 node-version: '20'

 - name: Install dependencies
 run: npm ci

 - name: Run tests
 run: npm test

 - name: Deploy to AWS
 env:
 AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
 AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
 run: npx serverless deploy --stage production
```

This integrates naturally with the Claude Skills for GitHub Actions pattern. the serverless skill and the CI/CD skill complement each other.

## Environment Variables and Secrets

Production functions need environment configuration. Your skill should generate a secure way to handle secrets:

```yaml
serverless.yml
provider:
 environment:
 DATABASE_URL: ${env:DATABASE_URL}
 API_KEY: ${env:API_KEY}

Use a secrets manager reference for sensitive data
 - ${cf:security-stack.SecretArn}
```

Instruct users to never commit secrets to version control. Use `.env` files (added to `.gitignore`) for local development:

```
.env.example (commit this)
DATABASE_URL=
API_KEY=
```

```
.env.local (ignore this)
DATABASE_URL=postgres://localhost/mydb
API_KEY=sk_test_123
```

For production, the skill should generate AWS Secrets Manager retrieval code rather than relying on environment variables for truly sensitive credentials:

```python
import boto3
import json

def get_secret(secret_name: str) -> dict:
 """Retrieve secret from AWS Secrets Manager. Cache result in Lambda context."""
 client = boto3.client('secretsmanager')
 response = client.get_secret_value(SecretId=secret_name)
 return json.loads(response['SecretString'])

Called once per container lifecycle, not per invocation
_db_credentials = None

def handler(event, context):
 global _db_credentials
 if _db_credentials is None:
 _db_credentials = get_secret('prod/myapp/db')

 # Use _db_credentials['password'] etc.
 return {'statusCode': 200, 'body': 'ok'}
```

Caching the secret at module level means you pay the Secrets Manager API cost once per container warm-up, not on every invocation.

## Monitoring and Troubleshooting

After deployment, your skill should provide debugging guidance. Check logs with provider-specific commands:

```bash
AWS CloudWatch
serverless logs -f helloWorld --tail

GCP Cloud Logging
gcloud functions logs read my-function --limit=50

Azure
az functionapp logs show --resource-group my-group --name my-function-app
```

Add health check patterns to your functions:

```python
def handler(event, context):
 path = event.get('path', '')

 if path == '/health':
 return {
 'statusCode': 200,
 'body': json.dumps({'status': 'healthy'})
 }

 # Your main logic here
```

For structured logging that plays well with CloudWatch Insights and third-party tools like Datadog, the skill should generate JSON-formatted log output:

```python
import json
import logging
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def log_event(level: str, message: str, kwargs):
 entry = {
 'level': level,
 'message': message,
 'timestamp': time.time(),
 kwargs
 }
 print(json.dumps(entry))

def handler(event, context):
 request_id = context.aws_request_id
 log_event('INFO', 'Request received', request_id=request_id, path=event.get('path'))

 try:
 result = process(event)
 log_event('INFO', 'Request completed', request_id=request_id, status=200)
 return {'statusCode': 200, 'body': json.dumps(result)}
 except ValueError as e:
 log_event('ERROR', str(e), request_id=request_id, status=400)
 return {'statusCode': 400, 'body': json.dumps({'error': str(e)})}
```

This format makes CloudWatch Insights queries like `filter level = "ERROR"` work cleanly.

## Database Integration and Authentication

Serverless APIs need efficient database connections. Use managed services like DynamoDB to avoid connection pooling issues:

```javascript
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

async function fetchUsers() {
 const command = new GetCommand({
 TableName: 'Users',
 Key: { id: 'all' }
 });
 const response = await docClient.send(command);
 return response.Item?.users || [];
}
```

If your use case requires a relational database, use RDS Proxy to manage the connection pool. Without it, Lambda functions can exhaust Postgres connection limits during traffic spikes. The skill should generate the RDS Proxy connection string pattern:

```python
import os
import psycopg2

RDS Proxy endpoint. handles connection pooling
DB_HOST = os.environ['RDS_PROXY_ENDPOINT']
DB_NAME = os.environ['DB_NAME']
DB_USER = os.environ['DB_USER']

_conn = None

def get_connection():
 global _conn
 if _conn is None or _conn.closed:
 _conn = psycopg2.connect(
 host=DB_HOST,
 database=DB_NAME,
 user=DB_USER,
 password=get_secret('prod/db/password')['password'],
 sslmode='require'
 )
 return _conn
```

For authentication, add JWT middleware that validates tokens before reaching your handler logic:

```javascript
const jwt = require('jsonwebtoken');

function requireAuth(handler) {
 return async (event) => {
 const token = event.headers?.Authorization?.replace('Bearer ', '');
 if (!token) {
 return { statusCode: 401, body: JSON.stringify({ error: 'Unauthorized' }) };
 }

 try {
 const decoded = jwt.verify(token, process.env.JWT_SECRET);
 event.user = decoded;
 return handler(event);
 } catch (err) {
 return { statusCode: 403, body: JSON.stringify({ error: 'Invalid token' }) };
 }
 };
}

// Wrap your handler
exports.handler = requireAuth(async (event) => {
 return {
 statusCode: 200,
 body: JSON.stringify({ userId: event.user.sub })
 };
});
```

Pair this with the `tdd` skill to generate integration tests using `supertest` that verify your endpoints return correct status codes and payloads before deploying.

## Trigger Types Beyond HTTP

HTTP endpoints are the most common trigger, but the skill should handle the full range of serverless trigger patterns. A scheduled function for nightly data processing:

```yaml
serverless.yml. scheduled trigger
functions:
 nightly-report:
 handler: src/report.generate
 timeout: 900
 memorySize: 1024
 events:
 - schedule:
 rate: cron(0 2 * * ? *) # 2am UTC daily
 enabled: true
 input:
 reportType: daily
```

An SQS-triggered function for async job processing:

```python
def handler(event, context):
 """Process messages from SQS queue."""
 for record in event['Records']:
 body = json.loads(record['body'])
 process_job(body)

 # Returning without raising an exception marks messages as processed
 return {'batchItemFailures': []}
```

An S3-triggered function for processing file uploads:

```python
import boto3

s3 = boto3.client('s3')

def handler(event, context):
 for record in event['Records']:
 bucket = record['s3']['bucket']['name']
 key = record['s3']['object']['key']

 obj = s3.get_object(Bucket=bucket, Key=key)
 content = obj['Body'].read()

 process_upload(content, key)
```

The skill should ask about trigger type early in the conversation since it determines the handler signature, IAM permissions, and deployment configuration that get generated.

## Cost Optimization Patterns

Serverless can be extremely cost-efficient, but subtle mistakes create unexpectedly large bills. The skill should surface these patterns:

- Memory sizing: Lambda bills by GB-seconds. A 256MB function running 500ms costs the same as a 512MB function running 250ms. profile your functions and size appropriately.
- Reserved concurrency: Prevent a runaway function from consuming all account concurrency and impacting other services.
- Provisioned concurrency: For latency-critical endpoints, pre-warm a fixed number of containers to eliminate cold starts.

```yaml
functions:
 api:
 handler: src/handler.main
 reservedConcurrency: 100 # Never exceed 100 concurrent invocations
 provisionedConcurrency: 5 # Keep 5 containers warm at all times
```

## Conclusion

[Building serverless functions through Claude skills](/building-production-ai-agents-with-claude-skills-2026/) removes the friction from cloud function development. Your skill handles boilerplate, configuration, and deployment commands so you can focus on writing function logic. Start with a simple HTTP function, add environment configuration, then expand to scheduled jobs and event triggers.

The key is maintaining a clear structure: separate templates for each runtime, test locally before deploying, use environment variables for configuration, and follow least-privilege IAM patterns from the start. With this workflow, you can generate and deploy functions in minutes rather than hours. As you refine the skill, add patterns for your specific stack. RDS Proxy connection pooling, specific SQS batch error handling, or DynamoDB single-table design templates. so each conversation picks up exactly where your team's standards begin.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-serverless-function-development-workflow)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill MD Format Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/). structure serverless deployment skills with proper configuration
- [Building Production AI Agents with Claude Skills in 2026](/building-production-ai-agents-with-claude-skills-2026/). production architecture patterns for serverless AI applications
- [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-with-github-actions-ci-cd-pipeline/). automate serverless function deployment in CI/CD
- [Workflows Hub](/workflows/). explore Claude Code workflows for cloud and serverless development
- [Claude Code Skills for WordPress Development (2026)](/claude-code-skills-for-wordpress-development/)
- [Claude Skills For Restaurant Pos System — Developer Guide](/claude-skills-for-restaurant-pos-system-development/)
- [Claude Code Skills for iOS Swift Development](/claude-code-skills-for-ios-swift-development/)
- [Claude Skills for Unity Game Development Workflow](/claude-skills-for-unity-game-development-workflow/)
- [Claude Code Skills for Gaming Backend Development](/claude-code-skills-for-gaming-backend-development/)
- [Claude Skills For Android Kotlin — Developer Guide](/claude-skills-for-android-kotlin-development/)
- [Claude Skills for Salesforce Apex Development](/claude-skills-for-salesforce-apex-development/)
- [Claude Skills For Php Laravel — Complete Developer Guide](/claude-skills-for-php-laravel-development-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


