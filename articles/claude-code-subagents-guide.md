---
layout: default
title: "Claude Code Subagents Guide (2026)"
description: "Create custom subagents in Claude Code to delegate tasks, preserve context, control costs, and enforce tool restrictions."
date: 2026-04-15
permalink: /claude-code-subagents-guide/
categories: [guides, claude-code]
tags: [subagents, delegation, context, agents, workflow]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Claude Code Subagents Guide

## The Problem

Your Claude Code sessions become bloated with search results, file contents, and exploration output that you do not reference again. Context fills up quickly, compaction runs frequently, and you pay for irrelevant tokens on every subsequent message.

## Quick Fix

Claude Code has built-in subagents that handle common tasks in their own context window (see the [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/) for building custom agents). Create a file at `.claude/skills/code-reviewer.md`:

```markdown
---
description: Reviews code for readability, performance, and best practices
tools:
 - Read
 - Grep
 - Glob
model: sonnet
---
Review the specified files and provide improvement suggestions.
Focus on readability, performance, and adherence to project conventions.
```

Then ask Claude: "Use the code-reviewer agent to review src/api/handlers/"

## What's Happening

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. When Claude encounters a task matching a subagent's description, it delegates to that subagent. The subagent works independently and returns only the results. All the intermediate file reads and searches stay out of your main context.

Each subagent can use a different model. Route cheap exploratory work to Haiku, code review to Sonnet, and keep Opus for your main conversation's complex reasoning.

## Step-by-Step Fix

### Step 1: Understand built-in subagents

Claude Code includes three built-in subagents:

**Explore** runs on Haiku with read-only tools. Claude delegates to it for file discovery, code search, and codebase exploration. It uses three thoroughness levels: quick for targeted lookups, medium for balanced exploration, and very thorough for comprehensive analysis.

**Plan** inherits the main model with read-only tools. Used during plan mode to gather context before presenting a plan.

**General-purpose** inherits the main model with all tools. Used for complex multi-step tasks requiring both exploration and modification.

### Step 2: Create a custom subagent with /agents

The quickest way to create a subagent:

```text
/agents
```

Switch to the Library tab, select Create new agent, then choose Personal (saved to `~/.claude/agents/`) or Project (saved to `.claude/agents/`).

Select "Generate with Claude" and describe what you want:

```text
A security audit agent that scans files for common vulnerabilities
like hardcoded secrets, SQL injection, and XSS patterns.
```

### Step 3: Write a subagent file manually

Create a Markdown file with YAML frontmatter:

```markdown
---
description: Scans code for security vulnerabilities and hardcoded secrets
tools:
 - Read
 - Grep
 - Glob
 - Bash
model: sonnet
---
# Security Auditor

Scan the specified files or directories for:
- Hardcoded API keys, passwords, or tokens
- SQL injection vulnerabilities
- XSS patterns in output
- Insecure file permissions

Report findings with file path, line number, severity, and recommended fix.
```

Save to `.claude/agents/security-auditor.md` for project scope, or `~/.claude/agents/security-auditor.md` for all projects.

### Step 4: Configure tool restrictions

Limit what tools a subagent can use for safety:

```markdown
---
description: Read-only code analyzer
tools:
 - Read
 - Grep
 - Glob
allowedTools:
 - "Bash(npm run lint *)"
 - "Bash(npm run test *)"
disallowedTools:
 - "Edit"
 - "Write"
 - "Bash(rm *)"
---
```

### Step 5: Choose the right model

Set the model based on the task complexity:

```markdown
---
model: haiku
---
```

| Model | Best for | Cost |
|-------|----------|------|
| haiku | Fast exploration, simple analysis | Lowest |
| sonnet | Code review, implementation, testing | Medium |
| opus | Complex architecture, multi-step reasoning | Highest |

### Step 6: Enable persistent memory

Subagents can maintain their own auto memory across sessions:

```markdown
---
description: Code reviewer with persistent memory
model: sonnet
autoMemoryScope: user
---
```

Set `autoMemoryScope` to `user` for memory shared across projects, or `project` for project-specific memory.

### Step 7: Use the subagent

Ask Claude to delegate:

```text
Use the security-auditor agent to scan src/api/ for vulnerabilities
```

Claude reads the subagent's description and delegates. The subagent works in its own context window and returns a summary.

## Prevention

Design subagents for your most common delegation patterns:

- **Explorer**: read-only, Haiku model, for codebase understanding
- **Reviewer**: read-only, Sonnet model, for code quality analysis
- **Implementer**: full tools, Sonnet model, for isolated changes
- **Tester**: limited Bash access, Sonnet model, for running and analyzing tests

Commit project-level subagents (`.claude/agents/`) to version control so your entire team benefits.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-subagents-guide)**

</div>

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-subagents-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude Code Context Window Full in Large Codebase Fix](/claude-code-context-window-full-in-large-codebase-fix/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
- [Agent Handoff Strategies for Long Running Tasks](/agent-handoff-strategies-for-long-running-tasks-guide/)



- [Claude Flow tool guide](/claude-flow-tool-guide/) — How to use Claude Flow for multi-agent orchestration
- [Claude Code hooks](/claude-code-hooks-complete-guide/) — hook into subagent tool execution
- [Claude Agent SDK](/claude-agent-sdk-complete-guide/) — build custom subagent architectures with the SDK
- [Claude Code spec workflow](/claude-code-spec-workflow-guide/) — spec-driven subagent tasks

## Related Articles

- [Passing Context Between Claude Code Subagents Guide](/passing-context-between-claude-code-subagents-guide/)


