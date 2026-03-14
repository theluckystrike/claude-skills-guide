---
layout: default
title: "Passing Context Between Claude Code Subagents Guide"
description: "Learn how to effectively pass context and state between subagents in Claude Code. Practical patterns for multi-agent workflows with code examples."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /passing-context-between-claude-code-subagents-guide/
---

# Passing Context Between Claude Code Subagents Guide

Claude Code enables powerful multi-agent architectures through subagents. For an introduction to subagent coordination, see [multi-agent orchestration with Claude subagents](/claude-skills-guide/multi-agent-orchestration-with-claude-subagents-guide/). When building complex workflows, you need reliable ways to pass context, share state, and coordinate results between subagents. This guide covers practical patterns for context passing that work in real production workflows.

## Understanding Subagent Context Architecture

[Claude Code subagents operate as isolated execution units within a parent session](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) Each subagent receives its own context window, which means data generated in one subagent does not automatically propagate to another. This isolation provides safety and predictability, but requires explicit patterns for sharing information.

The parent agent serves as the coordinator. It holds the master context and decides which pieces of information to pass to each subagent at invocation time. This design gives you fine-grained control over what each subagent sees and can act upon.

## Pattern 1: Explicit Context Injection at Invocation

The most straightforward approach involves passing context directly when invoking a subagent. You construct the prompt with all necessary background information included.

```
/subagent:code-review Review this PR focusing on security issues. The codebase uses Python Django and the PR modifies authentication logic in accounts/views.py
```

This pattern works well when the context is relatively small and static. For larger contexts, consider summarizing or extracting only the relevant portions before passing to the subagent.

## Pattern 2: Shared File-Based State

When subagents need to work with larger datasets or maintain state across multiple turns, file-based storage provides a reliable mechanism. The parent agent writes context to a shared file, then instructs subagents to read from it.

```python
# Parent agent creates shared context
context_data = {
    "task_id": "pr_review_042",
    "priority": "high",
    "files_under_review": ["auth.py", "tokens.py", "permissions.py"],
    "previous_review_comments": []
}

# Write to shared file
with open(".claude/context/review_task.json", "w") as f:
    json.dump(context_data, f)
```

Subagents then read this file at startup:

```
/subagent:security-scan Read .claude/context/review_task.json and perform security analysis on the listed files
```

This pattern integrates well with skills like the tdd skill, which might need access to test specifications or requirements documents across multiple subagent invocations.

## Pattern 3: Structured Result Passing

For workflows where one subagent's output becomes another subagent's input, use structured result objects. Define a clear schema for what each subagent should return, making downstream processing reliable.

```
/subagent:data-extractor Extract all financial metrics from Q4-report.pdf and return as JSON with keys: revenue, expenses, net_income, yoy_change
```

The parent agent then parses this output and passes it to the next subagent:

```
/subagent:financial-analysis The extracted metrics are: {extracted_json}. Create a visualization comparing these to industry benchmarks
```

This pattern works particularly well with the pdf skill for extraction workflows and the xlsx skill when generating reports from extracted data.

## Pattern 4: Context Summarization for Long Workflows

For extended multi-step workflows, context can grow beyond manageable limits. Periodic summarization keeps things efficient. The parent agent periodically asks a subagent to summarize the current state:

```
/subagent:summarizer Review the current project state including all subagent results so far and provide a concise summary of: 1) completed tasks, 2) pending items, 3) blockers
```

Store this summary in a dedicated context file that gets passed to all subsequent subagents. This pattern prevents context window exhaustion in long-running workflows.

## Pattern 5: Event-Driven Coordination

For more complex architectures, consider an event-based approach where subagents publish results to named channels, and other subagents subscribe to those channels.

```yaml
# In skill definition or workflow config
channels:
  - name: code_analysis
    subscribers: [security-review, performance-check]
  - name: test_results
    subscribers: [report-generator]
```

The frontend-design skill might publish component specifications to a channel that the pdf skill then consumes for documentation generation.

## Best Practices for Context Passing

Keep context payloads focused. Include only what each subagent needs rather than dumping entire conversation histories. This improves both reliability and performance.

Use consistent naming conventions for shared files and channels. A clear structure like `.claude/context/{workflow_name}/{agent_name}.json` makes debugging much easier.

Log context passing points in your workflow. When a subagent fails, knowing exactly what context it received helps identify the problem quickly.

Handle partial failures gracefully. If one subagent fails, ensure downstream subagents can still operate with the context they received up to that point.

## Combining Patterns in Production

Real-world workflows often combine multiple patterns. A typical production pipeline might use:

1. File-based state for persistent configuration
2. Explicit injection for immediate task context
3. Structured results for inter-agent data flow
4. Periodic summarization for long workflows

For example, a documentation generation pipeline might invoke the pdf skill to extract content, pass that to a writing subagent, then use the xlsx skill to generate supporting data tables, and finally invoke frontend-design skill for visual components.

## Troubleshooting Context Issues

If subagents appear to miss context, verify the parent agent actually received and stored the information first. Check file permissions if using file-based storage. Review whether the context exceeded token limits, which can cause truncation.

When results seem inconsistent across subagents, ensure they're reading from the same version of shared files. Timestamp your context files to detect stale data issues.


## Related Reading

- [Multi-Agent Orchestration with Claude Subagents Guide](/claude-skills-guide/multi-agent-orchestration-with-claude-subagents-guide/) — Understand the subagent coordination model before implementing context-passing patterns.
- [Claude Code Multi-Agent Subagent Communication Guide](/claude-skills-guide/claude-code-multi-agent-subagent-communication-guide/) — Implement clear communication protocols alongside context passing for reliable workflows.
- [Claude SuperMemory Skill: Persistent Context Guide](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/) — Use the supermemory skill to persist and share context across subagent sessions.
- [Claude Skills Advanced Hub](/claude-skills-guide/advanced-hub/) — Explore advanced context management and subagent coordination patterns.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
