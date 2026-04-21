---
title: "IPv6 Fallback Failure Error — Fix (2026)"
permalink: /claude-code-ipv6-fallback-failure-fix-2026/
description: "Fix ENETUNREACH when Node tries IPv6 first. Force IPv4 with --dns-result-order=ipv4first or disable IPv6 on the interface."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: connect ENETUNREACH 2606:4700::6810:xxxx:443
  code: 'ENETUNREACH'
  syscall: 'connect'
  address: '2606:4700::6810:xxxx'
  Falling back to IPv4... Error: connect ETIMEDOUT
```

This error occurs when Node.js tries to connect via IPv6 first, fails because your network does not support IPv6, and then the IPv4 fallback also fails or times out due to the delay.

## The Fix

1. Force Node.js to prefer IPv4:

```bash
export NODE_OPTIONS="--dns-result-order=ipv4first"
claude "test"
```

2. Make it permanent:

```bash
echo 'export NODE_OPTIONS="--dns-result-order=ipv4first"' >> ~/.zshrc
source ~/.zshrc
```

3. Alternatively, disable IPv6 at the system level on macOS:

```bash
sudo networksetup -setv6off Wi-Fi
```

4. Verify the fix:

```bash
node -e "require('dns').lookup('api.anthropic.com', (e,a,f) => console.log(a,f===4?'IPv4':'IPv6'))"
```

## Why This Happens

Modern DNS returns both IPv4 (A) and IPv6 (AAAA) records. Node.js v17+ defaults to using the order returned by the OS resolver, which often prefers IPv6. If your network has IPv6 addresses configured but no actual IPv6 connectivity (common in corporate networks and some ISPs), the IPv6 connection fails and Node must fall back to IPv4, adding latency and sometimes exceeding timeouts.

## If That Doesn't Work

- Check if IPv6 is partially broken on your network:

```bash
ping6 -c 3 api.anthropic.com 2>&1
curl -6 -v https://api.anthropic.com 2>&1 | head -10
```

- Disable IPv6 in the Node.js DNS resolver programmatically:

```javascript
const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');
```

- Re-enable IPv6 later if your network supports it: `sudo networksetup -setv6automatic Wi-Fi`

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# IPv6
- If network has broken IPv6, set NODE_OPTIONS="--dns-result-order=ipv4first".
- Test IPv6: ping6 api.anthropic.com — if unreachable, force IPv4.
- Do not disable IPv6 system-wide unless necessary; prefer Node-level override.
```
