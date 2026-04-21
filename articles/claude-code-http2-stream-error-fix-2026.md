---
title: "HTTP/2 Stream Error During Request — Fix (2026)"
permalink: /claude-code-http2-stream-error-fix-2026/
description: "Fix HTTP/2 stream error (NGHTTP2_INTERNAL_ERROR). Force HTTP/1.1 or increase stream limits to resolve multiplexing issues."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Stream closed with error code NGHTTP2_INTERNAL_ERROR
  code: 'ERR_HTTP2_STREAM_ERROR'
  at ClientHttp2Stream._destroy (node:internal/http2/core:251:13)
```

This error occurs when an HTTP/2 stream fails during an API request. The multiplexed connection encounters an internal error, typically from a network intermediary that does not properly handle HTTP/2.

## The Fix

1. Force HTTP/1.1 for Anthropic API calls:

```bash
export ANTHROPIC_HTTP_VERSION=1.1
claude "test"
```

2. Or set it globally for Node.js:

```bash
export NODE_OPTIONS="--http-parser=legacy"
```

3. If using the Python SDK, disable HTTP/2:

```python
import httpx
import anthropic

http_client = httpx.Client(http2=False)
client = anthropic.Anthropic(http_client=http_client)
```

4. Verify the fix:

```bash
claude "count to 5"
```

## Why This Happens

HTTP/2 multiplexes multiple requests over a single TCP connection using streams. When a network device (corporate proxy, load balancer, CDN) does not fully support HTTP/2 or has stream limits, individual streams can fail with internal errors. The proxy may accept the HTTP/2 connection but fail to properly forward the stream frames to the origin server.

## If That Doesn't Work

- Check if your proxy supports HTTP/2:

```bash
curl -v --http2 https://api.anthropic.com 2>&1 | grep "HTTP/2"
```

- Reset the HTTP/2 connection pool:

```bash
# Kill all Claude Code processes to reset connections
pkill -f "claude"
claude "test"
```

- If using nginx as reverse proxy, increase the stream limit:

```nginx
http2_max_concurrent_streams 128;
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# HTTP/2
- If behind a corporate proxy, force HTTP/1.1: export ANTHROPIC_HTTP_VERSION=1.1
- HTTP/2 stream errors are usually proxy issues, not API issues.
- Test with curl --http2 to verify HTTP/2 support before enabling.
```
