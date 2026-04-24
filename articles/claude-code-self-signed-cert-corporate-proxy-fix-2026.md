---
title: "Self-Signed Cert in Corporate Proxy"
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

## See Also

- [Update Fails Behind Corporate Proxy — Fix (2026)](/claude-code-update-fails-behind-proxy-fix-2026/)
- [mTLS Client Certificate Error — Fix (2026)](/claude-code-mtls-client-cert-error-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `ECONNREFUSED: connection refused through proxy`
- `Error: unable to verify the first certificate`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### How do I configure Claude Code to use a corporate proxy?

Set the `HTTPS_PROXY` environment variable: `export HTTPS_PROXY=http://proxy.corp.com:8080`. Claude Code respects standard proxy environment variables. Add this to your shell profile for persistence.
