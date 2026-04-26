---
layout: default
title: "Claude Code Error Dictionary (2026)"
description: "Alphabetical reference of every Claude Code error message with causes and fixes. Updated for 2026 with new API, MCP, and skill errors."
permalink: /claude-code-error-messages-dictionary-2026/
date: 2026-04-26
---

# Claude Code Error Messages Dictionary (2026)

This is the definitive alphabetical reference for Claude Code error messages as of 2026. Every entry includes the exact error text, what causes it, and how to fix it. Use Ctrl+F or Cmd+F to search for your specific error.

For instant automated diagnosis, paste any error into the [Error Diagnostic Tool](/diagnose/) instead of searching manually.

## A

### `API key not found`
**Cause:** The `ANTHROPIC_API_KEY` environment variable is not set or the key was revoked.
**Fix:** Export your key: `export ANTHROPIC_API_KEY="sk-ant-..."`. Regenerate at console.anthropic.com if revoked.

### `Authentication failed`
**Cause:** OAuth token expired or credentials file corrupted.
**Fix:** Run `claude login` to re-authenticate. If the issue persists, delete `~/.claude/credentials.json` and login again.

### `Argument list too long`
**Cause:** Passing too many file paths in a single command.
**Fix:** Use glob patterns instead of listing individual files, or process files in batches.

## B

### `Binary file detected, skipping`
**Cause:** Claude Code only processes text files. Binary files (images, compiled code, archives) are skipped.
**Fix:** This is expected behavior. Convert to text if needed, or use a separate tool for binary file analysis.

### `Buffer overflow in stream parser`
**Cause:** Extremely long single-line output from a tool exceeded the stream buffer.
**Fix:** Break output into smaller chunks. If running a command that produces massive output, pipe through `head` or redirect to a file.

## C

### `CERT_HAS_EXPIRED`
**Cause:** SSL certificate validation failed due to expired certificates or incorrect system clock.
**Fix:** Sync your system clock with `ntpdate` or `timedatectl`. Update CA certificates with your package manager.

### `Config validation failed`
**Cause:** Invalid JSON or unsupported values in `.claude/config.json`.
**Fix:** Run `claude config reset` or manually fix the JSON syntax. Validate with `python -m json.tool .claude/config.json`.

### `Connection refused`
**Cause:** Target server (local dev server, MCP server, or API) not accepting connections.
**Fix:** Start the target server first. For MCP servers, check the port configuration in `.claude/mcp.json`.

### `Context window exceeded`
**Cause:** Conversation plus file contents exceeded the model's token limit.
**Fix:** Run `/compact` to summarize context. Remove large files from context. Start a fresh session for new tasks.

## D

### `DNS resolution failed`
**Cause:** Cannot resolve `api.anthropic.com` to an IP address.
**Fix:** Check DNS settings. Try `nslookup api.anthropic.com`. Switch to `8.8.8.8` or `1.1.1.1` as your DNS resolver.

## E

### `EACCES: permission denied`
**Cause:** Insufficient file system permissions for the target file or directory.
**Fix:** Fix ownership with `chown` or permissions with `chmod`. Avoid running Claude Code as root.

### `EMFILE: too many open files`
**Cause:** File descriptor limit reached. Common in large monorepos.
**Fix:** Increase limit: `ulimit -n 10240`. Make this permanent in your shell profile.

### `ENOENT: no such file or directory`
**Cause:** Referenced path does not exist.
**Fix:** Verify the path. Use tab completion to avoid typos. Check for case sensitivity on Linux.

### `ENOSPC: no space left on device`
**Cause:** Disk is full.
**Fix:** Free space. Check with `df -h`. Clean old builds, Docker images, and package caches.

### `EPERM: operation not permitted`
**Cause:** OS-level protection prevents the operation (macOS SIP, Linux SELinux/AppArmor).
**Fix:** Move your project to an unprotected directory. Do not disable SIP or SELinux.

### `ETIMEDOUT`
**Cause:** Network request timed out before receiving a response.
**Fix:** Check internet connection. If behind a proxy, configure `HTTPS_PROXY`. Increase timeout if the operation legitimately needs more time.

## F

### `Fatal: JavaScript heap out of memory`
**Cause:** Node.js exceeded its memory allocation limit.
**Fix:** Set `NODE_OPTIONS="--max-old-space-size=8192"`. For monorepos, you may need 16384. See the [OOM guide](/claude-code-error-out-of-memory-large-codebase-fix/).

### `File too large to read`
**Cause:** File exceeds Claude Code's maximum readable file size (approximately 10 MB for text files).
**Fix:** Extract the relevant section or split the file. Use `head`, `tail`, or `sed` to get specific line ranges.

## G

### `Git push rejected`
**Cause:** Remote branch has new commits that your local branch does not have.
**Fix:** Pull and rebase: `git pull --rebase origin main`, then retry the push.

## H

### `Hook execution failed`
**Cause:** A pre-commit or post-task hook script returned a non-zero exit code.
**Fix:** Check the hook script in `.claude/hooks/` for errors. Run it manually to see the full error output.

### `HTTP 401 Unauthorized`
**Cause:** Missing or invalid authentication credentials.
**Fix:** Re-authenticate with `claude login` or re-export your API key.

### `HTTP 403 Forbidden`
**Cause:** Your API key or account does not have permission for the requested operation.
**Fix:** Check your plan level and key permissions at console.anthropic.com.

### `HTTP 429 Too Many Requests`
**Cause:** Rate limit exceeded for your plan tier.
**Fix:** Wait and retry (Claude Code has built-in backoff). Consider upgrading your plan. See the [rate limit guide](/anthropic-api-error-429-rate-limit/).

### `HTTP 500 Internal Server Error`
**Cause:** Server-side error at Anthropic.
**Fix:** Retry after 30 seconds. If persistent, check status.anthropic.com for outage reports.

### `HTTP 502/503`
**Cause:** Anthropic API temporarily unavailable.
**Fix:** Wait 60 seconds and retry. This is almost always a transient issue.

## I

### `Invalid JSON in response`
**Cause:** Response was truncated or corrupted during transmission.
**Fix:** Retry the request. If it persists, check your network connection for packet loss.

### `Invalid skill definition`
**Cause:** Skill configuration file has syntax errors or missing required fields.
**Fix:** Validate the skill JSON against the schema. Check for missing `name`, `description`, or `instructions` fields.

## M

### `Maximum call stack size exceeded`
**Cause:** Infinite recursion in a tool or skill.
**Fix:** Restart Claude Code. Report the issue on GitHub with reproduction steps.

### `MCP server connection refused`
**Cause:** MCP server is not running or the port/path is misconfigured.
**Fix:** Start the MCP server and verify the connection details in `.claude/mcp.json`.

### `Model overloaded`
**Cause:** High demand on the specific model.
**Fix:** Wait 30-60 seconds or switch to a different model with `/model`.

## N

### `npm install failed`
**Cause:** Package conflicts, network issues, or corrupted cache.
**Fix:** Delete `node_modules` and lockfile, then retry. Clear npm cache with `npm cache clean --force`.

## P

### `Proxy authentication required (407)`
**Cause:** Corporate proxy requires credentials.
**Fix:** Set `HTTPS_PROXY=http://user:pass@proxy:port`. Contact IT for proxy credentials if needed.

## R

### `Rate limit exceeded`
**Cause:** Too many API requests in a short period.
**Fix:** Reduce request frequency. Use `/compact` to reduce token usage. See the [429 guide](/anthropic-api-error-429-rate-limit/).

### `Response truncated`
**Cause:** Model output hit the maximum token limit for a single response.
**Fix:** Ask Claude to continue from where it stopped. For code generation, ask for one file at a time.

## S

### `Session expired`
**Cause:** Inactivity timeout or token expiry.
**Fix:** Run `claude login` to start a fresh session.

### `SIGKILL / exit code 137`
**Cause:** OS killed the process for exceeding memory limits (OOM killer on Linux).
**Fix:** Increase available RAM or Node.js heap size. Close competing memory-heavy processes.

### `Skill not found`
**Cause:** Referenced skill is not installed or the name is misspelled.
**Fix:** Check installed skills with `claude skills list`. Install missing skills from the [Skill Finder](/skill-finder/).

### `Socket hang up`
**Cause:** Connection dropped during data transfer.
**Fix:** Check network stability. If using a VPN, test without it. Retry the operation.

### `Spawn UNKNOWN`
**Cause:** System cannot execute the specified binary (runtime not installed or path wrong).
**Fix:** Verify the binary exists: `which node`, `which python`. Reinstall the required runtime.

## T

### `Token expired`
**Cause:** Authentication token past its TTL.
**Fix:** Re-authenticate with `claude login`.

### `Tool not allowed in current mode`
**Cause:** The current permission mode restricts the requested tool.
**Fix:** Use `--allowedTools` to permit the tool, or switch to a less restrictive permission mode.

## U

### `UNABLE_TO_VERIFY_LEAF_SIGNATURE`
**Cause:** Corporate proxy intercepting SSL with a custom certificate.
**Fix:** Set `NODE_EXTRA_CA_CERTS` to your corporate CA bundle path.

## Try It Yourself

Instead of searching this dictionary every time, use the [Error Diagnostic Tool](/diagnose/) to get automated diagnosis. Paste any error message and receive the cause, fix, and prevention steps in seconds.

[Open Error Diagnostic Tool](/diagnose/){: .btn .btn-primary }

## FAQ

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How many distinct error messages does Claude Code have?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code can produce over 200 distinct error messages across its core runtime, API layer, file system operations, MCP connections, and skill execution. This dictionary covers the most common ones."
      }
    },
    {
      "@type": "Question",
      "name": "What is the fastest way to look up a Claude Code error?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use the Error Diagnostic Tool at claudecodeguides.com/diagnose/ for instant lookup. Paste any error message and get the cause and fix in seconds. It is faster than manual dictionary search."
      }
    },
    {
      "@type": "Question",
      "name": "Are Claude Code error messages the same across platforms?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most error messages are identical on macOS, Linux, and Windows. Platform-specific differences are mainly in file path formats and permission error details (EACCES vs Access Denied)."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report a new error that is not in this dictionary?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "File an issue on the Claude Code GitHub repository with the full error message, your OS, Claude Code version, and reproduction steps. Include verbose logs if possible."
      }
    }
  ]
}
</script>

### How many distinct error messages does Claude Code have?
Claude Code can produce over 200 distinct error messages across its core runtime, API layer, file system operations, MCP connections, and skill execution. This dictionary covers the most common ones.

### What is the fastest way to look up a Claude Code error?
Use the [Error Diagnostic Tool](/diagnose/) for instant lookup. Paste any error message and get the cause and fix in seconds. It is faster than manual dictionary search.

### Are Claude Code error messages the same across platforms?
Most error messages are identical on macOS, Linux, and Windows. Platform-specific differences are mainly in file path formats and permission error details (`EACCES` vs `Access Denied`).

### How do I report a new error that is not in this dictionary?
File an issue on the Claude Code GitHub repository with the full error message, your OS, Claude Code version, and reproduction steps. Include verbose logs if possible.



**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

- [Top 50 Claude Code Errors](/top-50-claude-code-errors-2026/) — Quick-fix list with one-line solutions
- [Claude Code Error Logs Location Guide](/claude-code-error-logs-location-guide/) — Find and parse log files
- [Why Claude Code Keeps Crashing](/why-claude-code-keeps-crashing-2026/) — Systematic crash debugging
- [Claude Code Debugging Workflow](/claude-code-debugging-workflow-guide-2026/) — Step-by-step debugging process
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/) — Set up verbose logging
- [Error Diagnostic Tool](/diagnose/) — Automated error lookup and resolution
