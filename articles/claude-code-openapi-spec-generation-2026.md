---
layout: default
title: "Claude Code for OpenAPI Spec Generation (2026)"
description: "Claude Code for OpenAPI Spec Generation — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-openapi-spec-generation-2026/
date: 2026-04-20
last_tested: "2026-04-21"
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
- [Claude Code for FEA Mesh Generation (2026)](/claude-code-fea-mesh-generation-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Claude Code Spec Workflow](/claude-code-spec-workflow-guide/)
- [Claude Code for OpenAPI 3.1 Workflow](/claude-code-for-openapi-3-1-workflow-tutorial/)
- [Claude Code OpenAPI Client Generation](/claude-code-openapi-client-generation-guide/)
- [Claude Code OpenAPI to Zod Client](/claude-code-for-openapi-zod-client-workflow/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
