---
layout: default
title: "Claude Code Supabase MCP Setup Guide (2026)"
description: "Connect Claude Code to Supabase via MCP for direct database queries, auth management, and schema operations from your editor."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-supabase-mcp-setup/
categories: [guides]
tags: [claude-code, claude-skills, supabase, mcp]
reviewed: true
score: 7
geo_optimized: true
---

Connecting Claude Code to Supabase through MCP lets you query tables, manage auth, and modify schemas directly from your development workflow. This guide covers the complete setup from installation to your first database query.

## The Problem

Switching between Claude Code and the Supabase dashboard breaks your flow. You copy-paste connection strings, manually run SQL in the dashboard, and lose context every time you switch windows. Without MCP, Claude Code cannot directly interact with your Supabase project -- it can only generate SQL that you execute elsewhere.

## Quick Solution

**Step 1: Install the Supabase MCP server**

```bash
npm install -g @supabase/mcp-server
```

**Step 2: Get your Supabase credentials**

From the Supabase dashboard, go to Project Settings > API. Copy your project URL and service role key.

**Step 3: Configure MCP in your project**

Create or edit `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://your-project-id.supabase.co",
        "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key-here"
      }
    }
  }
}
```

**Step 4: Restart Claude Code**

```bash
claude
```

Claude Code will detect the MCP configuration and connect to Supabase on startup. You should see the Supabase tools listed when Claude initializes.

**Step 5: Test the connection**

Ask Claude Code to list your tables:

```text
> List all tables in my Supabase database
```

Claude Code will use the MCP tools to query your database schema directly.

## How It Works

MCP (Model Context Protocol) is Claude Code's extension system for connecting to external services. When you configure an MCP server, Claude Code spawns it as a child process and communicates via stdio. The Supabase MCP server wraps the Supabase Management API and PostgREST, giving Claude Code tools like `list_tables`, `execute_sql`, and `get_project_info`.

The service role key bypasses Row Level Security, so Claude Code can read and write all tables without auth restrictions. This makes it powerful for development but dangerous for production data. The MCP server runs locally -- your credentials never leave your machine except to authenticate with Supabase's API.

## Common Issues

**"MCP server disconnected" immediately after startup**
The Supabase URL or key is wrong. Verify by running a direct curl:

```bash
curl -H "apikey: YOUR_KEY" -H "Authorization: Bearer YOUR_KEY" \
  https://your-project-id.supabase.co/rest/v1/
```

If this returns a JSON array, your credentials are valid. If it returns 401, regenerate the service role key in the Supabase dashboard.

**MCP tools not appearing in Claude Code**
Check that `.claude/mcp.json` is in your project root (not `~/.claude/`). Project-level MCP configs must be at the workspace level. Run `claude mcp list` to verify the server is detected.

**Slow responses on large tables**
The MCP server fetches data through the REST API, which paginates at 1000 rows. For large datasets, tell Claude Code to use specific SQL queries with `LIMIT` clauses rather than full table scans.

## Example CLAUDE.md Section

```markdown
# Supabase Project Context

## Database
- Supabase MCP is configured in .claude/mcp.json
- Database: PostgreSQL 15 on Supabase
- Key tables: users, orders, products, reviews
- RLS is enabled on all tables (MCP uses service role)

## Rules
- NEVER drop tables without explicit confirmation
- Always use parameterized queries to prevent injection
- Run SELECT queries before UPDATE/DELETE to preview affected rows
- Keep migrations in /supabase/migrations/ using Supabase CLI format
- Test schema changes on the staging project first

## Auth
- Using Supabase Auth with email/password and Google OAuth
- JWT tokens stored in httpOnly cookies
- Auth helpers in /src/lib/supabase.ts

## Useful Commands
- Local dev: `supabase start`
- Generate types: `supabase gen types typescript --local > src/types/database.ts`
- Push migrations: `supabase db push`
```

## Best Practices

1. **Use project-level MCP config** -- Keep `.claude/mcp.json` in your repo root (gitignored) so the Supabase connection activates automatically when you open the project.

2. **Never commit the service role key** -- Add `.claude/` to your `.gitignore`. The service role key has full database access and should never appear in version control.

3. **Regenerate types after schema changes** -- After Claude Code modifies your schema, run `supabase gen types typescript` to keep your TypeScript types in sync.

4. **Use staging for destructive operations** -- Configure a separate Supabase project for development and point the MCP server there. Reserve production credentials for deployment only.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-supabase-mcp-setup)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
