---
layout: default
title: "Claude Code for Payload CMS (2026)"
description: "Claude Code for Payload CMS — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-payload-cms-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, payload, workflow]
---

## The Setup

You are building a content management system with Payload CMS, the TypeScript-first headless CMS that gives you a complete admin panel, REST and GraphQL APIs, authentication, and access control — all generated from collection configs. Claude Code can generate Payload collections and hooks, but it creates raw Express CRUD routes instead of using Payload's config-driven approach.

## What Claude Code Gets Wrong By Default

1. **Builds CRUD endpoints manually.** Claude creates Express routes with Prisma queries. Payload auto-generates REST, GraphQL, and local APIs from collection definitions — you define the schema and Payload handles everything.

2. **Creates separate auth systems.** Claude builds JWT auth with bcrypt. Payload has built-in authentication — add `auth: true` to a collection and it provides login, registration, password reset, and session management.

3. **Uses Mongoose schema syntax.** Claude writes Mongoose `new Schema({})` definitions. Payload uses its own field types: `{ name: 'title', type: 'text', required: true }` in collection configs. Payload handles the database layer.

4. **Ignores Payload's hook system.** Claude writes Express middleware for custom logic. Payload has typed hooks (`beforeChange`, `afterRead`, `beforeValidate`) on every collection for custom business logic.

## The CLAUDE.md Configuration

```
# Payload CMS Project

## CMS
- Platform: Payload CMS 3.x (TypeScript headless CMS)
- Config: payload.config.ts at project root
- Collections: src/collections/ directory
- Database: PostgreSQL with @payloadcms/db-postgres

## Payload Rules
- Collections defined as config objects with fields array
- Field types: text, number, richText, upload, relationship, array, group
- Auth collection: add auth: true for built-in authentication
- Access control: per-collection and per-field access functions
- Hooks: beforeChange, afterChange, beforeRead, afterRead per collection
- Admin panel auto-generated at /admin
- API auto-generated at /api/collection-slug
- Never create manual CRUD routes — Payload handles them

## Conventions
- One file per collection: src/collections/Users.ts, Posts.ts
- Globals for site-wide settings: src/globals/SiteSettings.ts
- Hooks for business logic, not Express middleware
- Access control functions for permissions
- Custom components in src/components/ for admin panel
- Media uploads configured with upload: { ... } field type
- Blocks for flexible page building (layout builder pattern)
```

## Workflow Example

You want to create a blog with categories and media uploads. Prompt Claude Code:

"Create Payload CMS collections for blog posts, categories, and media. Posts should have a title, rich text content, featured image (upload), categories (relationship), author (relationship to users), and publish date. Add access control so only logged-in users can create posts."

Claude Code should create collection configs in `src/collections/` with proper field definitions, a `relationship` field linking to Categories, an `upload` field for the featured image, and access control functions like `create: ({ req }) => !!req.user` on the Posts collection.

## Common Pitfalls

1. **Relationship field direction confusion.** Claude creates bidirectional relationships manually. Payload relationship fields are unidirectional by default. Use the `hasMany: true` option for one-to-many and Payload handles the join.

2. **Rich text editor configuration.** Claude uses a basic text field for content. Payload's rich text field supports Lexical editor with customizable toolbars, embedded blocks, and media — configure it with `editor: lexicalEditor({ features })`.

3. **Deployment database mismatch.** Claude develops with SQLite (default) and deploys to production. Payload supports PostgreSQL and MongoDB for production — configure the production adapter in `payload.config.ts` and ensure schemas migrate properly. For a deeper dive, see [Claude Code for Kamal Deploy — Workflow Guide](/claude-code-for-kamal-deploy-workflow-guide/).

## Related Guides

- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## Related Articles

- [Claude Code for Microbenchmark Workflow Tutorial Guide](/claude-code-for-microbenchmark-workflow-tutorial-guide/)
- [How to Use For Braintree Payment — Complete Developer (2026)](/claude-code-for-braintree-payment-workflow-guide/)
- [Claude Code for Confluence Workflow Tutorial Guide](/claude-code-for-confluence-workflow-tutorial-guide/)
- [Claude Code for Transaction Tracing Workflow Tutorial](/claude-code-for-transaction-tracing-workflow-tutorial/)
- [Claude Code for Auto Assign Reviewer Workflow Tutorial](/claude-code-for-auto-assign-reviewer-workflow-tutorial/)
- [Claude Code for Nomad Container Scheduling Workflow](/claude-code-for-nomad-container-scheduling-workflow/)
- [Claude Code For Step Ca Pki — Complete Developer Guide](/claude-code-for-step-ca-pki-workflow-guide/)
- [How to Use Ripgrep: Search Workflow (2026)](/claude-code-with-ripgrep-and-grep-workflow-tips/)
