---
layout: default
title: "Claude Code for Bat (Cat Alternative)"
description: "View files with syntax highlighting using Bat and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-bat-cat-alternative-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, bat, workflow]
---

## The Setup

You are using bat as a replacement for `cat`, a Rust-based command-line tool that provides syntax highlighting, Git integration, line numbers, and paging for file output. bat auto-detects file types and applies appropriate syntax highlighting, making code review and file inspection faster. Claude Code can display file contents, but it uses plain `cat` without highlighting or context.

## What Claude Code Gets Wrong By Default

1. **Uses `cat` for file display.** Claude runs `cat file.ts` for plain text output. bat provides syntax highlighting, line numbers, and Git change markers — `bat file.ts` gives much more readable output.

2. **Pipes through separate tools for highlighting.** Claude chains `cat file.ts | pygmentize` or uses other colorizers. bat handles syntax highlighting natively for 100+ languages — no additional tools or pipes needed.

3. **Adds `--number` flag for line numbers.** Claude runs `cat -n file.ts` for numbered lines. bat shows line numbers by default with `--style=numbers` and includes Git change indicators alongside.

4. **Ignores bat's integration capabilities.** Claude uses bat as a standalone viewer only. bat can be used as `MANPAGER`, `GIT_PAGER`, and integrated with fzf, ripgrep, and other tools for enhanced output.

## The CLAUDE.md Configuration

```
# Bat File Viewer

## Tools
- Viewer: bat (cat alternative with syntax highlighting)
- Features: syntax highlighting, line numbers, Git integration
- Paging: built-in paging with less
- Themes: customizable color themes

## Bat Rules
- View: bat file.ts (with syntax highlighting)
- Plain: bat --plain file.ts (no decorations)
- Language: bat -l json file (force language)
- Line range: bat --line-range 10:20 file.ts
- Diff: bat --diff file1.ts file2.ts
- Pager: bat --paging=never for piping
- Theme: bat --theme="Catppuccin Mocha"

## Conventions
- Use bat for all file viewing commands
- bat --plain for piping to other commands
- Set BAT_THEME in shell config for consistent theme
- Use bat as MANPAGER: export MANPAGER="bat -l man -p"
- Integration: rg --json | bat for highlighted ripgrep output
- Use bat --line-range for viewing specific sections
- bat --show-all for whitespace characters
```

## Workflow Example

You want to set up bat as the default file viewer with project-specific configuration. Prompt Claude Code:

"Configure bat as the default pager for Git and man pages. Set the Catppuccin Mocha theme, enable Git integration, and create shell aliases for common bat operations. Also show how to use bat with ripgrep for highlighted search results."

Claude Code should add `export BAT_THEME="Catppuccin Mocha"` to shell config, set `export MANPAGER="sh -c 'col -bx | bat -l man -p'"` and `git config --global core.pager 'bat --paging=always'`, create aliases like `alias preview='bat --line-range :50'`, and show the `rg pattern --json | bat` integration.

## Common Pitfalls

1. **Paging interfering with piping.** Claude pipes bat output to other commands but the pager intercepts. Use `bat --paging=never` or `bat -p` when piping to other commands — the pager is for interactive viewing, not piping.

2. **Theme not matching terminal colors.** Claude sets a bat theme that clashes with the terminal theme. Use `bat --list-themes | bat` to preview themes in your terminal and pick one that matches your color scheme.

3. **Missing language detection for stdin.** Claude pipes content to bat without specifying the language: `curl url | bat`. Without a file extension, bat cannot detect the language. Use `curl url | bat -l json` to specify the language explicitly.

## Related Guides

- [Claude Code for Ripgrep Workflow Guide](/claude-code-for-ripgrep-workflow-guide/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
