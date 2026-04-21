---
layout: default
title: "Build Supabase Apps with Claude Code (2026)"
description: "Build Supabase full-stack apps with Claude Code skills covering database design, auth, Edge Functions, and deployment workflows in one guide."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, supabase, full-stack, backend]
author: "Claude Skills Guide"
reviewed: true
score: 8
last_tested: "2026-04-21"
permalink: /claude-code-skills-for-supabase-full-stack-apps-guide/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Building a Supabase-powered full-stack application involves multiple layers: database schema, authentication, backend logic, API endpoints, and frontend interfaces. [Claude Code skills](/claude-skill-md-format-complete-specification-guide/) streamline each phase of this workflow. This guide covers the most useful skills for Supabase development and shows how to invoke them effectively.

## Setting Up Your Supabase Project

Before diving into skills, ensure your local environment is ready. Initialize a new project with your preferred framework. Supabase works well with Next.js, Remix, SvelteKit, or Vue. The key is establishing a clean connection to your Supabase instance.

Create a `.env.local` file with your Supabase credentials:

```bash
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key # Server-side only, never expose to client
```

Keep your credentials secure and never commit them to version control. Distinguish clearly between the anon key (safe for client-side use, gated by RLS) and the service role key (bypasses RLS entirely. backend only).

Install the Supabase client library and create a shared client instance:

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

export const supabase = createClient<Database>(
 process.env.NEXT_PUBLIC_SUPABASE_URL!,
 process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Server-side admin client
export const supabaseAdmin = createClient<Database>(
 process.env.NEXT_PUBLIC_SUPABASE_URL!,
 process.env.SUPABASE_SERVICE_ROLE_KEY!
);
```

Using the generated `Database` type from `supabase gen types typescript` gives you end-to-end type safety from database to frontend, catching schema mismatches at compile time rather than at runtime. The [supermemory skill](/claude-supermemory-skill-persistent-context-explained/) helps maintain organized documentation of your project configuration across different environments.

## Database Design and Schema Management

Designing your PostgreSQL schema correctly from the start prevents costly migrations later. A well-structured schema should account for your access patterns, not just your data shape. Think about which queries will run most frequently and create indexes accordingly.

Here is an example schema for a multi-tenant SaaS application with teams, users, and posts:

```sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Teams table
create table teams (
 id uuid primary key default uuid_generate_v4(),
 name text not null,
 slug text unique not null,
 created_at timestamptz default now()
);

-- Users extend Supabase auth.users via foreign key
create table profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 team_id uuid references teams(id) on delete set null,
 display_name text,
 avatar_url text,
 role text check (role in ('admin', 'member', 'viewer')) default 'member',
 created_at timestamptz default now()
);

-- Posts belong to a team
create table posts (
 id uuid primary key default uuid_generate_v4(),
 team_id uuid not null references teams(id) on delete cascade,
 author_id uuid not null references profiles(id),
 title text not null,
 body text,
 published boolean default false,
 published_at timestamptz,
 created_at timestamptz default now(),
 updated_at timestamptz default now()
);

-- Index for common query patterns
create index posts_team_id_idx on posts(team_id);
create index posts_author_id_idx on posts(author_id);
create index posts_published_idx on posts(published, published_at desc) where published = true;
```

For Row Level Security (RLS) policies, write your policies in a separate SQL file and test them thoroughly. Supabase RLS is powerful but requires careful attention to security boundaries. Below are the policies for the posts table:

```sql
-- Enable RLS
alter table posts enable row level security;

-- Team members can read all team posts
create policy "team members read posts"
 on posts for select
 using (
 team_id in (
 select team_id from profiles where id = auth.uid()
 )
 );

-- Authors can insert into their team
create policy "authors create posts"
 on posts for insert
 with check (
 author_id = auth.uid()
 and team_id in (
 select team_id from profiles where id = auth.uid()
 )
 );

-- Authors can update their own posts; admins can update any team post
create policy "authors and admins update posts"
 on posts for update
 using (
 author_id = auth.uid()
 or exists (
 select 1 from profiles
 where id = auth.uid()
 and team_id = posts.team_id
 and role = 'admin'
 )
 );
```

Use the xlsx skill to document your database schema in a spreadsheet format, creating a clear reference for table relationships, column types, and constraints. The docx skill generates formal database design documents you can share with team members or stakeholders.

A useful pattern is to generate Supabase types directly from your database and commit them to the repository, so the TypeScript compiler enforces schema alignment across the entire codebase:

```bash
npx supabase gen types typescript --project-id your-project-id > lib/database.types.ts
```

## Backend Development with Edge Functions

Supabase Edge Functions run Deno at the edge, handling serverless backend logic. They are ideal for webhooks, background processing, and any backend operation that needs to happen outside the client. The [tdd skill](/claude-tdd-skill-test-driven-development-workflow/) proves invaluable here. Write your tests first, then implement the function logic.

```typescript
// supabase/functions/process-payment/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
 "Access-Control-Allow-Origin": "*",
 "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
 // Handle CORS preflight
 if (req.method === "OPTIONS") {
 return new Response("ok", { headers: corsHeaders });
 }

 try {
 const supabaseClient = createClient(
 Deno.env.get("SUPABASE_URL") ?? "",
 Deno.env.get("SUPABASE_ANON_KEY") ?? "",
 { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
 );

 // Verify caller is authenticated
 const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
 if (authError || !user) {
 return new Response(JSON.stringify({ error: "Unauthorized" }), {
 status: 401,
 headers: { ...corsHeaders, "Content-Type": "application/json" },
 });
 }

 const { amount, currency } = await req.json();

 // Use admin client for privileged operations
 const supabaseAdmin = createClient(
 Deno.env.get("SUPABASE_URL") ?? "",
 Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
 );

 const { data, error } = await supabaseAdmin
 .from("payments")
 .insert({ user_id: user.id, amount, currency, status: "pending" })
 .select()
 .single();

 if (error) throw error;

 return new Response(JSON.stringify({ success: true, payment: data }), {
 headers: { ...corsHeaders, "Content-Type": "application/json" },
 });
 } catch (err) {
 return new Response(JSON.stringify({ error: err.message }), {
 status: 500,
 headers: { ...corsHeaders, "Content-Type": "application/json" },
 });
 }
});
```

A few things this example demonstrates that are easy to get wrong: always handle CORS preflight OPTIONS requests, always verify the user's JWT before processing privileged actions, and use the service role key (not the anon key) only for operations that legitimately need to bypass RLS.

The pptx skill helps create technical presentations for architecture reviews or sprint demos. Export your Edge Function documentation to slides for team meetings.

## Frontend Integration

Connecting your frontend to Supabase involves handling authentication state, real-time subscriptions, and data fetching. The [frontend-design skill](/claude-frontend-design-skill-review-and-tutorial/) generates component structures that follow best practices for Supabase integration.

Authentication state management is often the trickiest part. The Supabase auth client persists sessions in localStorage by default, but you need to listen for changes and propagate them through your React tree:

```typescript
// hooks/useAuth.ts
import { useEffect, useState } from 'react';
import { Session, User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

export function useAuth() {
 const [session, setSession] = useState<Session | null>(null);
 const [user, setUser] = useState<User | null>(null);
 const [loading, setLoading] = useState(true);

 useEffect(() => {
 // Get initial session
 supabase.auth.getSession().then(({ data: { session } }) => {
 setSession(session);
 setUser(session?.user ?? null);
 setLoading(false);
 });

 // Listen for auth changes (login, logout, token refresh)
 const { data: { subscription } } = supabase.auth.onAuthStateChange(
 (_event, session) => {
 setSession(session);
 setUser(session?.user ?? null);
 setLoading(false);
 }
 );

 return () => subscription.unsubscribe();
 }, []);

 const signIn = async (email: string, password: string) => {
 const { data, error } = await supabase.auth.signInWithPassword({ email, password });
 if (error) throw error;
 return data;
 };

 const signOut = () => supabase.auth.signOut();

 return { session, user, loading, signIn, signOut };
}
```

For real-time subscriptions, Supabase uses PostgreSQL's logical replication to stream database changes to connected clients. Here is how to subscribe to live updates for a specific team's posts:

```typescript
// hooks/useTeamPosts.ts
import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { Database } from '../lib/database.types';

type Post = Database['public']['Tables']['posts']['Row'];

export function useTeamPosts(teamId: string) {
 const [posts, setPosts] = useState<Post[]>([]);

 useEffect(() => {
 // Initial fetch
 supabase
 .from('posts')
 .select('*')
 .eq('team_id', teamId)
 .order('created_at', { ascending: false })
 .then(({ data }) => setPosts(data ?? []));

 // Subscribe to real-time changes
 const channel = supabase
 .channel(`team-posts-${teamId}`)
 .on(
 'postgres_changes',
 { event: '*', schema: 'public', table: 'posts', filter: `team_id=eq.${teamId}` },
 (payload) => {
 if (payload.eventType === 'INSERT') {
 setPosts((prev) => [payload.new as Post, ...prev]);
 } else if (payload.eventType === 'UPDATE') {
 setPosts((prev) =>
 prev.map((p) => (p.id === payload.new.id ? (payload.new as Post) : p))
 );
 } else if (payload.eventType === 'DELETE') {
 setPosts((prev) => prev.filter((p) => p.id !== payload.old.id));
 }
 }
 )
 .subscribe();

 return () => supabase.removeChannel(channel);
 }, [teamId]);

 return posts;
}
```

Remember to enable the `realtime` feature for each table in the Supabase dashboard, and to set appropriate RLS policies. realtime subscriptions respect your row-level security rules.

## Testing and Quality Assurance

The tdd skill integrates with your Supabase project to create comprehensive test suites. Test authentication flows, RLS policies, Edge Functions, and API integrations. For Supabase specifically, use the Supabase CLI to run a local stack so tests don't hit your production database:

```bash
supabase start # Starts local Postgres, Auth, Storage, etc.
supabase db reset # Resets local DB and reruns migrations + seeds
```

With a local stack running, you can write integration tests that run real queries:

```typescript
// __tests__/posts.test.ts
import { createClient } from '@supabase/supabase-js';

const localUrl = 'http://localhost:54321';
const anonKey = 'your-local-anon-key'; // from supabase status output

describe('Posts RLS policies', () => {
 let userAClient: ReturnType<typeof createClient>;
 let userBClient: ReturnType<typeof createClient>;

 beforeAll(async () => {
 // Sign in as two different users
 userAClient = createClient(localUrl, anonKey);
 userBClient = createClient(localUrl, anonKey);

 await userAClient.auth.signInWithPassword({
 email: 'user-a@example.com',
 password: 'test-password'
 });
 await userBClient.auth.signInWithPassword({
 email: 'user-b@example.com',
 password: 'test-password'
 });
 });

 test('user cannot read posts from another team', async () => {
 // user-b is on a different team than user-a
 const { data, error } = await userBClient
 .from('posts')
 .select('*')
 .eq('team_id', 'user-a-team-id');

 expect(error).toBeNull();
 expect(data).toHaveLength(0); // RLS blocks cross-team reads
 });

 test('author can update their own post', async () => {
 const { error } = await userAClient
 .from('posts')
 .update({ title: 'Updated title' })
 .eq('id', 'known-post-id-belonging-to-user-a');

 expect(error).toBeNull();
 });
});
```

The pdf skill generates test reports and quality documentation. Export your test coverage reports to PDF for compliance or stakeholder reviews.

| Test Category | What to Cover | Recommended Tool |
|---|---|---|
| RLS policies | Cross-tenant read/write isolation | Supabase local + Jest |
| Auth flows | Sign up, sign in, password reset, OAuth | Playwright or Cypress |
| Edge Functions | Input validation, error handling, auth checks | Deno.test or Jest |
| Real-time | Subscribe, receive events, unsubscribe | Jest with fake timers |
| Type safety | Schema drift detection | `supabase gen types` in CI |

## Documentation and Knowledge Management

Maintaining clear documentation accelerates team collaboration. The docx skill creates comprehensive API documentation from your Supabase project.

One of the most useful documentation artifacts for a Supabase project is a migration changelog that explains the *why* behind each schema change, not just the *what*. Store this alongside your migrations directory:

```bash
supabase/
 migrations/
 20260101_initial_schema.sql
 20260115_add_team_roles.sql
 20260201_add_post_tags.sql
 seeds/
 test_data.sql
 MIGRATIONS.md # plain English explanation of each migration
```

The supermemory skill maintains contextual awareness of your project decisions, making it easier to recall why specific architectural choices were made. For instance, if you chose to use `profiles` as a separate table instead of extending `auth.users` directly, that reasoning should be captured so future developers don't inadvertently reverse it.

## Deployment and DevOps

Deploying Supabase applications involves multiple steps: building your frontend, deploying Edge Functions, and configuring environment variables. Automate this with a CI/CD pipeline that runs your test suite against the local Supabase stack before deploying:

```yaml
.github/workflows/deploy.yml
name: Test and Deploy

on:
 push:
 branches: [main]

jobs:
 test:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Setup Supabase CLI
 uses: supabase/setup-cli@v1
 with:
 version: latest

 - name: Start local Supabase
 run: supabase start

 - name: Run tests
 run: npm test

 - name: Stop local Supabase
 run: supabase stop

 deploy:
 needs: test
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Deploy Edge Functions
 run: |
 npx supabase functions deploy process-payment \
 --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}

 - name: Push migrations
 run: |
 npx supabase db push \
 --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}

 - name: Deploy frontend
 run: npm run build && npm run deploy
```

The webapp-testing skill validates your deployed application, checking that authentication flows, database connections, and API endpoints work correctly in production.

Use version control for your Supabase configuration. Store migrations and schema changes in your repository, enabling reproducible deployments across environments. Never apply schema changes directly in the Supabase dashboard without also creating the corresponding migration file. otherwise your local development environment and production will diverge silently.

## Skill-to-Phase Mapping for Supabase Projects

| Project Phase | Recommended Skill | Primary Use Case |
|---|---|---|
| Schema design | xlsx | Table relationship documentation |
| Team communication | docx, pptx | Architecture docs, sprint demos |
| Backend logic | tdd | Edge Function test coverage |
| Frontend UI | frontend-design | Component generation, auth flows |
| Cross-session context | supermemory | Project decision log |
| Compliance / reporting | pdf | Test reports, audit exports |
| Production validation | webapp-testing | Post-deploy smoke tests |

## Summary

Claude Code skills enhance every phase of Supabase full-stack development. The frontend-design skill accelerates UI implementation, especially for auth flows and real-time components. The tdd skill ensures reliable backend logic through test-driven development, and pairs naturally with Supabase's local development stack for genuine integration testing. The xlsx and docx skills maintain clear documentation for schema design and API contracts. The supermemory skill preserves project context across sessions, so architectural decisions don't get lost. The pdf skill generates reports and documentation for stakeholders and compliance needs.

The most important thing to get right early is your RLS policy design. it determines both your security posture and your query complexity. Invest the time to write thorough RLS tests against a local stack before deploying, and use generated TypeScript types to enforce schema alignment from database to UI. These habits compound over the lifetime of the project.

Start with the skills matching your current bottleneck. As your project matures, integrate additional skills to maintain code quality and team productivity.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-supabase-full-stack-apps-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Supermemory Skill: Persistent Context Explained](/claude-supermemory-skill-persistent-context-explained/). persist Supabase project decisions and configuration across sessions
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-tdd-skill-test-driven-development-workflow/). write tests for Edge Functions and RLS policies before implementing them
- [Claude Frontend Design Skill Review and Tutorial](/claude-frontend-design-skill-review-and-tutorial/). generate Supabase-connected React and Svelte component structures
- [Claude Skills with Supabase Database Integration](/claude-skills-with-supabase-database-integration/). connect Claude skills directly to your Supabase database for live queries

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


