---
title: "Claude Code ETIMEOUT Corporate Proxy"
description: "Fix Claude Code ETIMEOUT connecting through corporate proxy. Configure HTTPS_PROXY and SSL certificates. Step-by-step solution."
permalink: /claude-code-etimeout-corporate-proxy-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error: connect ETIMEDOUT 104.18.0.0:443
    at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1595:16) {
  errno: -60,
  code: 'ETIMEDOUT',
  syscall: 'connect',
  address: '104.18.0.0',
  port: 443
}

# Or:
FetchError: request to https://api.anthropic.com/v1/messages failed,
  reason: connect ECONNREFUSED 127.0.0.1:8080
```

## The Fix

1. **Set the proxy environment variables**

```bash
# Get your proxy URL from IT (common formats):
export HTTPS_PROXY="http://proxy.company.com:8080"
export HTTP_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.company.com"

# Add to shell profile for persistence:
echo 'export HTTPS_PROXY="http://proxy.company.com:8080"' >> ~/.zshrc
```

2. **If the proxy uses SSL inspection, add the corporate CA cert**

```bash
# Get the cert from your IT department, then:
export NODE_EXTRA_CA_CERTS="/path/to/corporate-ca.pem"

# Verify the cert works:
curl --proxy "$HTTPS_PROXY" https://api.anthropic.com/v1/messages
```

3. **Verify the fix:**

```bash
HTTPS_PROXY="http://proxy.company.com:8080" claude --version
# Expected: Version number without timeout error
```

## Why This Happens

Corporate networks typically route outbound traffic through a proxy server and block direct internet access at the firewall. Claude Code needs to reach `api.anthropic.com` on port 443 (HTTPS). Without the `HTTPS_PROXY` variable, Node.js tries a direct connection that the firewall drops, resulting in ETIMEDOUT after 30-60 seconds. If the proxy performs SSL/TLS inspection (MITM), it re-signs traffic with a corporate CA certificate that Node.js doesn't trust by default, causing a separate `UNABLE_TO_VERIFY_LEAF_SIGNATURE` error.

## If That Doesn't Work

- **Alternative 1:** Try the proxy with authentication: `HTTPS_PROXY="http://user:pass@proxy.company.com:8080"`
- **Alternative 2:** Ask IT to allowlist `api.anthropic.com` for direct access (bypass proxy)
- **Check:** Run `curl -v --proxy "$HTTPS_PROXY" https://api.anthropic.com` to see the full connection trace and identify where it fails

## Prevention

Add to your `CLAUDE.md`:
```markdown
On corporate networks, always set HTTPS_PROXY, HTTP_PROXY, and NODE_EXTRA_CA_CERTS before starting Claude Code. Test connectivity with curl before long sessions. Document proxy settings in project README for team members.
```

**Related articles:** [Claude Code TLS/SSL Proxy Fix](/claude-code-tls-ssl-connection-error-corporate-proxy-fix/), [Claude Code Network Proxy Config](/claude-code-network-proxy-configuration-for-enterprise/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Update Fails Behind Corporate Proxy — Fix (2026)](/claude-code-update-fails-behind-proxy-fix-2026/)
- [Self-Signed Cert in Corporate Proxy — Fix (2026)](/claude-code-self-signed-cert-corporate-proxy-fix-2026/)
