---

layout: default
title: "REST API Design with Claude Code (2026)"
description: "Design REST APIs with Claude Code for endpoint naming, error handling, versioning, and OpenAPI documentation. Production-ready patterns and examples."
date: 2026-04-19
last_modified_at: 2026-04-19
last_tested: "2026-04-21"
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, rest-api, api-design, best-practices, development, claude-skills]
permalink: /claude-code-rest-api-design-best-practices/
reviewed: true
score: 7
geo_optimized: true
---

Revised April 2026. With API specification tooling updates and OpenAPI 3.1 adoption, some rest api design workflows have changed. This guide reflects the updated Claude Code behavior for rest api design.

Building REST APIs that work well with Claude Code requires understanding both traditional API design principles and how Claude skills interpret and interact with your endpoints. This guide provides actionable patterns you can implement immediately.

## Resource-Oriented URL Structure

Design your URLs around resources rather than actions. Use nouns for resources and HTTP methods for actions.

```
Good design
GET /api/v1/users
POST /api/v1/users
GET /api/v1/users/{id}
PUT /api/v1/users/{id}
DELETE /api/v1/users/{id}

Avoid action-based URLs
GET /api/v1/getUsers
POST /api/v1/createUser
POST /api/v1/deleteUserById
```

When Claude Code generates client code or tests, resource-oriented URLs map naturally to cleaner function names. The `superMemory` skill benefits from predictable URL patterns when storing and retrieving API interaction history.

Nested resources follow the same convention. When representing relationships between resources, keep nesting shallow. ideally no more than two levels deep:

```
Good. one level of nesting
GET /api/v1/users/{id}/orders
GET /api/v1/users/{id}/orders/{order_id}

Avoid deep nesting. hard to read and maintain
GET /api/v1/users/{id}/orders/{order_id}/items/{item_id}/reviews
```

When you need to go deeper, consider whether a top-level endpoint with query parameters is cleaner. For example, `GET /api/v1/reviews?item_id=42` is often more ergonomic than a five-level nested path.

Here is a quick reference comparing resource-oriented versus action-oriented URLs:

| Action | Bad (verb URL) | Good (resource URL) |
|---|---|---|
| Get all users | GET /getUsers | GET /api/v1/users |
| Create a user | POST /createUser | POST /api/v1/users |
| Update a user | POST /updateUser/123 | PUT /api/v1/users/123 |
| Delete a user | POST /deleteUserById | DELETE /api/v1/users/123 |
| Get user orders | GET /getUserOrders/123 | GET /api/v1/users/123/orders |

## Consistent Response Envelopes

Wrap all responses in a consistent structure. This helps Claude skills parse responses reliably.

```json
{
 "data": { },
 "meta": {
 "timestamp": "2026-03-14T10:30:00Z",
 "version": "1.0"
 },
 "pagination": {
 "page": 1,
 "per_page": 20,
 "total": 150
 }
}
```

Error responses should follow the same envelope pattern:

```json
{
 "error": {
 "code": "VALIDATION_ERROR",
 "message": "Email format is invalid",
 "details": [
 { "field": "email", "issue": "missing @ symbol" }
 ]
 },
 "meta": {
 "timestamp": "2026-03-14T10:30:00Z"
 }
}
```

The `tdd` skill generates test cases more accurately when response structures follow predictable patterns across your entire API.

A consistent envelope provides three concrete benefits. First, client code can handle errors uniformly without special-casing each endpoint. Second, logging and monitoring tools can parse every response with the same logic. Third, Claude Code can generate typed interfaces from your schema once and apply them everywhere. If your `/users` endpoint returns `{ "data": {...} }` but your `/orders` endpoint returns a bare object, every consumer needs separate handling.

## Semantic HTTP Status Codes

Use status codes correctly to communicate outcomes:

- `200 OK`. Successful GET, PUT, or PATCH
- `201 Created`. Successful POST that creates a resource
- `204 No Content`. Successful DELETE with no response body
- `400 Bad Request`. Client sent invalid data
- `401 Unauthorized`. Missing or invalid authentication
- `403 Forbidden`. Authenticated but not authorized
- `404 Not Found`. Resource doesn't exist
- `409 Conflict`. Request conflicts with current state (e.g., duplicate creation)
- `422 Unprocessable Entity`. Request is syntactically valid but semantically wrong
- `429 Too Many Requests`. Rate limit exceeded
- `500 Internal Server Error`. Server-side failure

Avoid returning `200 OK` for error conditions. Claude skills making automated decisions rely on status codes to determine next steps.

One common mistake is returning `200` with a body like `{ "success": false, "error": "not found" }`. This forces every consumer to inspect the body before knowing whether the request succeeded. HTTP status codes exist precisely to convey this information at the transport layer, before any body parsing happens.

The distinction between `401` and `403` matters more than most developers realize. `401` means the request lacks valid credentials. the client should authenticate and retry. `403` means credentials are valid but the user does not have permission. retrying with the same credentials will not help. Conflating these causes confusing user-facing error messages and makes debugging access control problems harder.

## Versioning Strategy

Choose a versioning approach early. URL versioning provides clarity:

```
/api/v1/users
/api/v2/users
```

Add deprecation headers to responses from older versions:

```http
Deprecation: true
Sunset: Sat, 01 Aug 2026 00:00:00 GMT
Link: <https://api.example.com/v2/users>; rel="latest-version"
```

The `pdf` skill can generate version migration guides when your API evolves, but only if you maintain clean version transitions.

The three main versioning approaches each have tradeoffs:

| Strategy | Example | Pros | Cons |
|---|---|---|---|
| URL segment | /api/v2/users | Explicit, easy to route, visible in logs | Breaks REST resource identity |
| Header | Accept: application/vnd.api.v2+json | Cleaner URLs | Hidden from logs, harder to test in browser |
| Query param | /api/users?version=2 | Easy to add | Often ignored by CDN caches |

URL versioning wins for most teams because it is explicit, cacheable, and requires no special client configuration. Header versioning is useful when you are making minor variations to representation formats rather than breaking structural changes.

Plan your deprecation timeline before you publish a new major version. Announce the sunset date at least six months in advance, enforce it consistently through headers, and provide a migration guide. Claude Code can help draft migration guides by comparing your v1 and v2 OpenAPI specs and documenting each changed endpoint.

## Pagination Implementation

Never return unbounded collections. Implement cursor-based or offset pagination:

```json
{
 "data": [...],
 "pagination": {
 "cursor": "eyJpZCI6MTAwfQ==",
 "has_more": true
 }
}
```

Cursor pagination performs better at scale and avoids offset-based skipping issues. The `frontend-design` skill can generate pagination components when your API contract is consistent.

Offset pagination has an intuitive problem: if ten records are inserted while a client is paging through results, `OFFSET 20 LIMIT 10` will skip or repeat records. Cursor pagination avoids this by anchoring to a specific record ID or timestamp.

Here is how to implement cursor pagination in a typical query:

```python
Decode cursor (base64-encoded JSON)
import base64, json

def decode_cursor(cursor_str):
 return json.loads(base64.b64decode(cursor_str))

def encode_cursor(data):
 return base64.b64encode(json.dumps(data).encode()).decode()

Query with cursor
def get_users(cursor=None, limit=20):
 query = User.query.order_by(User.id)
 if cursor:
 cursor_data = decode_cursor(cursor)
 query = query.filter(User.id > cursor_data["id"])
 users = query.limit(limit + 1).all()
 has_more = len(users) > limit
 users = users[:limit]
 next_cursor = encode_cursor({"id": users[-1].id}) if has_more else None
 return users, next_cursor
```

For APIs that need to expose a total record count (e.g., "Showing 1-20 of 4,382 results"), add `total` to the pagination envelope. but fetch it separately with a COUNT query to avoid joining it to every paginated result.

## Field Selection with Sparse Fieldsets

Allow clients to request specific fields:

```
GET /api/v1/users?fields=id,name,email
GET /api/v1/users?fields=id,avatar_url
```

This reduces payload size for mobile clients and helps Claude skills process only relevant data. Implement this with a simple query parameter that filters your response object.

Sparse fieldsets are especially valuable for list endpoints. A user list might return 40 fields per record by default, but a mobile app rendering a contacts list only needs `id`, `name`, and `avatar_url`. Without field selection, you are transferring and serializing data nobody will use.

Implementation in Python using a simple filter:

```python
def filter_fields(data, fields_param):
 if not fields_param:
 return data
 requested = set(fields_param.split(","))
 if isinstance(data, list):
 return [{k: v for k, v in item.items() if k in requested} for item in data]
 return {k: v for k, v in data.items() if k in requested}

In your route handler
fields = request.args.get("fields")
response_data = filter_fields(user.to_dict(), fields)
```

Sparse fieldsets also pair well with OpenAPI documentation. Define a `fields` query parameter in your spec and list the available field names in its description. This lets Claude Code generate type-safe field selection in client SDKs.

## Idempotency for POST Endpoints

POST operations that create resources should support idempotency keys:

```http
POST /api/v1/orders
Idempotency-Key: unique-request-123

{
 "product_id": "prod_abc",
 "quantity": 2
}
```

Store idempotency keys with a TTL (typically 24-72 hours). Return the original response on duplicate requests. This pattern prevents duplicate orders when Claude skills retry requests after network timeouts.

The implementation pattern is straightforward:

```python
import redis
import json

r = redis.Redis()

def handle_order_creation(idempotency_key, order_data):
 # Check if we've seen this key before
 cached = r.get(f"idempotency:{idempotency_key}")
 if cached:
 return json.loads(cached), 200 # Return original response

 # Process new order
 order = create_order(order_data)
 response = {"id": order.id, "status": "pending"}

 # Cache with 48-hour TTL
 r.setex(
 f"idempotency:{idempotency_key}",
 172800, # 48 hours in seconds
 json.dumps(response)
 )
 return response, 201
```

When the stored response is returned for a duplicate request, return the original HTTP status code as well. not always `200`. A duplicate of a request that originally returned `201 Created` should also return `201`.

## Webhook Design

If your API sends webhooks, include sufficient context:

```json
{
 "event": "order.created",
 "timestamp": "2026-03-14T10:30:00Z",
 "data": {
 "id": "order_123",
 "status": "pending"
 },
 "webhook": {
 "id": "wh_abc123",
 "delivery_url": "https://client.example.com/webhooks"
 }
}
```

Always include the event type, timestamp, and a unique webhook identifier. The `supermemory` skill can track webhook patterns across integrations to help debug event flow issues.

Webhook consumers need to verify that events came from your server. Use HMAC signatures:

```python
import hmac, hashlib

def sign_payload(payload: bytes, secret: str) -> str:
 return hmac.new(
 secret.encode(),
 payload,
 hashlib.sha256
 ).hexdigest()

Include in webhook headers
headers = {
 "X-Webhook-Signature": f"sha256={sign_payload(payload_bytes, webhook_secret)}"
}
```

Consumers validate by computing the same signature and comparing with `hmac.compare_digest`. a constant-time comparison that prevents timing attacks. Document this verification process in your API reference so integrators know how to implement it.

## Rate Limiting Documentation

Document and enforce rate limits with standard headers:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1710412800
Retry-After: 60
```

Return `429 Too Many Requests` with a `Retry-After` header when limits are exceeded. Claude skills can then implement exponential backoff correctly.

Design rate limits at multiple granularities:

| Limit Type | Example | Purpose |
|---|---|---|
| Per-second burst | 20 req/s | Prevent DDoS and runaway clients |
| Per-minute sustained | 300 req/min | Smooth sustained load |
| Per-day quota | 10,000 req/day | Enforce plan-based billing |
| Per-endpoint | 5 req/min for /auth/login | Protect sensitive endpoints |

Claude Code can generate backoff utility functions when your API documentation includes clear rate limit headers. A well-documented rate limit contract means that any API client. whether written by a human or generated by Claude. can implement respectful, self-throttling request patterns automatically.

## OpenAPI Documentation

Maintain an OpenAPI specification that Claude skills can consume. Include:

- Clear parameter descriptions with examples
- Schema definitions for all request/response bodies
- Security scheme definitions
- Operation IDs for code generation

```yaml
paths:
 /users/{id}:
 get:
 operationId: getUser
 summary: Get a user by ID
 parameters:
 - name: id
 in: path
 required: true
 schema:
 type: string
 example: "usr_123"
 responses:
 '200':
 description: User found
 content:
 application/json:
 schema:
 $ref: '#/components/schemas/User'
 '404':
 description: User not found
 content:
 application/json:
 schema:
 $ref: '#/components/schemas/ErrorResponse'
```

The `claude-code-api-documentation-best-practices` skill can generate OpenAPI specs from your existing codebase or help validate your documentation.

A few OpenAPI practices that pay dividends:

1. Always define `operationId`. code generators use this for function names. Without it, they generate names like `get_api_v1_users_id_get`, which is unreadable.
2. Document every possible response status. not just the happy path. Clients need to know what `400`, `401`, and `500` responses look like.
3. Use `$ref` for shared schemas. define `User`, `Order`, and `ErrorResponse` once under `components/schemas` and reference them everywhere. This keeps your spec DRY and ensures consistency.
4. Include realistic examples. use actual-looking IDs (`usr_4f8a2b`) rather than placeholder strings (`string`). Examples drive better mock data generation.

## Authentication Patterns

Authentication deserves its own section because getting it wrong affects every endpoint. The two dominant patterns are API keys and OAuth 2.0 bearer tokens.

For server-to-server integrations, API keys are simpler:

```http
Authorization: Bearer sk_live_abc123xyz
```

For user-facing applications, OAuth 2.0 with short-lived access tokens and refresh tokens is the right choice:

```http
Access token request
POST /api/v1/auth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=rt_xyz789
```

Document your authentication scheme in OpenAPI under `components/securitySchemes` and apply it globally or per-operation:

```yaml
components:
 securitySchemes:
 BearerAuth:
 type: http
 scheme: bearer
 bearerFormat: JWT

security:
 - BearerAuth: []
```

When Claude Code generates client SDKs from your spec, it will automatically include the authentication header configuration if you define the security scheme correctly.

## Testing Your API with Claude Skills

Use the `tdd` skill to generate comprehensive API tests:

```bash
Load the tdd skill and generate tests for your endpoints
claude --print "Generate integration tests for /api/v1/users endpoints covering CRUD operations, validation, and error cases"
```

The `claude-code-api-mocking-development-guide` skill helps create mock servers for testing without depending on production endpoints.

A complete test strategy for REST APIs covers four layers:

1. Unit tests for serialization, validation, and business logic
2. Integration tests for each endpoint, including error conditions
3. Contract tests that verify your implementation matches the OpenAPI spec
4. Load tests that confirm rate limiting and pagination work under stress

For contract testing, tools like Schemathesis can automatically generate test cases from your OpenAPI specification and run them against a live server:

```bash
schemathesis run --checks all http://localhost:8000/openapi.json
```

This catches cases where your implementation drifts from your documentation. a common source of subtle bugs that only appear in production.

## Summary

Applying these REST API design patterns creates interfaces that Claude Code can interact with reliably. Focus on consistency in response structures, proper HTTP semantics, and comprehensive documentation. When Claude skills can predict your API behavior, they generate better code, tests, and integrations.

The single most impactful change you can make is adopting a consistent response envelope. Everything else. versioning, pagination, field selection. builds on top of that foundation. Start there, document it in OpenAPI, and layer in the remaining patterns as your API grows.

---

---



---

*Last verified: April 2026. If this approach no longer works, check [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/) for updated steps.*

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-rest-api-design-best-practices)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code API Documentation OpenAPI Guide](/claude-code-api-documentation-best-practices/). OpenAPI documents REST API designs
- [How to Make Claude Code Generate Consistent API Responses](/how-to-make-claude-code-generate-consistent-api-responses/). Consistent responses are a REST best practice
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/). Contract tests validate REST API design
- [Claude Code API Backward Compatibility Guide](/claude-code-api-backward-compatibility-guide/). REST API versioning and backward compatibility

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Claude Code Inconsistent API Design (2026)](/claude-code-inconsistent-api-design-fix-2026/)
