---
sitemap: false
layout: default
title: "Set Up Docker MCP Server for Claude (2026)"
description: "Give Claude Code direct Docker access via MCP. Manage containers, images, and compose stacks with a Docker MCP server configuration. Updated for 2026."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-docker-mcp/
categories: [guides]
tags: [claude-code, claude-skills, docker, mcp, devops]
reviewed: true
score: 6
geo_optimized: true
last_tested: "2026-04-22"
---

A Docker MCP server lets Claude Code manage containers, inspect images, read logs, and orchestrate compose stacks directly. Instead of copying and pasting Docker CLI output, Claude can query container status, tail logs, and restart services through structured MCP tool calls.

## The Problem

When debugging containerized applications, you constantly switch between Claude Code and the terminal to check container status, read logs, and restart services. Claude cannot see your Docker environment -- it suggests commands but cannot verify whether they worked. This back-and-forth wastes time and introduces copy-paste errors.

## Quick Solution

1. Install the Docker MCP server:

```bash
npm install -g @anthropic/docker-mcp-server
```

2. [Claude Code MCP configuration guide](/claude-code-mcp-configuration-guide/).json`:

```json
{
  "mcpServers": {
    "docker": {
      "command": "docker-mcp-server",
      "args": [],
      "env": {
        "DOCKER_HOST": "unix:///var/run/docker.sock"
      }
    }
  }
}
```

3. Verify the connection:

```bash
claude mcp list
# Should show "docker" as connected
```

4. Use Docker tools in your Claude session:

```bash
claude "List all running containers. Show me the logs
from the api container for the last 5 minutes. If there
are any errors, diagnose the root cause."
```

5. Manage compose stacks:

```bash
claude "Read docker-compose.yml and start all services.
Wait for health checks to pass on the db and redis
services before confirming the stack is ready."
```

## How It Works

The Docker MCP server connects to the Docker daemon via the Docker socket (`/var/run/docker.sock`) and exposes container management tools through the MCP protocol. Claude Code spawns it as a child process and communicates via stdio transport.

Typical tools exposed include:

- **list_containers** -- lists running and stopped containers with status, ports, and names
- **container_logs** -- retrieves logs from a specific container with time filtering
- **exec_container** -- runs a command inside a running container
- **inspect_container** -- returns detailed container metadata, environment, and network config
- **compose_up/down** -- manages Docker Compose stacks
- **list_images** -- shows local Docker images with sizes and tags

When Claude investigates a containerized application issue, it calls `list_containers` to see the state of all services, then `container_logs` on the failing service to read the error output. It can then `exec_container` to run diagnostic commands inside the container (checking network connectivity, file permissions, or process state) without you leaving the Claude Code session.

This creates a closed debugging loop: Claude reads the code, checks the container state, reads the logs, makes a code change, rebuilds the container, and verifies the fix -- all within a single conversation.

## Common Issues

**Docker socket permission denied.** The MCP server needs access to `/var/run/docker.sock`. On Linux, the user running Claude Code must be in the `docker` group. On macOS with Docker Desktop, this is handled automatically:

```bash
# Linux: add your user to the docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

**Container names vary between environments.** Docker Compose prefixes container names with the project directory name. Use the `--project-name` flag or set it in `.env` to ensure consistent names:

```yaml
# docker-compose.yml
name: myproject
services:
  api:
    build: .
```

**MCP server cannot see remote Docker hosts.** The Docker MCP server connects to the local Docker daemon by default. For remote hosts, set the `DOCKER_HOST` environment variable in the MCP config:

```json
{
  "env": {
    "DOCKER_HOST": "tcp://remote-host:2376",
    "DOCKER_TLS_VERIFY": "1",
    "DOCKER_CERT_PATH": "/path/to/certs"
  }
}
```

## Example CLAUDE.md Section

```markdown
# Docker MCP Server

## Available Tools
- `list_containers`: Show all containers and status
- `container_logs`: Read container logs (use --since for time filter)
- `exec_container`: Run commands inside containers
- `compose_up`: Start Docker Compose stack
- `compose_down`: Stop Docker Compose stack

## Project Services (docker-compose.yml)
- api: Node.js Express API (port 3000)
- db: PostgreSQL 15 (port 5432)
- redis: Redis 7 (port 6379)
- worker: Background job processor

## Debugging Workflow
1. Check container status: list_containers
2. Read logs from failing service: container_logs
3. Verify networking: exec_container with curl/ping
4. Fix code, rebuild: docker compose up --build api
5. Verify fix via container_logs

## Safety Rules
- NEVER run exec_container on production containers
- ALWAYS use --since flag for logs (avoid massive output)
- Rebuild only the changed service, not the full stack
```

## Best Practices

- **Use the `--since` flag for container logs.** Without time filtering, Claude receives the entire log history which may overflow the context window. Filter to the last 5-10 minutes for debugging.
- **Set a consistent project name** in docker-compose.yml to ensure container names are predictable across environments. Claude needs consistent names to reference containers reliably.
- **Add the Docker MCP to project-level config** (`.mcp.json`) rather than global config. Different projects have different compose stacks and the MCP server should connect to the right Docker context.
- **Document your service architecture in CLAUDE.md.** List each service, its port, its health check endpoint, and common failure patterns so Claude has context before querying containers.
- **Never expose the Docker socket to production MCP servers.** The Docker socket provides root-level access to the host. Use it only in development environments.




**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Desktop config.json guide](/claude-desktop-config-json-guide/) — How to configure Claude Desktop with config.json
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-docker-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)
- [Claude Code Docker Build Failed Fix](/claude-code-docker-build-failed-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
- [How to Use Docker Volumes Persistence (2026)](/claude-code-docker-volumes-persistence-guide/)


## MCP Server Architecture

The Model Context Protocol (MCP) provides a standardized way for Claude Code to interact with external tools and data sources. Understanding the architecture helps diagnose connection issues:

**Transport layer.** MCP servers communicate with Claude Code over stdio (standard input/output) or HTTP. Stdio is the default and most reliable transport. HTTP transport is used for remote servers.

**Initialization handshake.** When Claude Code starts, it spawns each configured MCP server as a child process and waits for the initialization response. If this handshake does not complete within 30 seconds, the connection times out.

**Tool registration.** After initialization, the MCP server declares its available tools (capabilities). Claude Code adds these to its tool catalog. Each registered tool adds approximately 50-100 tokens to the system prompt.

## Debugging MCP Connection Issues

Run this diagnostic sequence to isolate MCP problems:

```bash
# 1. Test the server command directly
npx -y @modelcontextprotocol/server-filesystem /tmp 2>&1 | head -5

# 2. Check if the port is already in use (HTTP transport)
lsof -i :3100 2>/dev/null

# 3. Verify the config file location and syntax
cat ~/.claude/settings.json | python3 -m json.tool

# 4. Check Claude Code's MCP status
claude -p "/mcp" --trust --yes 2>&1
```

If the server starts manually but fails in Claude Code, the issue is usually PATH differences between your shell and the spawned subprocess.
