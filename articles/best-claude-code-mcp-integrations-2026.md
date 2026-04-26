---
layout: default
title: "Best Claude Code MCP Integrations (2026)"
description: "Ranked list of the best MCP server integrations for Claude Code covering databases, GitHub, file systems, memory, and cloud services."
permalink: /best-claude-code-mcp-integrations-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Best Claude Code MCP Integrations (2026)

MCP (Model Context Protocol) servers give Claude Code access to external services -- databases, APIs, cloud providers, and custom tools. With 200+ servers available through the [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) index (85K+ stars), choosing the right ones matters. This ranked list covers the most useful integrations for developers.

## How MCP Servers Work

[MCP configuration](/claude-code-mcp-configuration-guide/) lives in `.claude/settings.json`.

For the full setup guide, see our [MCP servers setup guide](/mcp-servers-claude-code-complete-setup-2026/).

## 1. Filesystem Server

**What:** Gives Claude Code access to directories outside your project. Essential for cross-project work, documentation access, and reading config files stored elsewhere.

**Install:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
               "/Users/you/documents", "/Users/you/other-project"]
    }
  }
}
```

**Use cases:** Referencing documentation, copying patterns from other projects, accessing shared config.

**Pros:** Official server, stable, well-tested, minimal overhead.
**Cons:** Must explicitly whitelist directories (security feature). Cannot access paths not listed.
**Limitation:** Read/write access to listed directories. Scope carefully.

## 2. GitHub Server

**What:** Access GitHub repos, issues, PRs, and actions without leaving Claude Code.

**Install:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  }
}
```

**Use cases:** Reading issue details for context, creating PRs, reviewing open issues, checking CI status.

**Pros:** Official server. Full GitHub API coverage. Speeds up issue-driven development.
**Cons:** Requires personal access token. Token scope determines access level.
**Limitation:** Rate limited by GitHub API. Heavy usage may hit limits.

## 3. PostgreSQL Server

**What:** Query your database directly from Claude Code. Useful for debugging data issues, generating migrations, and understanding schema.

**Install:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@mcp/postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb"
      }
    }
  }
}
```

**Use cases:** "Show me all users who signed up last week," "What tables reference the orders table?", "Generate a migration for adding a status column."

**Pros:** Direct data access without copy-pasting SQL results. Schema introspection.
**Cons:** Database credentials in config (use env vars). Read access can be dangerous on production.
**Limitation:** Use on development databases only. Never connect to production without read-only credentials.

## 4. Memory / Knowledge Graph Server

**What:** Persistent memory across Claude Code sessions. Stores facts, decisions, and context that survives session boundaries.

**Install:**
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**Use cases:** Remembering architectural decisions, storing team preferences, tracking project state across sessions.

**Pros:** Solves the "Claude Code forgets between sessions" problem. Graph-based storage.
**Cons:** Memory grows over time and may need pruning. Storage is local.
**Limitation:** Not a replacement for CLAUDE.md -- use for dynamic state, not static rules.

## 5. Fetch / Web Server

**What:** Lets Claude Code read web pages, API documentation, and online resources.

**Install:**
```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

**Use cases:** Reading API docs, checking library documentation, accessing online resources during development.

**Pros:** Direct web access from Claude Code sessions. Supports HTML to markdown conversion.
**Cons:** Token cost for large pages. Cannot access authenticated content.
**Limitation:** Public pages only. Cannot log into services.

## 6. SQLite Server

**What:** Query SQLite databases for local data analysis, testing, and embedded database projects.

**Install:**
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "./data/app.db"]
    }
  }
}
```

**Use cases:** Analyzing local data, testing database queries, working with embedded databases.

**Pros:** Lightweight. No server needed. Good for prototyping.
**Cons:** SQLite limitations (no concurrent writes, limited types).
**Limitation:** Single-file databases only.

## 7. Puppeteer / Browser Server

**What:** Automated browser interactions for testing, scraping, and visual verification.

**Install:**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

**Use cases:** E2E testing, visual regression checks, generating screenshots.

**Pros:** Full browser automation. Can verify rendered output.
**Cons:** Heavy resource usage. Slow compared to API calls.
**Limitation:** Headless only in CI. Not suitable for long-running browser sessions.

## 8. Slack Server

**What:** Read and send Slack messages from Claude Code. Useful for team communication automation.

**Install:**
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@mcp/slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-..."
      }
    }
  }
}
```

**Use cases:** Posting deployment notifications, reading discussion context, updating channels with status.

**Pros:** Direct team communication. Automate status updates.
**Cons:** Requires Slack app setup. Token permissions must be scoped carefully.
**Limitation:** Rate limited by Slack API. Not for real-time chat.

## 9. Docker Server

**What:** Manage Docker containers, images, and compose environments from Claude Code.

**Use cases:** Starting test databases, managing development environments, debugging container issues.

**Pros:** Container lifecycle management without leaving Claude Code.
**Cons:** Docker socket access required. Security implications on shared machines.
**Limitation:** Local Docker only. Not for production orchestration.

## 10. Sentry / Error Tracking Server

**What:** Access error reports and monitoring data from your error tracking service.

**Use cases:** "What errors are happening most frequently?", "Show me the stack trace for the latest 500 error."

**Pros:** Direct error context for debugging sessions.
**Cons:** Requires Sentry API key. Data can be large (paginate).
**Limitation:** Read-only. Cannot resolve errors through MCP.

## Security Recommendations

1. **Development databases only** -- Never connect MCP servers to production data
2. **Read-only credentials** -- Use read-only database users for MCP
3. **Scope tokens** -- GitHub tokens should have minimal permissions
4. **Review source code** -- Check community servers before installing
5. **Project-level config** -- Database MCP goes in project settings, not global

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) covers MCP security in its threat model section.

## Stack Recommendations

### For Web Developers
Filesystem + GitHub + PostgreSQL + Fetch

### For DevOps
Filesystem + Docker + GitHub + Slack

### For Data Teams
Filesystem + PostgreSQL + SQLite + Fetch

### For Solo Developers
Filesystem + Memory + Fetch

## FAQ

### How many MCP servers should I run?
3-5 is the sweet spot. Each server adds tool definitions to context (100-500 tokens). More than 10 servers creates significant overhead.

### Can I use the same MCP server across projects?
Put shared servers (GitHub, Memory, Fetch) in `~/.claude/settings.json`. Put project-specific servers (database) in `.claude/settings.json`.

### Are MCP servers compatible with Cursor?
Yes. MCP is an open standard. Servers work with any MCP-compatible client. The [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes 55+ MCP configurations you can adapt.

### What if an MCP server crashes?
Claude Code continues working but loses access to that server's tools. Restart Claude Code to reconnect.

For setup instructions, see the [MCP setup guide](/mcp-servers-claude-code-complete-setup-2026/). For the full ecosystem, read the [tools map](/claude-code-ecosystem-complete-map-2026/). For security, see the [threat model guide](/claude-code-security-threat-model-2026/).


## Related

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [claude mcp list command guide](/claude-mcp-list-command-guide/) — How to use the claude mcp list command to manage MCP servers

