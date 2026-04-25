---
layout: default
title: "Keep-Alive Timeout Mismatch Error — Fix (2026)"
permalink: /claude-code-keep-alive-timeout-mismatch-fix-2026/
date: 2026-04-20
description: "Keep-Alive Timeout Mismatch Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
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

- [Fix Claude API Timeout](/claude-api-timeout-error-handling-retry-guide/)
- [Fix Claude Code Timeout Error (2026)](/claude-code-skill-timeout-error-how-to-increase-the-limit/)
- [Claude Code Bash Command Timeout 120s — Fix (2026)](/claude-code-bash-command-timeout-120s-fix-2026/)
- [Claude SDK Timeout Configuration Guide](/claude-sdk-timeout-configuration-customization/)

## Timeout Configuration Reference

Claude Code has several timeout settings that interact with each other:

| Setting | Default | Controls | How to Change |
|---------|---------|----------|---------------|
| Bash timeout | 120s | Maximum time for a single bash command | `CLAUDE_CODE_BASH_TIMEOUT=600` |
| API timeout | 300s | Maximum time waiting for API response | Network-level setting |
| Session timeout | None | Auto-close after inactivity | Not currently configurable |
| MCP server init | 30s | Time allowed for MCP server startup | Set in settings.json |

## Diagnosing Slow Operations

When Claude Code appears to hang, determine which component is slow:

**Step 1: Check CPU and memory.** Run `top -l 1 | grep -E "node|claude"` (macOS) or `top -bn1 | grep -E "node|claude"` (Linux). High CPU suggests active computation. High memory (over 1GB) suggests the conversation context is too large.

**Step 2: Check network connectivity.** Run `curl -s -o /dev/null -w "%{time_total}" https://api.anthropic.com/v1/messages`. Response times over 2 seconds indicate network issues between you and the API.

**Step 3: Check disk I/O.** Run `iostat 1 3` to see if disk is a bottleneck. Claude Code performs significant file reads when scanning large projects. An SSD reduces file scanning from minutes to seconds.

**Step 4: Reduce context size.** If the session has been running for many turns, accumulated context can slow API responses. Use `/clear` to reset the conversation and start fresh with a smaller context window.
