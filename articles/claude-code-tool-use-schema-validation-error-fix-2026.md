---
title: "Tool Use Schema Validation Error — Fix"
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

## See Also

- [Claude tool_use Response Parsing Error — Fix (2026)](/claude-tool-use-response-parsing-error-fix/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `SyntaxError: Unexpected token in JSON at position 0`
- `JSON.parse: unexpected character at line 1 column 1`
- `Error: invalid JSON response from API`
- `TS2307: Cannot find module`
- `TS2322: Type 'string' is not assignable to type 'number'`

## Frequently Asked Questions

### Why does JSON parsing fail on API responses?

JSON parse failures on API responses typically indicate a network issue where an intermediate proxy returned an HTML error page instead of JSON. Check the raw response by enabling debug logging with `CLAUDE_LOG_LEVEL=debug` to see the actual content received.

### How do I fix corrupted JSON config files?

Open the file in a text editor and look for common issues: trailing commas, missing quotes, or truncated content (from a crash during write). Use `python3 -m json.tool < file.json` to validate and identify the exact parse error location.

### Can Claude Code handle JSON files with comments?

Standard JSON does not support comments. If your project uses JSONC (JSON with Comments), Claude Code handles it when reading via tools. For configuration files like `tsconfig.json` that support JSONC, Claude Code strips comments before parsing.

### Why does Claude Code generate TypeScript errors?

Claude Code generates code based on the types and patterns it sees in your codebase. If your tsconfig uses strict mode but Claude Code does not see the full type definitions, it may produce code that fails type checking. Add the relevant type information to your prompt or CLAUDE.md.
