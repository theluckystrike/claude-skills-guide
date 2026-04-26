---
layout: default
title: "Claude Code for AeroSpace Tiling (2026)"
description: "Claude Code for AeroSpace Tiling — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-aerospace-tiling-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, aerospace, workflow]
---

## The Setup

You are configuring AeroSpace, the i3-like tiling window manager for macOS, to create an efficient development workspace. Claude Code can generate AeroSpace configuration, keybindings, and workspace layouts, but it confuses AeroSpace's TOML config syntax with i3's config format and misunderstands macOS-specific constraints.

## What Claude Code Gets Wrong By Default

1. **Generates i3 configuration syntax.** Claude writes `bindsym $mod+1 workspace 1` in i3 format. AeroSpace uses TOML configuration in `~/.aerospace.toml` with a completely different structure: `[mode.main.binding]` sections with key-value pairs.

2. **Assumes X11 window management capabilities.** Claude tries to configure window borders, transparency, and gaps using X11 concepts. AeroSpace on macOS has limited styling options and does not support all features that i3 offers on Linux.

3. **Ignores macOS app-specific behaviors.** Claude treats all windows equally. Some macOS apps (Finder, System Settings) do not tile well and need float rules. AeroSpace handles this with `[[on-window-detected]]` rules.

4. **Writes shell scripts for layout management.** Claude creates bash scripts to move windows. AeroSpace has a built-in `aerospace` CLI and IPC that should be used for layout commands instead of AppleScript or shell hacks.

## The CLAUDE.md Configuration

```
# AeroSpace Tiling WM Configuration

## System
- OS: macOS (AeroSpace tiling window manager)
- Config: ~/.aerospace.toml (TOML format, NOT i3 config)
- CLI: aerospace command for runtime control

## AeroSpace Rules
- Config is TOML, not i3 format
- Keybindings go in [mode.main.binding] section
- Use alt (Option) as mod key, not Super/Cmd (conflicts with macOS)
- Float rules use [[on-window-detected]] with app-id matching
- Workspace names are single characters or numbers
- Gaps configured with outer-gap and inner-gap in [gaps] section
- Auto-float apps: Finder, System Settings, Calculator, Archive Utility

## Conventions
- Workspace 1: Terminal (Warp/iTerm)
- Workspace 2: Editor (VS Code/Zed)
- Workspace 3: Browser
- Workspace 4: Communication (Slack/Discord)
- Layout: BSP (binary space partition) as default
- Never bind Cmd+key — reserved for macOS system shortcuts
```

## Workflow Example

You want to set up a three-workspace development layout. Prompt Claude Code:

"Create an AeroSpace config with workspaces for terminal, editor, and browser. Use alt as the modifier key. Add keybindings for switching workspaces, moving windows between them, and toggling float mode. Float Finder and System Settings by default."

Claude Code should produce a valid `~/.aerospace.toml` file with `[mode.main.binding]` entries for `alt-1` through `alt-3`, `alt-shift-1` through `alt-shift-3` for moves, and `[[on-window-detected]]` rules matching `com.apple.finder` app-id to float mode.

## Common Pitfalls

1. **Binding Cmd+key combinations.** Claude uses Cmd as the modifier because it is the macOS "super" key. This breaks system shortcuts like Cmd+C (copy) and Cmd+Q (quit). Use Alt (Option) as the modifier to avoid conflicts.

2. **Missing app-id format.** Claude uses app names like "Finder" in float rules. AeroSpace matches on bundle identifiers like `com.apple.finder`. Use `aerospace list-windows --all` to discover the correct app-id format.

3. **Reload vs restart confusion.** Claude tells users to restart AeroSpace after config changes. AeroSpace supports live config reload with `aerospace reload-config` — no restart needed, and restarting loses your current layout.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Ghostty Terminal Workflow](/claude-code-for-ghostty-terminal-workflow-tutorial/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)

## Related Articles

- [Claude Code SDK Development Workflow Guide](/claude-code-sdk-development-workflow-guide/)
- [Claude Code for Wing Cloud Language Workflow](/claude-code-for-wing-cloud-language-workflow/)
- [Claude Code for ScoutSuite Audit Workflow Guide](/claude-code-for-scoutsuite-audit-workflow-guide/)
- [Claude Code for RabbitMQ Topic Exchange Workflow](/claude-code-for-rabbitmq-topic-exchange-workflow/)
- [Claude Code for Upbound Marketplace Workflow Guide](/claude-code-for-upbound-marketplace-workflow-guide/)
- [Claude Code for Lottie Animation Workflow Tutorial](/claude-code-for-lottie-animation-workflow-tutorial/)
- [Claude Code for License Scanning Workflow Tutorial](/claude-code-for-license-scanning-workflow-tutorial/)
- [Claude Code for SharedArrayBuffer Workflow](/claude-code-for-shared-array-buffer-workflow/)


## Common Questions

### How do I get started with claude code for aerospace tiling?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
