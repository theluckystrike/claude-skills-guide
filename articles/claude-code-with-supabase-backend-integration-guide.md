---
layout: default
title: "How to Use Supabase Integration (2026)"
description: "Integrate Claude Code with Supabase for backend development. Database operations, authentication, Edge Functions, and SSO workflow in one guide."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-with-supabase-backend-integration-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---

# Claude Code with Supabase Backend Integration Guide

Integrating Claude Code with Supabase provides a powerful workflow for building backend services. This guide walks through connecting Claude Code to your Supabase project, executing database operations, and deploying serverless functions. For project structure, migration strategies, RLS policy patterns, and CI/CD pipelines, see the [Claude Code Supabase Backend Development Workflow Tips](/claude-code-supabase-backend-development-workflow-tips/) guide.

## Prerequisites

You need a Supabase project with the following credentials:
- Project URL
- Service role key (for admin operations)
- Anon key (for client-side operations)

Store these in your environment variables:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_KEY="your-service-role-key"
export SUPABASE_ANON_KEY="your-anon-key"
```

You also need the Supabase CLI installed for running migrations and deploying Edge Functions:

```bash
npm install -g supabase
supabase login
supabase link --project-ref your-project-ref
```

Verify the connection works before doing anything else:

```bash
supabase status
```

This prints your project URL, keys, and connected database. If it fails, check that your project ref matches the one in the Supabase dashboard under Project Settings.

## Setting Up the Connection

Create a simple Supabase client in your project:

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
 process.env.SUPABASE_URL,
 process.env.SUPABASE_SERVICE_KEY
);
```

The service role key bypasses Row Level Security (RLS), so use it only in server-side code or Claude Code workflows where you need full database access.

For client-side code. React components, browser scripts, mobile apps. always use the anon key instead. The anon key respects RLS policies and prevents users from accessing each other's data even if the frontend code is compromised:

```typescript
// Client-side: respects RLS
const supabaseClient = createClient(
 process.env.NEXT_PUBLIC_SUPABASE_URL,
 process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

// Server-side: bypasses RLS for admin operations
const supabaseAdmin = createClient(
 process.env.SUPABASE_URL,
 process.env.SUPABASE_SERVICE_KEY
);
```

A common mistake is exposing the service role key in frontend code. If you see `SUPABASE_SERVICE_KEY` without a `NEXT_PUBLIC_` prefix, you are safe. Next.js will not send server-only env vars to the browser. For other frameworks, double-check your bundler configuration.

## Database Operations with Claude Code

Claude Code can execute SQL queries directly against your Supabase database. Here's how to perform common operations:

## Inserting Records

```typescript
async function createUser(email: string, name: string) {
 const { data, error } = await supabase
 .from('users')
 .insert({ email, name })
 .select()
 .single();

 if (error) throw error;
 return data;
}
```

## Querying with Filters

```typescript
async function getUserByEmail(email: string) {
 const { data, error } = await supabase
 .from('users')
 .select('*')
 .eq('email', email)
 .single();

 if (error) return null;
 return data;
}
```

## Batch Operations and Upserts

When inserting multiple records or syncing data from an external source, use upsert to avoid duplicate errors:

```typescript
async function syncProducts(products: Product[]) {
 const { data, error } = await supabase
 .from('products')
 .upsert(products, {
 onConflict: 'sku', // conflict column
 ignoreDuplicates: false // update on conflict
 })
 .select();

 if (error) throw error;
 return data;
}
```

This pattern is especially useful when Claude Code is helping you build ETL scripts that pull data from external APIs and write it into Supabase. Rather than checking for existence first, let the database handle conflict resolution.

## Joins and Nested Selects

Supabase supports PostgREST-style relationship queries. Define foreign keys in your schema and you can query across tables in a single call:

```typescript
async function getOrdersWithItems(userId: string) {
 const { data, error } = await supabase
 .from('orders')
 .select(`
 id,
 created_at,
 total_amount,
 order_items (
 quantity,
 unit_price,
 products (
 name,
 sku
 )
 )
 `)
 .eq('user_id', userId)
 .order('created_at', { ascending: false });

 if (error) throw error;
 return data;
}
```

This avoids multiple round trips and lets Claude Code reason about your data model more naturally when you describe your schema in context.

## Real-time Subscriptions

Supabase provides real-time capabilities. Subscribe to database changes:

```typescript
const channel = supabase
 .channel('users-changes')
 .on(
 'postgres_changes',
 { event: 'INSERT', schema: 'public', table: 'users' },
 (payload) => console.log('New user:', payload.new)
 )
 .subscribe();
```

Clean up subscriptions when components unmount to avoid memory leaks:

```typescript
// In a React component
useEffect(() => {
 const channel = supabase
 .channel('orders-changes')
 .on(
 'postgres_changes',
 { event: '*', schema: 'public', table: 'orders' },
 handleOrderChange
 )
 .subscribe();

 return () => {
 supabase.removeChannel(channel);
 };
}, []);
```

For real-time features, consider using the frontend-design skill to build reactive UI components that update automatically when data changes.

## Schema Design with Row Level Security

Design your database schema with RLS from the start. Here is a practical example for a todo application:

```sql
CREATE TABLE todos (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
 title TEXT NOT NULL,
 completed BOOLEAN DEFAULT false,
 created_at TIMESTAMPTZ DEFAULT now(),
 updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own todos" ON todos
 FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own todos" ON todos
 FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own todos" ON todos
 FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own todos" ON todos
 FOR DELETE USING (auth.uid() = user_id);
```

## Shared Data with Team Access

Real applications often need more complex access patterns. Here is an example where team members can read shared resources, but only owners can modify them:

```sql
CREATE TABLE documents (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
 team_id UUID REFERENCES teams(id),
 title TEXT NOT NULL,
 content TEXT,
 is_public BOOLEAN DEFAULT false,
 created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Owners can do anything
CREATE POLICY "Owners have full access" ON documents
 FOR ALL USING (auth.uid() = owner_id);

-- Team members can read team documents
CREATE POLICY "Team members can read" ON documents
 FOR SELECT USING (
 team_id IN (
 SELECT team_id FROM team_members
 WHERE user_id = auth.uid()
 )
 );

-- Public documents are readable by anyone authenticated
CREATE POLICY "Public documents are readable" ON documents
 FOR SELECT USING (is_public = true AND auth.role() = 'authenticated');
```

When Claude Code writes migration scripts for you, describe access patterns this clearly. The model generates accurate policies when given concrete business rules rather than abstract descriptions.

For advanced RLS patterns and fine-grained access control, see the [Supabase Auth RLS Guide](/claude-code-supabase-auth-row-level-security-guide/).

## Authentication Integration

Supabase handles authentication with multiple providers. Claude Code can manage user sessions and protected routes.

## Sign Up New Users

```typescript
async function signUpUser(email: string, password: string) {
 const { data, error } = await supabase.auth.signUp({
 email,
 password,
 });

 if (error) throw error;
 return data;
}
```

## Session Management

```typescript
async function signInUser(email: string, password: string) {
 const { data, error } = await supabase.auth.signInWithPassword({
 email,
 password,
 });

 if (error) throw error;
 return data.session;
}
```

## OAuth Providers

Supabase supports GitHub, Google, Twitter, and other OAuth providers. Adding a provider takes one configuration step in the dashboard plus a client-side call:

```typescript
async function signInWithGitHub() {
 const { data, error } = await supabase.auth.signInWithOAuth({
 provider: 'github',
 options: {
 redirectTo: `${window.location.origin}/auth/callback`,
 scopes: 'repo read:user',
 },
 });

 if (error) throw error;
 return data;
}
```

## Protecting Server Routes

In a Next.js App Router application, use Supabase's server-side auth helpers to protect routes and read the user's session:

```typescript
// app/dashboard/page.tsx
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';

export default async function Dashboard() {
 const supabase = createServerComponentClient({ cookies });

 const { data: { session } } = await supabase.auth.getSession();

 if (!session) {
 redirect('/login');
 }

 const { data: profile } = await supabase
 .from('profiles')
 .select('*')
 .eq('id', session.user.id)
 .single();

 return <div>Welcome, {profile?.display_name}</div>;
}
```

The tdd skill pairs well here. write tests for your authentication flow before implementing to ensure secure user management.

## Edge Functions

Supabase Edge Functions run Deno at the edge and integrate tightly with your database. For detailed examples of writing Edge Functions with full error handling, authentication checks, and deployment patterns, see the [Claude Code Supabase Backend Development Workflow Tips](/claude-code-supabase-backend-development-workflow-tips/) guide.

The short form: create a function file in `supabase/functions/<name>/index.ts`, implement your handler, then deploy:

```bash
supabase functions deploy <function-name>
```

Here is a complete example Edge Function that handles a webhook, verifies the signature, and writes to the database:

```typescript
// supabase/functions/stripe-webhook/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
 Deno.env.get('SUPABASE_URL')!,
 Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

serve(async (req) => {
 if (req.method !== 'POST') {
 return new Response('Method not allowed', { status: 405 });
 }

 const signature = req.headers.get('stripe-signature');
 const body = await req.text();

 // Verify webhook signature
 const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;
 let event;

 try {
 event = verifyStripeSignature(body, signature, webhookSecret);
 } catch (err) {
 return new Response(`Webhook error: ${err.message}`, { status: 400 });
 }

 if (event.type === 'payment_intent.succeeded') {
 const { error } = await supabase
 .from('payments')
 .insert({
 stripe_payment_id: event.data.object.id,
 amount: event.data.object.amount,
 status: 'completed',
 });

 if (error) console.error('DB error:', error);
 }

 return new Response(JSON.stringify({ received: true }), {
 headers: { 'Content-Type': 'application/json' },
 });
});
```

When Claude Code writes Edge Functions, give it the function's purpose, the expected request shape, and any database tables it should interact with. The model handles Deno-specific imports and Supabase service role usage correctly when you establish that context upfront.

## Working with Storage

Supabase Storage handles file uploads. Here's a practical workflow:

```typescript
async function uploadFile(bucket: string, path: string, file: File) {
 const { data, error } = await supabase.storage
 .from(bucket)
 .upload(path, file, {
 cacheControl: '3600',
 upsert: false,
 })

 if (error) throw error;
 return data;
}

async function getPublicUrl(bucket: string, path: string) {
 const { data } = supabase.storage
 .from(bucket)
 .getPublicUrl(path)

 return data.publicUrl;
}
```

## Generating Signed URLs for Private Files

Not all files should be publicly accessible. For user-uploaded content that should only be readable by the owner, use signed URLs that expire:

```typescript
async function getSignedUrl(bucket: string, path: string, expiresIn = 3600) {
 const { data, error } = await supabase.storage
 .from(bucket)
 .createSignedUrl(path, expiresIn);

 if (error) throw error;
 return data.signedUrl;
}
```

## Organizing Storage with Folder Structures

Use a consistent path convention so RLS-style folder rules work correctly:

```typescript
function getUserFilePath(userId: string, fileName: string) {
 const timestamp = Date.now();
 const sanitized = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
 return `${userId}/${timestamp}-${sanitized}`;
}

async function uploadUserAvatar(userId: string, file: File) {
 const path = getUserFilePath(userId, 'avatar.jpg');
 const { data, error } = await supabase.storage
 .from('avatars')
 .upload(path, file, { upsert: true });

 if (error) throw error;
 return getPublicUrl('avatars', path);
}
```

Combine this with the pdf skill to generate reports, store them in Supabase Storage, and share via public URLs.

## Database Migrations

When schema changes are needed, use the Supabase CLI:

```bash
supabase migration new add_user_preferences
```

Edit the generated SQL file, then apply:

```bash
supabase db push
```

Claude Code can help generate migration scripts by analyzing your existing schema and suggesting improvements.

## A Practical Migration Workflow

The most reliable pattern when using Claude Code for migrations is to describe the change in plain language and let it draft the SQL, then review before applying:

1. Tell Claude Code: "Add a `preferences` JSONB column to the `users` table with a default of an empty object, and add an index on the `email` field."
2. Claude Code generates the migration file with correct syntax and rollback considerations.
3. Run `supabase db diff` to preview what will change against your local database.
4. Apply with `supabase db push` for local development or `supabase db push --linked` for production.

A well-structured migration looks like this:

```sql
-- supabase/migrations/20260314120000_add_user_preferences.sql

-- Add preferences column with default
ALTER TABLE users
 ADD COLUMN IF NOT EXISTS preferences JSONB NOT NULL DEFAULT '{}';

-- Add index for email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Add comment for documentation
COMMENT ON COLUMN users.preferences IS 'User-configurable settings stored as JSON';
```

Always use `IF NOT EXISTS` and `IF EXISTS` guards so migrations are idempotent and re-runnable without errors.

## Best Practices

1. Use RLS everywhere. Enable Row Level Security on all tables, even during development
2. Separate service and anon keys. Use service role only in trusted environments
3. Handle errors gracefully. Always check for Supabase errors in your callbacks
4. Use connection pooling. For high-traffic applications, configure connection pooling via the Supabase dashboard under Database > Connection Pooling
5. Monitor with Supabase logs. Check the dashboard for query performance and errors
6. Name policies descriptively. `"Users can view own orders"` is better than `"select_policy_1"` when debugging production access issues
7. Test RLS with the SQL editor. Use `SET LOCAL role TO authenticated; SET LOCAL request.jwt.claims TO '{"sub": "user-uuid"}';` to simulate a user and verify policies work as expected

## Using Claude Skills Together

The supermemory skill helps maintain context across sessions when working on complex Supabase projects. Document your database schema, API endpoints, and edge function configurations.

For testing, the tdd skill generates comprehensive test suites for your Supabase operations. A typical test suite for a Supabase-backed service should cover:

- Happy path CRUD operations
- RLS policy enforcement (verify that user A cannot access user B's data)
- Edge function request/response contracts
- Storage upload and signed URL expiry behavior

Combined with proper RLS policies, you get a reliable backend that passes security audits.

The frontend-design skill complements backend work by generating UI components that connect smoothly to your Supabase data layer. When you share your database schema in context, the frontend-design skill can generate typed hooks and components that match your actual column names and relationships. saving significant back-and-forth between backend and frontend work.

For greenfield projects, a productive sequence is: define your schema and RLS policies with Claude Code, run migrations, then hand the schema to frontend-design and tdd to generate the application layer and test coverage simultaneously.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-with-supabase-backend-integration-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Skills for Supabase Full-Stack Apps Guide](/claude-code-skills-for-supabase-full-stack-apps-guide/). See also
- [Claude Skills With Supabase Database Integration](/claude-skills-with-supabase-database-integration/). See also
- [Full Stack Web App with Claude Skills: Step by Step](/full-stack-web-app-with-claude-skills-step-by-step/). See also
- [Claude Code Tutorials Hub](/tutorials-hub/). See also

Built by theluckystrike. More at [zovo.one](https://zovo.one)


