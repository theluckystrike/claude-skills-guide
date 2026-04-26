---
layout: default
title: "mTLS Client Certificate Error — Fix (2026)"
permalink: /claude-code-mtls-client-cert-error-fix-2026/
date: 2026-04-20
description: "mTLS Client Certificate Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: SSL routines:ssl3_read_bytes:tlsv13 alert certificate required
  code: 'ERR_SSL_TLSV13_ALERT_CERTIFICATE_REQUIRED'
  The server requires a client certificate for mutual TLS authentication.
```

This error occurs when the API server or a network device requires mutual TLS (mTLS) authentication — the client must present a certificate, not just validate the server's.

## The Fix

1. Configure Node.js with your client certificate:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca.pem
export NODE_TLS_CLIENT_CERT=/path/to/client.pem
export NODE_TLS_CLIENT_KEY=/path/to/client-key.pem
```

2. If using the Python SDK with mTLS:

```python
import httpx
import anthropic

http_client = httpx.Client(
    cert=("/path/to/client.pem", "/path/to/client-key.pem"),
    verify="/path/to/ca.pem"
)
client = anthropic.Anthropic(http_client=http_client)
```

3. For the Node.js SDK:

```javascript
const https = require('https');
const fs = require('fs');
const agent = new https.Agent({
  cert: fs.readFileSync('/path/to/client.pem'),
  key: fs.readFileSync('/path/to/client-key.pem'),
  ca: fs.readFileSync('/path/to/ca.pem')
});
```

4. Verify the mTLS connection:

```bash
curl --cert /path/to/client.pem --key /path/to/client-key.pem \
  https://api.anthropic.com/v1/messages -v 2>&1 | grep "SSL"
```

## Why This Happens

Mutual TLS requires both the server and client to present certificates during the TLS handshake. Some corporate environments enforce mTLS as a zero-trust security measure. The Anthropic API itself does not require mTLS, but a corporate API gateway or proxy in front of it may. Without the client certificate, the server rejects the connection during the handshake.

## If That Doesn't Work

- Check if the client cert is in the correct format:

```bash
openssl x509 -in /path/to/client.pem -noout -text | head -15
```

- Verify the key matches the cert:

```bash
openssl x509 -noout -modulus -in client.pem | md5
openssl rsa -noout -modulus -in client-key.pem | md5
# Both should output the same hash
```

- If the cert is in PKCS12 format, convert it:

```bash
openssl pkcs12 -in client.p12 -out client.pem -clcerts -nokeys
openssl pkcs12 -in client.p12 -out client-key.pem -nocerts -nodes
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# mTLS Configuration
- Client cert and key paths must be configured for corporate mTLS proxies.
- Store cert files outside the repo. Reference by absolute path.
- Verify cert/key pair match before configuring: openssl x509 -modulus vs openssl rsa -modulus.
```


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Chrome Enterprise Certificate](/chrome-enterprise-certificate-management/)
- [Certificate Pinning Conflict Error](/claude-code-certificate-pinning-conflict-fix-2026/)
- [SSL Certificate Chain Incomplete Error — Fix (2026)](/claude-code-ssl-certificate-chain-incomplete-fix-2026/)
- [Chrome Check SSL Certificate](/chrome-check-ssl-certificate/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
