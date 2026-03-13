---
layout: post
title: "MCP Memory Server: Persistent Storage for Claude"
description: "Set up an MCP memory server for persistent storage across Claude Code sessions. Configuration, implementation examples, and deployment patterns for 2026."
date: 2026-03-13
categories: [mcp, integrations, guides]
tags: [claude-code, mcp, memory, persistent-storage, agents]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

The Model Context Protocol (MCP) enables Claude Code to connect to external servers that expose tools and resources. An MCP memory server provides persistent storage capabilities — so context, notes, and data can survive across multiple Claude Code sessions.

## What Is an MCP Memory Server?

An MCP memory server is a local process that Claude Code connects to via the MCP protocol. It exposes tools like `store_memory`, `retrieve_memory`, and `search_memories` that Claude can call during a session. The data persists in a local file or database, so it is available in future sessions.

This is different from the built-in `/supermemory` skill, which provides memory within Claude Code's own storage. An MCP memory server gives you a custom, programmable memory layer you control.

## Prerequisites

- Node.js 18 or higher installed
- Claude Code configured on your machine
- Basic familiarity with JSON configuration

## Option 1: Use the Official MCP Memory Server

Anthropic's official MCP repository includes a reference memory server implementation. Clone it and follow the README to run it locally:

```bash
git clone https://github.com/modelcontextprotocol/servers
cd servers/src/memory
npm install
npm run build
```

Register it in your `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["/path/to/servers/src/memory/dist/index.js"]
    }
  }
}
```

Restart Claude Code. Claude will now have access to the memory server's tools.

## Option 2: Build a Custom Memory Server

You can build a minimal MCP memory server using the MCP SDK. The official `@modelcontextprotocol/sdk` package is the correct dependency:

```bash
npm install @modelcontextprotocol/sdk better-sqlite3
```

Create `memory-server.js`:

```javascript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import Database from "better-sqlite3";

const db = new Database("memory.db");

db.exec(`
  CREATE TABLE IF NOT EXISTS memories (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  )
`);

const server = new Server(
  { name: "memory-server", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "store_memory",
      description: "Store a key-value memory entry",
      inputSchema: {
        type: "object",
        properties: {
          key: { type: "string" },
          value: { type: "string" }
        },
        required: ["key", "value"]
      }
    },
    {
      name: "retrieve_memory",
      description: "Retrieve a stored memory by key",
      inputSchema: {
        type: "object",
        properties: { key: { type: "string" } },
        required: ["key"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "store_memory") {
    db.prepare("INSERT OR REPLACE INTO memories (key, value) VALUES (?, ?)")
      .run(args.key, args.value);
    return { content: [{ type: "text", text: `Stored: ${args.key}` }] };
  }

  if (name === "retrieve_memory") {
    const row = db.prepare("SELECT value FROM memories WHERE key = ?")
      .get(args.key);
    return {
      content: [{
        type: "text",
        text: row ? row.value : `No memory found for key: ${args.key}`
      }]
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Register it in `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["/absolute/path/to/memory-server.js"]
    }
  }
}
```

## Using the Memory Server in Claude Code

Once configured, Claude can call the memory tools during a session:

```
Store the API endpoint for our production database as a memory

> Claude calls: store_memory("prod_db_endpoint", "https://db.example.com:5432")
```

In a later session:

```
What was the production database endpoint?

> Claude calls: retrieve_memory("prod_db_endpoint")
> Returns: https://db.example.com:5432
```

## Comparison: MCP Memory Server vs /supermemory Skill

| Aspect | MCP Memory Server | /supermemory Skill |
|---|---|---|
| Storage | Custom database (SQLite/PostgreSQL) | Built into Claude Code |
| Access | Via MCP tool calls | Via skill invocation |
| Control | Full control over schema and queries | Managed by the skill |
| Setup | Requires running a server process | Zero setup |

For most developers, the built-in `/supermemory` skill is sufficient. Build a custom MCP memory server when you need custom storage schemas, integration with existing databases, or memory accessible from multiple tools.

## Deployment Tips

Run the memory server as a background process using a process manager like `pm2`:

```bash
npm install -g pm2
pm2 start memory-server.js --name "claude-memory"
pm2 save
pm2 startup
```

This ensures the memory server starts automatically and restarts on failure.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
