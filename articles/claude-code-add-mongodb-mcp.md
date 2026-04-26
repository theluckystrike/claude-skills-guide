---
layout: default
title: "Add MongoDB MCP to Claude Code (2026)"
description: "Connect Claude Code to MongoDB via MCP for direct collection queries, schema inspection, and aggregation pipeline building."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-add-mongodb-mcp/
categories: [guides]
tags: [claude-code, claude-skills, mongodb, mcp]
reviewed: true
score: 6
geo_optimized: true
---

Adding MongoDB MCP to Claude Code lets you query collections, inspect schemas, and build aggregation pipelines directly from your editor. This guide covers the full setup using the official MongoDB MCP server, from connection string to your first query.

## The Problem

Without database access, Claude Code generates MongoDB queries blind. It guesses collection names, assumes field types, and builds aggregation pipelines that fail against your actual schema. You end up copying collection structures into prompts manually, which wastes context window tokens and goes stale as your schema evolves.

## Quick Solution

**Step 1: Install the MongoDB MCP server**

```bash
npm install -g mongodb-mcp-server
```

**Step 2: Get your MongoDB connection string**

For MongoDB Atlas, find it in the Atlas dashboard under Database > Connect > Drivers. It looks like:

```text
mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/mydb
```

For local MongoDB:

```text
mongodb://localhost:27017/mydb
```

**Step 3: Configure MCP in your project**

Create `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": [
        "-y",
        "mongodb-mcp-server",
        "--connectionString",
        "mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/mydb"
      ]
    }
  }
}
```

**Step 4: Restart Claude Code and verify**

```bash
claude
```

Test the connection:

```text
> List all collections in my MongoDB database
```

Claude Code will use MCP tools to connect and return your collection list.

## How It Works

The MongoDB MCP server connects to your database using the official Node.js driver and exposes tools through MCP's stdio protocol. Claude Code can call tools like `find`, `aggregate`, `listCollections`, and `collectionSchema` to inspect and query your data.

When you ask Claude Code to build a query, it first uses `collectionSchema` to sample documents and infer the schema. Then it constructs queries that match your actual field names and types. Aggregation pipelines are built with knowledge of your indexes, which means Claude Code can suggest `$match` stages that use indexed fields for performance.

The MCP server runs locally on your machine. Your connection string stays local -- queries go directly from your machine to MongoDB, not through Anthropic's servers.

## Common Issues

**"Authentication failed" when connecting to Atlas**
Ensure your IP address is whitelisted in Atlas under Network Access. Also verify the username and password in your connection string are URL-encoded -- special characters like `@` or `#` in passwords must be percent-encoded (e.g., `%40` for `@`).

**MCP server crashes on large collections**
The schema inference tool samples documents, but some operations may attempt to fetch too much data. Add a `--maxDocuments` flag if supported, or instruct Claude Code in CLAUDE.md to always use `LIMIT` when querying large collections.

**"MCP server disconnected" after idle period**
MongoDB connections time out after a period of inactivity. Restart Claude Code to re-establish the connection. For Atlas, ensure your cluster is not paused (free-tier clusters pause after inactivity).

## Example CLAUDE.md Section

```markdown
# MongoDB Project Configuration

## Database
- MongoDB Atlas cluster (M10, AWS us-east-1)
- MCP configured in .claude/mcp.json
- Primary database: myapp_production
- Read preference: secondaryPreferred for analytics queries

## Collections
- users — indexed on email (unique), createdAt
- orders — indexed on userId, status, createdAt
- products — indexed on sku (unique), category
- sessions — TTL index on expiresAt (24h)

## Rules
- NEVER run delete or drop operations without explicit confirmation
- Always use projection to limit returned fields
- Aggregation pipelines must use $match as first stage
- Prefer $lookup over multiple queries for joins
- All queries should include .explain() during development

## Mongoose Models
- Located in /src/models/
- Validation schemas mirror MongoDB validation rules
- Always update both Mongoose schema and MongoDB validation together

## Commands
- Start local: `mongosh mongodb://localhost:27017/myapp`
- Seed data: `npm run db:seed`
- Migrate: `npm run db:migrate`
```

## Best Practices

1. **Use a read-only database user for MCP** -- Create a dedicated MongoDB user with `readAnyDatabase` role. This prevents accidental data mutations while still giving Claude Code full schema visibility.

2. **Document your indexes in CLAUDE.md** -- Claude Code cannot always detect indexes through MCP. Listing them explicitly helps it generate queries that use indexed fields.

3. **Keep connection strings out of git** -- Add `.claude/` to `.gitignore`. For team setups, document the MCP config structure in your README but use environment-specific credentials.

4. **Prefer aggregation pipelines over multiple queries** -- When Claude Code has MCP access, it can build complex `$lookup` + `$unwind` + `$group` pipelines that are far more efficient than fetching data in multiple round trips.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-add-mongodb-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code for MongoDB Atlas Search Workflow](/claude-code-for-mongodb-atlas-search-workflow/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

