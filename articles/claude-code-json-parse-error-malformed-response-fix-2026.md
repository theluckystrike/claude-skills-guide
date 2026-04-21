---
title: "JSON Parse Error on Malformed Response Fix"
permalink: /claude-code-json-parse-error-malformed-response-fix-2026/
description: "Fix JSON parse error on malformed API response in Claude Code. Retry the request or clear corrupted cache to resolve SyntaxError unexpected token."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
SyntaxError: Unexpected token '<' at position 0 in JSON
  at JSON.parse (<anonymous>)
  at parseAPIResponse (api-client.js:234)
  Expected valid JSON response from API, got HTML error page instead
```

This appears when Claude Code receives a non-JSON response from the Anthropic API, typically an HTML error page or a truncated response, and fails to parse it.

## The Fix

```bash
claude "Retry the last operation"
```

1. Simply retry the request. Malformed responses are usually transient and caused by network interruptions or API gateway timeouts.
2. If the error persists, check your network connection and the Anthropic status page.
3. Clear any cached responses that may be corrupted.

## Why This Happens

The Anthropic API returns JSON responses, but when the API is overloaded, a CDN or load balancer may return an HTML error page (502/503) instead. Claude Code's JSON parser expects valid JSON and crashes when it encounters HTML. This can also happen when a network proxy injects its own error pages, or when a streaming response is cut off mid-transmission, producing invalid JSON.

## If That Doesn't Work

Check the Anthropic API status page:

```bash
curl -s https://status.anthropic.com/api/v2/status.json | jq '.status'
```

Test the API connection directly:

```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' | jq .
```

If behind a corporate proxy, check if it is intercepting API responses:

```bash
curl -v https://api.anthropic.com 2>&1 | grep "< HTTP"
```

## Prevention

```markdown
# CLAUDE.md rule
If you see a JSON parse error, retry once before investigating. Report persistent parse errors — they indicate a network or proxy issue, not a code problem.
```
