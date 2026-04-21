---
title: "Claude Code Request Timed Out 120000ms — Fix (2026)"
permalink: /claude-code-api-timeout-ms-setting-fix-2026/
description: "Increase the api_timeout setting to 300000ms with claude config set. Prevents request timeout failures on complex multi-file code operations."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Request timed out after 120000ms
```

## The Fix

```bash
# Set a longer timeout in your Claude Code settings
claude config set api_timeout 300000
```

## Why This Works

The default 120-second timeout is insufficient for complex multi-file operations or when the API is under heavy load. Setting the timeout to 300 seconds (5 minutes) gives the server enough time to process large context windows and generate lengthy responses without the client disconnecting prematurely.

## If That Doesn't Work

```bash
# Check if a proxy or VPN is adding latency
curl -o /dev/null -s -w "%{time_total}\n" https://api.anthropic.com/v1/messages
# If latency exceeds 5s, bypass proxy for Anthropic endpoints
export NO_PROXY="api.anthropic.com"
```

Network middleware (corporate proxies, VPNs, or DNS filtering) can add 10-30 seconds of overhead per request. If your base latency to Anthropic is over 5 seconds, route API traffic outside the proxy. Also confirm the timeout was saved correctly by running `claude config get api_timeout` — if it still shows the default value, you may have a read-only config file or a workspace override taking precedence.

## Prevention

Add to your CLAUDE.md:
```
API timeout is set to 300000ms. If operations on files larger than 5000 lines are needed, break them into smaller chunks rather than processing in a single request.
```
