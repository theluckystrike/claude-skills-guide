---
layout: default
title: "Connect Claude Code to Remote MCP (2026)"
description: "Set up remote HTTP and SSE MCP servers in Claude Code with authentication headers, OAuth, and troubleshooting connection issues."
date: 2026-04-15
permalink: /claude-code-mcp-remote-http-server-setup/
categories: [guides, claude-code]
tags: [mcp, remote-servers, HTTP, SSE, OAuth, authentication]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Connect Claude Code to Remote MCP Servers

## The Problem

You want to connect Claude Code to a cloud-hosted MCP server (like Notion, Asana, or a custom API) but the connection fails, authentication does not work, or the server shows as disconnected in `/mcp`.

## Quick Fix

Add a remote HTTP MCP server with authentication:

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

For servers requiring a Bearer token:

```bash
claude mcp add --transport http secure-api https://api.example.com/mcp \
 --header "Authorization: Bearer your-token"
```

## What's Happening

MCP servers can run locally (stdio transport) or remotely (HTTP or SSE transport). Remote servers are the recommended option for cloud-based services because they do not require local process management. HTTP is the preferred transport; SSE (Server-Sent Events) is deprecated but still supported for older servers.

Remote servers often require authentication via Bearer tokens, API keys, or OAuth 2.0. Claude Code passes configured headers with every request. For OAuth servers, Claude Code handles the authentication flow when you use `/mcp` to connect.

## Step-by-Step Fix

### Step 1: Add an HTTP server

HTTP is the recommended transport for remote MCP servers:

```bash
claude mcp add --transport http my-service https://api.example.com/mcp
```

### Step 2: Add authentication headers

Pass authentication with `--header` flags:

```bash
# Bearer token
claude mcp add --transport http my-api https://api.example.com/mcp \
 --header "Authorization: Bearer your-token"

# API key header
claude mcp add --transport http my-api https://api.example.com/mcp \
 --header "X-API-Key: your-key-here"
```

### Step 3: Use OAuth authentication

Some remote servers use OAuth 2.0. After adding the server, authenticate through the `/mcp` command inside Claude Code:

```text
/mcp
```

Select the server and follow the OAuth flow. Claude Code handles token exchange and refresh automatically.

### Step 4: Add an SSE server (legacy)

For older servers that only support SSE:

```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse

# With authentication
claude mcp add --transport sse private-api https://api.company.com/sse \
 --header "X-API-Key: your-key-here"
```

Note: SSE transport is deprecated. Use HTTP transport when available.

### Step 5: Choose the right scope

Control where the server configuration is stored:

```bash
# Local: only you, only this project (default)
claude mcp add --transport http --scope local my-api https://api.example.com/mcp

# Project: shared with team via .mcp.json
claude mcp add --transport http --scope project my-api https://api.example.com/mcp

# User: available across all your projects
claude mcp add --transport http --scope user my-api https://api.example.com/mcp
```

Project scope stores the configuration in `.mcp.json` at the project root, which can be committed to version control. Do not commit files containing secret tokens; use environment variable interpolation instead.

### Step 6: Verify the connection

Check server status:

```bash
claude mcp list
claude mcp get my-api
```

Inside Claude Code:

```text
/mcp
```

The server should show a green status. If it shows red, check:

- Is the URL correct and reachable?
- Are authentication headers valid?
- Does the server support the configured transport?

### Step 7: Troubleshoot connection failures

If the server shows as disconnected:

1. Test the URL directly:
```bash
curl -I https://api.example.com/mcp
```

2. Check if your network blocks the server:
```bash
curl -v https://api.example.com/mcp 2>&1 | head -20
```

3. Verify authentication works:
```bash
curl -H "Authorization: Bearer your-token" https://api.example.com/mcp
```

4. If behind a corporate proxy, ensure proxy environment variables are set in your Claude Code settings.

### Step 8: Remove or update servers

```bash
# Remove a server
claude mcp remove my-api

# To update, remove and re-add with new configuration
claude mcp remove my-api
claude mcp add --transport http my-api https://new-url.example.com/mcp
```

## Prevention

Use HTTP transport for all new MCP server connections. Store shared server configurations at project scope in `.mcp.json` for team consistency. Keep authentication tokens in environment variables and reference them with `--env` flags rather than hardcoding them in configuration files.

Periodically check server status with `/mcp` to catch configuration drift or expired tokens.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-remote-http-server-setup)**

47/500 founding spots. Price goes up when they're gone.

</div>

---



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Building Your First MCP Tool Integration Guide](/building-your-first-mcp-tool-integration-guide-2026/)
- [Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/)
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/)
- [Brave Search MCP Server Research Automation](/brave-search-mcp-server-research-automation/)


