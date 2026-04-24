---
layout: default
title: "Claude Code for SuperTokens Auth"
description: "Add self-hosted auth with SuperTokens and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-supertokens-auth-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, supertokens, workflow]
---

## The Setup

You are implementing authentication with SuperTokens, an open-source auth solution that can be self-hosted or used as a managed service. SuperTokens provides pre-built UI components for login flows, session management with rotating refresh tokens, and recipes for email/password, social login, passwordless, and multi-factor auth. Claude Code can implement auth, but it generates NextAuth or Firebase Auth patterns instead of SuperTokens' recipe-based approach.

## What Claude Code Gets Wrong By Default

1. **Uses NextAuth provider configuration.** Claude writes `providers: [GoogleProvider({...})]` arrays. SuperTokens uses recipes: `ThirdParty.init({ signInAndUpFeature: { providers: [Google({...})] } })` — a different initialization pattern.

2. **Creates custom login UI from scratch.** Claude builds login forms manually. SuperTokens provides pre-built, customizable UI components — `import { SignInAndUp } from "supertokens-auth-react/recipe/thirdpartyemailpassword"` renders a complete auth UI.

3. **Manages sessions with JWT in localStorage.** Claude stores JWT in localStorage and attaches it to headers. SuperTokens uses HTTP-only cookies with automatic refresh token rotation — session management is handled by the SDK.

4. **Ignores the SuperTokens Core service.** Claude expects auth to be embedded in the app. SuperTokens runs a separate Core service (or managed service) that handles the auth logic — your app communicates with it through the SDK.

## The CLAUDE.md Configuration

```
# SuperTokens Auth Project

## Auth
- Library: SuperTokens (open-source or managed)
- Core: SuperTokens Core service (self-hosted or cloud)
- Recipes: EmailPassword, ThirdParty, Passwordless, MFA
- Sessions: HTTP-only cookies with refresh rotation

## SuperTokens Rules
- Backend: supertokens-node SDK initialization
- Frontend: supertokens-auth-react SDK initialization
- Recipes: configure per auth method needed
- Core URL: connectionURI pointing to SuperTokens Core
- Pre-built UI: import from recipe/prebuiltui
- Custom UI: override recipe functions
- Session: verifySession middleware for protected routes

## Conventions
- Backend init in supertokensInit.ts
- Frontend init in app entry point
- Pre-built UI at /auth route
- verifySession() middleware on protected API routes
- getSession() in server components/API routes
- Custom styling via style overrides
- Self-host Core via Docker or use managed service
```

## Workflow Example

You want to set up SuperTokens with email/password and Google OAuth in a Next.js app. Prompt Claude Code:

"Integrate SuperTokens with email/password and Google third-party login in our Next.js 14 app. Use the pre-built UI components, configure session management, add middleware to protect API routes, and set up the SuperTokens Core connection."

Claude Code should initialize the SuperTokens backend SDK with `ThirdPartyEmailPassword` recipe and connection URI, initialize the frontend SDK in the app layout, create the `/auth` page with pre-built UI component, add `verifySession()` to API route middleware, and configure CORS for the SuperTokens Core connection.

## Common Pitfalls

1. **CORS issues between app and Core.** Claude deploys the app and SuperTokens Core on different domains without CORS. Configure `appInfo.apiDomain` and `appInfo.websiteDomain` correctly, and set CORS headers on the API server to allow SuperTokens cookie-based sessions.

2. **Missing middleware for session refresh.** Claude checks sessions but does not handle token refresh. SuperTokens automatically refreshes expired access tokens using the refresh token — ensure the middleware SDK is properly initialized to handle the refresh flow.

3. **Not running SuperTokens Core.** Claude initializes the SDK without starting the Core service. SuperTokens Core must be running (Docker: `docker run supertokens/supertokens-postgresql`) — the SDK communicates with Core for all auth operations.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Claude Code for Better Auth Workflow Guide](/claude-code-for-better-auth-workflow-guide/)
- [Claude Code for Clerk Auth Workflow Guide](/claude-code-for-clerk-auth-workflow-guide/)
