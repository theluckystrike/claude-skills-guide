---
layout: post
title: "How to Fix Claude Skill Infinite Loop Issues"
description: "Diagnose and fix infinite loop behavior in Claude Code skills: exit conditions, tool re-invocation, CLAUDE.md cycles, and recursive bash calls."
date: 2026-03-13
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging, troubleshooting, infinite-loop]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# How to Fix Claude Skill Infinite Loop Issue

An infinite loop in a Claude Code skill is one of the more disruptive problems you can encounter. The session hangs, tokens drain, and Claude keeps calling the same tool or repeating the same step without making progress. This guide explains why Claude skill infinite loops happen, how to break out of one, and how to redesign your skill to prevent it.

## What an Infinite Loop Looks Like in Claude Code

Unlike a traditional programming loop, a Claude skill infinite loop is not a binary branch that repeats forever. It is a behavior pattern where Claude keeps taking the same action because the skill instructions, tool results, or environment create conditions where no exit criterion is ever met.

Common symptoms:

- Claude calls `Bash` with the same command repeatedly (e.g., re-running a test that keeps failing)
- Claude reads and rewrites the same file in cycles, each time reverting a previous change
- A [`tdd`](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) or `frontend-design` workflow keeps generating new iterations without stopping
- The [`supermemory` skill](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) writes a memory entry, reads it back, and re-writes it in a loop
- Token usage spikes unusually fast for a simple task

## How to Stop an Active Loop

**Interrupt immediately:**
- Press `Ctrl+C` in the Claude Code terminal to interrupt the current operation
- Or type a message to break Claude's autonomous execution: `Stop. Do not make any more tool calls.`

Once interrupted:
```
Stop all current tasks. Summarize the last 5 actions you took and what you were trying to accomplish.
```

This breaks the execution pattern and gives you visibility into what Claude was doing.

## Root Cause 1: Ambiguous Exit Condition in Skill Instructions

The most common cause. Skill instructions like "keep fixing errors until all tests pass" create an implicit loop. If tests cannot pass (due to a real bug, missing dependency, or an incorrect test itself), Claude has no exit condition and will keep trying.

**Bad skill instruction pattern:**
```markdown
## Task
Run the test suite. Fix any failures. Repeat until all tests pass.
```

**Fixed — add an exit condition:**
```markdown
## Task
Run the test suite. For each failing test:
1. Attempt one fix per test.
2. Re-run to verify.
3. If the test still fails after one attempt, stop and report the failure.
Do not attempt more than one fix per test per invocation.
```

The `tdd` skill in well-maintained versions includes a maximum iteration count for exactly this reason.

## Root Cause 2: Tool Output Triggering Re-invocation

Some skill workflows read file output, process it, and write back. If the write changes the file in a way that the read step treats as "not done", the loop continues:

```
Read file → detect "TODO" → rewrite file → Read file → detect "TODO" → ...
```

This happens when the skill's definition of "done" is not deterministic — the output of step N looks identical to the input of step N to the condition check.

**Fix — add a completion marker:**

Instruct the skill to write a sentinel value when complete:

```markdown
## Completion
After processing the file, add `<!-- processed: YYYY-MM-DD -->` to the first line.
Before processing, check if this marker exists. If it does, stop.
```

## Root Cause 3: CLAUDE.md Skill Auto-Invocation Loop

If your `CLAUDE.md` includes an instruction to invoke a skill at the start of every session, and that skill itself modifies `CLAUDE.md`, you can create a session-to-session loop.

```markdown
<!-- CLAUDE.md — dangerous pattern -->
At session start, run /supermemory and update this file with current context.
```

If `supermemory` writes back to `CLAUDE.md`, the next session starts with a modified file that triggers the same write, which changes the file again.

**Fix — separate the skill trigger from the output target:**

```markdown
<!-- CLAUDE.md — safe pattern -->
At session start, run /supermemory to load context.
supermemory should read from ~/.claude-memory/, not write to this file.
```

## Root Cause 4: Recursive Bash Calls

A skill that instructs Claude to run a shell script, and that script invokes Claude again (e.g., via `claude --print`), can create a process-level loop.

**Check your scripts:**
```bash
grep -r "claude" scripts/
grep -r "claude" .claude/
```

If any script called by a skill also calls `claude`, you have a potential recursion path. Remove or guard those calls:

```bash
# Bad — script called by a skill that re-invokes claude
claude --print "Fix the error in $FILE"

# Safe — flag to prevent re-entry
if [ -n "$CLAUDE_SKILL_CONTEXT" ]; then
  echo "Already in claude context, skipping re-invocation"
  exit 0
fi
```

## Root Cause 5: The `frontend-design` Skill Rewriting Components Repeatedly

The `frontend-design` skill applied to an existing codebase can enter a loop if the skill's style instructions conflict with existing patterns. Claude rewrites the file to match the skill's conventions, reads it back, detects a remaining violation, and rewrites again — never reaching a clean state because the two style systems are incompatible.

**Fix — scope the skill to new files only:**

```
/frontend-design
Apply only to files I explicitly ask you to rewrite.
Do not proactively modify existing components.
```

Or reduce the skill to a review mode:
```
/frontend-design
Review src/Button.tsx and list violations. Do not rewrite the file.
```

## Root Cause 6: supermemory Re-reading Its Own Output

If `supermemory` stores a record, then is invoked again without a clear "what to do with memory" instruction, it may read its own previous session summaries, generate a new summary that includes the previous summary, and store that — exponentially growing the memory store.

**Fix — use explicit memory operations:**

```
/supermemory
READ the last checkpoint for project X.
Do not write a new checkpoint unless I explicitly ask.
```

## Preventing Loops in Custom Skills

When writing your own skills, follow these rules:

1. **Every loop has an explicit exit condition** — a maximum iteration count or a binary "done" check
2. **Processing steps are idempotent** — running the same step twice on an already-processed input produces no change
3. **Completion markers are written first** — write the "done" signal before finishing, so crashes do not cause re-runs from scratch
4. **Avoid re-reading files the skill just wrote** — unless there is a specific reason to verify the write

Example of a well-structured iterative skill instruction:

```markdown
## Iteration Rules
- Maximum 3 fix attempts per error
- After each attempt, re-run the check command
- If the error persists after 3 attempts, report it and stop — do not attempt further fixes
- If all errors are resolved, stop immediately
```

## Emergency Recovery After a Loop

If a loop consumed significant tokens or left your codebase in a partial state:

1. Run `git diff` to see all changes made during the loop
2. Run `git stash` if you want to review before keeping any changes
3. Check the `supermemory` store for corrupted entries: look in `~/.claude-memory/`
4. Restart Claude Code with a minimal prompt that does not re-trigger the skill

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Understanding the `max_turns` and `tools` fields helps you design skills with built-in loop prevention
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — Best practices for writing skill bodies that include clear exit conditions to prevent runaway execution
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — Auto-invocation can unexpectedly re-trigger skills in ways that create loops; this guide explains the full invocation model

Built by theluckystrike — More at [zovo.one](https://zovo.one)
