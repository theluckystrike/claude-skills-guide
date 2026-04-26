---
layout: default
title: "Claude Code ETIMEOUT Corporate Proxy (2026)"
description: "Fix Claude Code ETIMEOUT connecting through corporate proxy. Configure HTTPS_PROXY and SSL certificates. Step-by-step solution."
permalink: /claude-code-etimeout-corporate-proxy-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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

- [Chrome Proxy Slow — Developer Guide](/chrome-proxy-slow/)
- [MITM Proxy Detection Error — Fix (2026)](/claude-code-mitm-proxy-detection-error-fix-2026/)
- [Claude Code for Envoy Proxy Workflow](/claude-code-for-envoy-proxy-workflow-tutorial/)
- [SOCKS Proxy Not Supported Error — Fix](/claude-code-socks-proxy-not-supported-fix-2026/)

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
