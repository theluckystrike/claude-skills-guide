---
title: "Anthropic Rate Limit Tokens Per Minute"
permalink: /claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/
description: "Wait 60 seconds then retry to fix input token rate limit error. Reduce request size or upgrade your Anthropic API tier to prevent future hits."
last_tested: "2026-04-21"
render_with_liquid: false
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
