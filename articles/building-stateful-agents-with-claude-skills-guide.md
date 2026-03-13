---
layout: default
title: "Building Stateful Agents with Claude Skills: Complete Guide"
description: "How to design and build Claude Code agents that maintain state across turns, sessions, and invocations — using files, supermemory, and structured state management."
date: 2026-03-13
author: theluckystrike
---

# Building Stateful Agents with Claude Skills: Complete Guide

Claude Code is stateless by default. Each session starts fresh, and within a session, each tool call is independent. But real-world agents need to track progress, remember past decisions, and resume interrupted work. This guide shows you how to build genuinely stateful agents using Claude skills.

## What "Stateful" Means for AI Agents

A stateful agent can answer these questions reliably:
- What have I done so far in this task?
- What do I need to do next?
- What decisions did I make and why?
- Where should I resume if interrupted?

Statefulness in Claude Code is achieved by writing state to durable storage — files, databases, or the supermemory system — and reading it back at the start of each invocation.

## The State File Pattern

The most reliable approach: maintain a structured state file that the skill reads at the start of every invocation and updates throughout execution.

### State File Schema

```json
{
  "task_id": "sprint-15-test-coverage",
  "status": "in_progress",
  "started_at": "2026-03-13T09:00:00Z",
  "last_updated": "2026-03-13T09:45:00Z",
  "progress": {
    "total_files": 47,
    "completed": 23,
    "failed": 2,
    "remaining": 22
  },
  "completed_files": [
    "src/auth/login.ts",
    "src/auth/logout.ts"
  ],
  "failed_files": [
    {
      "file": "src/api/webhooks.ts",
      "error": "Complex async patterns require manual review",
      "timestamp": "2026-03-13T09:30:00Z"
    }
  ],
  "decisions": [
    {
      "decision": "Use msw for API mocking instead of jest.mock",
      "reason": "Project already uses msw in 3 other test files",
      "timestamp": "2026-03-13T09:05:00Z"
    }
  ],
  "next_action": "Process src/api/payments.ts"
}
```

### Reading State in the Skill Body

```
At the start of every invocation:
1. Check if .claude/state/{task_id}.json exists
2. If it exists, read the state file and continue from where you left off
3. If it doesn't exist, initialize a new state file with the task details
4. Never restart completed work — check completed_files before processing any file

State file location: .claude/state/{task_id}.json
If no task_id is provided, derive one from the task description: lowercase, spaces to hyphens.
```

### Updating State After Each Step

```
After each file is processed:
1. Add the file to completed_files (or failed_files with error details)
2. Update progress.completed count
3. Update last_updated timestamp
4. Write the updated state back to the state file
5. Set next_action to the next file to process

Always write state immediately after completing each unit of work.
Do not batch state updates — if interrupted mid-task, the state file should
accurately reflect completed work.
```

## Implementing State Updates via Tool Calls

The skill needs to read and write the state file as part of its execution. In the skill body, template the exact pattern:

```
State management procedure:
1. At start: read_file(".claude/state/{task_id}.json")
   - If file not found: initialize with {status: "starting", completed_files: [], ...}
2. After each unit of work: write_file(".claude/state/{task_id}.json", updated_state)
3. At completion: update status to "complete" and write final state

State writes must happen via write_file, not via bash echo or Python scripts.
```

## Resumable Task Design

A well-designed stateful skill should be safe to invoke multiple times for the same task:

```
Idempotency rules:
- Before processing any file, check if it's already in completed_files
- If a file is in completed_files, skip it and log "already done"
- If a file is in failed_files, attempt it once more with additional context
  from the failure error message, then mark it permanently failed if it fails again
- Never write over a completed test file without explicit user confirmation
```

This means you can interrupt the agent, close Claude Code, reopen it, invoke the same skill again, and it picks up where it left off.

## Long-Running Task Patterns

For tasks that take more than a few minutes (like generating tests for an entire codebase), design the skill to work in bounded chunks:

```
Chunk-based processing:
- Process at most 5 files per invocation
- After 5 files, stop and report progress
- The user can re-invoke the skill to continue
- Use the state file to track position across invocations

This prevents context window exhaustion and allows the user to review
progress incrementally rather than waiting for a multi-hour run to complete.
```

## The supermemory Skill for Decision Memory

The state file pattern handles task progress well, but it's not the right tool for decisions about how to approach problems. For that, the `supermemory` skill is more appropriate.

Configure your skill to work with supermemory for decision persistence:

```yaml
---
name: tdd
memory: true
memory_scope: project
---
```

Then in the skill body:

```
When you make a significant decision about how to approach testing in this project
(e.g., choosing a mocking strategy, deciding on test file structure, establishing
naming conventions), use remember() to save it:

remember("Testing decision: Using msw for API mocking because the project already 
uses it in auth tests. Pattern: server = setupServer(...handlers)")

This ensures future invocations of this skill know the established conventions
without having to re-discover them.
```

## Agent Lifecycle Management

A complete stateful agent needs lifecycle management: initialization, execution, checkpointing, and cleanup.

### Session Start Hook for State Loading

Use a `session.start` hook to load any relevant agent state at the beginning of a session:

```python
#!/usr/bin/env python3
# .claude/hooks/load-agent-state.py
import sys, json, glob, os

# Find active tasks in the state directory
state_files = glob.glob(".claude/state/*.json")
active_tasks = []

for state_file in state_files:
    with open(state_file) as f:
        state = json.load(f)
    if state.get("status") == "in_progress":
        active_tasks.append({
            "task_id": state["task_id"],
            "progress": state.get("progress", {}),
            "next_action": state.get("next_action")
        })

if active_tasks:
    # Inject summary into session context via stdout
    summary = f"ACTIVE TASKS ({len(active_tasks)}):\n"
    for task in active_tasks:
        p = task.get("progress", {})
        summary += f"- {task['task_id']}: {p.get('completed', 0)}/{p.get('total_files', '?')} complete. Next: {task.get('next_action', 'unknown')}\n"
    
    event_data = json.load(sys.stdin) if not sys.stdin.isatty() else {}
    event_data["injected_context"] = summary
    print(json.dumps(event_data))

sys.exit(0)
```

### Session End Hook for State Checkpointing

```python
#!/usr/bin/env python3
# .claude/hooks/checkpoint-state.py
import sys, json, datetime, glob

# Update last_checkpoint timestamp on all active tasks
for state_file in glob.glob(".claude/state/*.json"):
    with open(state_file) as f:
        state = json.load(f)
    
    if state.get("status") == "in_progress":
        state["last_checkpoint"] = datetime.datetime.utcnow().isoformat()
        with open(state_file, "w") as f:
            json.dump(state, f, indent=2)

sys.exit(0)
```

## State Cleanup

Old state files accumulate. Include cleanup in your skill:

```
When a task reaches "complete" or "cancelled" status:
1. Keep the state file for 7 days (for debugging and auditing)
2. After 7 days, the state file can be deleted with: bash("find .claude/state -mtime +7 -delete")
3. Never delete state files for in_progress tasks

You can list state files with: list_directory(".claude/state/")
```

## Anti-Patterns in Stateful Skill Design

**Storing state in conversation history**: Conversation history is ephemeral and grows unbounded. Don't use it as your primary state store.

**State writes inside bash scripts**: Writing state via `bash("echo '{}' > state.json")` bypasses the `write_file` tool's logging and hook system. Always use `write_file` for state updates.

**Unbounded task size**: Don't design a skill that tries to complete an entire codebase in one invocation. Break work into chunks and use state to track progress between invocations.

**No failure handling in state**: If you only track successful completions, failed files will be silently retried on every invocation. Always record failures with their error context.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
