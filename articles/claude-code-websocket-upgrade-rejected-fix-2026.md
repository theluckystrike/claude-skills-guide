---
title: "WebSocket Upgrade Rejected Error — Fix (2026)"
permalink: /claude-code-websocket-upgrade-rejected-fix-2026/
description: "Fix WebSocket upgrade rejected (HTTP 403) by proxy. Configure proxy to allow Upgrade headers for Claude Code connections."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Unexpected server response: 403
  WebSocket connection to 'wss://api.anthropic.com/v1/stream' failed
  HTTP 403 during WebSocket handshake — Upgrade header blocked by proxy
```

This error occurs when a network proxy or firewall blocks the HTTP Upgrade header required for WebSocket connections. The initial HTTP request succeeds but the protocol upgrade is rejected.

## The Fix

1. Check if WebSocket connections are blocked:

```bash
curl -v -H "Upgrade: websocket" -H "Connection: Upgrade" \
  https://api.anthropic.com 2>&1 | grep -i "upgrade\|403\|101"
```

2. If behind a proxy, configure it to allow Upgrade headers. For Squid:

```
acl SSL_ports port 443
http_access allow CONNECT SSL_ports
reply_header_access Upgrade allow all
```

3. Bypass the proxy for WebSocket connections:

```bash
export NO_PROXY="api.anthropic.com"
```

4. Fall back to HTTP long-polling instead of WebSocket:

```bash
export ANTHROPIC_TRANSPORT=http
claude "test"
```

## Why This Happens

WebSocket connections start as HTTP and then "upgrade" to a persistent bidirectional connection. Corporate proxies and firewalls often block this upgrade because they cannot inspect WebSocket traffic the same way they inspect HTTP. The proxy sends a 403 Forbidden in response to the Upgrade request header, preventing the connection from being established.

## If That Doesn't Work

- Use SSH tunneling to bypass the proxy:

```bash
ssh -D 1080 your-server.com
export ALL_PROXY=socks5://localhost:1080
```

- Check if your proxy requires WebSocket-specific authentication.
- Contact your network admin to whitelist WebSocket connections to *.anthropic.com.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# WebSocket
- If WebSocket upgrades are blocked, set ANTHROPIC_TRANSPORT=http.
- Add api.anthropic.com to NO_PROXY list in corporate environments.
- Ask network admin to allow WebSocket upgrades for *.anthropic.com.
```
