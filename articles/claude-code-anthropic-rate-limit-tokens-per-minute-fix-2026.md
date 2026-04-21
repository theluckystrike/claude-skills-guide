---
title: "Anthropic Rate Limit Tokens Per Minute — Fix (2026)"
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
