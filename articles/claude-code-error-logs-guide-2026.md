---
layout: default
title: "Claude Code Error Logs Guide (2026)"
description: "Where to find Claude Code logs on macOS, Linux, and Windows. How to read log formats, filter for errors, and use logs for debugging."
permalink: /claude-code-error-logs-guide-2026/
date: 2026-04-26
---

# Claude Code Error Logs Guide (2026)

When Claude Code fails, the error message you see in the terminal is often a simplified version of what actually happened. The full details live in log files. Knowing where to find these logs, how to read them, and how to filter for the information you need is an essential debugging skill.

Need a quicker path to the fix? Paste your error into the [Error Diagnostic Tool](/diagnose/) for instant diagnosis without digging through log files.

## Where Claude Code Stores Logs

### macOS
```
~/.claude/logs/
~/Library/Logs/Claude Code/
```

### Linux
```
~/.claude/logs/
~/.local/share/claude-code/logs/
```

### Windows
```
%APPDATA%\Claude Code\logs\
%USERPROFILE%\.claude\logs\
```

Log files are named with timestamps: `claude-2026-04-26T14-30-00.log`. Each session generates a new log file.

## Generating Verbose Logs

By default, Claude Code only logs errors and warnings. To capture everything:

```bash
# Maximum verbosity
claude --verbose 2>&1 | tee ~/claude-verbose-$(date +%Y%m%d).log

# Just stderr (errors only)
claude 2> ~/claude-errors-$(date +%Y%m%d).log
```

The `--verbose` flag enables debug-level logging that includes:

- Every API request and response (with timing)
- Tool execution details and return values
- File system operations (reads, writes, permission checks)
- MCP server communication
- Skill loading and execution
- Token usage per message

## Understanding the Log Format

Claude Code logs follow a structured format:

```
[2026-04-26T14:30:15.123Z] [INFO] [API] POST /v1/messages 200 1523ms
[2026-04-26T14:30:15.456Z] [INFO] [TOOL] bash: exit_code=0, output_bytes=342
[2026-04-26T14:30:16.789Z] [ERROR] [API] POST /v1/messages 429 Rate limit exceeded
[2026-04-26T14:30:16.790Z] [WARN] [RETRY] Backing off 5000ms before retry 1/3
```

Each line has four components:

1. **Timestamp** in ISO 8601 format with milliseconds
2. **Level**: `DEBUG`, `INFO`, `WARN`, `ERROR`, or `FATAL`
3. **Category**: `API`, `TOOL`, `FILE`, `MCP`, `SKILL`, `STREAM`, `CONFIG`, `RETRY`
4. **Message** with relevant details

## Filtering Logs Efficiently

### Find All Errors

```bash
grep '\[ERROR\]' ~/.claude/logs/claude-2026-04-26*.log
```

### Find API Issues

```bash
grep '\[API\]' ~/.claude/logs/claude-2026-04-26*.log | grep -v '200'
```

### Find Rate Limits

```bash
grep '429\|rate.limit\|Rate limit' ~/.claude/logs/claude-2026-04-26*.log
```

### Find Memory Issues

```bash
grep -i 'memory\|heap\|oom\|SIGKILL' ~/.claude/logs/claude-2026-04-26*.log
```

### Find Slow Operations (over 5 seconds)

```bash
grep -E '[0-9]{4,}ms' ~/.claude/logs/claude-2026-04-26*.log
```

### Tail Logs in Real Time

```bash
tail -f ~/.claude/logs/$(ls -t ~/.claude/logs/ | head -1)
```

## Common Log Patterns and What They Mean

### Pattern 1: Rate Limit Cascade

```
[ERROR] [API] 429 Rate limit exceeded
[WARN] [RETRY] Backing off 5000ms
[ERROR] [API] 429 Rate limit exceeded
[WARN] [RETRY] Backing off 10000ms
[ERROR] [API] 429 Rate limit exceeded
[FATAL] [API] Max retries exceeded
```

This means you have exhausted your plan's rate limit. The exponential backoff tried three times and gave up. Solutions: wait a few minutes, upgrade your plan, or reduce message frequency.

### Pattern 2: Memory Pressure

```
[WARN] [MEMORY] Heap usage at 85% (3.4GB/4.0GB)
[WARN] [MEMORY] Heap usage at 92% (3.7GB/4.0GB)
[FATAL] JavaScript heap out of memory
```

The logs show a gradual memory climb before the crash. Fix: increase `NODE_OPTIONS="--max-old-space-size=8192"` and use `/compact` more frequently.

### Pattern 3: MCP Server Failure

```
[INFO] [MCP] Connecting to localhost:3001
[ERROR] [MCP] Connection refused: localhost:3001
[WARN] [MCP] Retrying connection in 2000ms
[ERROR] [MCP] Failed after 3 retries
```

The MCP server is not running. Start it before launching Claude Code.

### Pattern 4: Skill Load Failure

```
[INFO] [SKILL] Loading skill: my-custom-skill
[ERROR] [SKILL] Invalid JSON in .claude/skills/my-custom-skill.json
[WARN] [SKILL] Skipping skill: my-custom-skill
```

The skill config has a JSON syntax error. Validate with `python -m json.tool`.

### Pattern 5: Network Timeout

```
[INFO] [API] POST /v1/messages ...
[WARN] [STREAM] No data received for 30000ms
[ERROR] [API] ETIMEDOUT
```

The API call started but no data came back. This is a network issue, not an API issue. Check VPN, proxy, and firewall settings.

## Log Rotation and Cleanup

Claude Code does not automatically clean up old logs. Over months, logs can consume gigabytes:

```bash
# Check log directory size
du -sh ~/.claude/logs/

# Delete logs older than 30 days
find ~/.claude/logs/ -name "*.log" -mtime +30 -delete

# Keep only the last 100 log files
ls -t ~/.claude/logs/*.log | tail -n +101 | xargs rm -f
```

Consider adding the cleanup command to a weekly cron job to prevent disk space issues.

## Try It Yourself

Reading logs is powerful but time-consuming. For known errors, the [Error Diagnostic Tool](/diagnose/) gives you the answer instantly. Use it as your first step, then dive into logs only when the tool suggests deeper investigation.

[Open Error Diagnostic Tool](/diagnose/){: .btn .btn-primary }

## FAQ

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Where are Claude Code log files stored?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "On macOS: ~/.claude/logs/ and ~/Library/Logs/Claude Code/. On Linux: ~/.claude/logs/ and ~/.local/share/claude-code/logs/. On Windows: %APPDATA%/Claude Code/logs/."
      }
    },
    {
      "@type": "Question",
      "name": "How do I enable verbose logging in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run Claude Code with the --verbose flag. This enables debug-level logging that includes API calls, tool execution, file operations, and token usage. Pipe to tee to save and watch simultaneously."
      }
    },
    {
      "@type": "Question",
      "name": "How much disk space do Claude Code logs use?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Normal logs use a few MB per session. Verbose logs can reach 50-100 MB per session. Without cleanup, months of logs can consume several gigabytes. Delete logs older than 30 days regularly."
      }
    },
    {
      "@type": "Question",
      "name": "Can I send Claude Code logs when reporting a bug?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Attach verbose logs to GitHub issues. Remove your API key from the logs first by searching for sk-ant and redacting those lines. Logs help maintainers reproduce and fix issues faster."
      }
    }
  ]
}
</script>

### Where are Claude Code log files stored?
On macOS: `~/.claude/logs/` and `~/Library/Logs/Claude Code/`. On Linux: `~/.claude/logs/` and `~/.local/share/claude-code/logs/`. On Windows: `%APPDATA%\Claude Code\logs\`.

### How do I enable verbose logging in Claude Code?
Run Claude Code with the `--verbose` flag. This enables debug-level logging that includes API calls, tool execution, file operations, and token usage. Pipe to `tee` to save and watch simultaneously.

### How much disk space do Claude Code logs use?
Normal logs use a few MB per session. Verbose logs can reach 50-100 MB per session. Without cleanup, months of logs can consume several gigabytes. Delete logs older than 30 days regularly.

### Can I send Claude Code logs when reporting a bug?
Yes. Attach verbose logs to GitHub issues. Remove your API key from the logs first by searching for `sk-ant` and redacting those lines. Logs help maintainers reproduce and fix issues faster.

## Related Guides

- [Claude Code Error Messages Dictionary](/claude-code-error-messages-dictionary-2026/) — Alphabetical error reference
- [Debugging Like a Senior Engineer](/debugging-claude-code-senior-engineer-2026/) — Advanced debugging methodology
- [Top 50 Claude Code Errors](/top-50-claude-code-errors-2026/) — Most common errors with one-line fixes
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/) — Setting up debug environments
- [Why Claude Code Keeps Crashing](/why-claude-code-keeps-crashing-2026/) — Crash cause analysis
- [Error Diagnostic Tool](/diagnose/) — Paste any error for instant diagnosis
