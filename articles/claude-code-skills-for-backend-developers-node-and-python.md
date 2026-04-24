---
layout: default
title: "Claude Code Skills for Backend"
description: "Claude Code skills for backend developers working with Node.js and Python. Practical patterns for /tdd, /pdf, /supermemory in API and data workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, backend, nodejs, python, api, tdd]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-skills-for-backend-developers-node-and-python/
geo_optimized: true
---

# Claude Code Skills for Backend Developers: Node.js and Python

[Backend development involves repetitive tasks that consume development time](/best-claude-code-skills-to-install-first-2026/) Claude Code and its built-in skills help automate these workflows. This guide covers practical applications of the real skills for Node.js and Python backend work.

## What Skills Are Available

Claude Code ships with these built-in skills:

- `/[tdd skill](/claude-tdd-skill-test-driven-development-workflow/)`. test-driven development guidance
- `/pdf`. document processing
- `/docx`. Word document generation
- `/xlsx`. spreadsheet operations
- `/supermemory`. persistent context across sessions
- `/frontend-design`. UI component guidance
- `/webapp-testing`. web application testing workflows

There are no `/api-design`, `/database`, `/fastapi`, `/django`, `/pytest`, `/typescript`, `/security-audit`, `/performance`, `/celery`, or `/documentation` built-in skills. For stack-specific work, you describe your task directly to Claude Code or write custom skills.

## Using /tdd for Backend Testing

The `/tdd` skill works for both Node.js and Python testing workflows:

Node.js with Jest:
```
/tdd
Write tests for this Express route handler:
[paste your route code]

Use Jest. Cover: successful response, validation error, and database error cases.
```

Python with pytest:
```
/tdd
Write pytest tests for this FastAPI endpoint:
[paste your endpoint code]

Cover: successful response, missing required fields, and unauthorized access.
```

The skill generates test structure and cases based on your existing code.

For more complex scenarios, layer additional context into the invocation. For example, when your Node.js handler has middleware dependencies:

```
/tdd
Write tests for this Express middleware and the route that uses it:
[paste middleware code]
[paste route code]

Use Jest with supertest. Mock the database layer using jest.mock().
Test middleware: valid JWT, expired JWT, missing token.
Test route: authorized request, unauthorized request, malformed body.
```

For Python services with external dependencies:

```
/tdd
Write pytest tests for this Celery task that processes user signups:
[paste task code]

Use pytest with unittest.mock. Mock the email service and database calls.
Cover: successful signup, duplicate email error, email service timeout.
```

## Using /supermemory for Long Sessions

Backend projects span many sessions. Use `/supermemory` to preserve architectural decisions:

```
/supermemory store "Database schema decisions: Users table has uuid primary key, email is unique, password_hash never returned in API responses. Using Prisma ORM."
```

In future sessions:
```
/supermemory What is the database schema setup?
```

Store API contracts, configuration choices, and design decisions. This prevents repeating context across long projects.

You can also use `/supermemory` to track the state of ongoing refactors or migrations:

```
/supermemory store "Migration status 2026-03-20: completed users and orders tables.
Remaining: payments table (has legacy currency_code column to rename), webhooks table.
All migrations use Knex. Run with: npm run migrate:latest"
```

Then at the start of any new session:

```
/supermemory What is the current migration status?
```

## Using /pdf for Documentation

Generate API documentation from your codebase:

```
/pdf
Create API documentation for our backend service.

Routes:
POST /auth/login - accepts email/password, returns JWT token
GET /users/:id - returns user profile (requires auth)
DELETE /users/:id - soft-deletes user (requires admin role)

Include: request format, response format, error codes, and authentication notes.
```

## Database Workflows with Claude Code Skills

Claude Code has no built-in `/database` or `/migrate` skill, but you can handle database work effectively by combining direct prompts with `/supermemory` and custom skills.

Writing and reviewing migrations (Node.js / Knex):

Describe the schema change directly to Claude Code:

```
Add a Knex migration that:
- Adds a `subscription_tier` column (string, not null, default 'free') to the users table
- Creates a new `invoices` table with: id (uuid), user_id (foreign key), amount_cents (integer),
 status (enum: pending, paid, failed), created_at, updated_at
- Adds an index on invoices.user_id

We use timestamps() for created_at/updated_at. Primary keys are UUIDs via uuid_generate_v4().
```

Claude Code will generate the up and down migration. Review the output, then use `/tdd` to write tests for the migration's rollback behavior if that matters for your project.

Writing and reviewing migrations (Python / Alembic):

```
Write an Alembic migration that adds a `last_login_at` column (DateTime, nullable) to the
User model. The model uses SQLAlchemy with a PostgreSQL backend. Include the downgrade function
that drops the column.
```

Query optimization workflow:

Paste a slow query with its EXPLAIN ANALYZE output and ask Claude Code to diagnose it:

```
This query is slow on our users table (4M rows). Here is the query and EXPLAIN ANALYZE output:
[paste query]
[paste EXPLAIN output]

Suggest index additions and any query rewrites that would help. We are on PostgreSQL 15.
```

Custom skill for migration reviews:

A short custom skill keeps migration reviews consistent across your team:

```markdown
---
name: migration-review
description: Review database migrations for common issues
---

Migration Review Checklist

When reviewing a database migration, check:

1. Reversibility: Does the down() function cleanly undo everything in up()?
2. Zero-downtime safety: Does the migration add columns as nullable first, or use a safe
 multi-step approach for adding NOT NULL constraints on large tables?
3. Index creation: Are indexes created CONCURRENTLY to avoid table locks in production?
4. Foreign keys: Are foreign key constraints deferred or added after data backfills?
5. Data loss risk: Does the down() migration drop columns or tables that may contain data?

Report each issue with the migration step it applies to and a suggested fix.
```

Save as `~/.claude/skills/migration-review.md` and invoke with:

```
/migration-review
[paste your migration file]
```

## API Development with Claude Code Skills

Building and iterating on APIs is a core backend workflow. Claude Code handles this through direct prompting, but combining it with skills makes common review and documentation steps faster.

Designing a new endpoint (Node.js / Express):

```
Design and implement a PATCH /users/:id/profile endpoint for our Express API.

Requirements:
- Accepts: display_name (string, max 50 chars), bio (string, max 500 chars), avatar_url (url)
- All fields optional; only update what is provided
- Requires authentication (JWT middleware already applied at the router level)
- Users can only update their own profile unless they have role: 'admin'
- Use Zod for input validation
- Use Prisma for the database update
- Return the updated profile object (exclude password_hash and internal fields)
```

Designing a new endpoint (Python / FastAPI):

```
Design and implement a PATCH /users/{user_id}/profile endpoint for our FastAPI service.

Requirements:
- Pydantic model with optional fields: display_name, bio, avatar_url
- Current user injected via Depends(get_current_user)
- Users can only update their own profile; admins can update any profile
- SQLAlchemy update; return a ProfileResponse schema (no password_hash)
- Raise 403 if unauthorized, 404 if user not found
```

API contract documentation with /pdf:

Once your endpoint is implemented, use `/pdf` to produce a reference document for other teams or for client SDK authors:

```
/pdf
Document the following API endpoints for our internal developer reference.

POST /auth/login
 Body: { email: string, password: string }
 Success: 200 { token: string, expires_at: ISO8601 }
 Errors: 401 invalid credentials, 429 rate limited

PATCH /users/:id/profile
 Body (all optional): { display_name: string, bio: string, avatar_url: url }
 Auth: Bearer token required
 Success: 200 { id, display_name, bio, avatar_url, updated_at }
 Errors: 400 validation, 401 unauthenticated, 403 unauthorized, 404 not found

Format as a clean developer reference with request examples and response examples for each.
```

Custom skill for API contract validation:

```markdown
---
name: api-contract-check
description: Validate Express or FastAPI endpoints against REST conventions
---

API Contract Checklist

When reviewing an API endpoint implementation, verify:

1. Status codes: POST creates return 201, successful deletes return 204, not 200
2. Error shape: All errors return { error: string, code: string }. not raw strings
3. Auth enforcement: Protected routes reject unauthenticated requests with 401, not 403
4. Input sanitization: String inputs are trimmed; no raw user input passed to queries
5. Response shape: No internal fields (password_hash, internal_id, __v) leak into responses
6. Idempotency: PUT and PATCH endpoints are safe to call twice with the same payload

Flag any violations with the line number and a corrected code snippet.
```

## Writing Custom Skills for Your Stack

Create custom skills for stack-specific workflows. A custom Node.js API review skill:

```markdown
---
name: node-api-review
description: Review Express route handlers for common issues
---

Node.js API Review

When reviewing Express route handlers, check:

1. Error handling: Every async handler has a try/catch or uses express-async-errors
2. Input validation: All inputs validated before processing (use Zod or Joi)
3. Authentication: Protected routes verify JWT before proceeding
4. Response codes: Correct HTTP status codes (201 for create, 204 for delete)
5. No secrets in responses: Never return password_hash, tokens, or internal IDs

Report each issue with the line number and suggested fix.
```

Save as `~/.claude/skills/node-api-review.md`, then invoke with:
```
/node-api-review
[paste your route handler]
```

## Typical Backend Workflow Example

Adding a new API endpoint:

```
1. Describe the endpoint to Claude Code directly:
 "Add a POST /orders endpoint that creates a new order. Uses Prisma.
 Fields: user_id, items (array), total_price. Returns the created order."

2. Review the generated code and ask Claude to adjust

3. Use /tdd to generate tests:
 /tdd
 Write Jest tests for this order creation handler:
 [paste the generated handler]

4. Store design decisions:
 /supermemory store "Orders endpoint: POST /orders, requires user auth,
 validates item IDs exist before creating order, returns full order object with items"
```

## Summary

The built-in skills useful for backend development are `/tdd` for tests, `/supermemory` for preserving context across sessions, and `/pdf` for documentation. There are no built-in skills for database work, API design, or specific frameworks. those workflows run through direct Claude Code prompts, optionally paired with custom skill files you write once and reuse across your team.

Custom skills are just `.md` files in `~/.claude/skills/` with a short YAML front matter block and a checklist or prompt pattern. The patterns in this guide. `migration-review`, `node-api-review`, `api-contract-check`. each take under ten minutes to write and eliminate a category of manual review work. Write them as you identify the checks you repeat most often in code review.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-backend-developers-node-and-python)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude TDD Skill: Test-Driven Development Workflow](/claude-tdd-skill-test-driven-development-workflow/). Full guide to the tdd skill used for Node.js and Python test generation in this guide
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). See the broader ecosystem of developer skills that complement backend workflows
- [Automated Testing Pipeline with Claude TDD Skill 2026](/claude-tdd-skill-test-driven-development-workflow/). Build a complete automated testing pipeline for your Node.js or Python backend project
- [Claude Skills Use Cases Hub](/use-cases-hub/). Explore more backend development, API, and infrastructure use case guides

Built by theluckystrike. More at [zovo.one](https://zovo.one)


