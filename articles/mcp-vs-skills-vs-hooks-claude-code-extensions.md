---
layout: default
title: "MCP vs Skills vs Hooks: Claude Code Extension Guide (2026)"
description: "Compare MCP servers, skills, and hooks in Claude Code. Learn when to use each extension type, how they differ, and how to combine them for powerful workflows."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /mcp-vs-skills-vs-hooks-claude-code-extensions/
reviewed: true
categories: [guides]
tags: [claude, claude-code, mcp, skills, hooks, extensions, architecture]
---

# MCP vs Skills vs Hooks: Claude Code Extension Guide (2026)

Claude Code supports three distinct extension mechanisms — MCP servers, skills, and hooks — each solving a different problem. MCP servers connect external data and APIs. Skills define reusable behavior templates. Hooks trigger actions on specific events. Choosing the wrong one wastes time; choosing the right one multiplies your productivity. This guide breaks down each type, compares them directly, and shows how to combine all three. Use the [MCP Config Generator](/mcp-config/) for MCP setup and the [Skill Finder](/skill-finder/) to discover available skills.

## MCP Servers: External Data and Actions

MCP (Model Context Protocol) servers give Claude Code access to systems outside your local codebase. Each server exposes **tools** (actions) and **resources** (data) through a standardized protocol.

**What MCP handles:**
- Querying databases (PostgreSQL, Supabase)
- Managing repositories (GitHub issues, PRs)
- Reading external services (Slack messages, Sentry errors)
- Accessing remote file systems

**Configuration:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx" }
    }
  }
}
```

**Key characteristic:** MCP servers are stateless processes that run alongside Claude Code. They handle the communication protocol automatically — you just configure and connect.

## Skills: Behavior Templates

Skills are reusable instruction sets that modify how Claude Code approaches specific tasks. They are stored as markdown files and loaded when relevant.

**What skills handle:**
- Code review checklists
- Commit message formatting
- Project-specific conventions
- Language-specific best practices

**Configuration:**

```markdown
<!-- .claude/skills/code-review.md -->
# Code Review Skill

When reviewing code:
1. Check for security vulnerabilities first
2. Verify error handling covers edge cases
3. Ensure test coverage for new functions
4. Flag any hardcoded credentials or secrets
```

Skills are loaded from `.claude/skills/` in your project directory or from the global `~/.claude/skills/` directory.

**Key characteristic:** Skills change Claude's behavior, not its capabilities. They are instructions, not integrations.

## Hooks: Event-Driven Automation

Hooks execute commands automatically when specific events occur during a Claude Code session. They run shell commands, scripts, or programs in response to triggers.

**What hooks handle:**
- Running linters after file edits
- Sending notifications on task completion
- Auto-formatting code before commits
- Logging session activity

**Configuration:**

```json
{
  "hooks": {
    "afterEdit": [
      {
        "command": "eslint --fix ${file}",
        "description": "Auto-fix lint errors after Claude edits a file"
      }
    ],
    "afterCommit": [
      {
        "command": "curl -X POST https://slack.webhook/notify -d '{\"text\": \"Commit created\"}'",
        "description": "Notify Slack after a commit"
      }
    ]
  }
}
```

**Key characteristic:** Hooks are reactive. They fire automatically — Claude does not decide whether to use them.

## Comparison Table

| Feature | MCP Servers | Skills | Hooks |
|---------|------------|--------|-------|
| **Purpose** | Connect external data/APIs | Define behavior patterns | Automate on events |
| **Trigger** | Claude decides to use | Always active when loaded | Event-driven (automatic) |
| **Config format** | JSON (mcp-servers.json) | Markdown (.md files) | JSON (settings.json) |
| **Scope** | Global or project | Global or project | Global or project |
| **Runs code** | Yes (server process) | No (instructions only) | Yes (shell commands) |
| **Requires auth** | Often (API tokens) | Never | Rarely |
| **Example** | Query GitHub issues | "Always use TypeScript strict mode" | Run tests after edit |

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│                Claude Code CLI               │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Skills   │  │   MCP    │  │  Hooks   │  │
│  │(behavior) │  │ (data)   │  │ (events) │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │              │              │        │
│  Modifies how   Adds what      Runs when    │
│  Claude thinks  Claude accesses something   │
│                                  happens    │
└─────────────────────────────────────────────┘
```

## Combining All Three

The real power comes from using all three together. Here is a practical example — a full-stack development workflow:

**Skill** (defines the approach):
```markdown
<!-- .claude/skills/fullstack-workflow.md -->
When building features:
1. Check Linear for the ticket requirements first
2. Write tests before implementation
3. Run the test suite before committing
4. Update the PR description with what changed
```

**MCP Servers** (provide the data):
```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-linear"],
      "env": { "LINEAR_API_KEY": "lin_xxx" }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx" }
    }
  }
}
```

**Hooks** (automate the guardrails):
```json
{
  "hooks": {
    "afterEdit": [
      { "command": "prettier --write ${file}" }
    ],
    "beforeCommit": [
      { "command": "npm test" }
    ]
  }
}
```

With this setup, Claude reads the Linear ticket (MCP), follows your team's workflow (Skill), formats code automatically (Hook), and runs tests before committing (Hook).

## Decision Framework

**Use MCP when** you need Claude to read or write data from an external service.

**Use Skills when** you want Claude to follow specific patterns, conventions, or workflows.

**Use Hooks when** you want automated actions triggered by Claude's behavior, regardless of what Claude is doing.

## Try It Yourself

Set up your MCP servers with the [MCP Config Generator](/mcp-config/) and discover available skills with the [Skill Finder](/skill-finder/). Both tools produce configurations you can copy directly into your project.

<details>
<summary>Can skills call MCP servers?</summary>
Skills cannot directly call MCP servers. However, a skill can instruct Claude to use a specific MCP server for certain tasks. For example, a skill might say "Always check the GitHub MCP server for open issues before starting work."
</details>

<details>
<summary>Do hooks run if Claude Code crashes?</summary>
No. Hooks are managed by the Claude Code process. If Claude Code crashes or is force-killed, pending hooks will not execute. Design critical automation (like notifications) with external monitoring as a backup.
</details>

<details>
<summary>Can I disable a skill temporarily?</summary>
Yes. Move the skill file out of the `.claude/skills/` directory, or rename it with a different extension (e.g., `.md.disabled`). Claude Code only loads `.md` files from the skills directory.
</details>

<details>
<summary>How many hooks can I have per event?</summary>
There is no hard limit. Hooks for the same event run sequentially in the order they are defined. Keep hooks fast — slow hooks delay Claude Code's response after each triggering event.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can skills call MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Skills cannot directly call MCP servers. However, a skill can instruct Claude to use a specific MCP server for certain tasks. For example, a skill might say 'Always check the GitHub MCP server for open issues before starting work.'"
      }
    },
    {
      "@type": "Question",
      "name": "Do hooks run if Claude Code crashes?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Hooks are managed by the Claude Code process. If Claude Code crashes or is force-killed, pending hooks will not execute. Design critical automation with external monitoring as a backup."
      }
    },
    {
      "@type": "Question",
      "name": "Can I disable a skill temporarily?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Move the skill file out of the .claude/skills/ directory, or rename it with a different extension (e.g., .md.disabled). Claude Code only loads .md files from the skills directory."
      }
    },
    {
      "@type": "Question",
      "name": "How many hooks can I have per event?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There is no hard limit. Hooks for the same event run sequentially in the order they are defined. Keep hooks fast — slow hooks delay Claude Code's response after each triggering event."
      }
    }
  ]
}
</script>

## Related Guides

- [MCP Config Generator](/mcp-config/) — Generate server configurations instantly
- [Skill Finder](/skill-finder/) — Browse and discover Claude Code skills
- [Command Reference](/commands/) — All slash commands explained
- [Claude Code Configuration Guide](/configuration/) — Full settings reference
- [Advanced Usage Patterns](/advanced-usage/) — Power-user techniques and automation
