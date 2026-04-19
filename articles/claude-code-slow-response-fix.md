---
layout: default
title: "Fix: Claude Code Slow Response Latency"
description: "Claude Code responding slowly with 2+ minute latency and minimal output? Diagnose and fix response latency issues with these steps."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-slow-response-fix/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, performance, slow, latency, context-window]
geo_optimized: true
---

# Fix: Claude Code Slow Response and High Latency

## The Error

Claude Code CLI responds extremely slowly. You wait over 2 minutes and receive minimal output -- sometimes as few as 13 tokens. The session feels frozen but eventually produces a tiny response:

```text
[2+ minute wait for 13 tokens of output]
```

## Quick Fix

1. Run `/compact` to reduce conversation context size
2. If that does not help, start a new session (`Ctrl+C`, then `claude`)
3. Check the Anthropic API status page at https://status.anthropic.com

## What Causes This

Slow responses in Claude Code have several distinct root causes. Identifying which one applies to your situation is key.

### 1. Context Window Bloat

The most common cause. Claude Code sends the entire conversation history with every request. After many tool calls, file reads, and responses, the context can grow to hundreds of thousands of tokens. The API must process all of this before generating a response.

From the error logs:

```text
ensureToolResultPairing: repaired missing tool_result blocks
(85 -> 85 messages)
```

85 messages means a large context. Each API call must process the full history.

### 2. Lock Acquisition Failures

```text
Error: NON-FATAL: Lock acquisition failed for
/Users/username/.local/share/claude/versions/2.1.92
(expected in multi-process scenarios)
```

This indicates multiple Claude Code instances are running simultaneously, competing for the same lock file. While marked "non-fatal," it can cause delays as processes wait for lock availability.

### 3. Tool Result Message Repair

The error log shows:

```text
ensureToolResultPairing: repaired missing tool_result blocks
```

This means the conversation history had corrupted tool_use/tool_result pairs. The repair process adds overhead and can indicate deeper session state issues.

## Full Solution

### Step 1: Diagnose the Cause

```bash
# Check if multiple Claude instances are running
ps aux | grep -i claude | grep -v grep
```

### Step 2: Reduce Context Size

```text
/compact
```

This summarizes the conversation and significantly reduces the input token count. If the session is responsive enough to accept commands, this is the best first step.

### Step 3: Kill Competing Instances

```bash
# Find all Claude processes
ps aux | grep -i claude | grep -v grep

# Kill any stuck or unwanted instances
kill <PID>

# Start fresh
claude
```

### Step 4: Check API Status

```bash
# Quick check from the terminal
curl -s https://status.anthropic.com/api/v2/status.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"Status: {data['status']['description']}\")
"
```

### Step 5: Network Diagnostics

```bash
# Check latency to Anthropic API
curl -w "@-" -o /dev/null -s "https://api.anthropic.com/v1/messages" <<'EOF'
 time_namelookup: %{time_namelookup}\n
 time_connect: %{time_connect}\n
 time_starttransfer: %{time_starttransfer}\n
 time_total: %{time_total}\n
EOF

# Check for DNS issues
dig api.anthropic.com
```

## Prevention

- **Compact regularly**: do not let context accumulate beyond what is needed for the current task
- **Start new sessions for new tasks**: do not continue stale conversations
- **Kill old sessions**: check for zombie Claude processes before starting new work
- **Monitor API status**: bookmark https://status.anthropic.com

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-code-slow-response-fix)**

$99 once. Pays for itself in saved tokens within a week.

</div>

## Related Guides

- [Fix: Claude API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Fix: Anthropic SDK Streaming Hangs Indefinitely](/anthropic-sdk-streaming-hang-timeout/)
- [Claude API Error 400 Invalid Request Fix](/claude-api-error-400-invalidrequesterror-explained/)
- [Fix: Claude Code Slow Response and Performance](/claude-code-slow-fix/)



## Related Articles

- [Claude Code Error: Unexpected Token in JSON Response Fix](/claude-code-error-unexpected-token-in-json-response-fix/)
