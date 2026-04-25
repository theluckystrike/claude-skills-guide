---
layout: default
title: "Response JSON Parse Failure — Fix (2026)"
permalink: /claude-code-response-json-parse-failure-fix-2026/
date: 2026-04-20
description: "Fix JSON parse error on API response. Caused by truncated response or proxy interference. Enable retry and increase timeout."
last_tested: "2026-04-22"
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

## See Also

- [IPv6 Fallback Failure Error — Fix (2026)](/claude-code-ipv6-fallback-failure-fix-2026/)
- [JSON Parse Error on Malformed Response Fix](/claude-code-json-parse-error-malformed-response-fix-2026/)
- [Response Truncation Max Tokens Hit Fix](/claude-code-response-truncation-max-tokens-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNREFUSED: connection refused through proxy`
- `Error: unable to verify the first certificate`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### How do I configure Claude Code to use a corporate proxy?

Set the `HTTPS_PROXY` environment variable: `export HTTPS_PROXY=http://proxy.corp.com:8080`. Claude Code respects standard proxy environment variables. Add this to your shell profile for persistence.


## Related Guides

- [Prisma Generate Failure After Schema](/claude-code-prisma-generate-failure-fix-2026/)
- [Pre-Commit Hook Failure on Claude — Fix (2026)](/claude-code-pre-commit-hook-failure-fix-2026/)
- [TLS Version Negotiation Failure — Fix](/claude-code-tls-version-negotiation-failure-fix-2026/)
- [ESM vs CJS Module Resolution Failure — Fix (2026)](/claude-code-esm-vs-cjs-module-resolution-fix-2026/)

## JSON Error Patterns in Claude Code

JSON parsing errors occur in several contexts within Claude Code, each with a different root cause:

**API response parsing.** The Anthropic API returns JSON responses. If the response is truncated (network timeout, proxy interference) or modified (corporate proxy injecting error pages), the JSON parser fails. Check network connectivity first.

**Configuration file parsing.** Files like `settings.json`, `tsconfig.json`, and `package.json` must be valid JSON. Common issues: trailing commas (not allowed in JSON), comments (not allowed in standard JSON, but allowed in tsconfig.json), and UTF-8 BOM characters at the start of the file.

**Tool output parsing.** When Claude Code's tools return results, they are JSON-encoded. If a bash command produces output that interferes with JSON encoding (binary data, very long lines, or null bytes), the parsing fails.

## Debugging JSON Parse Errors

Follow this sequence to identify and fix the problem:

```bash
# Validate a JSON file
python3 -m json.tool file.json 2>&1

# Find the exact error location
python3 -c "
import json
with open('file.json') as f:
    try:
        json.load(f)
    except json.JSONDecodeError as e:
        print(f'Error at line {e.lineno}, column {e.colno}: {e.msg}')
"

# Remove BOM characters
sed -i '1s/^ï»¿//' file.json

# Check for trailing commas (common mistake)
grep -n ',[ 	]*[}\]]' file.json
```
