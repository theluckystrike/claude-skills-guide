---
sitemap: false
layout: default
title: "Claude Code for Hanko Auth (2026)"
description: "Claude Code for Hanko Auth — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-hanko-auth-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, hanko, workflow]
---

## The Setup

You are implementing passwordless authentication using Hanko, which provides passkey-first auth with WebAuthn support and pre-built UI components. Claude Code can integrate Hanko's auth flow, but it defaults to building password-based login forms and misunderstands the passkey registration and verification flow.

## What Claude Code Gets Wrong By Default

1. **Builds password fields and bcrypt hashing.** Claude generates traditional email/password forms. Hanko is passkey-first — users register with biometrics or security keys via WebAuthn. There are no passwords to hash.

2. **Creates custom auth UI components.** Claude builds login forms from scratch with controlled inputs. Hanko provides `<hanko-auth>` and `<hanko-profile>` web components that handle the entire auth UI, including passkey registration, email verification, and fallback flows.

3. **Uses JWT verification with jsonwebtoken.** Claude verifies tokens with the `jsonwebtoken` npm package. Hanko issues JWTs that should be verified using Hanko's JWKS endpoint and the `jose` library for proper key rotation support.

4. **Ignores the Hanko API URL configuration.** Claude hardcodes auth endpoints. Hanko requires a `HANKO_API_URL` that points to your Hanko Cloud instance or self-hosted Hanko backend, and all components need this URL to function.

## The CLAUDE.md Configuration

```
# Hanko Passkey Auth Project

## Architecture
- Auth: Hanko (passkey-first, WebAuthn)
- Components: @teamhanko/hanko-elements (web components)
- Backend: Hanko Cloud or self-hosted Hanko backend
- JWT: Verified via Hanko JWKS endpoint

## Hanko Rules
- Use <hanko-auth> web component for login/register UI
- Use <hanko-profile> web component for user settings
- No password fields — Hanko handles passkeys and email codes
- JWT in cookie, verified with jose library + Hanko JWKS URL
- HANKO_API_URL env var points to Hanko instance
- Register web components: register(HANKO_API_URL) from @teamhanko/hanko-elements
- Access user info: hanko.user.getCurrent() from @teamhanko/hanko-frontend-sdk

## Conventions
- Hanko elements registered once in app entry point
- Auth middleware verifies JWT on protected API routes
- JWKS URL: {HANKO_API_URL}/.well-known/jwks.json
- User ID from JWT sub claim
- Session cookie name: hanko (httpOnly, secure)
- Never build custom auth forms — use Hanko components
```

## Workflow Example

You want to add passkey login to a Next.js app with protected routes. Prompt Claude Code:

"Integrate Hanko auth into this Next.js app. Add the login page with Hanko components, create middleware that verifies the Hanko JWT on protected routes, and add a profile page where users can manage their passkeys."

Claude Code should register Hanko elements in a client component, create a `/login` page rendering `<hanko-auth>`, build Next.js middleware that extracts the JWT cookie and verifies it against the Hanko JWKS endpoint using `jose`, and add a `/profile` page with `<hanko-profile>`.

## Common Pitfalls

1. **Web component registration in SSR.** Claude registers Hanko elements at the module level, which fails during server-side rendering because web components need the DOM. Wrap registration in a `useEffect` or use `"use client"` directive with dynamic imports.

2. **JWKS caching miss.** Claude fetches the JWKS endpoint on every request without caching. This adds latency and can hit rate limits. Cache the JWKS response using `jose.createRemoteJWKSet()` which handles caching and key rotation automatically.

3. **Missing redirect after authentication.** Claude renders `<hanko-auth>` but does not listen for the `onAuthFlowCompleted` event. Without this callback, users complete authentication but stay on the login page instead of redirecting to the dashboard.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## See Also

- [Claude Code for Clerk Auth — Workflow Guide](/claude-code-for-clerk-auth-workflow-guide/)


## Common Questions

### Is my data safe when using AI coding tools?

Review each tool's data handling policy. Claude Code processes code locally by default. For sensitive projects, use API-based access with enterprise data agreements and avoid sharing credentials in prompts.

### How do I audit AI-generated code for security?

Run static analysis tools on all AI-generated code. Review authentication logic, input validation, and data handling manually. Treat AI output like any untrusted code contribution.

### What are the compliance considerations?

Check your organization's policies on AI code generation. Many frameworks (SOC 2, HIPAA) require documentation of AI tool usage. Maintain audit logs of AI-assisted changes.

## Related Resources

- [Claude Code for Better Auth](/claude-code-for-better-auth-workflow-guide/)
- [Claude Code for Clerk Auth](/claude-code-for-clerk-auth-workflow-guide/)
- [Claude Code for Lucia Auth](/claude-code-for-lucia-auth-workflow-workflow-guide/)
