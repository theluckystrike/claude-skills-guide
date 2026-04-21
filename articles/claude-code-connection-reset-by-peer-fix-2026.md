---
title: "Connection Reset by Peer Error — Fix (2026)"
permalink: /claude-code-connection-reset-by-peer-fix-2026/
description: "Fix ECONNRESET 'connection reset by peer' during API calls. Implement retry logic and check network stability."
last_tested: "2026-04-22"
render_with_liquid: false
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
