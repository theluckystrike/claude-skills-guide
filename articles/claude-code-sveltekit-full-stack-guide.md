---

layout: default
title: "Build SvelteKit Apps with Claude Code (2026)"
description: "Build full-stack SvelteKit applications faster with Claude Code. Covers server routes, form actions, load functions, and deployment configuration."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, sveltekit, full-stack, web-development, ai-coding, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-sveltekit-full-stack-guide/
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-21"
---

SvelteKit has become a top choice for developers seeking a unified framework that handles both frontend and backend logic. When paired with Claude Code, you gain an AI coding assistant that understands your project structure, generates type-safe code, and helps you navigate the full development lifecycle from scaffolding to deployment.

This guide covers practical workflows for building SvelteKit applications with Claude Code, including skill recommendations, project setup strategies, and patterns for maintaining quality throughout your development process.

## Why SvelteKit and Claude Code Work Well Together

SvelteKit's file-based conventions give Claude Code strong structural context to work with. When Claude Code reads your `src/routes/` directory, it immediately understands your application's page hierarchy, data loading patterns, and API surface. This makes code generation significantly more accurate than working with frameworks that rely heavily on runtime configuration.

The tight coupling between server and client code in SvelteKit, where `+page.ts`, `+page.server.ts`, and `+page.svelte` files live side by side, also maps naturally to how Claude Code generates related code. Ask Claude Code to build a feature, and it will produce all three file types with consistent types flowing between them.

| Framework Feature | Claude Code Benefit |
|------------------|---------------------|
| File-based routing | Structural understanding without extra context |
| Co-located load functions | Consistent type generation across files |
| Form actions | End-to-end form handling in a single prompt |
| TypeScript by default | Accurate type inference in generated code |
| Unified SSR/CSR | Fewer context switches during development |

## Initializing a SvelteKit Project with Claude Code

Before invoking Claude Code, ensure your development environment is ready. Create a new SvelteKit project using the official CLI:

```bash
npm create svelte@latest my-app
cd my-app
npm install
```

Select TypeScript during setup for better type safety and improved Claude Code context understanding. Once your project structure exists, you can invoke Claude Code within the project directory:

```bash
claude
```

Claude Code will read your project files, enabling it to understand imports, routing structure, and configuration files. Adding a `CLAUDE.md` in the project root with project context helps Claude Code provide more accurate suggestions.

A useful `CLAUDE.md` for a SvelteKit project might include:

```markdown
Project Context

This is a SvelteKit application for [description].

Stack
- SvelteKit with TypeScript
- Prisma ORM with PostgreSQL
- Tailwind CSS for styling
- Vitest for unit tests, Playwright for e2e

Conventions
- Server-only logic goes in src/lib/server/
- Shared types go in src/lib/types.ts
- All API routes return JSON via the json() helper
- Form validation uses zod schemas defined alongside server actions
```

The more precise your `CLAUDE.md`, the less time you spend correcting generated code that violates your project's conventions.

## Essential Claude Skills for SvelteKit Development

Several Claude skills enhance your SvelteKit workflow significantly:

- frontend-design: Generates responsive layouts, component structures, and CSS patterns tailored to your design requirements
- tdd: Creates test files alongside implementation code, establishing a test-driven development workflow
- pdf: Generates documentation, API references, and reports directly from your codebase
- supermemory: Maintains context across sessions, recalling previous decisions and patterns

Install these skills using the Claude CLI to reach their full potential within your SvelteKit projects.

When to activate each skill during a SvelteKit project:

| Development Phase | Recommended Skills |
|-------------------|-------------------|
| UI component work | frontend-design |
| Building API routes | tdd |
| Database schema design | tdd, supermemory |
| Writing tests | tdd |
| Generating docs or changelogs | pdf |
| Long multi-session features | supermemory |

## Building API Routes and Server-Side Logic

SvelteKit's file-based routing extends naturally to API endpoints. Create server-side logic by placing files in `src/routes/api/` directories. Claude Code excels at generating these endpoints with proper TypeScript typing:

```typescript
// src/routes/api/users/+server.ts
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

interface User {
 id: string;
 email: string;
 createdAt: Date;
}

export const GET: RequestHandler = async ({ url }) => {
 const limit = Number(url.searchParams.get('limit') ?? 10);
 const users: User[] = await fetchUsers(limit);

 return json(users);
};

async function fetchUsers(limit: number): Promise<User[]> {
 // Database query logic here
 return [];
}
```

For more complex endpoints that handle multiple HTTP methods and include authentication checks, Claude Code can generate the full handler with proper error responses:

```typescript
// src/routes/api/posts/[id]/+server.ts
import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { db } from '$lib/server/db';

export const GET: RequestHandler = async ({ params, locals }) => {
 const post = await db.post.findUnique({
 where: { id: params.id },
 include: { author: { select: { id: true, email: true } } }
 });

 if (!post) {
 throw error(404, 'Post not found');
 }

 if (!post.published && locals.user?.id !== post.authorId) {
 throw error(403, 'Forbidden');
 }

 return json(post);
};

export const DELETE: RequestHandler = async ({ params, locals }) => {
 if (!locals.user) {
 throw error(401, 'Unauthorized');
 }

 const post = await db.post.findUnique({ where: { id: params.id } });

 if (!post) throw error(404, 'Post not found');
 if (post.authorId !== locals.user.id) throw error(403, 'Forbidden');

 await db.post.delete({ where: { id: params.id } });
 return new Response(null, { status: 204 });
};
```

When working with form actions, Claude Code helps you implement the recommended SvelteKit pattern:

```typescript
// src/routes/contact/+page.server.ts
import { fail } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
 default: async ({ request }) => {
 const data = await request.formData();
 const email = data.get('email');

 if (!email || typeof email !== 'string') {
 return fail(400, { missing: true });
 }

 // Process form submission
 return { success: true };
 }
};
```

## Data Loading Patterns

SvelteKit's load functions are where server-side data fetching happens. Claude Code generates both universal and server-only load functions, maintaining the distinction between what's safe to expose to the client and what must stay on the server.

```typescript
// src/routes/blog/[slug]/+page.server.ts
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { db } from '$lib/server/db';

export const load: PageServerLoad = async ({ params, locals }) => {
 const post = await db.post.findUnique({
 where: { slug: params.slug },
 include: {
 author: { select: { id: true, name: true } },
 tags: true
 }
 });

 if (!post || (!post.published && !locals.user?.isAdmin)) {
 throw error(404, 'Not found');
 }

 return {
 post,
 isOwner: locals.user?.id === post.authorId
 };
};
```

The returned data flows directly into your Svelte component via the `data` prop, fully typed thanks to SvelteKit's generated `$types`:

```svelte
<!-- src/routes/blog/[slug]/+page.svelte -->
<script lang="ts">
 import type { PageData } from './$types';

 let { data }: { data: PageData } = $props();
</script>

<article>
 <h1>{data.post.title}</h1>
 <p>By {data.post.author.name}</p>
 <div>{@html data.post.content}</div>
 {#if data.isOwner}
 <a href="/blog/{data.post.slug}/edit">Edit</a>
 {/if}
</article>
```

When prompting Claude Code for load functions, specify whether data should be cached, streamed, or invalidated on form submission. These hints produce code that handles SvelteKit's caching behaviors correctly.

## Database Integration Patterns

For database operations, pair SvelteKit with Prisma, Drizzle, or another ORM. Claude Code generates type-safe queries and migrations. With Prisma, request schema definitions:

```prisma
// prisma/schema.prisma
model Post {
 id String @id @default(cuid())
 title String
 content String
 published Boolean @default(false)
 author User @relation(fields: [authorId], references: [id])
 authorId String
 createdAt DateTime @default(now())
}

model User {
 id String @id @default(cuid())
 email String @unique
 posts Post[]
}
```

Run `npx prisma generate` after creating schemas, then invoke Claude Code to generate service functions that encapsulate database logic in `src/lib/server/`.

A well-structured service layer separates database logic from your route handlers:

```typescript
// src/lib/server/posts.ts
import { db } from './db';

export async function getPublishedPosts(page: number, perPage = 10) {
 const [posts, total] = await Promise.all([
 db.post.findMany({
 where: { published: true },
 orderBy: { createdAt: 'desc' },
 skip: (page - 1) * perPage,
 take: perPage,
 include: { author: { select: { name: true } } }
 }),
 db.post.count({ where: { published: true } })
 ]);

 return {
 posts,
 total,
 pages: Math.ceil(total / perPage)
 };
}

export async function createPost(authorId: string, data: {
 title: string;
 content: string;
 published?: boolean;
}) {
 return db.post.create({
 data: { ...data, authorId }
 });
}
```

With Drizzle as an alternative, Claude Code can generate the schema and query files with equivalent type safety using a different API style. Specify your ORM preference clearly in your `CLAUDE.md` so Claude Code doesn't mix patterns.

## Frontend Component Development

For component development, combine Svelte's reactivity with TypeScript. Claude Code generates components following established patterns:

```svelte
<!-- src/lib/components/PostCard.svelte -->
<script lang="ts">
 interface Props {
 title: string;
 excerpt: string;
 published: boolean;
 onPublish?: () => void;
 }

 let { title, excerpt, published, onPublish }: Props = $props();
</script>

<article class="post-card">
 <h2>{title}</h2>
 <p>{excerpt}</p>
 {#if !published}
 <button onclick={onPublish}>Publish</button>
 {/if}
</article>

<style>
 .post-card {
 padding: 1rem;
 border: 1px solid #e5e5e5;
 border-radius: 8px;
 }
</style>
```

For more stateful components, Claude Code handles Svelte 5 runes correctly. Ask for a data table with sorting and pagination:

```svelte
<!-- src/lib/components/DataTable.svelte -->
<script lang="ts" generics="T extends Record<string, unknown>">
 interface Column {
 key: keyof T & string;
 label: string;
 sortable?: boolean;
 }

 interface Props {
 rows: T[];
 columns: Column[];
 }

 let { rows, columns }: Props = $props();

 let sortKey = $state<string | null>(null);
 let sortDir = $state<'asc' | 'desc'>('asc');

 let sorted = $derived(() => {
 if (!sortKey) return rows;
 return [...rows].sort((a, b) => {
 const av = a[sortKey as keyof T];
 const bv = b[sortKey as keyof T];
 const cmp = av < bv ? -1 : av > bv ? 1 : 0;
 return sortDir === 'asc' ? cmp : -cmp;
 });
 });

 function toggleSort(key: string) {
 if (sortKey === key) {
 sortDir = sortDir === 'asc' ? 'desc' : 'asc';
 } else {
 sortKey = key;
 sortDir = 'asc';
 }
 }
</script>

<table>
 <thead>
 <tr>
 {#each columns as col}
 <th onclick={() => col.sortable && toggleSort(col.key)}>
 {col.label}
 {#if col.sortable && sortKey === col.key}
 {sortDir === 'asc' ? '↑' : '↓'}
 {/if}
 </th>
 {/each}
 </tr>
 </thead>
 <tbody>
 {#each sorted() as row}
 <tr>
 {#each columns as col}
 <td>{row[col.key]}</td>
 {/each}
 </tr>
 {/each}
 </tbody>
</table>
```

When building forms, use SvelteKit's enhanced form handling with `use:enhance`:

```svelte
<!-- src/routes/contact/+page.svelte -->
<script lang="ts">
 import { enhance } from '$app/forms';

 let loading = $state(false);
</script>

<form method="POST" use:enhance={() => {
 loading = true;
 return async ({ update }) => {
 await update();
 loading = false;
 };
}}>
 <label>
 Email
 <input type="email" name="email" required />
 </label>
 <button disabled={loading}>
 {loading ? 'Sending...' : 'Submit'}
 </button>
</form>
```

## Authentication and Session Management

Authentication is one of the more complex full-stack concerns in SvelteKit. Claude Code can generate a complete session-based auth setup using hooks and cookies:

```typescript
// src/hooks.server.ts
import type { Handle } from '@sveltejs/kit';
import { db } from '$lib/server/db';

export const handle: Handle = async ({ event, resolve }) => {
 const sessionToken = event.cookies.get('session');

 if (sessionToken) {
 const session = await db.session.findUnique({
 where: { token: sessionToken },
 include: { user: { select: { id: true, email: true, role: true } } }
 });

 if (session && session.expiresAt > new Date()) {
 event.locals.user = session.user;
 } else if (session) {
 // Clean up expired sessions
 await db.session.delete({ where: { token: sessionToken } });
 event.cookies.delete('session', { path: '/' });
 }
 }

 return resolve(event);
};
```

When asking Claude Code to generate auth flows, specify which parts need CSRF protection, rate limiting, and whether you want cookie-based or JWT-based sessions. Being explicit about security requirements produces more complete implementations.

## Testing Your Application

The tdd skill proves valuable for establishing testing workflows. Install it and request test generation for critical paths. SvelteKit supports Vitest for unit testing and Playwright for end-to-end tests:

```typescript
// src/lib/utils/validation.test.ts
import { describe, it, expect } from 'vitest';
import { validateEmail } from './validation';

describe('validateEmail', () => {
 it('accepts valid email addresses', () => {
 expect(validateEmail('user@example.com')).toBe(true);
 });

 it('rejects invalid email addresses', () => {
 expect(validateEmail('invalid')).toBe(false);
 });
});
```

For testing server-side logic, mock the database with Vitest:

```typescript
// src/lib/server/posts.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { getPublishedPosts } from './posts';

vi.mock('./db', () => ({
 db: {
 post: {
 findMany: vi.fn(),
 count: vi.fn()
 }
 }
}));

import { db } from './db';

describe('getPublishedPosts', () => {
 beforeEach(() => vi.clearAllMocks());

 it('returns paginated posts', async () => {
 vi.mocked(db.post.findMany).mockResolvedValue([
 { id: '1', title: 'Test Post', author: { name: 'Alice' } }
 ] as any);
 vi.mocked(db.post.count).mockResolvedValue(1);

 const result = await getPublishedPosts(1, 10);
 expect(result.posts).toHaveLength(1);
 expect(result.total).toBe(1);
 expect(result.pages).toBe(1);
 });
});
```

For Playwright end-to-end tests, Claude Code generates test files that cover user flows:

```typescript
// tests/blog.test.ts
import { test, expect } from '@playwright/test';

test('published posts appear on the blog index', async ({ page }) => {
 await page.goto('/blog');
 await expect(page.getByRole('heading', { level: 2 })).toHaveCount.greaterThan(0);
});

test('unpublished posts are not visible to anonymous users', async ({ page }) => {
 await page.goto('/blog/draft-post-slug');
 await expect(page).toHaveURL('/404');
});
```

Run tests with `npm test` for unit tests or `npx playwright test` for end-to-end coverage.

## Deployment Considerations

When deploying to platforms like Vercel, Netlify, or Cloudflare Pages, ensure your `svelte.config.js` adapter matches your target:

```javascript
// svelte.config.js
import adapter from '@sveltejs/adapter-vercel';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/ @type {import('@sveltejs/kit').Config} */
const config = {
 preprocess: vitePreprocess(),
 kit: {
 adapter: adapter()
 }
};

export default config;
```

Claude Code can generate environment-specific configuration files and help you set up preview deployments for pull requests.

Adapter selection depends on your deployment target:

| Platform | Adapter | Notes |
|----------|---------|-------|
| Vercel | `@sveltejs/adapter-vercel` | Auto-detects, good default |
| Netlify | `@sveltejs/adapter-netlify` | Supports edge functions |
| Cloudflare Pages | `@sveltejs/adapter-cloudflare` | Fast global edge network |
| Node.js server | `@sveltejs/adapter-node` | For self-hosted VMs or containers |
| Static export | `@sveltejs/adapter-static` | No server-side logic; CDN-friendly |

When switching adapters, ask Claude Code to audit your route files for patterns that are incompatible with your target. For example, `adapter-static` cannot build pages with server-side load functions, Claude Code will flag and help resolve those conflicts.

For environment variables, SvelteKit distinguishes between public variables prefixed with `PUBLIC_` and server-only secrets. Claude Code respects this distinction in generated code, avoiding the common mistake of exposing database credentials to the client bundle:

```typescript
// Correct: server-only variable, never sent to browser
import { DATABASE_URL } from '$env/static/private';

// Correct: public variable, safe to expose
import { PUBLIC_API_BASE_URL } from '$env/static/public';
```

## Workflow Summary

Your SvelteKit development with Claude Code follows a consistent pattern: scaffold your project, install relevant skills, generate code with clear specifications, and validate through tests. The combination of SvelteKit's cohesive architecture and Claude Code's contextual understanding creates a productive environment for building full-stack applications.

Work through features in this order: define your data model and Prisma schema first, generate service functions and tests next, build API routes and form actions, then create the Svelte components that consume them. This bottom-up approach gives Claude Code the data types it needs before generating UI code, which results in components with accurate typing from the start.

For documentation needs, the pdf skill generates project documentation directly from your source code and route structure, keeping your docs synchronized with implementation. Use it at the end of each feature cycle to capture the API surface before it gets stale.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-sveltekit-full-stack-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Vercel Supabase Clerk Full Stack Development](/claude-code-for-vercel-supabase-clerk-full-stack/)
- [Claude Code Remix Full Stack Workflow Guide](/claude-code-remix-full-stack-workflow-guide/)
- [Claude Code Skills for Product Engineers Building Full Stack](/claude-code-skills-for-product-engineers-building-full-stack/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code for ROS2 Nav2 Stack Development (2026)](/claude-code-ros2-navigation-stack-2026/)
- [Disk Space Full During Operation Fix](/claude-code-disk-space-full-during-operation-fix-2026/)
- [Claude Code ENOSPC Disk Full Error — Fix (2026)](/claude-code-enospc-disk-full-fix/)
