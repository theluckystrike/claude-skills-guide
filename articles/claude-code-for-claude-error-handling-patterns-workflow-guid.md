---
layout: default
title: "How to Use Claude Error Handling"
description: "A comprehensive guide to implementing error handling patterns in Claude Code workflows for developers."
date: 2026-03-20
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-claude-error-handling-patterns-workflow-guid/
categories: [guides]
tags: [claude-code, claude-skills]
score: 7
reviewed: true
geo_optimized: true
---


Claude Code for Claude Error Handling Patterns Workflow Guide

Error handling is a critical aspect of building solid Claude Code workflows. When you're orchestrating AI agents to perform complex tasks, failures are inevitable, whether from API timeouts, malformed responses, or unexpected state changes. This guide explores practical error handling patterns that will make your Claude Code workflows more resilient and maintainable.

## Understanding Error Types in Claude Code

Before diving into patterns, it's essential to understand what can go wrong in a Claude Code workflow. Errors typically fall into several categories:

- Tool Execution Failures: When a tool like `bash`, `read_file`, or `write_file` fails to complete
- API Rate Limits: External services imposing request limits
- Permission Denied: Insufficient permissions to access files or resources
- Timeout Errors: Operations that take too long to complete
- Syntax and Validation Errors: Malformed inputs or incorrect parameter types
- State Corruption: Partial writes or incomplete transactions that leave your system in an inconsistent state
- Dependency Failures: Downstream services, packages, or external tools that are unavailable

Understanding these error categories helps you design appropriate handling strategies for each scenario. A network timeout deserves a retry; a security violation deserves an immediate halt. Treating all errors the same way is one of the most common workflow design mistakes.

## Error Severity Levels

Not all errors are created equal. A useful mental model is to classify errors by severity before choosing a response strategy:

| Severity | Examples | Recommended Response |
|----------|----------|---------------------|
| Fatal | Disk full, invalid credentials | Stop workflow, alert operator |
| Transient | Network timeout, rate limit | Retry with backoff |
| Degraded | Cache miss, optional service down | Continue with fallback |
| Validation | Bad user input, wrong types | Reject early, return clear message |
| Warning | Deprecated API, slow response | Log and continue |

This table gives you a quick reference for routing each error type to the right handler.

## Pattern 1: Try-Catch with Tool Results

The fundamental error handling pattern in Claude Code involves checking tool execution results. Every tool returns a result object that indicates success or failure.

```python
result = bash(command="npm install", timeout=300)
if result.exit_code != 0:
 print(f"Installation failed: {result.stderr}")
 # Handle the error appropriately
```

This pattern works for all tools, always check the return value before proceeding. Many developers make the mistake of assuming tools always succeed, which leads to cascading failures.

A more complete version of this pattern includes structured output and distinguishes between stderr that is informational versus stderr that signals an actual failure:

```python
def run_bash_safe(command, context="", timeout=60):
 result = bash(command=command, timeout=timeout)

 if result.exit_code != 0:
 return {
 "success": False,
 "exit_code": result.exit_code,
 "stderr": result.stderr,
 "stdout": result.stdout,
 "context": context
 }

 return {
 "success": True,
 "stdout": result.stdout,
 "stderr": result.stderr # may contain warnings even on success
 }

Usage
install_result = run_bash_safe("npm install", context="project setup")
if not install_result["success"]:
 print(f"Setup failed (exit {install_result['exit_code']}): {install_result['stderr']}")
 # Route to appropriate recovery logic
```

Wrapping bash calls in a helper like this means you get consistent error objects everywhere in your workflow, making downstream handling easier to reason about.

## Pattern 2: Defensive Parameter Validation

Before calling any tool with user-provided parameters, validate inputs thoroughly. This prevents errors from propagating through your workflow.

```python
def execute_with_validation(command):
 # Validate command is safe
 if not command or not isinstance(command, str):
 raise ValueError("Invalid command provided")

 # Check for dangerous patterns
 dangerous_patterns = ["rm -rf /", "curl | sh", "&& rm"]
 for pattern in dangerous_patterns:
 if pattern in command:
 raise SecurityError(f"Dangerous pattern detected: {pattern}")

 return bash(command=command)
```

This validation layer catches errors early and provides clear feedback about what went wrong.

You can extend this with an allowlist approach rather than blocklist, which is more secure:

```python
import re

ALLOWED_COMMANDS = {"npm", "node", "git", "python", "pytest", "eslint"}

def validate_and_execute(command):
 if not command or not isinstance(command, str):
 raise ValueError("Command must be a non-empty string")

 # Extract the base command
 base_cmd = command.strip().split()[0]

 if base_cmd not in ALLOWED_COMMANDS:
 raise PermissionError(
 f"Command '{base_cmd}' is not in the allowed list. "
 f"Allowed: {', '.join(sorted(ALLOWED_COMMANDS))}"
 )

 # Reject shell metacharacters
 if re.search(r"[;&|`$]", command):
 raise SecurityError("Shell metacharacters are not permitted in commands")

 return bash(command=command)
```

Failing fast with a clear, specific error message is far more helpful than letting invalid inputs reach downstream steps and produce confusing failures.

## Pattern 3: Retry Logic with Exponential Backoff

Transient errors often resolve themselves if you wait and retry. Implement retry logic with exponential backoff for operations that might succeed on a subsequent attempt:

```python
import time

def retry_with_backoff(func, max_retries=3, base_delay=1):
 for attempt in range(max_retries):
 try:
 return func()
 except TemporaryError as e:
 if attempt == max_retries - 1:
 raise
 delay = base_delay * (2 attempt)
 print(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay}s...")
 time.sleep(delay)
```

This pattern is particularly useful for:
- Network requests to external APIs
- Database connections
- File system operations under load

A production-ready version adds jitter to prevent the thundering herd problem (where many clients retry at the same moment):

```python
import time
import random

def retry_with_jitter(func, max_retries=4, base_delay=0.5, max_delay=30):
 last_exception = None

 for attempt in range(max_retries):
 try:
 return func()
 except (TimeoutError, ConnectionError, RateLimitError) as e:
 last_exception = e
 if attempt == max_retries - 1:
 break

 # Exponential backoff with full jitter
 cap = min(max_delay, base_delay * (2 attempt))
 delay = random.uniform(0, cap)

 print(f"Attempt {attempt + 1}/{max_retries} failed: {e}")
 print(f"Waiting {delay:.2f}s before retry...")
 time.sleep(delay)

 raise RuntimeError(
 f"All {max_retries} attempts failed. Last error: {last_exception}"
 )
```

The jitter ensures that concurrent workflows don't all hammer an API at the exact same retry interval, which can trigger additional rate limiting.

## When NOT to Retry

Retrying is only appropriate for transient failures. Never retry these error types:

- Authentication failures (401, 403): Your credentials are wrong; retrying wastes time
- Validation errors (400): The input is bad; the same request will fail again
- Not found errors (404): The resource doesn't exist; retrying won't create it
- Business logic errors: If a rule prevents the operation, the rule won't change between attempts

## Pattern 4: Circuit Breaker for External Services

When working with unreliable external services, implement a circuit breaker pattern to prevent cascading failures:

```python
class CircuitBreaker:
 def __init__(self, failure_threshold=5, timeout=60):
 self.failure_threshold = failure_threshold
 self.timeout = timeout
 self.failures = 0
 self.last_failure_time = None
 self.state = "closed" # closed, open, half-open

 def call(self, func):
 if self.state == "open":
 if time.time() - self.last_failure_time > self.timeout:
 self.state = "half-open"
 else:
 raise CircuitOpenError("Circuit is open")

 try:
 result = func()
 self.on_success()
 return result
 except Exception as e:
 self.on_failure()
 raise

 def on_success(self):
 self.failures = 0
 self.state = "closed"

 def on_failure(self):
 self.failures += 1
 self.last_failure_time = time.time()
 if self.failures >= self.failure_threshold:
 self.state = "open"
```

The circuit breaker prevents your workflow from repeatedly hitting a failing service, giving it time to recover.

Understanding the three states is key to getting value from this pattern:

| State | Description | Behavior |
|-------|-------------|----------|
| Closed | Normal operation | All requests pass through |
| Open | Service considered down | Requests fail immediately without hitting the service |
| Half-Open | Testing if service recovered | One probe request allowed; success closes, failure re-opens |

The half-open state is what makes circuit breakers smarter than simple "fail after N errors" guards. It allows automatic recovery when the upstream service comes back online.

## Pattern 5: Graceful Degradation

Not all errors warrant stopping your workflow. Implement graceful degradation to continue operations with reduced functionality:

```python
def get_user_data(user_id, prefer_cache=True):
 try:
 if prefer_cache:
 return cache.get(f"user:{user_id}")
 except CacheError:
 print("Cache unavailable, falling back to database")

 try:
 return database.query(f"SELECT * FROM users WHERE id = {user_id}")
 except DatabaseError:
 print("Database unavailable, returning mock data")
 return {"id": user_id, "name": "Unknown", "status": "degraded"}
```

This pattern ensures your workflow continues even when some components fail.

A more sophisticated version tracks degradation state so callers can make informed decisions:

```python
from dataclasses import dataclass
from typing import Any, Optional

@dataclass
class ServiceResult:
 data: Any
 source: str # "cache", "database", "default"
 degraded: bool
 degradation_reason: Optional[str] = None

def get_user_data_with_status(user_id: str) -> ServiceResult:
 # Tier 1: fast cache
 try:
 data = cache.get(f"user:{user_id}")
 if data:
 return ServiceResult(data=data, source="cache", degraded=False)
 except CacheError as e:
 log_warning("cache_miss", user_id=user_id, error=str(e))

 # Tier 2: primary database
 try:
 data = database.query("SELECT * FROM users WHERE id = %s", user_id)
 return ServiceResult(data=data, source="database", degraded=False)
 except DatabaseError as e:
 log_error("database_failure", user_id=user_id, error=str(e))

 # Tier 3: degraded fallback
 return ServiceResult(
 data={"id": user_id, "name": "Unknown"},
 source="default",
 degraded=True,
 degradation_reason="Both cache and database unavailable"
 )

Caller can inspect degradation status
result = get_user_data_with_status(user_id)
if result.degraded:
 send_alert(f"Degraded response for user {user_id}: {result.degradation_reason}")
render_user(result.data, show_stale_warning=result.degraded)
```

Making degradation explicit in return types prevents silent failures where callers assume they got fresh data when they actually got stale defaults.

## Pattern 6: Comprehensive Logging and Error Context

Always log sufficient context to diagnose issues later. Include relevant state information in your error messages:

```python
def safe_execute(command, context):
 try:
 result = bash(command=command)
 return result
 except Exception as e:
 logger.error({
 "error": str(e),
 "command": command,
 "context": context,
 "timestamp": time.time(),
 "working_directory": os.getcwd()
 })
 raise
```

Good error context dramatically reduces debugging time when things go wrong in production.

Structured logging (as JSON objects rather than plain strings) makes errors searchable and parseable by log aggregation tools:

```python
import json
import time
import os
import traceback

def structured_log(level, event, kwargs):
 entry = {
 "level": level,
 "event": event,
 "timestamp": time.time(),
 "cwd": os.getcwd(),
 kwargs
 }
 print(json.dumps(entry))

def safe_execute_with_context(command, operation_id, step):
 structured_log("info", "tool_call_start",
 command=command, operation_id=operation_id, step=step)

 try:
 result = bash(command=command)

 if result.exit_code != 0:
 structured_log("error", "tool_call_failed",
 command=command,
 exit_code=result.exit_code,
 stderr=result.stderr,
 operation_id=operation_id,
 step=step)
 return None

 structured_log("info", "tool_call_success",
 command=command, operation_id=operation_id, step=step)
 return result

 except Exception as e:
 structured_log("error", "tool_call_exception",
 command=command,
 error=str(e),
 traceback=traceback.format_exc(),
 operation_id=operation_id,
 step=step)
 raise
```

When reviewing logs after an incident, you want to answer: "What was the system doing when this failed, and what state was it in?" The `operation_id` and `step` fields let you reconstruct the sequence of events for any given workflow run.

## Pattern 7: Structured Error Recovery Workflows

Design your workflows with explicit recovery paths for common error scenarios:

```python
def workflow_with_recovery():
 # Primary path
 try:
 data = fetch_data()
 process_data(data)
 except NetworkError:
 # Recovery path 1: Use cached data
 print("Network error, attempting recovery with cached data")
 cached = load_cached_data()
 if cached:
 process_data(cached)
 else:
 # Recovery path 2: Use default values
 print("No cache available, using defaults")
 process_data(DEFAULT_DATA)
 except ValidationError as e:
 # Recovery path: Log and skip invalid data
 logger.warning(f"Validation error: {e}")
 skip_record()
```

A more complete workflow design uses a state machine to track recovery progress and prevent partial completions:

```python
from enum import Enum

class WorkflowState(Enum):
 INIT = "init"
 FETCHING = "fetching"
 PROCESSING = "processing"
 SAVING = "saving"
 COMPLETE = "complete"
 FAILED = "failed"
 RECOVERING = "recovering"

class WorkflowRunner:
 def __init__(self):
 self.state = WorkflowState.INIT
 self.checkpoints = {}

 def checkpoint(self, name, data):
 self.checkpoints[name] = data
 structured_log("info", "checkpoint_saved", name=name)

 def run(self):
 try:
 self.state = WorkflowState.FETCHING
 data = fetch_data()
 self.checkpoint("raw_data", data)

 self.state = WorkflowState.PROCESSING
 result = process_data(data)
 self.checkpoint("processed", result)

 self.state = WorkflowState.SAVING
 save_result(result)

 self.state = WorkflowState.COMPLETE

 except NetworkError:
 self.state = WorkflowState.RECOVERING
 structured_log("warn", "entering_recovery", reason="network_error",
 last_checkpoint=list(self.checkpoints.keys()))

 # Resume from last checkpoint if available
 if "raw_data" in self.checkpoints:
 result = process_data(self.checkpoints["raw_data"])
 save_result(result)
 self.state = WorkflowState.COMPLETE
 else:
 self.state = WorkflowState.FAILED
 raise

 except Exception as e:
 self.state = WorkflowState.FAILED
 structured_log("error", "workflow_failed",
 state=self.state.value,
 checkpoints=list(self.checkpoints.keys()),
 error=str(e))
 raise
```

Checkpointing lets your workflow resume from a known-good intermediate state rather than starting over from scratch, which is especially valuable for long-running workflows that perform expensive operations.

## Pattern 8: Testing Your Error Handling

Error handling code that is never tested is error handling that will fail exactly when you need it most. Inject failures deliberately to verify your handlers work:

```python
class FaultInjector:
 def __init__(self, target_func, failure_rate=0.3, error_type=TimeoutError):
 self.target_func = target_func
 self.failure_rate = failure_rate
 self.error_type = error_type

 def __call__(self, *args, kwargs):
 if random.random() < self.failure_rate:
 raise self.error_type(f"Injected fault (rate={self.failure_rate})")
 return self.target_func(*args, kwargs)

Wrap your function during tests
unreliable_fetch = FaultInjector(fetch_data, failure_rate=0.5)
runner = WorkflowRunner(data_source=unreliable_fetch)
runner.run() # Should succeed via recovery paths despite 50% failure rate
```

Write at least one test for each error branch in your workflow. If you can't easily inject a particular failure, that's a signal your code is too tightly coupled and should be refactored to accept injectable dependencies.

## Choosing the Right Pattern

Here is a quick decision guide for selecting the appropriate error handling approach:

| Situation | Pattern to Use |
|-----------|---------------|
| Tool call might fail once | Check result, log and exit |
| External service is flaky | Retry with exponential backoff + jitter |
| External service keeps failing | Circuit breaker to stop hammering it |
| Some features are optional | Graceful degradation with status tracking |
| Input is dangerous or malformed | Defensive validation, fail fast |
| Long workflow with expensive steps | Checkpointing + structured recovery |
| Debugging production issues | Structured logging with full context |
| Verifying error handlers work | Fault injection in tests |

Use these patterns in combination, a single workflow might use validation at entry, retries for network calls, a circuit breaker for external APIs, graceful degradation for optional features, structured logging throughout, and checkpointing for the overall flow.

## Best Practices Summary

1. Always check tool results - Never assume success
2. Validate early, fail fast - Check inputs before processing
3. Implement retries for transient failures with backoff and jitter
4. Use circuit breakers for external dependencies
5. Log comprehensively - Include structured context for debugging
6. Design recovery paths - Plan for failure scenarios explicitly
7. Checkpoint long workflows - Enable resume from intermediate state
8. Test your error handling - Inject failures to verify robustness
9. Match pattern to error type - Different errors need different responses
10. Make degradation visible - Surface when callers receive fallback data

## Conclusion

Error handling isn't about preventing all failures, it's about responding to them gracefully. By implementing these patterns in your Claude Code workflows, you'll build systems that recover automatically from common issues, provide clear feedback when human intervention is needed, and continue operating even when components fail.

Start with the basics: always check tool results and log errors with context. Then layer in retry logic, circuit breakers, and graceful degradation as your workflows grow more complex. Add checkpointing when workflows become expensive to re-run, and invest in fault injection tests to prove your recovery paths actually work.

The patterns in this guide compound well together. A workflow that combines validation, structured retries, circuit breakers, checkpointing, and comprehensive logging is genuinely resilient, not just error-handled in the superficial sense of catching exceptions and printing messages, but capable of recovering automatically from the most common real-world failures. Your future self (and your users) will thank you when something inevitably goes wrong.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-for-claude-error-handling-patterns-workflow-guid)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code Express Middleware Error Handling Patterns Guide](/claude-code-express-middleware-error-handling-patterns-guide/)
- [Claude Code Prisma Transactions and Error Handling Patterns](/claude-code-prisma-transactions-and-error-handling-patterns/)
- [Accessible Forms with Claude Code: Error Handling Guide](/claude-code-accessible-forms-validation-error-handling-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Make Claude Code Add Error Handling (2026)](/claude-code-skips-error-handling-fix-2026/)
