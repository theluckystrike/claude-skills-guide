---
layout: default
title: "Opus Orchestrator with Haiku Workers"
description: "Haiku workers cost $1/$5 per MTok vs Opus at $5/$25. Use the 5x cost gap to build fleets where workers handle 80% of tokens."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /opus-orchestrator-haiku-workers-pattern/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, multi-agent, orchestrator-worker]
render_with_liquid: false
---

# Opus Orchestrator with Haiku Workers Pattern

Haiku 4.5 costs $1.00/$5.00 per million tokens. Opus 4.7 costs $5.00/$25.00. That is a 5x gap. In a properly designed orchestrator-worker system, workers handle 80% of total tokens. Moving those 80% from Opus to Haiku reduces total fleet cost by 64%, from $25.00 to $9.00 per sprint.

## The Setup

You are processing a large codebase through an AI review pipeline. The tasks break down naturally: one agent reads the full codebase and creates a review plan (complex reasoning -- Opus territory). Four agents execute individual review tasks like checking naming conventions, verifying error handling, scanning for deprecated APIs, and testing documentation completeness (structured execution -- Haiku territory).

The Opus orchestrator consumes 500K input + 100K output tokens per sprint. Each Haiku worker consumes the same volume. The difference is price: the orchestrator's tokens cost 5x more per token than the workers'.

## The Math

**Token distribution in a typical 5-agent sprint:**

| Agent | Role | Input Tokens | Output Tokens | Model | Input Cost | Output Cost | Total |
|-------|------|-------------|--------------|-------|-----------|------------|-------|
| Agent 1 | Orchestrator | 500K | 100K | Opus 4.7 | $2.50 | $2.50 | $5.00 |
| Agent 2 | Worker | 500K | 100K | Haiku 4.5 | $0.50 | $0.50 | $1.00 |
| Agent 3 | Worker | 500K | 100K | Haiku 4.5 | $0.50 | $0.50 | $1.00 |
| Agent 4 | Worker | 500K | 100K | Haiku 4.5 | $0.50 | $0.50 | $1.00 |
| Agent 5 | Worker | 500K | 100K | Haiku 4.5 | $0.50 | $0.50 | $1.00 |
| **Total** | | **2.5M** | **500K** | | **$4.50** | **$4.50** | **$9.00** |

All-Opus comparison: **$25.00** (5 x $5.00)

**Savings: $16.00 per sprint (64%)**

Workers consume 80% of total tokens (2M of 2.5M input) but account for only 44% of cost ($4.00 of $9.00). This is the core efficiency of the pattern: high-volume, low-complexity work runs on the cheapest capable model.

## The Technique

The pattern works because most multi-agent tasks decompose into one reasoning step and many execution steps.

```python
import anthropic
import json
from concurrent.futures import ThreadPoolExecutor, as_completed

client = anthropic.Anthropic()

OPUS = "claude-opus-4-7-20250415"      # $5.00/$25.00 per MTok
HAIKU = "claude-haiku-4-5-20251001"     # $1.00/$5.00 per MTok


def opus_plan(codebase_summary: str) -> list[dict]:
    """Opus creates the review plan (complex reasoning)."""
    response = client.messages.create(
        model=OPUS,
        max_tokens=4096,
        system=(
            "You are a senior code reviewer. Create a review plan with "
            "specific, actionable tasks that can be executed independently. "
            "Output as JSON array with 'task', 'focus_areas', and "
            "'expected_output' fields."
        ),
        messages=[
            {"role": "user", "content": f"Codebase:\n{codebase_summary}"}
        ]
    )
    return json.loads(response.content[0].text)


def haiku_execute(task: dict, code_context: str) -> str:
    """Haiku executes a single review task (structured execution)."""
    response = client.messages.create(
        model=HAIKU,
        max_tokens=2048,
        system=(
            f"You are a code reviewer focused on: {task['task']}. "
            f"Check these areas: {', '.join(task['focus_areas'])}. "
            f"Produce: {task['expected_output']}"
        ),
        messages=[
            {"role": "user", "content": code_context}
        ]
    )
    return response.content[0].text


def opus_synthesize(plan: list[dict], results: list[str]) -> str:
    """Opus synthesizes worker results (complex reasoning)."""
    combined = "\n\n---\n\n".join(
        f"Task: {plan[i]['task']}\nResult: {results[i]}"
        for i in range(len(results))
    )

    response = client.messages.create(
        model=OPUS,
        max_tokens=4096,
        system="Synthesize these code review results into a final report.",
        messages=[
            {"role": "user", "content": combined}
        ]
    )
    return response.content[0].text


def review_codebase(summary: str, code_context: str) -> str:
    """Full Opus-orchestrator, Haiku-worker pipeline."""

    # Phase 1: Opus plans (expensive but necessary)
    plan = opus_plan(summary)
    print(f"Plan: {len(plan)} tasks (Opus: ~$0.004)")

    # Phase 2: Haiku workers execute in parallel (cheap)
    results = []
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {
            executor.submit(haiku_execute, task, code_context): i
            for i, task in enumerate(plan)
        }
        ordered_results = [None] * len(plan)
        for future in as_completed(futures):
            idx = futures[future]
            ordered_results[idx] = future.result()
            print(f"  Worker {idx+1} done (Haiku: ~$0.001)")

    # Phase 3: Opus synthesizes (expensive but necessary)
    final = opus_synthesize(plan, ordered_results)
    print(f"Synthesis complete (Opus: ~$0.004)")

    return final
```

Deciding which tasks should be Opus vs Haiku:

```python
TASK_MODEL_MAP = {
    # Complex reasoning -> Opus ($5/$25)
    "architectural_analysis": OPUS,
    "design_pattern_review": OPUS,
    "performance_bottleneck_detection": OPUS,
    "security_vulnerability_assessment": OPUS,
    "task_decomposition": OPUS,
    "result_synthesis": OPUS,

    # Structured execution -> Haiku ($1/$5)
    "naming_convention_check": HAIKU,
    "import_organization": HAIKU,
    "documentation_completeness": HAIKU,
    "type_annotation_check": HAIKU,
    "error_message_quality": HAIKU,
    "test_coverage_verification": HAIKU,
    "deprecated_api_scan": HAIKU,
    "log_statement_review": HAIKU,
}

# 6 tasks on Opus, 8 tasks on Haiku
# Token-weighted cost: 43% Opus, 57% Haiku
# Dollar cost: 77% Opus, 23% Haiku
```

The model selection heuristic: if the task has a clear rubric and structured output format, use Haiku. If the task requires judgment, nuance, or synthesis across multiple inputs, use Opus.

## The Tradeoffs

The Opus-Haiku split introduces quality and latency trade-offs:

- **Haiku quality ceiling**: For genuinely difficult tasks (subtle security bugs, complex architectural issues), Haiku may miss findings that Opus would catch. Always benchmark Haiku on your specific task types before deploying.
- **Sonnet as middle ground**: At $3.00/$15.00 per MTok, Sonnet 4.6 sits between Opus and Haiku. Use it for tasks too complex for Haiku but not worth Opus pricing.
- **Parallel execution latency**: Workers running in parallel complete faster than sequential Opus calls, but the total pipeline adds orchestration overhead (plan + synthesize steps).
- **Context window differences**: Haiku 4.5 has a 200K context window vs Opus 4.7's 1M. Very large codebases may not fit in Haiku's context, forcing a model upgrade on those tasks.

## Implementation Checklist

1. List all tasks in your multi-agent pipeline
2. Classify each as "reasoning" (Opus) or "execution" (Haiku)
3. Benchmark Haiku on 50 examples of each execution task
4. If Haiku quality is below threshold, upgrade that task to Sonnet ($3/$15)
5. Implement parallel worker execution with ThreadPoolExecutor
6. Add per-model cost tracking to every API call
7. Compare total pipeline cost against all-Opus baseline

## Measuring Impact

Track the cost-quality balance across your fleet:

- **Model cost split**: Percentage of total spend on Opus vs Haiku. Target: 50-70% Opus (reasoning tasks dominate cost despite being fewer calls).
- **Worker quality score**: Manually review 20 Haiku outputs per week. Score each 1-5 for accuracy. Below 3.5 average means that task should move to Sonnet.
- **Cost per pipeline execution**: Total API cost for one complete orchestrate-execute-synthesize cycle. Compare monthly trend.
- **Token efficiency**: Output quality per dollar spent. Higher is better.

## Related Guides

- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Parallel Subagents Claude Code Best Practices](/parallel-subagents-claude-code-best-practices-2026/)
- [Monitoring and Logging Claude Code Multi-Agent Systems](/monitoring-and-logging-claude-code-multi-agent-systems/)
