---
layout: default
title: "Claude Code Multi-Agent and Subagent Communication Guide"
description: "How to design multi-agent workflows with Claude Code — spawning subagents, passing context between agents, and coordinating parallel work with skills."
date: 2026-03-13
author: theluckystrike
---

# Claude Code Multi-Agent and Subagent Communication Guide

Claude Code supports multi-agent workflows where a primary agent orchestrates one or more subagents, each running in isolated contexts with their own skills, tools, and system prompts. This architecture enables parallel work, task specialization, and the kind of complex autonomous workflows that single-agent approaches can't handle cleanly.

## The Multi-Agent Mental Model

In a multi-agent Claude Code setup, you have:

- **Orchestrator**: A primary Claude Code session (often with a skill that manages coordination)
- **Subagents**: Claude Code instances spawned by the orchestrator, each handling a specific task
- **Shared state**: Files, databases, or message queues that agents use to communicate

The orchestrator assigns work, subagents execute it, and results flow back through shared state. The orchestrator monitors completion and aggregates results.

## Spawning Subagents

Claude Code can spawn subagents using the `bash` tool to invoke `claude` CLI commands:

```python
# Inside an orchestrator skill
# The orchestrator writes a task specification and spawns a worker
task_spec = {
    "task": "write_tests",
    "target_file": "src/auth/login.ts",
    "test_framework": "jest",
    "output_file": "src/auth/login.test.ts"
}

# Write task to shared state
with open(".claude/agent-tasks/task-001.json", "w") as f:
    json.dump(task_spec, f)

# Spawn subagent
subprocess.run([
    "claude",
    "--skill", "tdd",
    "--input-file", ".claude/agent-tasks/task-001.json",
    "--output-file", ".claude/agent-results/result-001.json",
    "--non-interactive"
])
```

The `--non-interactive` flag runs Claude Code without waiting for user input. The subagent reads its task specification, executes it, and writes results to the output file.

## Communication Patterns

### 1. File-Based Message Passing

The simplest and most reliable pattern: agents communicate via files in a shared directory.

```
.claude/
  agent-tasks/
    task-001.json    # Written by orchestrator
    task-002.json
  agent-results/
    result-001.json  # Written by subagent
    result-002.json
  agent-status/
    agent-001.status # "pending" | "running" | "complete" | "failed"
```

Orchestrator writes task files, updates status to "pending". Subagents poll for pending tasks, set status to "running", execute, write results, set status to "complete".

This pattern is simple, debuggable, and doesn't require any infrastructure beyond the filesystem.

### 2. Skill-Based Coordination

You can design skills specifically for multi-agent coordination. An orchestrator skill might look like this:

```yaml
---
name: orchestrate
description: Coordinates multiple Claude agents to complete complex multi-step tasks
tools:
  - read_file
  - write_file
  - bash
  - list_directory
max_turns: 50
---

You are an orchestration agent. You break complex tasks into parallel subtasks, 
assign them to specialized subagents, monitor their progress, and aggregate results.

For each task:
1. Analyze the request and identify parallelizable subtasks
2. Write a task specification JSON file for each subtask to .claude/agent-tasks/
3. Spawn a subagent for each task using: claude --skill {skill_name} --non-interactive ...
4. Monitor .claude/agent-status/ for completion
5. Aggregate results from .claude/agent-results/ into a final output
6. Clean up task files after successful completion

Available subagent skills: tdd, frontend-design, pdf, docx
```

### 3. MCP Server as Communication Bus

For more complex setups, a Model Context Protocol (MCP) server can act as a centralized communication bus between agents. Each agent connects to the MCP server as a client and can publish/subscribe to task queues.

This requires more setup but enables:
- Real-time task assignment without polling
- Centralized logging and monitoring
- Agent discovery (agents can find each other dynamically)
- Backpressure and rate limiting

## Passing Context Between Agents

Context doesn't flow automatically between agents — each subagent starts fresh. You must explicitly package and pass any context the subagent needs.

### Task Specification Format

A well-structured task specification contains everything the subagent needs:

```json
{
  "task_id": "task-001",
  "task_type": "write_tests",
  "inputs": {
    "source_file": "src/auth/login.ts",
    "source_content": "// contents of the file...",
    "test_framework": "jest",
    "existing_tests": "// any existing test patterns...",
    "project_conventions": "// relevant conventions..."
  },
  "constraints": {
    "max_tokens_output": 4000,
    "output_format": "complete_file",
    "no_mocks": ["bcrypt", "database"]
  },
  "output": {
    "file": ".claude/agent-results/result-001.json",
    "schema": {
      "test_file_content": "string",
      "files_created": "string[]",
      "explanation": "string"
    }
  }
}
```

By including `source_content` directly in the task spec rather than just a file path, you avoid the subagent needing to read files from the project (which may be slow or require additional permissions).

## Parallel Execution

The power of multi-agent workflows is parallelism. If you have 10 files to test, you can spawn 10 subagents simultaneously rather than processing them sequentially.

```bash
#!/bin/bash
# Orchestrate parallel test generation

FILES=$(find src -name "*.ts" -not -name "*.test.ts")
TASK_COUNT=0

for FILE in $FILES; do
    TASK_COUNT=$((TASK_COUNT + 1))
    TASK_FILE=".claude/agent-tasks/task-${TASK_COUNT}.json"
    
    # Write task specification
    cat > "$TASK_FILE" << EOF
    {
        "task_id": "task-${TASK_COUNT}",
        "task_type": "write_tests",
        "inputs": {
            "source_file": "${FILE}"
        },
        "output": {
            "file": ".claude/agent-results/result-${TASK_COUNT}.json"
        }
    }
EOF
    
    # Spawn subagent in background
    claude --skill tdd \
           --input-file "$TASK_FILE" \
           --output-file ".claude/agent-results/result-${TASK_COUNT}.json" \
           --non-interactive &
done

# Wait for all subagents to complete
wait
echo "All ${TASK_COUNT} tasks complete"
```

## Aggregating Results

After subagents complete, the orchestrator aggregates results:

```python
import json, glob

results = []
for result_file in sorted(glob.glob(".claude/agent-results/result-*.json")):
    with open(result_file) as f:
        result = json.load(f)
        results.append(result)

# Write aggregated test files
for result in results:
    if result.get("status") == "success":
        with open(result["output_file"], "w") as f:
            f.write(result["test_file_content"])
    else:
        print(f"Task {result['task_id']} failed: {result.get('error')}")

print(f"Completed: {sum(1 for r in results if r.get('status') == 'success')}/{len(results)} tasks")
```

## Error Handling and Retries

Subagents fail. Network issues, context limits, and model errors happen. Design your orchestration layer to handle failures gracefully:

```python
MAX_RETRIES = 3

def run_subagent(task_file, output_file, skill, retry=0):
    result = subprocess.run(
        ["claude", "--skill", skill, "--input-file", task_file,
         "--output-file", output_file, "--non-interactive"],
        capture_output=True, timeout=120
    )
    
    if result.returncode != 0 and retry < MAX_RETRIES:
        print(f"Subagent failed (attempt {retry + 1}), retrying...")
        return run_subagent(task_file, output_file, skill, retry + 1)
    
    return result.returncode == 0
```

## Skill Design for Subagents

Skills designed to run as subagents need different characteristics than interactive skills:

- **Non-interactive output**: The subagent should write output to files, not to the terminal
- **Explicit completion signals**: Write a result JSON with a clear success/failure status
- **No clarifying questions**: Subagents cannot ask for clarification. Handle ambiguity in the skill body.
- **Strict output format**: The orchestrator parses subagent output programmatically

Add a "subagent mode" section to any skill you intend to use as a subagent:

```
When running in non-interactive mode (indicated by the presence of --input-file 
in the invocation or by the input being a JSON task specification):
1. Read the task specification from the provided JSON
2. Execute the task completely
3. Write results to the specified output file in the required schema
4. Exit without asking questions or providing interactive output
```

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
