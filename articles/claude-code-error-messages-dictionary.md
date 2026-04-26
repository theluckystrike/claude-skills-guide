---
layout: default
title: "Claude Code Error Messages Explained: Dictionary (2026)"
description: "Alphabetical dictionary of 30+ Claude Code error messages with severity levels, explanations, and exact fixes. Fatal, recoverable, and warning errors covered."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-error-messages-dictionary/
reviewed: true
categories: [troubleshooting]
tags: [claude, claude-code, error-messages, dictionary, reference]
---

# Claude Code Error Messages Explained: Dictionary

When Claude Code throws an error, the message itself contains the diagnostic information you need -- if you know how to read it. This dictionary organizes every documented error message alphabetically within three severity tiers: fatal (process exits), recoverable (operation fails but session continues), and warning (informational, no action required). Bookmark this page or use the [Error Diagnostic Tool](/diagnose/) to look up any error instantly by pasting the exact message.

## Fatal Errors (Process Exits)

Fatal errors terminate the Claude Code process. You must restart after resolving the cause.

**`ANTHROPIC_API_KEY not set`** -- No API key found in environment variables. Add `export ANTHROPIC_API_KEY="sk-ant-..."` to your shell profile and run `source ~/.zshrc`.

**`Cannot initialize: config file parse error`** -- The JSON in `~/.claude/config.json` is malformed. Validate with `python3 -m json.tool ~/.claude/config.json`. Fix the syntax error or delete and regenerate with `claude config reset`.

**`ENOSPC: no space left on device`** -- Disk is full. Claude Code cannot write session data. Free space in your home directory and `/tmp`.

**`Fatal: Node.js version 16 is not supported`** -- Claude Code requires Node.js 18+. Upgrade with `nvm install 20 && nvm use 20`.

**`ENOMEM: not enough memory`** -- The Node.js process was killed by the OS. Close other applications and increase the heap: `export NODE_OPTIONS="--max-old-space-size=8192"`.

**`Maximum retry count exceeded`** -- After 5 consecutive failures (usually 429 or 500 errors), Claude Code stops retrying and exits. Wait several minutes before restarting.

**`SSL certificate verification failed`** -- TLS handshake with api.anthropic.com failed. Usually caused by corporate proxy interception. Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`.

**`Segmentation fault`** -- Native module crash, typically in Node.js binary addons. Reinstall Claude Code: `npm install -g @anthropic-ai/claude-code --force`.

## Recoverable Errors (Operation Fails)

These errors fail the current operation but keep your session alive. You can retry or modify your approach.

**`401 Unauthorized`** -- API key rejected. Check that `$ANTHROPIC_API_KEY` is valid and has not been rotated by an admin.

**`429 Too Many Requests`** -- Rate limited. Claude Code will auto-retry with backoff. If persistent, your plan quota may be exhausted. Check with the [Cost Calculator](/calculator/).

**`502 Bad Gateway`** -- Anthropic API infrastructure issue. Transient; retry in 30 seconds. Check status.anthropic.com if repeated.

**`503 Service Unavailable`** -- API overloaded. Wait and retry. No action needed on your end.

**`Context window exceeded`** -- Conversation is too long. Run `/compact` to compress history, or start a new session with `claude --new`.

**`File not found`** -- Claude Code tried to read a file that does not exist at the specified path. Verify the path and check for typos.

**`MCP server disconnected`** -- An MCP server lost connection. Claude Code continues without that server. Restart the MCP server separately.

**`MCP tool execution timeout`** -- An MCP tool took longer than the configured timeout. Increase the timeout in your MCP config or simplify the tool's operation.

**`Output truncated at max_tokens`** -- Response hit the output ceiling. Ask Claude to continue or increase `--max-tokens`.

**`Permission denied: cannot write to file`** -- The target file is read-only or owned by another user. Fix with `chmod 644 file` or `sudo chown $(whoami) file`.

**`Tool result too large`** -- A bash command or tool returned output exceeding 100KB. Pipe through `head -100` or redirect to a file.

**`Git operation failed: merge conflict`** -- Claude Code attempted a git operation that hit a conflict. Resolve the conflict manually, then resume.

## Warning Messages (Informational)

Warnings do not stop execution. They inform you about suboptimal conditions.

**`CLAUDE.md not found, using defaults`** -- No project configuration file. Claude Code works without it, but creating one improves results. Run `claude init` to generate a starter.

**`Codebase index outdated, rebuilding`** -- The file index is stale. Claude Code rebuilds automatically. This may slow the first query by 5-10 seconds.

**`Deprecated flag: --model will be removed`** -- You used a CLI flag scheduled for removal. Check `claude --help` for the current syntax.

**`Large file skipped: exceeds 1MB limit`** -- Claude Code does not auto-load files over 1MB. Reference them explicitly if needed.

**`MCP server slow: response took >10s`** -- An MCP server is responding slowly. Not a failure, but may indicate the server needs optimization.

**`Session nearing context limit (>80%)`** -- You are approaching the context window limit. Run `/compact` soon to avoid a hard error.

**`Unused tool definitions detected`** -- Your configuration includes tools Claude Code is not using. This wastes context tokens. Review your [commands and tools setup](/commands/).

## Reading Error Output Effectively

Every Claude Code error follows a consistent structure:

```
[TIMESTAMP] [SEVERITY] [ERROR_CODE] Message text
  at functionName (file:line:col)
  Details: additional context
```

The most useful parts are the **severity** (fatal/error/warn), the **error code** (maps directly to entries in this dictionary), and the **details** line which often contains the specific file path, URL, or configuration key that triggered the error. When the details line includes a file path, check that file first -- it is almost always the root cause.

For [debugging Claude Code systematically](/debugging-claude-code-senior-engineer-guide/), start with the error code, then look at the stack trace to identify whether the error originated in your configuration, your code, or the Anthropic API.

## Try It Yourself

Looking up errors manually is slow. The **[Error Diagnostic Tool](/diagnose/)** matches your exact error message against a database of 50+ known errors and returns the fix, severity level, and prevention steps instantly.

**[Try the Diagnostic Tool -->](/diagnose/)**

## Common Questions

<details><summary>What is the difference between a fatal and recoverable error?</summary>
Fatal errors terminate the Claude Code process entirely -- you must restart. Recoverable errors fail the current operation (a single message or tool call) but keep your session running so you can retry or try a different approach.
</details>

<details><summary>How do I find which error code Claude Code threw?</summary>
Check the terminal output for the bracketed error code, e.g., <code>[ERR_CONTEXT_OVERFLOW]</code>. You can also check the session log at <code>~/.claude/logs/</code> where every error is logged with its full code and stack trace.
</details>

<details><summary>Are 429 errors my fault or Anthropic's?</summary>
Usually yours -- you have exceeded your plan's request rate. However, during API-wide rate limiting (e.g., high demand periods), even low-usage accounts may see 429s temporarily. Check status.anthropic.com for system-wide issues.
</details>

<details><summary>Should I worry about warning messages?</summary>
Most warnings are informational and safe to ignore short-term. However, the "session nearing context limit" warning should prompt you to run <code>/compact</code> immediately to avoid a fatal context overflow.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"What is the difference between a fatal and recoverable error?","acceptedAnswer":{"@type":"Answer","text":"Fatal errors terminate the Claude Code process entirely -- you must restart. Recoverable errors fail the current operation but keep your session running so you can retry or try a different approach."}},
{"@type":"Question","name":"How do I find which error code Claude Code threw?","acceptedAnswer":{"@type":"Answer","text":"Check the terminal output for the bracketed error code. You can also check the session log at ~/.claude/logs/ where every error is logged with its full code and stack trace."}},
{"@type":"Question","name":"Are 429 errors my fault or Anthropic's?","acceptedAnswer":{"@type":"Answer","text":"Usually yours -- you have exceeded your plan's request rate. However, during API-wide rate limiting, even low-usage accounts may see 429s temporarily. Check status.anthropic.com for system-wide issues."}},
{"@type":"Question","name":"Should I worry about warning messages?","acceptedAnswer":{"@type":"Answer","text":"Most warnings are informational and safe to ignore short-term. However, the session nearing context limit warning should prompt you to run /compact immediately to avoid a fatal context overflow."}}
]}
</script>



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

- [Top 50 Claude Code Errors Fix Guide](/top-50-claude-code-errors-fix-guide/)
- [Error Handling Guide](/error-handling/)
- [Commands Reference](/commands/)
- [Getting Started with Claude Code](/starter/)
- [Error Diagnostic Tool](/diagnose/) -- instant error lookup
