---

layout: default
title: "Claude Code + Zellij: Terminal Workflow (2026)"
description: "Set up Claude Code with Zellij terminal multiplexer. Persistent sessions, split panes, and layout configs for productive coding. Tested 2026."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-for-zellij-terminal-multiplexer-workflow/
categories: [workflows]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---



Zellij is a modern terminal multiplexer written in Rust that offers a fresh approach to terminal session management. Unlike traditional multiplexers, Zellij provides a plugin system, layout management, and first-class support for strider plugins that make it particularly well-suited for AI-assisted development workflows. This guide explores how to integrate Claude Code with Zellij to create a powerful, persistent development environment.

## Why Zellij for Claude Code Development

Zellij brings several advantages that make it an excellent choice for Claude Code workflows. The layout system allows you to predefined terminal arrangements that persist across sessions, meaning you can set up your ideal development environment once and restore it instantly. The plugin ecosystem enables extending functionality without external dependencies, and the Rust-based architecture provides excellent performance even with large terminal histories.

The strider plugins in Zellij are particularly relevant for AI workflows, as they allow for closer integration with development tools and automation scripts. When combined with Claude Code, you get persistent context, organized workspaces, and the ability to run multiple AI-assisted tasks in parallel.

## Setting Up Zellij for Claude Code

Before integrating with Claude Code, ensure Zellij is installed on your system. The installation process varies by operating system:

```bash
On macOS with Homebrew
brew install zellij

On Linux
curl -sL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin/

On Windows (via WSL)
Follow Linux installation within your WSL environment
```

After installation, create a default layout that works well with Claude Code. Zellij layouts are stored in the `~/.config/zellij/layouts` directory. Create a file called `claude-default.kdl`:

```kdl
layout {
 pane size=1 border="none" {
 pane command="echo" args="Claude Code Workspace" {
 size 1
 }
 }
 pane split_direction="vertical" {
 pane
 pane
 }
}
```

This creates a layout with a status bar pane at the top and two vertical panes below for running Claude Code and other development tools simultaneously.

## Persistent Claude Code Sessions in Zellij

One of Zellij's strongest features is its session persistence. Unlike tmux, which requires explicit session attachment, Zellij sessions can be configured to survive terminal closures and automatically reattach when you return.

Create a wrapper script to manage Claude Code sessions with Zellij:

```bash
#!/bin/bash
claude-zellij-session.sh

SESSION_NAME="claude-dev"
PROJECT_DIR="${1:-.}"

Check if session already exists
if zellij list-sessions | grep -q "$SESSION_NAME"; then
 echo "Attaching to existing session: $SESSION_NAME"
 zellij attach "$SESSION_NAME"
else
 echo "Creating new session: $SESSION_NAME"
 cd "$PROJECT_DIR"
 zellij new-session -d -s "$SESSION_NAME"
fi
```

Make this script executable and use it to start Claude Code in a persistent Zellij session. This approach ensures your Claude Code session survives SSH disconnections, system restarts, and terminal closures.

## Running Multiple Claude Code Instances in Parallel

Zellij's pane and layout system makes it straightforward to run multiple Claude Code instances for parallel task processing. This is particularly useful when you need to work on different features simultaneously or when running tests while continuing development.

Create a multi-pane layout for parallel work:

```kdl
layout {
 pane
 pane split_direction="horizontal" {
 pane
 pane
 }
}
```

This layout creates a main pane for primary development with two smaller panes below for secondary tasks like running tests or monitoring logs. You can then start Claude Code in each pane with different project contexts:

```bash
In the main pane
claude --print > /tmp/claude-main.md

In pane 2
cd /path/to/backend && claude

In pane 3
cd /path/to/tests && claude
```

## Integrating Zellij Layouts with Claude Code Workflows

Zellij layouts can be customized to match specific development workflows. For a typical web development scenario with Claude Code, consider this layout:

```kdl
layout {
 pane size=2 border="none" {
 pane command="zellij" args="action scrollback up 100" {
 size 2
 }
 }
 pane split_direction="vertical" {
 pane command="claude" {
 size 1
 }
 pane split_direction="horizontal" {
 pane command="npm" args="run dev" {
 size 1
 }
 pane command="docker" args="ps" {
 size 1
 }
 }
 }
}
```

This layout dedicates space for Claude Code while keeping development servers and container monitoring visible. The top pane provides room for displaying Claude Code's thinking process and tool outputs.

## Using Zellij Plugins with Claude Code

Zellij supports plugins that can enhance your Claude Code workflow. The official catppuccin plugin, for example, provides a pleasing color scheme that reduces eye strain during long coding sessions with Claude Code:

```bash
Install the catppuccin plugin
zellij plugin install https://github.com/zellij-org/zellij-plugin-catppuccin

Create a configuration that applies the theme
mkdir -p ~/.config/zellij
cat > ~/.config/zellij/config.kdl << 'EOF'
themes {
 catppuccin-mocha
}
theme "catppuccin-mocha"
EOF
```

For development workflows involving Claude Code, consider creating custom plugins that automate common tasks. The plugin system uses WebAssembly, allowing you to write custom functionality in Rust that interacts with your terminal sessions.

## Advanced Workflow: Claude Code with Zellij and Git

Combine Zellij's session management with Git operations for a complete AI-assisted development workflow. Create a layout that separates your Claude Code session from Git operations:

```bash
#!/bin/bash
start-dev-workflow.sh

SESSION="dev-$(date +%Y%m%d)"

zellij new-session -d -s "$SESSION"

Wait for session to initialize
sleep 1

Create panes for different tasks
zellij send-keyseq "C-a" "v" # Split vertically
zellij send-keyseq "C-a" "h" # Split horizontally

In main pane: Claude Code
zellij send-keys "claude" "Enter"

Navigate to other pane
zellij send-keyseq "C-a" "Left"

In second pane: Git status
zellij send-keys "git status" "Enter"

Navigate to third pane 
zellij send-keyseq "C-a" "Down"
zellij send-keys "npm run dev" "Enter"
```

This script creates a complete development environment with Claude Code, Git monitoring, and development servers all running simultaneously.

## Best Practices for Zellij and Claude Code Integration

When combining Zellij with Claude Code, follow these best practices to maximize productivity:

Session Naming Conventions: Use descriptive session names that indicate the project and purpose. A session named `claude-api-v2-feature-auth` immediately communicates context when you have multiple sessions running.

Layout Persistence: Save your most-used layouts to the default layouts directory. Zellij automatically loads `default.kdl` when starting a new session, so place your preferred layout there.

Scrollback Configuration: Increase the scrollback buffer to retain Claude Code's full output history. Add this to your Zellij configuration:

```kdl
scrollback_lines 10000
```

Key Binding Optimization: Customize key bindings to reduce friction when switching between panes. The default prefix is `Ctrl+a`, which you can change if it conflicts with other tools:

```kdl
keybinds {
 unbind "Ctrl a" { - |
 Tab => { switch_to_next_pane; }
 }
}
```

## Conclusion

Zellij provides a solid foundation for Claude Code workflows through its session persistence, flexible layouts, and plugin ecosystem. By setting up proper layouts, using multi-pane configurations, and creating automation scripts, you can build a development environment that maintains context across sessions and enables parallel AI-assisted development. The combination of Zellij's modern architecture with Claude Code's AI capabilities creates a powerful, productive workflow for developers working on complex projects.

Start with simple layouts and gradually add complexity as you become more comfortable with Zellij's capabilities. The investment in setting up your ideal environment will pay dividends in sustained productivity and reduced context loss throughout your development sessions.



---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-zellij-terminal-multiplexer-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Automated Code Documentation Workflow with Claude Skills](/automated-code-documentation-workflow-with-claude-skills/)
- [Before and After: Switching to Claude Code Workflow](/before-and-after-switching-to-claude-code-workflow/)
- [Claude Code for Zellij — Workflow Guide](/claude-code-for-zellij-multiplexer-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


