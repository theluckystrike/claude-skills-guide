---
sitemap: false
layout: default
title: "Claude Code For Vhs Terminal (2026)"
description: "Learn how to integrate Claude Code with VHS for creating professional terminal recordings, GIFs, and demos for your projects."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-vhs-terminal-recorder-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---
Claude Code for VHS Terminal Recorder Workflow

Creating high-quality terminal recordings for documentation, demos, and tutorials has never been easier than with the combination of Claude Code and VHS (Video Haskell System). This powerful workflow allows developers to automate the creation of terminal sessions that can be exported as GIFs, MP4s, or WebM files. this guide covers how to integrate Claude Code with VHS to streamline your terminal recording workflow.

What is VHS?

VHS is a terminal recorder that allows you to script and record terminal sessions. Unlike traditional screen recording tools, VHS lets you write your terminal sessions as code, making them reproducible, version-controllable, and easy to edit. The tool parses a simple scripting language (a Haskell DSL) and renders the output as a video file.

Key features of VHS include:
- Script-based terminal recording
- Multiple output formats (GIF, MP4, WebM, SVG)
- Customizable themes and fonts
- Support for cursor animations and typing effects
- Frame-by-frame control over the recording

## Setting Up Claude Code with VHS

Before diving into the workflow, ensure you have both Claude Code and VHS installed on your system.

## Installing VHS

You can install VHS using various methods depending on your operating system:

```bash
Using Homebrew on macOS
brew install vhs

Using npm
npm install -g @vhs-cli/vhs

Using Cargo (Rust)
cargo install vhs-cli
```

## Verifying Installation

After installation, verify that VHS is working correctly:

```bash
vhs --version
```

## Creating Your First VHS Script with Claude Code

The true power of this workflow emerges when you use Claude Code to help draft, refine, and execute your VHS scripts. Claude Code can assist with writing the VHS syntax, troubleshooting errors, and suggesting improvements to make your recordings more professional.

## Basic VHS Script Structure

A VHS script consists of commands that tell the recorder what to display. Here's a basic example:

```
Output demo.gif
Set Theme "Dracula"
Set FontSize 24
Set Width 1200
Set Height 800

Type "ls -la"
Enter
Sleep 500ms

Type "git status"
Enter
Sleep 1s
```

This script creates a GIF showing the `ls -la` and `git status` commands being executed with the Dracula theme.

## How Claude Code Enhances VHS Workflows

Claude Code can assist you in several ways when working with VHS:

1. Script Generation

Describe what you want to record, and Claude Code can generate the VHS script for you:

> "Create a VHS script showing a git workflow: checking status, staging files, and committing with a message."

Claude Code will produce the appropriate VHS commands:

```
Output git-workflow.gif
Set Theme "Nord"
Set FontSize 20
Set Width 1400
Set Height 900

Type "git status"
Enter
Sleep 500ms

Type "git add ."
Enter
Sleep 500ms

Type "git commit -m 'Add new feature'"
Enter
Sleep 1s

Type "git push origin main"
Enter
Sleep 2s
```

2. Troubleshooting

When your VHS script doesn't produce the expected output, Claude Code can help debug:

- Identifying syntax errors in your script
- Suggesting correct command sequences
- Recommending appropriate sleep durations for readability

3. Advanced Customization

Claude Code can help implement advanced VHS features:

- Custom color schemes beyond built-in themes
- Complex typing patterns with variable speeds
- Multi-pane layouts using Tmux integration
- Watermarks and frame annotations

## Practical Examples

## Example 1: API Documentation Recording

Create a recording showing API endpoint testing with curl:

```
Output api-demo.gif
Set Theme "Monokai"
Set FontSize 18
Set Width 1200
Set Height 800
Set Padding 1

Type "# Testing our new REST API"
Enter
Sleep 500ms

Type "curl -X GET https://api.example.com/users"
Enter
Sleep 2s

Type "curl -X POST https://api.example.com/users \\"
Enter
Sleep 100ms
Type " -H 'Content-Type: application/json' \\"
Enter
Sleep 100ms
Type " -d '{\"name\": \"John\"}'"
Enter
Sleep 2s
```

## Example 2: Project Setup Tutorial

Demonstrate initializing a new project:

```
Output project-setup.gif
Set Theme "GitHub Dark"
Set FontSize 20
Set Width 1280
Set Height 720

Type "npx create-next-app@latest my-app"
Enter
Sleep 3s

Type "cd my-app"
Enter
Sleep 200ms

Type "npm run dev"
Enter
Sleep 3s

Type "# Server running at http://localhost:3000"
Enter
```

## Optimizing Your Workflow

## Best Practices for Claude Code + VHS Integration

1. Plan Your Script First: Before generating code, outline the sequence of commands you want to record. This helps Claude Code produce more accurate scripts.

2. Use Appropriate Sleep Durations: Different commands need different pause times. File listings need less time (`300-500ms`), while command outputs that require reading need more (`1-3s`).

3. Test Incremental Changes: Build your VHS script piece by piece. Run the renderer after each addition to catch errors early.

4. Use Claude Code's Context: When working on complex scripts, share previous attempts with Claude Code so it can refine the output.

5. Version Control Your Scripts: Store VHS scripts alongside your code in version control. This makes it easy to update recordings when commands change.

## Common Issues and Solutions

## Issue: Text appears cut off or wrapped incorrectly

Solution: Adjust the `Set Width` and `Set Height` values in your script. Higher values provide more space for terminal output.

## Issue: Animations are too fast to follow

Solution: Increase sleep durations between commands. A good rule is to add at least `1s` after commands that produce significant output.

## Issue: Output file is too large

Solution: 
- Reduce dimensions with smaller width/height values
- Use fewer colors (set simpler themes)
- Limit the number of frames by reducing unnecessary sleep times

## Advanced Techniques

## Tmux Integration for Complex Demos

VHS supports Tmux, allowing you to create multi-pane recordings:

```
Output multi-pane.gif
Set Theme "Nord"
Set Width 1400
Set Height 900

TmuxSplitVertical
TmuxSendKeys "top" Enter
Sleep 1s

TmuxSelectPane right
TmuxSendKeys "htop" Enter
Sleep 2s
```

This creates a split-screen demo with different commands running in each pane.

## Custom Themes and Styling

While VHS comes with built-in themes, you can create custom color schemes:

```
Output custom.gif
Set ThemeFile "./my-custom-theme.tape"
Set FontSize 16
Set FontFamily "JetBrains Mono"

Type "echo 'Hello, World!'"
Enter
```

## Conclusion

The combination of Claude Code and VHS provides a powerful workflow for creating professional terminal recordings. By using Claude Code's ability to generate, debug, and refine VHS scripts, you can efficiently produce high-quality demos, tutorials, and documentation for your projects. Start incorporating this workflow into your development process, and you'll find creating terminal recordings becomes faster, more reliable, and far less frustrating.

Remember to experiment with different themes, fonts, and recording configurations to find the perfect setup for your specific needs. With practice, you'll be producing polished terminal recordings that enhance your documentation and captivate your audience.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-vhs-terminal-recorder-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Huh Forms Terminal Workflow Guide](/claude-code-for-huh-forms-terminal-workflow-guide/)
- [Claude Code for k9s Kubernetes Terminal Workflow Guide](/claude-code-for-k9s-kubernetes-terminal-workflow-guide/)
- [Claude Code for Slides Terminal Presentation Workflow](/claude-code-for-slides-terminal-presentation-workflow/)
- [Claude Code for WezTerm Terminal Workflow Guide](/claude-code-for-wezterm-terminal-workflow-guide/)
- [Claude Code for Tabby Terminal — Workflow Guide](/claude-code-for-tabby-terminal-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Get started →** Generate your project setup with our [Project Starter](/starter/).

