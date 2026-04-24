---
title: "HTTP/2 Stream Error During Request — Fix (2026)"
permalink: /claude-code-http2-stream-error-fix-2026/
description: "Fix HTTP/2 stream error (NGHTTP2_INTERNAL_ERROR). Force HTTP/1.1 or increase stream limits to resolve multiplexing issues."
last_tested: "2026-04-22"
---

## The Error

```
Error: Stream closed with error code NGHTTP2_INTERNAL_ERROR
  code: 'ERR_HTTP2_STREAM_ERROR'
  at ClientHttp2Stream._destroy (node:internal/http2/core:251:13)
```

This error occurs when an HTTP/2 stream fails during an API request. The multiplexed connection encounters an internal error, typically from a network intermediary that does not properly handle HTTP/2.

## The Fix

1. Force HTTP/1.1 for Anthropic API calls:

```bash
export ANTHROPIC_HTTP_VERSION=1.1
claude "test"
```

2. Or set it globally for Node.js:

```bash
export NODE_OPTIONS="--http-parser=legacy"
```

3. If using the Python SDK, disable HTTP/2:

```python
import httpx
import anthropic

http_client = httpx.Client(http2=False)
client = anthropic.Anthropic(http_client=http_client)
```

4. Verify the fix:

```bash
claude "count to 5"
```

## Why This Happens

HTTP/2 multiplexes multiple requests over a single TCP connection using streams. When a network device (corporate proxy, load balancer, CDN) does not fully support HTTP/2 or has stream limits, individual streams can fail with internal errors. The proxy may accept the HTTP/2 connection but fail to properly forward the stream frames to the origin server.

## If That Doesn't Work

- Check if your proxy supports HTTP/2:

```bash
curl -v --http2 https://api.anthropic.com 2>&1 | grep "HTTP/2"
```

- Reset the HTTP/2 connection pool:

```bash
# Kill all Claude Code processes to reset connections
pkill -f "claude"
claude "test"
```

- If using nginx as reverse proxy, increase the stream limit:

```nginx
http2_max_concurrent_streams 128;
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# HTTP/2
- If behind a corporate proxy, force HTTP/1.1: export ANTHROPIC_HTTP_VERSION=1.1
- HTTP/2 stream errors are usually proxy issues, not API issues.
- Test with curl --http2 to verify HTTP/2 support before enabling.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `ECONNREFUSED: connection refused through proxy`
- `Error: unable to verify the first certificate`
- `SELF_SIGNED_CERT_IN_CHAIN`
- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`

## Frequently Asked Questions

### How do I configure Claude Code to use a corporate proxy?

Set the `HTTPS_PROXY` environment variable: `export HTTPS_PROXY=http://proxy.corp.com:8080`. Claude Code respects standard proxy environment variables. Add this to your shell profile for persistence.

### Why does my proxy cause SSL errors?

Corporate proxies often perform TLS inspection by re-signing certificates with an internal CA. Node.js does not trust these CAs by default. Set `NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem` to add your proxy's CA certificate to the trust chain.

### Can I bypass the proxy for Anthropic endpoints only?

Yes. Set `NO_PROXY=api.anthropic.com` to route Anthropic API traffic directly while keeping the proxy for other traffic. This avoids TLS inspection issues specific to the API connection.

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated Fix — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Step-by-Step Debugging Process

When you encounter pipe-related errors in Claude Code, follow this systematic debugging approach:

**Step 1: Identify the failing command.** Check the error output for the command that triggered the failure. The stack trace shows which process wrote to the closed pipe.

**Step 2: Check command output size.** Run the command alone (without piping) and check output size with `wc -l`. If the output exceeds 10,000 lines, it needs buffering or file redirection.

**Step 3: Replace pipes with file intermediaries.** Instead of `command1 | command2`, use `command1 > /tmp/intermediate.txt && command2 < /tmp/intermediate.txt`. This eliminates pipe buffer pressure entirely.

**Step 4: Set appropriate timeouts.** Long-running commands need matching timeout values. Check `CLAUDE_CODE_BASH_TIMEOUT` and ensure it exceeds the expected command duration by at least 50%.

**Step 5: Verify the fix under load.** Run the full workflow three times consecutively to confirm the error does not recur under typical conditions.


## Common Scenarios That Trigger This Error

**Large repository searches.** Running `grep -r` or `find` across a repository with 50,000+ files produces output faster than the pipe consumer can process it. Use `--max-count` or `-maxdepth` to limit output volume.

**Build output during CI.** Build tools like webpack, tsc, and esbuild produce verbose output during compilation. If Claude Code's process supervisor terminates the build mid-output, the pipe breaks. Redirect build output to a log file.

**Streaming API responses.** When Claude Code processes long streaming responses and the connection is interrupted (timeout, network drop), the write side of the stream receives EPIPE. Implement proper stream error handlers with `.on('error', handler)`.

**Parallel tool execution.** Claude Code may run multiple bash commands simultaneously. If system pipe buffer capacity (typically 64KB on macOS, 65KB on Linux) is exhausted across all concurrent pipes, writes block and eventually fail.
