---
title: "CLAUDE.md for API Design — Consistent Endpoints, Responses, and Versioning (2026)"
description: "Encode API design patterns in CLAUDE.md so Claude Code generates consistent REST endpoints, response envelopes, pagination, and error formats."
permalink: /claude-md-api-design-patterns/
render_with_liquid: false
categories: [claude-md, patterns]
tags: [claude-md, api-design, rest, response-format, claude-code]
last_updated: 2026-04-19
---

## Why API Consistency Requires Explicit Rules

APIs are contracts. When one endpoint returns errors as `{ "error": "message" }` and another returns `{ "errors": [{ "field": "email", "message": "required" }] }`, every consumer has to write special-case handling. Claude Code generates working API code, but without explicit design rules, it picks whatever pattern seems right for each endpoint. The result is an API that works but is painful to consume.

CLAUDE.md enforces consistency by encoding your API design decisions as rules Claude applies to every endpoint it generates.

## API Design Rules Template

```markdown
## API Design Standards

### URL Structure
- Base path: /api/v1/
- Resources: plural nouns (users, orders, products)
- Nested resources: maximum 2 levels (/users/:id/orders, never /users/:id/orders/:orderId/items/:itemId)
- Actions that are not CRUD: use verbs as sub-resources (/orders/:id/cancel, /users/:id/verify)
- Query parameters: camelCase (sortBy, pageSize, includeDeleted)

### HTTP Methods
- GET: read (never modify state)
- POST: create new resource
- PUT: full replace (client sends complete object)
- PATCH: partial update (client sends only changed fields)
- DELETE: soft delete (set deleted_at, return 204)

### Response Envelope
Every response uses the envelope from src/responses/envelope.ts:

Success:
{
  "data": { ... },
  "meta": { "requestId": "uuid", "timestamp": "iso8601" }
}

Error:
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [{ "field": "email", "message": "must be valid email" }]
  },
  "meta": { "requestId": "uuid", "timestamp": "iso8601" }
}

Collection:
{
  "data": [ ... ],
  "meta": { "requestId": "uuid", "timestamp": "iso8601" },
  "pagination": { "cursor": "abc", "hasMore": true, "total": 142 }
}
```

## Pagination Rules

```markdown
## Pagination
- Default: cursor-based using encoded id
- Query params: cursor (opaque string), limit (default 20, max 100)
- Response: include pagination.cursor (for next page), pagination.hasMore, pagination.total
- NEVER use offset/page number pagination for user-facing APIs (unstable with concurrent writes)
- Admin/internal APIs may use offset pagination with explicit opt-in
```

## Validation and Error Responses

```markdown
## Input Validation
- Validate all request bodies with zod schemas from src/schemas/
- Validate path parameters (UUID format, positive integers)
- Validate query parameters with defaults and bounds
- Return ALL validation errors at once, not just the first one:

### Status Code Mapping
- 200: successful read or update
- 201: successful creation (include Location header)
- 204: successful deletion (no body)
- 400: validation error (include field-level details)
- 401: not authenticated
- 403: authenticated but not authorized
- 404: resource not found
- 409: conflict (duplicate, version mismatch)
- 422: semantically invalid (passes validation but violates business rules)
- 429: rate limited (include Retry-After header)
- 500: unexpected server error (log full details, return generic message)
```

## Versioning Rules

```markdown
## API Versioning
- Version in URL path: /api/v1/, /api/v2/
- Breaking changes require new version
- Breaking changes: removing a field, changing a field type, changing validation rules
- Non-breaking changes: adding optional fields, adding new endpoints
- Deprecation: add Deprecation header with sunset date, log usage for 90 days before removal
- Old versions: maintain for 6 months after new version launches
```

## Path-Specific API Rules

Use `.claude/rules/` to scope API rules to route files:

```markdown
# .claude/rules/api-routes.md
---
paths:
  - "src/routes/**/*.ts"
---

## Route Implementation Rules
- Every route handler: validate input → call service → format response
- Use asyncHandler wrapper from src/middleware/async-handler.ts
- Log request start and completion with duration
- Rate limiting middleware on all public endpoints
- Authentication middleware on all routes except /health and /auth/*
```

## OpenAPI Integration

```markdown
## API Documentation
- OpenAPI spec generated from zod schemas using zod-to-openapi
- Every endpoint has: summary, description, request/response examples
- Spec lives at /api/v1/docs (Swagger UI in development only)
- Update spec when adding or modifying endpoints — spec and code must match
```

## Authentication and Authorization Patterns

```markdown
## Auth Patterns for API Routes
- Bearer token in Authorization header for all authenticated endpoints
- Token validation middleware runs before route handler
- Role-based access: check user.roles against endpoint requirements
- Resource-level authorization: verify user owns or has access to the resource
- Public endpoints explicitly marked with @public decorator or comment
```

## Rate Limiting and Throttling

```markdown
## Rate Limiting
- Default: 100 requests per minute per API key
- Write endpoints: 20 requests per minute per API key
- Bulk endpoints: 5 requests per minute per API key
- Return 429 with Retry-After header (value in seconds)
- Include X-RateLimit-Remaining and X-RateLimit-Reset headers in all responses
```

Including rate limiting rules in your CLAUDE.md ensures Claude adds the correct middleware and headers when generating new endpoints, rather than creating unprotected endpoints that need to be secured after the fact.

For the response envelope pattern and how it integrates with error handling, see the [error handling guide](/claude-md-error-handling-patterns/). For the overall CLAUDE.md structure, see the [senior engineer template](/senior-engineer-claude-md-template/). For database conventions behind your API, see the [database conventions guide](/claude-md-database-conventions/).
