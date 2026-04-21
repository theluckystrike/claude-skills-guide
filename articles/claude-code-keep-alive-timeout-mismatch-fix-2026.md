---
title: "Keep-Alive Timeout Mismatch Error — Fix (2026)"
permalink: /claude-code-keep-alive-timeout-mismatch-fix-2026/
description: "Fix socket hang up from keep-alive timeout mismatch. Disable keep-alive or align client and server timeout values."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: socket hang up
  code: 'ECONNRESET'
  at connResetException (node:internal/errors:720:14)
  Reusing keep-alive connection that was closed by server
```

This error occurs when the client reuses a TCP connection that the server has already closed due to keep-alive timeout expiration. The client thinks the connection is live but sends data to a closed socket.

## The Fix

1. Disable keep-alive to force fresh connections:

```bash
export ANTHROPIC_DISABLE_KEEPALIVE=1
claude "test"
```

2. In the Node.js SDK, configure the HTTP agent:

```javascript
import { Agent } from 'node:https';
const agent = new Agent({
  keepAlive: true,
  keepAliveMsecs: 15000, // Less than server timeout
  maxSockets: 10
});
```

3. Or disable keep-alive entirely in the SDK:

```javascript
import { Agent } from 'node:https';
const agent = new Agent({ keepAlive: false });
```

## Why This Happens

HTTP keep-alive allows multiple requests over a single TCP connection. The server closes idle connections after a timeout (typically 30-60 seconds). If the client's keep-alive timeout is longer than the server's, the client may try to send a request on a connection that the server has already closed. The server sends a RST packet, causing "socket hang up."

## If That Doesn't Work

- Add retry logic specifically for ECONNRESET on reused connections:

```python
import anthropic
client = anthropic.Anthropic(max_retries=3)
# SDK automatically retries on ECONNRESET
```

- Check if a proxy modifies keep-alive headers:

```bash
curl -v -H "Connection: keep-alive" https://api.anthropic.com 2>&1 | grep -i "keep-alive\|connection"
```

- Reduce the max idle time on your HTTP client to below 30 seconds.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Connection Management
- Set keep-alive timeout to 15s (less than server's 30s default).
- Always configure max_retries for ECONNRESET recovery.
- In batch processing, disable keep-alive to avoid stale connections.
```
