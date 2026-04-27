---
sitemap: false
layout: default
title: "Claude Code for Ory Auth (2026)"
description: "Claude Code for Ory Auth — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-ory-auth-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, ory, workflow]
---

## The Setup

You are implementing authentication and identity management with Ory, an open-source identity infrastructure platform. Ory provides Kratos (identity/user management), Hydra (OAuth2/OIDC), Oathkeeper (API gateway), and Keto (permissions). Unlike auth libraries, Ory runs as separate services that your application integrates with via APIs. Claude Code can implement auth, but it generates monolithic auth code instead of integrating with Ory's service architecture.

## What Claude Code Gets Wrong By Default

1. **Implements auth logic in the application.** Claude writes password hashing, session management, and token validation in your app code. Ory Kratos handles all identity operations as a service — your app calls Kratos APIs, not implements auth.

2. **Creates a single auth middleware.** Claude builds one middleware for authentication and authorization. Ory separates these: Kratos handles identity (who are you), Oathkeeper handles API access (are you allowed), and Keto handles permissions (what can you do).

3. **Stores sessions in the application database.** Claude creates a sessions table in your app database. Ory Kratos manages sessions in its own database — your app validates sessions by calling Kratos's `/sessions/whoami` endpoint.

4. **Builds OAuth flows from scratch.** Claude implements OAuth2 authorization code flow manually. Ory Hydra is a full OAuth2/OIDC server — it handles the protocol, token issuance, and consent flows.

## The CLAUDE.md Configuration

```
# Ory Identity Project

## Auth
- Platform: Ory (open-source identity infrastructure)
- Kratos: identity management (signup, login, recovery)
- Hydra: OAuth2/OIDC server
- Oathkeeper: API gateway/proxy
- Keto: permission/authorization service

## Ory Rules
- Kratos: /self-service/ endpoints for auth flows
- Session check: GET /sessions/whoami with cookie
- Registration: redirect to Kratos self-service UI
- Login: Kratos handles form + validation
- Recovery: Kratos handles password reset flow
- Custom UI: your app renders forms, Kratos processes
- SDK: @ory/client for API calls

## Conventions
- Kratos config: kratos.yml (identity schemas, flows)
- Identity schema: JSON Schema for user attributes
- Self-service flows: browser and API modes
- UI nodes: Kratos returns form fields, your app renders
- Webhooks: Kratos fires on registration, login events
- Deploy: Docker Compose for Ory services
- Use @ory/integrations for framework-specific helpers
```

## Workflow Example

You want to add user registration with email verification to your Next.js app using Ory Kratos. Prompt Claude Code:

"Integrate Ory Kratos registration flow into our Next.js app. Create the registration page that renders Kratos UI nodes, handle form submission through Kratos, and add email verification. Use the Ory SDK for API calls."

Claude Code should create a registration page that initiates a Kratos self-service flow with `ory.createBrowserRegistrationFlow()`, render the UI nodes returned by Kratos as form fields, submit the form back to Kratos with `ory.updateRegistrationFlow()`, handle the verification redirect, and check session status with `ory.toSession()`.

## Common Pitfalls

1. **CORS issues between app and Kratos.** Claude deploys the app and Kratos on different domains without CORS config. Kratos needs `serve.public.cors.allowed_origins` configured to include your app's domain, or use a reverse proxy to serve both on the same domain.

2. **Missing cookie configuration for sessions.** Claude calls Kratos API without forwarding cookies. Kratos session cookies must be forwarded between the browser, your app, and Kratos — configure `cookie.domain` and `cookie.same_site` in Kratos config.

3. **Identity schema changes without migration.** Claude modifies the Kratos identity schema without considering existing users. Schema changes can break existing identities — use Kratos's schema versioning and migration strategies for production changes.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Claude Code for Better Auth Workflow Guide](/claude-code-for-better-auth-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

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
- [Claude Code for Hanko Auth](/claude-code-for-hanko-auth-workflow-guide/)
