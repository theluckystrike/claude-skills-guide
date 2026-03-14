---
layout: default
title: "Claude Code Hooks System: Complete Guide"
description: "How Claude Code hooks work: configuring pre-tool, post-tool, and session hooks in settings.json to audit, modify, or block Claude's tool calls."
date: 2026-03-13
categories: [guides]
tags: [claude-code, hooks, settings, devops, security, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Hooks System: Complete Guide

Claude Code's hooks system gives you programmatic control over Claude's behavior at defined points in its execution lifecycle. Hooks let you log tool calls for auditing, block dangerous commands, inject context at session start, and enforce project rules without modifying skill files or prompts.

## What Are Hooks?

Hooks are executable scripts or commands that Claude Code calls at specific lifecycle events. They run as separate shell processes outside of Claude's context.

A hook receives event data via stdin as JSON and can:
- Pass through (exit 0 with the original data unchanged)
- Modify the event data (output modified JSON to stdout, exit 0)
- Block the event (exit non-zero, optionally print a reason to stderr)

Hooks never interact with the Claude model directly. They are a CLI-level interception layer.

## Hook Types

Claude Code defines three primary hook types.

### `pre-tool`

Fires before Claude executes any tool call. This is the most commonly used hook type.

Event data includes:
- `tool_name` — the tool being called (e.g., `bash`, `read_file`, `write_file`)
- `tool_input` — the arguments Claude is passing to the tool
- `session_id` — current session identifier
- `project_root` — path to the project root

Use cases: logging, blocking dangerous commands, enforcing project standards before file writes.

```json
{
  "event": "pre-tool",
  "tool_name": "bash",
  "tool_input": {
    "command": "rm -rf ./dist"
  },
  "session_id": "sess_abc123",
  "project_root": "/Users/dev/myapp"
}
```

### `post-tool`

Fires after a tool call completes, regardless of success or failure.

Event data includes everything from `pre-tool`, plus:
- `tool_output` — what the tool returned
- `tool_error` — error message if the tool failed (null otherwise)
- `duration_ms` — how long the tool call took

Use cases: logging outcomes, triggering external notifications, updating audit trails.

### `session`

Two sub-events: `session.start` and `session.end`.

`session.start` fires when Claude Code begins a new session. Use it to inject project context, validate environment variables, or initialize logging.

`session.end` fires when the session closes. Use it to write summary logs, clean up temp files, or sync state.

## Hook Configuration

Hooks are defined in `.claude/settings.json` under the `"hooks"` key:

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

For `session`:
- `event`: `"session.start"`, `"session.end"`, or both

Multiple hooks of the same type run in order. If any hook exits non-zero, subsequent hooks do not run for that event.

## Writing a Hook Script

A complete Python hook that blocks `bash` commands containing `rm -rf`:

```python
#!/usr/bin/env python3
# .claude/hooks/no-dangerous-rm.py

import sys
import json

data = json.load(sys.stdin)

if data.get("tool_name") == "bash":
    command = data.get("tool_input", {}).get("command", "")
    if "rm -rf" in command:
        print("Blocked: rm -rf is not allowed in this project", file=sys.stderr)
        sys.exit(1)

# Pass through: output the original data unchanged
print(json.dumps(data))
sys.exit(0)
```

Register it in `.claude/settings.json`:

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

## Modifying Tool Input

A hook can modify the event data before it is processed. Output modified JSON to stdout and exit 0.

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

## Hook Performance

Hooks are synchronous — Claude Code waits for each hook to complete before proceeding. Slow hooks slow down every relevant operation.

Keep hooks fast. If you need to do heavy async work such as sending data to a logging service, write to a local queue file and process it separately rather than doing network I/O synchronously in the hook.

## Global vs Project Hooks

Like skills, hooks can be configured globally (`~/.claude/settings.json`) or per project (`.claude/settings.json`). Both sets are loaded. Global hooks run first, then project hooks. This is different from [auto-invocation](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/), which is skill-level behavior. They stack — there is no override mechanism that prevents a global hook from running.

This lets you have a global audit hook that logs all tool calls, plus project-specific hooks that enforce project-specific rules, without conflict.

## Example: Session Start Context Injection

A session start hook that prints a summary of active tasks in `.claude/state/`:

```python
#!/usr/bin/env python3
# .claude/hooks/session-start.py
import sys, json, glob

event = json.load(sys.stdin) if not sys.stdin.isatty() else {}

state_files = glob.glob(".claude/state/*.json")
active = []

for f in state_files:
    try:
        with open(f) as fp:
            s = json.load(fp)
        if s.get("status") == "in_progress":
            p = s.get("progress", {})
            active.append(
                f"- {s['task_id']}: {p.get('completed', 0)}/{p.get('total_files', '?')} complete"
            )
    except Exception:
        pass

if active:
    event["injected_context"] = "ACTIVE TASKS:\n" + "\n".join(active)

print(json.dumps(event))
sys.exit(0)
```

Register it:
```json
{
  "hooks": {
    "session": [
      {
        "matcher": { "event": ["session.start"] },
        "command": "python3 .claude/hooks/session-start.py"
      }
    ]
  }
}
```

---

## Related Reading

- [Building Stateful Agents with Claude Skills](/claude-skills-guide/building-stateful-agents-with-claude-skills-guide/) — Hooks are core to stateful agent design
- [Claude Skill .md File Format: Full Specification](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Skill file format reference
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Top developer skills that work well with hooks


Built by theluckystrike — More at [zovo.one](https://zovo.one)
