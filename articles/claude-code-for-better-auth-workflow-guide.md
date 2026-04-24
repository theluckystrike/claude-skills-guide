---
layout: default
title: "Claude Code for Better Auth (2026)"
description: "Claude Code for Better Auth — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-better-auth-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, better-auth, workflow]
---

## The Setup

You are implementing authentication with Better Auth, the TypeScript-first auth library that provides email/password, OAuth, magic links, and more with a database-backed approach. Unlike managed services, Better Auth runs in your application and stores data in your database. Claude Code can implement Better Auth, but it generates NextAuth or Clerk patterns that differ significantly.

## What Claude Code Gets Wrong By Default

1. **Uses NextAuth's provider-based config.** Claude writes `providers: [GoogleProvider({...})]` arrays. Better Auth configures providers differently through its `auth()` function with `socialProviders` option.

2. **Creates Clerk-style hosted UI components.** Claude adds pre-built auth components. Better Auth is headless — you build your own UI and call Better Auth's client API methods for authentication operations.

3. **Stores sessions in JWT.** Claude creates stateless JWT tokens. Better Auth uses database-backed sessions by default, giving you server-side session management with revocation support.

4. **Ignores the database adapter setup.** Claude uses Better Auth without configuring a database adapter. Better Auth requires a database (Drizzle, Prisma, or Kysely adapter) to store users, sessions, and accounts.

## The CLAUDE.md Configuration

```
# Better Auth Project

## Auth
- Library: Better Auth (better-auth package)
- Database: Your own DB via adapter (Drizzle/Prisma/Kysely)
- Sessions: Database-backed, not JWT
- UI: Headless — build your own forms

## Better Auth Rules
- Server: const auth = betterAuth({ database, socialProviders, ... })
- Client: const authClient = createAuthClient({ baseURL })
- Sign up: authClient.signUp.email({ email, password, name })
- Sign in: authClient.signIn.email({ email, password })
- OAuth: authClient.signIn.social({ provider: 'google' })
- Session: authClient.getSession() on client, auth.api.getSession() on server
- Middleware: auth.handler for API route handling
- Plugins: two-factor, organization, admin via plugin system

## Conventions
- Auth config in lib/auth.ts (server)
- Auth client in lib/auth-client.ts (client)
- API route: /api/auth/[...all] catches all auth routes
- Database tables auto-created by Better Auth
- Session validation in middleware or server components
- Plugins added via plugins: [twoFactor(), organization()]
- Custom UI: forms call authClient methods directly
```

## Workflow Example

You want to set up email auth with Google OAuth. Prompt Claude Code:

"Integrate Better Auth with email/password and Google OAuth sign-in. Configure the Drizzle database adapter, set up the API route handler, create the auth client, and build a login form component."

Claude Code should create `auth()` config with Drizzle adapter and Google social provider, set up the catch-all API route, create the client with `createAuthClient()`, and build a form that calls `authClient.signIn.email()` and `authClient.signIn.social({ provider: 'google' })`.

## Common Pitfalls

1. **Database tables not migrated.** Claude configures Better Auth but forgets to run migrations. Better Auth needs specific tables (user, session, account, verification). Run `npx better-auth migrate` or let the library auto-create tables on first run.

2. **Client baseURL mismatch.** Claude creates the auth client without specifying `baseURL`, or hardcodes `localhost`. The `baseURL` must match where the auth API route is hosted — use an environment variable that changes per environment.

3. **Missing CSRF protection configuration.** Claude uses the default settings without considering CSRF. Better Auth includes CSRF protection, but custom API routes that interact with auth must include the CSRF token from `authClient.getSession()`.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## Related Articles

- [Claude Code for Ory Auth — Workflow Guide](/claude-code-for-ory-auth-workflow-guide/)
- [Claude Code for Lucia Auth — Workflow Guide](/claude-code-for-lucia-auth-workflow-workflow-guide/)
- [Claude Code for Hanko Auth — Workflow Guide](/claude-code-for-hanko-auth-workflow-guide/)
- [Claude Code for Clerk Auth — Workflow Guide](/claude-code-for-clerk-auth-workflow-guide/)
