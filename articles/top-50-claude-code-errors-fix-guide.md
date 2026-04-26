---
layout: default
title: "Top 50 Claude Code Errors and How to Fix Them (2026)"
description: "Complete reference of the 50 most common Claude Code errors with exact fixes. Covers auth failures, context overflow, permission errors, and network timeouts."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /top-50-claude-code-errors-fix-guide/
reviewed: true
categories: [troubleshooting]
tags: [claude, claude-code, errors, debugging, diagnostics]
---

# Top 50 Claude Code Errors and How to Fix Them

Every Claude Code session eventually hits an error. Some are obvious typos in configuration. Others are cryptic messages that send you searching for 30 minutes before you find the one flag that fixes it. This reference catalogs the 50 most frequent errors Claude Code users encounter, organized by category, with the exact terminal command or config change that resolves each one. If you need instant diagnosis, the [Error Diagnostic Tool](/diagnose/) identifies your specific error and returns a fix in seconds.

## Authentication and API Key Errors (1-10)

These errors fire before Claude Code can even start processing your request. They almost always trace back to missing, expired, or malformed API keys.

**1. `Invalid API key provided`** — Your `ANTHROPIC_API_KEY` environment variable is missing or wrong. Verify it:

```bash
echo $ANTHROPIC_API_KEY | head -c 10
# Should start with "sk-ant-"
```

**2. `API key expired`** — Anthropic keys do not expire on their own, but organization admins can rotate them. Generate a new key at console.anthropic.com and update your shell profile.

**3. `Authentication failed: 401 Unauthorized`** — The key is syntactically valid but rejected by the API. Check that you are using the correct organization. Run `claude config list` to verify.

**4. `Rate limit exceeded (429)`** — You have sent too many requests. Wait 60 seconds and retry. If persistent, check your plan tier limits with the [Cost Calculator](/calculator/).

**5. `Organization quota exceeded`** — Your org has hit its monthly spending cap. An admin must raise the limit in the Anthropic dashboard.

**6. `Permission denied: API key lacks required scope`** — Some keys are scoped to specific models. Ensure your key has access to the model you selected.

**7. `ANTHROPIC_API_KEY not set`** — Add `export ANTHROPIC_API_KEY="sk-ant-..."` to `~/.zshrc` or `~/.bashrc`, then `source` the file.

**8. `SSL certificate verification failed`** — Corporate proxies intercept HTTPS. Set `NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem` in your environment.

**9. `Proxy authentication required (407)`** — Configure `HTTPS_PROXY` with credentials: `export HTTPS_PROXY="http://user:pass@proxy:8080"`.

**10. `Connection refused to api.anthropic.com`** — Firewall or DNS issue. Test with `curl -I https://api.anthropic.com`. If blocked, allowlist the domain.

## Context and Token Errors (11-20)

Context window errors happen when your conversation or project grows beyond what the model can process in a single turn.

**11. `Context window exceeded`** — Your conversation plus project files exceed the model limit (200K tokens for Sonnet/Opus). Run `/compact` to compress the conversation history.

**12. `Message too long`** — A single message exceeds the input limit. Break your prompt into smaller pieces or reference files by path instead of pasting content.

**13. `Token budget exhausted for this session`** — On Pro/Max plans, session token limits apply. Start a new session with `claude --new`.

**14. `Output truncated at max_tokens`** — The response hit the output token ceiling. Re-run with `--max-tokens 16384` or ask Claude to continue.

**15. `Input token count estimation failed`** — Malformed input, usually from binary file content. Add the file to `.claudeignore`.

**16. `Conversation history too large to compact`** — Even `/compact` cannot compress below the limit. Start a fresh session and load only the files you need.

**17. `Tool result too large (>100KB)`** — A tool returned too much data. Pipe output through `head` or `tail` before passing it back.

**18. `System prompt exceeds 8192 tokens`** — Your `CLAUDE.md` is too large. Trim unused instructions. Use the [Error Diagnostic Tool](/diagnose/) to audit your configuration size.

**19. `Embedding context retrieval failed`** — The codebase index is corrupted. Delete `.claude/index` and let it rebuild.

**20. `Maximum conversation turns reached`** — Anthropic limits turns per session. Start a new session.

## Permission and File System Errors (21-30)

These errors appear when Claude Code tries to read, write, or execute files it cannot access.

**21. `Permission denied: cannot read file`** — The file has restrictive permissions. Fix with `chmod 644 filename`.

**22. `EACCES: permission denied, mkdir`** — Node.js cannot create a directory. Check ownership with `ls -la` and fix with `sudo chown -R $(whoami) .`.

**23. `File not found: CLAUDE.md`** — Claude Code expects a project file. Create one with `touch CLAUDE.md` or run `claude init`.

**24. `Cannot write to read-only file system`** — You are in a read-only container or volume. Remount with write access or change the output directory.

**25. `ENOSPC: no space left on device`** — Disk is full. Free space with `df -h` to diagnose, then clean temp files.

**26. `Too many open files (EMFILE)`** — Increase the ulimit: `ulimit -n 4096`.

**27. `Symbolic link loop detected`** — A symlink points to itself. Find it with `find . -type l -exec test ! -e {} \; -print`.

**28. `.claudeignore pattern error`** — Invalid glob syntax in your ignore file. Test patterns with `git check-ignore -v filename`.

**29. `Workspace path contains invalid characters`** — Spaces or special characters in your project path. Move the project or use quotes around the path.

**30. `Git repository not found`** — Claude Code expected a git repo. Initialize one with `git init` or navigate to the correct directory.

## Network and Connection Errors (31-40)

Network errors occur between your machine and the Anthropic API.

**31. `ETIMEDOUT: connection timed out`** — Slow network or overloaded API. Retry after 30 seconds.

**32. `ECONNRESET: connection reset by peer`** — The server closed the connection mid-stream. This is transient; retry.

**33. `DNS resolution failed for api.anthropic.com`** — DNS misconfigured. Try `nslookup api.anthropic.com` and switch to `8.8.8.8` if needed.

**34. `WebSocket connection failed`** — Streaming mode requires persistent connections. Check if your proxy supports WebSocket upgrades.

**35. `Request aborted: timeout after 300s`** — Long-running requests exceed the timeout. Break the task into smaller steps.

**36. `HTTP 502 Bad Gateway`** — Anthropic infrastructure issue. Check status.anthropic.com and wait.

**37. `HTTP 503 Service Unavailable`** — API is temporarily overloaded. Implement exponential backoff.

**38. `Streaming response interrupted`** — Partial response received. The API will resume if you retry the same message.

**39. `TLS handshake failed`** — Old TLS version. Ensure Node.js 18+ is installed: `node --version`.

**40. `Response body exceeded size limit`** — API returned more data than the client can buffer. Update Claude Code to the latest version.

## Model and MCP Errors (41-50)

These relate to model selection, MCP server configuration, and tool execution.

**41. `Model not available: claude-opus-4`** — Your plan may not include Opus. Check access at [plan comparison](/claude-code-pro-vs-max-vs-api-plan-comparison/).

**42. `MCP server failed to start`** — The MCP configuration in `claude_desktop_config.json` has a syntax error. Validate JSON with `cat ~/.claude/config.json | python3 -m json.tool`.

**43. `MCP tool execution timeout`** — The MCP tool took longer than the allowed window. Increase the timeout in your MCP server config.

**44. `Tool not found in current context`** — The skill or tool is not installed. Use the [Skill Finder](/skill-finder/) to locate and install it.

**45. `Bash tool execution failed`** — A command returned a non-zero exit code. Check the command manually in your terminal.

**46. `Node version mismatch`** — Claude Code requires Node.js 18+. Update with `nvm install 18 && nvm use 18`.

**47. `Config file parse error`** — Invalid JSON or YAML in your configuration. Run `claude config validate`.

**48. `Hook execution failed`** — A pre/post hook script errored. Check the hook file permissions and syntax.

**49. `Memory file corrupted`** — Delete `~/.claude/memory` and restart. Claude Code will rebuild it.

**50. `Update required: version too old`** — Run `npm update -g @anthropic-ai/claude-code` to get the latest version.

## Try It Yourself

Stop scrolling through error lists manually. The **[Error Diagnostic Tool](/diagnose/)** identifies your exact error in seconds -- paste your error message, get the fix, prevention rules, and recommended CLAUDE.md configuration changes instantly.

**[Try the Diagnostic Tool -->](/diagnose/)**

## Common Questions

<details><summary>Where do Claude Code error logs live on macOS?</summary>
Claude Code stores logs in <code>~/.claude/logs/</code>. Each session gets its own log file with timestamps. Use <code>ls -lt ~/.claude/logs/ | head -5</code> to find the most recent.
</details>

<details><summary>How do I fix "context window exceeded" without losing my conversation?</summary>
Run <code>/compact</code> inside Claude Code. This compresses the conversation history while preserving key context. If that is not enough, start a new session and paste a summary of your previous work.
</details>

<details><summary>What does HTTP 429 mean in Claude Code?</summary>
HTTP 429 is a rate limit error. You have sent too many API requests in a short window. Wait 60 seconds, then retry. If you consistently hit this, consider upgrading your plan tier.
</details>

<details><summary>Can I use Claude Code behind a corporate proxy?</summary>
Yes. Set the <code>HTTPS_PROXY</code> environment variable and, if your proxy uses custom certificates, set <code>NODE_EXTRA_CA_CERTS</code> to your CA bundle path.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Where do Claude Code error logs live on macOS?","acceptedAnswer":{"@type":"Answer","text":"Claude Code stores logs in ~/.claude/logs/. Each session gets its own log file with timestamps. Use ls -lt ~/.claude/logs/ | head -5 to find the most recent."}},
{"@type":"Question","name":"How do I fix context window exceeded without losing my conversation?","acceptedAnswer":{"@type":"Answer","text":"Run /compact inside Claude Code. This compresses the conversation history while preserving key context. If that is not enough, start a new session and paste a summary of your previous work."}},
{"@type":"Question","name":"What does HTTP 429 mean in Claude Code?","acceptedAnswer":{"@type":"Answer","text":"HTTP 429 is a rate limit error. You have sent too many API requests in a short window. Wait 60 seconds, then retry. If you consistently hit this, consider upgrading your plan tier."}},
{"@type":"Question","name":"Can I use Claude Code behind a corporate proxy?","acceptedAnswer":{"@type":"Answer","text":"Yes. Set the HTTPS_PROXY environment variable and, if your proxy uses custom certificates, set NODE_EXTRA_CA_CERTS to your CA bundle path."}}
]}
</script>



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

- [Why Claude Code Keeps Crashing: Root Causes](/why-claude-code-keeps-crashing-root-causes/)
- [Claude Code Error Messages Dictionary](/claude-code-error-messages-dictionary/)
- [Error Handling Guide](/error-handling/)
- [Troubleshooting Guide](/troubleshooting/)
- [Error Diagnostic Tool](/diagnose/) -- instant error lookup
