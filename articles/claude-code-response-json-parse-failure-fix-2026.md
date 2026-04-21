---
title: "Response JSON Parse Failure — Fix (2026)"
permalink: /claude-code-response-json-parse-failure-fix-2026/
description: "Fix JSON parse error on API response. Caused by truncated response or proxy interference. Enable retry and increase timeout."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
SyntaxError: Unexpected end of JSON input at JSON.parse (<anonymous>)
  Response body: '{"id":"msg_01X...","type":"message","content":[{"type":"text","tex'
```

This error occurs when the API response is truncated before the SDK can parse it. The JSON body is incomplete, usually cut off mid-stream.

## The Fix

1. Increase the request timeout to allow longer responses:

```bash
export ANTHROPIC_TIMEOUT=120000
```

2. If using the Python SDK, set timeout explicitly:

```python
import anthropic
client = anthropic.Anthropic(timeout=120.0)
```

3. If using the Node.js SDK:

```javascript
const client = new Anthropic({ timeout: 120000 });
```

4. Test with a short prompt to confirm connectivity:

```bash
claude "say ok"
```

## Why This Happens

The response is cut short by a network timeout, TCP reset, or proxy that enforces a maximum response size. The SDK receives a partial JSON body and attempts to parse it, causing the SyntaxError. This is especially common with long responses (high `max_tokens`) or slow connections.

## If That Doesn't Work

- Switch to streaming mode which processes chunks incrementally:

```bash
claude config set streaming true
```

- Check if your proxy has a response size limit:

```bash
curl -v https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":100,"messages":[{"role":"user","content":"hi"}]}' 2>&1 | grep -i "content-length\|transfer-encoding"
```

- Reduce `max_tokens` to get shorter responses that complete within timeouts.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Response Handling
- Always use streaming for responses expected to exceed 4096 tokens.
- Set ANTHROPIC_TIMEOUT=120000 in all environments.
- Implement retry with exponential backoff for parse failures.
```
