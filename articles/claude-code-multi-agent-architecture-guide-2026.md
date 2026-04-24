---
title: "Claude Code Multi-Agent Architecture"
description: "Guide to Claude Code multi-agent patterns including sub-agent spawning, parallel execution, task delegation, and orchestration strategies."
permalink: /claude-code-multi-agent-architecture-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Multi-Agent Architecture Guide (2026)

Claude Code can spawn sub-agents — independent Claude instances that work on subtasks in parallel. This turns a single coding session into a coordinated team. Understanding when and how to use multi-agent patterns is the difference between wasting tokens and multiplying productivity.

## How Multi-Agent Works

Claude Code's multi-agent system works through the Agent tool:

```
Main Agent (orchestrator)
├── Sub-Agent A (frontend task)
├── Sub-Agent B (backend task)
└── Sub-Agent C (test writing)
```

The main agent delegates tasks to sub-agents, each running in its own context. Sub-agents can read files, run commands, and write code — but they report results back to the orchestrator.

The [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) repo (9K+ stars) documents the exact sub-agent prompt, revealing how sub-agents are constrained compared to the main agent.

## When to Use Multi-Agent

### Good Use Cases
- **Parallel file generation:** Creating 10 similar files simultaneously
- **Independent tasks:** Frontend and backend changes that do not depend on each other
- **Research and implementation:** One agent researches while another codes
- **Test writing:** Generating tests for multiple modules in parallel
- **Code review:** Multiple agents reviewing different aspects (security, performance, style)

### Poor Use Cases
- **Sequential dependencies:** Task B needs Task A's output
- **Small tasks:** Spawning a sub-agent for a one-line change wastes tokens
- **Shared state:** When agents need to coordinate on the same file
- **Debugging:** Linear investigation works better than parallel guessing

## Architecture Patterns

### Pattern 1: Fan-Out / Fan-In

The orchestrator distributes independent tasks, then collects results:

```markdown
## Orchestration Plan
1. Spawn Agent A: Write user service tests
2. Spawn Agent B: Write order service tests
3. Spawn Agent C: Write payment service tests
4. Collect results: Verify all tests pass together
```

This works best when tasks are independent and produce non-overlapping outputs.

### Pattern 2: Pipeline

Each agent processes a stage and passes results to the next:

```markdown
## Pipeline
Stage 1 (Agent A): Parse requirements into task list
Stage 2 (Agent B): Implement each task
Stage 3 (Agent C): Write tests for implementations
Stage 4 (Agent D): Review and fix issues
```

The [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars) automates Stage 1 by parsing PRDs into structured task lists that agents can execute.

### Pattern 3: Specialist Agents

Different agents have different expertise:

```markdown
## Specialist Team
- Security Agent: Reviews all code for vulnerabilities
- Performance Agent: Profiles and optimizes hot paths
- Documentation Agent: Generates docs for new functions
- Test Agent: Writes unit and integration tests
```

The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (22K+ stars) provides 16 pre-built specialist agents with slash commands for invoking them.

### Pattern 4: Supervisor

One agent monitors and corrects others:

```markdown
## Supervisor Pattern
- Worker Agent: Implements features
- Supervisor Agent: Reviews each implementation for:
  - CLAUDE.md compliance
  - Test coverage
  - Security issues
  - Performance concerns
- If issues found: Worker Agent fixes them
```

## Configuring Multi-Agent

### CLAUDE.md for Orchestration

```markdown
## Multi-Agent Rules
- Maximum 5 concurrent sub-agents
- Each sub-agent works on ONE file or ONE module
- Sub-agents do NOT modify files another agent is working on
- Orchestrator verifies all sub-agent outputs before committing
- If two agents need the same file, serialize their work
```

### Task Distribution Strategy

```markdown
## Task Assignment
When delegating to sub-agents:
1. Define the exact scope (which files, which functions)
2. Provide the relevant CLAUDE.md section for that scope
3. Set acceptance criteria (tests pass, types check, etc.)
4. Specify what the sub-agent should report back
```

## Cost Considerations

Multi-agent usage multiplies token costs. Each sub-agent starts a new context with:
- System prompt (~4K tokens)
- CLAUDE.md content (~2K tokens)
- Relevant file content (varies)
- Task instructions (~500 tokens)

For a 5-agent parallel task, expect 5x the token cost of a single-agent approach. Use [ccusage](https://github.com/ryoppippi/ccusage) to track multi-agent session costs:

```bash
npx ccusage
```

## Real-World Example

Writing a CRUD API with tests for 5 models:

**Single agent (sequential):** ~45 minutes, processes one model at a time.

**Multi-agent (parallel):**
```
Orchestrator: "Create CRUD API + tests for 5 models"
├── Agent 1: User model + routes + tests
├── Agent 2: Order model + routes + tests
├── Agent 3: Product model + routes + tests
├── Agent 4: Payment model + routes + tests
└── Agent 5: Inventory model + routes + tests
Orchestrator: Verify integration, fix conflicts
```
~15 minutes total, 3x faster, 5x token cost.

The tradeoff: speed vs cost. Use multi-agent when time matters more than tokens.

## Orchestration Frameworks

The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) (40K+ stars) index catalogs orchestration patterns and tools. Key options:

- **claude-task-master:** Structured task decomposition with dependency ordering
- **SuperClaude:** Pre-built agent roles with slash commands
- **Custom CLAUDE.md:** Roll your own orchestration rules

## FAQ

### Can sub-agents use MCP servers?
Sub-agents inherit the MCP configuration from the parent session. They can access the same MCP servers as the main agent.

### What happens if two agents edit the same file?
The last write wins, potentially overwriting the first agent's changes. Prevent this by assigning non-overlapping file scopes to each agent.

### How deep can agent nesting go?
Sub-agents can theoretically spawn their own sub-agents, but this is rarely useful. Two levels (orchestrator + workers) is the practical maximum.

### Do sub-agents share context?
No. Each sub-agent starts with a fresh context. The orchestrator must pass relevant information as part of the task delegation.

### Can I specify different CLAUDE.md rules per sub-agent?
Not directly. Sub-agents read the same CLAUDE.md. You can include role-specific sections that only apply when the agent is operating in that role.

For the full ecosystem overview, see the [tools map](/claude-code-ecosystem-complete-map-2026/). For cost tracking in multi-agent sessions, read about [productivity optimization](/best-claude-code-productivity-hacks-2026/). For task decomposition strategies, see [The Claude Code Playbook](/playbook/).

- [Claude Code hooks](/claude-code-hooks-complete-guide/) — hook into agent tool execution
- [Claude Agent SDK](/claude-agent-sdk-complete-guide/) — build custom agent architectures
- [Super Claude Code framework](/super-claude-code-framework-guide/) — structured prompting for multi-agent setups
- [Claude Code spec workflow](/claude-code-spec-workflow-guide/) — spec-driven agent tasks

## See Also

- [Multi-Agent Claude Fleet Cost Architecture Guide](/claude-cost-multi-agent-claude-fleet-cost-architecture/)
