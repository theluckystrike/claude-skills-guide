---
title: "API 529 Overloaded Retry Backoff — Fix"
permalink: /claude-code-api-overloaded-529-backoff-fix-2026/
description: "Fix API 529 overloaded errors with exponential backoff. Implement retry logic with jitter to handle Anthropic capacity limits."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 529: API is temporarily overloaded. Please retry after 30 seconds.
Retry-After: 30
```

This error means Anthropic's servers are at capacity. Unlike [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) (rate limit), 529 indicates server-side load, not per-account limits. It typically occurs during peak usage hours.

## The Fix

1. Implement exponential backoff with jitter:

```bash
# Quick retry with backoff
for i in 1 2 3 4 5; do
  response=$(claude "hello" 2>&1)
  if echo "$response" | grep -q "529"; then
    sleep_time=$((2 ** i + RANDOM % 5))
    echo "Retry $i: waiting ${sleep_time}s..."
    sleep $sleep_time
  else
    echo "$response"
    break
  fi
done
```

2. In Python, use the SDK's built-in retry:

```python
import anthropic
client = anthropic.Anthropic(max_retries=5)
# SDK automatically retries 529 with exponential backoff
```

3. In Node.js:

```javascript
const client = new Anthropic({ maxRetries: 5 });
```

## Why This Happens

529 errors indicate that Anthropic's infrastructure is experiencing high demand. This is different from 429 rate limits which are per-account. During peak hours (US business hours, product launches), the API may shed load by returning 529. The `Retry-After` header tells you exactly how long to wait.

## If That Doesn't Work

- Respect the `Retry-After` header value exactly — do not retry sooner.
- Switch to a smaller model (Haiku) for non-critical tasks during peak hours.
- Use the Message Batches API for non-urgent work — batches are processed during off-peak times.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# API Resilience
- Always configure max_retries >= 3 for SDK clients.
- For batch workloads, use the Message Batches API instead of synchronous calls.
- Schedule heavy API usage outside US business hours (9 AM - 5 PM PT).
```


## Related

- [Claude internal server error fix](/claude-internal-server-error-fix/) — Fix Claude internal server error (500/overloaded)
- [Claude Code Request Timed Out 120000ms — Fix (2026)](/claude-code-api-timeout-ms-setting-fix-2026/)
- [API Version Deprecated Error — Fix (2026)](/claude-code-api-version-deprecation-error-fix-2026/)
