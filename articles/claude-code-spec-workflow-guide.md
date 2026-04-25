---
layout: default
title: "Claude Code Spec Workflow (2026)"
description: "Spec-driven development with Claude Code. Write specifications first, let Claude implement, then verify against the spec. Full workflow with examples."
permalink: /claude-code-spec-workflow-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Code Spec Workflow: Write Specs First (2026)

The spec workflow is a development pattern where you write a detailed specification before Claude Code writes any code. Instead of describing what you want in a chat prompt and hoping Claude interprets it correctly, you create a structured document that defines inputs, outputs, behavior, edge cases, and constraints. Then Claude implements against that spec.

This approach consistently produces better results than freeform prompting because it eliminates ambiguity, provides built-in acceptance criteria, and gives Claude a concrete reference to verify its work against.

## Why Specs Work Better Than Prompts

### The Problem with Freeform Prompts

When you tell Claude Code "Build a user registration endpoint," Claude makes dozens of assumptions:

- What fields are required?
- How should passwords be validated?
- What error format should be used?
- Should email verification be included?
- What response shape does the client expect?
- What status codes should be returned?

Each assumption has a chance of being wrong. With 20 assumptions, even a 90% accuracy rate means 2 assumptions are wrong. You spend time finding and correcting them.

### What Specs Solve

A spec removes assumptions by stating decisions explicitly:

```markdown
## POST /api/auth/register

### Request Body
- email: string (required, RFC 5322 format)
- password: string (required, min 8 chars, at least 1 uppercase, 1 number)
- name: string (required, 2-100 chars)

### Success Response (201)
{ "id": "uuid", "email": "string", "name": "string", "createdAt": "ISO8601" }

### Error Response (400)
{ "code": "VALIDATION_ERROR", "errors": [{ "field": "email", "message": "Invalid email format" }] }

### Behavior
1. Check if email already exists → 409 CONFLICT
2. Hash password with bcrypt (12 rounds)
3. Insert user record
4. Send verification email (async, do not block response)
5. Return created user (without password)

### Edge Cases
- Email with leading/trailing whitespace: trim before validation
- Email case: normalize to lowercase
- Concurrent registration with same email: database unique constraint handles it, return 409
```

With this spec, Claude has zero ambiguity. Every decision is made. Implementation becomes mechanical.

## The Spec Workflow

### Step 1: Write the Spec

Create a spec file in your project. Convention: `specs/` directory.

```bash
mkdir -p specs
```

Write the spec in Markdown. Use the template in the next section.

### Step 2: Review the Spec

Read through the spec yourself (or with your team). Check for:
- Missing edge cases
- Contradictory requirements
- Unclear terminology
- Missing error scenarios

This is where you catch problems before any code is written. Fixing a spec is free. Fixing implemented code costs time.

### Step 3: Hand the Spec to Claude

```
Read specs/user-registration.md and implement it.
Follow the spec exactly. Do not add features that are not specified.
Do not skip any specified behavior.
```

The instruction to follow the spec exactly is important. Without it, Claude may "improve" things in ways that deviate from your design.

### Step 4: Verify Against the Spec

After Claude implements, verify:

```
Review the implementation against specs/user-registration.md.
For each requirement in the spec, confirm it is implemented.
List any deviations or missing items.
```

Claude compares its own code to the spec and reports gaps. This self-verification step catches most issues.

### Step 5: Write Tests from the Spec

```
Using specs/user-registration.md as the reference,
write tests that verify every requirement.
Include tests for all edge cases listed in the spec.
```

The spec serves as a test plan. Every specified behavior becomes a test case.

## Spec Template

Use this template for feature specs:

```markdown
# Feature: [Feature Name]

## Overview
[1-2 sentences describing what this feature does and why]

## Scope
### In Scope
- [What is included]

### Out of Scope
- [What is explicitly excluded]

## API / Interface

### [Method] [Path/Function]

#### Input
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| field1 | string | Yes | Max 255 chars |
| field2 | number | No | 0-100, default 0 |

#### Output (Success)
```json
{
  "field": "value"
}
```

#### Output (Error)
```json
{
  "code": "ERROR_CODE",
  "message": "Human-readable message"
}
```

### Behavior
1. Step one
2. Step two
3. Step three

### Edge Cases
- [Edge case 1]: [Expected behavior]
- [Edge case 2]: [Expected behavior]

### Error Scenarios
| Scenario | Status Code | Error Code |
|----------|-------------|------------|
| Invalid input | 400 | VALIDATION_ERROR |
| Not found | 404 | NOT_FOUND |
| Unauthorized | 401 | UNAUTHORIZED |

## Data Model Changes
- [Table changes, if any]
- [New columns, indexes, constraints]

## Dependencies
- [External services needed]
- [Libraries to use]

## Security
- [Authentication requirements]
- [Authorization rules]
- [Data sensitivity considerations]

## Performance
- [Expected load]
- [Response time requirements]
- [Caching strategy]

## Testing
- [Specific test scenarios to cover]
- [Integration test requirements]
```

## Real Example: Payment Processing Spec

Here is a complete spec for a real feature:

```markdown
# Feature: Stripe Subscription Checkout

## Overview
Allow authenticated users to subscribe to a plan by creating
a Stripe Checkout session and redirecting to Stripe's hosted page.

## Scope
### In Scope
- Create Stripe Checkout session
- Handle successful checkout (webhook)
- Handle failed/expired checkout
- Store subscription data in database

### Out of Scope
- Plan management (existing)
- Subscription cancellation (separate spec)
- Invoice handling (separate spec)
- Free trial logic (Phase 2)

## API

### POST /api/checkout/create-session

#### Input
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| planId | uuid | Yes | Must exist in plans table |
| successUrl | string | Yes | Valid URL |
| cancelUrl | string | Yes | Valid URL |

#### Headers
- Authorization: Bearer <JWT> (required)

#### Output (200)
```json
{
  "sessionId": "cs_live_...",
  "url": "https://checkout.stripe.com/..."
}
```

#### Output (400)
```json
{
  "code": "INVALID_PLAN",
  "message": "Plan not found or inactive"
}
```

#### Output (409)
```json
{
  "code": "ALREADY_SUBSCRIBED",
  "message": "User already has an active subscription"
}
```

### Behavior
1. Verify user is authenticated (JWT validation)
2. Fetch plan from database by planId
3. If plan not found or plan.active is false → 400
4. Check if user has existing active subscription → 409
5. Look up or create Stripe customer for user
   - If user.stripe_customer_id exists, use it
   - If not, create Stripe customer with user email
   - Store stripe_customer_id on user record
6. Create Stripe Checkout session:
   - mode: "subscription"
   - customer: stripe_customer_id
   - line_items: [{ price: plan.stripe_price_id, quantity: 1 }]
   - success_url: successUrl + "?session_id={CHECKOUT_SESSION_ID}"
   - cancel_url: cancelUrl
   - metadata: { userId, planId }
7. Return session ID and URL

### POST /api/webhooks/stripe (Webhook Handler)

#### Events Handled
- `checkout.session.completed`
- `checkout.session.expired`

#### checkout.session.completed
1. Verify webhook signature using STRIPE_WEBHOOK_SECRET
2. Extract userId and planId from metadata
3. Extract subscription ID from session
4. Insert subscription record:
   - user_id: metadata.userId
   - plan_id: metadata.planId
   - stripe_subscription_id: session.subscription
   - status: "active"
   - current_period_start: subscription.current_period_start
   - current_period_end: subscription.current_period_end
5. Return 200

#### checkout.session.expired
1. Verify webhook signature
2. Log expiration event
3. No database changes
4. Return 200

### Edge Cases
- User creates session, closes browser, never completes:
  Session expires after 24 hours, webhook fires checkout.session.expired
- User completes checkout but webhook fails:
  Stripe retries webhooks for up to 3 days. Handler must be idempotent.
- Duplicate webhook delivery:
  Check if subscription with stripe_subscription_id already exists.
  If yes, skip insert, return 200.
- Plan price changes between session creation and completion:
  Stripe uses the price locked at session creation time. No issue.
- User's payment method fails:
  Stripe handles this on their checkout page. We never see incomplete payments.

### Error Scenarios
| Scenario | Status | Code | Notes |
|----------|--------|------|-------|
| No auth token | 401 | UNAUTHORIZED | |
| Invalid plan | 400 | INVALID_PLAN | Plan not found or inactive |
| Already subscribed | 409 | ALREADY_SUBSCRIBED | Active sub exists |
| Stripe API error | 502 | STRIPE_ERROR | Log full error, return safe message |
| Invalid webhook signature | 400 | INVALID_SIGNATURE | Do not process |

## Data Model Changes
- users table: Add stripe_customer_id (text, nullable, unique)
- subscriptions table: Already exists (from schema spec)

## Dependencies
- Stripe SDK (stripe npm package)
- STRIPE_SECRET_KEY (env variable)
- STRIPE_WEBHOOK_SECRET (env variable)
- STRIPE_PRICE_ID per plan (stored in plans.stripe_price_id)

## Security
- Webhook endpoint must verify Stripe signature
- Never expose Stripe secret key in responses
- Checkout session metadata cannot be tampered with by user
- Rate limit: 10 session creations per user per hour

## Performance
- Stripe API calls: ~200-500ms each
- Total endpoint latency: < 1 second
- No caching needed (low volume, always fresh data)

## Testing
- Unit: createCheckoutSession() with mocked Stripe client
- Unit: handleCheckoutCompleted() with mocked database
- Integration: Full checkout flow with Stripe test mode
- Edge: Duplicate webhook handling (call handler twice, verify single record)
- Edge: Expired session webhook
- Error: Invalid plan ID
- Error: Already subscribed user
```

### Handing This Spec to Claude

```
Read specs/stripe-checkout.md and implement the following:
1. API route at src/app/api/checkout/create-session/route.ts
2. Webhook handler at src/app/api/webhooks/stripe/route.ts
3. Database migration for users.stripe_customer_id
4. Unit tests for both endpoints
5. Follow the spec exactly. Every edge case must be handled.
```

Claude implements each item against the spec. Because every decision is made in the spec, Claude's implementation matches your design intent precisely.

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Spec Workflow Variations

### Variation 1: Test-First Spec

Write the spec as tests first, then have Claude implement:

```
I have test specs in tests/checkout.test.ts that define
the expected behavior. Read them and implement the code
that makes all tests pass.
```

This is TDD powered by AI. The tests serve as the spec.

### Variation 2: Incremental Spec

For large features, break the spec into phases:

```markdown
# Phase 1: Basic Checkout (this sprint)
- Session creation
- Webhook handling
- Database storage

# Phase 2: Subscription Management (next sprint)
- Cancellation
- Plan changes
- Invoice history

# Phase 3: Billing Portal (future)
- Self-service billing
- Payment method updates
```

Implement Phase 1 first. Phase 2 builds on Phase 1's code.

### Variation 3: Architecture Spec

Before feature specs, write an architecture spec:

```markdown
# Architecture: Billing Module

## Module Location
src/features/billing/

## Internal Structure
- routes/ - API endpoint handlers
- services/ - Business logic
- repositories/ - Database access
- types/ - TypeScript interfaces
- webhooks/ - Webhook handlers
- __tests__/ - All tests

## Dependencies
- Depends on: auth module (user context), database module (queries)
- Depended on by: dashboard module (subscription status display)

## Patterns
- Repository pattern for database access
- Service layer for business logic
- Route handlers are thin (validation + service call + response)
```

Then Claude follows this architecture for all billing features.

### Variation 4: Fix Spec

For bug fixes, write a short spec:

```markdown
# Bug Fix: Duplicate Subscriptions

## Problem
When Stripe sends duplicate checkout.session.completed webhooks,
we create multiple subscription records for the same user.

## Root Cause
No idempotency check in webhook handler.

## Fix
Before inserting subscription, check if stripe_subscription_id
already exists. If yes, return 200 without inserting.

## Verification
1. Call webhook handler twice with same session data
2. Verify only one subscription record exists
3. Both calls return 200
```

## Tips for Writing Better Specs

### Tip 1: Start with the Interface

Define inputs and outputs before behavior. This forces you to think about the contract before the implementation.

### Tip 2: List Every Error Scenario

Most bugs come from unhandled errors. List every way the feature can fail and what should happen.

### Tip 3: Include Non-Obvious Constraints

Things Claude would not guess:
- "Email comparison must be case-insensitive"
- "Amounts are in cents, not dollars"
- "Timezone is always UTC, even for display"

### Tip 4: Reference Existing Patterns

```markdown
## Implementation Notes
Follow the same pattern as src/features/auth/services/login.ts:
- Validate input with Zod
- Call repository method
- Map to response type
- Handle errors with ErrorCode enum
```

This gives Claude a concrete reference in your codebase.

### Tip 5: Define What NOT to Do

```markdown
## Do NOT
- Do not send verification email synchronously (use a job queue)
- Do not store the Stripe session ID in the URL visible to the user
- Do not log the full webhook body (contains sensitive data)
```

### Tip 6: Keep Specs in Version Control

Commit specs to your repo:

```
my-project/
  specs/
    user-registration.md
    stripe-checkout.md
    notification-system.md
  src/
```

They serve as living documentation alongside the code.

## Integrating Specs with CLAUDE.md

Add a spec workflow section to your [CLAUDE.md](/claude-md-best-practices-definitive-guide/):

```markdown
## Spec Workflow
- Feature specs live in specs/ directory
- Always read the relevant spec before implementing
- Follow specs exactly. Do not add unspecified features.
- After implementing, verify against the spec and report gaps.
- Write tests that cover every spec requirement.
```

This ensures Claude follows the spec workflow automatically when specs exist.

## Combining Specs with Claude Code Features

### Specs + Hooks

Use a [Stop hook](/claude-code-hooks-complete-guide/) to verify spec compliance before Claude finishes:

```bash
#!/bin/bash
# verify-spec.sh (Stop hook)
if [ -f "specs/current.md" ]; then
  echo "Verify your implementation against specs/current.md before stopping."
  echo "List any unimplemented requirements."
fi
```

### Specs + MCP

With [Supabase MCP](/claude-code-mcp-supabase-setup-guide/), Claude can verify database changes match the spec:

```
Check the database schema against the data model section
of specs/stripe-checkout.md. Report any missing columns or constraints.
```

### Specs + Extended Thinking

For complex specs, enable extended thinking so Claude can reason through the requirements before coding:

```
Read specs/notification-system.md. Use extended thinking to plan
the implementation before writing any code. Then implement.
```

## Frequently Asked Questions

### How detailed should specs be?
Detailed enough that two developers would implement the same behavior independently. If a requirement is ambiguous, specify it further.

### Who writes the specs?
The developer, tech lead, or product manager. Writing the spec is the thinking part. Claude handles the mechanical coding part.

### How long does it take to write a spec?
A typical feature spec takes 15-45 minutes. This time is more than recovered by reduced back-and-forth with Claude and fewer bugs.

### Can Claude write the spec for me?
Yes, but review it carefully. Claude can draft a spec from a high-level description, but you must validate every decision it makes. The spec represents YOUR design intent.

### Do I need specs for small changes?
No. For a one-line bug fix or simple refactoring, a clear prompt is sufficient. Specs are for features with multiple requirements, edge cases, or team collaboration.

### What if the spec changes during implementation?
Update the spec file and tell Claude: "The spec has been updated. Re-read specs/feature.md and adjust the implementation." Keep the spec as the source of truth.

### How do specs work in a team?
Specs go through code review like any other file. Team members review the spec before implementation begins. This catches design issues before any code is written.

### Should specs include implementation details?
Include architectural decisions (which patterns, which libraries) but not line-by-line code instructions. Let Claude handle the implementation details within your constraints.

### How do specs interact with CLAUDE.md?
[CLAUDE.md](/claude-md-best-practices-definitive-guide/) defines project-wide rules (code style, architecture patterns). Specs define feature-specific requirements. They work together: CLAUDE.md provides the context and constraints, specs provide the feature blueprint. Add a note in CLAUDE.md: "Always read relevant specs from specs/ before implementing."

### Can I use specs with MCP servers?
Yes. Specs that involve database changes pair well with [Supabase MCP](/claude-code-mcp-supabase-setup-guide/) or other database MCP servers. After implementing, Claude can verify database schema changes through MCP match the spec.

### Do specs work with Claude Code hooks?
Yes. Use a [Stop hook](/claude-code-hooks-complete-guide/) to remind Claude to verify against the spec before completing work. This creates an automated verification loop that catches spec deviations.

### Where can I find spec templates for different project types?
Check our [CLAUDE.md best practices guide](/claude-md-best-practices-definitive-guide/) for project-type examples that include spec conventions. The [SuperClaude framework](/super-claude-code-framework-guide/) also includes spec-related commands like `/plan` and `/design`.

### How do specs affect Claude Code costs?
Spec files are read as input tokens when Claude processes them. A typical spec is 500-2,000 tokens. This small upfront cost pays for itself by reducing back-and-forth corrections. Track costs with [token usage auditing](/audit-claude-code-token-usage-step-by-step/).


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### How detailed should specs be?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Detailed enough that two developers would implement the same behavior independently. If a requirement is ambiguous, specify it further."
      }
    },
    {
      "@type": "Question",
      "name": "Who writes the specs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The developer, tech lead, or product manager. Writing the spec is the thinking part. Claude handles the mechanical coding part."
      }
    },
    {
      "@type": "Question",
      "name": "How long does it take to write a spec?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A typical feature spec takes 15-45 minutes. This time is more than recovered by reduced back-and-forth with Claude and fewer bugs."
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude write the spec for me?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, but review it carefully. Claude can draft a spec from a high-level description, but you must validate every decision it makes. The spec represents YOUR design intent."
      }
    },
    {
      "@type": "Question",
      "name": "Do I need specs for small changes?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. For a one-line bug fix or simple refactoring, a clear prompt is sufficient. Specs are for features with multiple requirements, edge cases, or team collaboration."
      }
    },
    {
      "@type": "Question",
      "name": "What if the spec changes during implementation?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Update the spec file and tell Claude: \\\"The spec has been updated. Re-read specs/feature.md and adjust the implementation.\\\" Keep the spec as the source of truth."
      }
    },
    {
      "@type": "Question",
      "name": "How do specs work in a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Specs go through code review like any other file. Team members review the spec before implementation begins. This catches design issues before any code is written."
      }
    },
    {
      "@type": "Question",
      "name": "Should specs include implementation details?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Include architectural decisions (which patterns, which libraries) but not line-by-line code instructions. Let Claude handle the implementation details within your constraints."
      }
    },
    {
      "@type": "Question",
      "name": "How do specs interact with CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "CLAUDE.md defines project-wide rules (code style, architecture patterns). Specs define feature-specific requirements. They work together: CLAUDE.md provides the context and constraints, specs provide the feature blueprint. Add a note in CLAUDE.md: \\\"Always read relevant specs from specs/ before implementing.\\\""
      }
    },
    {
      "@type": "Question",
      "name": "Can I use specs with MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Specs that involve database changes pair well with Supabase MCP or other database MCP servers. After implementing, Claude can verify database schema changes through MCP match the spec."
      }
    },
    {
      "@type": "Question",
      "name": "Do specs work with Claude Code hooks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use a Stop hook to remind Claude to verify against the spec before completing work. This creates an automated verification loop that catches spec deviations."
      }
    },
    {
      "@type": "Question",
      "name": "Where can I find spec templates for different project types?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Check our CLAUDE.md best practices guide for project-type examples that include spec conventions. The SuperClaude framework also includes spec-related commands like /plan and /design."
      }
    },
    {
      "@type": "Question",
      "name": "How do specs affect Claude Code costs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Spec files are read as input tokens when Claude processes them. A typical spec is 500-2,000 tokens. This small upfront cost pays for itself by reducing back-and-forth corrections. Track costs with token usage auditing."
      }
    }
  ]
}
</script>

## See Also

- [CLAUDE.md Best Practices Definitive Guide](/claude-md-best-practices-definitive-guide/)
- [Claude Code Hooks Complete Guide](/claude-code-hooks-complete-guide/)
- [How to Use Claude Code: Beginner Guide](/how-to-use-claude-code-beginner-guide/)


{% endraw %}