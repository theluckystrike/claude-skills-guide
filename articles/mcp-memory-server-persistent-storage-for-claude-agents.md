---
layout: default
title: "MCP Memory Server: Persistent Storage for Claude (2026)"
description: "Set up the MCP memory server for persistent storage across Claude Code sessions. Configuration, usage, and tips for 2026."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-skills, claude-code, mcp, memory, persistent-storage, agents, server]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /mcp-memory-server-persistent-storage-for-claude-agents/
geo_optimized: true
---

# MCP Memory Server: Persistent Storage for Claude Agents

Claude's Model Context Protocol (MCP) includes an official memory server that provides persistent storage across Claude Code sessions. Unlike ephemeral conversation context, the MCP memory server persists data so your agents can maintain long-term context and reference previous interactions. This guide covers setup, configuration, and practical usage patterns for solo developers and teams alike.

## What Is the MCP Memory Server

The MCP memory server is one of Anthropic's reference server implementations, maintained at [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers). It exposes a set of memory management tools. `create_entities`, `add_observations`, `search_nodes`, `delete_entities`, and others. that Claude can call during a session to read and write a persistent knowledge graph stored locally as JSON.

Each entity in the memory graph has a name, entity type, and a set of observations (plain-text facts). Relations between entities can be created too, making it possible to build a structured knowledge base that persists between sessions.

The memory server solves a real problem: Claude Code sessions are stateless by default. Every time you start a new session, Claude has no recollection of decisions made, architecture choices, or context accumulated in previous sessions. The MCP memory server bridges that gap by giving Claude a stable, queryable store it can read from and write to across any number of sessions.

## How the Knowledge Graph Works

Understanding the data model helps you use the memory server more effectively. The memory graph has three core concepts:

Entities are named nodes with a type. An entity is a service, a person, a configuration, a decision, or anything else you want to track. Every entity has a unique name within the graph.

Observations are plain-text facts attached to an entity. You can add as many observations as you want to a single entity over time. Each observation is a string. think of it as a bullet point in a knowledge base article about that entity.

Relations connect two entities with a named relationship. For example, `UserService "depends_on" PostgreSQL` or `AuthModule "owned_by" BackendTeam`. Relations make it possible to query the graph for connected context, not just isolated facts.

Here is what the raw JSON looks like inside the memory file for a simple two-entity graph:

```json
{
 "entities": [
 {
 "name": "MyApp-Auth",
 "entityType": "service",
 "observations": [
 "handles JWT authentication",
 "tokens expire after 24 hours",
 "refresh tokens stored in Redis"
 ]
 },
 {
 "name": "MyApp-Database",
 "entityType": "infrastructure",
 "observations": [
 "PostgreSQL 16",
 "runs on port 5432",
 "schema at db/schema.sql"
 ]
 }
 ],
 "relations": [
 {
 "from": "MyApp-Auth",
 "to": "MyApp-Database",
 "relationType": "depends_on"
 }
 ]
}
```

This flat JSON structure is human-readable, easy to back up, and simple to inspect when you need to audit what Claude has stored.

## Prerequisites

- Node.js 18 or higher
- Claude Code configured on your machine (`claude --version`)
- `npx` available (included with Node.js)

## Installing the MCP Memory Server

The official memory server is distributed via npm. The recommended way to run it is with `npx`, so Claude Code spawns it on demand:

```bash
No install needed. npx pulls it at runtime
To install globally if preferred:
npm install -g @modelcontextprotocol/server-memory
```

The server stores its memory graph in a JSON file at a path you specify (defaults to a temp location). To use a stable path, create a directory first:

```bash
mkdir -p ~/.claude/memory
```

If you work on multiple projects and want separate memory stores for each, create project-specific directories:

```bash
mkdir -p ~/.claude/memory/myapp
mkdir -p ~/.claude/memory/other-project
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

Replace `/Users/yourname` with your actual home directory path. Restart Claude Code after saving. the memory server will start automatically when Claude Code launches.

## Project-Level Configuration

For project-specific memory, create a `.claude/settings.json` in the project root instead of (or in addition to) the global config. This scopes the memory file to that project:

```json
{
 "mcpServers": {
 "memory": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-memory"],
 "env": {
 "MEMORY_FILE_PATH": "/Users/yourname/projects/myapp/.claude/memory.json"
 }
 }
 }
}
```

Claude Code merges project-level and global settings, with project-level taking precedence for conflicting keys.

## Verifying the Connection

After restarting, start a Claude Code session and ask:

```
What MCP tools do you have available?
```

Claude should list the memory tools: `create_entities`, `add_observations`, `search_nodes`, `open_nodes`, `read_graph`, `delete_entities`, `delete_observations`, `delete_relations`, `create_relations`.

If the tools are not listed, check:
1. The `settings.json` path. it must be valid JSON with no trailing commas
2. The `MEMORY_FILE_PATH` directory exists and is writable
3. `npx` resolves correctly in your shell (`which npx`)
4. Claude Code was fully restarted (not just a new tab in the same session)

## Complete MCP Memory Tool Reference

The memory server exposes nine tools. Knowing what each does helps you give Claude precise instructions:

| Tool | Purpose |
|------|---------|
| `create_entities` | Create one or more new entities with a type and initial observations |
| `add_observations` | Append new observations to existing entities |
| `search_nodes` | Search entities and observations by a text query |
| `open_nodes` | Retrieve specific entities by name |
| `read_graph` | Return the entire memory graph (all entities and relations) |
| `create_relations` | Add a directional relation between two entities |
| `delete_entities` | Remove entities (and their associated relations) by name |
| `delete_observations` | Remove specific observations from an entity |
| `delete_relations` | Remove specific relations between entities |

## Using Memory in Claude Sessions

Once connected, you can ask Claude to store and retrieve information in plain English. Claude calls the underlying memory tools automatically.

## Storing Context

```
Remember that this project uses PostgreSQL 16, runs on port 5432,
and the main schema is in db/schema.sql. Store this as a project entity.
```

Claude calls `create_entities` to store a "project" entity with those observations.

## Retrieving Context

In a future session:

```
What do you know about this project's database setup?
```

Claude calls `search_nodes` with a relevant query and returns what it stored.

## Building Structured Knowledge

```
Create an entity for "UserService" of type "service".
Add observations: "handles authentication", "uses JWT tokens",
"depends on PostgreSQL users table".
```

You can then create relations:

```
Create a relation: UserService "depends_on" PostgreSQL.
```

## Reading the Full Graph

```
Show me everything you have stored in memory.
```

Claude calls `read_graph` and returns all entities and relations.

## Updating Existing Entities

To add new information to an entity you've already stored:

```
Add an observation to MyApp-Auth: "added rate limiting in March 2026,
using the express-rate-limit package".
```

This appends to the entity without overwriting existing observations. Observations are cumulative, so the entity builds up a history over time.

## Cleaning Up Outdated Facts

When a fact becomes stale, you can remove specific observations rather than deleting the whole entity:

```
From MyApp-Auth, delete the observation about tokens expiring after 24 hours.
Add a new observation: "tokens now expire after 7 days, updated March 2026".
```

## Practical Usage Patterns

## Session Startup Routine

The most reliable way to use memory is to make context loading explicit at the start of every session. Add a CLAUDE.md instruction:

```markdown
Session Startup
At the start of each session, call read_graph to load all stored project context.
Summarize what you found before proceeding with any task.
```

This ensures Claude has full project context before answering questions or writing code, without you having to ask for it every time.

## Decision Log Pattern

One of the most valuable uses of the memory server is recording architectural decisions and the reasoning behind them:

```
Store a new entity "Decision-AuthStrategy" of type "decision".
Observations:
- "Chose JWT over session cookies on 2026-03-01"
- "Reason: stateless API needed for mobile clients"
- "Revisit if server-side session management becomes necessary"
```

Future sessions can query this to understand why the current approach was chosen, preventing the common pattern of re-litigating past decisions.

## Sprint/Milestone Tracking

```
Create entity "Sprint-14" of type "milestone".
Add observations:
- "Goal: complete payment integration"
- "Started 2026-03-10"
- "Blocked by: Stripe webhook signature verification issue"
```

Then update it as work progresses:

```
Add observation to Sprint-14: "Stripe issue resolved 2026-03-12,
fix was to use raw request body not parsed JSON".
```

## Dependency Map

For complex projects with many services, build a dependency map in the memory graph:

```
Create entities:
- "APIGateway" type "service"
- "AuthService" type "service"
- "PaymentService" type "service"
- "UserDB" type "database"

Create relations:
- APIGateway routes_to AuthService
- APIGateway routes_to PaymentService
- AuthService reads_from UserDB
- PaymentService reads_from UserDB
```

You can then ask: "What services depend on UserDB?" and Claude will traverse the graph to answer.

## Integrating Memory with Claude Skills

The memory server complements Claude skills naturally. Use it alongside [`/supermemory`](/claude-skills-token-optimization-reduce-api-costs/), `/tdd`, and other skills to build persistent workflows:

With [`/tdd`](/best-claude-skills-for-developers-2026/): After writing tests, ask Claude to store a summary of what was tested:

```
/tdd Write tests for the payment module.
When done, store a memory entity "PaymentModule" with an observation
summarizing what tests were written and what edge cases were covered.
```

With `/supermemory`: The `/supermemory` skill manages memory through the Supermemory cloud API. The MCP memory server is a local alternative. choose one or the other based on whether you want local-only or cloud-accessible memory.

Automatic context loading: Add an instruction to your `CLAUDE.md` to load memory at session start:

```markdown
Memory
At the start of each session, call read_graph to load project context
from the MCP memory server.
```

## MCP Memory Server vs Alternative Approaches

Before committing to the MCP memory server, it helps to understand how it compares to other persistence strategies:

| Approach | Persistence | Team Access | Searchable | Setup Complexity |
|----------|------------|-------------|------------|-----------------|
| MCP memory server | Yes (local JSON) | Single machine | Yes (semantic) | Low |
| CLAUDE.md file | Yes (committed) | Yes (git) | Manual | Minimal |
| Supermemory API | Yes (cloud) | Yes (shared) | Yes | Medium |
| Custom MCP + DB | Yes (database) | Yes | Yes | High |
| Pasting context manually | No | N/A | No | None |

The MCP memory server is the right choice when you want structured, queryable memory that persists across sessions on a single machine with minimal setup. For team environments or multi-machine access, a cloud solution or custom MCP server with a shared database backend is more appropriate.

## Practical Tips

Use descriptive entity names. Generic names like `project` become confusing across projects. Prefer `MyApp-AuthService` or `MyApp-DeploymentConfig`.

Prune stale entries. The memory graph grows over time. Periodically review it:

```
Show me all entities in memory. Delete any that are outdated or no longer relevant.
```

Scope to one project per memory file. If you work on multiple projects, use different `MEMORY_FILE_PATH` values per project by configuring MCP servers in project-level `.claude/settings.json` files rather than the global one.

Back up the memory file. The JSON file at `MEMORY_FILE_PATH` is the entire memory store. Add it to your backup routine or commit it to your repository if the project is team-shared.

Use entity types consistently. Decide on a fixed vocabulary for entity types. for example always using `service`, `database`, `decision`, `person`, `milestone`, `config`. so that searches and graph traversals return predictable results.

Add dates to observations. Since observations are plain text, timestamping them manually helps you track when things changed: `"Migrated from MySQL to PostgreSQL on 2026-02-15"`. This turns the memory graph into a lightweight changelog.

## Production Considerations

The official MCP memory server uses a local JSON file. For multi-user or multi-machine scenarios, this is a limitation. the file does not sync automatically across machines.

For teams that need shared persistent memory, the options are:

- Use the `/supermemory` skill with Supermemory's cloud API, which is designed for team access
- Build a custom MCP server using the `@modelcontextprotocol/sdk` that writes to a shared database (PostgreSQL, Redis) and exposes the same memory tool interfaces

The MCP SDK documentation at [modelcontextprotocol.io](https://modelcontextprotocol.io) covers building custom servers with the `Server` class from `@modelcontextprotocol/sdk/server/index.js`.

A minimal custom server that wraps a PostgreSQL table instead of a JSON file follows the same `Server` + `CallToolRequestSchema` pattern as the reference implementation, with `pg` queries replacing the file I/O. Teams with existing PostgreSQL infrastructure can often wire this up in an afternoon and get a centrally shared memory store that all developers and CI agents can read from.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=mcp-memory-server-persistent-storage-for-claude-agents)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Covers the supermemory skill and other memory-related capabilities that complement the MCP memory server
- [MCP Servers vs Claude Skills: What Is the Difference?](/mcp-servers-vs-claude-skills-what-is-the-difference/). Explains how MCP servers and Claude skills relate and when to use each
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Persistent memory via MCP servers reduces repeated context loading; this article explains token savings strategies
- [Fix Claude Code MCP Server Connection Closed](/claude-code-mcp-server-connection-closed-fix/)
- [Fix GitHub MCP Auth Server Registration Error](/claude-code-github-mcp-error-incompatible-auth-server-does-not-support-dynamic-client-registration/)
- [Zoom MCP Server Meeting Summary Automation](/zoom-mcp-server-meeting-summary-automation/)
- [Fix Skill Conflicts with MCP Servers in Claude Code — 2026](/fix-skill-conflicts-with-mcp-server/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


