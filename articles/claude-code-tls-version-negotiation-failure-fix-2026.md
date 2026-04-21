---
title: "TLS Version Negotiation Failure — Fix (2026)"
permalink: /claude-code-tls-version-negotiation-failure-fix-2026/
description: "Fix TLS handshake failure due to version mismatch. Ensure TLS 1.2+ is enabled in your Node.js and network configuration."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: write EPROTO 80B1070:error:0A000102:SSL routines:ssl_choose_client_version:unsupported protocol
  code: 'ERR_SSL_UNSUPPORTED_PROTOCOL'
  at TLSSocket._finishInit (node:_tls_wrap:946:8)
```

This error occurs when the TLS version negotiation fails between your client and the API server. The server requires TLS 1.2 or higher but your environment forces a lower version.

## The Fix

1. Check your Node.js TLS configuration:

```bash
node -e "console.log(require('tls').DEFAULT_MIN_VERSION)"
```

2. Force TLS 1.2 minimum:

```bash
export NODE_OPTIONS="--tls-min-v1.2"
claude "test"
```

3. If a corporate proxy downgrades TLS, bypass it:

```bash
export NO_PROXY="api.anthropic.com"
```

4. Verify TLS version in use:

```bash
openssl s_client -connect api.anthropic.com:443 </dev/null 2>/dev/null | grep "Protocol"
```

## Why This Happens

Anthropic's API requires TLS 1.2 or TLS 1.3. If your Node.js is configured with `--tls-min-v1.0` or your corporate proxy terminates TLS and re-establishes it with an older version, the handshake fails. Some older OpenSSL versions compiled into Node.js may also lack TLS 1.3 support, causing negotiation issues when the server prefers 1.3.

## If That Doesn't Work

- Check your OpenSSL version:

```bash
node -e "console.log(process.versions.openssl)"
# Needs 1.1.1+ for TLS 1.3
```

- Upgrade Node.js to get a newer OpenSSL:

```bash
nvm install 22
nvm use 22
```

- Force a specific TLS version:

```bash
export NODE_OPTIONS="--tls-max-v1.3 --tls-min-v1.2"
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# TLS Configuration
- Minimum TLS version: 1.2. Prefer TLS 1.3.
- Use Node.js 22+ which includes OpenSSL 3.x with TLS 1.3 support.
- Never set --tls-min-v1.0 in production environments.
```
