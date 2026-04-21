---
layout: post
title: "How to Set Up Claude Code in Ghostty Terminal 2026"
description: "Configure Ghostty terminal for Claude Code with GPU-accelerated rendering, custom fonts, keybindings, and split panes. Full config included."
permalink: /claude-code-ghostty-terminal-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Set up the Ghostty terminal emulator as a high-performance environment for Claude Code sessions. Ghostty's GPU-accelerated rendering handles long AI-generated outputs without lag, making it ideal for extended coding sessions.

Expected time: 15 minutes
Prerequisites: Ghostty 1.0+, Claude Code CLI installed, macOS or Linux

## Setup

### 1. Install Ghostty

```bash
# macOS via Homebrew
brew install --cask ghostty

# Linux (build from source)
git clone https://github.com/ghostty-org/ghostty.git
cd ghostty
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/ghostty /usr/local/bin/
```

Ghostty uses the GPU for text rendering, which prevents terminal freezes during large Claude Code outputs.

### 2. Create Ghostty Configuration

```bash
mkdir -p ~/.config/ghostty
cat > ~/.config/ghostty/config << 'EOF'
# Font configuration for code readability
font-family = JetBrains Mono
font-size = 14
font-thicken = true

# Window settings
window-padding-x = 12
window-padding-y = 8
window-decoration = true
window-theme = dark

# Performance settings for long Claude Code outputs
scrollback-limit = 100000
clipboard-read = allow
clipboard-write = allow
clipboard-paste-protection = false

# Colors (Catppuccin Mocha for reduced eye strain)
background = 1e1e2e
foreground = cdd6f4
cursor-color = f5e0dc
selection-background = 45475a
selection-foreground = cdd6f4

# Shell integration
shell-integration = zsh
shell-integration-features = cursor,sudo,title

# Keybindings for Claude Code workflow
keybind = super+shift+c=new_tab
keybind = super+k=clear_screen
keybind = super+shift+v=paste_from_clipboard
EOF
```

This config provides a comfortable environment optimized for reading AI-generated code.

### 3. Configure Shell Environment for Claude Code

```bash
cat >> ~/.zshrc << 'EOF'
# Claude Code in Ghostty
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
export CLAUDE_CODE_THEME="dark"

# Aliases for quick access
alias cc="claude"
alias ccp="claude --print"
alias ccr="claude --resume"

# Function to start Claude Code in a named session
ccn() {
    echo "Starting Claude Code session: $1"
    claude --resume "$1" 2>/dev/null || claude
}
EOF
source ~/.zshrc
```

The aliases reduce typing for frequent Claude Code operations.

### 4. Set Up Split Panes for Code + Claude

```bash
# Ghostty supports native splits
# Use these keybindings (default):
# Ctrl+Shift+Enter - Split horizontally
# Ctrl+Shift+| - Split vertically
# Ctrl+Shift+Arrow - Navigate between panes
```

Run your editor in one pane and Claude Code in the adjacent pane for side-by-side development.

### 5. Verify

```bash
ghostty --version
# Expected output:
# ghostty 1.x.x

claude --version
# Expected output:
# claude-code x.x.x

claude --print "Say hello from Ghostty"
# Expected output:
# Hello from Ghostty! (or similar response)
```

## Usage Example

A typical workflow with Claude Code in Ghostty using split panes:

```bash
# Terminal split: Left pane = editor, Right pane = Claude Code
# In right pane, start Claude Code
claude

# Generate a utility function
> Write a TypeScript debounce utility with proper generics and
> cancellation support. Include JSDoc comments.
```

Claude Code outputs directly in the Ghostty pane:

```typescript
/**
 * Creates a debounced version of the provided function.
 * The debounced function delays invoking func until after
 * `delay` milliseconds have elapsed since the last invocation.
 *
 * @param func - The function to debounce
 * @param delay - Milliseconds to delay
 * @returns Debounced function with cancel method
 */
export function debounce<T extends (...args: unknown[]) => unknown>(
  func: T,
  delay: number
): {
  (...args: Parameters<T>): void;
  cancel: () => void;
  flush: () => void;
} {
  let timeoutId: ReturnType<typeof setTimeout> | null = null;
  let lastArgs: Parameters<T> | null = null;

  const debounced = (...args: Parameters<T>): void => {
    lastArgs = args;
    if (timeoutId !== null) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      timeoutId = null;
      lastArgs = null;
      func(...args);
    }, delay);
  };

  debounced.cancel = (): void => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId);
      timeoutId = null;
      lastArgs = null;
    }
  };

  debounced.flush = (): void => {
    if (timeoutId !== null && lastArgs !== null) {
      clearTimeout(timeoutId);
      timeoutId = null;
      const args = lastArgs;
      lastArgs = null;
      func(...args);
    }
  };

  return debounced;
}
```

Copy the output with Cmd+C (Ghostty's clipboard integration handles this cleanly) and paste into your editor pane.

```bash
# Scrollback works perfectly even for 1000+ line outputs
# Use Cmd+K to clear the screen between prompts
# Use Cmd+Shift+C to open a new tab for parallel Claude sessions
```

## Common Issues

- **Text rendering artifacts after long sessions:** Run `Cmd+K` to clear the screen, or restart the Ghostty tab. This is rare but can happen with 100K+ line scrollback.
- **Claude Code output truncated:** Increase `scrollback-limit` in your config to 500000 if you regularly generate very long outputs.
- **Shell integration not working:** Ensure `shell-integration = zsh` matches your actual shell. For bash, use `shell-integration = bash`.

## Why This Matters

Ghostty's GPU rendering means zero frame drops when Claude Code streams 500+ line responses. Developers report 30% less fatigue in extended sessions compared to CPU-rendered terminals.

## Related Guides

- [Claude Code for Alacritty Workflow Guide](/claude-code-for-alacritty-workflow-guide/)
- [Claude Code for WezTerm Terminal Workflow Guide](/claude-code-for-wezterm-terminal-workflow-guide/)
- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)
