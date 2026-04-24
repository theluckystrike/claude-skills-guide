---
layout: default
title: "Database Schema Design with Claude Code"
description: "Use Claude Code to design, review, and optimize database schemas. Normalization, indexing strategies, migration workflows, and common pitfalls."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-database-schema-design-guide/
reviewed: true
categories: [guides, claude-code]
tags: [database, schema, postgresql, prisma, design]
geo_optimized: true
---

# Database Schema Design with Claude Code

## The Problem

Designing a database schema requires balancing normalization, query performance, data integrity, and future extensibility. Getting it wrong means painful migrations later, slow queries, and data inconsistencies that are hard to fix once production data exists.

## Quick Start

Describe your domain to Claude Code and ask for a schema:

```
Design a PostgreSQL schema for a SaaS project management tool.
Core entities: Users, Organizations, Projects, Tasks, Comments.

Requirements:
- Users belong to multiple organizations (many-to-many)
- Each organization has projects
- Tasks belong to projects and are assigned to users
- Tasks have status, priority, due date, and can be nested (subtasks)
- Comments belong to tasks and have an author
- Soft delete for all entities
- Audit trail (created_at, updated_at, created_by)

Use Prisma schema format. Include indexes for common queries.
```

## What Claude Code Brings to Schema Design

Claude Code excels at database schema design because it can:

1. **Apply normalization rules** consistently across your entire schema
2. **Identify missing indexes** by analyzing your query patterns
3. **Spot data integrity gaps** like missing foreign key constraints or cascading delete issues
4. **Generate migration files** that safely transform existing schemas
5. **Review schemas against best practices** and catch common mistakes before they reach production. See also [Generate GraphQL Schemas with Claude Code](/claude-code-graphql-schema-generation-guide/) for more on this topic.

## Step-by-Step Guide

### Step 1: Define your domain model

Start with a plain-English description of your entities and relationships. Claude Code works best when you describe the business rules:

```
Design a schema for an e-commerce platform:
- Customers can have multiple addresses (billing and shipping)
- Products belong to categories (products can be in multiple categories)
- Products have variants (size, color) with separate inventory tracking
- Orders contain order items that reference product variants
- Orders have a status lifecycle: pending → paid → shipped → delivered → completed
- Support partial refunds on individual order items
- Track inventory changes with a log (who, when, quantity change, reason)
```

### Step 2: Review the generated schema

Claude Code produces a complete schema. Ask it to explain trade-offs:

```prisma
model Customer {
 id String @id @default(cuid())
 email String @unique
 name String
 addresses Address[]
 orders Order[]
 createdAt DateTime @default(now())
 updatedAt DateTime @updatedAt
 deletedAt DateTime?

 @@index([email])
 @@index([deletedAt])
}

model Product {
 id String @id @default(cuid())
 name String
 description String?
 slug String @unique
 categories CategoryProduct[]
 variants ProductVariant[]
 createdAt DateTime @default(now())
 updatedAt DateTime @updatedAt
 deletedAt DateTime?

 @@index([slug])
 @@index([deletedAt])
}

model ProductVariant {
 id String @id @default(cuid())
 productId String
 product Product @relation(fields: [productId], references: [id])
 sku String @unique
 name String // e.g., "Large / Red"
 price Decimal @db.Decimal(10, 2)
 inventory Int @default(0)
 orderItems OrderItem[]

 @@index([productId])
 @@index([sku])
}

model Order {
 id String @id @default(cuid())
 customerId String
 customer Customer @relation(fields: [customerId], references: [id])
 status OrderStatus @default(PENDING)
 items OrderItem[]
 total Decimal @db.Decimal(10, 2)
 createdAt DateTime @default(now())
 updatedAt DateTime @updatedAt

 @@index([customerId])
 @@index([status])
 @@index([createdAt])
}

enum OrderStatus {
 PENDING
 PAID
 SHIPPED
 DELIVERED
 COMPLETED
 CANCELLED
}
```

### Step 3: Optimize indexes for your queries

Tell Claude Code about your most common queries:

```
My most common queries are:
1. Get all orders for a customer, sorted by date (paginated)
2. Search products by name (full-text)
3. Get all pending orders older than 24 hours
4. Get inventory levels for all variants of a product
5. Monthly revenue report grouped by product category

Add or modify indexes to optimize these queries.
```

Claude Code will add composite indexes:

```prisma
model Order {
 // ... fields ...

 // Composite index for customer orders, sorted by date
 @@index([customerId, createdAt(sort: Desc)])

 // For finding stale pending orders
 @@index([status, createdAt])
}

model Product {
 // ... fields ...

 // For full-text search (PostgreSQL specific)
 // Note: Prisma doesn't support GIN indexes directly;
 // use a custom migration for full-text search
}
```

### Step 4: Add data integrity constraints

Ask Claude Code to review for integrity gaps:

```
Review this schema for data integrity issues. Check for:
- Missing cascading deletes or restricts
- Columns that should be non-nullable
- Missing unique constraints
- Enum values that might need expansion
- Decimal precision for monetary values
```

Claude Code will identify issues like:

```prisma
model OrderItem {
 id String @id @default(cuid())
 orderId String
 order Order @relation(fields: [orderId], references: [id], onDelete: Cascade)
 variantId String
 variant ProductVariant @relation(fields: [variantId], references: [id], onDelete: Restrict)
 quantity Int
 unitPrice Decimal @db.Decimal(10, 2) // Snapshot price at time of order
 // ^^ Important: store the price, don't reference current price

 @@unique([orderId, variantId]) // Prevent duplicate items
}
```

### Step 5: Design for soft deletes

Soft deletes are common in SaaS applications. Ask Claude Code to implement them consistently:

```
Add soft delete support across the schema. Include:
- deletedAt column on every entity
- Default scope that excludes deleted records
- Index on deletedAt for query performance
- Cascade logic (soft-deleting a project should soft-delete its tasks)
```

### Step 6: Add audit trails

For compliance and debugging:

```prisma
model AuditLog {
 id String @id @default(cuid())
 entity String // "Order", "Product", etc.
 entityId String
 action String // "CREATE", "UPDATE", "DELETE"
 userId String
 changes Json // Before/after snapshot
 createdAt DateTime @default(now())

 @@index([entity, entityId])
 @@index([userId])
 @@index([createdAt])
}
```

### Step 7: Generate and review migrations

After finalizing the schema, generate migrations:

```bash
npx prisma migrate dev --name initial_schema --create-only
```

Ask Claude Code to review the generated SQL:

```
Review the migration SQL in prisma/migrations/. Check for:
- Correct index types (B-tree vs GIN vs GiST)
- Proper foreign key constraints
- Sensible default values
- Any destructive operations
```

## Common Schema Design Mistakes

Ask Claude Code to check for these anti-patterns:

1. **Storing money as floats**: Use `Decimal(10, 2)` for currency
2. **Missing timestamps**: Every table should have `createdAt` and `updatedAt`
3. **Over-normalization**: Sometimes denormalization improves read performance
4. **No soft deletes**: Hard deletes lose data and break referential integrity
5. **Generic columns**: Columns named `data`, `value`, or `type` without clear semantics

## Prevention

Add schema design rules to your CLAUDE.md:

```markdown
## Database Schema Rules
- Use cuid() for primary keys (not auto-increment)
- Every table: id, createdAt, updatedAt, deletedAt
- Money: Decimal(10, 2), never Float
- Foreign keys: always specify onDelete behavior
- Add indexes for every foreign key column
- Add composite indexes for common query patterns
- Use enums for status fields with known values
```

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-database-schema-design-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude Code Database Seeding Automation](/claude-code-database-seeding-automation/)
- [Claude Code Database Test Fixtures Guide](/claude-code-database-test-fixtures-guide/)
- [Claude Code Testcontainers Integration Testing](/claude-code-testcontainers-integration-testing/)



## Related Articles

- [How To Use Claude Code To Write — Complete Developer Guide](/how-to-use-claude-code-to-write-database-queries-from-scratch/)
- [Claude Code NextAuth Database Adapter Setup Guide](/claude-code-nextauth-database-adapter-setup-guide/)
- [Claude Code for Neon DB Branching — Guide](/claude-code-for-neon-database-branching-workflow-guide/)
- [Claude Code for Xata Database — Workflow Guide](/claude-code-for-xata-database-workflow-guide/)
- [Claude Code with PlanetScale Database Workflow Guide](/claude-code-with-planetscale-database-workflow-guide/)
- [Claude Code with Firebase Realtime Database Workflow](/claude-code-with-firebase-realtime-database-workflow/)
- [Claude Code for RF Antenna Design Simulation (2026)](/claude-code-rf-antenna-design-simulation-2026/)
