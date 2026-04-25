---

layout: default
title: "Claude.md for API Design Standards (2026)"
description: "Learn how to use Claude.md and Claude Code to create, maintain, and enforce consistent API design standards across your projects."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-for-api-design-standards-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
---

API design standards ensure consistency across your codebase, improve developer experience, and reduce friction when multiple teams work together. Without standards, every service invents its own conventions: some use snake_case fields, others use camelCase; some put the API version in the URL, others use headers; error shapes vary from endpoint to endpoint. The result is an ecosystem that feels cobbled together rather than designed.

Using Claude.md alongside Claude Code provides a powerful workflow for creating, documenting, and enforcing these standards automatically. This guide shows you how to integrate API design guidance into your development workflow using Claude's capabilities, from the initial standards document through to automated compliance checking in CI.

## What Claude.md Is and Why It Matters

Claude.md (also written as CLAUDE.md) is a Markdown file that Claude Code reads automatically when you start a session in a directory. It provides persistent context that shapes every interaction without requiring you to repeat yourself in each prompt.

For API design standards, this is particularly valuable. Instead of saying "use kebab-case endpoints and include a meta timestamp in every response" in every conversation, you write it once in CLAUDE.md and Claude applies it consistently. The file becomes a shared contract between your team and your AI tooling.

The key properties of a good API standards CLAUDE.md:

- Concrete, not abstract. "Use plural nouns for collections" is actionable. "Design good endpoints" is not.
- Example-driven. Show both correct and incorrect forms. Claude uses these examples as patterns.
- Comprehensive but not exhaustive. Cover the decisions that actually vary across developers. Skip the obvious.
- Version-aware. Note which standards apply to v1 vs. v2 if your API is versioned.

## Setting Up Your API Standards Reference

The foundation of using Claude for API design is creating a comprehensive reference document. Place a `CLAUDE.md` file in your project root that outlines your organization's API conventions. This file becomes part of Claude's context for every interaction, ensuring consistent guidance across all development tasks.

A production-quality API standards document covers naming, versioning, response format, error handling, pagination, authentication, and deprecation. Here is a template that covers the essentials:

```markdown
API Design Standards

Naming Conventions
- Endpoints use lowercase kebab-case: /user-profiles, /order-items
- Collections use plural nouns: /users, /orders, /products
- JSON fields use camelCase: userId, createdAt, orderItems
- Boolean fields use is/has prefix: isActive, hasChildren
- Timestamps use ISO 8601 format: "2026-03-14T10:30:00Z"

URL Structure
- Version prefix on all routes: /api/v1/resource
- Nested resources for ownership: /users/{userId}/orders
- Actions as sub-resources when needed: /orders/{id}/cancel
- Query params for filtering, not path segments: /orders?status=active

Response Format
All endpoints return this envelope:
{
 "data": {},
 "meta": {
 "timestamp": "ISO8601",
 "requestId": "uuid"
 },
 "errors": []
}

Error Format
{
 "data": null,
 "meta": { "timestamp": "ISO8601", "requestId": "uuid" },
 "errors": [
 {
 "code": "VALIDATION_FAILED",
 "message": "Human-readable description",
 "field": "email"
 }
 ]
}

HTTP Status Codes
- 200: Successful GET, PUT, PATCH
- 201: Successful POST (resource created)
- 204: Successful DELETE (no body)
- 400: Client error, validation failure
- 401: Authentication required
- 403: Authenticated but not authorized
- 404: Resource not found
- 409: Conflict (duplicate, version mismatch)
- 422: Unprocessable entity (valid JSON, invalid semantics)
- 500: Internal server error

Pagination
- Use cursor-based pagination for large collections
- Return nextCursor in meta when more pages exist
- Default page size: 20, maximum: 100

Deprecation
- Add Sunset header with ISO 8601 date
- Add Deprecation: true header
- Document in changelog with migration path
- Minimum 6-month deprecation window
```

When Claude Code reads this file, every code generation task, creating route handlers, writing OpenAPI specs, generating response objects, automatically follows these conventions.

## Enforcing Standards Through Conversation

With your CLAUDE.md in place, you can reference standards naturally in prompts. Instead of manually checking every endpoint design, ask Claude to generate code that follows your documented conventions:

```
"Generate a new endpoint for user authentication following our API standards in CLAUDE.md"
```

Claude will apply your documented conventions automatically. For more targeted guidance, reference specific sections:

```
"Create a REST endpoint for resetting passwords. Use the error handling patterns
from our standards. the response must follow our error envelope format with a
VALIDATION_FAILED code for missing fields."
```

The difference between vague prompts and standard-aware prompts is significant. Compare these two generated responses:

Without standards context:
```python
@app.post("/reset-password")
def reset_password(email: str):
 # generate token...
 return {"success": True, "message": "Email sent"}
```

With standards context from CLAUDE.md:
```python
@app.post("/api/v1/password-resets")
def create_password_reset(body: PasswordResetRequest, request: Request):
 try:
 token = password_service.create_reset_token(body.email)
 return JSONResponse(
 status_code=201,
 content={
 "data": {"resetTokenExpiry": token.expires_at.isoformat()},
 "meta": {
 "timestamp": datetime.utcnow().isoformat() + "Z",
 "requestId": str(request.state.request_id)
 },
 "errors": []
 }
 )
 except UserNotFoundError:
 return JSONResponse(
 status_code=404,
 content={
 "data": None,
 "meta": {"timestamp": "...", "requestId": "..."},
 "errors": [{"code": "USER_NOT_FOUND",
 "message": "No account found for that email address"}]
 }
 )
```

The second version follows your envelope format, uses the correct HTTP method and URL convention, and handles errors with the proper error code structure. This approach works smoothly with other Claude skills too. When you need to generate documentation alongside your API, combine your standards reference with the docx skill for specification documents, or use the pdf skill to export comprehensive API guides.

## Automating Standards Validation

Beyond generation, use Claude to audit existing code against your standards. This is especially powerful when inheriting a codebase or onboarding endpoints from another team:

```bash
claude "Review these endpoint definitions for compliance with our API standards in CLAUDE.md.
List each violation with the specific standard it breaks and the suggested fix.

GET /User/getById?id=123
POST /orders/create
DELETE /products/{productId}/delete
Response fields: user_id, created_at, isDeleted"
```

Claude will identify deviations systematically:

- `/User/getById`. should be `/api/v1/users/{id}` (kebab-case, plural noun, version prefix, no verb in path)
- `/orders/create`. should be `POST /api/v1/orders` (no verb suffix; POST implies creation)
- `/products/{productId}/delete`. should be `DELETE /api/v1/products/{productId}` (no verb suffix; DELETE method implies deletion)
- `user_id`. should be `userId` (camelCase fields)
- `created_at`. should be `createdAt` (camelCase fields)

This audit capability is valuable during code review. You can paste a diff into Claude and ask specifically whether the new endpoints comply with your standards before merging.

## Integrating with Testing Workflows

API design standards gain real teeth when enforced through automated testing. Combine your Claude.md standards with the tdd skill to create comprehensive test suites that validate conformance at the contract level, not just the behavior level:

```python
import pytest
import re
from api_client import APIClient

class TestAPIStandardsCompliance:
 """Validate API against organization standards documented in CLAUDE.md."""

 def test_all_endpoints_have_version_prefix(self):
 """All endpoints must be prefixed with /api/v{n}/."""
 routes = APIClient.discover_routes()
 pattern = re.compile(r'^/api/v\d+/')
 for route in routes:
 assert pattern.match(route.path), (
 f"Route {route.path} missing version prefix"
 )

 def test_collection_endpoints_use_plural_nouns(self):
 """GET / endpoints must use plural resource names."""
 collection_routes = [r for r in APIClient.discover_routes()
 if r.method == "GET" and "{" not in r.path]
 singular_words = {"user", "order", "product", "customer"}
 for route in collection_routes:
 last_segment = route.path.rstrip("/").split("/")[-1]
 assert last_segment not in singular_words, (
 f"Collection endpoint {route.path} uses singular noun"
 )

 def test_responses_include_required_envelope(self):
 """All 200 responses must include data, meta, and errors fields."""
 response = APIClient.get("/api/v1/users")
 assert response.status_code == 200
 body = response.json()
 assert "data" in body, "Response missing 'data' field"
 assert "meta" in body, "Response missing 'meta' field"
 assert "errors" in body, "Response missing 'errors' field"

 def test_meta_includes_timestamp_and_request_id(self):
 """Meta object must include ISO 8601 timestamp and requestId."""
 response = APIClient.get("/api/v1/users/1")
 meta = response.json()["meta"]
 assert "timestamp" in meta
 assert "requestId" in meta
 from datetime import datetime
 datetime.fromisoformat(meta["timestamp"].replace("Z", "+00:00"))

 def test_error_responses_use_correct_format(self):
 """Error responses must use the standard error envelope."""
 response = APIClient.get("/api/v1/users/nonexistent-id-99999")
 assert response.status_code == 404
 body = response.json()
 assert body["data"] is None
 assert len(body["errors"]) > 0
 error = body["errors"][0]
 assert "code" in error
 assert "message" in error
 assert error["code"] == error["code"].upper(), \
 "Error codes must be UPPER_SNAKE_CASE"

 def test_delete_returns_204_no_body(self):
 """DELETE endpoints must return 204 with no response body."""
 created = APIClient.post("/api/v1/test-resources", json={"name": "temp"})
 resource_id = created.json()["data"]["id"]
 response = APIClient.delete(f"/api/v1/test-resources/{resource_id}")
 assert response.status_code == 204
 assert response.text == "", "DELETE response must have empty body"
```

Run these tests after any Claude Code session that generates or modifies endpoints. The tdd skill helps you structure comprehensive test coverage that catches standard violations early. ideally in CI before a PR is merged.

## Handling Multiple Services with Shared Standards

In a microservices architecture, you want standards to be consistent across all services. Structure your CLAUDE.md files to inherit from a shared base:

```
/
 CLAUDE.md # Shared standards for all services
 services/
 user-service/
 CLAUDE.md # Extends shared + user-service specifics
 order-service/
 CLAUDE.md # Extends shared + order-service specifics
 product-service/
 CLAUDE.md
```

The service-level CLAUDE.md files reference the root standards and add service-specific conventions:

```markdown
User Service API Standards

This service follows all standards in the root CLAUDE.md plus these additions:

User Resource Fields
- id: UUID v4 string
- email: lowercase, validated RFC 5322
- role: enum. "admin" | "member" | "viewer"
- status: enum. "active" | "suspended" | "pending_verification"

Authentication Endpoints
- Password endpoints use /password-resets (not /passwords)
- Token endpoints live under /auth/, not /users/
- MFA endpoints: /auth/mfa/setup, /auth/mfa/verify
```

When working in the user-service directory, Claude reads the service-level CLAUDE.md and uses it in combination with the root standards.

## Standards Evolution and Documentation

API standards evolve as platforms mature. Common inflection points: migrating from REST to GraphQL for some endpoints, adopting cursor pagination after offset pagination breaks at scale, or standardizing on OpenAPI 3.1 after years of informal specs.

Your CLAUDE.md should be a living document. When introducing new standards, update the file and ask Claude to audit existing endpoints:

```
"Our standards now require OpenAPI 3.1 documentation for all endpoints,
with response schemas defined inline. Review the user-service endpoints
in src/routes/ and list which ones are missing OpenAPI annotations and
what the annotations should look like based on our response format standard."
```

For tracking changes to standards over time, keep your CLAUDE.md in version control and treat changes to it like changes to any other architectural document. they deserve a pull request, a brief justification, and a note in your changelog.

When a standard changes in a backwards-incompatible way, document the migration in CLAUDE.md itself:

```markdown
Deprecation Notice: offset pagination (deprecated 2026-01-01, sunset 2026-07-01)

The `page` and `per_page` query parameters are deprecated.
Migrate to cursor-based pagination using `cursor` and `limit` parameters.
The `nextCursor` field in meta.pagination replaces `totalPages`.
```

For larger documentation efforts, use the frontend-design skill to create visual API documentation portals, or generate markdown documentation that team members can reference directly from their editors.

## Practical Example: Complete Endpoint Design

Here is how a complete workflow looks when designing a new API feature with Claude and your standards:

Initial Request:
```
"Create endpoints for a task management feature with CRUD operations,
following our API standards in CLAUDE.md."
```

Claude Response (following your standards):
```yaml
Generated endpoints. compliant with API standards

POST /api/v1/task-groups # Create task group (returns 201)
GET /api/v1/task-groups # List task groups (cursor paginated)
GET /api/v1/task-groups/{id} # Get single group
PATCH /api/v1/task-groups/{id} # Update group (partial update)
DELETE /api/v1/task-groups/{id} # Delete group (returns 204)

POST /api/v1/tasks # Create task (returns 201)
GET /api/v1/tasks # List tasks (?status=open&cursor=...)
GET /api/v1/tasks/{id} # Get task details
PATCH /api/v1/tasks/{id} # Update task
DELETE /api/v1/tasks/{id} # Delete task (returns 204)

POST /api/v1/tasks/{id}/completions # Mark task complete (action sub-resource)
DELETE /api/v1/tasks/{id}/completions # Reopen task
```

All endpoints follow the kebab-case convention, use plural nouns, include the version prefix, and use sub-resources for actions rather than verbs in the path. The response for each endpoint automatically uses the envelope format from the standards document.

Claude will also generate the corresponding response schemas and error codes if you ask:

```
"Generate the response schema for GET /api/v1/tasks following our response
envelope format, including the pagination cursor fields in meta."
```

## Best Practices for API Standards Documents

Keep your CLAUDE.md focused and actionable. Concrete examples outperform abstract principles every time. When naming conventions have edge cases, document the decision tree explicitly:

```markdown
URL Pattern Decision Tree

1. Is the resource a noun? -> /users, /order-items
2. Is this an action on a resource? -> /users/{id}/activate (POST)
3. Are you relating two resources? -> /users/{id}/orders/{orderId}
4. Is this a search across resources? -> /search?q=...&type=users
5. Is this an async operation? -> /exports (POST to create), /exports/{id} (GET to poll)
```

A comparison table helps when teams debate conventions:

| Pattern | Compliant | Reason |
|---------|-----------|--------|
| GET /api/v1/users | Yes | Plural noun, versioned |
| GET /api/v1/user | No | Singular noun for collection |
| POST /api/v1/users/create | No | Verb in path |
| GET /api/v1/Users | No | PascalCase in URL |
| DELETE /api/v1/users/delete/123 | No | Verb and wrong ID placement |
| DELETE /api/v1/users/123 | Yes | Correct method and path |

Review and update your standards at least quarterly. Remove patterns that have been superseded and add conventions for new capabilities. Since Claude reads the file fresh each session, every update is immediately reflected in future code generation tasks.

## Conclusion

Using Claude.md for API design standards transforms how teams maintain consistency. Your standards document becomes an active participant in development, guiding every code generation session rather than sitting in a wiki that developers forget to consult.

The workflow compounds in value over time. Early sessions with a thin CLAUDE.md produce mostly compliant endpoints. As you refine the document based on edge cases and team feedback, the quality of generated code improves. After a few months, your CLAUDE.md is a battle-tested specification that reflects hard-won institutional knowledge about what works for your platform.

Start with the essentials: naming conventions, response envelope format, and HTTP status code usage. Those three sections alone eliminate the most common inconsistencies. Add error format standardization, pagination conventions, and versioning strategy as you encounter the problems they solve. Over time, your CLAUDE.md becomes the single source of truth that keeps your entire API ecosystem coherent and maintainable.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-for-api-design-standards-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code API Error Handling Standards](/claude-code-api-error-handling-standards/)
- [Claude Code Event Driven API Design Guide](/claude-code-event-driven-api-design-guide/)
- [Claude Code REST API Design Best Practices](/claude-code-rest-api-design-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Fix Claude Code Inconsistent API Design (2026)](/claude-code-inconsistent-api-design-fix-2026/)
- [CLAUDE.md for API Design — Consistent Endpoints, Responses, and Versioning (2026)](/claude-md-api-design-patterns/)
