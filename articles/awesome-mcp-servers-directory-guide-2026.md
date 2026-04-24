---
title: "Awesome MCP Servers: Directory Guide (2026)"
description: "Browse 200+ MCP servers across 30+ categories in the awesome-mcp-servers repo (85K stars) — the definitive directory at mcpservers.org."
permalink: /awesome-mcp-servers-directory-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Awesome MCP Servers: Directory Guide (2026)

The `awesome-mcp-servers` repository by punkpeye (85K+ stars) is the largest directory of Model Context Protocol servers. With 200+ servers across 30+ categories, it's the first place to check when you want Claude Code to interact with an external system. Browse at mcpservers.org for search and filtering.

## What It Is

A curated list of MCP (Model Context Protocol) server implementations. Each entry includes the server name, what it connects to, installation method, and compatibility notes. Categories span databases, APIs, developer tools, cloud providers, communication platforms, and more.

MCP servers act as bridges between Claude Code and external systems. Instead of telling Claude Code to "run a SQL query" and having it shell out to `psql`, an MCP server provides a structured tool interface. Claude Code calls `query_database` with parameters, and the MCP server handles connection pooling, authentication, and result formatting.

## Why It Matters

Claude Code's built-in tools cover file operations, bash commands, and web requests. For anything else — databases, SaaS APIs, cloud infrastructure, monitoring systems — you need an MCP server. This directory eliminates the build-vs-browse decision by showing what already exists.

The repo's 85K stars make it the most-starred resource in the entire Claude Code ecosystem, reflecting how central MCP is to serious Claude Code workflows.

## Installation

The directory itself requires no installation. To use a listed MCP server:

### 1. Find the Server

Browse mcpservers.org or the repo README. Example: you need PostgreSQL access.

### 2. Install the Server

Each listing includes install instructions. For PostgreSQL:

```bash
npm install -g @modelcontextprotocol/server-postgres
```

### 3. Configure in Claude Code

Add to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "args": ["--connection-string", "postgresql://user:pass@localhost:5432/mydb"]
    }
  }
}
```

### 4. Verify

Start Claude Code and ask it to list available tools. The PostgreSQL MCP tools should appear.

## Key Features

1. **200+ Servers** — coverage across databases (PostgreSQL, MySQL, MongoDB, Redis, SQLite), cloud providers (AWS, GCP, Azure), developer tools (GitHub, GitLab, Jira, Linear), communication (Slack, Discord, Email), file systems, and more.

2. **30+ Categories** — organized by domain so you can browse the right section without scrolling through 200 entries.

3. **Quality Ratings** — community upvotes and star counts on the web interface help distinguish well-maintained servers from experiments.

4. **Install Commands** — every listing includes the exact npm/pip/cargo command to install, plus config snippets for Claude Code integration.

5. **Official vs. Community Tags** — entries tagged as "official" are maintained by the service provider (e.g., Anthropic's reference servers). Community entries are third-party.

6. **Compatibility Matrix** — servers tagged with the MCP protocol version they support, so you don't install one that requires a newer protocol than your Claude Code version supports.

7. **Web Interface** — mcpservers.org adds search, category filtering, and sort-by-stars that the raw README lacks.

8. **Weekly Additions** — new servers are added multiple times per week as the MCP ecosystem grows.

## Real Usage Example

### Setting Up a Multi-MCP Workspace

A typical full-stack project might use three MCP servers:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "args": ["--connection-string", "postgresql://dev:dev@localhost:5432/app"]
    },
    "github": {
      "command": "mcp-server-github",
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    },
    "redis": {
      "command": "mcp-server-redis",
      "args": ["--url", "redis://localhost:6379"]
    }
  }
}
```

Now Claude Code can:

- Query and modify the database directly
- Create PRs, review issues, and manage branches through GitHub
- Read and write cache entries in Redis

All through structured tool calls rather than bash commands.

### Finding the Right Server

```
Need: Send Slack notifications when deployments complete

1. Go to mcpservers.org
2. Search "slack"
3. Find: @anthropic/mcp-server-slack (official, 2.1K stars)
4. Install: npm install -g @anthropic/mcp-server-slack
5. Config requires: SLACK_BOT_TOKEN, SLACK_TEAM_ID
6. Tools exposed: send_message, list_channels, read_thread
```

## When To Use

- **Any time Claude Code needs external system access** — databases, APIs, cloud services
- **Replacing fragile bash scripts** — MCP servers are more reliable (use [claude mcp list](/claude-mcp-list-command-guide/) to manage them)
- **Team standardization** — agree on which MCP servers to use across projects
- **Building custom workflows** — chain MCP tools for complex operations (query DB → format results → post to Slack)

## When NOT To Use

- **Simple file operations** — Claude Code's built-in tools handle files natively; no MCP needed
- **One-off commands** — if you need to run `psql` once, just use bash; MCP setup takes longer
- **Untrusted servers** — MCP servers execute with your permissions; only install from trusted sources
- **Air-gapped environments** — most MCP servers need network access to reach the services they connect to

## FAQ

### How do I know if an MCP server is safe?

Check the source code, star count, and maintainer reputation. Official servers from Anthropic or the service provider are safest. Community servers should be audited before use in production.

### Can I run multiple MCP servers simultaneously?

Yes. Claude Code supports any number of MCP servers in `.claude/settings.json`. Each gets its own process and tool namespace.

### What happens if an MCP server crashes?

Claude Code falls back to built-in tools and reports the MCP server as unavailable. Restart Claude Code to reconnect.

### Can I write my own MCP server?

Yes. The MCP SDK is available for TypeScript, Python, and Rust. The protocol spec is at modelcontextprotocol.io. Expect 2-4 hours to build a basic server.

### How do MCP servers affect token usage?

Each MCP tool definition adds ~50-100 tokens to the context. With 3 servers exposing 5 tools each, that's ~750-1,500 tokens of overhead per message. Use [ccusage](/ccusage-claude-code-cost-tracking-guide-2026/) to measure the impact.

## Our Take

**9/10.** The single most important directory in the Claude Code ecosystem. MCP servers are what turn Claude Code from a code generator into a full-stack development agent, and this repo catalogs all of them. The web interface at mcpservers.org is genuinely well-built. Only ding: some listings are outdated or abandoned, and the community rating system doesn't surface this clearly enough.

## Related Resources

- [MCP Setup Guide](/claude-code-mcp-setup-guide/) — step-by-step MCP configuration for Claude Code
- [Claude Code Best Practices](/claude-code-best-practices-2026/) — patterns for effective MCP usage
- [Claude Code Hooks Explained](/claude-code-hooks-explained/) — hooks can trigger MCP operations

