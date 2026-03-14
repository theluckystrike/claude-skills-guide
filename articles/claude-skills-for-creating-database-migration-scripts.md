---
layout: default
title: "Claude Skills for Creating Database Migration Scripts"
description: "Learn how to create and use Claude skills that automate database migration script generation, schema versioning, and data transformation tasks."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, database, migrations, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Skills for Creating Database Migration Scripts

Database migrations are one of the most error-prone parts of application development. A single typo in a migration script can corrupt data or bring production down. Claude skills can help you generate reliable migration scripts, validate schema changes, and handle complex data transformations with confidence.

This guide shows you how to build Claude skills specifically designed for database migration workflows.

## Why Use Claude for Migrations

Traditional migration workflows rely on manual script writing or ORM-generated changes. Both approaches have gaps. ORMs often generate inefficient SQL, and manual writing leaves room for errors. Claude skills bridge this gap by understanding your application context—your existing schema, data patterns, and business rules—and generating migrations that fit your specific situation.

A well-crafted migration skill reads your current database schema, understands your intent, and produces production-ready SQL or ORM migration code.

## Anatomy of a Migration Skill

A migration skill needs several components to be effective. First, it requires clear instructions for schema inspection. Second, it needs guidance for generating different migration types. Third, it must include validation rules specific to your database system.

Here is a basic structure for a migration skill:

```markdown
# Skill: db-migration

## Overview
Generate database migration scripts for PostgreSQL, MySQL, or SQLite.

## Schema Inspection
When asked to analyze the database:
1. Read the current schema from the project's ORM models or existing migrations
2. Identify all tables, columns, indexes, and constraints
3. Note any foreign key relationships and their referential actions

## Migration Generation
When generating migrations:
1. Always generate reversible migrations with UP and DOWN methods
2. Include appropriate indexes for foreign key columns
3. Add checks for existing data before altering columns
4. Use transactions for multi-step migrations

## Validation Rules
- Verify column types match the application's data expectations
- Ensure foreign keys include ON DELETE and ON UPDATE clauses
- Check that indexes exist for frequently queried columns
```

This skill template provides the foundation. You extend it based on your specific database and framework.

## PostgreSQL Migration Skills

PostgreSQL migrations often involve features beyond basic schema changes. You might need to handle JSON columns, array types, or custom functions. A PostgreSQL-specific skill should account for these.

```markdown
# Skill: pg-migration

## PostgreSQL-Specific Guidance
For PostgreSQL migrations:
- Use GENERATED ALWAYS AS for computed columns
- Prefer jsonb over json for better performance
- Include REINDEX for index-heavy tables
- Set appropriate locks using LOCK_TIMEOUT
- Handle sequences for auto-increment columns

## Data Migration Patterns
When migrating data within the same migration:
1. Add new column with temporary nullable field
2. Populate data with UPDATE statements
3. Add NOT NULL constraint
4. Drop temporary column

## Example: Adding a JSON Column
For adding a JSONB column with an index:
```sql
ALTER TABLE users ADD COLUMN preferences JSONB DEFAULT '{}';
CREATE INDEX idx_users_preferences ON users USING gin (preferences);
```
```

## Handling Complex Data Transformations

Many migrations involve not just schema changes but data transformations. A skill focused on data migration helps ensure data integrity during these operations.

Consider a scenario where you need to split a single `contact_info` column into separate `email` and `phone` columns. The migration skill should generate:

1. The schema alteration to add new columns
2. Data migration logic that parses and distributes values
3. Validation queries to confirm the transformation succeeded
4. Cleanup to remove the old column

```sql
-- Add new columns
ALTER TABLE customers ADD COLUMN email VARCHAR(255);
ALTER TABLE customers ADD COLUMN phone VARCHAR(50);

-- Migrate data
UPDATE customers 
SET email = SPLIT_PART(contact_info, '|', 1),
    phone = SPLIT_PART(contact_info, '|', 2)
WHERE contact_info IS NOT NULL;

-- Validate
SELECT COUNT(*) FROM customers 
WHERE email IS NULL AND contact_info IS NOT NULL;
-- Should return 0

-- Cleanup
ALTER TABLE customers DROP COLUMN contact_info;
```

The skill generates these steps automatically when you describe the transformation you need.

## Rollback Strategies

Every migration skill should address rollbacks. Generated migrations must include reversible operations. For complex transformations, the skill should guide you toward creating backup tables rather than attempting complex reverse transformations.

```sql
-- Safe rollback pattern for data transformation
BEGIN;

-- Create backup before major changes
CREATE TABLE customers_backup AS 
SELECT * FROM customers WHERE 1=1;

-- Apply migration
-- ... your migration logic here ...

-- If something goes wrong:
-- ROLLBACK; -- restores to pre-migration state

-- When confident:
-- DROP TABLE customers_backup;
COMMIT;
```

## Integration with Frameworks

If you use Rails, Django, Laravel, or similar frameworks, your migration skill should align with the framework's conventions. The skill generates migrations in the correct format and follows framework best practices.

For example, a Rails migration skill should generate Ruby-based migrations:

```ruby
class AddStatusToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :status, :string, default: 'pending', null: false
    add_index :orders, :status
    add_index :orders, [:status, :created_at]
  end
end
```

The skill understands Rails conventions—using `change` for reversible migrations, specifying migration versions, and including appropriate indexes.

## Testing Migrations

A comprehensive migration skill includes testing guidance. Before applying migrations to production, test them against staging data. Your skill should remind you to:

1. Run migrations on a staging environment first
2. Verify application functionality post-migration
3. Check query performance with EXPLAIN ANALYZE
4. Review migration runtime on realistic data volumes

## Building Your Own Migration Skill

Start by identifying your most common migration patterns. Do you mostly add columns? Create join tables? Refactor legacy schemas? Build the skill around these patterns.

Add your project's specific constraints to the skill. If you follow naming conventions—say, always prefix indexes with `idx_`—include that in the skill's instructions. The more context you provide, the better the generated migrations.

Store your migration skill in your project's `.claude/skills` directory or share it across projects if the database patterns are similar.

---

Building effective migration skills takes iteration. Start with a basic version, use it for real migrations, and refine the skill based on what worked and what needed adjustment. Over time, you'll have a specialized tool that handles your database changes reliably and follows your project's conventions precisely.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
