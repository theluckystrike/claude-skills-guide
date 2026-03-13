---
layout: default
title: "Claude Code Hooks Chaining: Multiple Hooks Together Guide"
description: "Learn how to chain multiple Claude Code hooks together — run sequential hook pipelines, create hook dependencies, and coordinate complex automation workflows."
date: 2026-03-13
author: theluckystrike
---

# Claude Code Hooks Chaining: Multiple Hooks Together Guide

Chaining multiple Claude Code hooks together enables sophisticated automation workflows where one hook's output becomes another hook's input, or where multiple hooks need to execute in a specific sequence with conditional logic. This guide covers practical patterns for building hook pipelines, managing hook dependencies, and coordinating complex automation across your development workflow.

## Why Chain Hooks?

While a single hook can handle simple tasks like logging or blocking certain actions, real-world workflows often require more sophisticated orchestration:

- **Multi-stage validation**: Run linting, then security scans, then formatting in sequence
- **Conditional workflows**: Execute different hooks based on previous hook results
- **Data transformation pipelines**: Process data through multiple transformation stages
- **Audit trails with checkpoints**: Ensure each workflow stage is logged before proceeding

## Hook Chaining Fundamentals

### Sequential Execution Pattern

The simplest chaining pattern runs hooks one after another. Each hook completes before the next begins:

```bash
#!/bin/bash
# Chain: validate-input → process-data → generate-output

# Stage 1: Validate input
echo "Validating input..."
if ! ./hooks/validate-input.sh < /dev/stdin; then
    echo "Validation failed" >&2
    exit 1
fi

# Stage 2: Process data  
echo "Processing data..."
if ! ./hooks/process-data.sh < /dev/stdin; then
    echo "Processing failed" >&2
    exit 1
fi

# Stage 3: Generate output
echo "Generating output..."
./hooks/generate-output.sh < /dev/stdin
```

### Exit Code Propagation

Each hook in the chain should propagate its exit code correctly:

```bash
#!/bin/bash
# hooks/chain-runner.sh

HOOKS=("validate.sh" "transform.sh" "export.sh")

for hook in "${HOOKS[@]}"; do
    echo "Running: $hook"
    if ! ./hooks/"$hook" < /dev/stdin; then
        echo "Hook failed: $hook" >&2
        exit 1  # Propagate failure
    fi
    echo "Completed: $hook"
done

echo "All hooks completed successfully"
exit 0
```

## Hook Input/Output Pipelines

### Passing Data Between Hooks

Each hook receives JSON via stdin and can output modified JSON to stdout:

```bash
#!/bin/bash
# hooks/Stage1-add-timestamp.sh

read -r event_data

# Add timestamp to event data
timestamped=$(echo "$event_data" | jq '. + {"chain_timestamp": now}')

# Pass to next stage via stdout
echo "$timestamped"
```

```bash
#!/bin/bash
# hooks/Stage2-enrich-data.sh

read -r event_data

# Extract the added timestamp
chain_ts=$(echo "$event_data" | jq -r '.chain_timestamp // "unknown"')

# Add enrichment data
enriched=$(echo "$event_data" | jq ". + {\"enriched_at\": \"$chain_ts\", \"enrichment_version\": \"1.0\"}")

echo "$enriched"
```

### Using a Coordinator Script

Create a central coordinator that manages the entire chain:

```bash
#!/bin/bash
# claude-code-hooks/chain-coordinator.sh

CHAIN_CONFIG=".claude/hooks/chain-config.json"

# Load chain configuration
STAGES=$(jq -r '.stages[]' "$CHAIN_CONFIG")

current_input=$(cat /dev/stdin)

for stage in $STAGES; do
    stage_script=$(jq -r ".scripts[\"$stage\"]" "$CHAIN_CONFIG")
    
    echo "Executing stage: $stage"
    
    if ! echo "$current_input" | ./hooks/"$stage_script"; then
        echo "Stage failed: $stage" >&2
        exit 1
    fi
    
    # Capture output for next stage
    current_input=$(echo "$current_input" | ./hooks/"$stage_script")
done

echo "$current_input"
```

## Practical Chaining Patterns

### Pattern 1: Pre-Tool Validation Pipeline

Chain multiple validation hooks that run before any tool execution:

```json
{
  "pre-tool": {
    "chain": [
      "check-rate-limit",
      "validate-project-state", 
      "audit-tool-request",
      "enforce-policy"
    ],
    "stop-on-failure": true
  }
}
```

```bash
#!/bin/bash
# hooks/check-rate-limit.sh

read -r event

# Check if we've exceeded tool call limit
remaining=$(jq -r '.remaining_calls // 100' "$HOME/.claude/state.json")

if [ "$remaining" -lt 10 ]; then
    echo "Rate limit approaching: $remaining calls remaining" >&2
    exit 1
fi

echo "$event"
exit 0
```

### Pattern 2: Conditional Hook Execution

Execute different hooks based on conditions:

```bash
#!/bin/bash
# hooks/router.sh

read -r event

tool_name=$(jq -r '.tool_name' <<< "$event")
skill_name=$(jq -r '.skill // null' <<< "$event")

case "$tool_name" in
    "bash")
        if [ "$skill_name" = "tdd-skill" ]; then
            echo "$event" | ./hooks/tdd-bash-guard.sh
        else
            echo "$event" | ./hooks/general-bash-guard.sh
        fi
        ;;
    "write_file")
        echo "$event" | ./hooks/file-write-guard.sh
        ;;
    "read_file")
        echo "$event" | ./hooks/file-read-guard.sh
        ;;
    *)
        # Pass through for unknown tools
        echo "$event"
        ;;
esac
```

### Pattern 3: Parallel Execution with Aggregation

Run independent checks simultaneously and aggregate results:

```bash
#!/bin/bash
# hooks/parallel-checks.sh

read -r event

# Run checks in parallel
check1=$(echo "$event" | ./hooks/security-check.sh &)
check2=$(echo "$event" | ./hooks/linting-check.sh &)
check3=$(echo "$event" | ./hooks-format-check.sh &)

wait

# Aggregate results
results=()
failed=0

for pid in $!; do
    if wait $pid; then
        results+=("pass")
    else
        results+=("fail")
        failed=1
    fi
done

if [ $failed -eq 1 ]; then
    echo "Some checks failed: ${results[*]}" >&2
    exit 1
fi

echo "$event"
```

### Pattern 4: Retry with Backoff

Chain hooks that retry failed operations:

```bash
#!/bin/bash
# hooks/retry-chain.sh

MAX_RETRIES=3
DELAY=2

read -r event

attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    echo "Attempt $attempt of $MAX_RETRIES"
    
    if echo "$event" | ./hooks/might-fail.sh; then
        echo "Success on attempt $attempt"
        exit 0
    fi
    
    echo "Attempt $attempt failed, retrying in ${DELAY}s..."
    sleep $DELAY
    DELAY=$((DELAY * 2))  # Exponential backoff
    attempt=$((attempt + 1))
done

echo "All $MAX_RETRIES attempts failed" >&2
exit 1
```

## Configuration File Approach

Store your chain configurations in a dedicated file:

```json
// .claude/hooks/chains.json
{
  "pre-tool-chains": {
    "safety-pipeline": {
      "hooks": [
        {"name": "rate-limit", "timeout": 5},
        {"name": "project-state", "timeout": 10},
        {"name": "audit-log", "timeout": 5}
      ],
      "continue-on-error": false
    },
    "lint-pipeline": {
      "hooks": [
        {"name": "eslint", "timeout": 30},
        {"name": "prettier-check", "timeout": 15},
        {"name": "types-check", "timeout": 60}
      ],
      "continue-on-error": true
    }
  },
  "post-tool-chains": {
    "notification-pipeline": {
      "hooks": [
        {"name": "log-to-file", "timeout": 2},
        {"name": "slack-notify", "timeout": 10},
        {"name": "metrics-push", "timeout": 5}
      ],
      "continue-on-error": true
    }
  }
}
```

## Error Handling Best Practices

### Graceful Degradation

```bash
#!/bin/bash
# hooks/robust-chain.sh

set +e  # Don't exit on error

result=$(echo "$event" | ./hooks/primary-hook.sh 2>&1)
primary_status=$?

if [ $primary_status -ne 0 ]; then
    echo "Primary hook failed, trying fallback..."
    result=$(echo "$event" | ./hooks/fallback-hook.sh 2>&1)
    fallback_status=$?
    
    if [ $fallback_status -ne 0 ]; then
        echo "Both primary and fallback failed" >&2
        exit 1
    fi
fi

echo "$result"
```

### Timeout Management

```bash
#!/bin/bash
# hooks/timeout-wrapper.sh

TIMEOUT=10

read -r event

# Run with timeout
output=$(timeout "$TIMEOUT" ./hooks/slow-hook.sh <<< "$event")
status=$?

if [ $status -eq 124 ]; then
    echo "Hook timed out after ${TIMEOUT}s" >&2
    exit 1
elif [ $status -ne 0 ]; then
    echo "Hook failed with status $status" >&2
    exit $status
fi

echo "$output"
```

## Debugging Chained Hooks

### Enable Verbose Logging

```bash
#!/bin/bash
# hooks/debug-chain.sh

DEBUG=true

log_debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $(date +%H:%M:%S) - $1" >> /tmp/hook-chain-debug.log
    fi
}

log_debug "Chain started with input: $event"

# ... rest of chain logic ...

log_debug "Chain completed successfully"
```

### Trace Execution Flow

```bash
#!/bin/bash
# hooks/trace.sh

TRACE_FILE="/tmp/hook-trace-$(date +%Y%m%d).log"

trace() {
    echo "[$(date -u +%H:%M:%S.%3N)] $1" >> "$TRACE_FILE"
}

trace ">>> Stage 1 start"
# Stage 1 work
trace "<<< Stage 1 end"

trace ">>> Stage 2 start"  
# Stage 2 work
trace "<<< Stage 2 end"
```

## Summary

Chaining Claude Code hooks enables powerful workflow automation:

- **Sequential execution** passes data between hooks via stdin/stdout
- **Exit codes** control flow — propagate failures to stop the chain
- **Conditional routing** executes different hooks based on context
- **Parallel execution** runs independent checks simultaneously
- **Retry logic** handles transient failures gracefully
- **Configuration files** make complex chains maintainable

Start with simple two-hook chains and progressively add complexity as your workflows require. Always implement proper error handling and logging for production chains.
