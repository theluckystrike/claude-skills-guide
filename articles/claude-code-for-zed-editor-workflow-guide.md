---
layout: default
title: "Claude Code for Zed Editor — Workflow Guide"
description: "Pair Claude Code with Zed editor for fast coding. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-zed-editor-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, zed, workflow]
---

## The Setup

You are using Zed, the GPU-accelerated code editor written in Rust with built-in collaboration and AI features. Running Claude Code alongside Zed creates a powerful workflow where Zed handles fast editing and its own AI assistant handles inline completions, while Claude Code handles larger refactoring and generation tasks from the terminal.

## What Claude Code Gets Wrong By Default

1. **Generates VS Code extension recommendations.** Claude suggests installing VS Code extensions for features Zed already has built-in, like multi-cursor editing, LSP support, and Git integration.

2. **References VS Code settings format.** Claude writes `settings.json` with VS Code keys. Zed uses its own `settings.json` format in `~/.config/zed/settings.json` with different key names and structure.

3. **Suggests VS Code keybindings.** Claude provides `Ctrl+Shift+P` command palette shortcuts. Zed uses `Cmd+Shift+P` on macOS by default with its own keybinding system configured in `keymap.json`.

4. **Ignores Zed's built-in terminal and AI.** Claude does not know that Zed has an integrated terminal where Claude Code can run, and a built-in AI assistant for inline code generation. The two AI tools should complement each other.

## The CLAUDE.md Configuration

```
# Zed Editor Development Workflow

## Editor
- Editor: Zed (GPU-accelerated, Rust-based)
- Config: ~/.config/zed/settings.json
- Keymap: ~/.config/zed/keymap.json
- Terminal: Built-in terminal panel (run Claude Code here)

## Workflow Rules
- Use Zed's built-in AI for inline completions and small edits
- Use Claude Code (in Zed terminal) for large refactors and generation
- Zed auto-saves — no manual Cmd+S needed after Claude Code changes
- LSP built-in — no extension installs for language support
- Multi-buffer editing: Zed opens changed files automatically
- Use Zed's project-wide search (Cmd+Shift+F) to verify changes

## Conventions
- Zed terminal panel at bottom for Claude Code sessions
- Claude Code edits files; Zed picks up changes via auto-reload
- Use Zed's inline AI for single-line fixes
- Use Claude Code for multi-file changes and architecture work
- Git integration built-in — use Zed's git panel for staging
- Zed's diagnostics panel shows LSP errors from Claude's changes
```

## Workflow Example

You want to use Claude Code and Zed together for a refactoring task. Prompt Claude Code:

"Refactor all API route handlers in src/routes/ to use a shared error handling middleware. Update each handler to remove try-catch blocks and use the new middleware pattern."

After Claude Code makes changes, Zed automatically reloads the modified files, shows LSP diagnostics for any type errors, and lets you review all changes in the multi-buffer editor. Use Zed's diagnostics panel to fix any issues Claude Code introduced.

## Common Pitfalls

1. **Two AI assistants competing.** Both Zed's built-in AI and Claude Code can edit the same file simultaneously. Disable Zed's inline edit suggestions when running a large Claude Code task to avoid conflicts where both modify the same code.

2. **File conflict on simultaneous saves.** Zed auto-saves, and Claude Code writes files directly. If you edit in Zed while Claude Code is writing, you may get conflicts. Let Claude Code finish its changes before editing the same files in Zed.

3. **Missing Zed theme for Claude Code output.** Claude Code's terminal output may not match Zed's editor theme. Configure Zed's terminal theme in settings to match the editor: `"terminal": { "font_family": "...", "theme": "..." }`.

## Related Guides

- [Zed Editor AI Features Review for Developers 2026](/zed-editor-ai-features-review-for-developers-2026/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [When to Use Claude Code vs Manual Coding Tradeoffs](/when-to-use-claude-code-vs-manual-coding-tradeoffs/)

## Related Articles

- [Claude Code for Helix Editor — Workflow Guide](/claude-code-for-helix-editor-workflow-guide/)
