---
layout: default
title: "Why Claude Code Keeps Crashing: 10 Root Causes (2026)"
description: "Claude Code crashing repeatedly? Diagnose the exact cause from these 10 root causes: OOM, context overflow, API issues, MCP failures, and more with fixes."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /why-claude-code-keeps-crashing-root-causes/
reviewed: true
categories: [troubleshooting]
tags: [claude, claude-code, crashes, debugging, stability]
---

# Why Claude Code Keeps Crashing: 10 Root Causes

Claude Code crashing mid-session is one of the most frustrating developer experiences. You have spent 10 minutes building context, Claude is halfway through a complex refactor, and the process terminates without warning. The fix depends entirely on the root cause, and there are exactly 10 reasons this happens. This guide walks through each one with specific diagnostic commands and permanent fixes. For instant diagnosis, paste your crash output into the [Error Diagnostic Tool](/diagnose/) and get the answer in seconds.

## 1. Out of Memory (OOM Kill)

The most common crash cause. Claude Code's Node.js process consumes memory proportional to conversation length, loaded files, and tool outputs. When your system runs low, the OS kills the process.

**Diagnose it:**

```bash
# Check if OOM killed the process (macOS)
log show --predicate 'eventMessage contains "killed"' --last 5m

# Check current memory pressure
memory_pressure
```

**Fix it:** Close memory-heavy applications. If the problem recurs, increase Node.js heap size:

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
```

Add this to your shell profile so it persists across sessions.

## 2. Context Window Overflow

When the accumulated conversation (system prompt + messages + tool results) exceeds the model's context window (200K tokens for Opus/Sonnet), Claude Code terminates the request. If the client does not handle this gracefully, it crashes.

**Diagnose it:** Watch for `context window exceeded` or `token limit` in the error output. Check your CLAUDE.md size:

```bash
wc -c CLAUDE.md
# If over 15,000 characters, it is consuming too much context
```

**Fix it:** Run `/compact` regularly during long sessions. Add large files to `.claudeignore` so they are not auto-loaded. Keep CLAUDE.md under 4,000 tokens.

## 3. Network Timeout During Streaming

Claude Code uses streaming responses. If your network drops mid-stream (VPN reconnect, Wi-Fi switch, proxy timeout), the WebSocket connection breaks and the process may crash.

**Diagnose it:**

```bash
# Test connection stability
curl -w "time_total: %{time_total}\n" -o /dev/null -s https://api.anthropic.com
```

**Fix it:** Use a stable wired connection for long sessions. If behind a proxy, ensure it supports long-lived WebSocket connections. Set `--timeout 600` for extended operations.

## 4. API Key Issues Mid-Session

Your API key can become invalid during a session if an admin rotates keys, your organization changes billing, or the key is revoked. Claude Code does not always recover gracefully from mid-session auth failures.

**Diagnose it:** Look for `401 Unauthorized` or `403 Forbidden` in the crash output. Verify your key:

```bash
curl -H "x-api-key: $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"test"}]}' \
  -H "content-type: application/json" -H "anthropic-version: 2023-06-01"
```

**Fix it:** Generate a new API key and update your environment variables. Use the [Cost Calculator](/calculator/) to verify your plan is active.

## 5. Permission Denied on Critical Files

Claude Code needs read/write access to its configuration directory (`~/.claude/`), your project directory, and temporary file locations. If permissions change (e.g., after a system update or running `sudo` commands), crashes follow.

**Diagnose it:**

```bash
ls -la ~/.claude/
ls -la /tmp/claude-*
```

**Fix it:**

```bash
sudo chown -R $(whoami) ~/.claude/
chmod -R 755 ~/.claude/
```

## 6. MCP Server Crash

If you have configured MCP (Model Context Protocol) servers, a crash in any connected MCP server propagates back to Claude Code. Common causes: the MCP server process exits, returns malformed JSON, or exceeds its memory allocation.

**Diagnose it:**

```bash
# Check MCP server status
claude mcp list
# Look for servers marked as "disconnected" or "error"
```

**Fix it:** Restart the failing MCP server independently. Check its logs for errors. If using a community MCP server, update to the latest version. Remove unstable servers from your [MCP configuration](/mcp-config/) temporarily.

## 7. Corrupted Configuration Files

`~/.claude/config.json`, `CLAUDE.md`, or `.claude/settings.json` can become corrupted from partial writes, concurrent access, or manual editing mistakes. A single missing comma in JSON crashes the parser.

**Diagnose it:**

```bash
python3 -m json.tool ~/.claude/config.json
# If this fails, the config is malformed
```

**Fix it:** Back up and regenerate the config:

```bash
cp ~/.claude/config.json ~/.claude/config.json.bak
claude config reset
```

## 8. Node.js Version Mismatch

Claude Code requires Node.js 18 or later. Running on Node 16 or earlier causes crashes from missing APIs (`structuredClone`, `fetch`, newer V8 features).

**Diagnose it:**

```bash
node --version
# Must be v18.0.0 or higher
```

**Fix it:**

```bash
nvm install 20
nvm use 20
npm install -g @anthropic-ai/claude-code
```

## 9. Disk Full

When `/tmp` or your home directory fills up, Claude Code cannot write session data, logs, or intermediate files. This causes silent crashes.

**Diagnose it:**

```bash
df -h /tmp ~
```

**Fix it:** Free disk space. Claude Code session data lives in `~/.claude/` -- old sessions can be cleaned:

```bash
# Remove sessions older than 7 days
find ~/.claude/sessions -mtime +7 -delete
```

## 10. Rate Limiting Cascade

Hitting rate limits (HTTP 429) repeatedly can cause Claude Code to enter a retry loop that eventually exhausts resources or hits a maximum retry count, resulting in a crash rather than a graceful error.

**Diagnose it:** Look for repeated `429 Too Many Requests` in the output. Check your usage against plan limits.

**Fix it:** Wait 5 minutes before retrying. If you consistently hit limits, your [plan may need upgrading](/claude-code-pro-vs-max-vs-api-plan-comparison/). Use the [Cost Calculator](/calculator/) to estimate whether a higher tier covers your usage.

## Try It Yourself

Stop guessing why Claude Code crashed. The **[Error Diagnostic Tool](/diagnose/)** takes your error message or crash output and tells you the exact cause, fix, and prevention steps. Covers all 10 crash categories above plus 40 more error types.

**[Try the Diagnostic Tool -->](/diagnose/)**

## Common Questions

<details><summary>How do I prevent Claude Code from crashing during long sessions?</summary>
Run <code>/compact</code> every 15-20 turns to keep context size manageable. Add large files to <code>.claudeignore</code>, and ensure at least 4GB of free RAM before starting a session.
</details>

<details><summary>Does Claude Code auto-save my work before crashing?</summary>
Claude Code does not auto-save conversation state. However, any file edits it made before the crash are already written to disk. Your code changes are preserved even if the session is lost.
</details>

<details><summary>How much memory does Claude Code need?</summary>
Minimum 2GB free RAM for basic sessions. For large codebases with many open files and MCP servers, allocate 4-8GB. Set <code>NODE_OPTIONS="--max-old-space-size=8192"</code> for heavy workloads.
</details>

<details><summary>Can I recover a crashed Claude Code session?</summary>
Run <code>claude --resume</code> to attempt session recovery. If the session data is intact, Claude Code will reload the conversation history and you can continue from where you left off.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"How do I prevent Claude Code from crashing during long sessions?","acceptedAnswer":{"@type":"Answer","text":"Run /compact every 15-20 turns to keep context size manageable. Add large files to .claudeignore, and ensure at least 4GB of free RAM before starting a session."}},
{"@type":"Question","name":"Does Claude Code auto-save my work before crashing?","acceptedAnswer":{"@type":"Answer","text":"Claude Code does not auto-save conversation state. However, any file edits it made before the crash are already written to disk. Your code changes are preserved even if the session is lost."}},
{"@type":"Question","name":"How much memory does Claude Code need?","acceptedAnswer":{"@type":"Answer","text":"Minimum 2GB free RAM for basic sessions. For large codebases with many open files and MCP servers, allocate 4-8GB. Set NODE_OPTIONS=--max-old-space-size=8192 for heavy workloads."}},
{"@type":"Question","name":"Can I recover a crashed Claude Code session?","acceptedAnswer":{"@type":"Answer","text":"Run claude --resume to attempt session recovery. If the session data is intact, Claude Code will reload the conversation history and you can continue from where you left off."}}
]}
</script>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

- [Top 50 Claude Code Errors Fix Guide](/top-50-claude-code-errors-fix-guide/)
- [Claude Code Error Logs Location Guide](/claude-code-error-logs-location-guide/)
- [Troubleshooting Guide](/troubleshooting/)
- [Configuration Guide](/configuration/)
- [Error Diagnostic Tool](/diagnose/) -- instant crash diagnosis
