---
layout: default
title: "Generate GraphQL Schemas with Claude Code"
description: "Use Claude Code to design and generate GraphQL schemas. Type definitions, resolvers, input validation, pagination, and code-first vs schema-first."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-graphql-schema-generation-guide/
reviewed: true
categories: [guides, claude-code]
tags: [graphql, schema, api, typescript, code-generation]
geo_optimized: true
---
# Generate GraphQL Schemas with Claude Code

## The Problem

Designing a GraphQL schema requires careful thought about types, queries, mutations, input types, pagination, error handling, and naming conventions. Getting the schema wrong early leads to painful breaking changes later because GraphQL clients depend on exact field names and types.

## Quick Start

Describe your data model and ask Claude Code to generate the schema:

```
Generate a GraphQL schema for a task management API.
Entities: User, Project, Task, Comment.
Include:
- Queries with pagination (cursor-based)
- Mutations for CRUD operations
- Input types with validation descriptions
- Proper nullability (use ! where values are guaranteed)
- Relay-style connection types for lists
Use the code-first approach with TypeGraphQL and TypeScript.
```

## What's Happening

GraphQL schemas define the contract between client and server. Unlike REST, where the API shape is implicit, GraphQL schemas are explicit and self-documenting. Every query, mutation, type, and field must be declared in the schema.

Claude Code excels at schema generation because it understands GraphQL conventions (Relay connections, input types, error unions), can derive the schema from your existing database models, and produces consistent naming throughout.

## Step-by-Step Guide

### Step 1: Choose your approach

**Schema-first** (write the schema, generate code):

```graphql
# schema.graphql
type User {
 id: ID!
 email: String!
 name: String!
 projects: [Project!]!
 createdAt: DateTime!
}
```

**Code-first** (write TypeScript, generate schema):

```typescript
// Using TypeGraphQL
@ObjectType()
class User {
 @Field(() => ID)
 id: string;

 @Field()
 email: string;

 @Field()
 name: string;

 @Field(() => [Project])
 projects: Project[];
}
```

Ask Claude Code which approach fits your project:

```
I have an existing Prisma schema with 12 models. Should I use
schema-first or code-first for my GraphQL API? I want type safety
between the database models and the GraphQL types.
```

### Step 2: Generate types from your data model

Ask Claude Code to read your Prisma schema (or database models) and generate GraphQL types:

```
Read prisma/schema.prisma and generate GraphQL type definitions
for every model. Follow these conventions:
- Use Relay-style connections for list fields
- Make IDs non-nullable
- Include timestamps (createdAt, updatedAt)
- Exclude internal fields (passwordHash, deletedAt)
- Use proper GraphQL scalar types (DateTime, JSON)
```

Claude Code generates:

```graphql
scalar DateTime

type User {
 id: ID!
 email: String!
 name: String!
 role: UserRole!
 projects: ProjectConnection!
 tasks(status: TaskStatus): TaskConnection!
 createdAt: DateTime!
 updatedAt: DateTime!
}

enum UserRole {
 ADMIN
 MEMBER
 VIEWER
}

type Project {
 id: ID!
 name: String!
 description: String
 owner: User!
 tasks(first: Int, after: String, status: TaskStatus): TaskConnection!
 members: [User!]!
 createdAt: DateTime!
 updatedAt: DateTime!
}

type Task {
 id: ID!
 title: String!
 description: String
 status: TaskStatus!
 priority: TaskPriority!
 assignee: User
 project: Project!
 comments(first: Int, after: String): CommentConnection!
 dueDate: DateTime
 createdAt: DateTime!
 updatedAt: DateTime!
}

enum TaskStatus {
 TODO
 IN_PROGRESS
 IN_REVIEW
 DONE
}

enum TaskPriority {
 LOW
 MEDIUM
 HIGH
 URGENT
}

type Comment {
 id: ID!
 body: String!
 author: User!
 task: Task!
 createdAt: DateTime!
 updatedAt: DateTime!
}
```

### Step 3: Generate connection types for pagination

Relay-style pagination is the GraphQL standard:

```graphql
type TaskConnection {
 edges: [TaskEdge!]!
 pageInfo: PageInfo!
 totalCount: Int!
}

type TaskEdge {
 node: Task!
 cursor: String!
}

type PageInfo {
 hasNextPage: Boolean!
 hasPreviousPage: Boolean!
 startCursor: String
 endCursor: String
}
```

Ask Claude Code to generate these for every list field:

```
Generate Relay-style connection types for all list relationships
in the schema. Include totalCount on every connection.
```

### Step 4: Generate queries and mutations

```graphql
type Query {
 # Single resource lookups
 user(id: ID!): User
 project(id: ID!): Project
 task(id: ID!): Task

 # List queries with pagination and filtering
 users(first: Int, after: String, search: String): UserConnection!
 projects(first: Int, after: String, ownerId: ID): ProjectConnection!
 tasks(
 first: Int
 after: String
 projectId: ID
 status: TaskStatus
 assigneeId: ID
 priority: TaskPriority
 ): TaskConnection!

 # Current user
 me: User!
}

type Mutation {
 # User mutations
 updateProfile(input: UpdateProfileInput!): User!

 # Project mutations
 createProject(input: CreateProjectInput!): Project!
 updateProject(id: ID!, input: UpdateProjectInput!): Project!
 deleteProject(id: ID!): Boolean!
 addProjectMember(projectId: ID!, userId: ID!, role: UserRole!): Project!

 # Task mutations
 createTask(input: CreateTaskInput!): Task!
 updateTask(id: ID!, input: UpdateTaskInput!): Task!
 deleteTask(id: ID!): Boolean!
 assignTask(taskId: ID!, userId: ID): Task!
 updateTaskStatus(taskId: ID!, status: TaskStatus!): Task!

 # Comment mutations
 addComment(input: AddCommentInput!): Comment!
 deleteComment(id: ID!): Boolean!
}
```

### Step 5: Generate input types

```graphql
input CreateProjectInput {
 name: String!
 description: String
}

input UpdateProjectInput {
 name: String
 description: String
}

input CreateTaskInput {
 projectId: ID!
 title: String!
 description: String
 priority: TaskPriority = MEDIUM
 assigneeId: ID
 dueDate: DateTime
}

input UpdateTaskInput {
 title: String
 description: String
 priority: TaskPriority
 assigneeId: ID
 dueDate: DateTime
}

input AddCommentInput {
 taskId: ID!
 body: String!
}

input UpdateProfileInput {
 name: String
 email: String
}
```

### Step 6: Generate resolvers

Ask Claude Code to generate type-safe resolvers:

```
Generate Fastify/Mercurius resolvers for the GraphQL schema.
Use the Prisma client for data access. Include:
- DataLoader for N+1 prevention
- Authorization checks
- Input validation
- Error handling
```

```typescript
// src/graphql/resolvers/task.ts
import { GraphQLContext } from '../context';
import DataLoader from 'dataloader';

export const taskResolvers = {
 Query: {
 task: async (_: unknown, { id }: { id: string }, ctx: GraphQLContext) => {
 ctx.requireAuth();
 const task = await ctx.prisma.task.findUnique({ where: { id } });
 if (!task) throw new Error('Task not found');
 return task;
 },

 tasks: async (_: unknown, args: TasksArgs, ctx: GraphQLContext) => {
 ctx.requireAuth();
 const { first = 20, after, projectId, status, assigneeId } = args;

 const where = {
 ...(projectId && { projectId }),
 ...(status && { status }),
 ...(assigneeId && { assigneeId }),
 deletedAt: null,
 };

 const cursor = after ? { id: after } : undefined;
 const tasks = await ctx.prisma.task.findMany({
 where,
 take: first + 1,
 cursor,
 skip: cursor ? 1 : 0,
 orderBy: { createdAt: 'desc' },
 });

 const hasNextPage = tasks.length > first;
 const edges = tasks.slice(0, first).map((task) => ({
 node: task,
 cursor: task.id,
 }));

 return {
 edges,
 pageInfo: {
 hasNextPage,
 hasPreviousPage: !!after,
 startCursor: edges[0]?.cursor ?? null,
 endCursor: edges[edges.length - 1]?.cursor ?? null,
 },
 totalCount: await ctx.prisma.task.count({ where }),
 };
 },
 },

 Task: {
 assignee: (task: { assigneeId: string | null }, _: unknown, ctx: GraphQLContext) => {
 if (!task.assigneeId) return null;
 return ctx.loaders.user.load(task.assigneeId);
 },

 project: (task: { projectId: string }, _: unknown, ctx: GraphQLContext) => {
 return ctx.loaders.project.load(task.projectId);
 },

 comments: async (task: { id: string }, args: PaginationArgs, ctx: GraphQLContext) => {
 // Paginated sub-query
 const { first = 20, after } = args;
 const comments = await ctx.prisma.comment.findMany({
 where: { taskId: task.id },
 take: first + 1,
 cursor: after ? { id: after } : undefined,
 skip: after ? 1 : 0,
 orderBy: { createdAt: 'asc' },
 });

 const hasNextPage = comments.length > first;
 const edges = comments.slice(0, first).map((c) => ({
 node: c,
 cursor: c.id,
 }));

 return {
 edges,
 pageInfo: { hasNextPage, hasPreviousPage: !!after },
 totalCount: await ctx.prisma.comment.count({ where: { taskId: task.id } }),
 };
 },
 },
};
```

### Step 7: Generate DataLoaders for N+1 prevention

```
Generate DataLoader instances for all relationships that could
cause N+1 queries. Register them in the GraphQL context so they
are created fresh per request.
```

```typescript
// src/graphql/loaders.ts
import DataLoader from 'dataloader';
import { PrismaClient } from '@prisma/client';

export function createLoaders(prisma: PrismaClient) {
 return {
 user: new DataLoader<string, User>(async (ids) => {
 const users = await prisma.user.findMany({
 where: { id: { in: [...ids] } },
 });
 const userMap = new Map(users.map((u) => [u.id, u]));
 return ids.map((id) => userMap.get(id) ?? new Error(`User ${id} not found`));
 }),

 project: new DataLoader<string, Project>(async (ids) => {
 const projects = await prisma.project.findMany({
 where: { id: { in: [...ids] } },
 });
 const projectMap = new Map(projects.map((p) => [p.id, p]));
 return ids.map((id) => projectMap.get(id) ?? new Error(`Project ${id} not found`));
 }),
 };
}
```

## Prevention

Add GraphQL conventions to your CLAUDE.md:

```markdown
## GraphQL Rules
- Use Relay-style connections for all list fields
- Every mutation input must be a dedicated Input type
- Use enums for finite value sets
- Non-nullable (!) by default, nullable only when data is absent
- Include totalCount on all connections
- Use DataLoader for all relationship resolvers
- Never expose internal IDs or sensitive fields
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-graphql-schema-generation-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)
- [Claude Code API Endpoint Testing Guide](/claude-code-api-endpoint-testing-guide/)
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/)



## Related Articles

- [Claude Code vs Codeium SQL — Developer Comparison 2026](/claude-code-vs-codeium-sql-query-generation/)
- [Claude Code FastAPI OpenAPI Schema Generation Workflow](/claude-code-fastapi-openapi-schema-generation-workflow/)
