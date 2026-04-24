---
title: "Best MCP Servers for Claude Code (2026)"
description: "The most useful MCP servers for Claude Code developers ranked by category. Database, Git, browser, and API servers with install commands and honest limits."
permalink: /best-mcp-servers-for-claude-code-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Best MCP Servers for Claude Code (2026)

MCP servers are the biggest force multiplier for Claude Code. They let Claude interact with databases, APIs, browsers, and cloud services directly. Here are the most useful ones, ranked by category.

## How We Selected

Criteria: stability, community adoption, documentation quality, Claude Code compatibility, and practical utility. Each entry has been used in production Claude Code workflows.

---

## Database Servers

### 1. PostgreSQL MCP Server

**What it does**: Gives Claude read/write access to PostgreSQL databases. Claude can query data, inspect schemas, create tables, and run migrations.

**Why it is good**: Most web applications use PostgreSQL. Direct database access means Claude can debug data issues, write queries, and create migrations without you copying SQL back and forth.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-postgres
```

**Config**:
```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

**Limitation**: Full database access means Claude can modify production data. Use read-only credentials for production databases.

### 2. SQLite MCP Server

**What it does**: Local SQLite database access for development, prototyping, and lightweight applications.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-sqlite
```

**Limitation**: Single-file database — not suitable for concurrent access patterns.

---

## Developer Tool Servers

### 3. GitHub MCP Server

**What it does**: GitHub API access — issues, PRs, repos, actions, and more. Claude can create issues, review PRs, and manage repositories.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-github
```

**Limitation**: Requires a personal access token with appropriate scopes. Be careful with write permissions.

### 4. Filesystem MCP Server

**What it does**: Controlled file system access beyond Claude Code's built-in file tools. Useful for accessing directories outside the project root.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

**Limitation**: Security risk if pointed at sensitive directories. Scope access narrowly.

---

## Browser and Web Servers

### 5. Puppeteer MCP Server

**What it does**: Headless Chrome browser control. Claude can navigate pages, fill forms, take screenshots, and extract data.

**Why it is good**: E2E testing, web scraping, and UI verification without leaving your Claude Code session.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-puppeteer
```

**Limitation**: Resource-heavy. Each browser instance uses significant memory. Close instances when not needed.

### 6. Fetch MCP Server

**What it does**: HTTP request capabilities. Claude can call REST APIs, download files, and interact with web services.

**Install**:
```bash
npm install -g @modelcontextprotocol/server-fetch
```

**Limitation**: No built-in authentication handling. You may need to configure headers or tokens for authenticated APIs.

---

## Cloud and Infrastructure

### 7. Docker MCP Server

**What it does**: Docker container management. Claude can build images, run containers, inspect logs, and manage Docker Compose stacks.

**Why it is good**: Containerized development and deployment without leaving your coding session.

**Limitation**: Requires Docker daemon running. Container operations can be slow on first pull.

### 8. Kubernetes MCP Server

**What it does**: Kubectl-like operations through MCP. Claude can inspect pods, read logs, apply manifests, and troubleshoot cluster issues.

**Limitation**: Powerful but dangerous in production. Use read-only kubeconfig for production clusters.

---

## Communication

### 9. Slack MCP Server

**What it does**: Send messages, read channels, and search Slack history. Useful for deployment notifications and team updates.

**Limitation**: Requires Slack app with appropriate permissions. Message rate limits apply.

---

## Knowledge and Search

### 10. Memory MCP Server

**What it does**: Persistent key-value storage across Claude Code sessions. Claude can save and recall information between conversations.

**Why it is good**: Claude normally loses context between sessions. This server lets Claude remember project decisions, preferences, and progress.

**Limitation**: Storage is local. Does not sync across machines.

---

## Monitoring and Management

### 11. Health Check MCP Server

**What it does**: Monitors the health of your other MCP servers and your application's endpoints. Claude can check if services are running, query response times, and diagnose connectivity issues.

**Why it is good**: When something breaks during a Claude Code session, Claude can diagnose the issue without you switching to another terminal to run health checks.

**Limitation**: Adds another server to manage. Only worth it if you run 3+ other MCP servers.

---

## How to Evaluate New MCP Servers

The Awesome MCP Servers directory adds new entries weekly. Here is how to evaluate new servers quickly:

1. **Check the README for Claude Code examples** — Not all MCP servers are tested with Claude Code. If the README only mentions other clients, proceed with caution.

2. **Check dependency count** — Servers with fewer dependencies are easier to install and less likely to have conflicts.

3. **Check the tool definitions** — Good MCP servers have well-defined tools with clear parameter descriptions. Claude works better with clear tool definitions.

4. **Run it standalone first** — Before adding to Claude Code, run the server in a terminal to verify it starts correctly and responds to requests.

5. **Check resource usage** — Some servers (especially browser-based ones) consume significant memory. Monitor resource usage during your first session.

## Recommended Starter Stack

For a typical web development project, start with these three:

1. **PostgreSQL or SQLite** — database access for your project
2. **GitHub** — PR and issue management
3. **Filesystem** — access to config files and documentation outside the project root

Add more as needed. Each server adds latency and context, so only install what you actively use.

For installation details, see the [MCP setup guide](/mcp-servers-claude-code-complete-setup-2026/). To discover more servers, browse [Awesome MCP Servers](/how-to-browse-awesome-mcp-servers-2026/). For combining MCP servers with other tools, check the [Claude Code hooks guide](/understanding-claude-code-hooks-system-complete-guide/) and the [Claude Code playbook](/playbook/).


## Related

- [claude mcp list command guide](/claude-mcp-list-command-guide/) — How to use the claude mcp list command to manage MCP servers

- [Claude Desktop config.json guide](/claude-desktop-config-json-guide/) — How to configure Claude Desktop with config.json
