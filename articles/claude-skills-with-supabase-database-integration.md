---
layout: default
title: "Claude Skills with Supabase (2026)"
description: "How to use Claude Code skills alongside Supabase for database-backed projects. what works, what does not, and practical patterns."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, supabase, database, backend]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-skills-with-supabase-database-integration/
geo_optimized: true
---

# Claude Skills with Supabase: Practical Workflows

Supabase is a popular open-source backend platform built on PostgreSQL. Claude Code skills are plain `.md` instruction files invoked with slash commands. These two tools are entirely separate. but they work well together because Claude Code can help you write, review, and debug the code that talks to Supabase.

This article covers practical patterns for using Claude Code skills to speed up Supabase-related development work.

What Skills Are (and Are Not)

Before diving in: Claude skills are not Node.js modules, Python packages, or server-side plugins. A skill is a text file in `~/.claude/skills/` that loads when you type a slash command like `/tdd` or `/frontend-design`. The skill gives Claude structured guidance for a type of task.

Skills do not run code. They do not have npm dependencies. They do not execute in a Node.js environment. When this article says "use the /pdf skill with Supabase," it means: use the `/pdf` skill to help you write the code that your application uses to store PDF-extracted data in Supabase.

Think of a skill as a persistent system prompt for a domain. Loading `/tdd` before asking Claude to write a Supabase query function tells Claude to produce tests first, apply test-driven conventions throughout, and flag untested code paths. The skill shapes Claude's behavior for the duration of the conversation without you having to re-specify those preferences every time.

## Supabase Architecture Concepts That Shape How You Use Claude

Before asking Claude to write Supabase code, it helps to be precise about which layer you are working in. Supabase has several distinct surfaces that require different approaches:

| Layer | What it is | Key concern |
|-------|-----------|-------------|
| Database | PostgreSQL tables, views, functions | Schema design, migrations, indexes |
| Auth | JWT-based authentication | Session handling, provider config |
| Storage | S3-compatible object store | Bucket policies, signed URLs |
| Realtime | WebSocket subscriptions | Channel setup, filter accuracy |
| Edge Functions | Deno-based serverless functions | Cold starts, Deno vs Node compatibility |
| RLS Policies | Row-level security rules | Policy correctness, test coverage |

When asking Claude Code for help, naming the layer explicitly gets better results. "Help me write a Supabase query" is less effective than "Help me write a PostgreSQL query using the Supabase JS client that filters by `owner_id` and applies an RLS policy check in the test."

## Using /tdd for Supabase Query Testing

The [`/tdd` skill](/best-claude-skills-for-developers-2026/) is useful when writing functions that query Supabase. Invoke it, describe the function you need, and Claude will help you write tests first. then the implementation.

Example workflow:

```
/tdd

I need a function that queries a Supabase table called "projects"
filtered by owner_id and status. Write tests first, then the implementation.
```

Claude will produce tests using your preferred test framework (Jest, Vitest, pytest, etc.) and then the function implementation. You get tested Supabase query code rather than untested boilerplate.

For the Supabase JavaScript client, a tested query function might look like:

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
 process.env.SUPABASE_URL,
 process.env.SUPABASE_ANON_KEY
)

export async function getProjectsByOwner(ownerId, status) {
 const { data, error } = await supabase
 .from('projects')
 .select('id, title, created_at')
 .eq('owner_id', ownerId)
 .eq('status', status)
 .order('created_at', { ascending: false })

 if (error) throw new Error(error.message)
 return data
}
```

The `/tdd` skill helps you think through edge cases: what happens when `ownerId` is null, when the table is empty, or when Supabase returns a network error.

## Writing Tests That Actually Mock Supabase

The Supabase JS client is a chained object, which makes mocking slightly awkward. Ask Claude Code to generate a mock factory that preserves the chain:

```javascript
// supabase-mock.js
export function createSupabaseMock(responseData = null, responseError = null) {
 const mockChain = {
 from: jest.fn().mockReturnThis(),
 select: jest.fn().mockReturnThis(),
 eq: jest.fn().mockReturnThis(),
 order: jest.fn().mockReturnThis(),
 insert: jest.fn().mockReturnThis(),
 update: jest.fn().mockReturnThis(),
 delete: jest.fn().mockReturnThis(),
 single: jest.fn().mockResolvedValue({ data: responseData, error: responseError }),
 // Terminal methods that resolve the chain
 then: undefined
 };

 // Make the chain itself awaitable at the end
 mockChain.order.mockResolvedValue({ data: responseData, error: responseError });
 mockChain.eq.mockReturnThis();

 return {
 from: jest.fn(() => mockChain),
 _chain: mockChain
 };
}
```

With this mock in place, the `/tdd` skill produces tests that accurately exercise the error-handling paths:

```javascript
// projects.test.js
import { getProjectsByOwner } from './projects';
import { createSupabaseMock } from './supabase-mock';

jest.mock('./supabaseClient', () => ({
 supabase: createSupabaseMock()
}));

describe('getProjectsByOwner', () => {
 it('returns projects when the query succeeds', async () => {
 const mockData = [{ id: '1', title: 'Alpha', created_at: '2026-01-01' }];
 // Reset mock for this test
 jest.resetModules();
 // ... setup mock to return mockData
 const result = await getProjectsByOwner('user-123', 'active');
 expect(result).toEqual(mockData);
 });

 it('throws when Supabase returns an error', async () => {
 // Setup mock to return an error
 await expect(getProjectsByOwner(null, 'active')).rejects.toThrow();
 });

 it('handles empty result sets without throwing', async () => {
 // Setup mock to return empty array
 const result = await getProjectsByOwner('user-123', 'active');
 expect(Array.isArray(result)).toBe(true);
 });
});
```

Paste this pattern into Claude Code with your actual schema and it will fill in the remaining test cases and the implementation that passes them.

## Using /frontend-design for Supabase-Backed UIs

When you are building a UI that reads from or writes to Supabase, the `/frontend-design` skill loads guidance for component structure, accessibility, and responsive layouts.

```
/frontend-design

Build a React component that displays a list of projects fetched from Supabase.
Show a loading state, an empty state, and the list when data arrives.
```

Claude produces clean, accessible component code that integrates with your data layer. The skill's guidance ensures the UI handles the async nature of database queries properly. loading indicators, error boundaries, and empty state messaging.

A well-structured component from this workflow handles all three states explicitly:

```javascript
import { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';

export function ProjectList({ ownerId }) {
 const [projects, setProjects] = useState([]);
 const [loading, setLoading] = useState(true);
 const [error, setError] = useState(null);

 useEffect(() => {
 let cancelled = false;

 async function fetchProjects() {
 setLoading(true);
 setError(null);
 const { data, error } = await supabase
 .from('projects')
 .select('id, title, status, created_at')
 .eq('owner_id', ownerId)
 .eq('status', 'active')
 .order('created_at', { ascending: false });

 if (cancelled) return;

 if (error) {
 setError(error.message);
 } else {
 setProjects(data || []);
 }
 setLoading(false);
 }

 fetchProjects();
 return () => { cancelled = true; };
 }, [ownerId]);

 if (loading) return <div role="status" aria-live="polite">Loading projects...</div>;
 if (error) return <div role="alert">Error: {error}</div>;
 if (projects.length === 0) return <div>No active projects found.</div>;

 return (
 <ul aria-label="Project list">
 {projects.map(project => (
 <li key={project.id}>
 <span>{project.title}</span>
 <time dateTime={project.created_at}>
 {new Date(project.created_at).toLocaleDateString()}
 </time>
 </li>
 ))}
 </ul>
 );
}
```

The `cancelled` flag in the cleanup function prevents state updates on unmounted components. a common source of React warnings in Supabase-backed UIs. Ask Claude Code via the `/frontend-design` skill to check every async effect you write for this pattern.

## Realtime Subscriptions in the UI

Supabase Realtime adds a layer of complexity to component design. Ask Claude Code to extend any data-fetching component with a Realtime subscription:

```javascript
useEffect(() => {
 // Initial fetch
 fetchProjects();

 // Subscribe to changes
 const channel = supabase
 .channel('projects-changes')
 .on(
 'postgres_changes',
 {
 event: '*',
 schema: 'public',
 table: 'projects',
 filter: `owner_id=eq.${ownerId}`
 },
 (payload) => {
 if (payload.eventType === 'INSERT') {
 setProjects(prev => [payload.new, ...prev]);
 } else if (payload.eventType === 'UPDATE') {
 setProjects(prev => prev.map(p =>
 p.id === payload.new.id ? payload.new : p
 ));
 } else if (payload.eventType === 'DELETE') {
 setProjects(prev => prev.filter(p => p.id !== payload.old.id));
 }
 }
 )
 .subscribe();

 return () => {
 supabase.removeChannel(channel);
 };
}, [ownerId]);
```

The `/frontend-design` skill will also flag that this subscription pattern requires careful cleanup and that the filter syntax (`owner_id=eq.${ownerId}`) must match the column type exactly. UUIDs require no quotes, but strings do.

## Using /webapp-testing for Integration Testing

The `/webapp-testing` skill is useful for end-to-end testing of features that depend on your Supabase backend.

```
/webapp-testing

Write Playwright tests for the project list page.
The page fetches from Supabase. Mock the API calls
and test the loading, error, and success states.
```

This approach gives you integration tests that do not depend on a live Supabase instance in CI. the tests mock the network layer and verify the UI behavior independently.

A Playwright test that intercepts the Supabase REST API:

```javascript
// projects.spec.js
import { test, expect } from '@playwright/test';

const SUPABASE_URL = process.env.SUPABASE_URL;

test.describe('Project list page', () => {
 test('shows loading state then project list', async ({ page }) => {
 // Intercept the Supabase REST call
 await page.route(`${SUPABASE_URL}/rest/v1/projects*`, async route => {
 // Simulate a slight delay to catch loading state
 await new Promise(r => setTimeout(r, 100));
 await route.fulfill({
 status: 200,
 contentType: 'application/json',
 body: JSON.stringify([
 { id: '1', title: 'Alpha Project', status: 'active', created_at: '2026-01-01T00:00:00Z' }
 ])
 });
 });

 await page.goto('/projects');

 // Loading state should appear
 await expect(page.getByRole('status')).toBeVisible();

 // Data should load
 await expect(page.getByText('Alpha Project')).toBeVisible();
 });

 test('shows error state when API fails', async ({ page }) => {
 await page.route(`${SUPABASE_URL}/rest/v1/projects*`, async route => {
 await route.fulfill({ status: 500, body: 'Internal Server Error' });
 });

 await page.goto('/projects');
 await expect(page.getByRole('alert')).toBeVisible();
 });

 test('shows empty state when no projects exist', async ({ page }) => {
 await page.route(`${SUPABASE_URL}/rest/v1/projects*`, async route => {
 await route.fulfill({
 status: 200,
 contentType: 'application/json',
 body: '[]'
 });
 });

 await page.goto('/projects');
 await expect(page.getByText('No active projects found.')).toBeVisible();
 });
});
```

The key insight here is that Supabase's REST API uses predictable URL patterns (`/rest/v1/tablename`) that Playwright's route interceptor can match with a glob. You do not need a special Supabase testing library. standard HTTP mocking works.

## Using /docx and /pdf for Document Storage Workflows

If your application stores documents in Supabase Storage and you need to process their contents, the [`/pdf`](/best-claude-skills-for-data-analysis/) or `/docx` skills help you write the extraction code.

A common pattern:

1. User uploads a PDF to Supabase Storage via your application.
2. A database trigger or webhook fires.
3. A server-side function downloads the file and extracts text.
4. The extracted text gets stored back to a `documents` table for search.

```
/pdf

Write a Node.js function that downloads a PDF from a Supabase Storage
signed URL, extracts the text content using pdf-parse, and returns
a string. Include error handling for corrupt files and network failures.
```

Claude provides the implementation with proper error handling for each failure point.

Here is what a complete document processing function looks like when the `/pdf` skill shapes the implementation:

```javascript
import { createClient } from '@supabase/supabase-js';
import pdfParse from 'pdf-parse';

const supabase = createClient(
 process.env.SUPABASE_URL,
 process.env.SUPABASE_SERVICE_ROLE_KEY // Service role needed for storage access
);

export async function extractTextFromStoredPDF(bucketName, filePath) {
 // Generate a short-lived signed URL
 const { data: signedUrlData, error: urlError } = await supabase
 .storage
 .from(bucketName)
 .createSignedUrl(filePath, 60); // 60-second expiry

 if (urlError) {
 throw new Error(`Failed to generate signed URL: ${urlError.message}`);
 }

 // Download the file
 let pdfBuffer;
 try {
 const response = await fetch(signedUrlData.signedUrl);
 if (!response.ok) {
 throw new Error(`HTTP ${response.status} fetching PDF`);
 }
 const arrayBuffer = await response.arrayBuffer();
 pdfBuffer = Buffer.from(arrayBuffer);
 } catch (fetchError) {
 throw new Error(`Network failure downloading PDF: ${fetchError.message}`);
 }

 // Extract text
 try {
 const parsed = await pdfParse(pdfBuffer);
 return {
 text: parsed.text,
 pageCount: parsed.numpages,
 metadata: parsed.info
 };
 } catch (parseError) {
 throw new Error(`PDF parse failed (possibly corrupt): ${parseError.message}`);
 }
}

export async function processAndStoreDocument(bucketName, filePath, documentId) {
 const { text, pageCount } = await extractTextFromStoredPDF(bucketName, filePath);

 const { error } = await supabase
 .from('documents')
 .update({
 extracted_text: text,
 page_count: pageCount,
 processed_at: new Date().toISOString()
 })
 .eq('id', documentId);

 if (error) {
 throw new Error(`Failed to store extracted text: ${error.message}`);
 }

 return { success: true, pageCount };
}
```

The `/pdf` skill instructs Claude to handle each distinct failure mode. URL generation, network download, and parse errors. as separate throw points with descriptive messages rather than a single catch-all.

## Schema Design with Claude Code

You do not need a specific skill for database schema work. Claude Code itself handles SQL well. But you can combine the `/tdd` skill with schema design to produce a migration file and tests simultaneously:

```sql
-- Example: projects table
create table projects (
 id uuid default gen_random_uuid() primary key,
 owner_id uuid references auth.users not null,
 title text not null,
 status text default 'active' check (status in ('active', 'archived', 'deleted')),
 created_at timestamptz default now()
);

-- Row-Level Security
alter table projects enable row level security;

create policy "Users can read their own projects"
 on projects for select
 using (auth.uid() = owner_id);

create policy "Users can insert their own projects"
 on projects for insert
 with check (auth.uid() = owner_id);
```

Ask Claude to review your schema for common issues. missing indexes, overly permissive RLS policies, or enum patterns that should use a lookup table.

## Common Schema Issues Claude Code Catches

When you paste a migration and ask Claude Code to review it, the most frequent findings are:

Missing indexes on foreign keys and filter columns:
```sql
-- Add these after the table creation
create index projects_owner_id_idx on projects(owner_id);
create index projects_status_idx on projects(status);
create index projects_created_at_idx on projects(created_at desc);
```

PostgreSQL does not automatically index foreign keys. If your app filters projects by `owner_id` and that column has no index, every query does a full table scan. something that works fine at 1,000 rows and becomes a serious bottleneck at 100,000.

Overly broad RLS policies:

A common mistake is writing an `UPDATE` policy that allows users to change any column including `owner_id`:

```sql
-- Dangerous: allows a user to reassign projects to another owner
create policy "Users can update their own projects"
 on projects for update
 using (auth.uid() = owner_id);

-- Better: use a security definer function or restrict updatable columns
-- at the application layer, since PostgreSQL RLS cannot restrict columns
```

Claude Code will flag this when you ask it to audit your policies.

Using text for status instead of an enum or lookup table:

```sql
-- If status values need to be enforced across multiple tables, use an enum
create type project_status as enum ('active', 'archived', 'deleted');

alter table projects
 alter column status type project_status
 using status::project_status;
```

This prevents invalid status values from being inserted by any code path, not just application-level validation.

## Generating Migrations from Schema Reviews

After Claude Code identifies schema improvements, ask it to generate a numbered migration file:

```
Review this schema and produce a migration file that adds the missing indexes
and converts the status column to an enum. Name it 20260315_projects_improvements.sql.
```

Claude generates the migration with the `alter table` and `create index` statements in the correct dependency order, with rollback comments where needed.

## RLS Policy Testing: The Most Overlooked Step

Row-Level Security is silent by default. A misconfigured policy either blocks legitimate access (returning empty results with no error) or permits unauthorized access (returning data it should not). Neither failure mode produces an obvious error message.

Ask Claude Code with the `/tdd` skill to generate RLS policy tests using Supabase's built-in test helpers or `pg_tap`:

```sql
-- Test that users cannot read other users' projects
begin;
select plan(3);

-- Simulate user A
set local role authenticated;
set local "request.jwt.claims" to '{"sub": "user-a-uuid"}';

select results_eq(
 'select count(*) from projects where owner_id = ''user-b-uuid''',
 'select 0::bigint',
 'User A cannot read User B projects'
);

-- Simulate user B
set local "request.jwt.claims" to '{"sub": "user-b-uuid"}';

select results_eq(
 'select count(*) from projects where owner_id = ''user-b-uuid''',
 'select 1::bigint',
 'User B can read their own projects'
);

select results_eq(
 'select count(*) from projects where owner_id = ''user-a-uuid''',
 'select 0::bigint',
 'User B cannot read User A projects'
);

select finish();
rollback;
```

These tests run directly in PostgreSQL via Supabase's SQL editor or your migration tooling. They verify the policy logic at the database layer, independently of any application code.

## Practical Tips

Keep credentials out of prompts: Never paste your Supabase service role key into a Claude Code session. Use environment variable names in your code examples and keep actual keys in `.env` files outside version control.

Use the anon key for client-side code: The anon key combined with Row-Level Security policies is the correct pattern for browser and mobile clients. The service role key bypasses RLS and should only appear in trusted server-side code.

Test RLS policies explicitly: RLS bugs are silent. a policy that is too permissive allows data leaks without errors. Use the `/tdd` skill to write tests that verify policies reject unauthorized access, not just that they allow authorized access.

Separate your Supabase client initialization: If you initialize the Supabase client inline in every file that uses it, you end up with multiple client instances and inconsistent auth state. Create a single `supabaseClient.js` module and import from it everywhere:

```javascript
// supabaseClient.js. create once, import everywhere
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
 process.env.NEXT_PUBLIC_SUPABASE_URL,
 process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);
```

When you ask Claude Code to generate any Supabase-using module, tell it to import from this shared client rather than calling `createClient` again.

Ask Claude to generate TypeScript types from your schema: Supabase's CLI can generate types automatically (`supabase gen types typescript`), but you can also paste your schema into Claude Code and ask it to write the TypeScript interfaces manually for when the CLI is not available:

```typescript
// Generated from projects table schema
export interface Project {
 id: string; // uuid
 owner_id: string; // uuid, references auth.users
 title: string; // text, not null
 status: 'active' | 'archived' | 'deleted';
 created_at: string; // timestamptz, ISO 8601 string in JS
}

export type NewProject = Omit<Project, 'id' | 'created_at'>;
export type ProjectUpdate = Partial<Omit<Project, 'id' | 'owner_id' | 'created_at'>>;
```

Typed query functions catch a large class of bugs at compile time rather than at runtime in production.

## Choosing the Right Skill for Each Supabase Task

A quick reference for which skill to invoke for common Supabase work:

| Task | Recommended skill | Why |
|------|------------------|-----|
| Write a new query function | `/tdd` | Gets tests alongside the implementation |
| Build a data display component | `/frontend-design` | Handles async states and accessibility |
| End-to-end test a feature | `/webapp-testing` | Produces Playwright tests with API mocking |
| Extract content from uploaded files | `/pdf` or `/docx` | Handles file parse error patterns |
| Review or design a schema | No skill needed | Claude handles SQL without a skill |
| Write RLS policies and tests | `/tdd` | Drives test-first policy verification |
| Write an Edge Function | No skill needed | Ask Claude to use Deno-compatible patterns explicitly |

No skill is required for pure schema or SQL work. Claude Code's baseline SQL knowledge is strong enough. Skills add the most value when you need structured output (tests + implementation) or domain-specific patterns (accessible component structure, file parsing error handling).

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-with-supabase-database-integration)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Data Analysis](/best-claude-skills-for-data-analysis/). Skills for data-heavy workflows
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Keep long sessions cost-efficient
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate in context

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

