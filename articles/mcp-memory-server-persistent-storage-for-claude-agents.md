---
layout: post
title: "MCP Memory Server: Persistent Storage for Claude Guide"
description: "Set up the MCP memory server for persistent storage across Claude Code sessions. Configuration, usage, and tips for 2026."
date: 2026-03-13
categories: [guides]
tags: [claude-code, mcp, memory, persistent-storage, agents, server]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# MCP Memory Server: Persistent Storage for Claude Agents

Claude's Model Context Protocol (MCP) includes an official memory server that provides persistent storage across Claude Code sessions. Unlike ephemeral conversation context, the MCP memory server persists data so your agents can maintain long-term context and reference previous interactions. This guide covers setup, configuration, and practical usage.

## What Is the MCP Memory Server

The MCP memory server is one of Anthropic's reference server implementations, maintained at [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers). It exposes a set of memory management tools — `create_entities`, `add_observations`, `search_nodes`, `delete_entities`, and others — that Claude can call during a session to read and write a persistent knowledge graph stored locally as JSON.

Each entity in the memory graph has a name, entity type, and a set of observations (plain-text facts). Relations between entities can be created too, making it possible to build a structured knowledge base that persists between sessions.

## Prerequisites

- Node.js 18 or higher
- Claude Code configured on your machine (`claude --version`)
- `npx` available (included with Node.js)

## Installing the MCP Memory Server

The official memory server is distributed via npm. The recommended way to run it is with `npx`, so Claude Code spawns it on demand:

```bash
# No install needed — npx pulls it at runtime
# To install globally if preferred:
npm install -g @modelcontextprotocol/server-memory
```

The server stores its memory graph in a JSON file at a path you specify (defaults to a temp location). To use a stable path, create a directory first:

```bash
mkdir -p ~/.claude/memory
```

## Connecting Claude Code to the Memory Server

Add the server to `~/.claude/settings.json` under `mcpServers`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "MEMORY_FILE_PATH": "/Users/yourname/.claude/memory/memory.json"
      }
    }
  }
}
```

Replace `/Users/yourname` with your actual home directory path. Restart Claude Code after saving — the memory server will start automatically when Claude Code launches.

## Verifying the Connection

After restarting, start a Claude Code session and ask:

```
What MCP tools do you have available?
```

Claude should list the memory tools: `create_entities`, `add_observations`, `search_nodes`, `open_nodes`, `read_graph`, `delete_entities`, `delete_observations`, `delete_relations`, `create_relations`.

## Using Memory in Claude Sessions

Once connected, you can ask Claude to store and retrieve information in plain English. Claude calls the underlying memory tools automatically.

### Storing Context

```
Remember that this project uses PostgreSQL 16, runs on port 5432,
and the main schema is in db/schema.sql. Store this as a project entity.
```

Claude calls `create_entities` to store a "project" entity with those observations.

### Retrieving Context

In a future session:

```
What do you know about this project's database setup?
```

Claude calls `search_nodes` with a relevant query and returns what it stored.

### Building Structured Knowledge

```
Create an entity for "UserService" of type "service".
Add observations: "handles authentication", "uses JWT tokens",
"depends on PostgreSQL users table".
```

You can then create relations:

```
Create a relation: UserService "depends_on" PostgreSQL.
```

### Reading the Full Graph

```
Show me everything you have stored in memory.
```

Claude calls `read_graph` and returns all entities and relations.

## Integrating Memory with Claude Skills

The memory server complements Claude skills naturally. Use it alongside [`/supermemory`](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/), `/tdd`, and other skills to build persistent workflows:

**With [`/tdd`](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/):** After writing tests, ask Claude to store a summary of what was tested:

```
/tdd Write tests for the payment module.
When done, store a memory entity "PaymentModule" with an observation
summarizing what tests were written and what edge cases were covered.
```

**With `/supermemory`:** The `/supermemory` skill manages memory through the Supermemory cloud API. The MCP memory server is a local alternative — choose one or the other based on whether you want local-only or cloud-accessible memory.

**Automatic context loading:** Add an instruction to your `CLAUDE.md` to load memory at session start:

```markdown
## Memory
At the start of each session, call read_graph to load project context
from the MCP memory server.
```

## Practical Tips

**Use descriptive entity names.** Generic names like `project` become confusing across projects. Prefer `MyApp-AuthService` or `MyApp-DeploymentConfig`.

**Prune stale entries.** The memory graph grows over time. Periodically review it:

```
Show me all entities in memory. Delete any that are outdated or no longer relevant.
```

**Scope to one project per memory file.** If you work on multiple projects, use different `MEMORY_FILE_PATH` values per project by configuring MCP servers in project-level `.claude/settings.json` files rather than the global one.

**Back up the memory file.** The JSON file at `MEMORY_FILE_PATH` is the entire memory store. Add it to your backup routine or commit it to your repository if the project is team-shared.

## Production Considerations

The official MCP memory server uses a local JSON file. For multi-user or multi-machine scenarios, this is a limitation — the file does not sync automatically across machines.

For teams that need shared persistent memory, the options are:

- Use the `/supermemory` skill with Supermemory's cloud API, which is designed for team access
- Build a custom MCP server using the `@modelcontextprotocol/sdk` that writes to a shared database (PostgreSQL, Redis) and exposes the same memory tool interfaces

The MCP SDK documentation at [modelcontextprotocol.io](https://modelcontextprotocol.io) covers building custom servers with the `Server` class from `@modelcontextprotocol/sdk/server/index.js`.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Covers the supermemory skill and other memory-related capabilities that complement the MCP memory server
- [MCP Servers vs Claude Skills: What Is the Difference?](/claude-skills-guide/articles/mcp-servers-vs-claude-skills-what-is-the-difference/) — Explains how MCP servers and Claude skills relate and when to use each
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Persistent memory via MCP servers reduces repeated context loading; this article explains token savings strategies

Built by theluckystrike — More at [zovo.one](https://zovo.one)
