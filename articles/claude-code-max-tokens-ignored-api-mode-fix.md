---
title: "Claude Code max_tokens Ignored in API"
description: "Fix Claude Code max_tokens parameter being ignored in API mode. Use the correct parameter name and placement. Step-by-step solution."
permalink: /claude-code-max-tokens-ignored-api-mode-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
# You set max_tokens=500 but get responses with 2000+ tokens:
Response tokens: 2,147 (expected max 500)

# Or:
Warning: max_tokens parameter has no effect in this mode.
  Claude Code manages response length internally.

# Or in API usage:
{
  "usage": {
    "input_tokens": 1234,
    "output_tokens": 4096  // Much higher than your max_tokens setting
  }
}
```

## The Fix

1. **Use the correct parameter for your invocation method**

```bash
# CLI mode — use --max-tokens flag
claude -p "Write a haiku" --max-tokens 100

# API mode — set max_tokens in the request body (not headers)
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 500,
    "messages": [{"role": "user", "content": "Write a haiku"}]
  }'
```

2. **For the SDK, ensure max_tokens is a top-level parameter**

```python
import anthropic

client = anthropic.Anthropic()

# WRONG — max_tokens in wrong location
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    messages=[{"role": "user", "content": "Write a haiku"}],
    # max_tokens missing — defaults to model maximum
)

# CORRECT — max_tokens as required top-level parameter
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=500,
    messages=[{"role": "user", "content": "Write a haiku"}]
)
print(f"Output tokens: {response.usage.output_tokens}")
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
r = client.messages.create(model='claude-sonnet-4-20250514', max_tokens=50, messages=[{'role':'user','content':'Count to 1000'}])
print(f'Output tokens: {r.usage.output_tokens} (max was 50)')
print(f'Stop reason: {r.stop_reason}')
"
# Expected: Output tokens: ~50 (or less), Stop reason: max_tokens
```

## Why This Happens

`max_tokens` is a required parameter in the Anthropic Messages API, but it is easily misconfigured. Common mistakes: passing it as a header instead of in the request body, nesting it inside a metadata object, or confusing it with `max_completion_tokens` (an OpenAI parameter that doesn't exist in the Anthropic API). In Claude Code CLI mode, the `--max-tokens` flag only applies to the API call, not to the tool usage budget. When the stop_reason is `end_turn` instead of `max_tokens`, the response finished naturally within the limit.

## If That Doesn't Work

- **Alternative 1:** Add an explicit instruction in the system prompt: "Respond in under 100 words" for soft length control
- **Alternative 2:** Check `response.stop_reason` — if it's `end_turn`, the model finished before hitting the limit (which means it's working correctly)
- **Check:** Print the full API response to verify `max_tokens` was accepted: `print(response.model_dump_json(indent=2))`

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always set max_tokens explicitly in API calls — it is a required parameter. Check response.stop_reason to confirm if output was truncated (max_tokens) or completed naturally (end_turn). Budget max_tokens for the expected response size plus 20% margin.
```

**Related articles:** [Claude API Error 400 Fix](/claude-api-error-400-invalidrequesterror-explained/), [Context Window Management](/claude-code-context-window-management-guide/), [Claude API Error Handling](/claude-code-api-error-handling-standards/)

## See Also

- [File Descriptor Leak in Watch Mode Fix](/claude-code-file-descriptor-leak-watch-mode-fix-2026/)
- [Claude Code Workspace Trust Blocks Headless — Fix (2026)](/claude-code-workspace-trust-blocks-headless-mode-fix/)
- [Response Truncation Max Tokens Hit Fix](/claude-code-response-truncation-max-tokens-fix-2026/)
