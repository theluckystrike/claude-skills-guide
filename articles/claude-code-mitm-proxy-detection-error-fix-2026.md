---
title: "MITM Proxy Detection Error — Fix (2026)"
permalink: /claude-code-mitm-proxy-detection-error-fix-2026/
description: "Fix MITM proxy detection blocking Claude API. Verify your proxy certificate is legitimate and add it to Node CA store."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Hostname/IP does not match certificate's altnames: Host: api.anthropic.com.
is not in the cert's altnames: DNS:*.proxy.corp.com, DNS:proxy.corp.com
  code: 'ERR_TLS_CERT_ALTNAME_INVALID'
```

This error occurs when a network intermediary presents a certificate for its own domain instead of the destination domain. The SSL certificate's Subject Alternative Names (SANs) do not include api.anthropic.com.

## The Fix

1. Verify this is a legitimate corporate proxy (not an actual attack):

```bash
openssl s_client -connect api.anthropic.com:443 </dev/null 2>/dev/null | \
  openssl x509 -noout -subject -issuer
```

2. If the issuer is your corporate CA, add it to Node's trusted certs:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
```

3. If the proxy is misconfigured, bypass it for Anthropic:

```bash
export NO_PROXY="api.anthropic.com"
claude "test"
```

4. Verify the connection works:

```bash
curl -v https://api.anthropic.com/v1/messages 2>&1 | grep "SSL certificate verify"
```

## Why This Happens

Some corporate proxies perform TLS inspection but misconfigure their certificate generation. Instead of generating a certificate for each destination domain (api.anthropic.com), they present their own wildcard certificate. Node.js correctly rejects this because the certificate does not match the requested hostname. This is by design — it protects against actual MITM attacks.

## If That Doesn't Work

- Ask your IT team to fix the proxy's certificate generation for *.anthropic.com.
- Use a VPN that bypasses the corporate proxy.
- Request a proxy exception for api.anthropic.com from your network admin.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Network Security
- If cert altname errors occur, verify the issuer before bypassing.
- Set NO_PROXY=api.anthropic.com if proxy causes certificate mismatches.
- Never set NODE_TLS_REJECT_UNAUTHORIZED=0 to work around cert errors.
- Report misconfigured proxy certs to IT — they need to fix the TLS inspection.
```
