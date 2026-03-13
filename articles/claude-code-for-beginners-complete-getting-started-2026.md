---
layout: post
title: "Claude Code for Beginners: Getting Started 2026"
description: "A step-by-step beginner guide to Claude Code in 2026 — installation, first session, understanding skills, and building your first AI-assisted workflow."
date: 2026-03-13
categories: [getting-started, guides]
tags: [claude-code, claude-skills, beginners, getting-started]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

Claude Code is Anthropic's command-line tool that brings Claude directly into your development workflow. Instead of switching to a browser to ask Claude questions, you work with Claude right in your terminal, and Claude can read your files, write code, and run commands. This guide walks you through getting started from zero.

## What You Need Before Starting

- A computer running macOS, Linux, or Windows (via WSL)
- Node.js installed (version 18 or later) — check with `node --version`
- An Anthropic account at console.anthropic.com
- Basic comfort with using a terminal

You do not need to know Python, be a senior developer, or understand how AI models work.

## Step 1: Install Claude Code

Claude Code installs via npm. Open your terminal and run:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation:

```bash
claude --version
```

You should see a version number. If you see "command not found", try restarting your terminal.

## Step 2: Authenticate

Claude Code needs your Anthropic API key to work. Get one at console.anthropic.com — go to "API Keys" and create a new key.

Then run:

```bash
claude auth
```

You'll be prompted to paste your API key. It gets stored securely in your system's keychain — you only need to do this once.

## Step 3: Start Your First Session

Navigate to a project folder you're working on (or create a new one for practice):

```bash
mkdir my-first-claude-project
cd my-first-claude-project
claude
```

Claude Code starts up and gives you a prompt. You're now in an interactive session. Type a message just like you would in any chat interface.

Try asking something simple:

```
> Create a JavaScript function that takes a list of numbers and returns their average.
```

Claude will write the function in the terminal. You can then ask it to save it to a file:

```
> Save that to a file called math-utils.js
```

Claude will write the file to your current directory.

## Step 4: Understand What Claude Code Can Do

Claude Code is different from regular Claude (the website) because it has **tools** — abilities to take action on your computer. By default it can:

- **Read files** in your project folder
- **Write files** and create new files
- **Run bash commands** like `npm install` or `git commit`
- **Search the web** for documentation or answers
- **Fetch web pages** like API documentation

When Claude needs to use one of these tools, it will tell you what it's doing. You can ask Claude to explain what it's doing or to check before taking actions if you prefer more control.

## Step 5: Try a Real Task

In your project folder, create a simple project:

```bash
npm init -y
claude
```

Ask Claude to build something:

```
> Build a simple command-line tool that takes a CSV file path as input and
  prints a summary of the data (number of rows, column names, and a sample
  of the first 5 rows).
```

Watch what Claude does. It will think through the problem, write the code, potentially install a CSV parsing library, test the code, and show you the result. This is the core loop: you describe what you want, Claude builds it.

## Step 6: Use Skills

Skills are plain `.md` files in `~/.claude/skills/` that make Claude especially good at specific tasks. Instead of Claude being a generalist, a skill makes it a specialist.

Claude Code includes built-in skills:

- `/tdd` — test-driven development
- `/pdf` — read and generate PDF documents
- `/docx` — read and create Word documents
- `/frontend-design` — UI component design
- `/supermemory` — extended memory across sessions
- `/xlsx`, `/pptx`, `/canvas-design`, `/webapp-testing`, `/skill-creator`

### Using a Skill

To use the `/tdd` skill (test-driven development), type:

```
/tdd Write tests for my math-utils.js file
```

Claude will now operate in TDD mode — it'll write tests first, then implementation.

### Installing Community Skills

To use a community skill, place the `.md` file in `~/.claude/skills/`:

```bash
cp my-skill.md ~/.claude/skills/
```

Then start a new Claude Code session and invoke it with `/my-skill`.

## Step 7: Set Up CLAUDE.md

The `CLAUDE.md` file is like a briefing document that Claude reads at the start of every session. Put information about your project there so Claude does not need you to explain it every time.

Create one in your project root:

```
> Create a CLAUDE.md file for this project with the project structure and key conventions
```

Claude will generate a draft. Review it and add any important details: what the project does, technologies you're using, coding conventions, how to run tests.

## Step 8: Common Beginner Commands

| Command | What it does |
|---------|--------------|
| `claude` | Start a session in the current directory |
| `/help` | Show available commands |
| `/clear` | Clear conversation history (fresh start) |
| `/exit` | End the session |

Within the conversation, you do not need any special syntax. Just type what you want.

## Common Beginner Mistakes

**Trying to do too much in one message**: Break large requests into steps. "Build me a full e-commerce site" will not go well. "Build a product listing page that shows items from a JSON file" is a good start.

**Not reviewing what Claude writes**: Claude is good but not perfect. Always read the code it writes, especially before running it or committing it to git.

**Forgetting to set up CLAUDE.md**: Without it, Claude has to rediscover your project every session. Spending 10 minutes on CLAUDE.md saves hours over time.

**Running Claude Code in the wrong directory**: Claude can only read files in your current directory and subdirectories. Make sure you're in your project root when starting a session.

## What to Try Next

Once you're comfortable with the basics:

1. **Use the `/supermemory` skill** — it gives Claude extended memory for project context
2. **Try the `/tdd` skill** — great for adding tests to existing code
3. **Try `/frontend-design`** — builds React components to match your design system
4. **Read the hooks guide** — learn to control what Claude can and can't do

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
