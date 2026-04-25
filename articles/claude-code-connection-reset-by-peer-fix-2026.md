---
layout: default
title: "Connection Reset by Peer Error — Fix (2026)"
permalink: /claude-code-connection-reset-by-peer-fix-2026/
date: 2026-04-20
description: "Connection Reset by Peer Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: read ECONNRESET
  code: 'ECONNRESET'
  syscall: 'read'
  at TLSWrap.onStreamRead (node:internal/stream_base_commons:217:20)
  request to https://api.anthropic.com/v1/messages failed
```

This error occurs when the remote server or a network device forcibly closes the TCP connection during data transfer. The connection was established but then dropped.

## The Fix

1. Retry the request — this is usually transient:

```bash
claude "your prompt" || claude "your prompt"
```

2. Configure the SDK with automatic retries:

```python
import anthropic
client = anthropic.Anthropic(max_retries=3)
```

3. Check your network connection:

```bash
curl -v https://api.anthropic.com 2>&1 | tail -5
ping -c 3 api.anthropic.com
```

4. If on WiFi, try a wired connection or different network.

## Why This Happens

ECONNRESET means the remote end sent a TCP RST packet, terminating the connection abruptly. Common causes: network instability (WiFi drops), load balancer timeout (the request took too long to process), firewall connection tracking table overflow, or VPN tunnel instability. This is a transport-level error, not an API error.

## If That Doesn't Work

- Disable HTTP keep-alive which can cause stale connection resets:

```bash
export ANTHROPIC_DISABLE_KEEPALIVE=1
```

- Increase TCP keepalive interval:

```bash
# macOS
sudo sysctl -w net.inet.tcp.keepidle=60000
```

- Check if your VPN is dropping long-lived connections and switch to split tunneling.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Network Resilience
- Always configure max_retries >= 3 for API clients.
- Use wired connections for long-running Claude Code sessions.
- If behind VPN, enable split tunneling for api.anthropic.com.
- ECONNRESET is transient — retry before investigating.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ERR_TLS_CERT_ALTNAME_INVALID`
- `UNABLE_TO_VERIFY_LEAF_SIGNATURE`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### What TLS version does Claude Code require?

Claude Code requires TLS 1.2 or later. The Anthropic API endpoints do not support TLS 1.0 or 1.1. If your network or proxy forces an older TLS version, the connection fails during the handshake.


## Related Guides

- [Peer Dependency Conflict npm Error](/claude-code-peer-dependency-conflict-fix-2026/)
- [Fix WebSocket Connection Failures](/claude-code-websocket-connection-failed-fix/)
- [Fix Claude Code MCP Server Connection](/claude-code-mcp-server-connection-closed-fix/)
- [Claude Code MCP Server Connection](/claude-code-mcp-server-connection-refused-fix/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
