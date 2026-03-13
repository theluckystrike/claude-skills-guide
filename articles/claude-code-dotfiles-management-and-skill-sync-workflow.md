---
layout: default
title: "Claude Code Dotfiles Management and Skill Sync Workflow"
description: "A practical workflow for managing Claude Code dotfiles across machines and synchronizing skills. Includes git-based dotfiles management, skill organization patterns, and automation scripts."
date: 2026-03-14
categories: [workflow]
tags: [claude-code, dotfiles, skill-sync, workflow, automation]
author: theluckystrike
reviewed: false
score: 7
---

# Claude Code Dotfiles Management and Skill Sync Workflow

Managing Claude Code configuration across multiple machines requires a deliberate approach to dotfiles and skill synchronization. This guide presents a practical workflow for tracking your Claude settings in git, organizing skills for portability, and keeping everything synchronized between workstations.

## Why Track Claude Config in Dotfiles

Your Claude Code setup includes several directories that benefit from version control: skill definitions, custom prompts, configuration files, and agent instructions. When you work across multiple machines—perhaps a desktop at home and a laptop on the go—having these tracked in git eliminates the friction of manual replication.

The standard Claude Code directories worth tracking include `~/.claude/skills/` for skill definitions, `~/.claude/agents/` for custom agent configurations, and `~/.claude/settings.json` for user preferences. Each of these can become part of a dotfiles repository with appropriate `.gitignore` rules.

## Setting Up Your Dotfiles Repository

Create a dedicated directory for Claude-specific configuration within your existing dotfiles setup:

```bash
mkdir -p ~/dotfiles/claude
cd ~/dotfiles
git init
```

Add a `.gitignore` that preserves your skills while excluding machine-specific data:

```
# Ignore local-only settings
settings.local.json
.env
*.local.md

# Keep skills but ignore cache
skills/
!.claude/
```

The key insight is treating `skills/` as source-controlled content while acknowledging that some files—like runtime cache or local overrides—should remain machine-specific.

## Skill Organization Patterns

Organizing skills effectively improves discoverability and reduces duplication. Consider a flat structure with descriptive filenames rather than deep nesting:

```
~/.claude/skills/
├── pdf-generate.md
├── tdd-workflow.md
├── xlsx-report.md
├── frontend-design.md
├── supermemory-notes.md
└── docx-export.md
```

Each skill file should be self-contained. If you find yourself referencing the same prompts across multiple skills, extract common instructions into a shared file and reference it using relative includes where supported.

For skills you use frequently, create symlinks to shorter aliases:

```bash
ln -s pdf-generate.md ~/.claude/skills/pdf.md
ln -s tdd-workflow.md ~/.claude/skills/tdd.md
```

This lets you invoke `/pdf` or `/tdd` instead of longer names.

## Cross-Machine Sync Strategies

Synchronizing dotfiles between machines requires choosing a sync mechanism that fits your workflow. Three common approaches work well:

**Direct git push**: Clone your dotfiles repository on each machine and run `git pull` manually or via a cron job. This approach gives you full control but requires discipline.

**Bare repository with worktree**: Set up a bare dotfiles repository and check out working files:

```bash
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles remote add origin git@github.com:yourusername/dotfiles.git
dotfiles checkout
```

This keeps your actual dotfiles in place while storing them in git.

**Automation wrapper**: Create a simple sync script that handles pull, merge, and push:

```bash
#!/bin/bash
# sync-claude.sh
cd ~/dotfiles/claude
git pull --rebase origin main
# Add new skills if any
git add -A
git commit -m "Sync $(date +%Y-%m-%d)"
git push origin main
```

Run this manually after establishing new skills, or schedule it daily with cron.

## Skill Sync Within Claude Sessions

Within an active Claude session, you can refresh skills without restarting. The exact mechanism depends on your Claude Code version, but typically creating or modifying a skill file triggers automatic reloading.

For manual refresh, you can invoke a built-in command if available, or simply start a new session. When you modify a skill like `tdd-workflow.md`, test it immediately:

```
/tdd create user service
```

If the skill loads correctly, you'll see its instructions applied to the session. Common failure points include syntax errors in front matter, broken YAML, or referenced files that don't exist.

## Practical Skill Examples

Here are skills that benefit from dotfiles management:

**PDF generation skill** (`pdf.md`):
```markdown
# PDF Generation Skill
Use this skill when the user asks to create, modify, or extract from PDF files.
Available tools: pdf skill for creation, pdftotext for extraction.
```

**Test-driven development** (`tdd.md`):
```markdown
# TDD Workflow Skill
For this skill, follow the red-green-refactor cycle:
1. Write a failing test
2. Write minimal code to pass
3. Refactor for clarity
Always start with tests before implementation.
```

**Spreadsheet operations** (`xlsx.md`):
```markdown
# XLSX Skill
Use for creating Excel files with formulas, formatting, charts.
Python required: pip install openpyxl
```

Each skill file remains portable when stored in your dotfiles repository.

## Handling Machine-Specific Variations

Some skills require machine-specific configuration. A skill that runs tests might need different paths on different machines. Handle this through environment detection:

```bash
# In your skill or associated script
if [[ "$OSTYPE" == "darwin"* ]]; then
  TEST_CMD="python3 -m pytest"
else
  TEST_CMD="pytest"
fi
```

Alternatively, use a local override file that your dotfiles git repository ignores but you maintain manually on each machine.

## Automation for Continuous Sync

For teams or power users who want near-real-time synchronization, consider a simple daemon:

```bash
#!/bin/bash
# watch-and-push.sh
while true; do
  inotifywait -e close_write ~/dotfiles/claude/ 2>/dev/null
  cd ~/dotfiles
  git add claude/
  git commit -m "Auto-sync $(date +%H:%M:%S)" || true
  git push origin main
  sleep 5
done
```

This watches for file changes and automatically commits and pushes. Adjust the tool (`inotifywait` for Linux, `fswatch` for macOS) based on your operating system.

## Conclusion

Managing Claude Code dotfiles and skills through git provides consistency across machines, backup protection, and the ability to share configurations with teammates. Start by organizing skills in a flat, descriptive structure, choose a sync strategy that matches your workflow, and automate incremental updates to keep machines in sync.

The initial setup takes maybe thirty minutes, but the time saved over months of use far exceeds the investment. Your Claude configuration becomes as portable as your dotfiles—exactly the way it should be.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
