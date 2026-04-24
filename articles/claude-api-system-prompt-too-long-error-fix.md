---
title: "Claude API System Prompt Too Long Error"
description: "Fix Claude API system prompt too long error. Compress system instructions and split into cached blocks. Step-by-step solution."
permalink: /claude-api-system-prompt-too-long-error-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error 400: Invalid Request
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "messages: system prompt is too long. System prompt tokens (98,542) + message tokens (4,231) exceeds the model maximum context window (200,000)."
  }
}
```

## The Fix

1. **Check your system prompt token count before sending**

```python
import anthropic

client = anthropic.Anthropic()

# Count tokens in your system prompt
count = client.count_tokens(
    model="claude-sonnet-4-20250514",
    system="YOUR SYSTEM PROMPT HERE",
    messages=[{"role": "user", "content": "test"}]
)
print(f"Total tokens: {count.input_tokens}")
```

2. **Split system prompt into cached static + dynamic parts**

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "Your large static instructions here...",
            "cache_control": {"type": "ephemeral"}
        },
        {
            "type": "text",
            "text": "Small dynamic context that changes per request"
        }
    ],
    messages=[{"role": "user", "content": "Hello"}]
)
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
r = client.messages.create(
    model='claude-sonnet-4-20250514', max_tokens=10,
    system=[{'type':'text','text':'You are a helpful assistant.','cache_control':{'type':'ephemeral'}}],
    messages=[{'role':'user','content':'ping'}])
print(f'OK: {r.usage.input_tokens} input tokens, cache_read={r.usage.cache_read_input_tokens}')
"
# Expected: OK: [count] input tokens, cache_read=0 (first call) or cache_read=[count] (subsequent)
```

## Why This Happens

The system prompt competes with your messages for space in the model's context window. A 100K-token system prompt leaves only 100K tokens for conversation in Claude's 200K window. This error surfaces when the combined token count of system prompt plus messages exceeds the model's maximum. It commonly occurs when developers embed entire codebases, documentation dumps, or RAG retrieval results directly into the system prompt without tracking token counts.

## If That Doesn't Work

- **Alternative 1:** Move reference material from system prompt to the first user message — system prompt space is premium
- **Alternative 2:** Summarize your system prompt using a cheaper model first: ask Haiku to condense your instructions to under 10K tokens
- **Check:** Use `client.count_tokens()` to measure before each call and abort if over 80% of the context window

## Prevention

Add to your `CLAUDE.md`:
```markdown
Keep system prompts under 10K tokens. Move large reference material to user messages with cache_control. Always count tokens before API calls when system prompt is dynamic. Use prompt caching for static system instructions.
```

**Related articles:** [Context Window Management](/claude-code-context-window-management-guide/), [Claude API 400 Error](/claude-api-error-400-invalidrequesterror-explained/), [Errors Atlas](/errors-atlas/)

## See Also

- [CLAUDE.md Too Long? How to Split and Optimize for Context Window (2026)](/claude-md-too-long-split-and-optimize-fix/)
- [Claude API 413 Request Payload Too Large — Fix (2026)](/claude-api-413-request-payload-too-large-fix/)
- [System Prompt Exceeds Token Limit — Fix (2026)](/claude-code-system-prompt-too-many-tokens-fix-2026/)
