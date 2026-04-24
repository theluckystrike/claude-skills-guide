---
layout: default
title: "Claude Code Multi-Agent Subagent"
description: "Design multi-agent workflows with Claude Code: spawn subagents, pass context between agents, and coordinate parallel work using print mode."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [advanced]
tags: [claude-code, claude-skills, multi-agent, automation, agentic]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-multi-agent-subagent-communication-guide/
geo_optimized: true
---

# Claude Code Multi-Agent and Subagent Communication Guide

[Claude Code supports multi-agent workflows where a primary agent orchestrates one or more subagents](/best-claude-code-skills-to-install-first-2026/), each running in isolated sessions with their own context. This architecture enables parallel work, task specialization, and complex autonomous workflows that single-session approaches cannot handle cleanly.

## The Multi-Agent Mental Model

In a multi-agent Claude Code setup:

- Orchestrator: A Claude Code session (or shell script) that breaks tasks into pieces and assigns them
- Subagents: Claude Code instances run in print mode (`claude -p "..."`) to handle specific tasks
- Shared state: Files, directories, or JSON that agents use to communicate

Each subagent runs in [its own isolated environment](/claude-agent-sandbox-skill-isolated-environments/) with a fresh context window, which means inter-agent communication must be explicit.

The orchestrator writes task specifications, subagents execute them and write results, and the orchestrator aggregates and reports.

## Spawning Subagents

Claude Code subagents run using the `-p` (print mode) flag, which runs a non-interactive session, outputs to stdout, and exits. You capture the output in your orchestration script:

```bash
#!/bin/bash
Spawn a subagent to write tests for one file

SOURCE_FILE="$1"
OUTPUT_FILE="$2"

RESULT=$(claude -p "/tdd Write comprehensive Jest tests for $SOURCE_FILE. Output only the test file content." 2>/dev/null)

echo "$RESULT" > "$OUTPUT_FILE"
echo "Subagent complete: $SOURCE_FILE -> $OUTPUT_FILE"
```

This is the correct way to invoke Claude Code non-interactively. There are no `--skill`, `--input-file`, or `--non-interactive` flags in the Claude Code CLI.

## Communication Patterns

1. File-Based Message Passing

The simplest and most reliable pattern: agents communicate via files in a shared directory.

```
.claude/
 agent-tasks/
 task-001.json # Written by orchestrator
 task-002.json
 agent-results/
 result-001.md # Written by subagent
 result-002.md
 agent-status/
 task-001.status # "pending" | "running" | "complete" | "failed"
```

Orchestrator shell script writes task files:

```bash
#!/bin/bash
orchestrate-tests.sh. spawn subagents for each source file

mkdir -p .claude/agent-tasks .claude/agent-results .claude/agent-status

FILES=$(find src -name "*.ts" -not -name "*.test.ts")
PIDS=()
COUNT=0

for FILE in $FILES; do
 COUNT=$((COUNT + 1))
 TASK_ID="task-$(printf '%03d' $COUNT)"
 RESULT_FILE=".claude/agent-results/${TASK_ID}.md"
 
 echo "pending" > ".claude/agent-status/${TASK_ID}.status"
 
 # Spawn subagent in background
 (
 echo "running" > ".claude/agent-status/${TASK_ID}.status"
 
 OUTPUT=$(claude -p "/tdd Write Jest tests for $FILE. Only output the test file, no explanation." 2>/dev/null)
 
 if [[ $? -eq 0 && -n "$OUTPUT" ]]; then
 echo "$OUTPUT" > "$RESULT_FILE"
 echo "complete" > ".claude/agent-status/${TASK_ID}.status"
 else
 echo "failed" > ".claude/agent-status/${TASK_ID}.status"
 fi
 ) &
 
 PIDS+=($!)
done

echo "Spawned $COUNT subagents..."

Wait for all to finish
for PID in "${PIDS[@]}"; do
 wait $PID
done

echo "All $COUNT tasks complete"
```

2. Passing Context Between Subagents

Context does not flow automatically between subagents. each starts fresh. Package any context the subagent needs directly in the prompt:

```bash
#!/bin/bash
Context-aware subagent invocation

FILE="$1"
CONVENTIONS="$2" # Path to project conventions file

CONTEXT=$(cat "$CONVENTIONS")
SOURCE=$(cat "$FILE")

OUTPUT=$(claude -p "/tdd 
Project conventions:
$CONTEXT

Write tests for this file:
$SOURCE

Output only the complete test file." 2>/dev/null)

echo "$OUTPUT"
```

By including file contents directly in the prompt rather than just a file path, you avoid the subagent needing file read access and reduce tool call overhead.

3. Aggregating Results

After subagents complete, aggregate their output:

```python
#!/usr/bin/env python3
import os
import glob

result_files = sorted(glob.glob(".claude/agent-results/*.md"))
status_files = sorted(glob.glob(".claude/agent-status/*.status"))

completed = 0
failed = 0

for status_file in status_files:
 with open(status_file) as f:
 status = f.read().strip()
 if status == "complete":
 completed += 1
 elif status == "failed":
 failed += 1

print(f"Results: {completed} complete, {failed} failed, {len(result_files)} files written")

Write test files to their proper locations
for result_file in result_files:
 with open(result_file) as f:
 content = f.read().strip()
 if content:
 # Parse the target path from the result file name
 task_id = os.path.basename(result_file).replace(".md", "")
 print(f" {task_id}: {len(content)} chars")
```

## Parallel Execution

The power of multi-agent workflows is parallelism. Running 10 subagents in background processes is much faster than sequential runs. Be aware that [response latency and throughput scale differently](/claude-code-response-latency-optimization-with-skills/) in parallel vs sequential architectures:

```bash
#!/bin/bash
Parallel review of all changed files

CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD -- "*.ts" "*.tsx")
PIDS=()
RESULTS=()

for FILE in $CHANGED_FILES; do
 OUTPUT_FILE="/tmp/review-$(echo $FILE | tr '/' '-').md"
 RESULTS+=("$OUTPUT_FILE")
 
 # Spawn background subagent
 (
 claude -p "/tdd Identify any missing test coverage in $FILE. Be specific about function names." > "$OUTPUT_FILE" 2>/dev/null
 ) &
 PIDS+=($!)
done

Wait for all subagents
for PID in "${PIDS[@]}"; do
 wait $PID
done

Print all results
for RESULT_FILE in "${RESULTS[@]}"; do
 echo "=== $(basename $RESULT_FILE) ==="
 cat "$RESULT_FILE"
 echo
done
```

## Rate Limiting Concurrent Subagents

Running too many subagents simultaneously can exhaust your API rate limits. Use a semaphore pattern:

```bash
#!/bin/bash
Rate-limited parallel execution

MAX_CONCURRENT=5
PIDS=()

run_with_limit() {
 local FILE="$1"
 local OUTPUT="$2"
 
 # Wait if at max concurrent
 while [ ${#PIDS[@]} -ge $MAX_CONCURRENT ]; do
 for i in "${!PIDS[@]}"; do
 if ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
 unset "PIDS[$i]"
 fi
 done
 PIDS=("${PIDS[@]}")
 sleep 0.5
 done
 
 # Spawn new subagent
 (claude -p "/tdd Write tests for $FILE" > "$OUTPUT" 2>/dev/null) &
 PIDS+=($!)
}

for FILE in src//*.ts; do
 run_with_limit "$FILE" "/tmp/result-$(basename $FILE).md"
done

wait
echo "All tasks complete"
```

## Error Handling and Retries

Subagents fail. network errors, rate limits, and context length issues all happen. Wrap subagent calls with retry logic:

```bash
run_subagent_with_retry() {
 local FILE="$1"
 local OUTPUT="$2"
 local MAX_RETRIES=3
 local ATTEMPT=0
 
 while [ $ATTEMPT -lt $MAX_RETRIES ]; do
 RESULT=$(claude -p "/tdd Write tests for $FILE" 2>/dev/null)
 
 if [[ $? -eq 0 && -n "$RESULT" ]]; then
 echo "$RESULT" > "$OUTPUT"
 return 0
 fi
 
 ATTEMPT=$((ATTEMPT + 1))
 echo "Attempt $ATTEMPT failed for $FILE, retrying..." >&2
 sleep $((ATTEMPT * 2)) # Exponential backoff
 done
 
 echo "All retries failed for $FILE" >&2
 return 1
}
```

## Using /supermemory for Shared Context

If subagents need to share learned context, use [`/supermemory`](/claude-skills-token-optimization-reduce-api-costs/) to store context before spawning subagents, then retrieve it in each subagent's prompt:

```bash
Store shared context once
claude -p "/supermemory Store project context: uses Jest, all mocks go in __mocks__/, test files named *.test.ts"

Retrieve in each subagent
CONTEXT=$(claude -p "/supermemory Retrieve the project testing conventions")

for FILE in src//*.ts; do
 (
 claude -p "/tdd 
Context: $CONTEXT
Write tests for: $FILE" > "/tmp/result-$(basename $FILE).md" 2>/dev/null
 ) &
done

wait
```

---

## Step-by-Step: Orchestrating a Multi-Agent Workflow

1. Define agent roles: before writing code, map out which agent does what. A typical setup has an orchestrator agent that breaks tasks into subtasks and n worker agents that each handle one specialized domain (e.g., code writing, test generation, documentation).
2. Choose a communication pattern: agents can communicate synchronously (orchestrator waits for each worker to finish before proceeding) or asynchronously (orchestrator fans out all tasks at once and collects results). Async fan-out is faster for independent tasks.
3. Set up a shared context store: use a simple key-value store (Redis, a JSON file, or an in-memory Map) where agents write their outputs. The orchestrator reads from this store rather than maintaining a chain of direct return values.
4. Implement task queueing: put subtasks into a queue (an array or a real queue like BullMQ) so worker agents can pull from it. This decouples producers from consumers and makes it easy to add more workers.
5. Handle failures with retries: wrap each agent invocation in a retry loop with exponential backoff. A subagent that fails once due to a transient API error should retry 2-3 times before the orchestrator marks the task as failed.
6. Aggregate and merge results: once all subagents have written to the context store, the orchestrator reads all outputs and merges them into a coherent final result.

## Communication Patterns Compared

```
// Pattern 1: Sequential chain
// A -> B -> C -> D (output of each is input to next)
const resultA = await agentA(input);
const resultB = await agentB(resultA);
const resultC = await agentC(resultB);

// Pattern 2: Fan-out / Fan-in (parallel)
// A -> [B, C, D] -> E (all three run concurrently)
const [resultB, resultC, resultD] = await Promise.all([
 agentB(input),
 agentC(input),
 agentD(input),
]);
const finalResult = await agentE({ resultB, resultC, resultD });

// Pattern 3: Hierarchical (orchestrator spawns sub-orchestrators)
// A -> [B1 -> [C1, C2], B2 -> [C3, C4]] -> D
```

For Claude Code workflows, pattern 2 is most efficient when the subtasks are truly independent. it cuts total wall-clock time by the number of parallel workers.

## Common Multi-Agent Architectures

| Architecture | Best For | Complexity | Fault Tolerance |
|---|---|---|---|
| Sequential chain | Dependent, ordered tasks | Low | Breaks on any step failure |
| Fan-out / fan-in | Independent parallel tasks | Medium | One failed worker doesn't block others |
| Hierarchical | Complex nested tasks | High | Configurable per level |
| Peer-to-peer | Collaborative refinement | High | Requires conflict resolution |
| Blackboard | Shared knowledge building | Medium | Any agent can contribute |

## Advanced: Agent-to-Agent Tool Calls

In Claude's agent SDK, a subagent can be exposed as a tool that the orchestrator calls. This means the orchestrator does not need to know the implementation details of each subagent. it just calls a named tool and gets a result:

```javascript
const tools = [
 {
 name: "code_review_agent",
 description: "Reviews code for bugs, style, and security issues",
 input_schema: {
 type: "object",
 properties: {
 code: { type: "string" },
 language: { type: "string" }
 },
 required: ["code", "language"]
 }
 }
];

// Orchestrator calls the subagent as a tool
const response = await claude.messages.create({
 model: "claude-opus-4-6",
 tools,
 messages: [{ role: "user", content: "Review this Python function: ..." }]
});
```

## Troubleshooting

Context window overflow in the orchestrator: Each subagent's output gets appended to the orchestrator's context. For long-running workflows, summarize each subagent's output before passing it back to the orchestrator instead of passing the full raw output. A 200-word summary is usually sufficient for the orchestrator to make routing decisions.

Subagents producing inconsistent output formats: Define a strict JSON schema for each subagent's output and validate it before the orchestrator consumes it. Reject and retry if the schema validation fails. models sometimes produce slightly malformed JSON on the first attempt.

Deadlocks in bidirectional agent communication: If agent A waits for agent B and agent B waits for agent A, the workflow hangs. Prevent this by using a unidirectional communication pattern: agents only write to the shared store, the orchestrator is the only reader, and agents never directly call each other.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-multi-agent-subagent-communication-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). The skills most suited for subagent use (tdd, pdf, frontend-design) are profiled here with invocation patterns that translate to multi-agent workflows
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). Understanding auto-invocation is key for orchestration: you need to know when to use explicit skill invocations in subagent print mode
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Running many subagents in parallel multiplies API costs; these optimization techniques are especially important in multi-agent architectures

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Multi-Cursor Edit Conflict Fix](/claude-code-multi-cursor-edit-conflict-fix-2026/)
