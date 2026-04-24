---
layout: default
title: "Claude Code for Lucia Auth (2026)"
description: "Claude Code for Lucia Auth — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-lucia-auth-workflow-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, lucia, workflow]
---

## The Setup

You are implementing authentication using Lucia, the session management library that gives you full control over auth without the magic of full auth platforms. Lucia handles session creation, validation, and cookie management while you own the database schema and auth logic. Claude Code can implement Lucia flows, but it either over-abstracts with NextAuth patterns or under-abstracts with raw cookie management.

## What Claude Code Gets Wrong By Default

1. **Uses NextAuth/Auth.js provider patterns.** Claude generates `providers: [Google, GitHub]` config arrays. Lucia is not a provider-based system — you implement OAuth flows manually and use Lucia only for session management after authentication.

2. **Stores sessions in JWT tokens.** Claude creates stateless JWTs for auth. Lucia uses database-backed sessions — each session is a row in your sessions table, giving you server-side control over revocation and expiration.

3. **Implements cookie parsing manually.** Claude writes `req.cookies.get('session')` with manual parsing. Lucia provides framework-specific adapters that handle cookie setting, reading, and CSRF protection.

4. **Skips the database adapter setup.** Claude creates sessions without configuring Lucia's database adapter. Lucia requires an adapter (Drizzle, Prisma, etc.) to persist sessions — without it, sessions are lost on server restart.

## The CLAUDE.md Configuration

```
# Lucia Auth Project

## Architecture
- Auth: Lucia v3 (session management library)
- Database: PostgreSQL with Drizzle adapter
- OAuth: Arctic library for OAuth providers
- Sessions: Database-backed, not JWT

## Lucia Rules
- Lucia handles sessions only — auth logic is yours
- Sessions stored in database via adapter (drizzle-adapter)
- Use Arctic (@oslojs/oauth2) for OAuth provider flows
- Password hashing: Scrypt from lucia or @node-rs/argon2
- Cookies managed by Lucia — do not set auth cookies manually
- Session validation: lucia.validateSession(sessionId)
- Create session: lucia.createSession(userId, attributes)

## Conventions
- Lucia instance in lib/auth.ts
- Database tables: user, session (required by Lucia)
- OAuth callbacks in /api/auth/callback/[provider]
- Middleware validates session on every request
- Session expiration: 30 days, extended on use
- Invalidate on logout: lucia.invalidateSession(sessionId)
- Never store sensitive data in session attributes
```

## Workflow Example

You want to add GitHub OAuth login with Lucia sessions. Prompt Claude Code:

"Implement GitHub OAuth login using Arctic for the OAuth flow and Lucia for session management. Create the authorization URL endpoint, callback handler that creates a user and session, and middleware that validates the session on protected routes."

Claude Code should create a GitHub OAuth instance with Arctic, an `/api/auth/github` route that redirects to GitHub's auth URL, a `/api/auth/callback/github` handler that exchanges the code for user info, creates/updates the user in the database, creates a Lucia session with `lucia.createSession()`, and sets the session cookie. Middleware should call `lucia.validateSession()` on every protected request.

## Common Pitfalls

1. **Lucia v2 vs v3 API confusion.** Claude mixes APIs from different versions. Lucia v3 simplified the API significantly — there is no `auth.handleRequest()`, and session attributes work differently. Check the version in `package.json` and use the matching API.

2. **Missing CSRF protection.** Claude implements session cookies without CSRF tokens. Lucia's cookie utilities include CSRF protection, but you must use Lucia's provided functions rather than setting cookies manually, or CSRF checks will not work.

3. **Session table schema mismatch.** Claude creates a sessions table with custom columns that do not match Lucia's expected schema. Lucia requires specific columns (`id`, `userId`, `expiresAt`) with exact types. Use the schema from Lucia's documentation for your database adapter.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Best Way to Use Claude Code for Database Migrations](/best-way-to-use-claude-code-for-database-migrations/)
