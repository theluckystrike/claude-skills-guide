---
title: "TLS Version Negotiation Failure — Fix (2026)"
permalink: /claude-code-tls-version-negotiation-failure-fix-2026/
description: "Fix TLS handshake failure due to version mismatch. Ensure TLS 1.2+ is enabled in your Node.js and network configuration."
last_tested: "2026-04-22"
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

- [CLAUDE.md Version Control Strategies](/claude-md-version-control-strategies/)
- [Claude Code for Version Matrix Workflow](/claude-code-for-version-matrix-workflow-tutorial-guide/)
- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [Claude Code for Runbook Version Control](/claude-code-for-runbook-version-control-workflow/)

## Network Configuration for Claude Code

Claude Code needs outbound HTTPS access to `api.anthropic.com` on port 443. In corporate environments, this traffic often passes through proxy servers, firewalls, or SSL inspection appliances that can interfere.

**Proxy configuration hierarchy.** Claude Code respects these environment variables in order: `HTTPS_PROXY`, `HTTP_PROXY`, `ALL_PROXY`. Set the appropriate variable before starting Claude Code:

```bash
export HTTPS_PROXY=http://proxy.company.com:8080
claude
```

**SSL certificate verification.** If your corporate network uses SSL inspection (MITM proxy), Node.js will reject the proxy's certificate. You need to add the corporate CA certificate:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
```

**DNS resolution issues.** If `api.anthropic.com` does not resolve inside your network, check with: `nslookup api.anthropic.com`. Some corporate DNS servers block external API endpoints. Contact your network team to whitelist the domain.

## Testing Network Connectivity

Run this sequence to diagnose network issues before contacting support:

```bash
# Test DNS resolution
nslookup api.anthropic.com

# Test HTTPS connectivity
curl -v https://api.anthropic.com/v1/messages 2>&1 | head -20

# Test through proxy
curl -v --proxy $HTTPS_PROXY https://api.anthropic.com/v1/messages 2>&1 | head -20

# Check for certificate issues
openssl s_client -connect api.anthropic.com:443 -servername api.anthropic.com </dev/null 2>&1 | grep -E "Verify|subject|issuer"
```
