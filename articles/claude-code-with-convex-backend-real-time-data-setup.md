---
layout: default
title: "Claude Code With Convex Backend"
description: "Learn how to set up Convex as a backend for real-time data in your Claude Code projects. Practical code examples and integration patterns for developers."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [integrations]
tags: [claude-code, claude-skills, claude-code, convex, backend, real-time-data, database, tutorial]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-with-convex-backend-real-time-data-setup/
geo_optimized: true
---

# Claude Code With Convex Backend Real-Time Data Setup

Convex provides a powerful backend-as-a-service platform that handles real-time data synchronization automatically. When combined with Claude Code, you get an end-to-end development experience where your AI assistant can read, write, and react to data changes in real time. This guide shows you how to integrate Convex with Claude Code to build reactive applications. covering schema design, backend functions, frontend hooks, scheduled jobs, and production concerns.

## Why Convex Works Well With Claude Code

Convex eliminates the need for manual API endpoints and WebSocket connections. The platform automatically synchronizes data between your frontend and backend, which means Claude Code can query and mutate data without complex setup. When you use the supermemory skill alongside Convex, you can persist conversation context across sessions while maintaining real-time sync with your application data.

The combination is particularly effective for building collaborative features like live dashboards, chat applications, and collaborative editing tools. Your Claude Code agent can directly interact with Convex functions, making it feel like working with a knowledgeable teammate who understands your entire data layer.

Beyond the DX convenience, Convex's architecture removes an entire category of bugs. Traditional stacks require you to invalidate caches, emit WebSocket events, and handle reconnection logic manually. Convex uses a reactive query model. every `query` function is re-run automatically when the underlying data changes, and the result is pushed to every subscribed client. This means you cannot accidentally forget to broadcast an update.

## Convex vs. Alternatives

Before committing to Convex, it helps to understand how it sits alongside other backend options a Claude Code project might use:

| Feature | Convex | Supabase | Firebase | PlanetScale |
|---------|--------|----------|----------|-------------|
| Real-time subscriptions | Built-in, reactive | Via Realtime channels | Via Firestore listeners | Polling only |
| TypeScript-first schema | Yes (codegen) | Partial | No | Partial (via Prisma) |
| Serverless functions | Yes (collocated) | Edge Functions | Cloud Functions | No |
| Scheduled jobs | Built-in cron | pg_cron (manual) | Cloud Scheduler | No |
| Full-text search | Built-in | pg_trgm / pgvector | Third-party | Third-party |
| Transactions | ACID per mutation | ACID | Limited | ACID |
| Pricing model | Function executions | Compute + storage | Pay per read/write | Rows + connections |

Convex is the strongest choice when your primary need is reactive UIs with minimal backend infrastructure. Supabase wins if you need raw SQL power. Firebase suits mobile-first projects with existing GCP infrastructure.

## Setting Up Convex in Your Project

Start by creating a new project or navigating to an existing one. Install the Convex CLI and initialize the backend:

```bash
npm install convex
npx convex dev
```

The initialization process creates a `convex/` directory with generated TypeScript types and a `_generated/` folder. These types ensure type safety between your frontend queries and backend functions.

The `npx convex dev` command does two things: it starts a local development server that syncs your `convex/` directory to Convex's cloud, and it watches for file changes and regenerates types automatically. Leave it running in a terminal while you develop. every time you save a backend function, the updated version is live within seconds.

Create a schema file at `convex/schema.ts` to define your data structure:

```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
 tasks: defineTable({
 title: v.string(),
 completed: v.boolean(),
 assignee: v.string(),
 createdAt: v.number(),
 priority: v.optional(v.union(v.literal("low"), v.literal("medium"), v.literal("high"))),
 }).index("by_assignee", ["assignee"])
 .index("by_completed", ["completed"]),
 messages: defineTable({
 content: v.string(),
 userId: v.string(),
 timestamp: v.number(),
 roomId: v.string(),
 }).index("by_room", ["roomId", "timestamp"]),
});
```

A few notes on schema design. Using `v.optional()` for fields added after launch prevents migration friction. Convex does not require backfilling existing documents when you add optional fields. Adding indexes at schema definition time avoids full-table scans in production; the `by_room` composite index on `[roomId, timestamp]` means fetching a room's message history is a direct index lookup rather than filtering the entire `messages` table.

## Writing Backend Functions

Convex backend functions live in the `convex/` directory. Create a file at `convex/tasks.ts` to handle task operations:

```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const getTasks = query({
 args: {},
 handler: async (ctx) => {
 const tasks = await ctx.db.query("tasks").collect();
 return tasks.sort((a, b) => b.createdAt - a.createdAt);
 },
});

export const createTask = mutation({
 args: {
 title: v.string(),
 assignee: v.string(),
 },
 handler: async (ctx, args) => {
 const taskId = await ctx.db.insert("tasks", {
 title: args.title,
 completed: false,
 assignee: args.assignee,
 createdAt: Date.now(),
 });
 return taskId;
 },
});

export const toggleComplete = mutation({
 args: {
 id: v.id("tasks"),
 },
 handler: async (ctx, args) => {
 const task = await ctx.db.get(args.id);
 if (task) {
 await ctx.db.patch(args.id, { completed: !task.completed });
 }
 },
});
```

These functions handle reading and writing data. The `query` functions run on read operations, while `mutation` functions handle writes. Claude Code can call these functions directly through the Convex client.

For more complex data access, use the index-based query API to avoid collection scans:

```typescript
export const getTasksByAssignee = query({
 args: { assignee: v.string() },
 handler: async (ctx, args) => {
 return await ctx.db
 .query("tasks")
 .withIndex("by_assignee", (q) => q.eq("assignee", args.assignee))
 .filter((q) => q.eq(q.field("completed"), false))
 .collect();
 },
});

export const updatePriority = mutation({
 args: {
 id: v.id("tasks"),
 priority: v.union(v.literal("low"), v.literal("medium"), v.literal("high")),
 },
 handler: async (ctx, args) => {
 await ctx.db.patch(args.id, { priority: args.priority });
 },
});
```

The `.withIndex()` call tells Convex to use the `by_assignee` index rather than scanning every document. This is the single most important performance habit in Convex. any query on a field that is not an index key will degrade linearly as your table grows.

## Validation and Authorization in Mutations

Production mutations should validate identity before performing writes. Convex integrates with Clerk, Auth0, and other identity providers through the `ctx.auth` context:

```typescript
export const createTaskSecure = mutation({
 args: {
 title: v.string(),
 },
 handler: async (ctx, args) => {
 const identity = await ctx.auth.getUserIdentity();
 if (!identity) {
 throw new Error("Unauthenticated: must be logged in to create tasks");
 }

 return await ctx.db.insert("tasks", {
 title: args.title,
 completed: false,
 assignee: identity.subject,
 createdAt: Date.now(),
 });
 },
});
```

Putting authorization checks inside the mutation. rather than relying on the client to enforce them. ensures that even direct API calls cannot bypass access control.

## Connecting Frontend to Real-Time Data

Install the Convex client in your frontend:

```bash
npm install convex
```

Configure the provider in your application entry point:

```typescript
import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export function App({ children }: { children: React.ReactNode }) {
 return (
 <ConvexProvider client={convex}>
 {children}
 </ConvexProvider>
 );
}
```

Query real-time data with the `useQuery` hook:

```typescript
import { useQuery } from "convex/react";
import { api } from "../convex/_generated/api";

function TaskList() {
 const tasks = useQuery(api.tasks.getTasks);

 if (!tasks) return <div>Loading...</div>;

 return (
 <ul>
 {tasks.map((task) => (
 <li key={task._id}>
 <input
 type="checkbox"
 checked={task.completed}
 onChange={() => toggleComplete(task._id)}
 />
 {task.title} - {task.assignee}
 </li>
 ))}
 </ul>
 );
}
```

The hook automatically re-renders when data changes on the server. This means multiple users see updates without polling or manual refresh.

For mutations, use the `useMutation` hook:

```typescript
import { useMutation } from "convex/react";
import { api } from "../convex/_generated/api";

function AddTaskForm() {
 const createTask = useMutation(api.tasks.createTask);
 const [title, setTitle] = React.useState("");

 const handleSubmit = async (e: React.FormEvent) => {
 e.preventDefault();
 if (!title.trim()) return;
 await createTask({ title, assignee: "current-user" });
 setTitle("");
 };

 return (
 <form onSubmit={handleSubmit}>
 <input
 value={title}
 onChange={(e) => setTitle(e.target.value)}
 placeholder="Task title"
 />
 <button type="submit">Add Task</button>
 </form>
 );
}
```

Convex mutations are optimistic by default when used through `useMutation`. the UI updates immediately and rolls back if the server rejects the write. This removes a class of latency problems common in traditional REST APIs.

## Using Claude Code With Convex

When Claude Code has access to your Convex setup, it can generate CRUD operations, suggest schema improvements, and even write test cases. Use the tdd skill to create comprehensive tests for your Convex functions:

```typescript
// test/tasks.spec.ts
import { expect, test } from "vitest";
import { api } from "../convex/_generated/api";
import { convexTest } from "convex-test";
import schema from "../convex/schema";

test("createTask adds a new task", async () => {
 const t = convexTest(schema);

 const taskId = await t.mutation(api.tasks.createTask, {
 title: "Test task",
 assignee: "testuser",
 });

 expect(taskId).toBeDefined();

 const tasks = await t.query(api.tasks.getTasks, {});
 expect(tasks).toHaveLength(1);
 expect(tasks[0].title).toBe("Test task");
 expect(tasks[0].completed).toBe(false);
});

test("toggleComplete flips completion state", async () => {
 const t = convexTest(schema);

 const taskId = await t.mutation(api.tasks.createTask, {
 title: "Flippable task",
 assignee: "testuser",
 });

 await t.mutation(api.tasks.toggleComplete, { id: taskId });

 const tasks = await t.query(api.tasks.getTasks, {});
 expect(tasks[0].completed).toBe(true);

 await t.mutation(api.tasks.toggleComplete, { id: taskId });
 const tasksAfter = await t.query(api.tasks.getTasks, {});
 expect(tasksAfter[0].completed).toBe(false);
});
```

The `convex-test` package provides an in-memory Convex environment so you do not need a live deployment to run unit tests. This makes CI fast and deterministic.

The frontend-design skill helps generate UI components that work with your Convex data, ensuring your interface properly handles loading states and real-time updates.

## Handling Real-Time Updates Beyond the Frontend

Convex supports scheduled functions for background processing. Create at `convex/scheduled.ts`:

```typescript
import { internalMutation, cronJobs } from "./_generated/server";
import { internal } from "./_generated/api";

const crons = cronJobs();

crons.daily(
 "cleanup old tasks",
 { hourUTC: 2, minuteUTC: 0 },
 internal.scheduled.cleanupOldTasks
);

export default crons;

export const cleanupOldTasks = internalMutation({
 args: {},
 handler: async (ctx) => {
 const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;
 const oldTasks = await ctx.db
 .query("tasks")
 .filter((q) => q.lt(q.field("createdAt"), thirtyDaysAgo))
 .collect();

 for (const task of oldTasks) {
 await ctx.db.delete(task._id);
 }

 return { deleted: oldTasks.length };
 },
});
```

Note the use of `internalMutation` instead of `mutation`. Internal functions cannot be called from the client. they are only reachable from other server-side functions and scheduled jobs. This is the right pattern for maintenance operations you do not want to expose as a public API.

Convex also supports one-off scheduled calls from within a mutation:

```typescript
export const createTaskWithReminder = mutation({
 args: {
 title: v.string(),
 assignee: v.string(),
 reminderInMs: v.number(),
 },
 handler: async (ctx, args) => {
 const taskId = await ctx.db.insert("tasks", {
 title: args.title,
 completed: false,
 assignee: args.assignee,
 createdAt: Date.now(),
 });

 await ctx.scheduler.runAfter(
 args.reminderInMs,
 internal.notifications.sendReminder,
 { taskId, assignee: args.assignee }
 );

 return taskId;
 },
});
```

`ctx.scheduler.runAfter` schedules a function to run after a delay in milliseconds. This is useful for reminders, follow-up emails, or deferred processing without needing a separate queue infrastructure.

## Production Considerations

When deploying to production, configure your Convex deployment appropriately:

```bash
npx convex deploy
```

Set environment variables for sensitive configuration through the Convex dashboard rather than in code. Access them in functions via `process.env`:

```typescript
export const sendWebhook = internalMutation({
 args: { payload: v.string() },
 handler: async (ctx, args) => {
 const webhookUrl = process.env.WEBHOOK_SECRET_URL;
 if (!webhookUrl) throw new Error("WEBHOOK_SECRET_URL not configured");

 await fetch(webhookUrl, {
 method: "POST",
 headers: { "Content-Type": "application/json" },
 body: args.payload,
 });
 },
});
```

For rate limiting, Convex does not provide built-in rate limiting primitives, but you can implement token bucket logic in a mutation using a dedicated table:

```typescript
// convex/schema.ts. add to schema
rateLimits: defineTable({
 key: v.string(),
 tokens: v.number(),
 lastRefill: v.number(),
}).index("by_key", ["key"]),
```

```typescript
// convex/rateLimit.ts
export async function checkRateLimit(
 ctx: MutationCtx,
 key: string,
 maxTokens: number,
 refillRateMs: number
): Promise<boolean> {
 const existing = await ctx.db
 .query("rateLimits")
 .withIndex("by_key", (q) => q.eq("key", key))
 .unique();

 const now = Date.now();

 if (!existing) {
 await ctx.db.insert("rateLimits", { key, tokens: maxTokens - 1, lastRefill: now });
 return true;
 }

 const elapsed = now - existing.lastRefill;
 const refilled = Math.min(maxTokens, existing.tokens + Math.floor(elapsed / refillRateMs));

 if (refilled <= 0) return false;

 await ctx.db.patch(existing._id, { tokens: refilled - 1, lastRefill: now });
 return true;
}
```

Call `checkRateLimit` at the top of any mutation that handles external-facing actions, such as sending messages or creating accounts.

Use the pdf skill if you need to generate reports from your Convex data for stakeholders. Pair it with a scheduled export mutation that aggregates metrics nightly into a summary document.

## Debugging and Observability

Convex provides a dashboard at dashboard.convex.dev where you can inspect function logs, query execution times, and document contents. During development, `console.log` inside functions surfaces in both the dashboard and the terminal running `npx convex dev`.

For structured logging in production, emit log objects rather than strings:

```typescript
export const processPayment = mutation({
 args: { amount: v.number(), userId: v.string() },
 handler: async (ctx, args) => {
 console.log(JSON.stringify({
 event: "payment_started",
 userId: args.userId,
 amount: args.amount,
 timestamp: Date.now(),
 }));

 // ... payment logic

 console.log(JSON.stringify({
 event: "payment_completed",
 userId: args.userId,
 amount: args.amount,
 timestamp: Date.now(),
 }));
 },
});
```

Structured logs are easier to filter in the dashboard and to pipe into external log aggregators via Convex's log streaming feature, available on paid plans.

## Summary

Convex simplifies backend development by handling real-time synchronization automatically. Combined with Claude Code, you have a powerful setup for building reactive applications. Define your schema with proper indexes, write backend functions using the `query`/`mutation`/`internalMutation` primitives, connect your frontend with the `useQuery` and `useMutation` hooks, and let Convex handle the broadcast infrastructure. The real-time updates work across all connected clients without additional configuration, and scheduled jobs give you a clean path for background processing without a separate queue service.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-with-convex-backend-real-time-data-setup)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code WebSocket Implementation Real-Time Events Guide](/claude-code-websocket-implementation-real-time-events-guide/). See also
- [Claude Skills WebSocket Real-Time App Development](/claude-skills-for-websocket-realtime-app-development/). See also
- [Claude Code Skills for Supabase Full-Stack Apps Guide](/claude-code-skills-for-supabase-full-stack-apps-guide/). See also
- [Claude Code Tutorials Hub](/tutorials-hub/). See also

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code for Convex — Workflow Guide](/claude-code-for-convex-backend-workflow-guide/)
