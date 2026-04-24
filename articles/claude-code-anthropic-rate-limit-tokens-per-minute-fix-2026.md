---
title: "Anthropic Rate Limit Tokens Per Minute — Fix (2026)"
permalink: /claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/
description: "Wait 60 seconds then retry to fix input token rate limit error. Reduce request size or upgrade your Anthropic API tier to prevent future hits."
last_tested: "2026-04-21"
---

## The Error

```
Rate limited: 80000 input tokens per minute exceeded
```

## The Fix

```bash
# Wait 60 seconds for the rate limit window to reset, then retry
sleep 60

# Reduce input size by being more specific in your requests
# Instead of: "Read all files in src/ and refactor them"
# Say: "Read src/auth/login.ts and fix the null check on line 42"
```

## Why This Works

Anthropic enforces per-minute token quotas based on your API tier. The 80,000 input token limit means your recent requests (within the sliding 60-second window) consumed too many tokens. Waiting for the window to reset clears the counter. Reducing file reads and narrowing scope keeps future requests under the ceiling.

## If That Doesn't Work

```bash
# Check your current API tier and limits
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
  2>&1 | grep -i "rate\|limit\|tier"

# Request a tier upgrade at console.anthropic.com if hitting limits regularly
# Or use the Max plan which has higher rate limits
```

Higher API tiers (Scale, Enterprise) offer significantly higher token-per-minute allowances.

## Prevention

Add to your CLAUDE.md:
```
Minimize input tokens by reading only files relevant to the current task. Avoid reading entire directories. Use Grep to locate specific content before reading full files. Space large operations across multiple sessions.
```

## See Also

- [Claude Code used 500K tokens for a simple task — how to prevent](/claude-code-500k-tokens-simple-task-prevent/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `429 Too Many Requests`
- `RateLimitError: rate limit exceeded`
- `Error: tokens_per_minute limit reached`
- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`

## Frequently Asked Questions

### What are the Claude API rate limits?

Rate limits vary by plan tier and are measured in requests per minute (RPM) and tokens per minute (TPM). Free tier has lower limits than paid plans. Check your current limits at console.anthropic.com under your organization settings.

### Does Claude Code handle rate limits automatically?

Yes. Claude Code implements exponential backoff when it receives HTTP 429 responses. It waits and retries automatically, typically resolving within 30-60 seconds. You do not need to add retry logic in your prompts or workflow.

### How can I reduce my token usage?

Use shorter prompts, reference specific files instead of loading entire directories, and close conversations that have accumulated large context windows. Starting a fresh conversation resets the context and reduces per-request token consumption.

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.


## Related Guides

- [Claude Code 429 Rate Limit](/claude-code-rate-limit-429-retry-after-fix/)
- [Fix Claude Code API Rate Limit Reached](/claude-code-api-error-rate-limit-reached/)
- [Fix Claude Rate Exceeded Error (2026)](/claude-rate-exceeded-error-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)

## Rate Limit Tiers and Thresholds

Understanding your rate limits helps you plan token budgets and avoid interruptions:

| Plan | Requests/min | Input tokens/min | Output tokens/min |
|------|-------------|-------------------|-------------------|
| Free | 50 | 40,000 | 8,000 |
| Build | 1,000 | 400,000 | 80,000 |
| Scale | 4,000 | 2,000,000 | 400,000 |

Check your current tier at console.anthropic.com/settings/limits. The most common trigger for rate limiting in Claude Code is running multiple sessions in parallel, each generating rapid API calls.

## Implementing Proper Backoff

The correct backoff strategy for Claude Code rate limits follows three rules:

1. **Always read the `retry-after` header.** This tells you exactly how many seconds to wait. Do not guess or use a fixed delay.

2. **Use exponential backoff as a fallback.** If the header is missing, start with a 2-second delay and double it on each consecutive 429 response, up to a maximum of 60 seconds.

3. **Track token consumption proactively.** Count tokens before sending requests. If you are within 80% of your per-minute limit, add a voluntary 5-second delay between requests to avoid hitting the hard limit.
