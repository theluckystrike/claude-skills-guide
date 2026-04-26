---
layout: default
title: "Claude Code for PocketBase (2026)"
description: "Claude Code for PocketBase — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-pocketbase-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, pocketbase, workflow]
---

## The Setup

You are building a backend with PocketBase, the open-source backend in a single Go binary that provides a database, REST API, authentication, file storage, and admin dashboard out of the box. Claude Code can write PocketBase integrations, but it creates Express APIs and PostgreSQL schemas instead of using PocketBase's SDK and collection system.

## What Claude Code Gets Wrong By Default

1. **Builds an Express API server.** Claude creates route handlers and database connections. PocketBase provides all CRUD endpoints automatically — you define collections through the admin UI or migrations and get REST/realtime APIs for free.

2. **Sets up authentication from scratch.** Claude writes JWT and bcrypt auth logic. PocketBase has built-in auth with email/password, OAuth2, and magic links — configure it in the admin panel, not code.

3. **Uses PostgreSQL or MongoDB.** Claude sets up external databases. PocketBase uses embedded SQLite — no database server needed. Data, auth, and files are all handled by the single PocketBase binary.

4. **Creates file upload infrastructure.** Claude configures S3 and multer for file handling. PocketBase has built-in file storage in collections with automatic thumbnail generation.

## The CLAUDE.md Configuration

```
# PocketBase Backend Project

## Backend
- Platform: PocketBase (single binary backend)
- Database: Embedded SQLite (automatic)
- Auth: Built-in (email, OAuth2, magic link)
- SDK: pocketbase (JavaScript SDK for client)

## PocketBase Rules
- Collections defined in admin UI or migrations
- CRUD API auto-generated: /api/collections/{name}/records
- SDK: const pb = new PocketBase('http://127.0.0.1:8090')
- Auth: pb.collection('users').authWithPassword(email, password)
- Realtime: pb.collection('posts').subscribe('*', callback)
- Files: upload via FormData, access via pb.files.getURL()
- Expand relations: ?expand=author,comments
- Filter: ?filter=(title~'hello' && created>'2024-01-01')

## Conventions
- PocketBase binary in pb/ directory
- Migrations in pb/pb_migrations/ (JavaScript)
- Client SDK in lib/pocketbase.ts
- Auth state: pb.authStore (auto-persisted)
- Realtime subscriptions for live data
- Admin panel: http://localhost:8090/_/
- Never build REST endpoints — PocketBase provides them
```

## Workflow Example

You want to create a blog with user authentication and image uploads. Prompt Claude Code:

"Set up PocketBase collections for a blog. Create users, posts (with title, content, cover image, author relation), and comments collections. Write the client-side code for creating a post with an image upload and listing posts with expanded author data."

Claude Code should define collections via migration files, write client code using `pb.collection('posts').create(formData)` with the cover image in FormData, and list posts with `pb.collection('posts').getList(1, 20, { expand: 'author' })` to include the author's name and avatar.

## Common Pitfalls

1. **Auth store not persisted across page reloads.** Claude creates the PocketBase instance but does not configure auth store persistence. Use `pb.authStore.onChange()` to save tokens to localStorage, or PocketBase's built-in cookie store for SSR frameworks.

2. **Realtime subscription cleanup.** Claude subscribes to collections but never unsubscribes. PocketBase subscriptions use WebSocket connections — unsubscribe with `pb.collection('posts').unsubscribe()` when the component unmounts.

3. **File URL construction.** Claude builds file URLs manually with string concatenation. PocketBase provides `pb.files.getURL(record, filename)` which handles the correct URL format including CDN paths and thumb sizes.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)

## Related Articles

- [Claude Code for Microbenchmark Workflow Tutorial Guide](/claude-code-for-microbenchmark-workflow-tutorial-guide/)
- [How to Use For Braintree Payment — Complete Developer (2026)](/claude-code-for-braintree-payment-workflow-guide/)
- [Claude Code for Confluence Workflow Tutorial Guide](/claude-code-for-confluence-workflow-tutorial-guide/)
- [Claude Code for Transaction Tracing Workflow Tutorial](/claude-code-for-transaction-tracing-workflow-tutorial/)
- [Claude Code for Auto Assign Reviewer Workflow Tutorial](/claude-code-for-auto-assign-reviewer-workflow-tutorial/)
- [Claude Code for Nomad Container Scheduling Workflow](/claude-code-for-nomad-container-scheduling-workflow/)
- [Claude Code For Step Ca Pki — Complete Developer Guide](/claude-code-for-step-ca-pki-workflow-guide/)
- [How to Use Ripgrep: Search Workflow (2026)](/claude-code-with-ripgrep-and-grep-workflow-tips/)


## Common Questions

### How do I get started with claude code for pocketbase?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
