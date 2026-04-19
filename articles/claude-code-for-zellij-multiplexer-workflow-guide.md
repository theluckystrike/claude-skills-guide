---
layout: default
title: "Claude Code for Zellij — Workflow Guide"
description: "Run parallel Claude Code sessions with Zellij multiplexer. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-zellij-multiplexer-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, zellij, workflow]
---

## The Setup

You are using Zellij, the terminal multiplexer written in Rust with a plugin system and built-in layout management. Zellij lets you run multiple Claude Code sessions in parallel panes, each working on different parts of your project. Claude Code can help configure Zellij, but it generates tmux commands and config syntax instead.

## What Claude Code Gets Wrong By Default

1. **Writes tmux commands and configuration.** Claude generates `tmux split-window` and `.tmux.conf` configuration. Zellij has its own commands: `zellij action new-pane` and uses KDL (`.kdl`) config files, not tmux's format.

2. **Uses tmux keybinding syntax.** Claude configures `bind-key C-b` tmux prefixes. Zellij uses a mode-based keybinding system with configurable modes in `config.kdl` and defaults to `Ctrl+Pane_key` without a prefix key.

3. **Creates shell scripts for pane management.** Claude writes bash scripts to manage terminal layouts. Zellij has built-in layout files (`.kdl` format) that declaratively define pane arrangements, automatically creating the workspace on startup.

4. **Ignores Zellij's plugin system.** Claude does not leverage Zellij plugins for status bars, file managers, or session management. Zellij plugins run in WASM and can enhance the Claude Code development workflow.

## The CLAUDE.md Configuration

```
# Zellij Terminal Multiplexer

## Terminal
- Multiplexer: Zellij (Rust, plugin-based, KDL config)
- Config: ~/.config/zellij/config.kdl
- Layouts: ~/.config/zellij/layouts/ directory
- Plugins: WASM-based, built-in and custom

## Zellij Rules
- Layouts in KDL format, NOT tmux conf
- New pane: Ctrl+p then n (or zellij action new-pane)
- Split: Ctrl+p then d (down) or r (right)
- Resize: Ctrl+n then arrows
- Sessions: zellij attach <name>, zellij kill-session <name>
- Floating panes: Ctrl+p then w (for quick Claude Code tasks)
- Layouts define workspace for project startup

## Conventions
- Dev layout: editor pane (top), Claude Code pane (bottom-right), server pane (bottom-left)
- Use named sessions per project: zellij -s project-name
- Floating pane for quick Claude Code queries
- Full pane for long Claude Code generation tasks
- Layout file per project: .zellij-layout.kdl in project root
- Lock mode (Ctrl+g) when Claude Code needs keyboard input
```

## Workflow Example

You want to create a development layout for a full-stack project. Prompt Claude Code:

"Create a Zellij layout file for a Next.js project with four panes: a large editor pane on top, a dev server pane bottom-left, a Claude Code pane bottom-right, and a floating pane for quick tasks. Configure the layout to auto-start the dev server."

Claude Code should create a `.kdl` layout file with a `layout { }` block defining the pane arrangement, `command` directives for auto-starting the dev server, size percentages for each pane, and a floating pane configuration that opens on demand.

## Common Pitfalls

1. **Keybinding mode confusion.** Claude sends Zellij commands while in normal mode. Zellij uses modes (normal, pane, tab, resize, scroll) — you must enter the correct mode first. Claude Code users often get stuck in scroll mode; press `Esc` to return to normal.

2. **Layout file syntax errors.** Claude writes KDL syntax incorrectly, mixing it with TOML or JSON. KDL uses `node key=value { children }` structure. A single syntax error prevents the entire layout from loading with an unhelpful error message.

3. **Session persistence expectations.** Claude assumes pane contents persist like tmux with tmux-resurrect. Zellij sessions persist the layout and pane arrangement, but running processes (like Claude Code sessions) must be restarted after system reboot or session detach/reattach.

## Related Guides

- [Claude Code for Ghostty Terminal Workflow](/claude-code-for-ghostty-terminal-workflow-tutorial/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)

## Related Articles

- [Claude Code for Zellij Terminal Multiplexer Workflow](/claude-code-for-zellij-terminal-multiplexer-workflow/)
