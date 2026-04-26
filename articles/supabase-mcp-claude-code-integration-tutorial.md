---
layout: default
title: "Supabase MCP for Claude Code: Full Integration (2026)"
description: "Complete tutorial for connecting Supabase to Claude Code via MCP. Configure auth, run queries, inspect schemas, and build features with real terminal examples."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /supabase-mcp-claude-code-integration-tutorial/
reviewed: true
categories: [tutorials]
tags: [claude, claude-code, mcp, supabase, database, integration, tutorial]
---

# Supabase MCP for Claude Code: Full Integration (2026)

The Supabase MCP server connects Claude Code directly to your Supabase project — tables, auth, storage, and edge functions. Instead of switching between the Supabase dashboard and your editor, you query data, inspect schemas, and debug issues from a single terminal session. This tutorial covers the full setup: generating your access token, configuring the MCP server, running your first query, and building a feature end-to-end. Generate the configuration file instantly with the [MCP Config Generator](/mcp-config/).

## Prerequisites

Before starting, you need:

- Claude Code installed (`npm install -g @anthropic-ai/claude-code`)
- A Supabase project (free tier works)
- Node.js 18 or newer

## Step 1: Generate Your Supabase Access Token

Go to [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens) and create a new access token. This token grants API access to all projects in your account.

```bash
# Save the token — you will only see it once
# Format: sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

For project-specific access, you can also use the project's `service_role` key from Settings > API. The access token is preferred because it works across multiple projects.

## Step 2: Configure the MCP Server

Create or update your MCP configuration. You can do this manually or use the [MCP Config Generator](/mcp-config/) to produce the config automatically.

**Manual configuration:**

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "sbp_your_token_here"
      }
    }
  }
}
```

Save this to `~/.claude/mcp-servers.json` for global access, or `.claude/mcp-servers.json` for project-level access.

## Step 3: Restart and Verify

```bash
# Start a new Claude Code session
claude

# Check the MCP server status
/mcp
```

You should see `supabase` listed with status `connected`. If it shows `disconnected`, check the troubleshooting section below.

## Step 4: Run Your First Queries

With the Supabase MCP server connected, Claude can interact with your database directly:

```
# List all tables in your project
"Show me all tables in the zovo-production project"

# Inspect a specific table schema
"What columns does the users table have?"

# Run a query
"How many users signed up in the last 7 days?"

# Check auth users
"List the 10 most recent auth users with their email addresses"
```

Each query goes through the MCP server, which translates it into the appropriate Supabase API call. Results come back formatted in your terminal.

## Building a Feature with Supabase MCP

Here is a real workflow — adding a "user activity log" feature using Claude Code with the Supabase MCP server:

### 1. Explore the existing schema

```
"Show me the current database schema for the users and sessions tables"
```

Claude queries the Supabase MCP server and returns column names, types, and relationships.

### 2. Create the migration

```
"Create a new table called activity_log with columns: id (uuid), user_id (uuid, FK to auth.users),
action (text), metadata (jsonb), created_at (timestamptz). Add an index on user_id and created_at."
```

Claude generates the SQL migration:

```sql
CREATE TABLE public.activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_activity_log_user_created
  ON public.activity_log (user_id, created_at DESC);

ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own activity" ON public.activity_log
  FOR SELECT USING (auth.uid() = user_id);
```

### 3. Apply and verify

```
"Run this migration on the development project and verify the table was created"
```

Claude executes the migration through the MCP server and confirms the table exists with the correct schema.

### 4. Write the application code

```
"Now write a TypeScript function to log user activity, using the Supabase client library"
```

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);

interface ActivityEntry {
  action: string;
  metadata?: Record<string, unknown>;
}

export async function logActivity(
  userId: string,
  entry: ActivityEntry
): Promise<void> {
  const { error } = await supabase
    .from('activity_log')
    .insert({
      user_id: userId,
      action: entry.action,
      metadata: entry.metadata ?? {},
    });

  if (error) {
    throw new Error(`Failed to log activity: ${error.message}`);
  }
}
```

### 5. Test with real data

```
"Insert a test activity entry for user abc-123 with action 'login' and then query to confirm it exists"
```

Claude uses the MCP server to insert the test row and immediately query it back, confirming the full flow works.

## Troubleshooting

### "disconnected" status after restart

```bash
# Verify the npm package is accessible
npx -y @supabase/mcp-server --help

# Check your token is valid
curl -H "Authorization: Bearer sbp_your_token" https://api.supabase.com/v1/projects
```

### Permission errors on queries

Your access token needs sufficient permissions. The account-level token has full access. If using a `service_role` key, it bypasses RLS but is limited to one project.

### Slow responses

The first query after connecting may take 3-5 seconds as the MCP server initializes. Subsequent queries are typically under 1 second.

## Try It Yourself

Generate a working Supabase MCP configuration with the [MCP Config Generator](/mcp-config/). Select Supabase from the server list, paste your access token, and get a ready-to-use config file.

<details>
<summary>Does the Supabase MCP server support all Supabase features?</summary>
The MCP server supports database queries, schema inspection, auth user management, and storage operations. Edge functions and realtime subscriptions are not directly supported through MCP — use the Supabase CLI for those.
</details>

<details>
<summary>Is my data safe when using the Supabase MCP server?</summary>
The MCP server runs locally on your machine. Database queries go directly from your machine to Supabase's API. Your access token is stored in your local config file — never share your mcp-servers.json file publicly.
</details>

<details>
<summary>Can I connect to multiple Supabase projects?</summary>
Yes. Your access token works across all projects in your account. Specify the project when making queries, or configure separate MCP server entries with project-specific service_role keys.
</details>

<details>
<summary>What is the difference between the access token and the service_role key?</summary>
The access token authenticates at the account level and works across all projects. The service_role key is project-specific and bypasses Row Level Security. Use the access token for development workflows and the service_role key only when you need RLS bypass.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does the Supabase MCP server support all Supabase features?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The MCP server supports database queries, schema inspection, auth user management, and storage operations. Edge functions and realtime subscriptions are not directly supported through MCP — use the Supabase CLI for those."
      }
    },
    {
      "@type": "Question",
      "name": "Is my data safe when using the Supabase MCP server?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The MCP server runs locally on your machine. Database queries go directly from your machine to Supabase's API. Your access token is stored in your local config file — never share your mcp-servers.json file publicly."
      }
    },
    {
      "@type": "Question",
      "name": "Can I connect to multiple Supabase projects?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Your access token works across all projects in your account. Specify the project when making queries, or configure separate MCP server entries with project-specific service_role keys."
      }
    },
    {
      "@type": "Question",
      "name": "What is the difference between the access token and the service_role key?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The access token authenticates at the account level and works across all projects. The service_role key is project-specific and bypasses Row Level Security. Use the access token for development workflows and the service_role key only when you need RLS bypass."
      }
    }
  ]
}
</script>

## Related Guides

- [MCP Config Generator](/mcp-config/) — Generate MCP configurations instantly
- [Claude Code Configuration Guide](/configuration/) — Full settings and preferences reference
- [Command Reference](/commands/) — Every Claude Code command explained
- [Getting Started with Claude Code](/starter/) — First-time setup guide
- [Permissions and Security](/permissions/) — Control tool access and permissions
