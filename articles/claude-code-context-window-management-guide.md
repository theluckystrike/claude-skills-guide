---
layout: default
title: "Claude Code Context Window Management (2026)"
description: "Master context window management in Claude Code with compaction, /clear, subagents, and CLAUDE.md optimization to reduce token costs."
date: 2026-04-15
permalink: /claude-code-context-window-management-guide/
categories: [guides, claude-code]
tags: [context-window, tokens, compaction, costs, optimization]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Claude Code Context Window Management Guide

## The Problem

Your Claude Code sessions become slow, expensive, or produce lower-quality responses as the conversation grows. You see compaction happening frequently, or `/cost` shows unexpectedly high token usage for simple tasks.

## Quick Fix

Use `/clear` between unrelated tasks and delegate exploratory work to subagents:

```text
/clear
```

Check your current context usage at any time:

```text
/context
```

## What's Happening

Claude Code's context window holds everything Claude knows about your session: your CLAUDE.md instructions, auto memory, MCP tool names, skill descriptions, every file read, every response, and metadata that never appears in your terminal. When this window fills up, Claude Code automatically runs compaction, which summarizes the conversation history to make room.

The problem is that context size directly drives token costs. Every message you send includes the full conversation context, so a bloated context window means you pay for irrelevant information on every single API call. Compaction helps, but it is lossy and may discard details you need later.

## Step-by-Step Fix

### Step 1: Understand what loads at startup

Before you type anything, Claude Code loads several items into context:

- Project-root CLAUDE.md and any user-level CLAUDE.md
- Auto memory (first 200 lines or 25KB)
- MCP tool names (deferred by default, so only names load until a tool is used)
- Skill descriptions from configured skills

Run `/memory` to see which CLAUDE.md and auto memory files loaded. Run `/context` for a live breakdown by category.

### Step 2: Keep CLAUDE.md files concise

Target under 200 lines per CLAUDE.md file. Every line consumes tokens on every message. Move detailed procedures into skills instead of cramming everything into CLAUDE.md:

```markdown
# CLAUDE.md - keep it lean
- Use 2-space indentation for TypeScript
- Run `pnpm test` before committing
- API handlers live in src/api/handlers/
```

Detailed workflows belong in `.claude/skills/` where Claude loads them on demand rather than on every session.

### Step 3: Clear between tasks

When you finish a task and start something unrelated, clear the context:

```text
/rename feature-auth-implementation
/clear
```

Renaming first lets you resume the session later with `/resume`. Stale context from a previous task wastes tokens on every subsequent message.

### Step 4: Use custom compaction instructions

When compaction runs, tell Claude what to preserve:

```text
/compact Focus on code samples, test results, and API changes
```

You can also configure this in your CLAUDE.md:

```markdown
# Compact instructions
When you are using compact, please focus on test output and code changes
```

### Step 5: Delegate exploration to subagents

When Claude needs to search through many files, the search results fill your main context. Use subagents to keep exploration out of your main window:

Claude has a built-in Explore subagent that runs on Haiku (fast, cheap) with read-only access. When you ask Claude to understand a codebase, it delegates to Explore, which works in its own context window and returns only a summary.

For custom delegation, create a subagent:

```markdown
---
description: Research agent for codebase exploration
tools:
 - Read
 - Grep
 - Glob
model: haiku
---
Search the codebase and return a concise summary of findings.
```

### Step 6: Understand what survives compaction

After compaction, some instructions reload automatically and some are lost:

| Content | After compaction |
|---------|-----------------|
| System prompt, output style | Unchanged |
| Project-root CLAUDE.md | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until a matching file is read again |
| Nested subdirectory CLAUDE.md | Lost until a file in that directory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens per skill |

If a rule must persist across compaction, remove the `paths:` frontmatter or move it to the project-root CLAUDE.md.

### Step 7: Reduce MCP overhead

MCP tool definitions are deferred by default, so only tool names enter context. But if you have many servers configured, even the names add up. Disable unused servers:

```text
/mcp
```

Review active servers and disable any you are not using. Prefer CLI tools like `gh`, `aws`, and `gcloud` over MCP servers when both options exist, as CLI tools add zero per-tool context overhead.

### Step 8: Choose the right model

Sonnet handles most coding tasks well and costs less than Opus. Reserve Opus for complex architectural decisions. Switch mid-session:

```text
/model sonnet
```

For subagent tasks, configure them to use Haiku for maximum cost efficiency.

## Prevention

Build context hygiene into your workflow:

1. Start each distinct task with `/clear`
2. Keep CLAUDE.md under 200 lines; use skills for detailed procedures
3. Run `/context` periodically to spot bloat
4. Use subagents for any task involving many file reads
5. Configure your status line to show context usage continuously with `/statusline`

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-code-context-window-management-guide)**

$99 once. Pays for itself in saved tokens within a week.

</div>

---



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Context Window Full in Large Codebase Fix](/claude-code-context-window-full-in-large-codebase-fix/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
- [Claude Code for Context Window Optimization Workflow](/claude-code-for-context-window-optimization-workflow-guide/)



## Related Articles

- [Claude Code Snippet Library Management](/claude-code-snippet-library-management/)
- [Claude Code Git Tags Release Management — Developer Guide](/claude-code-git-tags-release-management/)
- [Claude Code Git Submodules Management Guide](/claude-code-git-submodules-management-guide/)
- [Claude Code Focus Management Audit Accessibility Guide](/claude-code-focus-management-audit-accessibility-guide/)
- [Claude Code Lost Context Mid — Complete Developer Guide](/claude-code-lost-context-mid-task-how-to-recover/)
- [Why Does Claude Keep Timing Out? Context Window Fix (2026)](/why-does-claude-code-need-so-much-context-window/)
