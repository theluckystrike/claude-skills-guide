---
sitemap: false
layout: default
title: "Claude Code Keyboard Shortcuts: Complete Cheat Sheet (2026)"
description: "Every Claude Code keyboard shortcut organized by workflow — navigation, editing, session management, and output control. Printable table format included."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-keyboard-shortcuts-cheat-sheet/
reviewed: true
categories: [reference]
tags: [claude, claude-code, keyboard-shortcuts, cheat-sheet, productivity, reference]
---

# Claude Code Keyboard Shortcuts: Complete Cheat Sheet (2026)

Keyboard shortcuts in Claude Code eliminate the need to type slash commands or reach for the mouse. The right shortcut at the right moment — canceling a runaway operation, accepting a suggestion, navigating history — keeps your hands on the keyboard and your focus on the problem. This cheat sheet covers every shortcut organized by workflow. For the full command reference, see the [Command Reference tool](/commands/).

## Input and Editing Shortcuts

These shortcuts work in the Claude Code input prompt where you type your messages.

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Enter` | Send message | Submits your current input |
| `Shift+Enter` | New line | Adds a line break without sending |
| `Up Arrow` | Previous message | Cycles through your input history |
| `Down Arrow` | Next message | Moves forward through input history |
| `Tab` | Accept suggestion | Accepts autocomplete or file path suggestion |
| `Shift+Tab` | Previous suggestion | Cycles backward through suggestions |
| `Ctrl+A` | Start of line | Moves cursor to the beginning |
| `Ctrl+E` | End of line | Moves cursor to the end |
| `Ctrl+W` | Delete word backward | Removes the word before the cursor |
| `Ctrl+U` | Clear line | Erases the entire input line |
| `Ctrl+K` | Delete to end | Removes everything after the cursor |

## Session Control Shortcuts

These shortcuts control the Claude Code session itself.

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+C` | Cancel current | Stops Claude's current response or tool execution |
| `Ctrl+C` (twice) | Force cancel | Immediately kills a stuck operation |
| `Ctrl+D` | Exit session | Closes Claude Code (same as typing "exit") |
| `Ctrl+L` | Clear screen | Clears the terminal display (history preserved) |
| `Ctrl+R` | Search history | Search through previous inputs |
| `Escape` | Cancel input | Clears the current input without sending |

## Response Interaction Shortcuts

These shortcuts work while Claude is responding or after a response completes.

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+C` | Stop generation | Halts Claude's current response mid-stream |
| `y` | Accept change | Confirms a proposed file edit |
| `n` | Reject change | Declines a proposed file edit |
| `e` | Edit change | Opens the proposed change for manual editing |

## Permission Prompt Shortcuts

When Claude requests permission to perform an action:

| Shortcut | Action | Notes |
|----------|--------|-------|
| `y` | Allow once | Permits this specific action |
| `n` | Deny | Blocks this specific action |
| `a` | Always allow | Permits this action type for the rest of the session |

## File Path Completion

Claude Code includes intelligent file path completion in the input prompt:

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Tab` | Complete path | Autocompletes file or directory names |
| `Tab Tab` | List matches | Shows all matching files when ambiguous |
| `@` | File reference | Type `@filename` to reference a file in your prompt |

### Using @ File References

The `@` symbol triggers file path completion anywhere in your message:

```
Fix the bug in @src/auth/login.ts that causes the token refresh to fail

# Claude reads the referenced file automatically
```

Multiple file references work in a single message:

```
Compare @src/old-handler.ts with @src/new-handler.ts and explain the differences
```

## Vim Mode Shortcuts

After enabling vim mode with `/vim`, these additional shortcuts become available:

### Normal Mode

| Shortcut | Action |
|----------|--------|
| `h/j/k/l` | Move left/down/up/right |
| `w/b` | Move forward/backward by word |
| `0/$` | Start/end of line |
| `i/a` | Enter insert mode (at/after cursor) |
| `o/O` | New line below/above |
| `dd` | Delete entire line |
| `yy` | Copy entire line |
| `p` | Paste |
| `u` | Undo |
| `/` | Search |

### Insert Mode

| Shortcut | Action |
|----------|--------|
| `Escape` | Return to normal mode |
| All standard editing shortcuts | Continue to work |

## Terminal-Specific Shortcuts

These depend on your terminal emulator but work with Claude Code:

| Shortcut | Action | Terminal |
|----------|--------|---------|
| `Cmd+K` | Clear terminal | macOS Terminal, iTerm2 |
| `Cmd+T` | New tab | Most macOS terminals |
| `Ctrl+Shift+C` | Copy selection | Linux terminals |
| `Ctrl+Shift+V` | Paste | Linux terminals |

## Quick Reference Card

The most frequently used shortcuts in a single block:

```
ESSENTIAL SHORTCUTS
─────────────────────────────
Enter          Send message
Shift+Enter    New line
Ctrl+C         Cancel/stop
Ctrl+D         Exit
Ctrl+L         Clear screen
Tab            Accept/complete
Up Arrow       Previous input
@filename      Reference file
y/n/a          Permission prompts
─────────────────────────────
```

## Try It Yourself

Practice these shortcuts in a live session. The [Command Reference](/commands/) includes an interactive explorer where you can search for any command or shortcut by name or function.

<details>
<summary>Can I customize keyboard shortcuts in Claude Code?</summary>
Claude Code does not currently support custom keyboard shortcut remapping. The shortcuts are built into the CLI. However, you can use your terminal emulator's keybinding features to create macros that type specific commands.
</details>

<details>
<summary>Do keyboard shortcuts work the same on Windows and macOS?</summary>
Most shortcuts use Ctrl as the modifier on both platforms. macOS users can use either Ctrl or Cmd for terminal-level shortcuts. Claude Code's own shortcuts (Ctrl+C, Ctrl+D, Tab, etc.) work identically across platforms.
</details>

<details>
<summary>How do I disable vim mode once enabled?</summary>
Run /vim again to toggle vim mode off. Your input prompt returns to standard editing behavior immediately.
</details>

<details>
<summary>What happens if I press Ctrl+C during a file edit?</summary>
Ctrl+C cancels the current operation. If Claude is in the middle of writing a file, the edit is aborted and the file remains unchanged. Claude will report that the operation was cancelled.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I customize keyboard shortcuts in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code does not currently support custom keyboard shortcut remapping. The shortcuts are built into the CLI. However, you can use your terminal emulator's keybinding features to create macros that type specific commands."
      }
    },
    {
      "@type": "Question",
      "name": "Do keyboard shortcuts work the same on Windows and macOS?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most shortcuts use Ctrl as the modifier on both platforms. macOS users can use either Ctrl or Cmd for terminal-level shortcuts. Claude Code's own shortcuts work identically across platforms."
      }
    },
    {
      "@type": "Question",
      "name": "How do I disable vim mode once enabled?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run /vim again to toggle vim mode off. Your input prompt returns to standard editing behavior immediately."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if I press Ctrl+C during a file edit?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Ctrl+C cancels the current operation. If Claude is in the middle of writing a file, the edit is aborted and the file remains unchanged. Claude will report that the operation was cancelled."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Command Reference](/commands/) — Full interactive command explorer
- [Getting Started with Claude Code](/getting-started/) — First-time setup and basics
- [Claude Code Configuration Guide](/configuration/) — Settings and customization
- [Best Practices for Claude Code](/best-practices/) — Workflow optimization
- [Getting Started with Claude Code](/starter/) — Beginner-friendly introduction
