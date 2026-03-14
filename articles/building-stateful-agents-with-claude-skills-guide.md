---
layout: default
title: "Building Stateful Agents with Claude Skills: Complete Guide"
description: "Design Claude Code agents that maintain state across turns and sessions using files, supermemory, and structured state management patterns."
date: 2026-03-13
categories: [advanced]
tags: [claude-code, claude-skills, agents, state-management, supermemory]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Building Stateful Agents with Claude Skills

Claude Code is stateless by default. Each session starts fresh, and within a session, each tool call is independent. But real-world agents need to track progress, remember past decisions, and resume interrupted work. This guide shows you how to build genuinely stateful agents using Claude skills.

## What Stateful Means for AI Agents

A stateful agent can answer these questions reliably:
- What have I done so far in this task?
- What do I need to do next?
- What decisions did I make and why?
- Where should I resume if interrupted?

Statefulness in Claude Code is achieved by writing state to durable storage — files, databases, or the [`/supermemory` skill](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — and reading it back at the start of each invocation.

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

Include state management instructions in your skill's markdown body:

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

The skill needs to read and write the state file as part of its execution. Template the exact pattern in the skill body:

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

This means you can interrupt the agent, close Claude Code, reopen it, invoke the same skill again, and it picks up where it left off. This pattern is especially useful with skills like the [**tdd** skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) where test generation tasks may span multiple sessions.

## Long-Running Task Patterns

For tasks that take more than a few minutes, design the skill to work in bounded chunks:

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

The state file pattern handles task progress well, but the `/supermemory` skill is better suited for decisions about how to approach problems.

When the agent makes a significant decision, store it using the `/supermemory` skill:

```
/supermemory
Store testing decision for this project:
Using msw for API mocking because the project already uses it in auth tests.
Pattern: server = setupServer(...handlers)
Apply this pattern to all future API test files.
```

On future invocations, load the project's established conventions:

```
/supermemory
Retrieve all stored testing decisions and conventions for this project.
```

This ensures future invocations know the established conventions without having to re-discover them from scratch.

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
    summary = f"ACTIVE TASKS ({len(active_tasks)}):\n"
    for task in active_tasks:
        p = task.get("progress", {})
        summary += f"- {task['task_id']}: {p.get('completed', 0)}/{p.get('total_files', '?')} complete. Next: {task.get('next_action', 'unknown')}\n"

    event_data = json.load(sys.stdin) if not sys.stdin.isatty() else {}
    event_data["injected_context"] = summary
    print(json.dumps(event_data))

sys.exit(0)
```

Configure this hook in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "Read" },
        "command": ".claude/hooks/load-agent-state.py"
      }
    ]
  }
}
```

### Session End Hook for State Checkpointing

```python
#!/usr/bin/env python3
# .claude/hooks/checkpoint-state.py
import sys, json, datetime, glob

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
2. After 7 days, the state file can be deleted:
   bash("find .claude/state -mtime +7 -name '*.json' -delete")
3. Never delete state files for in_progress tasks
```

## Anti-Patterns in Stateful Skill Design

**Storing state in conversation history**: Conversation history is ephemeral and grows unbounded. Do not use it as your primary state store.

**State writes inside bash scripts**: Writing state via `bash("echo '{}' > state.json")` bypasses the `write_file` tool's logging and hook system. Always use `write_file` for state updates.

**Unbounded task size**: Do not design a skill that tries to complete an entire codebase in one invocation. Break work into chunks and use state to track progress between invocations.

**No failure handling in state**: If you only track successful completions, failed files will be silently retried on every invocation. Always record failures with their error context.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Top skills every developer should know
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Keep long-running agents cost-efficient


Built by theluckystrike — More at [zovo.one](https://zovo.one)
