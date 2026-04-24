---
title: "Certificate Pinning Conflict Error"
permalink: /claude-code-certificate-pinning-conflict-fix-2026/
description: "Fix certificate pinning failure when proxy replaces certs. Disable pinning for dev or update pins to match proxy CA."
last_tested: "2026-04-22"
render_with_liquid: false
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
