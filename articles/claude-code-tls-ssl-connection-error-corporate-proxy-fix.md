---
layout: default
title: "Fix Claude Code TLS/SSL Errors Behind (2026)"
description: "Resolve Claude Code TLS/SSL Errors Behind Proxy issues with tested solutions, step-by-step debugging, and production-ready code examples verified for 2026."
date: 2026-04-15
permalink: /claude-code-tls-ssl-connection-error-corporate-proxy-fix/
categories: [troubleshooting, claude-code]
tags: [tls, ssl, proxy, corporate, NODE_EXTRA_CA_CERTS]
last_modified_at: 2026-04-17
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix Claude Code TLS/SSL Errors Behind Corporate Proxy

## The Error

When installing or running Claude Code behind a corporate proxy, you see one of these errors:

```text
curl: (35) TLS connect error
```

```text
unable to get local issuer certificate
```

```text
schannel: next InitializeSecurityContext failed
```

```text
Could not establish trust relationship for the SSL/TLS secure channel
```

## Quick Fix

Set the `NODE_EXTRA_CA_CERTS` environment variable to point to your corporate CA certificate bundle:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
claude
```

If you do not have the certificate file, ask your IT team for the corporate CA bundle, or check your browser's certificate settings.

## What's Happening

Corporate proxies that perform TLS inspection replace the upstream server's certificate with their own, signed by a corporate certificate authority. Your operating system and browser trust this CA because IT installed it in the system certificate store. However, Node.js (which Claude Code uses internally) maintains its own certificate store and does not automatically trust system-level certificates.

When Claude Code makes HTTPS requests to Anthropic's API or to `storage.googleapis.com` during installation, the corporate proxy's certificate appears untrusted because Node.js cannot verify the corporate CA that signed it. This breaks the TLS handshake.

The `NODE_EXTRA_CA_CERTS` environment variable tells Node.js to trust additional certificate authorities beyond its built-in bundle.

## Step-by-Step Fix

### Step 1: Identify the proxy certificate

Determine if you are behind a TLS-inspecting proxy. Check your proxy environment variables:

```bash
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

If these are set, you are using a proxy. The TLS error confirms it is performing inspection.

### Step 2: Get the corporate CA certificate

Ask your IT team for the corporate root CA certificate in PEM format. Common locations where it may already exist:

```bash
# macOS - export from Keychain
security find-certificate -a -p /Library/Keychains/System.keychain > /tmp/corp-ca.pem

# Linux - common locations
ls /etc/ssl/certs/
ls /usr/local/share/ca-certificates/
```

### Step 3: Set NODE_EXTRA_CA_CERTS

Point the variable to your corporate CA certificate file:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
```

Add this to your shell configuration for persistence:

```bash
# macOS
echo 'export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem' >> ~/.zshrc

# Linux
echo 'export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem' >> ~/.bashrc
```

### Step 4: Set proxy environment variables

If not already set, configure proxy variables so Claude Code can route traffic through the proxy:

```bash
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### Step 5: Configure proxy in Claude Code settings

For persistence across all sessions, add the environment variables to your Claude Code settings:

```json
{
 "env": {
 "NODE_EXTRA_CA_CERTS": "/path/to/corporate-ca.pem",
 "HTTP_PROXY": "http://proxy.example.com:8080",
 "HTTPS_PROXY": "http://proxy.example.com:8080"
 }
}
```

Save this to `~/.claude/settings.json` so it applies to every project.

### Step 6: Fix installation-time TLS errors

If the error occurs during installation rather than runtime, set the variables before running the installer:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
export HTTPS_PROXY=http://proxy.example.com:8080
curl -fsSL https://claude.ai/install.sh | bash
```

Alternatively, install via Homebrew or WinGet, which use system certificate stores:

```bash
brew install --cask claude-code
```

### Step 7: Windows-specific TLS fixes

On Windows, enable TLS 1.2 in PowerShell before installing:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
irm https://claude.ai/install.ps1 | iex
```

If you see `CRYPT_E_NO_REVOCATION_CHECK` or `CRYPT_E_REVOCATION_OFFLINE`, your network blocks certificate revocation lookups. Use:

```bat
curl --ssl-revoke-best-effort -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

## Prevention

For teams behind corporate proxies, create a shared Claude Code settings file with the correct proxy and certificate configuration:

```json
{
 "env": {
 "NODE_EXTRA_CA_CERTS": "/path/to/corporate-ca.pem",
 "HTTPS_PROXY": "http://proxy.example.com:8080"
 }
}
```

Distribute this as a managed settings file to standardize the configuration across all developers. On macOS, managed settings go in `/Library/Application Support/ClaudeCode/managed-settings.json`. On Linux, use `/etc/claude-code/managed-settings.json`.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-tls-ssl-connection-error-corporate-proxy-fix)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)
- [Anthropic API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)

## See Also

- [Update Fails Behind Corporate Proxy — Fix (2026)](/claude-code-update-fails-behind-proxy-fix-2026/)
- [Self-Signed Cert in Corporate Proxy — Fix (2026)](/claude-code-self-signed-cert-corporate-proxy-fix-2026/)
- [TLS Version Negotiation Failure — Fix (2026)](/claude-code-tls-version-negotiation-failure-fix-2026/)
- [HTTP/2 Stream Error During Request -- Fix (2026)](/claude-code-http2-stream-error-fix-2026/)
