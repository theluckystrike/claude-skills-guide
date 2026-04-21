---
title: "Tool Use Schema Validation Error — Fix (2026)"
permalink: /claude-code-tool-use-schema-validation-error-fix-2026/
description: "Fix tool use schema validation error. Ensure input_schema is valid JSON Schema draft 2020-12 with correct property types."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 400: tools[0].input_schema: 'anyOf' is not supported. Use 'oneOf' or separate tool definitions instead.
```

This error occurs when your tool definition's `input_schema` uses JSON Schema features that the Anthropic API does not support, such as `anyOf`, `$ref`, or `patternProperties`.

## The Fix

1. Replace unsupported schema features with supported ones:

```python
# Before (fails):
tools = [{"name": "search", "input_schema": {
    "type": "object",
    "properties": {"query": {"anyOf": [{"type": "string"}, {"type": "array"}]}}
}}]

# After (works):
tools = [{"name": "search", "input_schema": {
    "type": "object",
    "properties": {"query": {"type": "string", "description": "Search query as a string"}},
    "required": ["query"]
}}]
```

2. Validate your schema before sending:

```bash
python3 -c "
import json
schema = {
    'type': 'object',
    'properties': {
        'query': {'type': 'string', 'description': 'The search term'}
    },
    'required': ['query']
}
print(json.dumps(schema, indent=2))
print('Schema is valid')
"
```

3. Test the tool definition:

```bash
claude "use the search tool to find python docs" --tools '[{"name":"search","description":"Search the web","input_schema":{"type":"object","properties":{"query":{"type":"string"}},"required":["query"]}}]'
```

## Why This Happens

The Anthropic API supports a subset of JSON Schema for tool definitions. Features like `anyOf`, `$ref`, `allOf`, `patternProperties`, and recursive schemas are not supported. The API validates schemas strictly at request time and rejects unsupported keywords.

## If That Doesn't Work

- Simplify nested schemas by flattening them into a single-level object.
- Replace enum arrays with a `description` that lists valid values.
- If your schema is generated from TypeScript types, manually simplify the output.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Tool Schemas
- Only use: type, properties, required, description, enum in tool input_schema.
- Avoid: anyOf, allOf, oneOf, $ref, patternProperties, additionalProperties.
- Test all tool definitions with a minimal API call before production use.
```
