---
layout: default
title: "Claude Code for WorkOS AuthKit (2026)"
description: "Claude Code for WorkOS AuthKit — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-workos-authkit-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, workos, workflow]
---

## The Setup

You are adding enterprise authentication features using WorkOS AuthKit — SSO, SCIM directory sync, and passwordless auth for B2B SaaS applications. WorkOS handles the complexity of enterprise identity providers (Okta, Azure AD, Google Workspace). Claude Code can implement WorkOS flows, but it defaults to consumer auth patterns that miss the enterprise-specific requirements.

## What Claude Code Gets Wrong By Default

1. **Builds social OAuth instead of enterprise SSO.** Claude implements Google/GitHub OAuth for login. WorkOS handles enterprise SSO with SAML and OIDC — companies connect their Okta or Azure AD identity provider, not consumer social accounts.

2. **Creates user tables without organization context.** Claude designs user-only data models. WorkOS AuthKit is organization-centric — users belong to organizations, and enterprise features (SSO, directory sync) are configured per organization.

3. **Uses JWT validation without JWKS.** Claude validates WorkOS JWTs with a static secret. WorkOS uses JWKS (JSON Web Key Set) for token validation with key rotation — use the WorkOS SDK's `verifySession()` or fetch keys from the JWKS endpoint.

4. **Skips the directory sync webhook.** Claude creates users only through the auth flow. WorkOS Directory Sync (SCIM) provisions and deprovisions users automatically from the company's identity provider — you need webhook handlers for these events.

## The CLAUDE.md Configuration

```
# WorkOS AuthKit Enterprise Auth

## Architecture
- Auth: WorkOS AuthKit (@workos-inc/authkit-nextjs)
- SSO: Enterprise SAML/OIDC via WorkOS dashboard
- Directory: SCIM sync for user provisioning
- Webhooks: /api/webhooks/workos for directory events

## WorkOS Rules
- Use AuthKit middleware for session management
- SSO configured per organization in WorkOS dashboard
- Session validation: authkit.verifySession()
- User info: authkit.getUser() in server components
- Organization context required for enterprise features
- Directory sync events via webhooks (user.created, user.deleted)
- Verify webhook signatures with WorkOS SDK
- WORKOS_API_KEY, WORKOS_CLIENT_ID in environment

## Conventions
- AuthKit middleware in middleware.ts
- Webhook handler in /api/webhooks/workos/route.ts
- Organization ID stored with tenant data
- SSO connection setup via WorkOS admin portal link
- User provisioning/deprovisioning handled by directory sync
- Never store passwords for SSO users — WorkOS handles auth
- Multi-tenant: org context required on all data queries
```

## Workflow Example

You want to add SSO login and directory sync to your SaaS app. Prompt Claude Code:

"Integrate WorkOS AuthKit for enterprise SSO. Set up the AuthKit middleware for session management, create a webhook handler for directory sync events to provision and deprovision users, and add an admin endpoint that generates the SSO setup portal link for customers."

Claude Code should configure AuthKit middleware for Next.js, create the webhook handler verifying signatures and handling `dsync.user.created`/`dsync.user.deleted` events, and add an API endpoint using `workos.portal.generateLink({ intent: 'sso', organization: orgId })` for customer self-service SSO setup.

## Common Pitfalls

1. **Missing organization context in queries.** Claude fetches all users globally. WorkOS is multi-tenant — always scope database queries to the user's organization. Use `authkit.getUser().organizationId` to filter data access.

2. **Webhook replay vulnerability.** Claude processes webhooks without idempotency checks. Directory sync events can be replayed. Track processed event IDs and skip duplicates to prevent creating duplicate users or double-deleting.

3. **SSO-only vs universal login confusion.** Claude forces all users through SSO. WorkOS AuthKit supports both SSO and email/password — SSO is configured per organization. New signups use email login, and enterprises enable SSO when ready.

## Related Guides

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
