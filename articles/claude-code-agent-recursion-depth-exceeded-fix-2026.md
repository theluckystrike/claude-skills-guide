---
title: "Agent Recursion Depth Exceeded Fix"
permalink: /claude-code-agent-recursion-depth-exceeded-fix-2026/
description: "Fix agent recursion depth exceeded in Claude Code. Set max turns limit and break circular task delegation to stop infinite subagent loops."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Maximum agent recursion depth exceeded (depth: 10)
Subagent spawned subagent which spawned subagent — circular delegation detected.
Aborting to prevent infinite loop.
```

This appears when a Claude Code agent delegates a task to a subagent, which then delegates back or spawns further subagents, creating a recursive chain that exceeds the maximum depth.

## The Fix

```bash
claude --max-turns 5 "Fix the bug in auth.ts"
```

1. Use `--max-turns` to limit how many turns Claude Code can take, which caps recursion depth.
2. If using the Agent tool in a CLAUDE.md or custom workflow, ensure tasks are specific enough that subagents do not re-delegate.
3. Restart the session with a clearer, more targeted prompt that does not require multi-level delegation.

## Why This Happens

Claude Code's agent architecture allows spawning subagents for complex tasks. When the task description is vague (like "fix all issues"), a subagent may interpret its subtask as equally broad and spawn its own subagent. Each level adds to the recursion depth until the safety limit triggers. This is especially common with custom hooks or skills that invoke Claude Code recursively.

## If That Doesn't Work

Disable subagent spawning entirely for the current task:

```bash
claude --disallowedTools "Agent" "Fix the bug in auth.ts"
```

Break the task into explicit sequential steps:

```bash
claude "Step 1: Read auth.ts. Step 2: Identify the null check bug on line 45. Step 3: Fix only that line."
```

Check for recursive hooks that might be triggering agent loops:

```bash
cat .claude/settings.json | grep -A5 "hooks"
```

## Prevention

```markdown
# CLAUDE.md rule
Never delegate tasks to subagents that are broader than the original task. Always specify exact files and line numbers when possible. Use --max-turns 10 for automated pipelines.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
