---

layout: default
title: "Shared Memory Patterns (2026)"
description: "Learn how to build effective shared memory patterns that enable AI agents to collaborate smoothly using Claude Code skills and features."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, ai-agents, collaboration, shared-memory, multi-agent, claude-skills]
permalink: /shared-memory-patterns-for-collaborating-ai-agents/
reviewed: true
score: 7
geo_optimized: true
---

As AI agent systems grow more sophisticated, the challenge of enabling multiple agents to work together effectively becomes increasingly important. Claude Code skills provide powerful mechanisms for implementing shared memory patterns that allow AI agents to collaborate, share context, and maintain coherent understanding across complex tasks. This guide explores practical patterns for building collaborative AI agent systems using Claude Code.

## Understanding Shared Memory in Multi-Agent Systems

Shared memory in AI agent contexts refers to any mechanism that allows multiple agents to access, read, and modify common information. This differs from traditional single-agent architectures where all state exists within a single execution context. When agents collaborate, they need ways to:

- Share discovered context and research findings
- Maintain awareness of what other agents have accomplished
- Coordinate on complex, multi-step tasks
- Build upon each other's work without redundancy

Claude Code skills can serve as the foundation for these shared memory patterns, acting as both the medium for storage and the mechanism for coordination.

The fundamental challenge is that individual AI agent invocations are stateless by default. Each Claude session starts fresh. Without an external coordination layer, two agents running in parallel have no awareness of each other and may duplicate work, contradict each other's outputs, or overwrite files without knowing they are in conflict. Shared memory patterns solve this by externalizing state into a medium that all agents can read from and write to.

## Why Shared Memory Architecture Matters

Before diving into specific patterns, it's worth understanding what goes wrong without shared memory. Consider a hypothetical pipeline where three Claude agents process a codebase:

- Agent A reviews API endpoints for security issues.
- Agent B reviews the same endpoints for performance.
- Agent C writes a summary report.

Without shared memory, Agent C has no access to what Agents A and B discovered unless you manually pipe their outputs together. With shared memory, Agent C can read structured files written by A and B, reference specific findings, and produce a coherent integrated report.

The architecture becomes even more valuable at scale. A fleet of ten specialized agents working on a large migration project needs a way to track which files have been processed, which are in progress, and which still need attention. otherwise agents will step on each other's work constantly.

## Pattern 1: File-Based Shared Context

The simplest and most reliable shared memory pattern uses the filesystem as a common data store. Claude Code can read and write files, making the filesystem an ideal coordination medium.

## Implementation Approach

Create a shared context directory that all agents can access:

```bash
mkdir -p /workspace/shared-context
mkdir -p /workspace/shared-context/findings
mkdir -p /workspace/shared-context/claims
mkdir -p /workspace/shared-context/completed
```

Each agent writes findings to structured files within this directory. A common pattern uses JSON or Markdown files with timestamps and agent identifiers:

```json
{
 "agent": "research-agent",
 "timestamp": "2026-03-14T10:30:00Z",
 "task": "api-documentation-analysis",
 "findings": {
 "endpoints": 12,
 "authentication": "OAuth2",
 "rate-limits": "1000/hour"
 }
}
```

## Namespace Your Files

Use a consistent naming convention so agents can quickly discover relevant files without reading the entire directory:

```
findings/
 research-agent_2026-03-14T10-30-00_api-docs.json
 security-agent_2026-03-14T10-45-00_auth-review.json
 performance-agent_2026-03-14T11-00-00_bottlenecks.json
```

The pattern `{agent-name}_{timestamp}_{task-slug}.json` gives any agent enough context to decide whether to read a file before opening it.

## Best Practices

Use clear naming conventions that indicate which agent created the content and when. Include a manifest file that indexes all shared documents for quick discovery.

A manifest file is a simple index that agents update whenever they write a new finding:

```json
{
 "last_updated": "2026-03-14T11:00:00Z",
 "entries": [
 {
 "file": "findings/research-agent_2026-03-14T10-30-00_api-docs.json",
 "agent": "research-agent",
 "task": "api-documentation-analysis",
 "status": "completed"
 },
 {
 "file": "findings/security-agent_2026-03-14T10-45-00_auth-review.json",
 "agent": "security-agent",
 "task": "authentication-review",
 "status": "completed"
 }
 ]
}
```

Agents should read the manifest first, identify relevant entries, then read only those files rather than scanning the whole directory.

## Pattern 2: Structured Memory Files with Skills

Claude Code skills can define structured schemas for shared memory, ensuring consistency across agent communications. Create a skill that defines the memory format:

```yaml
---
name: memory-store
description: "Read and write structured memory entries"
---
```

This skill becomes a contract between agents, ensuring that all shared information follows a predictable structure.

A more complete skill definition might include the schema explicitly so that any agent using the skill writes compatible JSON:

```markdown
Memory Store Skill

Memory Entry Schema

Every memory entry MUST include:
- `agent`: string. identifier of the writing agent
- `timestamp`: ISO 8601 string
- `task`: string. slug identifying the task
- `status`: one of "in_progress", "completed", "blocked"
- `findings`: object. task-specific data
- `dependencies`: array of strings. task slugs this entry depends on

Writing a Memory Entry

1. Read the existing manifest at /workspace/shared-context/manifest.json.
2. Write your findings to /workspace/shared-context/findings/{agent}_{timestamp}_{task}.json.
3. Append your entry metadata to the manifest.
4. Never overwrite another agent's findings file.

Reading Memory Entries

1. Read manifest.json to find relevant entries.
2. Load only the files whose task field matches your needs.
3. If a dependency task is "in_progress", wait or flag a dependency.
```

By encoding these rules in a skill, every agent that loads the skill follows the same protocol without needing it re-stated in every prompt.

## Pattern 3: Event-Driven Coordination

For more dynamic collaboration, implement an event log pattern where agents publish and subscribe to state changes. A shared "coordination log" file serves as the event bus:

```markdown
Agent Coordination Log

2026-03-14

10:00 - research-agent
STARTED: API documentation review

10:15 - code-agent
READ: research-agent findings
STARTED: Client library implementation

10:45 - research-agent
COMPLETED: API documentation review
PUBLISHED: 12 endpoints documented
```

This approach allows agents to discover what work has already been done and what's in progress, preventing duplicate efforts.

The event log is append-only by convention. Agents never modify or delete existing entries. they only add new lines at the end. This makes the log safe to write from multiple agents with minimal risk of corruption:

```python
def append_event(log_path, agent_name, event_type, message):
 """Append a single event line to the coordination log."""
 timestamp = datetime.utcnow().strftime("%H:%M")
 entry = f"\n### {timestamp} - {agent_name}\n{event_type}: {message}\n"
 with open(log_path, "a") as f:
 f.write(entry)
```

Agents read the entire log at startup to build situational awareness before beginning their assigned work. A search through the log for their own task name tells them whether another agent has already claimed it.

## Pattern 4: Shared Scratch Pads

For iterative problem-solving, establish shared scratch pads where agents can leave intermediate results. This works particularly well for complex tasks that require multiple passes:

```python
shared_scratchpad.py
SCRATCH_PATH = "/workspace/shared-context/scratchpad.md"

def read_scratchpad():
 """Read current scratchpad contents"""
 try:
 return read_file(SCRATCH_PATH)
 except FileNotFoundError:
 return "# Scratchpad\n\n"

def append_to_scratchpad(agent_name, content):
 """Append agent's contributions to shared scratchpad"""
 existing = read_scratchpad()
 new_content = f"{existing}\n\n## {agent_name}\n{content}"
 write_file(SCRATCH_PATH, new_content)
```

Each agent can add its insights to the scratch pad, and subsequent agents can review previous work before contributing their own.

The scratch pad pattern works best for exploratory tasks where agents are building toward a shared understanding rather than executing distinct subtasks. For example, if a group of agents is collectively analyzing an unfamiliar codebase, each agent reads the scratch pad, adds its observations, and the cumulative document becomes richer with each pass.

A structured scratch pad format improves readability as the document grows:

```markdown
Analysis Scratch Pad. Project: myapp

research-agent. 2026-03-14 10:00

Reviewed the authentication module. Key observations:
- JWT tokens expire after 24 hours.
- Refresh token rotation is implemented.
- No rate limiting on the token endpoint.

security-agent. 2026-03-14 10:30

Read research-agent's notes on token endpoint.
Rate limiting absence is a significant risk. recommend adding.
Reviewed input sanitization on login form: adequate.

performance-agent. 2026-03-14 11:00

JWT validation happens on every request with no caching.
This adds ~5ms per request. Consider a short-lived local cache.
```

This layered structure lets a summary agent later scan for headings and synthesize each agent's perspective into a unified report.

## Pattern 5: Memory Pruning and Consolidation

As collaborative work progresses, shared memory can grow unwieldy. Implement periodic consolidation where agents review and merge related entries:

```python
def consolidate_memory(shared_dir, output_file):
 """Merge related memory entries into unified summaries"""
 entries = []
 for filename in os.listdir(shared_dir):
 if filename.endswith('.json'):
 entries.append(json.load(open(f"{shared_dir}/{filename}")))

 # Group by task and create summaries
 by_task = defaultdict(list)
 for entry in entries:
 by_task[entry['task']].append(entry)

 # Write consolidated summaries
 for task, task_entries in by_task.items():
 summary = {
 "task": task,
 "contributors": list(set(e['agent'] for e in task_entries)),
 "consolidated_findings": merge_findings(task_entries)
 }
 # Write consolidated summary
```

This prevents information overload while preserving the essential insights from collaborative work.

A consolidation agent can be scheduled to run after every N individual agent completions, or triggered when the manifest exceeds a certain number of entries. The consolidated summaries then become the primary reading material for downstream agents, with the original detailed entries archived but no longer in the active read path:

```
/workspace/shared-context/
 manifest.json # Active index
 findings/ # Individual agent findings
 consolidated/ # Merged summaries by topic
 authentication_summary.json
 performance_summary.json
 api_coverage_summary.json
 archive/ # Processed individual findings
```

By moving processed findings to an archive directory, the active workspace stays lean while history is preserved for audit purposes.

## Pattern 6: Agent Awareness Skills

Create skills that make agent collaboration explicit. A "team coordination" skill can maintain awareness of who's working on what:

```yaml
---
name: team-coordination
description: "Track and coordinate multi-agent tasks"
---
Team Coordination Skill

Current Team Status

Maintain a team state file tracking:
- Active agents and their roles
- Current task assignments
- Completed work items
- Blocked tasks requiring handoff

Coordination Protocols

When starting work:
1. Read team state to understand current status
2. Claim your task assignment
3. Update status to "in progress"

When completing work:
1. Document findings in shared context
2. Update team state to "completed"
3. Note any downstream dependencies
```

The team state file is the single source of truth for who is doing what. It looks like this:

```json
{
 "updated": "2026-03-14T11:15:00Z",
 "tasks": [
 {
 "id": "auth-review",
 "description": "Review authentication module for vulnerabilities",
 "assigned_to": "security-agent",
 "status": "completed",
 "output": "findings/security-agent_2026-03-14T10-45-00_auth-review.json"
 },
 {
 "id": "perf-audit",
 "description": "Identify performance bottlenecks in API layer",
 "assigned_to": "performance-agent",
 "status": "in_progress",
 "started": "2026-03-14T11:00:00Z"
 },
 {
 "id": "summary-report",
 "description": "Produce unified findings report",
 "assigned_to": null,
 "status": "pending",
 "depends_on": ["auth-review", "perf-audit"]
 }
 ]
}
```

An agent that is looking for work reads this file, identifies an unclaimed task whose dependencies are all completed, atomically claims it by updating `assigned_to` and `status`, and then begins execution. This prevents two agents from inadvertently picking up the same task.

## Pattern 7: Locking and Conflict Prevention

In high-concurrency scenarios where multiple agents may try to write to the same file simultaneously, implement a simple lock file convention:

```python
import os
import time

def acquire_lock(lock_path, agent_id, timeout=30):
 """Acquire a file lock, waiting up to timeout seconds."""
 start = time.time()
 while time.time() - start < timeout:
 if not os.path.exists(lock_path):
 with open(lock_path, "w") as f:
 f.write(agent_id)
 # Verify we won the race
 with open(lock_path, "r") as f:
 if f.read() == agent_id:
 return True
 time.sleep(0.5)
 return False

def release_lock(lock_path):
 """Release the file lock."""
 if os.path.exists(lock_path):
 os.remove(lock_path)
```

Each shared resource. the manifest, the team state file, the coordination log. gets a corresponding `.lock` file. Agents that need to write acquire the lock, perform their write, and release it. Agents that cannot acquire the lock within the timeout report a conflict for human review.

For most Claude-based workflows where agents run sequentially or in loosely parallel fashion, full locking is unnecessary. But when running a large fleet of agents against a single shared resource, even a simple lock convention prevents hard-to-debug corruption.

## Practical Example: Code Review Pipeline

Consider a multi-agent code review system where different agents specialize in different aspects:

1. Architecture agent reviews design patterns and structure
2. Security agent focuses on vulnerabilities and best practices
3. Performance agent analyzes optimization opportunities

Using shared memory patterns, these agents can collaborate effectively:

- Each agent writes findings to structured files in `/workspace/reviews/<pr-id>/`
- A manifest file indexes all findings by category
- The security agent can reference architecture findings when assessing attack surfaces
- A final "summary agent" consolidates all findings into a unified report

This separation of concerns with shared context produces more thorough reviews than any single agent could generate.

The directory structure for a single PR review looks like this:

```
/workspace/reviews/PR-447/
 manifest.json
 team-state.json
 coordination-log.md
 findings/
 architecture-agent_findings.json
 security-agent_findings.json
 performance-agent_findings.json
 consolidated/
 unified-report.md
```

The unified report written by the summary agent might reference specific findings from each specialist:

```markdown
Code Review: PR-447

Executive Summary

Three agents reviewed this PR. Key concerns:

Security (High Priority): The new endpoint at /api/export lacks authentication
middleware. See security-agent findings, item 3.

Performance (Medium Priority): The export query runs without pagination and could
return unbounded result sets. See performance-agent findings, item 1.

Architecture (Low Priority): The export service duplicates logic already in
ReportService. Consider extracting a shared helper. See architecture-agent findings, item 2.
```

Cross-referencing between agent outputs is only possible because each agent wrote structured, discoverable findings to the shared workspace.

## Choosing the Right Pattern

Not every project needs every pattern. Here is a practical guide for matching patterns to scenarios:

| Scenario | Recommended Patterns |
|---|---|
| 2-3 agents, sequential | File-based context + event log |
| 5+ agents, parallel | Team state file + locking + manifest |
| Iterative/exploratory work | Shared scratch pad |
| Long-running pipelines | Memory consolidation |
| Formal handoffs between agents | Structured skills + team coordination |
| Audit requirements | Append-only event log + archive |

Start with the simplest pattern that works and add complexity only when the simpler approach breaks down. A file-based shared context and a coordination log will handle the majority of multi-agent Claude workflows without requiring lock management or consolidation agents.

## Conclusion

Shared memory patterns transform isolated AI agents into collaborative teams. Claude Code skills provide the foundation through file operations, structured schemas, and coordination mechanisms. Start with simple file-based patterns and evolve toward more sophisticated event-driven architectures as your multi-agent systems grow. The key principle remains constant: establish clear contracts for what information gets shared, how it's structured, and how agents discover and build upon each other's work.

By implementing these patterns, you can create AI agent systems that scale collaboration effectively, avoid redundant work, and produce higher quality outcomes through coordinated effort. The patterns described here are not theoretical. they are the same coordination mechanisms used in production multi-agent Claude deployments, adapted for the filesystem-centric model that Claude Code's skill architecture makes natural.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=shared-memory-patterns-for-collaborating-ai-agents)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Multi-Agent Orchestration Patterns Guide](/claude-code-multi-agent-orchestration-patterns-guide/)
- [Grounding AI Agents in Real World Data Explained](/grounding-ai-agents-in-real-world-data-explained/)
- [How to Coordinate Multiple AI Agents in Pipeline](/how-to-coordinate-multiple-ai-agents-in-pipeline/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


