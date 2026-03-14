---
layout: default
title: "Fly.io MCP Server Deployment Workflow Guide"
description: "A practical guide to deploying Model Context Protocol servers on Fly.io. Learn the deployment workflow, configuration, and automation with Claude skills."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, mcp, fly-io, deployment, docker, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Fly.io MCP Server Deployment Workflow Guide

[Deploying a Model Context Protocol (MCP) server to Fly.io gives you](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/) a globally distributed, low-latency endpoint that Claude Code can connect to for enhanced tool-calling capabilities. This guide covers the complete deployment workflow, from containerization to automated deployments using Claude skills.

## Why Deploy MCP Servers on Fly.io

Fly.io runs containers close to users, making it ideal for MCP servers that need fast response times. The platform handles TLS certificates automatically, manages edge networking, and supports persistent volumes when your server needs state. Many developers [combine their MCP deployment with the frontend-design skill](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) for generating UI components, or the pdf skill for document processing—all without requiring local infrastructure.

The workflow described here works with any MCP server implementation, whether you built it in Python, Node.js, or Go.

## Preparing Your MCP Server for Containerization

Before deploying to Fly.io, ensure your MCP server listens on the correct port and handles shutdown signals gracefully. Fly.io exposes applications through port 8080 by default.

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

Ensure your server reads the port from an environment variable:

```javascript
const port = process.env.PORT || 8080;
server.listen(port, () => {
  console.log(`MCP server running on port ${port}`);
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

The `[env]` section lets you pass environment variables to your container. Use this for API keys, database connection strings, or configuration flags.

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

## Automating Deployments with Claude Skills

You can streamline deployments using a Claude skill that encapsulates your workflow. Create a skill file that guides Claude through the deployment process:

```markdown
# Deploy Skill

When the user wants to deploy an MCP server to Fly.io:

1. Check if fly.toml exists
2. If not, run `fly launch` with appropriate settings
3. Run `fly deploy` to deploy
4. Verify the deployment with a health check
5. Report the final URL to the user
```

Save this as `~/.claude/skills/deploy.md` and activate it with `/deploy` in your Claude session.

For more complex workflows, consider chaining the deploy skill with other Claude skills. The tdd skill helps you write tests for your MCP server before deployment, while the supermemory skill can track deployment history and configuration across sessions.

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

This approach lets you test changes on staging before promoting them to production.

## Monitoring Your MCP Server

Fly.io provides built-in metrics through its dashboard. For custom monitoring, add logging to your server:

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

For connection issues between Claude Code and your server, verify the endpoint responds correctly:

```bash
curl https://your-server.fly.dev/mcp
```

## Next Steps

With your MCP server deployed on Fly.io, explore extending its capabilities. The pdf skill can process documents through your server, while the canvas-design skill might generate visual assets. Each skill you add creates new possibilities for what Claude Code can accomplish through your deployed endpoint.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [AWS MCP Server Cloud Automation with Claude Code](/claude-skills-guide/aws-mcp-server-cloud-automation-with-claude-code/)
- [Claude Code for Fly.io Deployment Automation Workflow](/claude-skills-guide/claude-code-for-fly-io-deployment-automation-workflow/)
- [Integrations Hub](/claude-skills-guide/integrations-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
