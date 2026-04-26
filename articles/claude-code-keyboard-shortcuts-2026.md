---
layout: default
title: "Claude Code Keyboard Shortcuts (2026)"
description: "All Claude Code keyboard shortcuts for faster coding. Navigation, editing, session control, and output shortcuts with examples."
permalink: /claude-code-keyboard-shortcuts-2026/
date: 2026-04-26
---

# Claude Code Keyboard Shortcuts (2026)

Every second you spend reaching for a mouse or typing a slash command is a second you are not solving problems. Claude Code's keyboard shortcuts keep your hands on the keyboard and your focus on the code. This guide covers every shortcut available in 2026, grouped by workflow.

For the full command reference including slash commands, see the [Command Reference tool](/commands/).

## Input Shortcuts

These work in the Claude Code prompt where you type messages and instructions.

| Shortcut | Action |
|----------|--------|
| `Enter` | Send message |
| `Shift+Enter` | New line without sending |
| `Up Arrow` | Previous input from history |
| `Down Arrow` | Next input from history |
| `Tab` | Accept file path or autocomplete suggestion |
| `Shift+Tab` | Previous autocomplete suggestion |
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+U` | Clear current input line |
| `Ctrl+W` | Delete word before cursor |

The `Up Arrow` history is particularly powerful. If you sent a complex prompt three messages ago and want to modify it, press `Up` three times, edit, and send. No retyping.

## Session Control Shortcuts

These manage your Claude Code session without typing slash commands.

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal display (not conversation) |
| `Escape` | Dismiss current suggestion or cancel pending action |

The difference between `Ctrl+C` and `Escape` matters. `Ctrl+C` stops Claude mid-response, which is useful when you see it heading in the wrong direction. `Escape` dismisses UI elements like autocomplete menus without interrupting processing.

Double-pressing `Ctrl+C` during a long operation performs a hard interrupt. Use this when a single `Ctrl+C` does not stop the current tool execution.

## Output and Display Shortcuts

These control how Claude Code displays its responses.

| Shortcut | Action |
|----------|--------|
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+S` | Scroll-lock toggle |
| `Space` | Page down during long output |
| `q` | Quit pager view |

When Claude produces long output, the terminal enters a pager mode. Use `Space` to page through results and `q` to exit back to the prompt.

## File and Navigation Shortcuts

These help when Claude Code references files or asks for input about file paths.

| Shortcut | Action |
|----------|--------|
| `Tab` | Complete file path |
| `Tab Tab` | Show all completions |
| `Ctrl+R` | Reverse search through input history |

The `Tab` completion is context-aware. If Claude asks you to specify a file, pressing `Tab` lists files from your project directory. This prevents typos in paths that would cause tool failures.

## Permission Response Shortcuts

When Claude requests permission to run a tool or access a file, you can respond quickly with shortcuts instead of typing full responses.

| Shortcut | Action |
|----------|--------|
| `y` + `Enter` | Approve single action |
| `a` + `Enter` | Approve all similar actions this session |
| `n` + `Enter` | Deny action |

The `a` (approve all) shortcut is the most impactful. When Claude needs to read fifteen files to understand your codebase, approving each one individually wastes time. Press `a` once and Claude proceeds without further prompts for that tool type. Configure default permissions with the [Permissions Configurator](/permissions/) to eliminate these prompts entirely.

## Workflow Patterns

### Fast iteration loop

```
1. Type prompt → Enter
2. Watch output → Ctrl+C if wrong direction
3. Up Arrow → edit prompt → Enter
4. Repeat until correct
```

### Context management

```
1. Work until context feels heavy
2. Type /cost → check token usage
3. If over 50% context: /compact
4. Continue working with compressed context
```

The `/cost` command shows your current token usage, which tells you when to compact. See the [Token Estimator](/token-estimator/) for forecasting usage before you start.

## Try It Yourself

Open the [Command Reference](/commands/) to see every command alongside these shortcuts. The interactive tool lets you search by action (like "cancel" or "clear") to find the right shortcut instantly.

Practice the three shortcuts that save the most time: `Up Arrow` for history, `a` for bulk approval, and `Ctrl+C` for early cancellation. These three alone can cut minutes from every session.

## Frequently Asked Questions

**Do keyboard shortcuts work the same on Mac and Linux?**

Most shortcuts are identical. The main difference is that Mac uses `Cmd` for some system-level shortcuts, but Claude Code itself uses `Ctrl` consistently across platforms.

**Can I customize keyboard shortcuts?**

Claude Code does not currently support custom keybindings. The shortcuts are built into the CLI interface. You can, however, use your terminal emulator's key remapping to create custom bindings.

**Why does Ctrl+C sometimes not stop Claude?**

A single `Ctrl+C` sends an interrupt signal, but some tool executions (like long-running shell commands) may need a second `Ctrl+C` to force-stop. If Claude is mid-thought, one press is usually enough.

**What is the fastest way to approve all permissions?**

Configure [allowedTools in settings.json](/claude-code-permission-rules-settings-json-guide/) to pre-approve specific tools. This eliminates permission prompts entirely for trusted operations.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do keyboard shortcuts work the same on Mac and Linux?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most shortcuts are identical. Mac uses Cmd for some system-level shortcuts, but Claude Code itself uses Ctrl consistently across platforms."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize keyboard shortcuts?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code does not currently support custom keybindings. The shortcuts are built into the CLI. You can use your terminal emulator's key remapping to create custom bindings."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Ctrl+C sometimes not stop Claude?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A single Ctrl+C sends an interrupt signal, but some tool executions may need a second Ctrl+C to force-stop. If Claude is mid-thought, one press is usually enough."
      }
    },
    {
      "@type": "Question",
      "name": "What is the fastest way to approve all permissions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Configure allowedTools in settings.json to pre-approve specific tools. This eliminates permission prompts entirely for trusted operations."
      }
    }
  ]
}
</script>

## Related Guides

- [Command Reference](/commands/) — Interactive command and shortcut explorer
- [Every Claude Code Slash Command](/every-claude-code-slash-command-explained/) — Complete slash command reference
- [Claude Code Keyboard Shortcuts Cheat Sheet](/claude-code-keyboard-shortcuts-cheat-sheet/) — Printable table format
- [Permissions Model Guide](/claude-code-permissions-model-security-guide-2026/) — Understanding permission modes
- [Speed Up Claude Code with Commands](/speed-up-claude-code-with-commands-2026/) — Command-based workflow optimization
