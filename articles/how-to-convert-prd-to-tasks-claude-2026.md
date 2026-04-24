---
title: "Convert a PRD to Tasks with Task Master"
description: "Turn a product requirements document into structured tasks using Claude Task Master. Step-by-step with PRD formatting, parsing, and dependency wiring."
permalink: /how-to-convert-prd-to-tasks-claude-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Convert a PRD to Tasks with Claude Task Master (2026)

Claude Task Master's best feature is parsing a PRD (Product Requirements Document) into structured, dependency-aware tasks. Here is how to format your PRD for optimal parsing and use the generated tasks with Claude Code.

## Prerequisites

- Task Master installed (`npm install -g task-master-ai`)
- A PRD or requirements document (markdown format works best)
- Claude Code installed (for MCP integration)

## Step 1: Format Your PRD

Task Master works best with clearly structured PRDs. Format yours like this:

```markdown
# Product: User Dashboard

## Overview
A real-time dashboard showing user activity metrics, notifications, and account settings.

## Features

### F1: Activity Feed
- Display last 50 user actions in reverse chronological order
- Each action shows: timestamp, action type, description
- Real-time updates via WebSocket
- Pagination for historical data

### F2: Notification Center
- Display unread notifications with badge count
- Mark individual or all notifications as read
- Notification types: system, mention, update
- Push notification opt-in

### F3: Account Settings
- Edit profile (name, email, avatar)
- Change password with current password verification
- Two-factor authentication toggle
- Email notification preferences

## Technical Requirements
- Frontend: React with TypeScript
- State management: Zustand
- API: REST endpoints on existing Express backend
- Database: PostgreSQL (existing schema)
- Authentication: JWT (existing)
```

Key formatting rules:
- Use markdown headers for hierarchy
- Use bullet points for individual requirements
- Be specific — vague requirements produce vague tasks
- Include technical constraints so tasks are implementable

## Step 2: Initialize Task Master

```bash
cd /path/to/your/project
task-master init
```

## Step 3: Parse the PRD

```bash
task-master parse docs/prd.md
```

Task Master sends the PRD to an AI model, which generates structured tasks. Typical output for the PRD above: 25-40 tasks covering:
- Database schema changes
- API endpoint creation
- Frontend component development
- Integration and wiring
- Testing for each feature

## Step 4: Review and Adjust Tasks

List the generated tasks:

```bash
task-master list
```

Review the output. Common adjustments needed:

**Tasks too granular**: Merge related tasks. If "Create ActivityFeed component" and "Add ActivityFeed styles" are separate, consider combining them.

**Tasks too broad**: Break down tasks that would take more than a day. "Implement notification center" should be split into backend, frontend, and integration tasks.

**Missing tasks**: Add forgotten items manually:
```bash
task-master add "Add WebSocket reconnection logic" --depends-on 5
```

**Wrong dependencies**: Fix dependency chains:
```bash
task-master update 12 --depends-on 3,7
```

## Step 5: Connect to Claude Code

Configure Task Master as an MCP server:

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

Start Claude Code and begin executing:

```bash
claude
```

```
Read the task list and start working on the highest priority unblocked task
```

Claude reads the task graph, identifies unblocked tasks, and begins implementation. As it completes tasks, it updates their status and moves to the next one.

## Verification

```bash
# Verify task count
task-master list --status all

# Check for dependency issues
task-master validate

# See execution order
task-master next --count 5
```

## PRD Quality Checklist

The quality of generated tasks depends directly on the quality of your PRD. Before parsing, verify your PRD includes:

- [ ] Clear feature descriptions (not just names)
- [ ] Acceptance criteria for each feature
- [ ] Technical constraints (language, framework, database)
- [ ] User roles and permissions
- [ ] API specifications (endpoints, payloads, responses)
- [ ] UI/UX requirements (if applicable)
- [ ] Performance requirements (response times, throughput)
- [ ] Non-functional requirements (security, accessibility)

A PRD that covers these areas produces 30-50 high-quality tasks. A PRD that only lists feature names produces vague, unhelpful tasks.

## Iterating on Generated Tasks

Task generation is not a one-shot process. Plan for 2-3 iterations:

**First pass**: Generate raw tasks from the PRD. Review for completeness and accuracy.

**Second pass**: Split broad tasks (anything estimated at more than one day), merge overly granular tasks (anything estimated at less than 30 minutes), and fix dependency ordering.

**Third pass**: Add tasks the AI missed — deployment steps, documentation, testing infrastructure, and CI/CD configuration often get overlooked.

After the third pass, your task list should be clean enough for Claude to execute autonomously through the MCP integration.

## Ongoing PRD Updates

Projects evolve. When requirements change:

1. Update your PRD document
2. Re-run `task-master parse` on the updated PRD
3. Compare new tasks with existing ones
4. Manually reconcile: mark already-completed tasks, add new tasks, update changed ones

Task Master does not automatically diff new and existing tasks. The reconciliation is manual but straightforward.

## Troubleshooting

**Poor task generation**: Your PRD may be too vague. Add specific implementation details, technical constraints, and acceptance criteria. Compare your PRD against the quality checklist above.

**Circular dependencies**: Run `task-master validate` to detect cycles. Remove or reorder dependencies to break the cycle. Common cause: two tasks that each claim to depend on the other.

**Claude picks the wrong task**: The MCP integration respects dependency ordering. If Claude picks an unexpected task, check that dependencies are correctly defined. Also verify that completed tasks are marked as such — Claude may pick an already-done task if it was not updated.

**Too many tasks**: Set a task limit in config to prevent the AI from over-decomposing simple features. Alternatively, generate tasks for one feature at a time rather than the entire PRD.

**Tasks do not match your architecture**: The AI generates tasks based on common patterns. If your architecture is unusual, review and adjust tasks to match your actual codebase structure.

## Next Steps

- Compare Task Master with [GitHub Issues](/claude-task-master-vs-github-issues-project-2026/) for team workflows
- Compare with [Linear and Jira](/claude-task-master-vs-linear-jira-2026/) for enterprise contexts
- Read the [Claude Code playbook](/playbook/) for execution patterns
- Explore [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for efficient task execution
