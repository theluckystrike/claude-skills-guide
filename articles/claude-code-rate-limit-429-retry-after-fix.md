---
title: "Claude Code 429 Rate Limit with Retry-After — Fix (2026)"
description: "Fix Claude Code 429 rate limit with retry-after header. Parse the header and implement proper backoff logic. Step-by-step solution."
permalink: /claude-code-rate-limit-429-retry-after-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error 429: Too Many Requests
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "Number of request tokens has exceeded your per-minute rate limit (https://docs.anthropic.com/en/api/rate-limits). Please reduce your prompt size or try again after 34 seconds."
  }
}

# Headers include:
retry-after: 34
x-ratelimit-limit-requests: 1000
x-ratelimit-remaining-requests: 0
x-ratelimit-reset-requests: 2026-04-21T15:30:34Z
```

## The Fix

1. **Parse and respect the retry-after header**

```python
import anthropic
import time

def call_with_rate_limit(client, max_retries=5, **kwargs):
    for attempt in range(max_retries):
        try:
            return client.messages.create(**kwargs)
        except anthropic.RateLimitError as e:
            retry_after = int(e.response.headers.get("retry-after", 30))
            print(f"Rate limited. Waiting {retry_after}s (attempt {attempt + 1})")
            time.sleep(retry_after)
    raise RuntimeError("Rate limit exceeded after max retries")
```

2. **Check your current rate limit status**

```bash
# Make a lightweight request and inspect headers
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-haiku-4-20250514","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
  2>&1 | grep -i "x-ratelimit"
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
r = client.messages.create(model='claude-haiku-4-20250514', max_tokens=5, messages=[{'role':'user','content':'test'}])
print(f'OK — remaining requests visible in response headers')
"
# Expected: OK (no rate limit error)
```

## Why This Happens

Anthropic enforces per-minute rate limits on both request count and token count. The limits vary by plan tier (free, build, scale) and model. When you exceed either limit, the API returns 429 with a `retry-after` header indicating how many seconds to wait. Common triggers: parallel requests from multiple Claude Code sessions, batch scripts without throttling, or a single large prompt that exceeds the tokens-per-minute budget. The Anthropic SDK's built-in retry logic may not read `retry-after` by default.

## If That Doesn't Work

- **Alternative 1:** Reduce parallelism — run one Claude Code session at a time or add `time.sleep(2)` between requests
- **Alternative 2:** Use the Batch API for bulk work — it has separate, higher limits: `client.batches.create(...)`
- **Check:** Visit `console.anthropic.com/settings/limits` to see your exact per-minute limits and current usage

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always respect retry-after headers on 429 responses. Default to 2-second delays between API calls in batch scripts. Use a token counter to stay under per-minute token limits. Prefer the Batch API for workloads exceeding 50 requests per minute.
```

**Related articles:** [Claude API Rate Limit Fix](/claude-api-rate-limit-fix/), [Claude API 429 Explained](/claude-api-error-429-ratelimiterror-explained/), [Claude API 529 Fix](/claude-api-529-overloaded-error-handling-fix/)
