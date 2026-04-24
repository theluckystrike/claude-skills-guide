---
title: "Use Claude Task Master With Your (2026)"
description: "Add Claude Task Master to an existing project in 5 steps. Parse your PRD, generate tasks, and let Claude execute them through MCP integration."
permalink: /how-to-use-claude-task-master-existing-project-2026/
last_tested: "2026-04-22"
---

# How to Use Claude Task Master With an Existing Project (2026)

Claude Task Master parses product requirement documents into structured task lists with dependency tracking. Here is how to add it to a project you are already working on.

## Prerequisites

- Node.js 18+ installed (`node --version`)
- An existing project with a PRD, spec, or requirements document
- Claude Code installed for MCP integration (optional but recommended)

## Step 1: Install Task Master Globally

```bash
npm install -g task-master-ai
```

Verify the installation:

```bash
task-master --version
```

## Step 2: Initialize in Your Project

Navigate to your project root and initialize Task Master:

```bash
cd /path/to/your/project
task-master init
```

This creates a `.task-master/` directory with:
- `config.json` — settings for task generation
- `tasks/` — directory where generated tasks live
- `.task-master.json` — project-level configuration

## Step 3: Parse Your Requirements Document

If you have a PRD or requirements file, feed it to Task Master:

```bash
task-master parse docs/requirements.md
```

Task Master analyzes the document and generates structured tasks. Each task includes:
- Unique ID
- Description
- Acceptance criteria
- Dependencies (which tasks must complete first)
- Suggested priority

Review the generated tasks:

```bash
task-master list
```

If you do not have a formal PRD, you can create tasks manually:

```bash
task-master add "Set up authentication with JWT" --priority high
task-master add "Create user registration endpoint" --depends-on 1
task-master add "Add login endpoint" --depends-on 1
```

## Step 4: Connect to Claude Code via MCP

Add Task Master as an MCP server in your Claude Code configuration. Edit `.claude/settings.json`:

```json
{
  "mcpServers": {
    "task-master": {
      "command": "task-master",
      "args": ["mcp-server"],
      "cwd": "/path/to/your/project"
    }
  }
}
```

Now Claude Code can read the task graph, pick the next unblocked task, and update task status — all through the MCP protocol.

## Step 5: Execute Tasks With Claude

Start a Claude Code session and tell Claude to work from the task list:

```
Look at the task list and start working on the next unblocked task
```

Claude reads the task graph through MCP, identifies tasks with no pending dependencies, and begins implementation. As tasks complete, Claude updates their status and moves to the next unblocked item.

## Verification

Confirm everything is working:

```bash
# Check task count
task-master list --status all

# Check for dependency issues
task-master validate

# See next available tasks
task-master next
```

## Working With the Task Graph

Once tasks are generated, the dependency graph becomes your project roadmap. Key commands for navigating it:

```bash
# See what is ready to work on now
task-master next

# See the next 5 available tasks
task-master next --count 5

# Mark a task as in progress
task-master start 7

# Mark a task as complete
task-master complete 7

# See the full dependency tree
task-master tree
```

When Claude is connected through MCP, you can also manage tasks conversationally:

```
Show me the dependency tree for the authentication feature
What tasks are currently blocked?
Mark task 12 as complete and show me what it unblocks
```

## Best Practices for Existing Projects

Adding Task Master to a project that is already underway requires some adjustment:

**Audit existing work first**: Before generating tasks from a PRD, identify what is already done. After generation, immediately mark completed tasks to avoid Claude re-doing existing work.

**Start with a feature, not the whole project**: If your project is large, parse just one feature's requirements rather than the entire PRD. This keeps the task list manageable and focused.

**Sync with your existing tracker**: If you use GitHub Issues or another tracker, Task Master's tasks are not automatically synced. Either use Task Master as the source of truth for Claude sessions or manually keep both in sync.

**Review generated tasks critically**: The AI decomposition is a starting point. Adjust priority, reword vague descriptions, and fix dependency chains before letting Claude execute against the list.

## Troubleshooting

**"No tasks found" after parsing**: Your requirements document may be too vague for the AI to extract structured tasks. Try adding more specific, actionable requirements with clear acceptance criteria.

**MCP connection fails**: Verify the `cwd` path in your MCP configuration points to the directory containing `.task-master/`. Restart Claude Code after changing MCP settings. Check that `task-master mcp-server` runs without errors in a standalone terminal.

**Dependencies create a cycle**: Task Master validates dependencies on creation, but manual edits can introduce cycles. Run `task-master validate` to detect and fix them. Remove the dependency causing the cycle and add it as a note instead.

**Tasks too granular or too broad**: Adjust the decomposition depth in `.task-master/config.json`. The `decomposition_depth` setting controls how finely tasks are split. A value of 2-3 works for most projects.

**Claude ignores the task order**: If Claude is not following the dependency graph, check that the MCP server is running. Ask Claude directly: "What is the next unblocked task according to the task graph?"

## Next Steps

- Learn to [convert a PRD to tasks](/how-to-convert-prd-to-tasks-claude-2026/) with detailed examples
- Compare Task Master with [GitHub Issues](/claude-task-master-vs-github-issues-project-2026/) for team workflows
- Add [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) that trigger on task completion
- Explore the [Claude Code playbook](/playbook/) for workflow patterns
