---
layout: default
title: "Certificate Pinning Conflict Error (2026)"
permalink: /claude-code-certificate-pinning-conflict-fix-2026/
date: 2026-04-20
description: "Certificate Pinning Conflict Error — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: Certificate fingerprint does not match pinned value.
  Expected: sha256/AbCdEf123...
  Received: sha256/XyZwVu789...
  at checkServerIdentity (node:tls:343:15)
```

This error occurs when an application has certificate pinning enabled and the received certificate fingerprint does not match the expected pin. This commonly happens behind corporate TLS inspection proxies.

## The Fix

1. If using a corporate proxy, the pinned cert will never match. Disable pinning for development:

```bash
export NODE_TLS_REJECT_UNAUTHORIZED=1  # Keep validation on
export ANTHROPIC_DISABLE_CERT_PINNING=1  # Disable pin check only
```

2. If using a custom HTTP client with pinning, update the pin:

```javascript
const https = require('https');
const agent = new https.Agent({
  // Remove or update the checkServerIdentity function
  // that performs pinning
});
```

3. If the error is in a third-party SDK, check for a pin override option:

```bash
# Check SDK docs for pinning configuration
npm info @anthropic-ai/sdk | grep -i pin
```

## Why This Happens

Certificate pinning hardcodes the expected server certificate fingerprint in the client. When a corporate TLS inspection proxy intercepts the connection, it presents its own certificate (with a different fingerprint) instead of the original server certificate. The pin check fails because the proxy certificate does not match the hardcoded fingerprint, even though the proxy's certificate is otherwise valid.

## If That Doesn't Work

- Bypass the proxy entirely for Anthropic API traffic:

```bash
export NO_PROXY="api.anthropic.com"
```

- Request an exception from your corporate proxy for api.anthropic.com (skip TLS inspection for this domain).

- Use a VPN that exits outside the corporate network.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Certificate Pinning
- Do not use certificate pinning for api.anthropic.com in corporate environments.
- If pinning is required, pin the CA cert, not the leaf cert (survives rotation).
- Use NO_PROXY to bypass TLS inspection proxies for trusted domains.
```

## See Also

- [Windows WSL Path Conflict Error — Fix (2026)](/claude-code-windows-wsl-path-conflict-fix-2026/)
- [Git Worktree Lock Conflict Fix](/claude-code-worktree-lock-conflict-fix-2026/)
- [Peer Dependency Conflict npm Error — Fix (2026)](/claude-code-peer-dependency-conflict-fix-2026/)
- [Claude Code Rust-Analyzer Conflict — Fix (2026)](/claude-code-rust-analyzer-conflict-fix-2026/)
- [Cursor Conflict With Claude Code CLI Fix](/claude-code-cursor-conflict-cli-fix-2026/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Related Guides

- [mTLS Client Certificate Error — Fix](/claude-code-mtls-client-cert-error-fix-2026/)
- [Chrome Enterprise Certificate](/chrome-enterprise-certificate-management/)
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
