---
layout: default
title: "Claude Code for Electric SQL Sync Workflow Guide"
description: "A comprehensive guide for developers on using Claude Code to streamline Electric SQL sync workflows, manage local-first databases, and build reactive applications with seamless data synchronization."
date: 2026-03-15
author: Claude Skills Guide
permalink: /claude-code-for-electric-sql-sync-workflow-guide/
categories: [tutorials]
tags: [claude-code, claude-skills, electric-sql, database, sync, local-first]
---

# Claude Code for Electric SQL Sync Workflow Guide

Electric SQL is a powerful toolkit for building local-first applications with SQLite that automatically syncs with your backend database. When combined with Claude Code, you can dramatically accelerate the development of reactive applications that work seamlessly offline and online. This guide walks you through practical strategies for integrating Claude Code into your Electric SQL workflow.

## Understanding Electric SQL Architecture

Before diving into implementation, it's essential to understand how Electric SQL works. Electric SQL provides a local SQLite database that syncs with a PostgreSQL backend using a sync service. The key components include:

- **Local SQLite Database**: An embedded database that works offline
- **Satellite**: The local sync client that manages data synchronization
- **Electric Sync Service**: The backend service that coordinates data changes
- **PostgreSQL Backend**: The authoritative database that stores your data

Claude Code can help you set up, configure, and troubleshoot this architecture more efficiently by generating boilerplate code, explaining complex sync scenarios, and helping debug synchronization issues.

## Setting Up Your Electric SQL Project

The first step is to initialize your project with Electric SQL. Claude Code can guide you through this process and generate the necessary configuration files.

### Project Initialization

Start by creating your project structure and installing dependencies:

```bash
# Initialize a new project with Electric SQL
npx create-electric-app@latest my-electric-app
cd my-electric-app
npm install @electric-sql/client @electric-sql/local
```

When setting up Electric SQL with Claude Code, create a context file that describes your project:

```typescript
// CLAUDE.md context for Electric SQL project
// Database: PostgreSQL with Electric Sync Service
// Client: @electric-sql/client v1.x
// Framework: React with TypeScript
// Schema location: ./src/database/schema.ts
// Migrations: ./migrations/
```

This context helps Claude Code generate accurate code that matches your project structure and conventions.

### Defining Your Schema

Electric SQL uses a schema definition that maps to both your local SQLite and PostgreSQL backend. Here's how to define tables that sync correctly:

```typescript
// schema.ts - Define your data model
import { defineSchema, defineTable } from 'electric-sql'

export const appSchema = defineSchema({
  tables: {
    users: defineTable({
      id: 'uuid'.primaryKey(),
      email: 'string'.unique().notNull(),
      name: 'string',
      created_at: 'timestamp'.default('now()'),
    }),
    posts: defineTable({
      id: 'uuid'.primaryKey(),
      user_id: 'uuid'.references('users.id'),
      title: 'string'.notNull(),
      content: 'text',
      published: 'boolean'.default(false),
      created_at: 'timestamp'.default('now()'),
      updated_at: 'timestamp'.default('now()'),
    }),
  },
})
```

Claude Code can help you generate these schemas from natural language descriptions of your data model, making it easy to define complex relationships and constraints.

## Implementing Data Sync with Claude Code

Once your schema is defined, you need to implement the sync logic. Electric SQL handles most of this automatically, but there are patterns and best practices Claude Code can help you implement.

### Connecting to the Electric Service

Here's how to set up your Electric SQL client:

```typescript
// db.ts - Initialize Electric SQL client
import { electrify } from '@electric-sql/client'
import { appSchema } from './schema'

const config = {
  url: process.env.ELECTRIC_URL || 'http://localhost:5133',
  auth: {
    token: process.env.ELECTRIC_TOKEN,
  },
}

export const db = await electrify(
  {
    schema: appSchema,
    migrations: './migrations',
  },
  config
)
```

Claude Code can help you customize this configuration for different environments, add error handling, and implement reconnection logic for unstable networks.

### Performing CRUD Operations

With Electric SQL, your local SQLite database automatically syncs with the backend. Here's a typical workflow:

```typescript
// Example: Creating and syncing a new post
async function createPost(userId: string, title: string, content: string) {
  const post = await db.posts.create({
    user_id: userId,
    title,
    content,
    published: false,
  })
  
  // Electric SQL automatically syncs to backend
  return post
}

// Example: Observing data changes reactively
import { useElectric } from './electric-react'

function PostList() {
  const { db } = useElectric()
  const posts = db.posts.useMany({
    where: { published: true },
    orderBy: { created_at: 'desc' },
  })
  
  return (
    <ul>
      {posts.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

Claude Code can help you implement more complex queries, handle edge cases, and optimize your data access patterns.

## Handling Sync Conflicts and Errors

One of the most challenging aspects of local-first development is handling conflicts when the same data is modified offline. Electric SQL provides built-in conflict resolution, but you may need custom logic for specific scenarios.

### Implementing Custom Conflict Resolution

```typescript
// Configure conflict resolution strategies
const db = await electrify(schema, {
  ...config,
  conflictResolution: {
    // Last-write-wins for posts
    posts: 'last-write-wins',
    // Custom resolution for users
    users: {
      resolve: async (local, remote) => {
        // Prefer the version with more complete data
        if (local.name && !remote.name) return local
        if (remote.name && !local.name) return remote
        // For equal records, prefer remote (authoritative)
        return remote
      },
    },
  },
})
```

Claude Code can help you analyze your specific conflict scenarios and implement appropriate resolution strategies.

### Error Handling Best Practices

Implement robust error handling for sync failures:

```typescript
async function syncWithRetry(maxRetries = 3) {
  let attempt = 0
  
  while (attempt < maxRetries) {
    try {
      await db.sync()
      return { success: true }
    } catch (error) {
      attempt++
      if (attempt >= maxRetries) {
        console.error('Sync failed after retries:', error)
        return { success: false, error }
      }
      // Exponential backoff
      await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 1000))
    }
  }
}
```

## Optimizing Your Sync Workflow

To get the most out of Electric SQL with Claude Code, follow these optimization strategies:

### Selective Sync

Only sync the data your users need:

```typescript
// Sync only recent data for better performance
const db = await electrify(schema, {
  ...config,
  // Only sync posts from the last 30 days
  where: {
    posts: {
      created_at: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
    },
  },
})
```

### Index Optimization

Create indexes to speed up queries:

```sql
-- Electric SQL migration
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_published ON posts(published) WHERE published = true;
```

Claude Code can analyze your query patterns and recommend appropriate indexes.

## Testing Your Electric SQL Application

Testing local-first applications requires special considerations. Here's how to approach testing with Claude Code:

### Unit Testing Database Operations

```typescript
import { testDb } from './test-utils'

describe('Post operations', () => {
  it('should create a post and sync', async () => {
    const post = await testDb.posts.create({
      user_id: 'test-user-id',
      title: 'Test Post',
      content: 'Test content',
    })
    
    expect(post.title).toBe('Test Post')
    expect(testDb.posts.syncStatus(post.id)).toBe('synced')
  })
})
```

## Conclusion

Electric SQL combined with Claude Code provides a powerful toolkit for building responsive, offline-first applications. By leveraging Claude Code's ability to generate code, explain complex concepts, and help debug issues, you can significantly accelerate your development workflow. Remember to:

- Set up proper project context for accurate code generation
- Implement appropriate conflict resolution for your use case
- Handle sync errors gracefully with retry logic
- Optimize queries with selective sync and proper indexing
- Test thoroughly for both online and offline scenarios

With these practices, you'll be well-equipped to build robust local-first applications that work seamlessly whether your users are online or offline.
