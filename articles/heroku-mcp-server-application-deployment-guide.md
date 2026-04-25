---
layout: default
title: "Heroku MCP Server Application (2026)"
description: "Claude Code resource: heroku MCP Server Application — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, heroku, mcp, deployment, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /heroku-mcp-server-application-deployment-guide/
geo_optimized: true
---

# Heroku MCP Server Application Deployment Guide

[Deploying a Model Context Protocol (MCP) server on Heroku provides a reliable, scalable way](/building-your-first-mcp-tool-integration-guide-2026/) to expose AI capabilities to your applications. This guide walks through the complete deployment process, from local development to production-ready infrastructure.

## Understanding MCP Servers

[MCP servers act as intermediaries between Claude and external tools or data sources](/how-do-i-combine-two-claude-skills-in-one-workflow/) They enable Claude to interact with APIs, databases, and services that aren't natively integrated. Whether you're building a custom integration with your internal systems or exposing specialized AI capabilities, hosting your MCP server on Heroku simplifies deployment and maintenance.

When you run an MCP server locally, it communicates with Claude over stdio on the same machine. Heroku deployment changes that model: your server becomes a persistent HTTP endpoint reachable over the network, which means Claude Desktop. or any other MCP client. can connect from anywhere without requiring a local process. This is the key architectural shift this guide addresses.

Heroku suits MCP deployment well for several reasons. You get a managed runtime that handles TLS termination, process restarts, and log aggregation out of the box. The `git push heroku main` deploy workflow is low-friction. And the add-on ecosystem makes it straightforward to attach a database or Redis cache if your MCP server needs persistent state.

## Prerequisites

Before deploying, ensure you have:

- Node.js 18 or higher installed locally
- A Heroku account with the CLI installed (`brew tap heroku/brew && brew install heroku` on macOS)
- An existing MCP server project or a basic template
- Git initialized in your project directory
- Familiarity with the MCP SDK's basic request-handler pattern

## Setting Up Your MCP Server Project

If you're starting from scratch, create a basic MCP server structure:

```bash
mkdir my-mcp-server && cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/server-basic @modelcontextprotocol/sdk
```

Create your server file:

```javascript
// server.js
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server({
 name: 'my-custom-server',
 version: '1.0.0'
}, {
 capabilities: {
 tools: {}
 }
});

server.setRequestHandler('tools/list', async () => {
 return {
 tools: [{
 name: 'greet',
 description: 'Greet a user by name',
 inputSchema: {
 type: 'object',
 properties: {
 name: { type: 'string', description: 'Name to greet' }
 },
 required: ['name']
 }
 }]
 };
});

server.setRequestHandler('tools/call', async ({ name, arguments: args }) => {
 if (name === 'greet') {
 return { content: [{ type: 'text', text: `Hello, ${args.name}!` }] };
 }
 throw new Error(`Unknown tool: ${name}`);
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Update your `package.json` with a start script:

```json
{
 "type": "module",
 "scripts": {
 "start": "node server.js"
 }
}
```

The `"type": "module"` field is important. it tells Node.js to treat `.js` files as ES modules, which the MCP SDK uses. Without it, the `import` statements in the SDK will throw a syntax error when Heroku tries to start your dyno.

## Configuring Heroku for MCP Deployment

MCP servers typically communicate over stdio, but Heroku's architecture requires an HTTP-based approach. Modify your server to support HTTP connections:

```javascript
// server-http.js
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { HttpServerTransport } from '@modelcontextprotocol/sdk/server/http.js';
import express from 'express';

const app = express();
app.use(express.json());

const server = new Server({
 name: 'my-custom-server',
 version: '1.0.0'
}, {
 capabilities: {
 tools: {}
 }
});

// Define your tools and handlers here
server.setRequestHandler('tools/list', async () => {
 return { tools: [/* your tool definitions */] };
});

server.setRequestHandler('tools/call', async (request) => {
 // Handle tool calls
});

const transport = new HttpServerTransport('/mcp', app);
await server.connect(transport);

const port = process.env.PORT || 3000;
app.listen(port, () => {
 console.log(`MCP server listening on port ${port}`);
});
```

Heroku assigns a dynamic port through the `PORT` environment variable at runtime. Hard-coding port 3000 will cause your dyno to fail its health check, so always read from `process.env.PORT`.

Heroku requires a `Procfile` to know how to run your application:

```procfile
web: node server-http.js
```

Add a `.gitignore` file before your first commit to keep `node_modules` out of your repository:

```
node_modules/
.env
*.log
```

## Deploying to Heroku

Initialize git in your project if you haven't already:

```bash
git init
git add .
git commit -m "Initial MCP server commit"
```

Create a new Heroku application and deploy:

```bash
heroku create my-mcp-server
git push heroku main
```

Your MCP server is now live. Retrieve the URL:

```bash
heroku apps:info | grep "Web URL"
```

The URL will look like `https://my-mcp-server.herokuapp.com`. Your MCP endpoint is at `https://my-mcp-server.herokuapp.com/mcp`.

Confirm the dyno is running correctly before proceeding:

```bash
heroku ps
Should show: web.1: up YYYY/MM/DD ...
```

If you see `web.1: crashed`, check the logs immediately:

```bash
heroku logs --tail
```

Common startup failures at this stage are missing dependencies (forgot to `npm install` before committing a lock file), syntax errors in ES module imports, or the wrong `main` field in `package.json`.

## Connecting Claude to Your Heroku MCP Server

With your server deployed, configure Claude Desktop to connect. Create or edit your Claude configuration file:

```json
{
 "mcpServers": {
 "my-heroku-mcp": {
 "url": "https://your-app-name.herokuapp.com/mcp"
 }
 }
}
```

Replace `your-app-name` with your actual Heroku application name. Claude will now be able to call your deployed MCP server for tool invocations.

On macOS, the Claude Desktop config file lives at `~/Library/Application Support/Claude/claude_desktop_config.json`. On Windows it is at `%APPDATA%\Claude\claude_desktop_config.json`. After editing the file, restart Claude Desktop completely. a reload is not sufficient to pick up new MCP server entries.

## Production Considerations

When moving to production, several factors require attention:

Environment Variables: Store sensitive configuration in Heroku config vars rather than hardcoding credentials. Access them in your server:

```javascript
const apiKey = process.env.API_KEY;
const databaseUrl = process.env.DATABASE_URL;
```

Set config vars from the CLI:

```bash
heroku config:set API_KEY=your-secret-key
heroku config:set DATABASE_URL=postgres://user:pass@host/dbname
```

Config vars are encrypted at rest and injected into your dyno's environment at startup. They are the correct way to pass secrets to Heroku apps. never commit credentials to your repository.

Scaling: Heroku's free tier sleeps after inactivity. For consistent response times, consider a paid dyno or implement a keep-alive mechanism. Scale your dynos based on demand:

```bash
heroku ps:scale web=2
```

A comparison of Heroku dyno tiers for MCP workloads:

| Dyno Type | Sleep Behavior | RAM | Good For |
|-----------|---------------|-----|----------|
| Eco | Sleeps after 30 min | 512 MB | Development only |
| Basic | Never sleeps | 512 MB | Low-traffic production |
| Standard-1X | Never sleeps | 512 MB | General production |
| Standard-2X | Never sleeps | 1 GB | Memory-intensive tools |
| Performance-M | Never sleeps | 2.5 GB | High-throughput MCP servers |

For most MCP servers that bridge Claude to internal APIs, a Standard-1X dyno is sufficient. Upgrade to Standard-2X or Performance-M if your tools load large datasets or run in-process ML inference.

Logging and Monitoring: Heroku provides built-in logging:

```bash
heroku logs --tail
```

For more comprehensive monitoring, integrate with services like DataDog or New Relic through Heroku addons:

```bash
heroku addons:create newrelic:wayne
```

Add structured logging to your server so log lines are easy to query in your monitoring dashboard:

```javascript
function log(level, message, meta = {}) {
 console.log(JSON.stringify({ level, message, timestamp: new Date().toISOString(), ...meta }));
}

// Usage inside a tool handler:
log('info', 'tool_call', { tool: name, args });
```

## Authentication and Security

A publicly deployed MCP server is reachable by anyone who knows the URL. For internal tools, add a simple bearer-token check:

```javascript
app.use('/mcp', (req, res, next) => {
 const token = req.headers['authorization']?.replace('Bearer ', '');
 if (token !== process.env.MCP_SECRET_TOKEN) {
 return res.status(401).json({ error: 'Unauthorized' });
 }
 next();
});
```

Then set the token in Heroku config vars:

```bash
heroku config:set MCP_SECRET_TOKEN=$(openssl rand -hex 32)
```

Update your Claude Desktop config to send the token:

```json
{
 "mcpServers": {
 "my-heroku-mcp": {
 "url": "https://your-app-name.herokuapp.com/mcp",
 "headers": {
 "Authorization": "Bearer your-token-here"
 }
 }
 }
}
```

## Using Claude Skills with Your MCP Server

Your deployed MCP server works well with various Claude skills. The frontend-design skill can help generate UI components that consume your MCP tools. If you're building documentation, pair your server with the pdf skill to generate reports from MCP-sourced data.

For test-driven development, the tdd skill assists in writing comprehensive tests for your MCP server endpoints. The supermemory skill can help maintain context across complex conversations about your deployment architecture.

A practical integration pattern: use the tdd skill to write a test suite that exercises each of your MCP tools via HTTP, then add that test suite to your CI pipeline so every `git push heroku main` is preceded by a test run. This prevents broken tool handlers from reaching production.

## Troubleshooting Common Issues

Connection Timeouts: If Claude cannot reach your server, verify your Heroku dyno is running and the endpoint URL is correct in your configuration. Run `heroku ps` to check dyno state and `heroku logs --tail` to see if requests are arriving.

CORS Issues: If your MCP server serves web clients directly, ensure CORS headers are properly configured in Express:

```javascript
app.use((req, res, next) => {
 res.header('Access-Control-Allow-Origin', '*');
 res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
 res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
 if (req.method === 'OPTIONS') return res.sendStatus(200);
 next();
});
```

Memory Limits: Heroku dynos have memory constraints. Optimize your server's memory usage and consider upgrading to larger dyno types for resource-intensive operations. You can monitor memory usage with:

```bash
heroku ps:exec --dyno=web.1 -- node -e "console.log(process.memoryUsage())"
```

R10 Boot Timeout: Heroku kills dynos that don't bind to `PORT` within 60 seconds. If your server does heavy initialization (loading models, seeding caches), do it lazily after the HTTP listener starts, not before.

## Conclusion

Deploying an MCP server on Heroku bridges the gap between Claude's capabilities and your custom backend services. The platform handles infrastructure concerns, letting you focus on building valuable integrations. With proper configuration and monitoring, your Heroku-hosted MCP server provides a reliable foundation for AI-powered applications.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=heroku-mcp-server-application-deployment-guide)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/building-your-first-mcp-tool-integration-guide-2026/)
- [Railway MCP Server Deployment Automation Guide](/railway-mcp-server-deployment-automation-guide/)
- [Render MCP Server Web Service Automation](/render-mcp-server-web-service-automation/)
- [Integrations Hub](/integrations-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


