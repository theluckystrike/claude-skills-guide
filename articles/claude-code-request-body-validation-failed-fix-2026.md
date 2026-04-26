---
layout: default
title: "Request Body Validation Failed — Fix (2026)"
permalink: /claude-code-request-body-validation-failed-fix-2026/
date: 2026-04-20
description: "Fix 'request body validation failed' error. Check JSON structure, required fields, and type mismatches in your API call."
last_tested: "2026-04-22"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [MCP Server Input Validation Security](/mcp-server-input-validation-security-patterns/)
- [FastAPI Pydantic V2 Validation](/claude-code-fastapi-pydantic-v2-validation-deep-dive/)
- [Tool Use Schema Validation Error — Fix](/claude-code-tool-use-schema-validation-error-fix-2026/)
- [Input Validation and Sanitization](/claude-code-input-validation-sanitization-patterns-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
