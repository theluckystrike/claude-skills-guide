---
layout: default
title: "Fly.io MCP Server Deployment Workflow"
description: "A practical guide to deploying Model Context Protocol servers on Fly.io. Learn the deployment workflow, configuration, and automation with Claude skills."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, mcp, fly-io, deployment, docker, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /fly-io-mcp-server-deployment-workflow-guide/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[Deploying a Model Context Protocol (MCP) server to Fly.io gives you](/building-your-first-mcp-tool-integration-guide-2026/) a globally distributed, low-latency endpoint that Claude Code can connect to for enhanced tool-calling capabilities. This guide covers the complete deployment workflow, from containerization to automated deployments using Claude skills.

## Why Deploy MCP Servers on Fly.io

Fly.io runs containers close to users, making it ideal for MCP servers that need fast response times. The platform handles TLS certificates automatically, manages edge networking, and supports persistent volumes when your server needs state. Many developers [combine their MCP deployment with the frontend-design skill](/best-claude-code-skills-to-install-first-2026/) for generating UI components, or the pdf skill for document processing, all without requiring local infrastructure.

The workflow described here works with any MCP server implementation, whether you built it in Python, Node.js, or Go.

There are several reasons to prefer Fly.io over alternatives like Railway, Render, or self-managed servers for MCP deployments. First, Fly.io's anycast routing places your server in the region closest to whoever is initiating requests, important when Claude Code itself is running on different machines or by different team members across the globe. Second, Fly.io's free tier is genuinely useful: a small MCP server with modest traffic runs comfortably within the free allowance. Third, the `flyctl` CLI is well-designed and scriptable, which matters when you want to automate deployments from Claude skills or CI pipelines.

Compared to running an MCP server on a VPS, Fly.io removes the operational overhead of managing certificates, configuring nginx or caddy, handling restarts on failure, and shipping logs to an external provider. Those things come out of the box.

## Preparing Your MCP Server for Containerization

Before deploying to Fly.io, ensure your MCP server listens on the correct port and handles shutdown signals gracefully. Fly.io exposes applications through port 8080 by default. Graceful shutdown matters because Fly.io sends `SIGTERM` before terminating a machine, giving your server a window to finish in-flight requests. If your server ignores `SIGTERM` and gets killed mid-request, Claude Code will see a connection error that breaks whatever workflow it was executing.

Create a `Dockerfile` in your project root:

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --production

COPY . .
EXPOSE 8080

CMD ["node", "server.js"]
```

For Python-based MCP servers, use:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python", "server.py"]
```

The `--no-cache-dir` flag in the Python Dockerfile keeps image size smaller by preventing pip from storing wheel caches. For Alpine-based Python images, you may also need to install build dependencies for packages with C extensions:

```dockerfile
FROM python:3.11-alpine

WORKDIR /app
RUN apk add --no-cache gcc musl-dev libffi-dev
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python", "server.py"]
```

Ensure your server reads the port from an environment variable:

```javascript
const port = process.env.PORT || 8080;
server.listen(port, () => {
 console.log(`MCP server running on port ${port}`);
});
```

Reading from `process.env.PORT` rather than hardcoding 8080 gives you flexibility when running the same container in different environments. Fly.io sets `PORT` automatically, but other platforms use different values.

Add a graceful shutdown handler to avoid broken connections during deployments:

```javascript
process.on('SIGTERM', () => {
 console.log('SIGTERM received, closing server...');
 server.close(() => {
 console.log('Server closed cleanly');
 process.exit(0);
 });
 // Force exit after 10 seconds if close() hangs
 setTimeout(() => process.exit(1), 10000);
});
```

## Configuring Fly.io Deployment

Create a `fly.toml` file in your project root. This configuration tells Fly.io how to deploy your container:

```toml
app = "my-mcp-server"

[build]
 dockerfile = "Dockerfile"

[[services]]
 http_checks = []
 internal_port = 8080
 processes = ["app"]

 [[services.ports]]
 handlers = ["http"]
 port = 8080

[env]
 MCP_SERVER_NAME = "my-custom-server"
```

The `[env]` section lets you pass environment variables to your container. Use this for API keys, database connection strings, or configuration flags. However, never put secrets in `fly.toml` since this file is committed to version control. For sensitive values, use Fly.io secrets instead:

```bash
fly secrets set OPENAI_API_KEY=sk-...
fly secrets set DATABASE_URL=postgres://...
```

Secrets set this way are encrypted at rest and injected as environment variables at runtime, exactly the same as `[env]` entries but without exposing values in your repository.

For production deployments, add health check configuration to `fly.toml` so Fly.io knows when your server is actually ready to serve traffic:

```toml
[[services.http_checks]]
 interval = "15s"
 timeout = "2s"
 grace_period = "10s"
 method = "GET"
 path = "/health"
 protocol = "http"
 tls_skip_verify = false
```

Your server needs to expose a `/health` endpoint that returns a 200 status. Without this, Fly.io has no way to distinguish a server that is starting up from one that has crashed.

## Deploying Your MCP Server

With your configuration ready, deploy using the Fly.io CLI:

```bash
fly launch
fly deploy
```

The first command creates your application on Fly.io's infrastructure. The second command builds your Docker image and deploys it. After deployment completes, Fly.io provides a URL like `https://my-mcp-server.fly.dev`.

Test your server by sending a request:

```bash
curl https://my-mcp-server.fly.dev/health
```

The `fly launch` command is interactive by default, it asks about regions, pricing plans, and whether to deploy Postgres. If you want a non-interactive launch (useful in CI or scripted workflows), pass flags:

```bash
fly launch --name my-mcp-server --region iad --no-deploy --copy-config
```

The `--no-deploy` flag creates the app configuration without immediately deploying, giving you time to set secrets before the first deployment.

After deploying, verify the server is running as expected:

```bash
fly status # Show running machines and their health
fly logs --tail # Stream live logs
fly ssh console # Open a shell in a running machine
```

If the deployment fails, `fly logs --recent` is usually the fastest way to understand why.

## Connecting Claude Code to Your Deployed MCP Server

Once your server runs on Fly.io, configure Claude Code to use it. Create or update your Claude settings:

```json
{
 "mcpServers": {
 "my-custom-server": {
 "url": "https://my-mcp-server.fly.dev/mcp"
 }
 }
}
```

Restart your Claude Code session. The server's tools become available alongside Claude's built-in capabilities.

The MCP endpoint path (`/mcp` in this example) must match what your server actually exposes. Check your server implementation to confirm the correct path. Some MCP frameworks use `/` as the root endpoint, others use `/mcp`, and some use `/api/mcp`. Mismatches here are a common source of connection failures.

You can also configure authentication between Claude Code and your MCP server using bearer tokens:

```json
{
 "mcpServers": {
 "my-custom-server": {
 "url": "https://my-mcp-server.fly.dev/mcp",
 "headers": {
 "Authorization": "Bearer your-token-here"
 }
 }
 }
}
```

On the server side, validate the token before processing requests:

```javascript
app.use('/mcp', (req, res, next) => {
 const token = req.headers.authorization?.replace('Bearer ', '');
 if (token !== process.env.MCP_SECRET_TOKEN) {
 return res.status(401).json({ error: 'Unauthorized' });
 }
 next();
});
```

This is particularly important if your MCP server has access to sensitive resources or can perform write operations.

## Automating Deployments with Claude Skills

You can streamline deployments using a Claude skill that encapsulates your workflow. Create a skill file that guides Claude through the deployment process:

```markdown
Deploy Skill

When the user wants to deploy an MCP server to Fly.io:

1. Check if fly.toml exists
2. If not, run `fly launch` with appropriate settings
3. Run `fly deploy` to deploy
4. Verify the deployment with a health check
5. Report the final URL to the user
```

Save this as `~/.claude/skills/deploy.md` and activate it with `/deploy` in your Claude session.

For more complex workflows, consider chaining the deploy skill with other Claude skills. The tdd skill helps you write tests for your MCP server before deployment, while the supermemory skill can track deployment history and configuration across sessions.

A more complete deploy skill might also handle rollback scenarios:

```markdown
Deploy Skill

When the user wants to deploy an MCP server to Fly.io:

1. Check if fly.toml exists in the current directory
2. Run `fly status` to check current deployment state
3. Run `fly deploy` and capture output
4. Wait for deployment to complete, then run `curl <app-url>/health`
5. If health check fails:
 - Run `fly releases` to list recent releases
 - Run `fly deploy --image <previous-image>` to roll back
 - Report the rollback to the user
6. If health check passes, report the live URL
```

## Setting Up Continuous Deployment

Automate deployments whenever you push to your repository. Create a GitHub Actions workflow:

```yaml
name: Deploy to Fly.io

on:
 push:
 branches: [main]

jobs:
 deploy:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Set up Docker Buildx
 uses: docker/setup-buildx-action@v3

 - name: Deploy to Fly.io
 uses: superfly/flyctl-actions@master
 with:
 args: "deploy"
 env:
 FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

Generate an API token from your Fly.io dashboard and add it as a repository secret named `FLY_API_TOKEN`.

Add a smoke test step after deployment to catch regressions early:

```yaml
 - name: Smoke test
 run: |
 sleep 10 # Wait for deployment to stabilize
 STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://my-mcp-server.fly.dev/health)
 if [ "$STATUS" != "200" ]; then
 echo "Health check failed with status $STATUS"
 exit 1
 fi
 echo "Health check passed"
```

If the smoke test fails, the workflow marks the deployment as failed, and you can configure branch protection rules to block merges when CI fails. This gives you a safety net against deploying broken MCP servers that would silently fail for Claude Code users.

## Managing Multiple Environments

For staging and production environments, create separate `fly.toml` configurations:

```bash
fly config save -a my-mcp-server-staging
fly config save -a my-mcp-server-prod
```

Deploy to a specific environment:

```bash
fly deploy -c fly.staging.toml
fly deploy -c fly.prod.toml
```

This approach lets you test changes on staging before promoting them to production. Your GitHub Actions workflow can deploy to staging on every push and to production only on tagged releases:

```yaml
on:
 push:
 branches: [main] # Deploy to staging
 push:
 tags: ['v*'] # Deploy to production
```

For staging environments where you want to test against production-like data without risking real data, use Fly.io's volume cloning feature to copy a production volume snapshot to staging. This is more reliable than maintaining separate seed scripts.

## Monitoring Your MCP Server

Fly.io provides built-in metrics through its dashboard. For custom monitoring, add structured logging to your server:

```javascript
const server = http.createServer(async (req, res) => {
 const start = Date.now();

 // Handle MCP requests
 const result = await handleMcpRequest(req);

 console.log({
 method: req.method,
 path: req.url,
 status: result.status,
 duration: Date.now() - start
 });

 res.json(result);
});
```

View logs with:

```bash
fly logs
```

JSON-formatted logs are easier to filter and analyze than plain text. If you later add a log aggregation service (Datadog, Logtail, Papertrail), structured JSON makes it trivial to build dashboards on request latency, error rates by tool name, and usage patterns.

For tracking which MCP tools are being called most frequently, log the tool name in every request:

```javascript
console.log(JSON.stringify({
 event: 'tool_call',
 tool: req.body.method,
 duration_ms: Date.now() - start,
 success: !result.error,
 timestamp: new Date().toISOString()
}));
```

This gives you the data to identify which tools are slow or error-prone, so you can prioritize optimization work.

## Common Deployment Issues

If your server fails to start, check the logs:

```bash
fly logs --recent
```

Common problems include missing environment variables, incorrect port configuration, or startup timeouts. Increase the timeout in `fly.toml` if your server needs more time to initialize:

```toml
[deploy]
 timeout = 60
```

A common gotcha: the `timeout` in `[deploy]` refers to the deployment timeout, how long Fly.io waits for your new instance to pass health checks before considering the deployment failed. If your server takes 20+ seconds to start (for example, because it loads a large ML model into memory), raise this value.

For connection issues between Claude Code and your server, verify the endpoint responds correctly:

```bash
curl https://your-server.fly.dev/mcp
```

If you see TLS errors, check that your `fly.toml` is not using the `http` handler on port 443, Fly.io handles TLS termination automatically and your container should only speak HTTP internally.

Another common issue is forgetting to set required secrets before the first deployment. If your server crashes immediately with an error about a missing environment variable, set the secret and redeploy:

```bash
fly secrets set REQUIRED_VAR=value
fly deploy
```

Port binding failures happen when the server tries to bind to a privileged port (below 1024) inside the container. Always use port 8080 or higher inside the container; Fly.io maps external ports to internal ones transparently.

## Next Steps

With your MCP server deployed on Fly.io, explore extending its capabilities. The pdf skill can process documents through your server, while the canvas-design skill might generate visual assets. Each skill you add creates new possibilities for what Claude Code can accomplish through your deployed endpoint.

Consider adding Fly.io's persistent volumes if your MCP server needs to cache data between restarts or maintain state across requests. Volumes cost a small amount but are far cheaper than adding an external database for simple use cases like caching API responses or storing user preferences.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=fly-io-mcp-server-deployment-workflow-guide)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/building-your-first-mcp-tool-integration-guide-2026/)
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/)
- [Claude Code for Fly.io Deployment Automation Workflow](/claude-code-for-fly-io-deployment-automation-workflow/)
- [Integrations Hub](/integrations-hub/)
- [Claude Code Firebase MCP Integration](/claude-code-firebase-mcp/)
- [Claude Code Flutter MCP Server Guide](/claude-code-flutter-mcp/)
- [Claude Code Azure MCP Server Guide](/claude-code-azure-mcp/)
- [Figma MCP Server: Design to Code Workflow Guide](/figma-mcp-server-design-to-code-workflow/)
- [Heroku MCP Server Application Deployment Guide](/heroku-mcp-server-application-deployment-guide/)
- [How to Choose the Right MCP Server](/how-to-choose-the-right-mcp-server/)
- [PagerDuty MCP Server Incident Management Guide](/pagerduty-mcp-server-incident-management-guide/)
- [Claude Code for Playwright MCP — Workflow Guide](/claude-code-for-playwright-mcp-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


