---
layout: default
title: "Claude Code 429 Rate Limit (2026)"
description: "Fix Claude Code 429 rate limit with retry-after header. Parse the header and implement proper backoff logic. Step-by-step solution."
permalink: /claude-code-rate-limit-429-retry-after-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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

- [Fix Claude Code API Rate Limit Reached](/claude-code-api-error-rate-limit-reached/)
- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)
- [Fix Claude Rate Exceeded Error (2026)](/claude-rate-exceeded-error-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
