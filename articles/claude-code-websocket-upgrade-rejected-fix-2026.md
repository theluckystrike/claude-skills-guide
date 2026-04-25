---
title: "WebSocket Upgrade Rejected Error — Fix"
permalink: /claude-code-websocket-upgrade-rejected-fix-2026/
description: "Fix WebSocket upgrade rejected (HTTP 403) by proxy. Configure proxy to allow Upgrade headers for Claude Code connections."
last_tested: "2026-04-22"
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

## See Also

- [Codespaces WebSocket Disconnect Fix](/claude-code-codespaces-websocket-disconnect-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ECONNREFUSED: connection refused through proxy`
- `Error: unable to verify the first certificate`
- `SELF_SIGNED_CERT_IN_CHAIN`
- `UNABLE_TO_VERIFY_LEAF_SIGNATURE`
- `CERT_HAS_EXPIRED`

## Frequently Asked Questions

### How do I configure Claude Code to use a corporate proxy?

Set the `HTTPS_PROXY` environment variable: `export HTTPS_PROXY=http://proxy.corp.com:8080`. Claude Code respects standard proxy environment variables. Add this to your shell profile for persistence.

### Why does my proxy cause SSL errors?

Corporate proxies often perform TLS inspection by re-signing certificates with an internal CA. Node.js does not trust these CAs by default. Set `NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem` to add your proxy's CA certificate to the trust chain.

### Can I bypass the proxy for Anthropic endpoints only?

Yes. Set `NO_PROXY=api.anthropic.com` to route Anthropic API traffic directly while keeping the proxy for other traffic. This avoids TLS inspection issues specific to the API connection.

### What does 'unable to verify the first certificate' mean?

This error means Node.js cannot build a complete certificate chain from the server certificate to a trusted root CA. The most common cause is a corporate proxy performing TLS inspection with a self-signed CA certificate that Node.js does not trust.


## Related Guides

- [Build WebSocket Apps with Claude Code](/claude-code-skills-websocket-real-time-app-development/)
- [Fix WebSocket Connection Failures](/claude-code-websocket-connection-failed-fix/)
- [Claude Code for WebSocket Realtime Apps](/claude-skills-for-websocket-realtime-app-development/)
- [Claude Code for tRPC WebSocket Workflow](/claude-code-for-trpc-websocket-workflow-guide/)

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
