---
title: "Request Body Validation Failed — Fix"
permalink: /claude-code-request-body-validation-failed-fix-2026/
description: "Fix 'request body validation failed' error. Check JSON structure, required fields, and type mismatches in your API call."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 400: Invalid request body: messages[0].content must be a string or array of content blocks, got number
```

This error fires when the request JSON does not match the Anthropic API schema. Common culprits are wrong types, missing required fields, or malformed content blocks.

## The Fix

1. Validate your request body structure. Messages must follow this format:

```bash
cat <<'EOF' > /tmp/test-request.json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "Hello Claude"}
  ]
}
EOF
python3 -c "import json; json.load(open('/tmp/test-request.json')); print('Valid JSON')"
```

2. Send the corrected request:

```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d @/tmp/test-request.json | python3 -m json.tool
```

3. If using tool_use, verify the input_schema is valid JSON Schema:

```bash
python3 -c "
import json
schema = {'type': 'object', 'properties': {'query': {'type': 'string'}}, 'required': ['query']}
print(json.dumps(schema, indent=2))
"
```

## Why This Happens

The Anthropic API performs strict schema validation on every request. Unlike some APIs that silently coerce types, Anthropic rejects anything that does not match the expected schema. Common mistakes include passing `content` as a number instead of a string, omitting `max_tokens`, or nesting content blocks incorrectly.

## If That Doesn't Work

- Enable SDK debug logging to see the raw request:

```bash
ANTHROPIC_LOG=debug claude "test"
```

- Check for invisible characters or BOM markers in your JSON:

```bash
file /tmp/test-request.json
xxd /tmp/test-request.json | head -5
```

- Verify your `system` prompt is a string, not an array (unless using multi-turn system blocks).

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# API Requests
- Always validate JSON payloads before sending to Anthropic API.
- Use the SDK instead of raw HTTP — it enforces correct types at compile time.
- Test tool schemas with a minimal request before adding to production.
```
