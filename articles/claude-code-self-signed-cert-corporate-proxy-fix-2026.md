---
title: "Self-Signed Cert in Corporate Proxy — Fix (2026)"
permalink: /claude-code-self-signed-cert-corporate-proxy-fix-2026/
description: "Self-Signed Cert in Corporate Proxy — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
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
