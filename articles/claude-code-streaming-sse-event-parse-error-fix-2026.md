---
title: "Streaming SSE Event Parse Error — Fix (2026)"
permalink: /claude-code-streaming-sse-event-parse-error-fix-2026/
description: "Fix SSE 'unexpected field in event stream' error. Caused by proxy rewriting chunked responses. Bypass with direct connection."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
AnthropicError: Could not parse server-sent event: unexpected field 'X-Cache-Status' in event stream at position 847
```

This error occurs when a network intermediary (CDN, reverse proxy, or corporate firewall) injects HTTP headers into the SSE chunked transfer stream, corrupting the event format that the Anthropic SDK expects.

## The Fix

1. Bypass any local proxy for Anthropic API calls:

```bash
export NO_PROXY="api.anthropic.com,$NO_PROXY"
```

2. If behind a corporate proxy, set the direct endpoint:

```bash
export HTTPS_PROXY=""
claude "test streaming"
```

3. If using nginx as a reverse proxy, disable response buffering:

```nginx
proxy_buffering off;
proxy_cache off;
proxy_set_header Connection '';
proxy_http_version 1.1;
chunked_transfer_encoding on;
```

4. Restart Claude Code and test:

```bash
claude "count from 1 to 5 slowly"
```

## Why This Happens

The Anthropic streaming API uses Server-Sent Events (SSE) over HTTP/1.1 chunked transfer encoding. Each chunk must follow the `event:` / `data:` format strictly. When a proxy or CDN buffers and re-chunks the response, it can inject its own headers or merge chunks, breaking the SSE parser in the SDK.

## If That Doesn't Work

- Disable HTTP/2 multiplexing which some proxies force:

```bash
export ANTHROPIC_DISABLE_HTTP2=1
```

- Test with curl to confirm the raw stream is clean:

```bash
curl -N https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":50,"stream":true,"messages":[{"role":"user","content":"hi"}]}'
```

- Upgrade the SDK to the latest version which has improved chunked parsing:

```bash
pip install --upgrade anthropic
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Streaming Configuration
- Do not route Anthropic API traffic through caching proxies or CDNs.
- Set NO_PROXY=api.anthropic.com in CI/CD environments.
- Always use proxy_buffering off when reverse-proxying SSE streams.
```
