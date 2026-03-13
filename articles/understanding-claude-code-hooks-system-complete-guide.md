---
layout: default
title: "Understanding Claude Code Hooks System: Complete Guide"
description: "A complete guide to Claude Code's hooks system — how to use pre-tool, post-tool, pre-skill, and session hooks to extend, audit, and control Claude's behavior."
date: 2026-03-13
author: theluckystrike
---

# Understanding Claude Code Hooks System: Complete Guide

Claude Code's hooks system gives you programmatic control over Claude's behavior at defined points in its execution lifecycle. Whether you want to log every file write for auditing, block certain tool calls in production environments, or inject context before a skill runs, hooks are the mechanism to do it.

## What Are Hooks?

Hooks are executable scripts or commands that Claude Code calls at specific lifecycle events. They run outside of Claude's context — they're shell processes invoked by the Claude Code CLI itself.

A hook receives event data via stdin as JSON and can:
- Pass through (exit 0, no output required)
- Modify the event data (output modified JSON to stdout)
- Block the event (exit non-zero, optionally print a reason to stderr)

Hooks never interact with the Claude model directly. They're a CLI-level interception layer, not a prompt-level one.

## Hook Types

Claude Code defines four hook types, each firing at a different lifecycle point.

### `pre-tool`

Fires before Claude executes any tool call. This is the most commonly used hook type.

Event data includes:
- `tool_name` — the name of the tool (e.g., `bash`, `read_file`, `write_file`)
- `tool_input` — the arguments Claude is passing to the tool
- `session_id` — current session identifier
- `project_root` — path to the project root
- `skill` — name of the currently active skill (if any), or null

Use cases: logging, blocking dangerous commands, enforcing coding standards before writes.

```json
{
  "event": "pre-tool",
  "tool_name": "bash",
  "tool_input": {
    "command": "rm -rf ./dist"
  },
  "session_id": "sess_abc123",
  "project_root": "/Users/dev/myapp",
  "skill": null
}
```

### `post-tool`

Fires after a tool call completes, regardless of success or failure.

Event data includes everything from `pre-tool`, plus:
- `tool_output` — what the tool returned
- `tool_error` — error message if the tool failed (null otherwise)
- `duration_ms` — how long the tool call took

Use cases: logging outcomes, triggering external notifications, updating audit trails.

### `pre-skill`

Fires before a skill is invoked (both manual and auto-invocation).

Event data includes:
- `skill_name` — name of the skill about to be invoked
- `trigger_phrase` — the phrase that matched (for auto-invocation), or null for manual
- `trigger_score` — the similarity score (for auto-invocation), or null
- `user_input` — the user's original message
- `session_id`

Use cases: skill access control (only certain users can invoke certain skills), pre-loading context, logging skill usage.

### `session`

Two sub-events: `session.start` and `session.end`.

`session.start` fires when Claude Code begins a new session. Use it to inject project context, validate environment variables, or set up logging.

`session.end` fires when the session closes (normally or via Ctrl+C). Use it to write summary logs, clean up temp files, or sync state.

## Hook Configuration

Hooks are defined in `.claude/settings.json`:

```json
{
  "hooks": {
    "pre-tool": [
      {
        "matcher": {
          "tool_name": ["bash", "write_file"]
        },
        "command": "python3 .claude/hooks/audit.py"
      }
    ],
    "post-tool": [
      {
        "matcher": {},
        "command": "/usr/local/bin/log-tool-call"
      }
    ],
    "pre-skill": [
      {
        "matcher": {
          "skill_name": ["pdf", "docx"]
        },
        "command": ".claude/hooks/check-skill-permissions.sh"
      }
    ],
    "session": [
      {
        "matcher": {
          "event": ["session.start"]
        },
        "command": ".claude/hooks/setup.sh"
      }
    ]
  }
}
```

### Matchers

The `matcher` object filters which events trigger the hook command. An empty matcher `{}` matches all events of that type.

For `pre-tool` and `post-tool`:
- `tool_name`: array of tool names to match
- `skill`: skill name to match (only fires when this skill is active)

For `pre-skill`:
- `skill_name`: array of skill names to match

For `session`:
- `event`: `"session.start"`, `"session.end"`, or both

Multiple hooks of the same type run in order. If any hook blocks (exits non-zero), subsequent hooks do not run.

## Writing a Hook Script

Here's a complete Python hook that blocks `bash` commands containing `rm -rf`:

```python
#!/usr/bin/env python3
# .claude/hooks/no-dangerous-rm.py

import sys
import json

data = json.load(sys.stdin)

if data.get("tool_name") == "bash":
    command = data.get("tool_input", {}).get("command", "")
    if "rm -rf" in command and "/" in command:
        print("Blocked: rm -rf on paths is not allowed in this project", file=sys.stderr)
        sys.exit(1)

# Pass through: output the original data unchanged
print(json.dumps(data))
sys.exit(0)
```

Register it:

```json
{
  "hooks": {
    "pre-tool": [
      {
        "matcher": { "tool_name": ["bash"] },
        "command": "python3 .claude/hooks/no-dangerous-rm.py"
      }
    ]
  }
}
```

## Modifying Tool Input with Hooks

A hook can modify the event data before it's processed. To do this, output modified JSON to stdout and exit 0.

Example: a hook that appends `--dry-run` to all `npm publish` commands:

```python
#!/usr/bin/env python3
import sys
import json

data = json.load(sys.stdin)

if data.get("tool_name") == "bash":
    cmd = data.get("tool_input", {}).get("command", "")
    if "npm publish" in cmd and "--dry-run" not in cmd:
        data["tool_input"]["command"] = cmd + " --dry-run"

print(json.dumps(data))
sys.exit(0)
```

## Hooks and Skills

The `skill` field in `pre-tool` events tells you which skill (if any) is currently active. This lets you write hooks that apply different rules depending on which skill is running.

For example, allow the `pdf` skill to write to the `output/` directory, but block all other contexts from writing there:

```python
import sys, json, os

data = json.load(sys.stdin)

if data["tool_name"] == "write_file":
    path = data["tool_input"].get("path", "")
    active_skill = data.get("skill")
    if path.startswith("output/") and active_skill != "pdf":
        print(f"Blocked: only the pdf skill can write to output/", file=sys.stderr)
        sys.exit(1)

print(json.dumps(data))
sys.exit(0)
```

## Hook Timeouts and Performance

Hooks are synchronous — Claude Code waits for each hook to complete before proceeding. If your hook is slow, it will slow down every relevant operation.

Default timeout: **5 seconds**. Hooks that exceed this are killed and treated as pass-through (they cannot block events if they time out).

Configure per-hook timeout:

```json
{
  "command": "python3 .claude/hooks/slow-audit.py",
  "timeout_ms": 10000
}
```

Keep hooks fast. If you need to do heavy async work (send data to a logging service, etc.), write to a queue file and process it separately — don't do network I/O synchronously in hooks.

## Debugging Hooks

Enable hook debug output in your Claude Code session:

```
/hooks debug on
```

This prints each hook invocation and its result to the session output, which helps diagnose why a hook is or isn't firing.

Check hook logs directly:

```
/hooks log
```

This shows the last 50 hook events with their inputs, outputs, and exit codes.

## Global vs Project Hooks

Like skills, hooks can be global (`~/.claude/settings.json`) or project-level (`.claude/settings.json`). Both are loaded and run — global hooks run first, then project hooks. There is no override mechanism for hooks; they stack.

This means you can have a global audit hook that logs everything, plus project-specific hooks that enforce project rules, and both will run without conflict.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
