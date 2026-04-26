---
layout: default
title: "Claude Code Cloudflare MCP Server Setup (2026)"
description: "Connect Claude Code to Cloudflare Workers, Pages, KV, and R2 via MCP. Deploy and manage edge infrastructure from your terminal."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-cloudflare-mcp/
categories: [guides]
tags: [claude-code, claude-skills, cloudflare, mcp, edge-computing]
reviewed: true
score: 6
geo_optimized: true
---

The Cloudflare MCP server lets Claude Code interact with your Cloudflare Workers, Pages, KV stores, R2 buckets, and DNS settings through the Model Context Protocol. This guide covers setup, authentication with API tokens, and practical workflows for managing Cloudflare edge infrastructure.

## The Problem

Cloudflare developers manage Workers, Pages, KV namespaces, R2 storage, and DNS records across the Cloudflare dashboard and Wrangler CLI. Claude Code has no native Cloudflare awareness. Without MCP, you describe your Workers config, paste Wrangler errors, and manually copy deployment outputs into your Claude Code session. Edge computing has enough complexity without this overhead.

## Quick Solution

1. Create a Cloudflare API token with the permissions you need:

```text
Cloudflare Dashboard > My Profile > API Tokens > Create Token
Permissions: Workers Scripts (Edit), Workers KV (Edit), Pages (Edit)
Zone: your-domain.com
```

2. Add the Cloudflare MCP server to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "your-api-token",
        "CLOUDFLARE_ACCOUNT_ID": "your-account-id"
      }
    }
  }
}
```

3. Restart Claude Code and verify the connection:

```bash
claude /mcp
# Should show "cloudflare" with available tools
```

4. Test with a query:

```text
List all Workers in my Cloudflare account
```

5. Ensure Wrangler is installed for deployment operations:

```bash
npm install -g wrangler
wrangler login
```

## How It Works

The Cloudflare MCP server wraps the Cloudflare API v4, exposing operations as structured tools that Claude Code can invoke. When Claude Code starts, it spawns the MCP server, which authenticates using your API token.

Available tools typically include: listing and deploying Workers, reading and writing KV pairs, managing R2 buckets and objects, querying DNS records, and checking Pages deployment status. Each tool accepts typed parameters and returns structured responses.

For deployment workflows, the MCP server can trigger Wrangler deployments or call the Cloudflare API directly. Claude Code can read your `wrangler.toml` configuration, understand your Worker bindings (KV, R2, D1, Durable Objects), and suggest changes based on your infrastructure.

The API token scopes control exactly what Claude Code can do. A read-only token lets Claude Code inspect your setup, while edit tokens allow deployments and configuration changes.

## Common Issues

**API token scope insufficient**: If Claude Code gets 403 errors, your API token is missing the required permission. Create a new token with broader scope or add the specific permission (e.g., Workers KV Storage Edit).

**Account ID mismatch**: If you have multiple Cloudflare accounts (personal + team), ensure `CLOUDFLARE_ACCOUNT_ID` points to the correct one. Find it in the Cloudflare dashboard under the domain overview page.

**Wrangler and MCP conflicts**: If both Wrangler CLI and the MCP server try to deploy simultaneously, you may get version conflicts. Use one approach per session -- either MCP-triggered deploys or manual Wrangler deploys.

## Example CLAUDE.md Section

```markdown
# Cloudflare Infrastructure

## MCP Server
- Cloudflare MCP configured in .claude/settings.json
- Account ID: abc123def456
- Primary zone: myapp.com

## Workers
- api-worker: Handles /api/* routes (src/worker.ts)
- auth-worker: JWT validation (src/auth-worker.ts)
- cron-worker: Scheduled tasks (runs every 5min)

## Bindings
- KV Namespace: CACHE (production), CACHE_DEV (development)
- R2 Bucket: assets (public), uploads (private)
- D1 Database: main-db
- Durable Objects: RateLimiter, SessionStore

## Deployment
- Use `wrangler deploy` for Workers
- Pages auto-deploys from main branch
- NEVER deploy Workers during peak hours (09:00-17:00 UTC)
- Always test with `wrangler dev` before deploying
```

## Best Practices

- **Use scoped API tokens.** Never use your Global API Key. Create tokens with minimum permissions for the specific Cloudflare services Claude Code needs to access.
- **Separate development and production tokens.** Use different API tokens for dev and prod accounts, configured in project-level `.claude/settings.json`.
- **Document Worker bindings in CLAUDE.md.** KV namespaces, R2 buckets, D1 databases, and Durable Objects are critical context that Claude Code needs to generate correct code.
- **Include wrangler.toml context.** Tell Claude Code where your `wrangler.toml` lives and what environment configurations it contains.
- **Monitor Worker analytics.** After MCP-triggered deployments, check Worker analytics for error rate spikes. Document the monitoring URL in CLAUDE.md.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-cloudflare-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code cloudflare mcp server setup?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Resources

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

- [Claude Code AWS MCP Server Setup Guide](/claude-code-aws-mcp-server/)
- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
