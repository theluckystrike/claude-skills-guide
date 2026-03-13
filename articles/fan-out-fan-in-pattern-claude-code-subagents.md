---
layout: post
title: "Fan Out Fan In Pattern with Claude Code Subagents"
description: "Learn how to implement the fan out fan in pattern using Claude Code subagents for parallel task execution. Practical examples and code snippets for develop"
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, subagents, parallel-processing, automation, workflows]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Fan Out Fan In Pattern with Claude Code Subagents

The fan out fan in pattern is a powerful concurrency paradigm that distributes work across multiple workers, collects results, and aggregates them into a final output. When applied to Claude Code subagents, this pattern enables you to parallelize complex tasks that would otherwise execute sequentially—dramatically reducing processing time for batch operations, multi-file analysis, and distributed workflows.

This guide covers practical implementation of the fan out fan in pattern using Claude Code subagents, with real code examples you can adapt for your projects.

## Understanding Subagents in Claude Code

Claude Code supports subagents through the `/subagent` skill or by invoking agents directly in your configuration. A subagent is an independent Claude instance that handles a specific task while the main agent coordinates the workflow. Subagents operate with their own context, making them ideal for parallel execution scenarios.

To use subagents effectively, you need to understand how Claude Code manages agent sessions and message passing between the coordinator and worker agents.

## Implementing the Fan Out Phase

The fan out phase involves spawning multiple subagents to handle independent tasks simultaneously. Consider a scenario where you need to analyze five different code repositories for security vulnerabilities:

```
# Coordinate analysis across multiple repositories
/subagent
Analyze repository at /projects/ecommerce-api for security vulnerabilities.
Focus on: SQL injection, XSS, authentication flaws.
Return findings as JSON with severity levels.
```

You would spawn separate subagents for each repository, passing the specific repository path and focus area to each. The coordinator does not wait for one to finish before spawning the next—this is the fan out.

A practical implementation in a shell script might look like:

```bash
#!/bin/bash
# Fan out: spawn analysis agents for each repository

REPOS=("ecommerce-api" "user-service" "payment-gateway" "inventory-system" "notification-service")

for repo in "${REPOS[@]}"; do
  claude --subagent "analyze /projects/$repo --security" &
done

# Fan in: wait for all background jobs
wait
echo "All repository analyses complete"
```

The key principle is that each subagent operates independently on its assigned subset of work.

## Implementing the Fan In Phase

The fan in phase collects results from all completed subagents and aggregates them into a unified output. This is where you apply business logic to merge findings, calculate summaries, or generate reports.

Continuing the security analysis example, your main agent would aggregate results like this:

```python
def aggregate_security_findings(results):
    """Fan in: combine and prioritize findings from all subagents."""
    
    all_findings = []
    severity_counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
    
    for result in results:
        if result["status"] == "success":
            all_findings.extend(result["findings"])
            severity_counts[result["severity"]] += 1
    
    # Generate prioritized action items
    prioritized = sorted(
        all_findings, 
        key=lambda x: {"critical": 0, "high": 1, "medium": 2, "low": 3}[x["severity"]]
    )
    
    return {
        "total_findings": len(all_findings),
        "by_severity": severity_counts,
        "action_items": prioritized[:10]  # Top 10 priorities
    }
```

The fan in phase transforms raw subagent outputs into actionable insights.

## Practical Use Cases

### Parallel Code Review

The fan out fan in pattern excels when you need to review multiple pull requests or code files simultaneously. Using the code review skill, spawn subagents for each PR:

```
/review
Review PR #142 for API endpoint changes.
Check for: error handling, input validation, performance concerns.
```

Coordinate the results to generate a unified code review summary with prioritized feedback.

### Batch Document Processing

If you work with document processing pipelines, the [pdf skill combined with subagents](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) enables parallel extraction:

- Fan out: Spawn subagents to process individual documents using the pdf skill
- Fan in: Aggregate extracted text, tables, and metadata into a searchable index

This approach scales linearly with the number of documents, limited only by your system's parallel processing capacity.

### Multi-Environment Testing

Deploy your application across staging, testing, and production-like environments simultaneously:

```
/subagent
Run integration tests against staging environment.
Report: test pass/fail counts, response times, error logs.
```

Collect results to identify environment-specific issues that might not appear in isolated testing.

## Error Handling Strategies

Robust fan out fan in implementations must handle partial failures gracefully. Consider these patterns:

**Timeout-based continuation:** Set maximum wait times for subagents. If a subagent exceeds its timeout, proceed with available results and log the failure:

```bash
timeout 300 claude --subagent "long-task" &
SUBAGENT_PID=$!

# Do other work...

# Check if still running
if kill -0 $SUBAGENT_PID 2>/dev/null; then
    wait $SUBAGENT_PID || echo "Subagent completed with errors"
fi
```

**Result validation:** Before aggregating, validate each subagent's output structure. Discard malformed results and flag them for manual review.

**Idempotent retries:** Design subagent tasks to be idempotent—safe to retry without side effects. This allows automatic retry logic when transient failures occur.

## Performance Considerations

The fan out fan in pattern provides significant speedups, but consider these factors:

- **Subagent overhead:** Each subagent spawns a new Claude session. For very short tasks, this overhead may exceed the parallelization benefit.
- **Context window limits:** Aggregated results must fit within your coordinator's context window. Chunk large result sets if needed.
- **Rate limiting:** If your workflow involves external APIs, respect rate limits by controlling subagent spawn rates.
- **Resource consumption:** Running many subagents simultaneously increases memory and CPU usage. Monitor system resources and adjust parallelism accordingly.

For most practical applications, running 5-10 subagents in parallel provides a good balance between speedup and resource consumption.

## Skill Recommendations

Several Claude skills complement the fan out fan in pattern:

- The **tdd skill** helps generate test cases for your parallel workloads
- The **frontend-design skill** can coordinate multiple design review subagents
- The **supermemory skill** stores aggregated results for historical analysis
- The **project-management skill** helps track progress across parallel workstreams

Combine these skills strategically based on your specific workflow requirements.

## Conclusion

The fan out fan in pattern transforms Claude Code from a sequential task executor into a parallel processing powerhouse. By distributing work across subagents and aggregating results intelligently, you can tackle batch processing, comprehensive analysis, and multi-environment workflows that would be impractical with sequential execution.

Start with small parallel workloads to build intuition, then scale up as you refine your error handling and aggregation logic. The pattern adapts well to various domains—whether you are processing documents with the pdf skill, running tests with the tdd skill, or coordinating complex development workflows.

## Related Reading

- [Claude Code Agent Swarm Coordination Strategies](/claude-skills-guide/articles/claude-code-agent-swarm-coordination-strategies/) — Complement fan-out/fan-in with shared state coordination patterns for swarms of agents.
- [Multi-Agent Orchestration with Claude Subagents Guide](/claude-skills-guide/articles/multi-agent-orchestration-with-claude-subagents-guide/) — Broader orchestration patterns that build on the fan-out/fan-in foundation.
- [Claude Code Multi-Agent Subagent Communication Guide](/claude-skills-guide/articles/claude-code-multi-agent-subagent-communication-guide/) — How subagents communicate during fan-in aggregation phases.
- [Advanced Claude Skills](/claude-skills-guide/advanced-hub/) — Advanced parallel processing and agent architecture patterns for production use.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
