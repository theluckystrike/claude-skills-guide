---
title: "SSL Certificate Chain Incomplete Error — Fix (2026)"
permalink: /claude-code-ssl-certificate-chain-incomplete-fix-2026/
description: "Fix 'unable to verify the first certificate' SSL error. Add intermediate CA bundle or set NODE_EXTRA_CA_CERTS path."
last_tested: "2026-04-22"
render_with_liquid: false
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
