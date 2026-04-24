---
title: "Fix Claude Code Inconsistent API Design"
description: "Fix inconsistent API design from Claude Code by defining response shapes, naming patterns, and error formats in your CLAUDE.md file."
permalink: /claude-code-inconsistent-api-design-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Inconsistent API Design (2026)

One endpoint returns `{ user: {...} }`, another returns `{ data: {...} }`, and a third returns the object directly. Error responses vary between `{ error: "message" }` and `{ message: "error", code: 400 }`. Every client integration becomes a special case.

## The Problem

Claude Code generates API endpoints that are internally consistent but inconsistent with each other:
- Different response wrapper shapes across endpoints
- Varying error response formats
- Inconsistent naming (kebab-case in one route, camelCase in another)
- Mixed HTTP status code semantics
- Pagination that works differently per endpoint

## Root Cause

Each Claude Code request is somewhat independent. When you ask "add a user endpoint" and later "add an orders endpoint," the model may not reference how the first endpoint was built. It generates each endpoint from its general knowledge rather than matching your existing patterns.

## The Fix

Use the API design patterns from [claude-code-templates](https://github.com/davila7/claude-code-templates) (25K+ stars). Their agent templates include REST API conventions you can customize and enforce.

### Step 1: Define Response Shapes

```markdown
## API Response Contract — ALL ENDPOINTS

### Success Response
{
  "data": T,              // The response payload (always under "data")
  "meta": {               // Optional metadata
    "page": number,
    "pageSize": number,
    "total": number
  }
}

### Error Response
{
  "error": {
    "code": "VALIDATION_ERROR",   // Machine-readable error code
    "message": "Email is required", // Human-readable message
    "details": [...]               // Optional field-level errors
  }
}

### NEVER return raw objects without the data/error wrapper.
```

### Step 2: Define Naming and Status Codes

```markdown
## API Naming
- URLs: kebab-case (/api/user-profiles, NOT /api/userProfiles)
- Query params: camelCase (?pageSize=25, NOT ?page_size=25)
- Body fields: camelCase ({ firstName, lastName })

## HTTP Status Codes
- 200: Success (GET, PUT, PATCH)
- 201: Created (POST that creates a resource)
- 204: No Content (DELETE)
- 400: Validation error (bad input)
- 401: Not authenticated
- 403: Not authorized (authenticated but lacking permission)
- 404: Resource not found
- 409: Conflict (duplicate email, etc.)
- 500: Internal server error (never expose stack traces)
```

### Step 3: Define Pagination

```markdown
## Pagination — ALL LIST ENDPOINTS
- Default page size: 25
- Max page size: 100
- Query params: ?page=1&pageSize=25
- Response includes meta: { page, pageSize, total, totalPages }
- NEVER use cursor-based pagination unless the endpoint has 1M+ records
```

## CLAUDE.md Code to Add

```markdown
## API Design Checklist
Before completing any API endpoint:
1. Response matches the standard wrapper shape
2. Error responses use the error wrapper with code + message
3. HTTP status code is correct per our table
4. URL uses kebab-case, body uses camelCase
5. List endpoints include pagination
6. Check existing routes in src/app/api/ for consistency
```

## Verification

1. Ask Claude Code to create three endpoints in sequence
2. Compare response shapes: Are they identical in structure?
3. Compare error handling: Same format across all three?
4. Compare naming: Consistent casing?

## Prevention

Add API contract tests using a schema validator:

```typescript
import { apiResponseSchema } from '@/schemas/api';
expect(apiResponseSchema.safeParse(response.body).success).toBe(true);
```

The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) index lists API design skills that validate consistency across endpoints.

For more API patterns, see [The Claude Code Playbook](/playbook/). For type-safe API contracts, read the [type system guide](/claude-code-ignores-type-system-fix-2026/). For testing API consistency, see our [best practices guide](/karpathy-skills-vs-claude-code-best-practices-2026/).

## See Also

- [Fix Claude Code Inconsistent Code Style (2026)](/claude-code-inconsistent-style-fix-2026/)
