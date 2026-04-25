---
layout: default
title: "Claude Code + Supabase MCP: Setup Guide (2026)"
description: "Step-by-step Supabase MCP server setup for Claude Code. Schema inspection, SQL queries, RLS policies, edge functions, and a real project example."
permalink: /claude-code-mcp-supabase-setup-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Code + Supabase MCP: Setup Guide (2026)

The Supabase MCP server connects Claude Code directly to your Supabase project. Instead of switching between Claude Code and the Supabase dashboard, Claude can inspect your database schema, run SQL queries, manage RLS policies, and handle migrations without leaving the terminal.

This guide walks through setup, configuration, available tools, and a real-world project example showing how to use Claude Code with Supabase MCP in practice.

## What the Supabase MCP Server Provides

When connected, Claude Code gains these capabilities:

- **Schema inspection**: Read table definitions, column types, constraints, indexes, and relationships
- **SQL queries**: Run SELECT, INSERT, UPDATE, DELETE queries against your database
- **Migration management**: Create and apply database migrations
- **RLS policy management**: Inspect and create Row Level Security policies
- **Function management**: View and create PostgreSQL functions and triggers
- **Type generation**: Generate TypeScript types from your schema
- **Seed data**: Create and insert test data

Without MCP, Claude Code can only interact with Supabase through the CLI or API calls. MCP gives it direct, structured access.

## Prerequisites

Before setting up:

1. **Supabase project**: An existing project at supabase.com
2. **Claude Code**: Installed and authenticated ([setup guide](/how-to-use-claude-code-beginner-guide/))
3. **Supabase CLI**: Installed locally
4. **Node.js 18+**: Required for the MCP server
5. **Project reference ID**: Found in your Supabase project settings under "General"

### Getting Your Supabase Credentials

You need two values:

1. **Project URL**: `https://your-project-ref.supabase.co`
2. **Service Role Key**: Found in Project Settings > API > Project API keys > `service_role`

The service role key bypasses Row Level Security. Use it for development. For production environments, use the `anon` key with appropriate RLS policies.

## Step 1: Install the Supabase MCP Server

The Supabase MCP server is available as an npm package:

```bash
npm install -g @supabase/mcp-server-supabase
```

Verify the installation:

```bash
npx @supabase/mcp-server-supabase --help
```

## Step 2: Configure Claude Code

Add the Supabase MCP server to your Claude Code MCP configuration. Edit or create `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server-supabase",
        "--url", "https://your-project-ref.supabase.co",
        "--service-role-key", "eyJhbGciOiJI..."
      ]
    }
  }
}
```

### Using Environment Variables (Recommended)

Do not hardcode secrets in configuration files. Use environment variables instead:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server-supabase",
        "--url", "${SUPABASE_URL}",
        "--service-role-key", "${SUPABASE_SERVICE_ROLE_KEY}"
      ]
    }
  }
}
```

Then set the environment variables:

```bash
export SUPABASE_URL="https://your-project-ref.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJI..."
```

Add these to your `.env` file (not committed to git):

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJI...
```

### Global vs Project Configuration

- **Project-level** (`.claude/mcp.json`): Recommended. Each project connects to its own Supabase instance.
- **Global** (`~/.claude/mcp.json`): Use when you have a single Supabase project for everything.

## Step 3: Verify the Connection

Start Claude Code in your project directory:

```bash
claude
```

Test the connection:

```
List all tables in my Supabase database
```

Claude should list your tables with column definitions. If you see an error, check the troubleshooting section below.

## Available MCP Tools

Once connected, Claude Code has access to these Supabase-specific tools:

### Schema Tools

```
Show me the schema for the users table
```

Returns column names, types, nullability, defaults, constraints, and foreign keys.

```
What indexes exist on the orders table?
```

Lists all indexes including unique constraints and partial indexes.

```
Show all foreign key relationships in my database
```

Maps out the relationship graph between tables.

### Query Tools

```
Select the 10 most recent orders with their user emails
```

Claude writes and executes the SQL:

```sql
SELECT o.id, o.created_at, o.total, u.email
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.created_at DESC
LIMIT 10;
```

```
How many users signed up in the last 7 days?
```

```sql
SELECT COUNT(*) FROM users
WHERE created_at > NOW() - INTERVAL '7 days';
```

### Migration Tools

```
Create a migration to add a 'status' column to the orders table
with values: pending, processing, completed, cancelled
```

Claude generates:

```sql
-- Migration: Add status column to orders
ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'
CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));

CREATE INDEX idx_orders_status ON orders(status);
```

### RLS Policy Tools

```
Show me all RLS policies on the profiles table
```

Lists each policy with its name, action (SELECT, INSERT, UPDATE, DELETE), roles, and USING/WITH CHECK expressions.

```
Create an RLS policy that lets users read only their own profile
```

Claude generates:

```sql
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

### Function Tools

```
Create a PostgreSQL function that calculates order totals
including tax for a given user_id
```

```sql
CREATE OR REPLACE FUNCTION calculate_user_order_total(p_user_id UUID)
RETURNS NUMERIC AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT SUM(subtotal * (1 + tax_rate))
  INTO total
  FROM orders
  WHERE user_id = p_user_id AND status = 'completed';

  RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Real Project Example: Building a SaaS User System

Here is a complete workflow showing Claude Code with Supabase MCP building a subscription management system.

### Step 1: Design the Schema

```
I need a subscription management system. Create tables for:
- users (email, name, created_at)
- plans (name, price, interval, features as JSONB)
- subscriptions (user_id, plan_id, status, current_period_start, current_period_end, stripe_subscription_id)
- invoices (subscription_id, amount, status, stripe_invoice_id, paid_at)

Add appropriate constraints and indexes.
```

Claude inspects your existing schema, then creates the migration:

```sql
-- Create plans table
CREATE TABLE plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  interval TEXT NOT NULL CHECK (interval IN ('month', 'year')),
  features JSONB DEFAULT '[]'::jsonb,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create subscriptions table
CREATE TABLE subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES plans(id),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'past_due', 'cancelled', 'trialing')),
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  stripe_subscription_id TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_subscription_id);

-- Create invoices table
CREATE TABLE invoices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subscription_id UUID NOT NULL REFERENCES subscriptions(id),
  amount NUMERIC(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
  stripe_invoice_id TEXT UNIQUE,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_invoices_subscription ON invoices(subscription_id);
CREATE INDEX idx_invoices_status ON invoices(status);
```

### Step 2: Add RLS Policies

```
Create RLS policies for the subscription tables:
- Users can only see their own subscriptions and invoices
- Plans are readable by everyone
- Only service role can insert/update subscriptions and invoices
```

Claude generates the policies and applies them through MCP.

### Step 3: Create Edge Functions

```
Create a Supabase edge function that handles Stripe webhook events
for subscription.created, subscription.updated, and invoice.paid
```

Claude writes the edge function, using the schema it already inspected through MCP.

### Step 4: Generate TypeScript Types

```
Generate TypeScript types from the current database schema
```

Claude queries the schema through MCP and generates:

```typescript
export interface Plan {
  id: string;
  name: string;
  price: number;
  interval: 'month' | 'year';
  features: Record<string, unknown>[];
  active: boolean;
  created_at: string;
}

export interface Subscription {
  id: string;
  user_id: string;
  plan_id: string;
  status: 'active' | 'past_due' | 'cancelled' | 'trialing';
  current_period_start: string;
  current_period_end: string;
  stripe_subscription_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface Invoice {
  id: string;
  subscription_id: string;
  amount: number;
  status: 'pending' | 'paid' | 'failed' | 'refunded';
  stripe_invoice_id: string | null;
  paid_at: string | null;
  created_at: string;
}
```

### Step 5: Seed Test Data

```
Insert 3 plans (Basic $9/mo, Pro $29/mo, Enterprise $99/mo)
and create 5 test users with subscriptions
```

Claude generates and runs the INSERT statements through MCP.

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Security Considerations

### Service Role Key

The service role key bypasses RLS. Only use it in:
- Local development
- Server-side environments where you control access
- Claude Code sessions where you are the only operator

Never use the service role key in client-side code or share it.

### Query Validation

Claude Code with MCP can run any SQL query. When using the service role key, it can:
- Drop tables
- Delete all data
- Modify RLS policies
- Access any row regardless of RLS

Configure [Claude Code hooks](/claude-code-hooks-complete-guide/) to add a safety layer:

```bash
#!/bin/bash
# PreToolUse hook for Supabase MCP
# Block destructive SQL operations

TOOL_INPUT="$CLAUDE_TOOL_INPUT"

if echo "$TOOL_INPUT" | grep -qiE 'DROP TABLE|TRUNCATE|DELETE FROM.*WHERE 1|ALTER TABLE.*DROP'; then
  echo "BLOCKED: Destructive SQL operation detected"
  exit 1
fi

exit 0
```

### Read-Only Mode

For safer exploration, create a read-only Supabase database user and use that connection string instead of the service role:

```sql
CREATE ROLE readonly_user WITH LOGIN PASSWORD 'your-password';
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
```

Then configure MCP with this restricted connection.

## Troubleshooting

### "Connection refused" Error

1. Verify your Supabase project is active (not paused)
2. Check the project URL is correct (no typos)
3. Ensure the service role key matches the current project
4. Test connectivity:

```bash
curl https://your-project-ref.supabase.co/rest/v1/ \
  -H "apikey: your-service-role-key" \
  -H "Authorization: Bearer your-service-role-key"
```

### MCP Server Not Starting

1. Check Node.js version: `node --version` (need 18+)
2. Reinstall the MCP server: `npm install -g @supabase/mcp-server-supabase`
3. Verify the mcp.json syntax (valid JSON, correct paths)
4. Check Claude Code logs for error details

### Slow Queries

The MCP server adds a network hop. For large result sets:

1. Add LIMIT clauses to queries
2. Use specific column selections instead of `SELECT *`
3. Ensure indexes exist for filtered columns
4. Check if your Supabase project is on a free tier (slower performance)

### Schema Not Updating

After making schema changes outside of Claude Code (e.g., in the Supabase dashboard):

1. Restart Claude Code to refresh the MCP connection
2. Ask Claude to "refresh the database schema"
3. Check that migrations were applied correctly

### Permission Errors

If using the `anon` key instead of `service_role`:

1. RLS policies must permit the operation
2. The table must have RLS enabled
3. The authenticated user's JWT must have the required role

For development, the service role key avoids these issues. For [production MCP configurations](/claude-code-mcp-server-least-privilege-configuration/), use properly scoped keys.

## Advanced Configuration

### Multiple Supabase Projects

Connect to multiple projects by naming them:

```json
{
  "mcpServers": {
    "supabase-prod": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server-supabase",
        "--url", "${SUPABASE_PROD_URL}",
        "--service-role-key", "${SUPABASE_PROD_KEY}"
      ]
    },
    "supabase-staging": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server-supabase",
        "--url", "${SUPABASE_STAGING_URL}",
        "--service-role-key", "${SUPABASE_STAGING_KEY}"
      ]
    }
  }
}
```

Then tell Claude which environment to use:

```
Using the staging database, show me the users table schema
```

### Combining with Other MCP Servers

Supabase MCP works alongside other [MCP servers](/best-mcp-servers-for-claude-code-2026/):

```json
{
  "mcpServers": {
    "supabase": { ... },
    "github": { ... },
    "filesystem": { ... }
  }
}
```

Claude can then create a GitHub issue, check the database schema, and write code all in one session.

### Local Supabase Development

For local Supabase development with `supabase start`:

```json
{
  "mcpServers": {
    "supabase-local": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server-supabase",
        "--url", "http://localhost:54321",
        "--service-role-key", "your-local-service-role-key"
      ]
    }
  }
}
```

The local service role key is printed when you run `supabase start`.

## Frequently Asked Questions

### Does the MCP server store my database credentials?
No. Credentials are passed as arguments at startup and held in memory. They are not written to disk by the MCP server.

### Can I use Supabase MCP with the free tier?
Yes. The MCP server works with any Supabase plan. Free tier projects may pause after inactivity, which will cause connection errors until you unpause them.

### Does MCP support Supabase Edge Functions?
The MCP server focuses on database operations. For edge function deployment, use the Supabase CLI through Claude Code's Bash tool.

### Can Claude Code modify my production database?
Yes, if you give it the production service role key. Use read-only credentials or a staging environment for safety. Add [hooks](/claude-code-hooks-complete-guide/) to block destructive operations.

### How does this compare to using the Supabase CLI?
The CLI (`supabase`) handles project management, migrations, and deployments. MCP provides direct database access for queries and schema inspection. They complement each other.

### Does the MCP connection count against Supabase rate limits?
Yes. MCP queries count against your Supabase project's database connection and request limits. On free tier, be mindful of connection pooling limits.

### Can I use Supabase Auth through MCP?
The MCP server focuses on database operations. For auth operations, use the Supabase JavaScript client library through Claude Code's Bash tool or direct API calls.

### Is the MCP server open source?
Yes. The Supabase MCP server is open source and available on GitHub under the Supabase organization.

### What other MCP servers work well alongside Supabase MCP?
Common pairings include GitHub MCP for issue tracking, filesystem MCP for structured file access, and custom servers for internal APIs. See our [best MCP servers guide](/best-mcp-servers-for-claude-code-2026/) and [MCP configuration guide](/claude-code-mcp-configuration-guide/) for setup.

### How do I configure my CLAUDE.md to work with Supabase MCP?
Add Supabase-specific rules to your [CLAUDE.md file](/claude-md-best-practices-definitive-guide/) including your database conventions, naming patterns, and RLS requirements. See our [CLAUDE.md best practices guide](/claude-md-best-practices-definitive-guide/) for templates.

### Can I use Supabase MCP with the spec workflow?
Yes. The [spec workflow](/claude-code-spec-workflow-guide/) works well with Supabase MCP. Write your database schema changes in a spec, then have Claude implement and verify them through MCP.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Does the MCP server store my database credentials?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Credentials are passed as arguments at startup and held in memory. They are not written to disk by the MCP server."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Supabase MCP with the free tier?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The MCP server works with any Supabase plan. Free tier projects may pause after inactivity, which will cause connection errors until you unpause them."
      }
    },
    {
      "@type": "Question",
      "name": "Does MCP support Supabase Edge Functions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The MCP server focuses on database operations. For edge function deployment, use the Supabase CLI through Claude Code's Bash tool."
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude Code modify my production database?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, if you give it the production service role key. Use read-only credentials or a staging environment for safety. Add hooks to block destructive operations."
      }
    },
    {
      "@type": "Question",
      "name": "How does this compare to using the Supabase CLI?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The CLI (supabase) handles project management, migrations, and deployments. MCP provides direct database access for queries and schema inspection. They complement each other."
      }
    },
    {
      "@type": "Question",
      "name": "Does the MCP connection count against Supabase rate limits?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. MCP queries count against your Supabase project's database connection and request limits. On free tier, be mindful of connection pooling limits."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Supabase Auth through MCP?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The MCP server focuses on database operations. For auth operations, use the Supabase JavaScript client library through Claude Code's Bash tool or direct API calls."
      }
    },
    {
      "@type": "Question",
      "name": "Is the MCP server open source?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The Supabase MCP server is open source and available on GitHub under the Supabase organization."
      }
    },
    {
      "@type": "Question",
      "name": "What other MCP servers work well alongside Supabase MCP?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Common pairings include GitHub MCP for issue tracking, filesystem MCP for structured file access, and custom servers for internal APIs. See our best MCP servers guide and MCP configuration guide for setup."
      }
    },
    {
      "@type": "Question",
      "name": "How do I configure my CLAUDE.md to work with Supabase MCP?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add Supabase-specific rules to your CLAUDE.md file including your database conventions, naming patterns, and RLS requirements. See our CLAUDE.md best practices guide for templates."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Supabase MCP with the spec workflow?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The spec workflow works well with Supabase MCP. Write your database schema changes in a spec, then have Claude implement and verify them through MCP."
      }
    }
  ]
}
</script>

## See Also

- [InsForge Setup Guide for Claude Code: Skills + CLI + MCP](/insforge-setup-guide-claude-code-skills-cli-mcp/)

{% endraw %}