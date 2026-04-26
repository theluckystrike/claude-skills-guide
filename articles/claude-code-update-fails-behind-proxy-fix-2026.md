---
layout: default
title: "Update Fails Behind Corporate Proxy (2026)"
permalink: /claude-code-update-fails-behind-proxy-fix-2026/
date: 2026-04-20
description: "Update Fails Behind Corporate Proxy — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
npm ERR! code ETIMEDOUT
npm ERR! errno ETIMEDOUT
npm ERR! network request to https://registry.npmjs.org/@anthropic-ai/claude-code failed
npm ERR! network This is a problem related to network connectivity.
```

This error occurs when `npm update -g @anthropic-ai/claude-code` fails because the corporate proxy blocks or times out connections to the npm registry.

## The Fix

1. Configure npm to use your corporate proxy:

```bash
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

2. If the proxy requires authentication:

```bash
npm config set proxy http://username:password@proxy.company.com:8080
npm config set https-proxy http://username:password@proxy.company.com:8080
```

3. Retry the update:

```bash
npm update -g @anthropic-ai/claude-code
```

4. If the proxy uses a custom CA certificate:

```bash
npm config set cafile /path/to/corporate-ca.crt
```

## Why This Happens

Corporate networks route outbound HTTPS traffic through a proxy server for security monitoring. npm does not automatically detect proxy settings from system environment variables on all platforms. Without explicit proxy configuration, npm's requests to registry.npmjs.org time out because they cannot reach the internet directly.

## If That Doesn't Work

- Use environment variables instead of npm config:

```bash
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
npm update -g @anthropic-ai/claude-code
```

- Use a private npm registry mirror if your company has one:

```bash
npm config set registry https://npm.company.com/
```

- Download the package manually and install from tarball:

```bash
# On a machine with internet access:
npm pack @anthropic-ai/claude-code
# Transfer the .tgz file, then:
npm install -g anthropic-ai-claude-code-*.tgz
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Corporate Proxy
- Set npm proxy config: npm config set https-proxy http://proxy:8080
- Add corporate CA cert: npm config set cafile /path/to/ca.crt
- Document proxy URL in project README for new team members.
```

## See Also

- [MITM Proxy Detection Error — Fix (2026)](/claude-code-mitm-proxy-detection-error-fix-2026/)
- [Self-Signed Cert in Corporate Proxy — Fix (2026)](/claude-code-self-signed-cert-corporate-proxy-fix-2026/)
- [SOCKS Proxy Not Supported Error — Fix (2026)](/claude-code-socks-proxy-not-supported-fix-2026/)


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
- [Claude Code ETIMEOUT Corporate Proxy](/claude-code-etimeout-corporate-proxy-fix/)
- [Claude Code for Envoy Proxy Workflow](/claude-code-for-envoy-proxy-workflow-tutorial/)
- [Next.js Build Fails With Generated Code](/claude-code-nextjs-build-generated-code-fix-2026/)

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
