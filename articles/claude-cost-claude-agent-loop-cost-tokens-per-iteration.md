---
layout: default
title: "Claude Agent Loop Cost (2026)"
description: "Each agent loop iteration costs 245-735 tokens in tool overhead. At 100 iterations on Opus 4.7, that is $2.05 in overhead alone."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-agent-loop-cost-tokens-per-iteration/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, multi-agent, token-overhead]
---

# Claude Agent Loop Cost: Tokens Per Iteration

Every agent loop iteration adds 245 to 735 tokens of tool overhead before a single token of useful work is done. Over 100 iterations on a 5-agent fleet running Opus 4.7, that overhead reaches 409,250 tokens -- costing $2.05 just for the structural tokens that describe available tools. Understanding and minimizing this overhead is essential for cost-efficient agent systems.

## The Setup

You have built an autonomous coding agent that loops through read-edit-test cycles. Each iteration sends the full system prompt (346 tokens of tool definitions), invokes a tool (245-735 tokens), receives the result, and decides the next action.

The useful content -- the actual code being reviewed, the files being read, the edits being made -- sits on top of this fixed overhead. At 100 iterations, the agent has consumed 34,600 tokens just for system prompt repetition and 47,250 tokens for tool schema definitions, before counting any actual context.

On Opus 4.7, that is $0.41 in overhead per agent, per sprint. Across 5 agents, $2.05 in pure overhead.

## The Math

**Tool overhead per interaction (verified from Anthropic docs):**

| Component | Tokens |
|-----------|--------|
| System prompt (auto/none mode) | 346 |
| System prompt (any/tool mode) | 313 |
| Bash tool schema | 245 |
| Text editor tool schema | 700 |
| Computer use tool schema | 735 |

**Per-iteration overhead scenarios:**

Agent using bash only: 346 + 245 = 591 tokens/iteration
Agent using text editor: 346 + 700 = 1,046 tokens/iteration
Agent using bash + editor: 346 + 245 + 700 = 1,291 tokens/iteration
Agent using all tools: 346 + 245 + 700 + 735 = 2,026 tokens/iteration

**100 iterations, 5 agents (bash + editor):**
- 5 x 100 x 1,291 = 645,500 overhead tokens
- On Opus 4.7: 645,500 x $5.00/MTok = $3.23

**Cost breakdown per sprint:**
- Tool overhead: $3.23 (13% of a $25 sprint)
- Useful context: ~$21.77
- This 13% is pure infrastructure cost that cannot be eliminated but can be minimized

## The Technique

Reduce tool overhead by declaring only the tools each agent needs and minimizing iteration count:

```python
import anthropic

client = anthropic.Anthropic()


def create_minimal_agent(
    task_type: str,
    model: str = "claude-opus-4-7-20250415"
) -> dict:
    """Configure agent with minimal tool set for its task type."""

    # Only declare tools the agent actually needs
    tool_configs = {
        "code_reader": {
            "tools": ["bash"],  # 245 tokens overhead
            "overhead_per_iter": 591,
        },
        "code_editor": {
            "tools": ["bash", "text_editor"],  # 945 tokens
            "overhead_per_iter": 1291,
        },
        "full_agent": {
            "tools": ["bash", "text_editor", "computer_use"],  # 1680 tokens
            "overhead_per_iter": 2026,
        },
        "chat_only": {
            "tools": [],  # 0 tool tokens
            "overhead_per_iter": 346,
        },
    }

    config = tool_configs.get(task_type, tool_configs["chat_only"])

    return {
        "model": model,
        "tools": config["tools"],
        "overhead_per_iter": config["overhead_per_iter"],
        "estimated_100_iter_overhead": config["overhead_per_iter"] * 100,
        "estimated_100_iter_cost": config["overhead_per_iter"] * 100 * 5.0 / 1e6
    }


# Compare overhead by configuration
for task_type in ["chat_only", "code_reader", "code_editor", "full_agent"]:
    config = create_minimal_agent(task_type)
    print(f"{task_type:>15}: {config['overhead_per_iter']:>5} tokens/iter, "
          f"${config['estimated_100_iter_cost']:.3f}/100 iters")
```

Strategies to reduce iteration count (and therefore overhead):

```python
def optimize_agent_loop(
    max_iterations: int = 100,
    early_stop_threshold: int = 3
) -> dict:
    """Agent loop with early stopping and batch operations."""

    iterations = 0
    no_change_count = 0
    total_overhead_tokens = 0
    overhead_per_iter = 1291  # bash + editor

    for i in range(max_iterations):
        iterations += 1
        total_overhead_tokens += overhead_per_iter

        # Simulate agent work
        # In production: call Claude, execute tools, check results
        made_changes = simulate_iteration(i)

        if not made_changes:
            no_change_count += 1
        else:
            no_change_count = 0

        # Early stop: if no changes for N iterations, task is done
        if no_change_count >= early_stop_threshold:
            break

    overhead_cost = total_overhead_tokens * 5.0 / 1e6  # Opus pricing

    return {
        "iterations": iterations,
        "overhead_tokens": total_overhead_tokens,
        "overhead_cost": f"${overhead_cost:.4f}",
        "saved_iterations": max_iterations - iterations,
        "saved_tokens": (max_iterations - iterations) * overhead_per_iter
    }


def simulate_iteration(i: int) -> bool:
    """Simulate whether an iteration makes meaningful changes."""
    # Typically, agents make changes in early iterations
    # and converge (no changes) in later iterations
    return i < 15  # Simulates 15 productive iterations
```

Batch tool calls to reduce iterations:

```bash
# Instead of: read file, analyze, read another file, analyze
# Do: read ALL files in one iteration, analyze all at once
python3 -c "
# Single-iteration overhead: 1,291 tokens (bash + editor)
# 5 separate reads = 5 iterations = 6,455 overhead tokens
# 1 batch read = 1 iteration = 1,291 overhead tokens

separate = 5 * 1291
batched = 1 * 1291
saved = separate - batched
print(f'Separate reads: {separate:,} overhead tokens')
print(f'Batched read: {batched:,} overhead tokens')
print(f'Saved: {saved:,} tokens (\${saved * 5.0 / 1e6:.4f} on Opus)')
"
```

## The Tradeoffs

Minimizing tool overhead has limits:

- **Removing tools reduces capability**: An agent without the text editor tool cannot edit files. Only remove tools the agent genuinely does not need for its assigned task.
- **Fewer iterations may reduce quality**: Early stopping saves tokens but may terminate before the agent reaches optimal output. Tune the early-stop threshold per task type.
- **Batching tool calls increases context size**: Reading 5 files in one iteration sends all 5 file contents in a single context, consuming more input tokens per call. The trade-off is fewer overhead tokens vs more content tokens.
- **Overhead is proportionally smaller with large contexts**: For agents processing 100K-token codebases, the 1,291-token overhead per iteration is 1.3% of context. For agents with 5K-token tasks, it is 26%.

## Implementation Checklist

1. Audit each agent's actual tool usage over 10 sprints
2. Remove tools that an agent never invokes (saves 245-735 tokens/iteration)
3. Implement early stopping based on consecutive no-change iterations
4. Batch related tool calls into single iterations where possible
5. Track total overhead tokens vs useful tokens per agent per sprint
6. Set iteration limits per agent based on observed convergence patterns
7. Monitor overhead-to-useful ratio (target: below 15% of total input tokens)

## Measuring Impact

Track overhead efficiency:

- **Overhead ratio**: Tool overhead tokens / total input tokens per sprint. Below 15% is good, below 10% is excellent.
- **Iterations to convergence**: Average iterations before early stopping triggers. Lower means less overhead.
- **Cost per useful token**: Total cost / (total tokens - overhead tokens). This reveals the true cost of productive work.
- **Tool utilization**: For each declared tool, track how often it is actually invoked. Remove tools with under 5% utilization.

## Related Guides

- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Parallel Subagents Claude Code Best Practices](/parallel-subagents-claude-code-best-practices-2026/)
- [Monitoring and Logging Claude Code Multi-Agent Systems](/monitoring-and-logging-claude-code-multi-agent-systems/)

## See Also

- [Claude Agent Token Budget Management Guide](/claude-agent-token-budget-management/)
- [Claude Max Subscription vs API for Agent Fleets](/claude-max-subscription-vs-api-agent-fleets/)
