---
title: "SOCKS Proxy Not Supported Error — Fix"
permalink: /claude-code-socks-proxy-not-supported-fix-2026/
description: "Fix 'SOCKS proxy not supported' in Claude Code. Install socks-proxy-agent or switch to HTTP proxy for API connections."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: SOCKS proxy not supported by default HTTP agent.
  Set ALL_PROXY=socks5://localhost:1080 but Node.js does not support SOCKS natively.
  Install a SOCKS-compatible agent: npm install socks-proxy-agent
```

This error occurs when you configure a SOCKS proxy (common with SSH tunnels and Tor) but Node.js's default HTTP agent does not support the SOCKS protocol.

## The Fix

1. Install the SOCKS proxy agent globally:

```bash
npm install -g socks-proxy-agent
```

2. Switch to an HTTP proxy instead of SOCKS if possible:

```bash
# Instead of SOCKS5:
# export ALL_PROXY=socks5://localhost:1080

# Use HTTP CONNECT proxy:
export HTTPS_PROXY=http://localhost:8080
```

3. If you must use SOCKS (SSH tunnel), create an HTTP proxy bridge:

```bash
# Start SSH tunnel with HTTP proxy using socat
ssh -D 1080 your-server.com &

# Use a local HTTP-to-SOCKS bridge
npx proxy-chain -p 8080 -s socks5://localhost:1080 &
export HTTPS_PROXY=http://localhost:8080
claude "test"
```

## Why This Happens

Node.js's built-in `http` and `https` modules only support HTTP CONNECT proxies natively. SOCKS4/SOCKS5 proxies use a different protocol that requires a third-party agent. Setting `ALL_PROXY` or `SOCKS_PROXY` to a `socks5://` URL does not work without additional packages because Node does not parse or handle the SOCKS handshake.

## If That Doesn't Work

- Use an SSH port forward instead of SOCKS:

```bash
ssh -L 8443:api.anthropic.com:443 your-server.com &
# Then connect to localhost:8443 instead
```

- Use `proxychains` to transparently SOCKS-ify all connections:

```bash
# Install proxychains
brew install proxychains-ng
# Configure /usr/local/etc/proxychains.conf
proxychains4 claude "test"
```

- Check that your SOCKS proxy is actually running:

```bash
curl --socks5 localhost:1080 https://api.anthropic.com 2>&1 | head -5
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Proxy Configuration
- Use HTTP proxies (HTTPS_PROXY) not SOCKS for Claude Code.
- If SOCKS is required, use a local HTTP-to-SOCKS bridge.
- SSH tunnels: prefer -L (port forward) over -D (SOCKS) for single hosts.
```
