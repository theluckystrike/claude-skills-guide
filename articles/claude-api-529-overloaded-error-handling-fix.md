---
title: "Claude API 529 Overloaded Error"
description: "Fix Claude API 529 overloaded_error with queue-based retry and model fallback chain. Step-by-step solution with working code."
permalink: /claude-api-529-overloaded-error-handling-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error 529: Overloaded
{
  "type": "error",
  "error": {
    "type": "overloaded_error",
    "message": "Overloaded. Too many requests to this model right now. Please try a different model or try again later."
  }
}
```

## The Fix

1. **Implement a model fallback chain with automatic retry**

```python
import anthropic
import time

FALLBACK_CHAIN = [
    "claude-sonnet-4-20250514",
    "claude-haiku-4-20250514",
]

def call_with_fallback(client, messages, max_tokens=1024):
    for model in FALLBACK_CHAIN:
        for attempt in range(3):
            try:
                return client.messages.create(
                    model=model,
                    max_tokens=max_tokens,
                    messages=messages
                )
            except anthropic.APIStatusError as e:
                if e.status_code == 529:
                    wait = min(30, (2 ** attempt) * 5)
                    time.sleep(wait)
                    continue
                raise
    raise RuntimeError("All models overloaded after retries")
```

2. **For batch workloads, use the Message Batches API**

```python
batch = client.batches.create(
    requests=[
        {"custom_id": f"req-{i}", "params": {
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [{"role": "user", "content": prompt}]
        }}
        for i, prompt in enumerate(prompts)
    ]
)
print(f"Batch {batch.id} queued — check status later")
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
try:
    r = client.messages.create(model='claude-sonnet-4-20250514', max_tokens=10, messages=[{'role':'user','content':'test'}])
    print(f'Direct call OK: {r.model}')
except anthropic.APIStatusError as e:
    if e.status_code == 529:
        print('Model overloaded — fallback chain would activate')
"
# Expected: Direct call OK: claude-sonnet-4-20250514
```

## Why This Happens

The 529 status code signals that the specific model you requested is at capacity. Unlike a generic 503 (infrastructure down), 529 means the API is running but that particular model's inference cluster is saturated. This happens more with larger models (Opus) during peak hours and less with smaller models (Haiku). The Batch API sidesteps this entirely by queuing requests for processing within a 24-hour window.

## If That Doesn't Work

- **Alternative 1:** Reduce `max_tokens` — smaller response budgets free capacity faster on the server
- **Alternative 2:** Spread requests over time with a [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/): `time.sleep(1)` between calls
- **Check:** Monitor `https://status.anthropic.com` for ongoing capacity incidents

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always implement a model fallback chain for production API calls: Sonnet -> Haiku. Use the Batch API for non-interactive workloads. Never retry 529 errors without backoff delay.
```

**Related articles:** [Claude API 529 Overloaded Explained](/claude-api-error-529-overloadederror-explained/), [Claude API Rate Limit Fix](/claude-api-rate-limit-fix/), [Claude API 503 Fix](/claude-api-503-service-unavailable-fix/)


## Related

- [Claude internal server error fix](/claude-internal-server-error-fix/) — Fix Claude internal server error (500/overloaded)
- [Make Claude Code Add Error Handling (2026)](/claude-code-skips-error-handling-fix-2026/)
