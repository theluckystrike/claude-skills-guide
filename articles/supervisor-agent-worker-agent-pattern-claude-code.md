---
layout: default
title: "Supervisor-Agent Worker-Agent Pattern (2026)"
description: "Implement the supervisor-worker agent pattern in Claude Code: task decomposition, parallel execution, result aggregation, and error handling for."
date: 2026-03-20
last_modified_at: 2026-04-17
categories: [advanced]
tags: [claude-code, agent-patterns, supervisor-agent, worker-agent, parallel-execution, pipelines]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /supervisor-agent-worker-agent-pattern-claude-code/
geo_optimized: true
---

# Supervisor-Agent Worker-Agent Pattern with Claude Code

The supervisor-worker pattern is one of the most practical multi-agent architectures you can build with Claude Code. A supervisor agent receives a high-level task, decomposes it into subtasks, delegates each subtask to a worker agent, collects results, and synthesizes a final output. The pattern scales to problems that are too large, too parallel, or too risky to handle in a single agent context.

This guide covers the mechanics of implementing this pattern with Claude Code's SDK: how to decompose tasks cleanly, run workers in parallel, aggregate results, and handle failures without cascading breakdowns.

## When to Use the Supervisor-Worker Pattern

Not every task benefits from this architecture. It makes sense when:

- The work is naturally parallel (reviewing 20 files simultaneously rather than sequentially)
- Worker failures should be isolated rather than aborting the whole job
- Different subtasks require different tool sets or context windows
- The result requires synthesis across multiple independent outputs

Avoid it when the task is inherently sequential, when subtask outputs depend on each other, or when the coordination overhead exceeds the parallelism benefit.

## Task Decomposition: The Supervisor's Core Responsibility

The supervisor's first job is to produce a task list that workers can execute independently. Good decomposition has three properties: tasks are atomic, tasks are independent, and tasks carry enough context for a worker to complete them without asking follow-up questions.

Here is a supervisor prompt structure that produces reliable decomposition:

```python
SUPERVISOR_PROMPT = """
You are a supervisor agent. Your job is to decompose the following task into
independent subtasks that can be executed in parallel by worker agents.

Task: {task_description}

Rules for decomposition:
- Each subtask must be self-contained (worker needs no external context)
- Each subtask must have a clear completion criterion
- Maximum {max_workers} subtasks
- Output as JSON array with fields: id, description, context, success_criterion

Output only valid JSON. No prose.
"""
```

The `context` field is critical. Workers operate in isolated sessions. they cannot see what the supervisor knows. Pack everything the worker needs into the subtask context field: relevant file paths, constraints, prior decisions, and output format requirements.

## Spawning Workers with the Claude Code SDK

The Claude Code SDK's `query` function is the right primitive for spawning workers. Each worker call is independent. it gets its own context window and runs to completion before returning.

```python
import anthropic
import asyncio
from typing import Any

client = anthropic.Anthropic()

async def run_worker(subtask: dict) -> dict:
 """Run a single worker agent for a given subtask."""
 worker_prompt = f"""
You are a worker agent. Complete the following subtask and return your result.

Subtask ID: {subtask['id']}
Description: {subtask['description']}
Context: {subtask['context']}
Success criterion: {subtask['success_criterion']}

When complete, output a JSON object with:
- id: the subtask id
- status: "success" or "failure"
- result: your output (string)
- error: null or error description
"""
 messages = []
 final_text = []

 async with client.messages.stream(
 model="claude-opus-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": worker_prompt}]
 ) as stream:
 async for text in stream.text_stream:
 final_text.append(text)

 raw = "".join(final_text)

 try:
 import json
 # Extract JSON from the response
 start = raw.find("{")
 end = raw.rfind("}") + 1
 return json.loads(raw[start:end])
 except Exception:
 return {
 "id": subtask["id"],
 "status": "failure",
 "result": None,
 "error": f"Worker returned unparseable output: {raw[:200]}"
 }
```

## Running Workers in Parallel

Parallel execution is where the pattern pays off. Use `asyncio.gather` with a semaphore to control concurrency. unbounded parallelism will saturate your API rate limits.

```python
async def run_workers_parallel(
 subtasks: list[dict],
 max_concurrent: int = 5
) -> list[dict]:
 """Run all workers in parallel with a concurrency limit."""
 semaphore = asyncio.Semaphore(max_concurrent)

 async def bounded_worker(subtask: dict) -> dict:
 async with semaphore:
 return await run_worker(subtask)

 results = await asyncio.gather(
 *[bounded_worker(subtask) for subtask in subtasks],
 return_exceptions=True
 )

 # Normalize exceptions into failure results
 normalized = []
 for i, result in enumerate(results):
 if isinstance(result, Exception):
 normalized.append({
 "id": subtasks[i]["id"],
 "status": "failure",
 "result": None,
 "error": str(result)
 })
 else:
 normalized.append(result)

 return normalized
```

With `max_concurrent=5`, you run five workers at a time regardless of how many subtasks the supervisor generated. Tune this based on your Anthropic API tier.

## Result Aggregation

The supervisor receives all worker results and synthesizes a final output. Do not concatenate worker results blindly. have the supervisor reason over them.

```python
async def aggregate_results(
 original_task: str,
 subtasks: list[dict],
 worker_results: list[dict]
) -> str:
 """Supervisor aggregates worker results into a final output."""
 import json

 results_summary = json.dumps(worker_results, indent=2)

 aggregation_prompt = f"""
You are a supervisor agent completing a final aggregation step.

Original task: {original_task}

Worker results:
{results_summary}

Your job:
1. Identify any failed subtasks and assess their impact
2. Synthesize the successful results into a coherent final output
3. Note any gaps caused by failures
4. Produce the final deliverable

Be concrete. Do not omit results from successful workers.
"""

 response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=8096,
 messages=[{"role": "user", "content": aggregation_prompt}]
 )

 return response.content[0].text
```

## Error Handling: Isolation and Retry

Worker failures should not abort the pipeline. There are three levels of error handling to implement.

Level 1: Worker-level isolation. Each worker catches its own exceptions and returns a structured failure result. The supervisor sees a failed result, not an unhandled exception.

Level 2: Retry logic. For transient failures (rate limits, network errors), retry the specific worker rather than the whole pipeline.

```python
async def run_worker_with_retry(
 subtask: dict,
 max_retries: int = 2
) -> dict:
 for attempt in range(max_retries + 1):
 result = await run_worker(subtask)
 if result["status"] == "success":
 return result
 if attempt < max_retries:
 await asyncio.sleep(2 ** attempt) # exponential backoff
 return result # return final failure after retries exhausted
```

Level 3: Supervisor recovery. After aggregation, give the supervisor the list of failed subtasks and ask it to either re-attempt them with adjusted context or produce a partial result with explicit gaps noted.

## Real-World Use Case: Code Review Pipeline

A code review pipeline is an ideal fit for the supervisor-worker pattern. The supervisor receives a pull request diff, decomposes it into per-file reviews, runs workers in parallel (one per file), and aggregates a final PR summary.

```python
async def code_review_pipeline(pr_diff: str) -> str:
 # Step 1: Supervisor decomposes into per-file reviews
 decompose_prompt = f"""
Analyze this PR diff and create a review subtask for each changed file.
For each file subtask, include the full diff for that file in the context field.

PR diff:
{pr_diff}

Output JSON array of subtasks. Each subtask: id, description, context, success_criterion.
"""
 decomp_response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": decompose_prompt}]
 )

 import json
 raw = decomp_response.content[0].text
 subtasks = json.loads(raw[raw.find("["):raw.rfind("]")+1])

 # Step 2: Run per-file review workers in parallel
 results = await run_workers_parallel(subtasks, max_concurrent=5)

 # Step 3: Supervisor aggregates into final PR review
 return await aggregate_results(
 "Produce a complete code review for this pull request",
 subtasks,
 results
 )
```

## Real-World Use Case: Test Generation

Test generation benefits from parallelism because each module's tests are independent. The supervisor identifies untested functions, assigns one worker per function, and collects test files.

```python
Supervisor identifies targets
decompose_prompt = """
Given this list of untested functions, create a test generation subtask for each.
Each subtask context must include the function signature and docstring.
Each worker must output a complete pytest test file as a string.

Functions: {function_list}
"""

Workers produce test files
worker_instruction = """
Write a complete pytest test file for the function described in context.
Include: happy path tests, edge cases, and one test for expected exceptions.
Output only valid Python code. No markdown.
"""
```

## Putting It Together: Full Supervisor Loop

```python
import asyncio
import json
import anthropic

client = anthropic.Anthropic()

async def supervisor_loop(task: str, max_workers: int = 8) -> str:
 # 1. Decompose
 decomp = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=2048,
 messages=[{
 "role": "user",
 "content": SUPERVISOR_PROMPT.format(
 task_description=task,
 max_workers=max_workers
 )
 }]
 )
 raw = decomp.content[0].text
 subtasks = json.loads(raw[raw.find("["):raw.rfind("]")+1])

 # 2. Execute workers in parallel with retry
 results = await asyncio.gather(
 *[run_worker_with_retry(st, max_retries=2) for st in subtasks]
 )

 # 3. Aggregate
 return await aggregate_results(task, subtasks, list(results))

Entry point
if __name__ == "__main__":
 result = asyncio.run(supervisor_loop(
 "Review all Python files in src/ for security vulnerabilities"
 ))
 print(result)
```

## Common Mistakes

Underspecified subtask context. Workers fail because they lack the information needed. Always include file paths, relevant constraints, and exact output format requirements in the context field.

Ignoring partial failures. Pipelines that require all workers to succeed will break on any transient error. Design aggregation to produce useful output even when some workers fail.

No concurrency limit. Spawning 50 workers simultaneously will hit rate limits immediately. Always use a semaphore or equivalent.

Supervisor and worker using the same context window. These should be separate API calls. Mixing them defeats the purpose of the pattern.

The supervisor-worker pattern is one of the most effective ways to apply Claude Code at scale. The implementation overhead is modest. roughly 100 lines of Python. and the gains in throughput and fault isolation are substantial.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=supervisor-agent-worker-agent-pattern-claude-code)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Agent Handoff Strategies for Long-Running Tasks](/agent-handoff-strategies-for-long-running-tasks-guide/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

