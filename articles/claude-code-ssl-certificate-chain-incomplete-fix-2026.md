---
title: "SSL Certificate Chain Incomplete Error"
permalink: /claude-code-ssl-certificate-chain-incomplete-fix-2026/
description: "Claude Code troubleshooting: sSL Certificate Chain Incomplete Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions..."
last_tested: "2026-04-22"
---

## The Error

```
Error: unable to verify the first certificate
  code: 'UNABLE_TO_VERIFY_LEAF_SIGNATURE'
  at TLSSocket.onConnectSecure (node:_tls_wrap:1530:34)
  connecting to: https://api.anthropic.com
```

This error occurs when the SSL certificate chain is incomplete — the server sends its certificate but not the intermediate certificates needed to verify the chain back to a trusted root CA.

## The Fix

1. Download and set the intermediate CA bundle:

```bash
# Download Mozilla's CA bundle
curl -o /tmp/cacert.pem https://curl.se/ca/cacert.pem
export NODE_EXTRA_CA_CERTS=/tmp/cacert.pem
claude "test"
```

2. Make it permanent:

```bash
echo 'export NODE_EXTRA_CA_CERTS=/tmp/cacert.pem' >> ~/.zshrc
source ~/.zshrc
```

3. If behind a corporate proxy, export the proxy's CA cert:

```bash
# Export from macOS Keychain
security find-certificate -a -p /Library/Keychains/System.keychain > /tmp/corp-ca.pem
export NODE_EXTRA_CA_CERTS=/tmp/corp-ca.pem
```

## Why This Happens

Node.js uses its own CA certificate store, separate from the operating system. When a corporate proxy terminates and re-signs SSL connections (TLS inspection), the proxy's CA certificate is not in Node's store. The connection appears to have an incomplete chain because Node cannot find the intermediate CA that signed the proxy's certificate.

## If That Doesn't Work

- Temporarily disable SSL verification (development only, never in production):

```bash
export NODE_TLS_REJECT_UNAUTHORIZED=0
claude "test"
# Remember to unset after testing:
unset NODE_TLS_REJECT_UNAUTHORIZED
```

- Check the actual certificate chain:

```bash
openssl s_client -connect api.anthropic.com:443 -showcerts </dev/null 2>/dev/null | grep "Certificate chain" -A 20
```

- Ask your IT team for the corporate CA certificate file.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# SSL/TLS
- Set NODE_EXTRA_CA_CERTS for corporate environments with TLS inspection.
- Never set NODE_TLS_REJECT_UNAUTHORIZED=0 in production.
- Document corporate CA cert path in team onboarding docs.
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

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

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
