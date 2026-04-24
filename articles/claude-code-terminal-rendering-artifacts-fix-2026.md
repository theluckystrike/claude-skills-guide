---
title: "Terminal Emulator Rendering Artifacts Fix"
permalink: /claude-code-terminal-rendering-artifacts-fix-2026/
description: "Fix terminal rendering artifacts in Claude Code. Reset ANSI state and switch terminal emulator to resolve garbled output, broken prompts, and ghost text."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
[Garbled terminal output]
 ←[0m←[1m←[38;5;208m   Claude Code ←[0m←[2m v1.2.3←[0m
  ^[[A^[[B^[[D — ghost ANSI escape sequences visible in output
  Terminal prompt corrupted after Claude Code streaming response
```

This appears when ANSI escape codes leak into the terminal output, causing garbled text, invisible characters, ghost cursor movements, or corrupted prompts.

## The Fix

```bash
reset
claude
```

1. Run the `reset` command to reinitialize the terminal state and clear all ANSI modes.
2. If `reset` is not available, press `Ctrl+L` to clear the screen and try `tput reset`.
3. Restart Claude Code in the cleaned terminal.

## Why This Happens

Claude Code uses ANSI escape codes for colors, bold text, progress spinners, and cursor movement. When a streaming response is interrupted (Ctrl+C, network drop, or crash), the terminal may be left in an altered state (wrong color mode, hidden cursor, alternate screen buffer). Some terminal emulators do not properly handle the rapid escape code sequences that Claude Code produces during streaming, causing them to render raw escape characters instead.

## If That Doesn't Work

Clear ANSI state manually:

```bash
printf '\033[0m\033[?25h\033[?1049l'
```

Switch to a simpler output mode:

```bash
export TERM=xterm
export NO_COLOR=1
claude
```

Try a different terminal emulator (iTerm2, Alacritty, or Kitty handle ANSI better than Terminal.app):

```bash
# Install a better terminal:
brew install --cask iterm2
# Or:
brew install --cask alacritty
```

## Prevention

```markdown
# CLAUDE.md rule
If terminal output becomes garbled, run 'reset' and restart Claude Code. Use iTerm2 or Alacritty for best rendering compatibility. Set NO_COLOR=1 if you do not need colored output.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
