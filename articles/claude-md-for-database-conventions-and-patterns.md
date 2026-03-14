---
layout: default
title: "Claude MD for Database Conventions and Patterns"
description: "Learn how to use Claude's markdown-based skills to implement consistent database conventions and design patterns across your projects."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, database, conventions, patterns, sql, mcp]
author: theluckystrike
---

# Claude MD for Database Conventions and Patterns

Database consistency remains one of the most challenging aspects of software development. When teams work across multiple projects, maintaining uniform naming conventions, table structures, and relationship patterns becomes difficult without explicit guidelines. Claude's markdown-based skills provide a practical solution for codifying and enforcing database conventions directly in your workflow.

## How Claude Skills Work with Database Conventions

Claude Code loads skills from `~/.claude/skills/` as plain Markdown files. Each skill contains instructions that guide Claude's behavior when you activate it. For database conventions, you can create a custom skill that defines your team's standards for naming tables, columns, relationships, and indexes.

The power of using Claude skills for database work lies in their ability to apply consistent rules across every interaction. Whether you're generating new schemas, reviewing existing code, or refactoring legacy tables, the skill ensures your conventions stay intact throughout the development lifecycle.

## Creating a Database Conventions Skill

A database conventions skill is simply a Markdown file that Claude loads when activated. Here's how to structure one for your team:

```
# Database Conventions Skill

You are a database architecture expert. Apply these conventions to all schema work:

## Naming Rules
- Use snake_case for all identifiers (tables, columns, indexes)
- Prefix tables with module name (e.g., users_account, orders_items)
- Use singular names for tables (user, not users)
- Add _id suffix to foreign key columns (user_id, not user)
- Prefix indexes with idx_ and unique indexes with uk_

## Standard Columns
Every table must include:
- id: BIGINT PRIMARY KEY AUTO_INCREMENT
- created_at: DATETIME DEFAULT CURRENT_TIMESTAMP
- updated_at: DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- deleted_at: DATETIME NULL (soft delete)

## Relationship Patterns
- Always define foreign keys with ON DELETE CASCADE or ON DELETE SET NULL
- Use junction tables for many-to-many relationships
- Name junction tables with both table names in singular form (user_role)
```

Save this as `~/.claude/skills/database-conventions.md` and activate it with `/database-conventions` in your Claude session.

## Applying Conventions to Schema Generation

When you need to generate new database schemas, activate your conventions skill and describe your requirements. Claude will follow your rules automatically:

```
/database-conventions

Create a schema for a blog system with posts, categories, and tags. Include proper relationships and indexes.
```

Claude will generate tables following your conventions—singular table names, standard columns, proper foreign key naming, and appropriate indexes. The skill applies your team's standards without requiring you to repeat them in every request.

## Integration with Other Skills

Database conventions work well alongside other Claude skills. The [tdd skill](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) helps you write migration tests alongside your schema changes. The [pdf skill](/claude-skills-guide/best-claude-skills-for-data-analysis/) lets you generate database documentation in PDF format for stakeholders. Combined with the [supermemory skill](/claude-skills-guide/best-claude-skills-for-developers-2026/), you can maintain a searchable history of schema decisions and migrations.

For frontend developers working with ORMs, the [frontend-design skill](/claude-skills-guide/best-claude-code-skills-for-frontend-development/) pairs with database conventions to ensure your API responses match your schema structure consistently.

## Pattern Enforcement Beyond Naming

Beyond simple naming conventions, your skill can encode architectural patterns. Consider including rules for:

**Soft Deletes**: Always use the deleted_at pattern rather than hard deletes. Your skill should reject any DELETE statements and suggest UPDATE with deleted_at instead.

**Audit Trails**: Tables with sensitive data should include audit columns. The skill can automatically suggest adding created_by and updated_by columns to relevant tables.

**UUID vs Integer Keys**: Your conventions should specify whether to use UUIDs or auto-incrementing integers. The skill then applies this consistently across all new tables.

**Cascade Rules**: Define standard delete behavior—usually ON DELETE SET NULL for optional relationships and ON DELETE CASCADE for required ones.

## Using MCP Servers with Database Skills

The AWS MCP server and other database-related MCP tools work seamlessly with your conventions skill. When you connect to a database through an MCP server, activate your conventions skill first to ensure all generated queries follow your standards.

For teams using PostgreSQL, the conventions skill can include rules specific to that database, such as array column usage, JSONB best practices, or specific index types like GIN and BRIN for different use cases.

## Real-World Example

Suppose your team is building an e-commerce platform. Your database conventions skill includes rules for:

- Table prefixes: `orders_`, `products_`, `customers_`
- Standard audit columns on all transactional tables
- UUID primary keys for distributed systems
- Foreign key constraints on all relationships

When you request a new feature—perhaps a wishlist system—Claude generates:

```sql
CREATE TABLE customers_wishlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    position INTEGER DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers_account(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products_catalog(id) ON DELETE CASCADE,
    UNIQUE(customer_id, product_id)
);

CREATE INDEX idx_wishlist_customer ON customers_wishlist(customer_id);
CREATE INDEX idx_wishlist_product ON customers_wishlist(product_id);
```

The schema follows every convention automatically—prefixed table name, UUID primary key, standard timestamps, soft delete column, proper foreign keys with cascade rules, and appropriate indexes.

## Maintaining Your Conventions Skill

As your project evolves, update your conventions skill to reflect new requirements. Review it quarterly to remove outdated rules and add patterns for new features. Version control your skill file alongside your code so team members can track convention changes over time.

Document any exceptions directly in the skill file using comments. If a specific table genuinely requires different treatment, note the rationale so future developers understand why the standard was modified.

## Summary

Claude's markdown skills provide an effective framework for enforcing database conventions without creating complex build scripts or linters. By defining your standards in a plain Markdown file, you get consistent schema design across every project, automatic application of patterns, and documentation that doubles as executable instructions. Combine your conventions skill with other Claude skills like tdd, pdf, and supermemory to build a comprehensive database workflow that scales with your team.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
