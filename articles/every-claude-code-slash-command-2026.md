---
layout: default
title: "Every Claude Code Slash Command (2026)"
description: "Complete list of every Claude Code slash command with syntax, examples, and use cases. Updated for 2026 with new commands."
permalink: /every-claude-code-slash-command-2026/
date: 2026-04-26
---

# Every Claude Code Slash Command (2026)

Claude Code ships with a growing list of slash commands that control everything from session state to cost tracking. Unlike natural language prompts, slash commands execute instantly and deterministically. They do not consume thinking tokens. They do not require interpretation. They just work.

This reference covers every slash command available in Claude Code as of April 2026, organized by function. Whether you are managing context windows, debugging configuration issues, or switching models mid-session, there is a command for it. For an interactive version you can search and filter, visit the [Command Reference tool](/commands/).

## Session Lifecycle Commands

These commands control the lifecycle of your Claude Code session: starting fresh, compacting context, and resetting state.

### /init

Creates a `CLAUDE.md` file in your project root. This file tells Claude about your project structure, build commands, testing conventions, and coding standards. Running `/init` in an existing project regenerates the file based on current project state.

```
/init
```

Claude scans your repository and produces a context file tuned to what it finds. A Node.js project gets different defaults than a Rust project. The generated file is a starting point; edit it to match your actual conventions. See our [CLAUDE.md templates guide](/10-claude-md-templates-project-types/) for project-specific examples.

### /clear

Wipes the entire conversation history from the current session. Your `CLAUDE.md` context reloads, but everything you discussed is gone. Use this when the conversation has drifted far from your current task or when Claude starts referencing outdated code states.

```
/clear
```

This command is irreversible. If you need to preserve some context while reducing token usage, use `/compact` instead. For a detailed comparison, read [/compact vs /clear: When to Use Each](/claude-code-compact-vs-clear-when-to-use/).

### /compact

Summarizes the current conversation into a compressed context and continues from there. Unlike `/clear`, you do not lose the thread of the conversation. Claude rewrites the history into a shorter form while preserving key decisions, code changes, and task state.

```
/compact
# or with a custom focus:
/compact focus on the database migration
```

The optional focus parameter tells Claude what to prioritize during compression. Without it, Claude uses its own judgment about what matters most. This command is essential for long sessions that approach the [context window limit](/claude-code-context-window-management-2026/).

## Configuration Commands

### /config

Opens the Claude Code configuration interface. From here you can view and modify settings like model selection, permission modes, and custom instructions.

```
/config
```

Configuration changes persist across sessions. For a deep get startedto every configurable option, see the [configuration hierarchy guide](/claude-code-configuration-hierarchy-explained-2026/).

### /model

Switches the active model mid-session. Useful when you want to use a faster model for simple tasks and a more capable model for complex reasoning.

```
/model claude-sonnet-4
/model claude-opus-4
```

Model switching does not reset your conversation. The new model picks up the existing context. Token pricing changes immediately, which matters if you are [managing a token budget](/claude-code-cost-alerts-notifications-budget/).

### /permissions

Displays and modifies the current permission configuration. Controls which tools Claude can use, which directories it can access, and whether it can execute shell commands without asking.

```
/permissions
```

Permission management is critical for team environments. The wrong setting can either block legitimate workflows or expose sensitive files. Configure permissions properly with our [Permissions Configurator](/permissions/) or read the [permissions model guide](/claude-code-permissions-model-security-guide-2026/).

## Diagnostic Commands

### /doctor

Runs a diagnostic check on your Claude Code installation. Verifies API connectivity, configuration validity, tool availability, and environment compatibility.

```
/doctor
```

Run this first when something is not working. It catches misconfigured API keys, broken tool paths, and version mismatches before you spend time debugging.

### /cost

Displays token usage and estimated cost for the current session. Shows input tokens, output tokens, cache reads, and the dollar amount consumed.

```
/cost
```

If you are tracking costs across sessions, combine this with the [Token Estimator](/token-estimator/) to forecast spend before starting work. For systematic cost tracking, see our [audit token usage guide](/audit-claude-code-token-usage-step-by-step/).

### /review

Triggers a code review of your recent changes. Claude examines your uncommitted diffs and provides structured feedback on logic errors, security issues, style violations, and performance concerns.

```
/review
```

The review covers staged and unstaged changes. It works best when your `CLAUDE.md` includes coding standards, because Claude checks against those conventions. For a broader look at AI-assisted reviews, see [AI code review workflows](/ai-assisted-code-review-workflow-best-practices/).

### /memory

Manages persistent memory entries that carry across sessions. You can view, add, or remove memory items that Claude remembers every time it starts.

```
/memory
/memory add "Always use pnpm, never npm"
/memory remove 3
```

Memory entries supplement `CLAUDE.md` with personal or project-specific preferences. They are stored locally and never leave your machine.

## Workflow Commands

### /help

Displays the complete list of available slash commands with brief descriptions. This is your quick reference when you forget a command name.

```
/help
```

### /status

Shows the current state of your Claude Code session: active model, permission mode, loaded context files, and tool availability.

```
/status
```

## Try It Yourself

The fastest way to explore these commands is through our interactive [Command Reference](/commands/). It lets you search commands by name or function, see syntax examples, and discover related commands you might not know about.

The tool includes every command listed here plus contextual tips about when to use each one. Bookmark it as your quick-reference cheat sheet.

## Command Quick Reference Table

| Command | Purpose | Destructive? |
|---------|---------|-------------|
| `/init` | Create or regenerate CLAUDE.md | Overwrites existing file |
| `/clear` | Reset conversation entirely | Yes, irreversible |
| `/compact` | Compress conversation | No, preserves meaning |
| `/config` | Edit configuration | No |
| `/model` | Switch active model | No |
| `/permissions` | View/edit permissions | Settings persist |
| `/doctor` | Run diagnostics | No |
| `/cost` | Show token usage | No |
| `/review` | Review recent changes | No |
| `/memory` | Manage persistent memory | Can remove entries |
| `/help` | List all commands | No |
| `/status` | Show session state | No |

## Frequently Asked Questions

**Do slash commands consume tokens?**

No. Slash commands execute locally before any API call. They do not count against your input or output token budget.

**Can I create my own custom slash commands?**

Yes. Place markdown files in `.claude/commands/` in your project directory. The filename becomes the command name. See [best commands you are not using](/best-claude-code-commands-you-are-not-using-2026/) for examples.

**What happens if I run /compact on a short conversation?**

It still works, but the savings are minimal. Compact is most useful when your conversation exceeds a few thousand tokens. The [Token Estimator](/token-estimator/) can help you decide when compacting makes sense.

**Is /clear the same as starting a new session?**

Nearly. Both reset the conversation, but `/clear` keeps your terminal session active and reloads `CLAUDE.md`. Starting a new session also resets any in-memory state from hooks or tools.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do slash commands consume tokens?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Slash commands execute locally before any API call. They do not count against your input or output token budget."
      }
    },
    {
      "@type": "Question",
      "name": "Can I create my own custom slash commands?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Place markdown files in .claude/commands/ in your project directory. The filename becomes the command name."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if I run /compact on a short conversation?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "It still works but savings are minimal. Compact is most useful when your conversation exceeds a few thousand tokens."
      }
    },
    {
      "@type": "Question",
      "name": "Is /clear the same as starting a new session?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Nearly. Both reset the conversation, but /clear keeps your terminal session active and reloads CLAUDE.md. Starting a new session also resets any in-memory state from hooks or tools."
      }
    }
  ]
}
</script>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

- [Command Reference](/commands/) — Interactive command search and filter tool
- [Claude Code Keyboard Shortcuts Cheat Sheet](/claude-code-keyboard-shortcuts-cheat-sheet/) — All keyboard shortcuts
- [Best Claude Code Commands You Are Not Using](/best-claude-code-commands-you-are-not-using-2026/) — Hidden commands most devs miss
- [/compact vs /clear: When to Use](/claude-code-compact-vs-clear-when-to-use/) — Detailed comparison
- [Claude Code Cost Optimization](/claude-code-cost-optimization-15-techniques/) — 15 techniques to reduce spend
