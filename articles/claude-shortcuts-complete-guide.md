---
title: "Claude Shortcuts (2026)"
description: "Complete list of keyboard shortcuts for Claude.ai, Claude Desktop, and Claude Code CLI. Platform-specific keys, slash commands, and customization."
permalink: /claude-shortcuts-complete-guide/
last_tested: "2026-04-24"
---

# Claude Shortcuts: Every Keyboard Shortcut (2026)

Claude has keyboard shortcuts across three interfaces: Claude.ai (web), Claude Desktop (native app), and Claude Code (terminal CLI). Each surface has its own set of shortcuts optimized for its input method. This reference lists every shortcut, organized by interface, with platform-specific variations.

Throughout this guide, `Cmd` refers to the Command key on macOS and `Ctrl` refers to the Control key on Windows and Linux. Where a shortcut uses `Cmd/Ctrl`, use whichever matches your operating system.

## Claude.ai Web Shortcuts

These shortcuts work in any browser when using claude.ai.

### Chat Navigation

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + Shift + O` | Start a new chat |
| `Cmd/Ctrl + Shift + S` | Toggle the sidebar |
| `Cmd/Ctrl + Shift + ;` | Focus the message input field |
| `Cmd/Ctrl + Shift + C` | Copy the last Claude response |
| `Cmd/Ctrl + Shift + Backspace` | Delete current conversation |

### Message Input

| Shortcut | Action |
|----------|--------|
| `Enter` | Send message |
| `Shift + Enter` | New line in message (without sending) |
| `Up Arrow` | Edit last sent message (when input is empty) |
| `Cmd/Ctrl + Z` | Undo text changes in input |
| `Cmd/Ctrl + Shift + Z` | Redo text changes in input |

### File and Content

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + V` | Paste text or image from clipboard |
| Drag and drop | Upload files to the message input |

### Search and Navigation

| Shortcut | Action |
|----------|--------|
| `/` | Open slash command menu (when input is focused and empty) |
| `Cmd/Ctrl + K` | Open search/navigation palette |

## Claude Desktop Shortcuts

Claude Desktop inherits all the web shortcuts above plus adds native application shortcuts.

### Application Controls

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + ,` | Open Settings |
| `Cmd/Ctrl + Q` | Quit Claude Desktop (macOS) |
| `Alt + F4` | Quit Claude Desktop (Windows/Linux) |
| `Cmd/Ctrl + M` | Minimize window |
| `Cmd/Ctrl + W` | Close current window |
| `Cmd/Ctrl + N` | New window |

### Global Activation

Claude Desktop supports a configurable system-wide hotkey that works even when the app is in the background:

- Default: none (must be configured)
- Configuration: set `globalShortcut` in [`claude_desktop_config.json`](/claude-desktop-config-json-guide/)

```json
{
  "globalShortcut": "CommandOrControl+Shift+Space"
}
```

This brings Claude Desktop to the foreground from any application. See the [claude_desktop_config.json guide](/claude-desktop-config-json-guide/) for setup details.

### Window Management

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + +` | Zoom in |
| `Cmd/Ctrl + -` | Zoom out |
| `Cmd/Ctrl + 0` | Reset zoom |
| `F11` | Toggle fullscreen (Windows/Linux) |
| `Cmd + Ctrl + F` | Toggle fullscreen (macOS) |

## Claude Code CLI Shortcuts

Claude Code runs in your terminal and has shortcuts specific to the command-line environment.

### Session Control

| Shortcut | Action |
|----------|--------|
| `Escape` | Cancel current generation / interrupt Claude |
| `Ctrl + C` | Interrupt current operation (harder stop) |
| `Ctrl + D` | Exit Claude Code (end of input) |
| `Ctrl + L` | Clear terminal screen |

### Input and Editing

| Shortcut | Action |
|----------|--------|
| `Up Arrow` | Navigate to previous message in history |
| `Down Arrow` | Navigate to next message in history |
| `Tab` | Autocomplete file paths and commands |
| `Shift + Tab` | Toggle between compact and full response mode |
| `Ctrl + A` | Move cursor to beginning of line |
| `Ctrl + E` | Move cursor to end of line |
| `Ctrl + W` | Delete word before cursor |
| `Ctrl + U` | Delete from cursor to beginning of line |
| `Ctrl + K` | Delete from cursor to end of line |

These input shortcuts follow standard readline keybindings, so they will feel familiar if you use bash or zsh.

### Slash Commands

Type `/` followed by a command name to access Claude Code's built-in commands:

| Command | Action |
|---------|--------|
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/compact` | Summarize and compact conversation context |
| `/config` | Open configuration settings |
| `/cost` | Show token usage and cost for current session |
| `/doctor` | Diagnose common issues |
| `/init` | Initialize CLAUDE.md for current project |
| `/login` | Authenticate with Anthropic |
| `/logout` | Remove authentication |
| `/memory` | View and edit CLAUDE.md memory files |
| `/model` | Switch the active model |
| `/permissions` | View and manage tool permissions |
| `/pr-review` | Review a pull request |
| `/review` | Review code changes |
| `/status` | Show session status |
| `/terminal-setup` | Configure terminal integration |
| `/vim` | Toggle vim keybindings |

### Multi-line Input

To enter a multi-line message in Claude Code:

- Type `\` at the end of a line and press Enter to continue on the next line
- Or use the `Shift + Enter` combination if your terminal supports it

### Vim Mode

Claude Code supports vim-style keybindings for the input editor:

```
/vim
```

When enabled, the standard vim motion keys work in the input field (`h`, `j`, `k`, `l`, `w`, `b`, `i`, `a`, `Esc` to return to normal mode).

## Claude Code VS Code Extension Shortcuts

When using Claude Code through the VS Code extension, these additional shortcuts apply.

### Opening Claude Code

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + Shift + P` | Open command palette, then type "Claude" |
| `Cmd/Ctrl + L` | Open Claude Code panel (if configured) |

### Panel Controls

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + Shift + P` > "Claude: New Conversation" | Start a new conversation |
| `Cmd/Ctrl + Shift + P` > "Claude: Focus Input" | Focus the Claude Code input |

The VS Code extension respects your VS Code keybinding customizations. You can rebind any Claude Code command through VS Code's Keyboard Shortcuts editor (`Cmd/Ctrl + K, Cmd/Ctrl + S`).

## Platform Differences

### macOS vs Windows vs Linux

| Action | macOS | Windows | Linux |
|--------|-------|---------|-------|
| New chat | `Cmd + Shift + O` | `Ctrl + Shift + O` | `Ctrl + Shift + O` |
| Copy response | `Cmd + Shift + C` | `Ctrl + Shift + C` | `Ctrl + Shift + C` |
| Toggle sidebar | `Cmd + Shift + S` | `Ctrl + Shift + S` | `Ctrl + Shift + S` |
| Settings | `Cmd + ,` | `Ctrl + ,` | `Ctrl + ,` |
| Quit | `Cmd + Q` | `Alt + F4` | `Alt + F4` |
| Fullscreen | `Cmd + Ctrl + F` | `F11` | `F11` |

### Terminal Emulator Differences

Some Claude Code shortcuts may conflict with your terminal emulator's built-in shortcuts:

**iTerm2 (macOS):**
- `Cmd + K` clears the terminal in iTerm2, which may conflict with Claude Code's usage
- Configure iTerm2 to pass through keys using Profiles > Keys > Key Mappings

**Windows Terminal:**
- `Ctrl + Shift + C` is copy in Windows Terminal — this can conflict with Claude.ai's copy response shortcut
- Use the web app shortcut or change Windows Terminal's keybinding

**GNOME Terminal (Linux):**
- `Ctrl + Shift + C` is copy — same conflict as Windows Terminal
- Configure in Edit > Preferences > Shortcuts

## Customizing Shortcuts

### Claude Desktop Global Shortcut

Edit your `claude_desktop_config.json` file:

```json
{
  "globalShortcut": "Alt+Space"
}
```

See the [claude_desktop_config.json guide](/claude-desktop-config-json-guide/) for the full file location and syntax.

### Claude Code Vim Keybindings

Toggle vim mode in Claude Code:

```
/vim
```

This persists across sessions. Run `/vim` again to disable.

### VS Code Extension Keybindings

Open VS Code's Keyboard Shortcuts editor:

1. Press `Cmd/Ctrl + K` then `Cmd/Ctrl + S`
2. Search for "Claude"
3. Click the pencil icon next to any command to rebind it

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

## Tips for Efficient Shortcuts Usage

### Learn These Three First

If you remember nothing else, these three shortcuts cover 80% of use cases:

1. **`Cmd/Ctrl + Shift + O`** — start a new chat (web/desktop)
2. **`Escape`** — cancel generation (Claude Code)
3. **`Tab`** — autocomplete file paths (Claude Code)

### Terminal Navigation Shortcuts

In Claude Code, standard terminal navigation shortcuts work in the input:

- `Ctrl + A` / `Ctrl + E` — jump to start/end of line
- `Ctrl + W` — delete previous word
- `Alt + B` / `Alt + F` — move backward/forward one word (in some terminals)

These are especially useful when editing long prompts or file paths.

### Quick Model Switching

In Claude Code, type `/model` to quickly switch between models without restarting:

```
/model claude-sonnet-4-20250514
```

This is faster than exiting and restarting with the `--model` flag.

## Frequently Asked Questions

### Can I create custom keyboard shortcuts for Claude.ai?

Not directly within Claude.ai. You can use browser extensions like Vimium or custom scripts to add additional shortcuts, but Claude.ai does not expose a shortcut configuration interface.

### Do Claude Code shortcuts work over SSH?

Yes. Claude Code runs in your terminal, so the shortcuts work in any SSH session just as they do locally. Terminal-specific shortcuts (like `Cmd + K` in iTerm2) will not work over SSH — only the standard terminal shortcuts (`Ctrl + C`, `Ctrl + L`, etc.).

### How do I disable the global shortcut in Claude Desktop?

Remove the `globalShortcut` field from your `claude_desktop_config.json` file and restart Claude Desktop.

### Can I use Claude Code with screen or tmux?

Yes. Claude Code works inside tmux and screen sessions. Be aware that tmux captures `Ctrl + A` by default (for its prefix key), so you may need to press `Ctrl + A` twice or rebind your tmux prefix.

### Is there a shortcut to switch between conversations?

In Claude.ai, use `Cmd/Ctrl + Shift + S` to open the sidebar, then click a conversation. There is no keyboard shortcut for directly switching between specific conversations.

### Does Claude Code support Emacs keybindings?

The default input mode uses Emacs-style readline keybindings (`Ctrl + A`, `Ctrl + E`, `Ctrl + K`, etc.). These work out of the box without any configuration.

### Can I remap the Escape key in Claude Code?

Claude Code uses standard terminal keybindings. The Escape key behavior is built into the application. You can use terminal emulator-level key remapping if needed, but Claude Code itself does not expose shortcut customization beyond vim mode.

### Does Ctrl+C lose my conversation in Claude Code?

No. Ctrl+C interrupts the current operation but does not end the session or lose conversation history. Your conversation is automatically saved to disk as it happens.

### Are there keyboard shortcuts for switching between Claude models?

Not a direct keyboard shortcut. Use the /model slash command to switch models during a session, for example /model sonnet or /model opus.

### Can I use keyboard shortcuts in the Claude mobile app?

The Claude iOS and Android apps support basic system keyboard shortcuts when using an external keyboard, but do not have Claude-specific shortcuts beyond standard text editing.

## Related Guides

- [claude_desktop_config.json Guide](/claude-desktop-config-json-guide/) — configure Claude Desktop settings
- [The Claude Code Playbook](/playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Claude Code Getting Started](/claude-code-for-beginners-complete-getting-started-2026/) — initial CLI setup
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — understand settings files
- [Claude Code Save Conversation Guide](/claude-code-save-conversation-guide/) — manage session history
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — extend capabilities
- [Claude Code Security Best Practices](/claude-code-security-best-practices-2026/) — secure your workflow
- [Claude MCP List Command Guide](/claude-mcp-list-command-guide/) — MCP CLI command reference
- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Permission shortcuts and auto-mode

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Can I create custom keyboard shortcuts for Claude.ai?", "acceptedAnswer": {"@type": "Answer", "text": "Not directly within Claude.ai. You can use browser extensions like Vimium or custom scripts to add additional shortcuts, but Claude.ai does not expose a shortcut configuration interface."}},
    {"@type": "Question", "name": "Do Claude Code shortcuts work over SSH?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Claude Code runs in your terminal, so the shortcuts work in any SSH session just as they do locally. Terminal-specific shortcuts like Cmd+K in iTerm2 will not work over SSH."}},
    {"@type": "Question", "name": "How do I disable the global shortcut in Claude Desktop?", "acceptedAnswer": {"@type": "Answer", "text": "Remove the globalShortcut field from your claude_desktop_config.json file and restart Claude Desktop."}},
    {"@type": "Question", "name": "Can I use Claude Code with screen or tmux?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Claude Code works inside tmux and screen sessions. Be aware that tmux captures Ctrl+A by default, so you may need to press it twice or rebind your tmux prefix."}},
    {"@type": "Question", "name": "Is there a shortcut to switch between conversations?", "acceptedAnswer": {"@type": "Answer", "text": "In Claude.ai, use Cmd/Ctrl+Shift+S to open the sidebar, then click a conversation. There is no keyboard shortcut for directly switching between specific conversations."}},
    {"@type": "Question", "name": "Does Claude Code support Emacs keybindings?", "acceptedAnswer": {"@type": "Answer", "text": "The default input mode uses Emacs-style readline keybindings (Ctrl+A, Ctrl+E, Ctrl+K, etc.). These work out of the box without any configuration."}},
    {"@type": "Question", "name": "Can I remap the Escape key in Claude Code?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code uses standard terminal keybindings. The Escape key behavior is built into the application. You can use terminal emulator-level key remapping if needed."}},
    {"@type": "Question", "name": "Does Ctrl+C lose my conversation in Claude Code?", "acceptedAnswer": {"@type": "Answer", "text": "No. Ctrl+C interrupts the current operation but does not end the session or lose conversation history. Your conversation is automatically saved to disk."}},
    {"@type": "Question", "name": "Are there keyboard shortcuts for switching between Claude models?", "acceptedAnswer": {"@type": "Answer", "text": "Not a direct keyboard shortcut. Use the /model slash command to switch models during a session, for example /model sonnet or /model opus."}},
    {"@type": "Question", "name": "Can I use keyboard shortcuts in the Claude mobile app?", "acceptedAnswer": {"@type": "Answer", "text": "The Claude iOS and Android apps support basic system keyboard shortcuts when using an external keyboard, but do not have Claude-specific shortcuts beyond standard text editing."}}
  ]
}
</script>

{% endraw %}