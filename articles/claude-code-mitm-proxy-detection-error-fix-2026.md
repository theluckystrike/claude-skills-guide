---
title: "MITM Proxy Detection Error — Fix (2026)"
permalink: /claude-code-mitm-proxy-detection-error-fix-2026/
description: "MITM Proxy Detection Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
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

## See Also

- [SOCKS Proxy Not Supported Error — Fix (2026)](/claude-code-socks-proxy-not-supported-fix-2026/)

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