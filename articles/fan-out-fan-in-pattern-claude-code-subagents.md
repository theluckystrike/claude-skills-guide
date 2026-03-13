---
layout: post
title: "Fan-Out Fan-In Pattern with Claude Code Subagents"
description: "Learn how to implement the fan-out fan-in pattern using Claude Code subagents for parallel task execution and efficient result aggregation."
date: 2026-03-14
author: theluckystrike
---

# Fan-Out Fan-In Pattern with Claude Code Subagents

The fan-out fan-in pattern is a powerful concurrency strategy that enables parallel processing of multiple independent tasks, then aggregates their results into a unified output. When implemented with Claude Code subagents, this pattern becomes exceptionally useful for developers building complex automation workflows, handling bulk operations, or processing multiple data sources simultaneously.

## Understanding the Pattern

Fan-out refers to the process of spawning multiple subagents to handle independent tasks in parallel. Fan-in is the subsequent aggregation of results from these subagents into a coherent whole. This approach significantly reduces total execution time when tasks are independent and can run concurrently.

Claude Code provides native support for subagent creation through the `claude` CLI tool and programmatic interfaces. By leveraging this capability, you can orchestrate complex workflows that distribute work across multiple AI agents while maintaining control over the aggregation logic.

## Basic Implementation Structure

The fundamental structure involves three key phases: task decomposition, parallel execution, and result aggregation.

```python
import subprocess
import json
from concurrent.futures import ThreadPoolExecutor, as_completed

def fan_out_tasks(tasks, max_workers=5):
    """Execute tasks in parallel using Claude Code subagents."""
    results = []
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_task = {
            executor.submit(process_with_claude, task): task 
            for task in tasks
        }
        
        for future in as_completed(future_to_task):
            task = future_to_task[future]
            try:
                result = future.result()
                results.append(result)
            except Exception as e:
                results.append({"error": str(e), "task": task})
    
    return fan_in_results(results)

def process_with_claude(task):
    """Invoke Claude Code with a specific task."""
    prompt = f"Process this task: {task}"
    cmd = ["claude", "-p", prompt]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return {"task": task, "output": result.stdout}

def fan_in_results(results):
    """Aggregate results from all subagents."""
    aggregated = {
        "total_tasks": len(results),
        "successful": sum(1 for r in results if "error" not in r),
        "results": results
    }
    return aggregated
```

## Practical Applications

### Bulk File Processing

When you need to process multiple files with similar operations, the fan-out fan-in pattern excels. For instance, using the **pdf** skill to extract text from hundreds of PDF documents becomes highly efficient when you spawn multiple subagents, each handling a subset of files.

```bash
# Example: Process multiple files using Claude Code
claude -p "Extract all text from file1.pdf and return as JSON"
claude -p "Extract all text from file2.pdf and return as JSON"
# ... parallel execution continues
```

### Multi-Source Data Aggregation

The pattern shines when gathering information from disparate sources. Suppose you're building a research assistant that pulls data from multiple APIs or documents. You can spawn subagents using the **supermemory** skill to query different knowledge bases in parallel, then aggregate the findings into a comprehensive report.

### Test-Driven Development Workflows

When working with the **tdd** skill, you can fan out test generation across multiple modules simultaneously. Each subagent generates tests for a specific module, and the results are aggregated into a complete test suite.

## Advanced Patterns with Claude Skills

### Skill-Specific Subagent Routing

You can route tasks to specialized subagents based on their capabilities:

```python
SKILL_ROUTER = {
    "frontend": "frontend-design",
    "document": "pdf",
    "testing": "tdd",
    "memory": "supermemory",
    "presentation": "pptx",
    "spreadsheet": "xlsx"
}

def route_to_specialized_agent(task_type, task_data):
    """Route task to the appropriate Claude skill subagent."""
    skill = SKILL_ROUTER.get(task_type)
    prompt = f"[Use {skill} skill] Process: {task_data}"
    
    result = subprocess.run(
        ["claude", "-p", prompt],
        capture_output=True, text=True
    )
    return result.stdout
```

### Hierarchical Fan-Out

For complex workflows, implement hierarchical fan-out where primary agents spawn secondary agents:

```python
def hierarchical_fan_out(primary_tasks, max_primary=3, max_secondary=5):
    """Two-level fan-out for complex task structures."""
    primary_results = []
    
    # Level 1: Primary agents
    for primary_task in primary_tasks[:max_primary]:
        secondary_tasks = decompose_task(primary_task)
        
        # Level 2: Secondary agents
        with ThreadPoolExecutor(max_workers=max_secondary) as executor:
            futures = [
                executor.submit(process_with_claude, task) 
                for task in secondary_tasks
            ]
            secondary_results = [f.result() for f in as_completed(futures)]
        
        primary_results.append({
            "primary": primary_task,
            "secondary_results": secondary_results
        })
    
    return aggregate_hierarchical_results(primary_results)
```

## Error Handling and Resilience

Robust fan-out fan-in implementations must handle failures gracefully:

```python
def resilient_fan_out(tasks, max_workers=5, retries=2):
    """Execute tasks with retry logic and error tracking."""
    results = []
    failed_tasks = []
    
    for attempt in range(retries):
        if not tasks:
            break
            
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {
                executor.submit(safe_process, task): task 
                for task in tasks
            }
            
            for future in as_completed(futures):
                task = futures[future]
                result = future.result()
                
                if result.get("success"):
                    results.append(result)
                else:
                    failed_tasks.append(task)
        
        tasks = failed_tasks
        failed_tasks = []
    
    return {
        "results": results,
        "failed": failed_tasks,
        "success_rate": len(results) / (len(results) + len(failed_tasks))
    }

def safe_process(task):
    """Process task with error handling."""
    try:
        output = process_with_claude(task)
        return {"success": True, "output": output}
    except Exception as e:
        return {"success": False, "error": str(e), "task": task}
```

## Performance Considerations

When implementing this pattern, consider these factors:

**Worker Count Tuning**: Balance between parallelism and resource usage. Start with 3-5 workers and adjust based on your use case. The **algorithmic-art** skill, for example, may require fewer concurrent workers due to higher memory usage.

**Token Budget Management**: Each subagent consumes tokens from your Claude API allocation. Monitor usage and implement budget controls for large-scale operations.

**Rate Limiting**: Implement throttling to respect API limits and prevent token exhaustion during intensive workloads.

## Conclusion

The fan-out fan-in pattern with Claude Code subagents enables scalable, efficient processing of parallel workloads. Whether you're automating document processing with the **pdf** skill, generating comprehensive tests with **tdd**, or building complex multi-agent systems, this pattern provides a solid foundation for concurrent AI-driven workflows.

Start with simple two-agent implementations and progressively add complexity as your requirements grow. The pattern's flexibility allows it to adapt to virtually any parallel processing need in your Claude Code projects.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
