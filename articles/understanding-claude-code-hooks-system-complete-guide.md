---
layout: default
title: "Claude Code Hooks System (2026)"
description: "How Claude Code hooks work: configuring pre-tool, post-tool, and session hooks in settings.json to audit, modify, or block Claude's tool calls."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-skills, claude-code, hooks, settings, devops, security, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /understanding-claude-code-hooks-system-complete-guide/
geo_optimized: true
---

# Claude Code Hooks System: Complete Guide

[Claude Code's hooks system gives you programmatic control over Claude's behavior at defined points in its execution lifecycle](/best-claude-code-skills-to-install-first-2026/) Hooks let you log tool calls for auditing, block dangerous commands, inject context at session start, and enforce project rules without modifying skill files or prompts.

What Are Hooks?

Hooks are executable scripts or commands that Claude Code calls at specific lifecycle events. They run as separate shell processes outside of Claude's context.

A hook receives event data via stdin as JSON and can:
- Pass through (exit 0 with the original data unchanged)
- Modify the event data (output modified JSON to stdout, exit 0)
- Block the event (exit non-zero, optionally print a reason to stderr)

Hooks never interact with the Claude model directly. They are a CLI-level interception layer. This is a crucial distinction: hooks operate on the tool calls that Claude issues, not on Claude's reasoning or outputs. You cannot use hooks to rewrite Claude's prose responses, but you can intercept every file it reads, every command it runs, and every file it writes.

This design has important implications for how you think about hooks. They are not middleware in a request/response pipeline. they are gatekeepers and observers at the tool execution boundary. Claude decides it wants to run `rm -rf ./dist`, but before that command reaches the shell, your hook has the opportunity to allow, block, or modify it.

## Hook Types

Claude Code defines three primary hook types.

`pre-tool`

Fires before Claude executes any tool call. This is the most commonly used hook type.

Event data includes:
- `tool_name`. the tool being called (e.g., `Bash`, `Read`, `Write`)
- `tool_input`. the arguments Claude is passing to the tool
- `session_id`. current session identifier
- `project_root`. path to the project root

Use cases: logging, blocking dangerous commands, enforcing project standards before file writes.

```json
{
 "event": "pre-tool",
 "tool_name": "Bash",
 "tool_input": {
 "command": "rm -rf ./dist"
 },
 "session_id": "sess_abc123",
 "project_root": "/Users/dev/myapp"
}
```

The `pre-tool` hook is where you enforce policy. If your project prohibits certain shell commands, disallows writes to protected directories, or requires that every file modification is associated with an open task, this is the hook type you want. Because it fires before the tool executes, you can prevent damage rather than reacting to it.

`post-tool`

Fires after a tool call completes, regardless of success or failure.

Event data includes everything from `pre-tool`, plus:
- `tool_output`. what the tool returned
- `tool_error`. error message if the tool failed (null otherwise)
- `duration_ms`. how long the tool call took

Use cases: logging outcomes, triggering external notifications, updating audit trails.

The `post-tool` hook is valuable for observability. You can record that a file was written and what it contained, track how long Bash commands take over a session, or detect when Claude encounters repeated errors trying the same approach. This data is useful both for debugging Claude's behavior in a specific session and for improving your prompts and skills over time.

One practical pattern: write all `post-tool` events to an append-only JSONL file during a session, then analyze it afterward to understand where Claude spent time, what commands it ran, and where it got stuck.

`session`

Two sub-events: `session.start` and `session.end`.

`session.start` fires when Claude Code begins a new session. Use it to inject project context, validate environment variables, or initialize logging.

`session.end` fires when the session closes. Use it to write summary logs, clean up temp files, or sync state.

Session hooks are often overlooked but are among the most powerful. A well-crafted `session.start` hook can give Claude a precise picture of what work is in progress before it reads a single file. Instead of relying on Claude to discover state by exploring directories, you hand it a structured summary the moment it starts. This is particularly useful for long-running projects where Claude operates in many short sessions.

## Hook Configuration

Hooks are defined in `.claude/settings.json` under the `"hooks"` key:

```json
{
 "hooks": {
 "pre-tool": [
 {
 "matcher": {
 "tool_name": ["Bash", "Write"]
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

## Matchers

The `matcher` object filters which events trigger the hook command. An empty matcher `{}` matches all events of that type.

For `pre-tool` and `post-tool`:
- `tool_name`: array of tool names to match

For `session`:
- `event`: `"session.start"`, `"session.end"`, or both

Multiple hooks of the same type run in order. If any hook exits non-zero, subsequent hooks do not run for that event.

Understanding matcher specificity matters when you have multiple hooks. A hook matching only `["Bash"]` will not fire for `Write` calls. An empty matcher fires for everything. Order them so that the broadest hooks come last and specific blocking hooks come first. this keeps your security-critical checks fast because they short-circuit before logging hooks run.

## Writing a Hook Script

A complete Python hook that blocks `bash` commands containing `rm -rf`:

```python
#!/usr/bin/env python3
.claude/hooks/no-dangerous-rm.py

import sys
import json

data = json.load(sys.stdin)

if data.get("tool_name") == "bash":
 command = data.get("tool_input", {}).get("command", "")
 if "rm -rf" in command:
 print("Blocked: rm -rf is not allowed in this project", file=sys.stderr)
 sys.exit(1)

Pass through: output the original data unchanged
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

A few things worth noting about this script. First, it reads from stdin exactly once. do not read stdin in a loop or you will hang. Second, on the pass-through path it outputs the original JSON to stdout. If you forget to output JSON on the pass-through path and just exit 0, the hook chain may behave unexpectedly. Third, the error message on stderr is surfaced to Claude Code's output, so make it informative. Claude may see it and adjust its approach.

## Modifying Tool Input

A hook can modify the event data before it is processed. Output modified JSON to stdout and exit 0.

a hook that appends `--dry-run` to all `npm publish` commands:

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

Modification hooks are powerful but require care. You are changing what Claude believes it requested. If you silently modify a command and something goes wrong, the discrepancy between what Claude intended and what actually ran can be confusing to debug. Consider logging any modification you make in addition to performing it, so you have a record of what was changed and why.

A more complex modification pattern: rewriting file paths. If your project has a staging directory and you want all Write calls to go there during a review session, a hook can intercept every `Write` call and remap the path from `src/` to `staging/src/`. Claude continues to work as if writing to the production path, but the actual file operations go to staging.

```python
#!/usr/bin/env python3
.claude/hooks/redirect-to-staging.py
import sys
import json

data = json.load(sys.stdin)

if data.get("tool_name") == "Write":
 file_path = data.get("tool_input", {}).get("file_path", "")
 if file_path.startswith("/Users/dev/myapp/src/"):
 new_path = file_path.replace(
 "/Users/dev/myapp/src/",
 "/Users/dev/myapp/staging/src/"
 )
 data["tool_input"]["file_path"] = new_path
 print(f"Redirected write: {file_path} -> {new_path}", file=sys.stderr)

print(json.dumps(data))
sys.exit(0)
```

## Hook Performance

Hooks are synchronous. Claude Code waits for each hook to complete before proceeding. Slow hooks slow down every relevant operation.

Keep hooks fast. If you need to do heavy async work such as sending data to a logging service, write to a local queue file and process it separately rather than doing network I/O synchronously in the hook.

Here is a practical pattern for async logging without blocking Claude:

```python
#!/usr/bin/env python3
.claude/hooks/async-audit.py
import sys
import json
import os
import time

data = json.load(sys.stdin)

Write to a local JSONL file. fast, non-blocking
log_path = os.path.join(
 os.environ.get("PROJECT_ROOT", "."),
 ".claude/logs/audit.jsonl"
)
os.makedirs(os.path.dirname(log_path), exist_ok=True)

entry = dict(data)
entry["logged_at"] = time.time()

with open(log_path, "a") as f:
 f.write(json.dumps(entry) + "\n")

print(json.dumps(data))
sys.exit(0)
```

A separate process (cron job, background daemon, or post-session script) can then ship those entries to your logging infrastructure without any impact on Claude's response time.

## Global vs Project Hooks

Like skills, hooks can be configured globally (`~/.claude/settings.json`) or per project (`.claude/settings.json`). Both sets are loaded. Global hooks run first, then project hooks. This is different from [auto-invocation](/claude-skills-auto-invocation-how-it-works/), which is skill-level behavior. They stack. there is no override mechanism that prevents a global hook from running.

This lets you have a global audit hook that logs all tool calls, plus project-specific hooks that enforce project-specific rules, without conflict.

A practical layered setup might look like this:

| Scope | Hook | Purpose |
|---|---|---|
| Global | `post-tool` logger | Records every tool call across all projects |
| Global | `pre-tool` safety check | Blocks known dangerous patterns everywhere |
| Project | `pre-tool` path guard | Prevents writes outside project root |
| Project | `session.start` context | Injects project-specific task state |
| Project | `session.end` cleanup | Commits log files, cleans temp directories |

The global hooks give you a consistent baseline of observability and safety. The project hooks give you fine-grained control for that project's specific needs. Neither interferes with the other.

## Session Start Context Injection

A session start hook that prints a summary of active tasks in `.claude/state/`:

```python
#!/usr/bin/env python3
.claude/hooks/session-start.py
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

## Debugging Hooks

When a hook behaves unexpectedly, the first step is to test it in isolation. Because hooks read from stdin and write to stdout, you can pipe test JSON directly:

```bash
echo '{"event":"pre-tool","tool_name":"Bash","tool_input":{"command":"rm -rf ./dist"}}' \
 | python3 .claude/hooks/no-dangerous-rm.py
```

If the hook exits non-zero, check the exit code and stderr output. If it passes through when it should block, add debug prints to stderr (they appear in Claude Code's output without affecting the hook protocol).

Common mistakes:
- Forgetting to `print(json.dumps(data))` on the pass-through path
- Reading stdin twice (the second read returns empty)
- Assuming `tool_name` casing. check whether it is `"bash"` or `"Bash"` for your version
- Slow hooks caused by imports that take time to initialize. pre-import heavy libraries at the top of the file

## Comparing Hook Types: When to Use Each

| Scenario | Hook Type |
|---|---|
| Block dangerous shell commands | `pre-tool` on `Bash` |
| Prevent writes to protected files | `pre-tool` on `Write` |
| Rewrite file paths to staging | `pre-tool` on `Write` |
| Log all tool calls to JSONL | `post-tool`, empty matcher |
| Alert on failed commands | `post-tool`, check `tool_error` |
| Inject task state at session start | `session`, `session.start` |
| Write session summary to file | `session`, `session.end` |
| Clean up temp files after session | `session`, `session.end` |

The hooks system rewards incremental adoption. Start with a simple `post-tool` logger so you can see what Claude is actually doing. Once you understand the patterns in your own usage, add targeted `pre-tool` guards for the operations you care about. Session hooks are a final layer that pays dividends on projects where Claude operates in many short sessions and needs state continuity between them.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=understanding-claude-code-hooks-system-complete-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading


- [Advanced Usage Guide](/advanced-usage/). Power user techniques and advanced patterns
- [Building Stateful Agents with Claude Skills](/building-stateful-agents-with-claude-skills-guide/). Hooks are core to stateful agent design
- [Claude Skill .md File Format: Full Specification](/claude-skill-md-format-complete-specification-guide/). Skill file format reference
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Top developer skills that work well with hooks
- [2,675 Articles to 496 Clicks: AI Content Lessons](/ai-content-at-scale-lessons-2675-articles/)
- [Claude Code Developer Census 2026](/claude-code-developer-census-2026/)
- [What 1,024 Queries Reveal About Claude Code Users](/claude-code-search-query-analysis-2026/)
- [Claude Code Beta Features: How to Access and Use Them](/claude-code-beta-features-how-to-access/)
- [Zero-Click Crisis: 26,619 Wasted Impressions](/claude-code-zero-click-crisis-2026-study/)
- [Claude Code Client Library Generation Guide](/claude-code-client-library-generation-guide/)
- [Why Senior Developers Prefer Claude Code (2026)](/why-do-senior-developers-prefer-claude-code-2026/)
- [Claude Code Fortran Scientific — Complete Developer Guide](/claude-code-fortran-scientific-code-modernization-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


