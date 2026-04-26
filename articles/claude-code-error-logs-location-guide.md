---
layout: default
title: "Claude Code Error Logs: Where to Find and Read Them (2026)"
description: "Find Claude Code log files on macOS, Linux, and Windows. Learn the log format, use --verbose for detailed output, and filter logs to find specific errors."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-error-logs-location-guide/
reviewed: true
categories: [troubleshooting]
tags: [claude, claude-code, logs, debugging, error-logs]
---

# Claude Code Error Logs: Where to Find and Read Them

When Claude Code fails and the terminal output is not enough, the log files hold the full story. Every API call, tool invocation, error, and internal state change is recorded. Knowing where these files live and how to read them is the difference between a 5-minute fix and an hour of guessing. This guide covers log locations on every OS, the log format, filtering techniques, and the `--verbose` flag for real-time debugging. For instant error identification, paste any error from your logs into the [Error Diagnostic Tool](/diagnose/).

## Log File Locations by OS

### macOS

```bash
~/.claude/logs/
# Example: ~/.claude/logs/session-2026-04-26T14-30-00.log
```

Each session creates its own log file with a timestamp in the filename. The most recent session is always the last file sorted alphabetically.

```bash
# Find the latest log
ls -lt ~/.claude/logs/ | head -5

# Open the latest log
cat ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

### Linux

```bash
~/.claude/logs/
# Same structure as macOS
# On some distributions, XDG paths may apply:
$XDG_DATA_HOME/claude/logs/
# Which defaults to:
~/.local/share/claude/logs/
```

### Windows (WSL)

```bash
# Inside WSL:
~/.claude/logs/

# Native Windows (if using Node directly):
%USERPROFILE%\.claude\logs\
# Typically: C:\Users\YourName\.claude\logs\
```

### Additional Log Sources

Beyond session logs, Claude Code writes to these locations:

```bash
# MCP server logs (separate from main logs)
~/.claude/mcp-logs/

# Crash dumps (created on fatal errors)
~/.claude/crash-reports/

# Configuration change audit log
~/.claude/audit.log
```

## Understanding the Log Format

Every log entry follows a structured format:

```
2026-04-26T14:30:15.123Z [INFO] [session:abc123] Message sent to API
  model: claude-sonnet-4-20250514
  input_tokens: 4521
  max_tokens: 8192

2026-04-26T14:30:16.456Z [ERROR] [session:abc123] API request failed
  status: 429
  retry_after: 60
  message: Rate limit exceeded
```

The key fields are:

- **Timestamp** -- ISO 8601 format, always UTC
- **Level** -- `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`
- **Session ID** -- links all entries for a single session
- **Message** -- human-readable description
- **Metadata** -- indented key-value pairs with context

## Filtering Logs for Specific Errors

Raw log files can be thousands of lines. Use these filtering patterns:

### Find All Errors

```bash
grep -E "\[ERROR\]|\[FATAL\]" ~/.claude/logs/session-*.log
```

### Find Token Usage

```bash
grep "input_tokens\|output_tokens" ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

### Find API Failures

```bash
grep -A 3 "API request failed" ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

### Find MCP Issues

```bash
grep -i "mcp\|server.*disconnect\|server.*error" ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

### Find Permission Errors

```bash
grep -i "EACCES\|permission denied\|EPERM" ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

### Tail Logs in Real Time

```bash
# Watch the current session's log as it writes
tail -f ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

## Using --verbose for Real-Time Debugging

The `--verbose` flag outputs maximum detail to stderr during execution:

```bash
claude --verbose
```

Verbose mode adds:
- Full HTTP request/response headers (API key redacted)
- Tool input/output payloads
- Token count per message
- Context window usage percentage
- MCP server communication details
- File read/write operations with paths

For targeted debugging, redirect verbose output to a file while using Claude Code normally:

```bash
claude --verbose 2>/tmp/claude-verbose.log
# Work normally in the session, then check:
grep "ERROR" /tmp/claude-verbose.log
```

## Log Rotation and Cleanup

Claude Code does not automatically rotate or delete logs. Over months of use, the logs directory can grow to several gigabytes.

### Check Log Directory Size

```bash
du -sh ~/.claude/logs/
```

### Clean Old Logs (Keep Last 7 Days)

```bash
find ~/.claude/logs/ -name "session-*.log" -mtime +7 -delete
```

### Archive Instead of Delete

```bash
mkdir -p ~/.claude/logs/archive
find ~/.claude/logs/ -name "session-*.log" -mtime +7 -exec mv {} ~/.claude/logs/archive/ \;
# Compress the archive
tar -czf ~/.claude/logs/archive-$(date +%Y%m%d).tar.gz ~/.claude/logs/archive/
rm -rf ~/.claude/logs/archive/
```

## Correlating Logs with Crashes

When Claude Code crashes, follow this workflow:

1. **Find the crash session log:**

```bash
ls -lt ~/.claude/logs/ | head -1
# The newest file corresponds to the session that crashed
```

2. **Find the last error before the crash:**

```bash
grep -n "ERROR\|FATAL" ~/.claude/logs/[crash-session].log | tail -5
```

3. **Read the context around that error:**

```bash
# If the error is on line 450:
sed -n '440,460p' ~/.claude/logs/[crash-session].log
```

4. **Check the crash report** (if generated):

```bash
cat ~/.claude/crash-reports/$(ls -t ~/.claude/crash-reports/ | head -1)
```

The crash report includes the Node.js process exit code, signal (SIGKILL for OOM, SIGSEGV for memory corruption), and the last 20 log entries before termination.

## Try It Yourself

Reading logs is powerful but slow. The **[Error Diagnostic Tool](/diagnose/)** takes the error message from your log and instantly returns the fix, root cause, and prevention steps. Paste the `[ERROR]` or `[FATAL]` line directly from your log file.

**[Try the Diagnostic Tool -->](/diagnose/)**

## Common Questions

<details><summary>Can I change where Claude Code stores its logs?</summary>
Not directly through Claude Code's configuration. However, you can create a symlink: <code>ln -s /your/preferred/path ~/.claude/logs</code>. Claude Code will follow the symlink and write logs to your preferred location.
</details>

<details><summary>Do logs contain my API key or sensitive data?</summary>
API keys are redacted in logs (shown as <code>sk-ant-***</code>). However, logs do contain your prompts, file paths, and tool outputs. Treat log files as sensitive and do not share them publicly without redaction.
</details>

<details><summary>How large do Claude Code log files get?</summary>
A typical 30-minute session produces a 2-5MB log file. Heavy sessions with verbose mode enabled can reach 50MB+. Run <code>du -sh ~/.claude/logs/</code> periodically and clean files older than 7 days.
</details>

<details><summary>Is there a GUI log viewer for Claude Code?</summary>
No official GUI exists. For a better reading experience, pipe logs through <code>less -R</code> for paged viewing, or open them in VS Code which provides syntax highlighting for structured log formats.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Can I change where Claude Code stores its logs?","acceptedAnswer":{"@type":"Answer","text":"Not directly through Claude Code's configuration. However, you can create a symlink: ln -s /your/preferred/path ~/.claude/logs. Claude Code will follow the symlink."}},
{"@type":"Question","name":"Do logs contain my API key or sensitive data?","acceptedAnswer":{"@type":"Answer","text":"API keys are redacted in logs. However, logs do contain your prompts, file paths, and tool outputs. Treat log files as sensitive and do not share them publicly."}},
{"@type":"Question","name":"How large do Claude Code log files get?","acceptedAnswer":{"@type":"Answer","text":"A typical 30-minute session produces a 2-5MB log file. Heavy sessions with verbose mode can reach 50MB+. Clean files older than 7 days periodically."}},
{"@type":"Question","name":"Is there a GUI log viewer for Claude Code?","acceptedAnswer":{"@type":"Answer","text":"No official GUI exists. For a better reading experience, pipe logs through less -R for paged viewing, or open them in VS Code which provides syntax highlighting."}}
]}
</script>



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Debugging Claude Code Like a Senior Engineer](/debugging-claude-code-senior-engineer-guide/)
- [Error Handling Guide](/error-handling/)
- [Troubleshooting Guide](/troubleshooting/)
- [Configuration Guide](/configuration/)
- [Error Diagnostic Tool](/diagnose/) -- instant error lookup
