---
layout: default
title: "10 Claude Code Commands You Didn't Know Existed (2026)"
description: "Hidden and lesser-known Claude Code commands — /doctor, /memory, /cost, /review, /vim, --resume, --append-system-prompt, and more. Each with practical use cases."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /10-claude-code-commands-you-didnt-know/
reviewed: true
categories: [guides]
tags: [claude, claude-code, commands, hidden-features, tips, productivity]
---

# 10 Claude Code Commands You Didn't Know Existed (2026)

Most Claude Code users stick to the basics — type a prompt, get a response, repeat. But the CLI includes commands and flags that dramatically change how you work: diagnose broken setups, persist preferences across sessions, resume interrupted work, and control output formats. These are the features that separate casual users from power users. For the complete interactive reference, see the [Command Reference](/commands/).

## 1. /doctor — Diagnose Installation Issues

When something breaks, `/doctor` runs a full diagnostic suite on your Claude Code setup. It checks authentication, model availability, MCP connections, config file validity, and Node.js compatibility.

```
/doctor

# Output:
# ✓ Authentication: Valid (API key)
# ✓ Model: claude-sonnet-4-20250514 (available)
# ✗ MCP: github server disconnected (invalid token)
# ✓ Config: ~/.claude/settings.json valid
# ✓ Node.js: v20.11.0 (compatible)
```

**Why this matters:** Instead of guessing why MCP servers will not connect or why responses seem wrong, `/doctor` pinpoints the exact issue. Run it before spending 20 minutes debugging manually.

## 2. /memory — Persistent Preferences Across Sessions

The `/memory` command lets you store instructions that Claude remembers in every future session. Preferences are saved to `CLAUDE.md` and loaded automatically.

```
/memory

# Add preferences like:
# "Use pnpm instead of npm for package management"
# "Always write tests using Vitest, not Jest"
# "Prefer named exports over default exports"
```

**Why this matters:** Without `/memory`, you repeat the same instructions every session. With it, Claude already knows your preferences when you start a new conversation.

## 3. /cost — Track Session Spending

The `/cost` command shows exactly how many tokens your current session has consumed and what it costs.

```
/cost

# Session: 2h 15m
# Input tokens: 128,450
# Output tokens: 34,200
# Cache hits: 82%
# Estimated cost: $1.23
```

**Why this matters:** Long debugging sessions can burn through tokens without you noticing. Check `/cost` periodically and use `/compact` to compress context when spending climbs.

## 4. /review — Code Review Mode

Instead of asking Claude to "review my changes," the `/review` command enters a structured code review mode that examines your staged changes against best practices.

```
/review

# Claude analyzes staged changes and reports:
# SECURITY: SQL injection risk in query builder (line 45)
# PERFORMANCE: N+1 query pattern in user loader (line 78)
# STYLE: Inconsistent error handling — some throw, some return null
# TESTS: No test coverage for the new validateInput function
```

**Why this matters:** `/review` catches categories of issues that linters cannot detect — logic errors, missing edge cases, security vulnerabilities, and architectural concerns.

## 5. /vim — Vim Keybindings in the Prompt

For vim users, `/vim` enables vim-style keybindings in the Claude Code input prompt. Normal mode, insert mode, visual mode — the works.

```
/vim

# Enables:
# - ESC for normal mode
# - i, a, o for insert mode
# - hjkl navigation
# - dd, yy, p for editing
# - / for search
```

**Why this matters:** If you live in vim, switching to a different editing paradigm in Claude Code breaks your flow. `/vim` keeps your muscle memory intact.

## 6. --resume — Continue Previous Sessions

The `--resume` flag restarts your most recent Claude Code session with full context intact. No need to re-explain what you were working on.

```bash
# Resume the last session
claude --resume

# Resume a specific session by ID
claude --resume session_abc123
```

**Why this matters:** Crashed terminal? Accidentally closed the tab? `--resume` picks up exactly where you left off, including conversation history and decisions made.

## 7. --append-system-prompt — Inject Custom Instructions

Add custom system-level instructions without modifying config files. Useful for one-off behavioral changes.

```bash
claude --append-system-prompt "Always respond in bullet points. Never use code blocks longer than 20 lines."

# Or for CI/CD pipelines:
claude --append-system-prompt "Output only the final code, no explanations" --print "Fix the failing test in auth.test.ts"
```

**Why this matters:** Perfect for CI/CD integrations where you need Claude to behave differently than in interactive mode, without changing your permanent configuration.

## 8. /config — Runtime Configuration

The `/config` command shows and modifies your configuration during a live session. No restart needed for most changes.

```
/config

# View or modify:
# - Theme and display settings
# - Notification preferences
# - Tool permission levels
# - Custom keybindings
```

**Why this matters:** Tweak settings on the fly. Switch notification behavior mid-session, adjust permissions for a specific task, or check what configuration is currently active.

## 9. --continue — Resume and Add Context

Similar to `--resume` but lets you add new instructions when resuming. The previous session context is loaded, and your new message is appended.

```bash
# Resume and immediately give a new instruction
claude --continue "Now refactor the auth module to use the new token format"
```

**Why this matters:** Combines the context preservation of `--resume` with the ability to immediately pivot to a new task without re-explaining the project state.

## 10. --max-turns — Limit Autonomous Actions

Control how many tool-use turns Claude can take before pausing for your input. Essential for controlling runaway automated sessions.

```bash
# Allow only 5 tool calls before pausing
claude --max-turns 5

# Useful in scripts:
claude --max-turns 1 --print "What files changed in the last commit?"
```

**Why this matters:** Without limits, Claude can chain dozens of tool calls in complex tasks. `--max-turns` gives you checkpoints to review progress and course-correct before Claude goes too far.

## Bonus: Combining Flags for Power Workflows

Chain these flags for sophisticated automation:

```bash
# Resume a session with a token limit and custom instructions
claude --resume --max-turns 10 --append-system-prompt "Focus on security fixes only"

# Non-interactive script mode with output formatting
claude --print "Generate a migration for adding user roles" --output-format json --max-turns 3
```

## Try It Yourself

Explore all commands, flags, and shortcuts interactively with the [Command Reference](/commands/). Search by name, browse by category, and see real examples for every feature.

<details>
<summary>How do I see all available CLI flags?</summary>
Run <code>claude --help</code> in your terminal. This shows every available flag with brief descriptions. For detailed explanations of each flag, use the <a href="/commands/">Command Reference</a>.
</details>

<details>
<summary>Does /memory persist across different projects?</summary>
/memory saves preferences to the project's CLAUDE.md file. These preferences apply only to that project. For global preferences that apply everywhere, edit ~/.claude/CLAUDE.md directly.
</details>

<details>
<summary>Can I use --resume in non-interactive (--print) mode?</summary>
Yes. Combine --resume with --print to continue a previous session with a new prompt and get the output directly in stdout. This is useful for scripted workflows that need session continuity.
</details>

<details>
<summary>What happens if I set --max-turns to 1?</summary>
Claude will make at most one tool call (file read, edit, command execution) and then return its response. This is useful for simple queries where you want a single lookup without multi-step automation.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How do I see all available CLI flags?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run claude --help in your terminal. This shows every available flag with brief descriptions. For detailed explanations of each flag, use the Command Reference."
      }
    },
    {
      "@type": "Question",
      "name": "Does /memory persist across different projects?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "/memory saves preferences to the project's CLAUDE.md file. These preferences apply only to that project. For global preferences that apply everywhere, edit ~/.claude/CLAUDE.md directly."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use --resume in non-interactive (--print) mode?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Combine --resume with --print to continue a previous session with a new prompt and get the output directly in stdout. This is useful for scripted workflows that need session continuity."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if I set --max-turns to 1?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude will make at most one tool call (file read, edit, command execution) and then return its response. This is useful for simple queries where you want a single lookup without multi-step automation."
      }
    }
  ]
}
</script>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Command Reference](/commands/) — Full interactive command explorer
- [Claude Code Configuration Guide](/configuration/) — Complete settings reference
- [Cost Optimization for Claude Code](/cost-optimization/) — Reduce token spending
- [Best Practices for Claude Code](/best-practices/) — Workflow optimization tips
- [Advanced Usage Patterns](/advanced-usage/) — Automation and scripting techniques
