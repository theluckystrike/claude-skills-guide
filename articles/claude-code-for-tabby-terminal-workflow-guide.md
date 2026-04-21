---
layout: default
title: "Claude Code for Tabby Terminal — Workflow Guide"
description: "Configure Tabby terminal for Claude Code workflows. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-tabby-terminal-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, tabby-terminal, workflow]
---

## The Setup

You are using Tabby (formerly Terminus) as your terminal emulator — a modern, highly configurable terminal with built-in SSH client, serial port support, tabs, split panes, and a plugin system. Tabby runs on Electron and provides a GUI settings panel for configuration. Claude Code works inside Tabby, but it generates configuration for other terminals like iTerm2 or Alacritty.

## What Claude Code Gets Wrong By Default

1. **References iTerm2 or Terminal.app settings.** Claude tells you to change settings in iTerm2's Preferences panel. Tabby has its own settings accessible through the GUI (Settings icon) or `~/.config/tabby/config.yaml`.

2. **Suggests tmux for session management.** Claude installs tmux for splits and tabs. Tabby has built-in tabs, split panes, and session recovery — tmux is not needed for basic workspace management.

3. **Uses Alacritty/Kitty config format.** Claude writes TOML configuration for Alacritty. Tabby uses YAML configuration in `~/.config/tabby/config.yaml` and a GUI settings panel — the config format is different.

4. **Ignores Tabby's SSH and profile system.** Claude writes SSH config in `~/.ssh/config` only. Tabby has built-in SSH connection management with profiles, key management, and connection history — configure SSH connections in Tabby's GUI for a better experience.

## The CLAUDE.md Configuration

```
# Tabby Terminal Configuration

## Terminal
- Emulator: Tabby (modern configurable terminal)
- Config: GUI settings + ~/.config/tabby/config.yaml
- Features: tabs, splits, SSH client, plugins
- Platform: Electron-based, cross-platform

## Tabby Rules
- Config: YAML at ~/.config/tabby/config.yaml
- Settings: GUI settings panel for visual configuration
- Tabs: built-in (no tmux needed)
- Splits: built-in horizontal and vertical
- SSH: built-in SSH client with profiles
- Plugins: installable through settings panel
- Profiles: shell, SSH, serial connection profiles

## Conventions
- Use Tabby's built-in tabs and splits
- Configure Claude Code profile for dedicated settings
- Font: set in Appearance settings
- Theme: install via Tabby plugin system
- SSH connections: managed in Tabby SSH profiles
- Scrollback: increase in settings for Claude Code output
- Shell integration: enable for working directory tracking
```

## Workflow Example

You want to configure Tabby for efficient Claude Code development. Prompt Claude Code:

"Configure Tabby terminal with a dedicated Claude Code profile using JetBrains Mono font, a dark theme, increased scrollback buffer, and keyboard shortcuts for creating splits and switching between tabs. Set up an SSH profile for the development server."

Claude Code should modify `~/.config/tabby/config.yaml` to add a shell profile named "Claude Code" with font, scrollback, and color settings, add hotkey configurations for split management, and create an SSH profile with the dev server connection details.

## Common Pitfalls

1. **Electron performance with long output.** Claude generates very long output that slows Tabby. Electron-based terminals can struggle with extremely large terminal buffers. Set a reasonable scrollback limit and clear the buffer periodically during long sessions.

2. **Plugin compatibility issues.** Claude installs multiple Tabby plugins that conflict. Some plugins may be outdated or incompatible with your Tabby version. Install plugins one at a time and test for conflicts.

3. **Config file vs GUI settings conflict.** Claude edits the YAML config file while Tabby's GUI overwrites changes on save. Either use the GUI or the config file — editing both can cause settings to be lost. For reproducible setups, prefer the config file.

## Related Guides

- [Claude Code for Alacritty Workflow Guide](/claude-code-for-alacritty-workflow-guide/)
- [Claude Code for Warp AI Terminal Workflow Guide](/claude-code-for-warp-ai-terminal-workflow-guide/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)

## Related Articles

- [Claude Code + Warp Terminal: Workflow Guide](/claude-code-for-warp-ai-terminal-workflow-guide/)
- [Claude Code for WezTerm Terminal Workflow Guide](/claude-code-for-wezterm-terminal-workflow-guide/)
