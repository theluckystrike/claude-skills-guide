---
title: "Self-Signed Cert in Corporate Proxy — Fix (2026)"
permalink: /claude-code-self-signed-cert-corporate-proxy-fix-2026/
description: "Fix SELF_SIGNED_CERT_IN_CHAIN error behind corporate proxy. Export proxy CA cert and set NODE_EXTRA_CA_CERTS."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: self-signed certificate in certificate chain
  code: 'SELF_SIGNED_CERT_IN_CHAIN'
  at TLSSocket.onConnectSecure (node:_tls_wrap:1530:34)
```

This error occurs when your corporate network intercepts HTTPS traffic with a TLS inspection proxy that uses a self-signed or internal CA certificate that Node.js does not trust.

## The Fix

1. Export the corporate proxy CA certificate on macOS:

```bash
security find-certificate -a -p /Library/Keychains/System.keychain | \
  awk '/BEGIN/,/END/' > ~/corp-proxy-ca.pem
```

2. On Linux, find the corporate cert:

```bash
cp /usr/local/share/ca-certificates/corp-proxy.crt ~/corp-proxy-ca.pem
```

3. Tell Node.js to trust it:

```bash
export NODE_EXTRA_CA_CERTS=~/corp-proxy-ca.pem
echo 'export NODE_EXTRA_CA_CERTS=~/corp-proxy-ca.pem' >> ~/.zshrc
```

4. Test Claude Code:

```bash
source ~/.zshrc
claude "hello"
```

## Why This Happens

Corporate TLS inspection proxies (Zscaler, BlueCoat, Palo Alto) decrypt and re-encrypt all HTTPS traffic using their own CA certificate. The OS trusts this CA (IT installed it in the system keychain), but Node.js has its own CA store that does not include it. Every HTTPS connection from Node fails because it sees a certificate signed by an unknown CA.

## If That Doesn't Work

- Identify exactly which CA is missing:

```bash
openssl s_client -connect api.anthropic.com:443 -proxy proxy.company.com:8080 </dev/null 2>/dev/null | openssl x509 -noout -issuer
```

- Combine the proxy CA with the default Node CA bundle:

```bash
node -e "console.log(require('tls').rootCertificates.length + ' certs in store')"
```

- Configure npm to also use the corporate cert:

```bash
npm config set cafile ~/corp-proxy-ca.pem
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Corporate Network
- NODE_EXTRA_CA_CERTS must point to the corporate proxy CA cert.
- Ask IT for the CA cert file if not in /Library/Keychains/System.keychain.
- Test with: curl -v https://api.anthropic.com 2>&1 | grep "SSL certificate"
```
