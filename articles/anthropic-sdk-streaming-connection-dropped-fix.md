---
title: "Anthropic SDK Streaming Connection Dropped — Fix (2026)"
description: "Fix Anthropic SDK streaming connection dropped mid-response. Implement reconnection with partial content recovery. Step-by-step solution."
permalink: /anthropic-sdk-streaming-connection-dropped-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
anthropic.APIConnectionError: Connection error.
  Request was interrupted during streaming response.
  Received 1,247 of expected ~4,000 tokens before connection was lost.
```

Or in TypeScript:

```
AnthropicError: Connection terminated unexpectedly
  at StreamingMessageResponse._readableStream
```

## The Fix

1. **Wrap streaming calls with reconnection logic that preserves partial output**

```python
import anthropic

def stream_with_recovery(client, messages, max_retries=3, **kwargs):
    collected_text = ""
    for attempt in range(max_retries):
        try:
            with client.messages.stream(
                messages=messages,
                **kwargs
            ) as stream:
                for text in stream.text_stream:
                    collected_text += text
                    print(text, end="", flush=True)
                return collected_text
        except anthropic.APIConnectionError:
            if attempt == max_retries - 1:
                raise
            messages = messages + [
                {"role": "assistant", "content": collected_text},
                {"role": "user", "content": "Continue from where you left off."}
            ]
```

2. **Increase your HTTP client timeout settings**

```python
client = anthropic.Anthropic(
    timeout=600.0,  # 10 minutes for long responses
)
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic(timeout=600.0)
with client.messages.stream(model='claude-sonnet-4-20250514', max_tokens=1000, messages=[{'role':'user','content':'Write a 500-word essay about trees.'}]) as s:
    text = ''.join([t for t in s.text_stream])
print(f'Received {len(text)} chars successfully')
"
# Expected: Received XXXX chars successfully
```

## Why This Happens

Streaming connections use long-lived HTTP/2 or SSE connections that are vulnerable to network interruptions. Corporate proxies, load balancers with idle timeout settings (often 60-120 seconds), and unstable WiFi connections commonly terminate these streams mid-response. The server sends chunks incrementally, and any break in the TCP connection causes data loss.

## If That Doesn't Work

- **Alternative 1:** Use non-streaming `client.messages.create()` for critical requests — it buffers the full response server-side
- **Alternative 2:** Run behind a stable wired connection if on WiFi
- **Check:** Test your network stability with `curl -N https://api.anthropic.com/v1/messages --max-time 300` to see if the connection holds

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use streaming with reconnection logic for any response expected to exceed 500 tokens. Set HTTP timeout to at least 300s. Avoid streaming through proxies with aggressive idle timeouts.
```

**Related articles:** [Claude API Timeout Handling](/claude-code-timeout-fix/), [Claude API Error Handling](/claude-code-api-error-handling-standards/), [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)
