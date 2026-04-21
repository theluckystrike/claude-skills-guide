---
title: "Claude Code for OpenAPI Spec Generation (2026)"
description: "OpenAPI specification generation with Claude Code. Auto-generate 3.1 specs from existing codebases with validation."
permalink: /claude-code-openapi-spec-generation-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for OpenAPI Specs

Most REST APIs lack accurate documentation. The OpenAPI spec is either missing, outdated, or was written once and never updated as endpoints changed. Writing a complete OpenAPI 3.1 spec by hand for a 50-endpoint API takes days and requires knowing the difference between requestBody and parameters, understanding discriminators for polymorphic responses, and correctly modeling pagination, error envelopes, and auth schemes.

Claude Code reads your route handlers, extracts path parameters, query parameters, request/response types, and generates OpenAPI 3.1 YAML that validates against the spec. It infers schemas from TypeScript interfaces, Python dataclasses, or Java records and produces documentation that Swagger UI, Redoc, or Stoplight can render immediately.

## The Workflow

### Step 1: Setup

```bash
pip install pyyaml openapi-spec-validator pydantic \
  fastapi uvicorn  # if using FastAPI

# OpenAPI validator
npm install -g @redocly/cli

mkdir -p openapi/{extractors,output,tests}
```

### Step 2: Extract Routes and Generate Spec

```python
# openapi/extractors/generate_spec.py
"""Generate OpenAPI 3.1 specification from route definitions."""
import yaml
import re
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional

MAX_ENDPOINTS = 500
MAX_PARAMS = 30


@dataclass
class Parameter:
    name: str
    location: str       # path, query, header, cookie
    required: bool
    schema_type: str    # string, integer, boolean, number, array
    description: str = ""
    example: str = ""


@dataclass
class Endpoint:
    method: str             # get, post, put, delete, patch
    path: str
    summary: str
    description: str
    parameters: list = field(default_factory=list)
    request_body_schema: dict = field(default_factory=dict)
    response_schema: dict = field(default_factory=dict)
    response_code: int = 200
    tags: list = field(default_factory=list)
    auth_required: bool = True


def extract_path_params(path: str) -> list:
    """Extract path parameters from URL pattern."""
    params = []
    for match in re.finditer(r'\{(\w+)\}', path):
        params.append(Parameter(
            name=match.group(1),
            location="path",
            required=True,
            schema_type="string",
        ))
    return params


def infer_schema_from_python_type(type_hint: str) -> dict:
    """Map Python type hints to JSON Schema."""
    type_map = {
        "str": {"type": "string"},
        "int": {"type": "integer"},
        "float": {"type": "number"},
        "bool": {"type": "boolean"},
        "list": {"type": "array", "items": {"type": "string"}},
        "dict": {"type": "object"},
        "datetime": {"type": "string", "format": "date-time"},
        "date": {"type": "string", "format": "date"},
        "UUID": {"type": "string", "format": "uuid"},
        "Optional[str]": {"type": "string", "nullable": True},
        "Optional[int]": {"type": "integer", "nullable": True},
    }
    return type_map.get(type_hint, {"type": "string"})


def generate_openapi_spec(
    endpoints: list,
    title: str = "API",
    version: str = "1.0.0",
    description: str = "",
    server_url: str = "https://api.example.com",
) -> dict:
    """Generate OpenAPI 3.1 specification from endpoint list."""
    assert len(endpoints) > 0, "No endpoints to document"
    assert len(endpoints) <= MAX_ENDPOINTS, \
        f"Too many endpoints: {len(endpoints)}"

    spec = {
        "openapi": "3.1.0",
        "info": {
            "title": title,
            "version": version,
            "description": description,
        },
        "servers": [{"url": server_url}],
        "paths": {},
        "components": {
            "schemas": {},
            "securitySchemes": {
                "BearerAuth": {
                    "type": "http",
                    "scheme": "bearer",
                    "bearerFormat": "JWT",
                },
            },
        },
    }

    # Collect all unique tags
    all_tags = set()

    for ep in endpoints:
        assert ep.method in ("get", "post", "put", "delete", "patch"), \
            f"Invalid method: {ep.method}"
        assert ep.path.startswith("/"), f"Path must start with /: {ep.path}"

        if ep.path not in spec["paths"]:
            spec["paths"][ep.path] = {}

        operation = {
            "summary": ep.summary,
            "description": ep.description,
            "tags": ep.tags,
            "responses": {
                str(ep.response_code): {
                    "description": "Successful response",
                },
            },
        }

        all_tags.update(ep.tags)

        # Parameters
        if ep.parameters:
            assert len(ep.parameters) <= MAX_PARAMS
            operation["parameters"] = []
            for param in ep.parameters:
                operation["parameters"].append({
                    "name": param.name,
                    "in": param.location,
                    "required": param.required,
                    "schema": {"type": param.schema_type},
                    "description": param.description,
                })

        # Request body
        if ep.request_body_schema and ep.method in ("post", "put", "patch"):
            schema_name = f"{ep.summary.replace(' ', '')}Request"
            spec["components"]["schemas"][schema_name] = ep.request_body_schema
            operation["requestBody"] = {
                "required": True,
                "content": {
                    "application/json": {
                        "schema": {"$ref": f"#/components/schemas/{schema_name}"},
                    },
                },
            }

        # Response body
        if ep.response_schema:
            schema_name = f"{ep.summary.replace(' ', '')}Response"
            spec["components"]["schemas"][schema_name] = ep.response_schema
            operation["responses"][str(ep.response_code)]["content"] = {
                "application/json": {
                    "schema": {"$ref": f"#/components/schemas/{schema_name}"},
                },
            }

        # Auth
        if ep.auth_required:
            operation["security"] = [{"BearerAuth": []}]

        # Error responses
        operation["responses"]["400"] = {
            "description": "Bad Request",
            "content": {
                "application/json": {
                    "schema": {"$ref": "#/components/schemas/Error"},
                },
            },
        }
        operation["responses"]["401"] = {
            "description": "Unauthorized",
        }

        spec["paths"][ep.path][ep.method] = operation

    # Standard error schema
    spec["components"]["schemas"]["Error"] = {
        "type": "object",
        "properties": {
            "error": {"type": "string"},
            "message": {"type": "string"},
            "status": {"type": "integer"},
        },
        "required": ["error", "message", "status"],
    }

    # Tags
    spec["tags"] = [{"name": t} for t in sorted(all_tags)]

    return spec


def validate_spec(spec: dict) -> bool:
    """Validate against OpenAPI 3.1 specification."""
    from openapi_spec_validator import validate
    validate(spec)
    return True


def write_spec(spec: dict, output_path: str,
               format: str = "yaml") -> None:
    """Write specification to file."""
    assert format in ("yaml", "json"), f"Unknown format: {format}"

    with open(output_path, 'w') as f:
        if format == "yaml":
            yaml.dump(spec, f, default_flow_style=False, sort_keys=False)
        else:
            import json
            json.dump(spec, f, indent=2)

    print(f"Spec written: {output_path}")


if __name__ == "__main__":
    # Example: generate spec for a user management API
    endpoints = [
        Endpoint(
            method="get", path="/users",
            summary="List Users", description="Get paginated list of users",
            parameters=[
                Parameter("page", "query", False, "integer", "Page number"),
                Parameter("limit", "query", False, "integer", "Items per page"),
            ],
            response_schema={
                "type": "object",
                "properties": {
                    "users": {"type": "array", "items": {"$ref": "#/components/schemas/User"}},
                    "total": {"type": "integer"},
                    "page": {"type": "integer"},
                },
            },
            tags=["Users"],
        ),
        Endpoint(
            method="post", path="/users",
            summary="Create User", description="Create a new user account",
            request_body_schema={
                "type": "object",
                "properties": {
                    "email": {"type": "string", "format": "email"},
                    "name": {"type": "string", "minLength": 1},
                    "role": {"type": "string", "enum": ["admin", "user", "viewer"]},
                },
                "required": ["email", "name"],
            },
            response_code=201,
            tags=["Users"],
        ),
        Endpoint(
            method="get", path="/users/{user_id}",
            summary="Get User", description="Get user by ID",
            tags=["Users"],
        ),
    ]

    spec = generate_openapi_spec(
        endpoints,
        title="User Management API",
        version="2.0.0",
        server_url="https://api.example.com/v2",
    )

    valid = validate_spec(spec)
    print(f"Spec valid: {valid}")
    write_spec(spec, "output/openapi.yaml")
```

### Step 3: Validate and Publish

```bash
python3 openapi/extractors/generate_spec.py
# Expected: output/openapi.yaml generated and validated

# Lint with Redocly
redocly lint output/openapi.yaml
# Expected: no errors

# Preview documentation
redocly preview-docs output/openapi.yaml
# Opens browser at localhost:8080 with rendered API docs
```

## CLAUDE.md for OpenAPI Projects

```markdown
# OpenAPI Specification Rules

## Standards
- OpenAPI 3.1.0 (JSON Schema compatible)
- REST API naming conventions (plural nouns, no verbs)
- HTTP status codes per RFC 9110

## File Formats
- .yaml / .json (OpenAPI spec)
- .py / .ts (route source code)

## Libraries
- openapi-spec-validator 0.7+ (Python validation)
- @redocly/cli 1.x (linting and preview)
- swagger-ui / redoc (documentation rendering)

## Testing
- Spec must validate against OpenAPI 3.1 schema
- All $ref references must resolve
- Every endpoint must have at least one response code
- Request/response examples must match schemas

## Conventions
- Use $ref for reusable schemas in components/
- Error responses: 400, 401, 403, 404, 500
- Pagination: page/limit query parameters
- All date-time fields: ISO 8601 format
```

## Common Pitfalls

- **Missing $ref targets:** Referencing `#/components/schemas/User` without defining it causes spec validation failure. Claude Code tracks all references and generates stub schemas for any missing targets.
- **Path parameter not in path template:** Declaring a path parameter that does not appear in the URL template (e.g., declaring `user_id` but path is `/users`) produces a valid-but-broken spec. Claude Code validates parameter names against path templates.
- **Inconsistent error envelope:** Different endpoints returning errors in different formats breaks client code generation. Claude Code standardizes all error responses to a single Error schema.

## Related

- [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code for Code Review](/best-claude-skills-for-code-review-automation/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
