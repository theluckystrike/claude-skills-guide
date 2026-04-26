---
layout: default
title: "Every Claude Code Slash Command Explained (2026)"
description: "Complete reference for all Claude Code slash commands — /init, /compact, /clear, /doctor, /review, /cost, /memory, /model, /config, and more with examples."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /every-claude-code-slash-command-explained/
reviewed: true
categories: [reference]
tags: [claude, claude-code, slash-commands, commands, reference, cli]
---

# Every Claude Code Slash Command Explained (2026)

Claude Code includes a set of slash commands that control session behavior, configuration, and debugging — all accessible by typing `/` in the prompt. Knowing which command to reach for at the right moment saves tokens, prevents context loss, and unlocks features most users never discover. This guide documents every available slash command with its purpose, syntax, and practical examples. For the full interactive reference, see the [Command Reference tool](/commands/).

## Session Management Commands

### /init

Initializes a new Claude Code project in the current directory. Creates a `CLAUDE.md` file with project context that Claude reads at the start of every session.

```
/init

# Creates CLAUDE.md with:
# - Project description
# - Key files and directories
# - Build and test commands
# - Coding conventions
```

**When to use:** The first time you open Claude Code in a new repository. Run it once, then edit the generated `CLAUDE.md` to refine project context.

### /clear

Resets the entire conversation. All context, instructions, and history are erased. Claude starts fresh as if you just opened a new session.

```
/clear

# Conversation reset. Token count returns to baseline.
```

**When to use:** When the conversation has gone off track and you want a clean start. Also useful when switching to a completely different task in the same project.

### /compact

Compresses the current conversation context. Claude summarizes the conversation so far into a shorter representation, preserving key decisions and facts while reducing token count.

```
/compact

# Context compressed. Conversation continues with summarized history.
```

**When to use:** When you are running low on context window but want to continue the current task. Prefer `/compact` over `/clear` when you need continuity.

## Configuration Commands

### /config

Opens the Claude Code configuration for viewing or editing. Shows current settings and allows modifications.

```
/config

# Displays current configuration including:
# - Model selection
# - Permission settings
# - MCP server status
# - Custom preferences
```

### /model

Switches the active model during a session. Useful for toggling between models for different tasks.

```
/model

# Shows available models and lets you switch
# Common options: claude-sonnet-4-20250514, claude-opus-4-20250414
```

**When to use:** When you want a faster model for simple tasks or a more capable model for complex reasoning.

### /permissions

Reviews and manages tool permissions. Controls what actions Claude Code can take without asking for confirmation.

```
/permissions

# Shows current permission levels:
# - File read/write
# - Command execution
# - Network access
```

### /memory

Manages persistent memory across sessions. Memory items are stored and loaded automatically in future sessions.

```
/memory

# Add persistent preferences:
# "Always use TypeScript strict mode"
# "Prefer functional components over class components"
```

**When to use:** When you want Claude to remember project-specific conventions or personal preferences across sessions.

## Diagnostic Commands

### /doctor

Runs diagnostic checks on your Claude Code installation. Identifies configuration issues, missing dependencies, and connection problems.

```
/doctor

# Checks:
# ✓ Authentication status
# ✓ Model availability
# ✓ MCP server connections
# ✓ Configuration file validity
# ✓ Node.js version compatibility
```

**When to use:** When something is not working as expected. Run `/doctor` before filing a bug report.

### /cost

Shows token usage and cost information for the current session.

```
/cost

# Output:
# Session tokens: 45,230 input / 12,450 output
# Estimated cost: $0.42
# Cache hits: 78%
```

**When to use:** Monitor spending during long sessions or when evaluating whether to use `/compact` to reduce costs.

### /status

Displays the current session state — model, connected MCP servers, active permissions, and loaded context.

```
/status

# Shows: model, MCP connections, permissions, context size
```

### /bug

Reports a bug to the Claude Code team. Collects diagnostic information and opens a report.

```
/bug

# Collects session info, config, and error logs
# Opens a bug report with pre-filled details
```

## Workflow Commands

### /review

Enters code review mode. Claude analyzes recent changes and provides structured feedback on code quality, security, and best practices.

```
/review

# Claude reviews staged changes and provides:
# - Security concerns
# - Performance issues
# - Style inconsistencies
# - Test coverage gaps
```

**When to use:** Before committing changes. Catches issues that linters miss, like logic errors and missing edge cases.

### /help

Shows all available commands and their descriptions.

```
/help

# Lists all slash commands with brief descriptions
```

### /login

Authenticates or re-authenticates your Claude Code session.

```
/login

# Opens browser for authentication
# Or accepts API key directly
```

### /mcp

Lists connected MCP servers and their status. Shows available tools and resources from each server.

```
/mcp

# Output:
# github: connected (12 tools, 3 resources)
# supabase: connected (8 tools, 1 resource)
# filesystem: disconnected
```

### /vim

Toggles vim-style keybindings for the input prompt.

```
/vim

# Enables vim mode: normal/insert mode, hjkl navigation
```

### /fast

Toggles fast output mode. Uses the same Claude Opus 4.6 model but with faster output generation.

```
/fast

# Fast mode: ON (same model, faster output)
```

## Try It Yourself

Explore all commands interactively with the [Command Reference](/commands/). It provides searchable documentation, usage examples, and contextual tips for every slash command.

<details>
<summary>What is the difference between /compact and /clear?</summary>
/compact compresses the current conversation into a summary and continues the session. /clear erases everything and starts fresh. Use /compact when you want to continue working on the same task but need to free up context space. Use /clear when switching to a completely different task.
</details>

<details>
<summary>Do slash commands count toward token usage?</summary>
The slash commands themselves use minimal tokens. However, commands like /review and /compact trigger Claude to process the conversation, which does consume tokens. Commands like /cost and /help are lightweight and use negligible tokens.
</details>

<details>
<summary>Can I create custom slash commands?</summary>
Claude Code does not support user-defined slash commands. However, you can achieve similar functionality through skills (markdown instruction files) that Claude loads automatically. Skills let you define reusable workflows triggered by natural language.
</details>

<details>
<summary>How do I see which slash commands are available?</summary>
Type / in the Claude Code prompt to see an autocomplete list of available commands. You can also run /help for a complete list with descriptions.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the difference between /compact and /clear?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "/compact compresses the current conversation into a summary and continues the session. /clear erases everything and starts fresh. Use /compact when you want to continue working on the same task but need to free up context space. Use /clear when switching to a completely different task."
      }
    },
    {
      "@type": "Question",
      "name": "Do slash commands count toward token usage?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The slash commands themselves use minimal tokens. However, commands like /review and /compact trigger Claude to process the conversation, which does consume tokens. Commands like /cost and /help are lightweight and use negligible tokens."
      }
    },
    {
      "@type": "Question",
      "name": "Can I create custom slash commands?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code does not support user-defined slash commands. However, you can achieve similar functionality through skills (markdown instruction files) that Claude loads automatically. Skills let you define reusable workflows triggered by natural language."
      }
    },
    {
      "@type": "Question",
      "name": "How do I see which slash commands are available?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Type / in the Claude Code prompt to see an autocomplete list of available commands. You can also run /help for a complete list with descriptions."
      }
    }
  ]
}
</script>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Command Reference](/commands/) — Interactive command explorer
- [Getting Started with Claude Code](/getting-started/) — First-time setup and basics
- [Claude Code Configuration Guide](/configuration/) — Full settings reference
- [Permissions and Security](/permissions/) — Control tool access
- [Best Practices for Claude Code](/best-practices/) — Workflow optimization tips
