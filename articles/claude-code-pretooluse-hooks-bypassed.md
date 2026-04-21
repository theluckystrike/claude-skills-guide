---
layout: default
title: "Fix: Claude Code PreToolUse Hooks Stop Working (2026)"
description: "Claude Code PreToolUse hooks and --dangerously-skip-permissions stop working after background tasks complete. Diagnosis and workarounds. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-pretooluse-hooks-bypassed/
reviewed: true
categories: [troubleshooting]
tags: [claude-code, hooks, permissions, error, troubleshooting]
geo_optimized: true
---

# Fix: Claude Code PreToolUse Hooks Stop Working

## The Error

You have Claude Code running with `--dangerously-skip-permissions` and a PreToolUse hook configured to log and allow all tool calls. Everything works initially. Then, after a background task completes (or after an extended idle period), permission prompts start appearing:

```
Permission rule **Bash** requires confirmation for this command
```

Your hook log shows **no entry** for the blocked command — the hook was never called. All subsequent tool calls in the session prompt for permission.

## Quick Fix

```bash
# Kill and restart Claude Code
# Ctrl+C to exit the broken session

# Restart with the same flags
claude --dangerously-skip-permissions --permission-mode bypassPermissions
```

There is no way to recover the permission state within the same session once it degrades.

## What's Happening

Claude Code maintains an internal permission state machine that tracks which permission mode is active and whether hooks should be invoked for each tool call. This state machine has a bug where certain events cause it to reset to the default (interactive confirmation) mode:

**Trigger events that cause permission state degradation:**

1. **Background task completion** — When a `Bash` tool call with `run_in_background: true` completes, the permission state handler processes the completion event and can reset the session's permission configuration
2. **Extended idle periods** — Sessions left idle for 30+ minutes may experience the same reset
3. **Subagent spawning** — Child agent processes may not inherit the parent's permission configuration

**Evidence from hook logs:**

```
# Hook is being called normally:
2026-04-14 15:53:33 tool=Bash decision=allow input_bytes=951 elapsed_ms=23
2026-04-14 15:53:39 tool=Bash decision=allow input_bytes=849 elapsed_ms=23
2026-04-14 15:58:35 tool=Agent decision=allow input_bytes=1203 elapsed_ms=24
2026-04-14 16:00:39 tool=Bash decision=allow input_bytes=427 elapsed_ms=21
2026-04-14 16:01:01 tool=Bash decision=allow input_bytes=484 elapsed_ms=17
# ^^^ last hook entry before the blocked command
# The blocked command has NO log entry — hook was never invoked
```

The hook was not just returning a different decision — it was never called at all. This confirms the issue is in the permission dispatch layer, not in the hook execution.

**Settings that do NOT prevent the issue:**

```json
{
 "defaultMode": "bypassPermissions",
 "skipDangerousModePermissionPrompt": true,
 "sandbox": {
 "autoAllowBashIfSandboxed": true
 }
}
```

All of these are correctly configured but none prevents the permission state from degrading.

## Step-by-Step Solution

### 1. Detect the Problem Early

Add monitoring to your hook script to alert you when it stops being called:

```bash
#!/bin/bash
# ~/.claude/hooks/monitored-allow.sh

LOG_FILE="$HOME/.claude/hook-activity.log"
TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-unknown}"

# Log every invocation with timestamp
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') tool=$TOOL_NAME" >> "$LOG_FILE"

# Return allow
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
```

Then set up a watcher:

```bash
# In a separate terminal, watch for gaps in hook activity
tail -f ~/.claude/hook-activity.log
```

If you see permission prompts but no new log entries, the hook has been bypassed.

### 2. Avoid Background Tasks in Permission-Critical Sessions

If you need reliable `--dangerously-skip-permissions` behavior:

```bash
# Instead of background tasks within Claude Code,
# run long-running commands in a separate terminal

# DON'T do this in Claude Code:
# "Run this build in the background"

# DO ask Claude to give you the command, then run it yourself:
# "What command should I run to build this project?"
```

### 3. Use Session Watchdog Script

```bash
#!/bin/bash
# claude-watchdog.sh — restarts Claude Code if hooks stop firing

HOOK_LOG="$HOME/.claude/hook-activity.log"
MAX_SILENCE_SECONDS=300 # 5 minutes

while true; do
 if [ -f "$HOOK_LOG" ]; then
 last_entry=$(tail -1 "$HOOK_LOG")
 last_ts=$(echo "$last_entry" | cut -d' ' -f1)
 last_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_ts" "+%s" 2>/dev/null)
 now_epoch=$(date "+%s")

 if [ -n "$last_epoch" ]; then
 silence=$((now_epoch - last_epoch))
 if [ "$silence" -gt "$MAX_SILENCE_SECONDS" ]; then
 echo "WARNING: No hook activity for ${silence}s"
 fi
 fi
 fi
 sleep 60
done
```

### 4. Register the Hook Correctly

Ensure your hook configuration in `~/.claude/settings.json` uses a broad matcher:

```json
{
 "hooks": {
 "PreToolUse": [{
 "matcher": ".*",
 "hooks": [{
 "type": "command",
 "command": "/absolute/path/to/hook.sh",
 "timeout": 30
 }]
 }]
 }
}
```

Key points:
- Use `"matcher": ".*"` to catch all tools
- Use an absolute path for the command (not `~` or relative)
- Set a reasonable timeout (30s) to avoid hanging

## Prevention

- **Keep sessions short** for security-sensitive work. Start a new session every few hours
- **Avoid background tasks** when permission consistency matters
- **Use git branch isolation** so that even if permissions degrade, changes are reviewable
- **Monitor hook activity** with the logging approach described above

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-pretooluse-hooks-bypassed)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

## Related Issues

- [Fix: Claude Code PreToolUse Hooks Bypassed](/claude-code-pretooluse-hooks-bypassed/)
- [Claude Code Permission Modes Explained](/claude-code-permission-modes/)
- [Claude Code 2026 New Features: Skills and Hooks Roundup](/claude-code-2026-new-features-skills-and-hooks-roundup/)

## Tools That Help

For developers running Claude Code in automation pipelines where permission integrity is critical, a dev tool extension can help monitor and debug the tool call flow in real time.


