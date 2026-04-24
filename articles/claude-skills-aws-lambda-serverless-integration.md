---
layout: default
title: "Claude Skills + AWS Lambda (2026)"
description: "Integrate Claude Code skills with AWS Lambda for serverless AI workflows. Patterns for document processing, test generation, and event-driven pipelines."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, aws, lambda, serverless, pdf, tdd]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-skills-aws-lambda-serverless-integration/
render_with_liquid: false
geo_optimized: true
last_tested: "2026-04-22"
---

{% raw %}
## Claude Code Skills + AWS Lambda: Serverless Integration

Claude Code skills run locally in your terminal. AWS Lambda runs your code in the cloud. Connecting them means invoking Claude Code. including skill-augmented sessions. from within a Lambda function, then routing the output into your broader AWS infrastructure.

This guide covers practical patterns for this integration: document processing, test generation triggers, and event-driven workflows.

## How the Architecture Works

Claude Code can run in print mode (`claude -p "..."`) which accepts a prompt, runs the session non-interactively, and returns output to stdout. A Lambda function can shell out to `claude -p` the same way any process can call a subprocess.

The setup requires bundling the Claude Code binary in your Lambda container image. Lambda's managed runtimes do not include Claude Code by default, so a custom Docker image is the practical path.

## Building the Container Image

Create a `Dockerfile` that installs Claude Code alongside your runtime:

```dockerfile
FROM public.ecr.aws/lambda/python:3.12

Install Node.js (Claude Code requires it)
RUN dnf install -y nodejs npm

Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

Copy your function code
COPY handler.py ${LAMBDA_TASK_ROOT}/

CMD ["handler.handler"]
```

Build and push to ECR:

```bash
aws ecr get-login-password --region us-east-1 | \
 docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

docker build -t claude-skills-lambda .
docker tag claude-skills-lambda:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/claude-skills-lambda:latest
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/claude-skills-lambda:latest
```

## Writing the Lambda Handler

The handler invokes Claude Code in print mode and returns the output:

```python
import json
import subprocess
import os

def handler(event, context):
 prompt = event.get("prompt", "")
 if not prompt:
 return {"statusCode": 400, "body": json.dumps({"error": "prompt is required"})}

 # ANTHROPIC_API_KEY must be set via Lambda environment variables
 # Store it in AWS Secrets Manager and inject at runtime
 env = os.environ.copy()

 try:
 result = subprocess.run(
 ["claude", "-p", prompt],
 capture_output=True,
 text=True,
 timeout=240,
 env=env,
 )

 if result.returncode != 0:
 return {
 "statusCode": 500,
 "body": json.dumps({"error": result.stderr}),
 }

 return {
 "statusCode": 200,
 "body": json.dumps({"output": result.stdout.strip()}),
 }
 except subprocess.TimeoutExpired:
 return {"statusCode": 504, "body": json.dumps({"error": "timeout"})}
 except Exception as exc:
 return {"statusCode": 500, "body": json.dumps({"error": str(exc)})}
```

## Practical Pattern 1: Document Processing with /pdf

Trigger this Lambda from an S3 `ObjectCreated` event. When a PDF lands in your uploads bucket, the function processes it using the [pdf skill](/best-claude-skills-for-data-analysis/):

```python
def handler(event, context):
 # Extract S3 object key from the event
 record = event["Records"][0]
 bucket = record["s3"]["bucket"]["name"]
 key = record["s3"]["object"]["key"]

 # Download the file to /tmp (Lambda's writable directory)
 import boto3
 s3 = boto3.client("s3")
 local_path = f"/tmp/{key.split('/')[-1]}"
 s3.download_file(bucket, key, local_path)

 prompt = f"/pdf Extract all tables and section headings from {local_path}"

 result = subprocess.run(
 ["claude", "-p", prompt],
 capture_output=True,
 text=True,
 timeout=240,
 env=os.environ.copy(),
 )

 output = result.stdout.strip()

 # Store extracted content in DynamoDB
 dynamo = boto3.resource("dynamodb")
 table = dynamo.Table(os.environ["OUTPUT_TABLE"])
 table.put_item(Item={"documentKey": key, "extractedContent": output})

 return {"statusCode": 200, "body": json.dumps({"key": key, "chars": len(output)})}
```

SAM template for the trigger:

```yaml
Resources:
 DocumentProcessor:
 Type: AWS::Serverless::Function
 Properties:
 PackageType: Image
 ImageUri: YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/claude-skills-lambda:latest
 Timeout: 300
 MemorySize: 1024
 Environment:
 Variables:
 OUTPUT_TABLE: !Ref ExtractedContentTable
 ANTHROPIC_API_KEY: !Sub "{{resolve:secretsmanager:claude-api-key}}"
 Events:
 S3Upload:
 Type: S3
 Properties:
 Bucket: !Ref UploadBucket
 Events: s3:ObjectCreated:*
 Filter:
 S3Key:
 Rules:
 - Name: suffix
 Value: ".pdf"
```

## Practical Pattern 2: Test Generation in CI/CD

Trigger the [tdd skill](/best-claude-skills-for-developers-2026/) when a developer opens a pull request. A GitHub Actions webhook posts to API Gateway, which invokes Lambda:

```python
def handler(event, context):
 body = json.loads(event.get("body", "{}"))
 repo_url = body.get("repository", {}).get("clone_url", "")
 pr_branch = body.get("pull_request", {}).get("head", {}).get("ref", "")

 if not repo_url or not pr_branch:
 return {"statusCode": 400, "body": "missing repository or branch"}

 # Clone the PR branch into /tmp
 clone_dir = "/tmp/repo"
 subprocess.run(["git", "clone", "--branch", pr_branch, repo_url, clone_dir], check=True)

 prompt = f"/tdd Review the Python files in {clone_dir}/src/ and list missing test coverage for public functions"

 result = subprocess.run(
 ["claude", "-p", prompt],
 capture_output=True,
 text=True,
 timeout=240,
 env=os.environ.copy(),
 )

 # Post the analysis as a PR comment via GitHub API
 import urllib.request
 pr_number = body.get("pull_request", {}).get("number")
 repo_full_name = body.get("repository", {}).get("full_name")
 gh_token = os.environ["GITHUB_TOKEN"]

 comment_url = f"https://api.github.com/repos/{repo_full_name}/issues/{pr_number}/comments"
 comment_body = json.dumps({"body": f"TDD Analysis\n\n{result.stdout.strip()}"}).encode()

 req = urllib.request.Request(
 comment_url,
 data=comment_body,
 headers={"Authorization": f"Bearer {gh_token}", "Content-Type": "application/json"},
 method="POST",
 )
 urllib.request.urlopen(req)

 return {"statusCode": 200, "body": "comment posted"}
```

## Managing State Across Invocations

Lambda functions are ephemeral. each invocation starts fresh. The [supermemory skill](/claude-skills-token-optimization-reduce-api-costs/) stores context in `~/.claude/`, which does not persist between Lambda invocations by default.

To persist memory, sync the skill's storage directory to S3 before and after each run:

```python
import boto3
import subprocess
import os

MEMORY_BUCKET = os.environ["MEMORY_BUCKET"]
MEMORY_KEY = "supermemory-state.tar.gz"
MEMORY_DIR = "/tmp/.claude"

def restore_memory():
 s3 = boto3.client("s3")
 try:
 s3.download_file(MEMORY_BUCKET, MEMORY_KEY, "/tmp/memory.tar.gz")
 subprocess.run(["tar", "-xzf", "/tmp/memory.tar.gz", "-C", "/tmp"], check=True)
 except s3.exceptions.NoSuchKey:
 os.makedirs(MEMORY_DIR, exist_ok=True)

def save_memory():
 subprocess.run(
 ["tar", "-czf", "/tmp/memory.tar.gz", "-C", "/tmp", ".claude"], check=True
 )
 boto3.client("s3").upload_file("/tmp/memory.tar.gz", MEMORY_BUCKET, MEMORY_KEY)

def handler(event, context):
 restore_memory()
 # ... run Claude Code ...
 save_memory()
```

## Deployment Best Practices

API key security: Store your `ANTHROPIC_API_KEY` in AWS Secrets Manager. Reference it in your SAM/CloudFormation template with `{{resolve:secretsmanager:...}}`. Never hard-code it in environment variables directly in source control.

Timeout configuration: The `/pdf` skill on a large document can take 2-3 minutes. Set Lambda timeout to 300 seconds (5 minutes) for document-heavy workloads. For quick prompts, 60 seconds is sufficient.

Cold start reduction: Claude Code's Node.js runtime adds cold start latency. Use provisioned concurrency for latency-sensitive API Gateway integrations. For batch or async workflows triggered by SQS or S3, cold starts are acceptable.

Error handling: Always check `result.returncode` before using stdout. Log `result.stderr` to CloudWatch for debugging. Wrap the subprocess call in a try/except for `TimeoutExpired` and `OSError`.

Cost management: Lambda charges per invocation and duration. Long-running Claude Code sessions (processing large PDFs, generating extensive tests) will cost more. Use SQS to queue requests and process them at a controlled rate rather than allowing unbounded concurrency.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-skills-aws-lambda-serverless-integration)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Full developer skill stack
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How Claude decides when to load skills
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Keep API costs down as you scale

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Step-by-Step: Integrating Claude Skills with AWS Lambda

1. Create the Lambda function: ask Claude Code to scaffold a Python or Node.js Lambda handler that accepts a Claude skill invocation payload and returns a structured response.
2. Package the Anthropic SDK: bundle the `anthropic` Python package (or `@anthropic-ai/sdk` for Node.js) with your Lambda deployment package, or use a Lambda Layer to share it across functions.
3. Store credentials securely: put the Claude API key in AWS Secrets Manager or Parameter Store. Retrieve it at function startup using the AWS SDK. never hard-code it in the function code.
4. Configure the function URL or API Gateway: expose the Lambda function as an HTTPS endpoint. A Lambda Function URL is the simplest option for development; API Gateway gives you rate limiting and authentication for production.
5. Connect the skill: register the Lambda endpoint URL as the skill's action endpoint. Claude will POST the user's request to this URL and render the response.
6. Add error handling and logging: wrap the handler in a try/catch that returns structured error responses. Use CloudWatch Logs with structured JSON logging so failures are easy to diagnose.

## Lambda Handler for Claude Skill

```python
import json
import boto3
import anthropic

secrets_client = boto3.client('secretsmanager')

def get_claude_key():
 secret = secrets_client.get_secret_value(SecretId='claude-api-key')
 return json.loads(secret['SecretString'])['CLAUDE_API_KEY']

def handler(event, context):
 try:
 body = json.loads(event.get('body', '{}'))
 user_message = body.get('message', '')

 client = anthropic.Anthropic(api_key=get_claude_key())
 message = client.messages.create(
 model='claude-opus-4-6',
 max_tokens=1024,
 messages=[{'role': 'user', 'content': user_message}]
 )

 return {
 'statusCode': 200,
 'headers': {'Content-Type': 'application/json'},
 'body': json.dumps({'response': message.content[0].text})
 }
 except Exception as e:
 return {
 'statusCode': 500,
 'body': json.dumps({'error': str(e)})
 }
```

## AWS Lambda + Claude Skill Architecture Options

| Approach | Latency | Cost | Complexity | Scalability |
|---|---|---|---|---|
| Lambda + Function URL | Low | Pay-per-use | Low | High (auto) |
| Lambda + API Gateway | Low | Pay-per-use + API GW | Medium | High |
| Lambda + ALB | Low | Pay-per-use + ALB | Medium | High |
| ECS Fargate (persistent) | Very low (no cold start) | Higher (always-on) | High | Manual |
| EC2 (always-on) | Very low | Higher | High | Manual |

Lambda + Function URL is the right starting point for most skills. zero infrastructure overhead, automatic scaling, and costs nothing during periods of no usage.

## Advanced: Caching Skill Responses with ElastiCache

For skills that call expensive external APIs (database queries, web searches), add Redis caching via ElastiCache to reduce latency and cost:

```python
import redis, hashlib, json

redis_client = redis.Redis(host=ELASTICACHE_ENDPOINT, port=6379, decode_responses=True)

def cached_claude_call(message, ttl=300):
 cache_key = 'skill:' + hashlib.md5(message.encode()).hexdigest()
 cached = redis_client.get(cache_key)
 if cached:
 return json.loads(cached)

 result = call_claude(message)
 redis_client.setex(cache_key, ttl, json.dumps(result))
 return result
```

## Troubleshooting

Cold start latency making the skill feel slow: Pre-warm the Lambda function by invoking it on a scheduled EventBridge rule every 5 minutes. This keeps the execution environment warm and eliminates the 1-3 second cold start for Python functions with large dependencies.

Lambda timing out on long Claude responses: The default Lambda timeout is 3 seconds. Increase it to 30-60 seconds for Claude skill calls. Set `max_tokens` in the Anthropic API call appropriately. `max_tokens=4096` can take 10-20 seconds for complex responses.

Secrets Manager adding latency: Cache the API key in a module-level variable after the first retrieval. AWS Lambda reuses execution environments between invocations. the cached key persists across warm invocations without repeated Secrets Manager calls.
{% endraw %}


