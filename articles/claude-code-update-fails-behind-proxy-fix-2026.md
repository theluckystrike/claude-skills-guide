---
title: "Update Fails Behind Corporate Proxy"
permalink: /claude-code-update-fails-behind-proxy-fix-2026/
description: "Fix Claude Code update failing behind proxy. Configure npm proxy settings and registry mirror for corporate networks."
last_tested: "2026-04-22"
render_with_liquid: false
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
