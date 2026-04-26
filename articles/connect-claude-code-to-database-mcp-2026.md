---
layout: default
title: "Connect Claude Code to Database via MCP (2026)"
description: "Step-by-step setup for PostgreSQL, Supabase, SQLite, and MySQL MCP servers. Query databases directly from Claude Code. April 2026."
date: 2026-04-26
permalink: /connect-claude-code-to-database-mcp-2026/
categories: [guides, claude-code]
tags: [MCP, database, PostgreSQL, Supabase, SQLite]
last_modified_at: 2026-04-26
---

# Connect Claude Code to Database via MCP (2026)

Connecting Claude Code to your database via MCP transforms how you develop. Instead of writing queries manually, switching to a database client, and copying results back, Claude directly queries your database, inspects schemas, and writes code informed by your actual data structure.

This guide covers setup for the four most common databases: PostgreSQL, Supabase, SQLite, and MySQL. The [MCP Config Generator](/mcp-config/) can build your database config automatically.

## Why Use Database MCP Instead of Shell Commands

Claude Code can already run SQL via shell commands (`psql`, `sqlite3`, `mysql`). Database MCP servers add structured tool access with these advantages:

**Schema awareness.** MCP servers expose your database schema as structured data. Claude sees table names, column types, relationships, and indexes without running discovery queries.

**Safety boundaries.** MCP servers can be configured for read-only access, preventing Claude from accidentally modifying production data.

**Better output parsing.** MCP returns structured JSON results that Claude can reason about directly, rather than parsing text output from command-line tools.

**Connection management.** The MCP server handles connection pooling and reconnection, avoiding the overhead of spawning a new database client for every query.

## PostgreSQL Setup

### Prerequisites
- PostgreSQL running locally or remotely
- Connection string with appropriate permissions

### Configuration

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://username:password@localhost:5432/database_name"
      ],
      "env": {}
    }
  }
}
```

### Using Environment Variables (Recommended)

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "${DATABASE_URL}"
      ],
      "env": {}
    }
  }
}
```

Set `DATABASE_URL` in your shell profile:
```bash
export DATABASE_URL="postgresql://dev:devpass@localhost:5432/myapp_dev"
```

### Available Tools

Once connected, Claude can:
- `query` — Run SELECT statements and return results
- `list_tables` — Show all tables in the database
- `describe_table` — Show columns, types, and constraints for a table

### Read-Only Mode

For production databases, restrict to read-only access:

```bash
# Create a read-only PostgreSQL role
CREATE ROLE claude_readonly LOGIN PASSWORD 'readonly_pass';
GRANT CONNECT ON DATABASE myapp TO claude_readonly;
GRANT USAGE ON SCHEMA public TO claude_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO claude_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO claude_readonly;
```

Use this role in your MCP connection string for production databases.

## Supabase Setup

Supabase provides its own MCP server with additional features beyond raw database access.

### Configuration

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "${SUPABASE_URL}",
        "SUPABASE_SERVICE_KEY": "${SUPABASE_SERVICE_KEY}"
      }
    }
  }
}
```

### Finding Your Credentials

1. Go to your Supabase project dashboard
2. Navigate to Settings then API
3. Copy the Project URL (SUPABASE_URL)
4. Copy the service_role key (SUPABASE_SERVICE_KEY)

**Warning:** The service_role key bypasses Row Level Security. For development this is fine. For production, use an anon key with RLS policies.

### Available Tools

The Supabase MCP server provides:
- Database queries (same as PostgreSQL)
- Auth user management (list, create, delete users)
- Storage operations (list buckets, upload, download)
- Edge function management
- Table and schema management

## SQLite Setup

SQLite is the simplest database MCP to configure because it requires no running server.

### Configuration

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sqlite",
        "--db-path",
        "/absolute/path/to/database.db"
      ],
      "env": {}
    }
  }
}
```

### Important Notes

- Use an absolute path. Relative paths resolve from the working directory, which may vary.
- SQLite locks the database file during writes. If your application is also writing, you may encounter lock contention.
- For read-only access, add `?mode=ro` to the path: `/path/to/database.db?mode=ro`

## MySQL Setup

### Configuration

```json
{
  "mcpServers": {
    "mysql": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-mysql",
        "--host", "localhost",
        "--port", "3306",
        "--user", "dev",
        "--password", "${MYSQL_PASSWORD}",
        "--database", "myapp"
      ],
      "env": {}
    }
  }
}
```

### Connection via URL

Some MySQL MCP servers accept a connection URL:

```json
"args": ["-y", "@modelcontextprotocol/server-mysql", "mysql://user:pass@localhost:3306/myapp"]
```

## Try It Yourself

Configuring database MCP servers means getting connection strings right, managing credentials securely, and ensuring the correct package names and arguments. The [MCP Config Generator](/mcp-config/) handles all of this. Select your database type, enter your connection details, and it generates a correct `mcp.json` with proper environment variable handling and security recommendations.

## Practical Workflows

### Schema-Informed Code Generation

With a database MCP connected, ask Claude to generate code that matches your actual schema:

> "Create a TypeScript API endpoint that returns all orders for a user with their line items"

Claude queries the schema, sees the actual table names and column types, and generates code that matches your database exactly. No guessing column names or relationship types.

### Data-Driven Debugging

When debugging a data issue:

> "User ID abc123 says their order is missing. Check the orders and payments tables."

Claude queries the relevant tables, finds the data, and identifies the issue without you writing a single query.

### Migration Verification

After running a migration:

> "Verify the migration ran correctly. Check that the new columns exist and have the right types."

Claude inspects the schema and confirms the migration state.

## Security Best Practices

1. **Never use production credentials in development config.** Maintain separate MCP configs for dev and prod.
2. **Use read-only roles for production.** Create a database role with SELECT-only permissions.
3. **Keep credentials in environment variables.** Never hardcode passwords in mcp.json.
4. **Audit MCP server source code.** Database credentials pass through the MCP server. Use official or well-audited servers only.
5. **Restrict network access.** If possible, only allow MCP database connections from localhost.

## Related Guides

- [MCP Server Setup Complete Guide](/mcp-server-setup-complete-guide-2026/) — General MCP installation
- [MCP Config JSON Explained](/mcp-config-json-explained-2026/) — Config file reference
- [Supabase MCP Integration Tutorial](/supabase-mcp-claude-code-integration-tutorial/) — Supabase deep dive
- [Claude Code Supabase MCP Setup](/claude-code-supabase-mcp-setup/) — Quick Supabase setup
- [Best MCP Servers for Claude Code](/best-mcp-servers-claude-code-2026/) — Full server ranking
- [MCP Config Generator](/mcp-config/) — Generate database MCP configs

## Frequently Asked Questions

### Can Claude modify my database through MCP?
By default, most database MCP servers allow both read and write operations. To prevent modifications, use a read-only database role or configure the server for read-only mode if the server supports it.

### Does the database MCP server keep a persistent connection?
Yes. The MCP server maintains a connection pool to your database for the duration of the Claude Code session. Connections are closed when the session ends.

### Can I connect to multiple databases simultaneously?
Yes. Add separate MCP server entries for each database. Name them descriptively like "postgres-users" and "postgres-analytics" so Claude knows which database to query for each task.

### Is it safe to connect Claude to a production database?
Only with read-only credentials and proper access controls. Create a dedicated database role with minimal permissions. Never use admin or superuser credentials in MCP configuration.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can Claude modify my database through MCP?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "By default most database MCP servers allow read and write. To prevent modifications use a read-only database role or configure read-only mode if the server supports it."
      }
    },
    {
      "@type": "Question",
      "name": "Does the database MCP server keep a persistent connection?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The MCP server maintains a connection pool for the duration of the Claude Code session. Connections close when the session ends."
      }
    },
    {
      "@type": "Question",
      "name": "Can I connect to multiple databases simultaneously?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Add separate MCP server entries for each database with descriptive names so Claude knows which to query for each task."
      }
    },
    {
      "@type": "Question",
      "name": "Is it safe to connect Claude to a production database?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Only with read-only credentials and proper access controls. Create a dedicated role with minimal permissions. Never use admin credentials in MCP configuration."
      }
    }
  ]
}
</script>
