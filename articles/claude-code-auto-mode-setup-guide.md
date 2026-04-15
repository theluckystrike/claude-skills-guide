---
layout: default
title: "Claude Code Auto Mode Setup Guide"
description: "Configure Claude Code auto mode to eliminate permission prompts with background safety checks. Setup, customization, and best practices."
date: 2026-04-15
permalink: /claude-code-auto-mode-setup-guide/
categories: [guides, claude-code]
tags: [auto-mode, permissions, configuration, workflow]
---

# Claude Code Auto Mode Setup Guide

## The Problem

You spend too much time clicking "Yes" on permission prompts while Claude Code works. Every file edit, shell command, and network request requires manual approval, breaking your flow during long implementation tasks.

## Quick Fix

Enable auto mode by pressing `Shift+Tab` to cycle through permission modes until you reach "Auto mode." Or start a session directly in auto mode:

```bash
claude --permission-mode auto
```

## What's Happening

Claude Code's permission system is tiered. In the default mode, Claude pauses and asks for approval before editing files, running shell commands, or making network requests. This is safe but interrupts long tasks.

Auto mode eliminates these prompts by running background safety checks that verify each action aligns with your request. It auto-approves tool calls that pass the safety classifier, while still blocking actions that appear dangerous or misaligned. This mode is currently a research preview.

Auto mode sits between `acceptEdits` (which only auto-approves file edits) and `bypassPermissions` (which skips all checks). It provides the best balance for trusted development work.

## Step-by-Step Fix

### Step 1: Enable auto mode for your session

Press `Shift+Tab` in the CLI to cycle through modes: `default` -> `acceptEdits` -> `plan` -> `auto`. Auto mode only appears in the cycle after you opt in.

To opt in for the first time:

```bash
claude --enable-auto-mode
```

Or start directly in auto mode:

```bash
claude --permission-mode auto
```

### Step 2: Set auto mode as your default

Add the default mode to your settings file at `~/.claude/settings.json`:

```json
{
  "permissions": {
    "defaultMode": "auto"
  }
}
```

Every new session will start in auto mode.

### Step 3: Customize the auto mode classifier

Fine-tune what auto mode allows and blocks by adding rules in your settings:

```json
{
  "autoMode": {
    "environment": [
      "Trusted repo: github.com/myorg/myrepo"
    ],
    "allow": [
      "npm run test and npm run build are always safe",
      "File edits within src/ are expected"
    ],
    "soft_deny": [
      "Never run git push without confirmation",
      "Do not modify .env files"
    ]
  }
}
```

The `environment` array provides context to the classifier. The `allow` array lists actions that should always pass. The `soft_deny` array lists actions that should prompt for confirmation even in auto mode.

### Step 4: Layer permission rules on top

Auto mode respects your existing permission rules. Pre-approve safe commands and block dangerous ones:

```json
{
  "permissions": {
    "defaultMode": "auto",
    "allow": [
      "Bash(npm run test *)",
      "Bash(npm run build)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Read(./.env)"
    ]
  }
}
```

Deny rules always take precedence, even in auto mode.

### Step 5: Use in VS Code

In VS Code, click the mode indicator at the bottom of the prompt box and select "Auto mode." You may need to enable "Allow dangerously skip permissions" in the extension settings first for auto mode to appear.

### Step 6: Use in non-interactive scripts

For CI/CD or headless usage, pass the mode flag with `-p`:

```bash
claude -p "Run the test suite" --permission-mode auto
```

## Prevention

Use auto mode for development work in trusted repositories where you review Claude's output. For sensitive operations (production deployments, credential management), switch back to `default` mode:

```text
Shift+Tab
```

Protected paths are never auto-approved regardless of mode. Writes to `.git`, `.claude`, `.vscode`, `.idea`, and `.husky` directories always prompt for confirmation to prevent accidental corruption.

For enterprise teams, administrators can disable auto mode entirely with managed settings:

```json
{
  "disableAutoMode": "disable"
}
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

**[Get Claude Code Mastery — included in Zovo Lifetime →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-auto-mode-setup-guide)**

16 CLAUDE.md templates · 80+ prompts · orchestration configs · workflow playbooks. $99 once, free forever.

---

## Related Guides

- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
- [Claude Code 2026 New Features Skills and Hooks Roundup](/claude-code-2026-new-features-skills-and-hooks-roundup/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
